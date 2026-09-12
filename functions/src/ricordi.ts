/**
 * L'INDICE DEI RICORDI, LATO SERVER. Ordine CG voce 03.
 *
 * **Cosa custodisce e cosa no.** Un documento per persona e per mese, in
 * `users/{uid}/ricordi/{AAAA-MM}`, che porta SOLO le righe magre: quando,
 * quale arte, quale Maestro, il titolo troncato e il riferimento a dove vive
 * il contenuto vero. Il contenuto pieno non passa mai di qua: le
 * conversazioni stanno nei loro turni, i responsi custoditi nel loro
 * magazzino.
 *
 * **Perche' una mappa e non una lista.** Se il mese fosse una lista, due
 * apparecchi della stessa persona che sincronizzano lo stesso mese si
 * cancellerebbero a vicenda. Qui il campo `righe` e' una MAPPA da chiave di
 * riga alla riga, si scrive con `merge`, e i due apparecchi si sommano. La
 * chiave la calcola il telefono in modo deterministico, quindi la stessa voce
 * mandata due volte resta una riga sola.
 *
 * **I tetti, e nascono da un conto.** Un Illuminato ha 250 voci al giorno di
 * tetto, cioe' 7.750 in un mese di trentun giorni: [MASSIME_RIGHE_PER_MESE] e'
 * fissato sopra quel numero con margine. [MASSIMI_BYTE_PER_CHIAMATA] tiene la
 * chiamata dentro il limite di una callable senza dover spezzare la sincronia
 * in piu' viaggi nel caso normale.
 */
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {getFirestore, FieldValue, Timestamp} from "firebase-admin/firestore";

const OPZIONI = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
};

/**
 * QUANTE RIGHE PUO' PORTARE UN MESE.
 *
 * Diecimila. Il tetto piu' alto della matrice, l'Illuminato, vale 250 voci al
 * giorno: in un mese di trentun giorni sono 7.750. Diecimila lascia margine
 * senza permettere che un client compromesso riempia il progetto una riga
 * alla volta.
 */
export const MASSIME_RIGHE_PER_MESE = 10000;

/**
 * QUANTI BYTE PUO' PESARE UNA CHIAMATA.
 *
 * Ottocento chilobyte. Un documento Firestore ne regge poco piu' di uno
 * (1.048.576): stare sotto vuol dire che una sincronia accettata qui e' una
 * sincronia che il documento puo' davvero contenere, invece di essere presa e
 * poi rifiutata dalla scrittura.
 */
export const MASSIMI_BYTE_PER_CHIAMATA = 800000;

/** La forma del mese, `AAAA-MM`. Niente altro entra come nome di documento. */
const FORMA_DEL_MESE = /^\d{4}-\d{2}$/;

const db = getFirestore();
const meseDoc = (uid: string, mese: string) =>
  db.collection("users").doc(uid).collection("ricordi").doc(mese);

/**
 * IL PRIMO ISTANTE DEL MESE, in UTC.
 *
 * Serve alla pulizia notturna: la scadenza di un mese si conta dal mese che
 * descrive, non da quando qualcuno lo ha sincronizzato per l'ultima volta.
 */
function primoIstanteDel(mese: string): Timestamp {
  const anno = Number(mese.slice(0, 4));
  const numero = Number(mese.slice(5, 7));
  return Timestamp.fromDate(new Date(Date.UTC(anno, numero - 1, 1)));
}

/** L'uid dal token, mai dal corpo. */
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
 * SCRIVE LE RIGHE DI UN MESE.
 *
 * Il telefono manda l'intero mese che ha, e il server fonde con `merge`: cosi'
 * una sincronia che arriva dopo un'altra da un secondo apparecchio non
 * cancella niente.
 */
export const scriviIRicordi = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const mese = String(request.data?.mese ?? "").trim();
  const righe = request.data?.righe;

  if (!FORMA_DEL_MESE.test(mese)) {
    throw new HttpsError("invalid-argument", "Mese non valido.");
  }
  if (righe === null || typeof righe !== "object" || Array.isArray(righe)) {
    throw new HttpsError("invalid-argument", "Righe non valide.");
  }
  const quante = Object.keys(righe as Record<string, unknown>).length;
  if (quante > MASSIME_RIGHE_PER_MESE) {
    throw new HttpsError(
      "invalid-argument",
      `Troppe righe per un mese: ${quante}.`
    );
  }
  if (JSON.stringify(righe).length > MASSIMI_BYTE_PER_CHIAMATA) {
    throw new HttpsError("invalid-argument", "Sincronia troppo grande.");
  }

  // **UNA SCRITTURA SOLA, ed e' la misura di accettazione dell'ordine.**
  // `merge` su una mappa fonde chiave per chiave: le righe che c'erano gia'
  // restano, quelle nuove si aggiungono, e nessun apparecchio cancella
  // l'altro.
  //
  // **`quando` E' IL MESE, NON LA SINCRONIA, e la differenza e' la scadenza.**
  // Se portasse la data dell'ultima sincronia, un mese del 2024 risincronizzato
  // oggi sembrerebbe nuovo e non scadrebbe mai. Qui `quando` e' il primo
  // istante del mese che il documento descrive, cosi' la pulizia notturna lo
  // trova col campo che cerca in tutte le altre collezioni.
  await meseDoc(uid, mese).set(
    {
      righe: righe,
      quando: primoIstanteDel(mese),
      aggiornatoIl: FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  return {scritto: true, quante};
});

