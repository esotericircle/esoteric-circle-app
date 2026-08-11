import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {chiaveDelGiorno} from "./giorno";
import {
  Budget,
  Piano,
  BUDGET,
  budgetValido,
  decidi,
  pianoValido,
  restaOggi,
} from "./budget";
import {
  CAUSALI_CHIEDIBILI,
  causaleValida,
  importoRichiesto,
  saldoDopo,
} from "./borsellino";

/**
 * CIO' CHE VIVE SUL SERVER, ordine N.
 *
 * **La regola che tiene in piedi tutto: il client non scrive mai.** Memoria,
 * contatori del giorno e saldo Eos stanno sotto `users/{uid}` e le regole di
 * sicurezza vietano al client ogni scrittura su quel ramo. Si scrive solo da
 * qui, dove il giorno lo decide il server e i limiti li decide la matrice del
 * server. Un limite che il telefono puo' riscrivere non e' un limite, e fino
 * a oggi il telefono poteva riscriverlo tutto: bastava spostare l'ora avanti
 * di un giorno, verificato eseguendo.
 *
 * **App Check resta spento anche qui**, per la stessa ragione scritta accanto
 * a `natalChart`: l'app arriva da App Distribution e Play Integrity non la
 * riconosce. Al posto suo ogni callable PRETENDE un utente autenticato e
 * lavora solo sul ramo di quell'uid: l'uid non arriva mai dal corpo della
 * richiesta, arriva dal token, quindi nessuno puo' toccare i dati di un
 * altro nemmeno chiedendolo.
 */
admin.initializeApp();
const db = admin.firestore();

/** La regione e le impostazioni comuni delle callable del Cerchio. */
const OPZIONI_DEL_CERCHIO = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
};

/** L'uid dal token, mai dal corpo. Senza token non si fa niente. */
function uidDi(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Serve un account, anche anonimo, per parlare col Cerchio."
    );
  }
  return uid;
}

const utente = (uid: string) => db.collection("users").doc(uid);
const contatoriDoc = (uid: string) =>
  utente(uid).collection("stato").doc("contatori");
const borsellinoDoc = (uid: string) =>
  utente(uid).collection("stato").doc("borsellino");
const abbonamentoDoc = (uid: string) =>
  utente(uid).collection("stato").doc("abbonamento");

/** I quattro budget a zero, come nascono e come ribaltano. */
function contatoriVuoti(giorno: string): Record<string, unknown> {
  const spesi: Record<string, number> = {};
  for (const b of BUDGET) spesi[b] = 0;
  return {giorno, spesi};
}

/**
 * IL PIANO LO DICE IL SERVER, non il client.
 *
 * Oggi il documento dell'abbonamento non lo scrive nessuno e vale free per
 * tutti: e' il posto dove l'abbonamento comprato sul sito si attacchera' alla
 * persona, ed esiste gia' perche' quel giorno non ci sia da cambiare la forma
 * dei dati sotto i piedi di chi li sta usando.
 */
async function pianoDi(uid: string): Promise<Piano> {
  const snap = await abbonamentoDoc(uid).get();
  return pianoValido(snap.data()?.piano);
}

function residuiDi(
  piano: Piano,
  spesi: Record<string, number>
): Record<string, number | null> {
  const resta: Record<string, number | null> = {};
  for (const b of BUDGET) {
    resta[b] = restaOggi(b as Budget, piano, spesi[b] ?? 0);
  }
  return resta;
}

/**
 * LO STATO DEL CERCHIO: giorno del server, residui, saldo, piano.
 *
 * E' la prima cosa che l'app chiede all'avvio e al ritorno in primo piano.
 * Ribalta il giorno se e' cambiato, cosi' chi apre l'app dopo mezzanotte
 * trova i budget interi senza che nessuno debba passare a mezzanotte.
 */
export const statoDelCerchio = onCall(OPZIONI_DEL_CERCHIO, async (request) => {
  const uid = uidDi(request);
  const giorno = chiaveDelGiorno();
  const piano = await pianoDi(uid);

  const spesi = await db.runTransaction(async (tx) => {
    const snap = await tx.get(contatoriDoc(uid));
    const dati = snap.data();
    if (!dati || dati.giorno !== giorno) {
      tx.set(contatoriDoc(uid), contatoriVuoti(giorno));
      return {} as Record<string, number>;
    }
    return (dati.spesi ?? {}) as Record<string, number>;
  });

  const borsellino = await borsellinoDoc(uid).get();
  return {
    giorno,
    piano,
    spesi,
    resta: residuiDi(piano, spesi),
    saldoEos: (borsellino.data()?.saldo as number) ?? 0,
  };
});

