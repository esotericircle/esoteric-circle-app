import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// **FIREBASE-ADMIN E' MODULARE DALLA 14, ordine BF voce 05.k.** Il
// namespace unico non esiste piu': si importa dal modulo che serve. Il
// rialzo porta il runtime a Node 22 (il 20 viene dismesso il 30 ottobre
// 2026) e spegne l'avviso EBADENGINE sul PC del fondatore, che gira Node 24.
import {createHash} from "node:crypto";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
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
  CamminoCustodito,
  fondiCammini,
  leggiCammino,
} from "./cammino";
import {
  BONUS_DELLA_CONDIVISIONE,
  ACCREDITO_DEL_GIORNO,
  BENVENUTO,
  CAUSALI_CHIEDIBILI,
  PREZZI_DEL_RISCATTO,
  TETTO_CONDIVISIONI_PREMIATE,
  budgetDelRiscatto,
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
initializeApp();
const db = getFirestore();

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

/**
 * LA REGISTRAZIONE, letta dal token e mai dal corpo. Ordine BH voce 01.
 *
 * Il benvenuto (250) non e' piu' la dote di nascita: e' il premio della
 * PRIMA registrazione, per decisione del fondatore. Registrato vuol dire
 * provider non anonimo CON email; per il provider "password" l'email deve
 * anche essere verificata, o il premio si comprerebbe con un indirizzo
 * inventato. Google e Apple portano email gia' verificate dal loro conto.
 */
function registrazioneDi(request: CallableRequest): {
  registrato: boolean;
  email: string | null;
} {
  const token = request.auth?.token;
  const provider = (token?.firebase as {sign_in_provider?: string} | undefined)
    ?.sign_in_provider;
  const email =
    typeof token?.email === "string" ? token.email.trim().toLowerCase() : null;
  const verificata = token?.email_verified === true;
  const registrato =
    provider !== undefined &&
    provider !== "anonymous" &&
    email !== null &&
    (provider !== "password" || verificata);
  return {registrato, email: registrato ? email : null};
}

/**
 * LA LAPIDE DEL BENVENUTO, l'antifrode che sopravvive all'oblio.
 * Ordine BH voce 05.
 *
 * Il buco che il fondatore ha visto da solo: cancella l'account, registrati
 * di nuovo, incassa altri 250. La cura: quando il benvenuto viene pagato a
 * una email, la sua IMPRONTA (hash SHA-256 dell'indirizzo normalizzato, non
 * l'indirizzo) entra in una collezione fuori dal ramo utente, che la
 * cancellazione non tocca e che le regole chiudono al client. Un'email che
 * ha gia' consumato il benvenuto non lo riceve una seconda volta, con
 * qualunque account.
 *
 * **Perche' l'impronta e non l'indirizzo**: il diritto all'oblio resta
 * onesto (nessun dato personale leggibile sopravvive), e la base giuridica
 * e' il legittimo interesse antifrode, dichiarato nella privacy policy.
 * Il sale opzionale arriva dall'ambiente (BENVENUTO_PEPPER, Secret Manager
 * in produzione): senza sale l'impronta e' comunque un'impronta, e il
 * segreto non sta mai nel codice.
 */
function improntaDellEmail(email: string): string {
  const sale = process.env.BENVENUTO_PEPPER ?? "";
  return createHash("sha256").update(sale + email).digest("hex");
}

const lapideDelBenvenuto = (impronta: string) =>
  db.collection("lapidi_del_benvenuto").doc(impronta);

const utente = (uid: string) => db.collection("users").doc(uid);
const contatoriDoc = (uid: string) =>
  utente(uid).collection("stato").doc("contatori");
const borsellinoDoc = (uid: string) =>
  utente(uid).collection("stato").doc("borsellino");
const abbonamentoDoc = (uid: string) =>
  utente(uid).collection("stato").doc("abbonamento");
/**
 * IL CAMMINO CUSTODITO, ordine AP voce 01: sta accanto agli altri stati
 * dell'utente, sotto lo stesso ramo che le regole proteggono dalla scrittura
 * del client.
 */
const camminoDoc = (uid: string) =>
  utente(uid).collection("stato").doc("cammino");

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

  // **IL BENVENUTO E L'ACCREDITO DEL GIORNO, ordine AN voce 07.**
  //
  // Stanno QUI perche' `statoDelCerchio` e' cio' che il client chiede al
  // primo avvio e a ogni apertura: un secondo giro di chiamate per gli
  // accrediti sarebbe una seconda porta sullo stesso momento. Tutti e due
  // sono IDEMPOTENTI e vivono nella stessa transazione del saldo: il
  // benvenuto ha un identificativo fisso, quindi si accredita una volta
  // sola nella vita del Cerchio; l'accredito del giorno ne ha uno che porta
  // il giorno, quindi al piu' una volta al giorno.
  //
  // **IL SALDO NON SI AZZERA MAI**: a mezzanotte locale si rinnovano i tetti
  // d'uso, e questo e' un accredito che si SOMMA. Le azioni premiate non
  // esistono e non si predispone niente per loro: decisione di Mauro del 18
  // agosto.
  // **GLI ACCREDITI COMPIUTI IN QUESTA CHIAMATA SI DICHIARANO AL CLIENT.**
  // Ordine BF voce 01: il fondatore ha cancellato l'account, si e'
  // registrato di nuovo e ha ritrovato 270 Eos, leggendoli come il
  // borsellino vecchio che tornava. Erano la dote di nascita (250 di
  // benvenuto piu' 20 del giorno), ma il saldo non raccontava da dove
  // veniva: da qui in poi la risposta porta anche `accreditati`, cosi' il
  // telefono puo' scrivere nel registro dei movimenti "Benvenuto nel
  // Cerchio" e "Dono del giorno" invece di mostrare un numero senza ragione.
  const accreditati: {motivo: string; quanti: number}[] = [];
  const registrazione = registrazioneDi(request);
  // **IL SEGNALE DI NASCITA ROBUSTO, ordine BH voce 01.** "Appena nato" non
  // puo' piu' dedursi dal benvenuto (la lapide di BH.05 puo' fermarlo su un
  // Cerchio nuovo di zecca): il segnale vero e' il borsellino che non e' mai
  // esistito prima di questa chiamata.
  let cerchioNuovo = false;
  const saldoEos = await db.runTransaction(async (tx) => {
    // La transazione puo' RIPARTIRE da capo in caso di contesa: l'elenco si
    // svuota a ogni giro, o un giro fallito lascerebbe accrediti fantasma.
    accreditati.length = 0;
    const borsellino = borsellinoDoc(uid);
    const snap = await tx.get(borsellino);
    cerchioNuovo = !snap.exists;
    let saldo = (snap.data()?.saldo as number) ?? 0;

    const daAccreditare: {id: string; quanti: number; motivo: string}[] = [];
    // **IL BENVENUTO SOLO A CHI SI REGISTRA, ordine BH voce 01.** Decisione
    // del fondatore: chi non si registra non viene premiato. Il Cerchio
    // anonimo nasce con il solo accredito del giorno, e i 250 arrivano al
    // momento della prima registrazione, nella prima sincronia che vede il
    // token registrato. L'idempotenza resta la stessa: il movimento
    // "benvenuto" esiste una volta sola nella vita del Cerchio.
    if (registrazione.registrato) {
      daAccreditare.push({
        id: "benvenuto",
        quanti: BENVENUTO,
        motivo: "benvenuto",
      });
    }
    const delGiorno = ACCREDITO_DEL_GIORNO[piano] ?? 0;
    if (delGiorno > 0) {
      daAccreditare.push({
        id: `giorno-${giorno}`,
        quanti: delGiorno,
        motivo: "accredito_del_giorno",
      });
    }

    // **TUTTE LE LETTURE PRIMA DI TUTTE LE SCRITTURE.** Ordine AZ, trovato
    // sul telefono del fondatore il 22 agosto 2026.
    //
    // **Questa riga rompeva l'intera app, e nessuna prova poteva vederlo.**
    // Prima il ciclo leggeva e scriveva a ogni giro: alla seconda voce da
    // accreditare il `tx.get` cadeva dopo il `tx.set` della prima, e
    // Firestore lo vieta ("transactions require all reads to be executed
    // before all writes"). Le voci sono DUE ogni volta che il piano ha un
    // accredito del giorno, quindi **`statoDelCerchio` falliva sempre**, con
    // un errore interno.
    //
    // **E' la causa radice dei fatti F1, F5, F6, F8 e F10 messi insieme**:
    // l'accesso riusciva davvero, ma la callable che restituisce borsellino,
    // cammino e identita' non rispondeva mai. Il borsellino a zero, i Sigilli
    // spenti, i dati di nascita a caso che restavano: tutto veniva da qui.
    const riferimenti = daAccreditare.map((voce) =>
      utente(uid).collection("movimenti").doc(voce.id)
    );
    // La lapide si legge nella STESSA fase delle letture: la lezione
    // dell'ordine AZ (tutte le letture prima di tutte le scritture) vale
    // anche per lei.
    const lapide = registrazione.email !== null ?
      lapideDelBenvenuto(improntaDellEmail(registrazione.email)) :
      null;
    const [gia, lapideSnap] = await Promise.all([
      Promise.all(riferimenti.map((r) => tx.get(r))),
      lapide !== null ? tx.get(lapide) : Promise.resolve(null),
    ]);

    let cambiato = false;
    for (let i = 0; i < daAccreditare.length; i++) {
      const voce = daAccreditare[i];
      if (gia[i].exists) {
        // **IL RETROFIT DELLA LAPIDE.** Chi ha ricevuto il benvenuto prima
        // di quest'ordine (quando era dote di nascita) non ha una lapide:
        // gliela si scrive alla prima sincronia registrata, o proprio i
        // Cerchi piu' vecchi resterebbero liberi di rifarsi il premio.
        if (
          voce.id === "benvenuto" &&
          lapide !== null &&
          lapideSnap !== null &&
          !lapideSnap.exists
        ) {
          tx.set(lapide, {quando: FieldValue.serverTimestamp()});
        }
        continue;
      }
      if (voce.id === "benvenuto") {
        // **LA LAPIDE FERMA IL SECONDO BENVENUTO, ordine BH voce 05.**
        // L'email ha gia' consumato il premio con un altro account: il
        // movimento non nasce e il client non riceve niente da raccontare.
        if (lapideSnap !== null && lapideSnap.exists) continue;
        if (lapide !== null) {
          tx.set(lapide, {quando: FieldValue.serverTimestamp()});
        }
      }
      saldo += voce.quanti;
      cambiato = true;
      accreditati.push({motivo: voce.motivo, quanti: voce.quanti});
      tx.set(riferimenti[i], {
        causale: "rettifica",
        motivo: voce.motivo,
        importo: voce.quanti,
        saldoDopo: saldo,
        quando: FieldValue.serverTimestamp(),
      });
    }
    // Il borsellino si scrive UNA VOLTA SOLA e col saldo finale, invece di
    // una volta per voce: due scritture sullo stesso documento nella stessa
    // transazione sono lavoro sprecato, e la prima verrebbe comunque persa.
    if (cambiato) {
      tx.set(borsellino, {
        saldo,
        aggiornato: FieldValue.serverTimestamp(),
      });
    }
    return saldo;
  });

  // **IL CAMMINO VIAGGIA CON LO STATO, ordine AP voce 01.**
  //
  // Il client manda cio' che ha sul telefono, il server lo fonde col
  // custodito e risponde con cio' che vale. Non c'e' una callable nuova, e
  // non e' pigrizia: `statoDelCerchio` e' gia' cio' che si chiede a ogni
  // apertura e dopo ogni riconoscimento, e un secondo canale sullo stesso
  // momento sarebbe la seconda porta sullo stesso dato.
  //
  // **La fusione sta in un punto solo e sta QUI**, non nel client: se la
  // regola vivesse anche in Dart sarebbero due regole, e il giorno che una
  // cambia il cammino di qualcuno si spezzerebbe a meta'.
  const camminoDalTelefono = leggiCammino(
    (request.data as Record<string, unknown> | undefined)?.cammino
  );
  // **L'AZZERAMENTO DEL CAMMINO, ordine AR voce 06.** Il Cammino e' stato
  // riprogettato: i contatori di prima raccontano una storia che non esiste
  // piu'. Il telefono non puo' cancellare niente da solo (allow write: if
  // false), quindi lo chiede qui, e il server DIMENTICA prima di fondere:
  // altrimenti la fusione difenderebbe proprio i numeri che si vogliono
  // buttare, perche' vince sempre il piu' alto.
  //
  // **Gli Eos non passano di qui e non vengono toccati**: vivono nel
  // borsellino, in un altro documento, e questa riga non lo apre nemmeno.
  const azzeraIlCammino =
    (request.data as Record<string, unknown> | undefined)?.azzeraIlCammino ===
    true;
  const cammino = await db.runTransaction(async (tx) => {
    const doc = camminoDoc(uid);
    const snap = await tx.get(doc);
    const custodito = azzeraIlCammino
      ? ({} as CamminoCustodito)
      : ((snap.data() ?? {}) as CamminoCustodito);
    const fuso = fondiCammini(custodito, camminoDalTelefono);
    // Si scrive solo se c'e' qualcosa da custodire: un documento vuoto in
    // piu' per ogni utente anonimo non dice niente a nessuno.
    const daScrivere = Object.keys(fuso).filter((k) => k !== "versione");
    // Con l'azzeramento si scrive SEMPRE, anche un documento vuoto: e' cio'
    // che cancella dal Cerchio il cammino di prima. Senza questa riga il
    // documento vecchio resterebbe intatto ogni volta che il telefono non ha
    // ancora niente da mandare.
    if (daScrivere.length > 0 || azzeraIlCammino) {
      tx.set(doc, {
        ...fuso,
        aggiornato: FieldValue.serverTimestamp(),
      });
    }
    return fuso;
  });

  // **SE L'OBLIO E' IN ATTESA, LO STATO LO DICE.** Ordine BC voce 02.
  //
  // I trenta giorni di ripensamento non esistono piu', ordine BE voce 07:
  // la cancellazione e' immediata e totale, e lo stato non ha piu' niente
  // da raccontare in proposito.

  return {
    giorno,
    piano,
    spesi,
    resta: residuiDi(piano, spesi),
    saldoEos,
    // **IL LISTINO DELLA CONDIVISIONE VIAGGIA CON LO STATO.** Ordine BB voce
    // 04: sui pulsanti deve comparire quanti Eos si guadagnano, e il
    // fondatore chiede che il numero si legga dal server invece di essere
    // scritto a mano nel testo, **cosi' se il listino cambia la frase cambia
    // da sola**.
    //
    // **Non nasce una callable nuova**, per la stessa ragione per cui il
    // cammino viaggia gia' di qui: `statoDelCerchio` e' cio' che si chiede a
    // ogni apertura, e un secondo canale sullo stesso momento sarebbe la
    // seconda porta sullo stesso dato.
    //
    // **Il client lo mostra e non lo usa per pagare**: il conto lo fa sempre
    // il server, che dal motivo sa quanto vale. Un listino che arriva al
    // telefono e' un'informazione, non un'autorizzazione.
    listinoDellaCondivisione: BONUS_DELLA_CONDIVISIONE,
    // Ordine BG voce 05: il prezzo del riscatto di ogni budget, deciso dal
    // server. Il client lo mostra sul pulsante e non lo detta mai.
    listinoDelRiscatto: PREZZI_DEL_RISCATTO,
    // Il premio della registrazione e' un numero del SERVER, come ogni
    // altro prezzo: il client lo scrive negli inviti senza cablarlo.
    listinoDellaRegistrazione: {benvenuto: BENVENUTO},
    cerchioNuovo,
    // Ordine BF voce 01: cosa e' stato accreditato IN QUESTA chiamata, con
    // il motivo. Il client lo racconta nel registro dei movimenti; il saldo
    // resta l'unico numero che conta.
    accreditati,
    cammino,
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
      quando: FieldValue.serverTimestamp(),
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

  const giorno = chiaveDelGiorno();

  return db.runTransaction(async (tx) => {
    const movimento = utente(uid).collection("movimenti").doc(id);
    const gia = await tx.get(movimento);
    const snap = await tx.get(borsellinoDoc(uid));
    const contatori = await tx.get(contatoriDoc(uid));
    const saldo = (snap.data()?.saldo as number) ?? 0;
    if (gia.exists) return {saldo, applicato: false, gia: true};

    // IL TETTO GIORNALIERO ANTI FARMING, dentro la stessa transazione del
    // saldo: contarlo fuori vorrebbe dire poterlo aggirare con due richieste
    // che arrivano insieme. Superato il tetto il Sigillo resta acceso e il
    // bonus non si accredita: si risponde con quanto e' stato accreditato,
    // cioe' niente, senza fingere il contrario.
    const dati = contatori.data();
    const spesiOggi: Record<string, number> =
      dati && dati.giorno === giorno ?
        {...((dati.spesi ?? {}) as Record<string, number>)} :
        {};
    if (causale === "bonus_condivisione") {
      const gia = spesiOggi.condivisioni_premiate ?? 0;
      if (gia >= TETTO_CONDIVISIONI_PREMIATE) {
        return {saldo, applicato: false, tettoRaggiunto: true};
      }
      spesiOggi.condivisioni_premiate = gia + 1;
      tx.set(contatoriDoc(uid), {giorno, spesi: spesiOggi});
    }

    // **IL RISCATTO SCALA IL CONTATORE NELLA STESSA TRANSAZIONE del saldo.**
    // Ordine BG voce 05: pagare 60 Eos per una gettata deve rendere QUELLA
    // gettata possibile subito, e il contatore del giorno e' del server.
    // Scalare lo speso di uno riapre un uso; se gli Eos non bastano la
    // transazione muore piu' sotto e il contatore non si tocca, tutto o
    // niente. Lo speso puo' scendere sotto zero, ed e' voluto: vale come
    // credito di oggi comprato in anticipo sul proprio limite.
    const budgetRiscattato =
      causale === "spesa" ? budgetDelRiscatto(motivo) : null;
    if (budgetRiscattato !== null) {
      spesiOggi[budgetRiscattato] = (spesiOggi[budgetRiscattato] ?? 0) - 1;
      tx.set(contatoriDoc(uid), {giorno, spesi: spesiOggi});
    }

    const dopo = saldoDopo(saldo, importo);
    if (dopo === null) {
      throw new HttpsError("failed-precondition", "Gli Eos non bastano.");
    }
    tx.set(movimento, {
      causale,
      motivo,
      importo,
      saldoDopo: dopo,
      quando: FieldValue.serverTimestamp(),
    });
    tx.set(borsellinoDoc(uid), {
      saldo: dopo,
      aggiornato: FieldValue.serverTimestamp(),
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
    updatedAt: FieldValue.serverTimestamp(),
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
        createdAt: FieldValue.serverTimestamp(),
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
 * QUANTI GIORNI DI RIPENSAMENTO. Ordine BC voce 02.
 *
 * Trenta, decisi dal fondatore. Non e' un obbligo di legge: Apple e Google
 * chiedono che la cancellazione si possa chiedere dall'app, e il GDPR che
 * avvenga; nessuno dei tre impone un'attesa. E' una scelta di prodotto, e ne
 * vale la pena: **una cancellazione fatta per rabbia o per sbaglio e'
 * irreversibile, e un cammino di mesi non si ricostruisce.**
 */
/**
 * **I TRENTA GIORNI NON ESISTONO PIU'. Ordine BE voce 07, decisione del
 * fondatore che SOSTITUISCE quella dell'ordine BC**: "elimina la regola di
 * aspettare 30 giorni: se l'utente cancella l'account lo cancella subito e
 * con tutti i dati". Le callable chiediLOblio e annullaLOblio e il lavoro
 * notturno che le serviva sono stati RIMOSSI, non nascosti: l'unica porta
 * e' cancellaIlCerchio, immediata e totale.
 */

/**
 * IL DIRITTO ALL'OBLIO, e non e' una gentilezza: e' un obbligo.
 *
 * Cancella il ramo dell'utente con tutto quello che ci sta sotto (memoria,
 * contatori, movimenti) e POI l'account stesso, cosi' non resta un uid vivo
 * senza dati ne' dati vivi senza uid. L'ordine conta: cancellando prima
 * l'account il token diventerebbe invalido e la cancellazione dei dati
 * resterebbe a meta'.
 *
 * **RESTA E SERVE A DUE COSE. Ordine BC voce 02.** E' la voce "cancella i
 * tuoi dati" che non aspetta nessuno, ed e' quello che il lavoro notturno
 * esegue quando i trenta giorni sono passati.
 */
/**
 * AZZERA I DATI TENENDO L'ACCOUNT. Ordine BE voce 07, punto 3.
 *
 * **Il fatto del fondatore sulla 2199**: ha cancellato i dati dall'app,
 * reinstallato, e si e' ritrovato 270 Eos e traguardi accesi. La voce
 * "cancella i tuoi dati" puliva solo il telefono: il ramo sul server
 * restava intero, e al ritorno dell'identita' (il backup di Android
 * ripristinava i gettoni di Firebase Auth) il server rendeva tutto.
 * "Se cancello i dati e' perche' voglio ricominciare da capo e questi
 * devono essere cancellati per sempre, anche dal dispositivo."
 *
 * Cancella il ramo intero dell'utente ma NON l'account: chi azzera vuole
 * ricominciare, non andarsene.
 */
/**
 * IL CONGEDO, il perche' della cancellazione. Ordine BH voce 06.
 *
 * Parole del fondatore: "chiedergli perche' sta eliminando i dati o
 * l'account in modo da avere un feedback". Il perche' e' facoltativo, si
 * scrive in una collezione FUORI dal ramo utente (sopravvive alla
 * cancellazione, e' anonimo per costruzione: nessun uid, nessuna email) e
 * si scrive PRIMA di cancellare, o non ci sarebbe piu' nessuno a scriverlo.
 */
async function scriviIlCongedo(
  request: CallableRequest,
  tipo: "dati" | "account"
): Promise<void> {
  const perche =
    (request.data as {ragione?: unknown} | undefined)?.ragione;
  if (typeof perche !== "string") return;
  const testo = perche.trim().slice(0, 300);
  if (testo.length === 0) return;
  try {
    await db.collection("congedi").add({
      tipo,
      ragione: testo,
      quando: FieldValue.serverTimestamp(),
    });
  } catch (errore) {
    // Il feedback non deve mai bloccare un diritto: si va avanti.
    logger.warn("congedo non scritto", {tipo});
  }
}

export const azzeraIDatiDelCerchio = onCall(
  OPZIONI_DEL_CERCHIO,
  async (request) => {
    const uid = uidDi(request);
    await scriviIlCongedo(request, "dati");
    await db.recursiveDelete(utente(uid));
    logger.info("azzeraIDatiDelCerchio: ramo azzerato, account vivo", {uid});
    return {datiAzzerati: true};
  },
);

export const cancellaIlCerchio = onCall(
  OPZIONI_DEL_CERCHIO,
  async (request) => {
    const uid = uidDi(request);
    await scriviIlCongedo(request, "account");
    await db.recursiveDelete(utente(uid));
    try {
      await getAuth().deleteUser(uid);
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