/**
 * QUANTI MOVIMENTI DEGLI EOS SI RESTITUISCONO IN UN GIRO.
 *
 * Duecento. Il telefono ne tiene otto, che bastano al borsellino e non
 * bastano ai Ricordi: la voce CG.10 chiede che nei Ricordi si vedano i due
 * anni che il server tiene davvero. Duecento coprono con margine i movimenti
 * di una persona molto attiva in due anni senza far diventare la lettura un
 * viaggio che si paga a peso.
 */
export const QUANTI_MOVIMENTI_PER_GIRO = 200;

/**
 * IL REGISTRO DEI MOVIMENTI DEGLI EOS, come lo tiene il server.
 *
 * **Perche' non bastano gli otto del telefono.** `RegistroDegliEos` ne tiene
 * otto, che e' la misura giusta per il borsellino, dove servono gli ultimi
 * movimenti. Nei Ricordi la domanda e' un'altra, cioe' "quanti Eos ho
 * guadagnato quel mese", e a quella otto righe non rispondono. Il server i
 * movimenti li tiene due anni, che e' esattamente l'orizzonte dell'indice dei
 * Ricordi: qui si restituiscono quelli.
 */
export const leggiIMovimenti = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const quanti = Math.min(
    Number(request.data?.quanti ?? QUANTI_MOVIMENTI_PER_GIRO) ||
      QUANTI_MOVIMENTI_PER_GIRO,
    QUANTI_MOVIMENTI_PER_GIRO
  );
  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("movimenti")
    .orderBy("quando", "desc")
    .limit(quanti)
    .get();

  const movimenti = snap.docs.map((d) => {
    const dati = d.data() as Record<string, unknown>;
    const quando = dati.quando as {toDate?: () => Date} | undefined;
    return {
      id: d.id,
      quanti: typeof dati.quanti === "number" ? dati.quanti : 0,
      causale: typeof dati.causale === "string" ? dati.causale : "",
      motivo: typeof dati.motivo === "string" ? dati.motivo : "",
      quando: quando?.toDate ? quando.toDate().toISOString() : null,
    };
  });
  return {movimenti};
});

/**
 * RILEGGE UN MESE.
 *
 * Serve solo quando qualcuno scende indietro oltre i dodici mesi che il
 * telefono tiene: una lettura, un mese.
 */
export const leggiIRicordi = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const mese = String(request.data?.mese ?? "").trim();
  if (!FORMA_DEL_MESE.test(mese)) {
    throw new HttpsError("invalid-argument", "Mese non valido.");
  }
  const doc = await meseDoc(uid, mese).get();
  if (!doc.exists) return {righe: {}};
  const dentro = doc.data()?.righe;
  return {righe: dentro && typeof dentro === "object" ? dentro : {}};
});

/**
 * LO SCRIGNO DEI RESPONSI CUSTODITI. Ordine CG voce 06.
 *
 * **I custoditi NON SCADONO, ed e' una decisione dichiarata.** La pulizia
 * notturna non li tocca: sono decine e non migliaia, quindi non pesano, e sono
 * esattamente cio' che la persona ha dichiarato di voler tenere. Il documento
 * non porta nessun campo `quando` di scadenza proprio per questo: se un giorno
 * qualcuno aggiungesse una scadenza, dovrebbe anche aggiungere il campo, e la
 * prova che pretende che nessuna scadenza li nomini cadrebbe prima.
 */
const custoditoDoc = (uid: string, chiave: string) =>
  db.collection("users").doc(uid).collection("custoditi").doc(chiave);

/** Il tetto di peso di un custodito, in byte. Duemila, cioe' il doppio del
 * tetto che il telefono si impone: cosi' un responso lungo un po' piu' del
 * previsto non si perde, e un client compromesso non riempie comunque niente.
 */
export const MASSIMI_BYTE_PER_CUSTODITO = 2000;

/** Quanti custoditi si restituiscono in un giro. */
export const QUANTI_CUSTODITI_PER_GIRO = 500;

/** La forma di una chiave di custodito: minuti, un punto, il nome dell arte. */
const FORMA_DELLA_CHIAVE = /^\d+\.[a-z_]+$/;

export const custodisciIlResponso = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const chiave = String(request.data?.chiave ?? "").trim();
  const ricordo = request.data?.ricordo;
  if (!FORMA_DELLA_CHIAVE.test(chiave)) {
    throw new HttpsError("invalid-argument", "Chiave non valida.");
  }
  if (ricordo === null || typeof ricordo !== "object" || Array.isArray(ricordo)) {
    throw new HttpsError("invalid-argument", "Ricordo non valido.");
  }
  if (JSON.stringify(ricordo).length > MASSIMI_BYTE_PER_CUSTODITO) {
    throw new HttpsError("invalid-argument", "Ricordo troppo grande.");
  }
  await custoditoDoc(uid, chiave).set(
    {...(ricordo as Record<string, unknown>),
      custoditoIl: FieldValue.serverTimestamp()},
    {merge: true}
  );
  return {custodito: true};
});

export const leggiICustoditi = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("custoditi")
    .limit(QUANTI_CUSTODITI_PER_GIRO)
    .get();
  return {custoditi: snap.docs.map((d) => d.data())};
});

export const lasciaIlResponso = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const chiave = String(request.data?.chiave ?? "").trim();
  if (!FORMA_DELLA_CHIAVE.test(chiave)) {
    throw new HttpsError("invalid-argument", "Chiave non valida.");
  }
  await custoditoDoc(uid, chiave).delete();
  return {lasciato: true};
});