/**
 * CONSUMA UN BUDGET DEL GIORNO, e la decisione e' del server.
 *
 * **L'identificativo del movimento non e' un vezzo.** Senza rete l'app accoda
 * il consumo e lo rimanda al ritorno: se la risposta si perde e il client
 * ritenta, senza idempotenza la persona pagherebbe due volte lo stesso gesto.
 * Il documento in `consumi/{id}` E' il segno che quel gesto e' gia' stato
 * contato, e si scrive dentro la stessa transazione del contatore.
 */
export const consumaDelGiorno = onCall(OPZIONI_DEL_CERCHIO, async (request) => {
  const uid = uidDi(request);
  const budget = budgetValido(request.data?.budget);
  if (!budget) {
    throw new HttpsError("invalid-argument", "Budget sconosciuto.");
  }
  const id = String(request.data?.idMovimento ?? "").trim();
  if (id.length < 8 || id.length > 200) {
    throw new HttpsError(
      "invalid-argument",
      "Ogni consumo porta il suo identificativo."
    );
  }
  const piano = await pianoDi(uid);
  const giorno = chiaveDelGiorno();

  return db.runTransaction(async (tx) => {
    const segno = utente(uid).collection("consumi").doc(id);
    const gia = await tx.get(segno);
    const snap = await tx.get(contatoriDoc(uid));
    const dati = snap.data();
    const spesi: Record<string, number> =
      dati && dati.giorno === giorno ?
        {...((dati.spesi ?? {}) as Record<string, number>)} :
        {};

    if (gia.exists) {
      // Gia' contato: si risponde com'e' andata allora, senza contare di
      // nuovo. Ritentare deve essere innocuo.
      return {
        giorno,
        concesso: (gia.data()?.concesso as boolean) ?? true,
        resta: residuiDi(piano, spesi)[budget],
        gia: true,
      };
    }

    const esito = decidi(budget, piano, spesi[budget] ?? 0);
    if (esito.concesso) {
      spesi[budget] = (spesi[budget] ?? 0) + 1;
      tx.set(contatoriDoc(uid), {giorno, spesi});
    }
    tx.set(segno, {
      budget,
      giorno,
      concesso: esito.concesso,
      quando: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {
      giorno,
      concesso: esito.concesso,
      resta: esito.resta,
      motivo: esito.motivo ?? null,
      gia: false,
    };
  });
});

/**
 * MUOVE GLI EOS, e il valore lo decide il server.
 *
 * Il client dice cosa ha compiuto oppure cosa vuole spendere, mai quanto vale
 * un premio: il listino sta in `borsellino.ts`. Saldo e movimento nascono
 * nella stessa transazione, quindi non possono discordare, e l'identificativo
 * rende innocuo ogni ritentativo.
 */
export const muoviGliEos = onCall(OPZIONI_DEL_CERCHIO, async (request) => {
  const uid = uidDi(request);
  const causale = causaleValida(request.data?.causale);
  if (!causale || !CAUSALI_CHIEDIBILI.includes(causale)) {
    throw new HttpsError("invalid-argument", "Causale non chiedibile.");
  }
  const motivo = String(request.data?.motivo ?? "").trim();
  if (motivo.length === 0 || motivo.length > 80) {
    throw new HttpsError("invalid-argument", "Motivo mancante.");
  }
  const id = String(request.data?.idMovimento ?? "").trim();
  if (id.length < 8 || id.length > 200) {
    throw new HttpsError(
      "invalid-argument",
      "Ogni movimento porta il suo identificativo."
    );
  }
  const importo = importoRichiesto(causale, motivo, request.data?.quanti);
  if (importo === null) {
    throw new HttpsError("invalid-argument", "Movimento non ammesso.");
  }

  return db.runTransaction(async (tx) => {
    const movimento = utente(uid).collection("movimenti").doc(id);
    const gia = await tx.get(movimento);
    const snap = await tx.get(borsellinoDoc(uid));
    const saldo = (snap.data()?.saldo as number) ?? 0;
    if (gia.exists) return {saldo, applicato: false, gia: true};

    const dopo = saldoDopo(saldo, importo);
    if (dopo === null) {
      throw new HttpsError("failed-precondition", "Gli Eos non bastano.");
    }
    tx.set(movimento, {
      causale,
      motivo,
      importo,
      saldoDopo: dopo,
      quando: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(borsellinoDoc(uid), {
      saldo: dopo,
      aggiornato: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {saldo: dopo, applicato: true, gia: false};
  });
});

/**
 * SCRIVE LA MEMORIA, perche' il client non puo' piu' farlo da solo.
 *
 * La memoria si LEGGE dritta da Firestore (le regole consentono la lettura
 * del proprio ramo, ed e' la lettura che deve essere veloce), ma si SCRIVE
 * solo da qui: e' la stessa regola dei contatori e del saldo, e vale anche
 * dove il dato sembra innocuo, perche' una porta lasciata aperta su un ramo
 * e' aperta su tutto il ramo.
 */
export const scriviLaMemoria = onCall(OPZIONI_DEL_CERCHIO, async (request) => {
  const uid = uidDi(request);
  const operazione = String(request.data?.operazione ?? "");
  const campi = (request.data?.campi ?? {}) as Record<string, unknown>;
  const maestro = String(request.data?.maestro ?? "").trim();

  // Un tetto alla dimensione, come nelle regole di prima: senza, un client
  // compromesso riempie il progetto un documento alla volta.
  if (JSON.stringify(campi).length > 100000) {
    throw new HttpsError("invalid-argument", "Scrittura troppo grande.");
  }
  const conTempo = {
    ...campi,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  switch (operazione) {
  case "profilo":
    await utente(uid).set(conTempo, {merge: true});
    return {scritto: true};
  case "memoriaDelMaestro": {
    if (!maestro) {
      throw new HttpsError("invalid-argument", "Maestro mancante.");
    }
    await utente(uid)
      .collection("maestri")
      .doc(maestro)
      .set(conTempo, {merge: true});
    return {scritto: true};
  }
  case "messaggio": {
    if (!maestro) {
      throw new HttpsError("invalid-argument", "Maestro mancante.");
    }
    const rif = await utente(uid)
      .collection("maestri")
      .doc(maestro)
      .collection("messages")
      .add({
        ...campi,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    return {scritto: true, id: rif.id};
  }
  case "ultimoMessaggio": {
    if (!maestro) {
      throw new HttpsError("invalid-argument", "Maestro mancante.");
    }
    const col = utente(uid)
      .collection("maestri")
      .doc(maestro)
      .collection("messages");
    const ultimi = await col.orderBy("createdAt", "desc").limit(1).get();
    if (ultimi.empty) return {scritto: false};
    await ultimi.docs[0].ref.set(campi, {merge: true});
    return {scritto: true};
  }
  default:
    throw new HttpsError("invalid-argument", "Operazione sconosciuta.");
  }
});

/**
 * IL DIRITTO ALL'OBLIO, e non e' una gentilezza: e' un obbligo.
 *
 * Cancella il ramo dell'utente con tutto quello che ci sta sotto (memoria,
 * contatori, movimenti) e POI l'account stesso, cosi' non resta un uid vivo
 * senza dati ne' dati vivi senza uid. L'ordine conta: cancellando prima
 * l'account il token diventerebbe invalido e la cancellazione dei dati
 * resterebbe a meta'.
 */
export const cancellaIlCerchio = onCall(
  OPZIONI_DEL_CERCHIO,
  async (request) => {
    const uid = uidDi(request);
    await db.recursiveDelete(utente(uid));
    try {
      await admin.auth().deleteUser(uid);
    } catch (err) {
      // I dati non ci sono piu', ed e' la parte che conta: se l'account non
      // si cancella lo si dice, invece di far credere che sia tutto fatto.
      logger.error("cancellaIlCerchio: account non cancellato", {
        err: String(err),
      });
      return {datiCancellati: true, accountCancellato: false};
    }
    return {datiCancellati: true, accountCancellato: true};
  }
);
