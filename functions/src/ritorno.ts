/**
 * LA MISURA DEL RITORNO, sul server. Ordine CC voce 09.
 *
 * **Cosa misura, e cosa NON misura.** Conta i GESTI per giorno e per tipo:
 * quante aperture, quanti riti cominciati, quanti finiti, quante condivisioni.
 * Da qui si legge quante persone tornano il giorno dopo e quante dopo una
 * settimana. **Non costruisce nessun profilo**: non esiste una riga per
 * persona con dentro cosa ha fatto, esistono contatori.
 *
 * **Perche' due posti e non uno.** Il contatore del giorno sta sotto l'utente,
 * `users/{uid}/ritorno/{giorno}`, perche' solo li' le regole di sicurezza gia'
 * scritte impediscono al telefono di scrivere. L'aggregato, che e' il numero
 * che si legge davvero, sta in `ritorno/{giorno}` fuori dal ramo utente:
 * quello e' un conto, non un dato di nessuno, e sopravvive alla cancellazione
 * perche' non contiene niente da cancellare.
 *
 * **L'elenco degli eventi e' CHIUSO.** Un nome che non e' in questa lista non
 * viene registrato, e la funzione risponde di no. E' l'unico modo perche' la
 * privacy policy possa dire il vero su cosa si misura: se domani qualcuno
 * aggiunge un evento senza toccare questo elenco e la policy, non succede
 * niente.
 *
 * **Nessun testo della persona entra qui.** Il contesto e' una parola sola,
 * corta, e viene tagliata: e' il nome di un rito, non una frase.
 */
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

const db = getFirestore();

const OPZIONI = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 20,
  memory: "256MiB" as const,
};

/**
 * GLI EVENTI AMMESSI, uno per uno.
 *
 * Sono gli stessi cinque che il client dichiara in `EventoDelRitorno`, e la
 * prova del client legge questo file per pretendere che le due liste
 * coincidano: due elenchi che divergono sono una misura che perde pezzi in
 * silenzio.
 */
export const EVENTI_AMMESSI = [
  "apertura",
  "ritorno_da_avviso",
  "rito_cominciato",
  "rito_compiuto",
  "responso_condiviso",
] as const;

/** Quanto lunga puo' essere la parola di contesto. */
export const CONTESTO_MASSIMO = 40;

/** Il giorno come chiave, nel fuso di Roma: e' il giorno che vede la persona. */
export function giornoDiRoma(adesso: number): string {
  const d = new Date(adesso);
  const roma = new Date(d.toLocaleString("en-US", {timeZone: "Europe/Rome"}));
  const m = `${roma.getMonth() + 1}`.padStart(2, "0");
  const g = `${roma.getDate()}`.padStart(2, "0");
  return `${roma.getFullYear()}-${m}-${g}`;
}

export const segnaLEvento = onCall(OPZIONI, async (request: CallableRequest) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Serve un account, anche anonimo, per parlare col Cerchio."
    );
  }
  const nome = String((request.data as {nome?: unknown})?.nome ?? "");
  if (!(EVENTI_AMMESSI as readonly string[]).includes(nome)) {
    // **NON E' UN ERRORE, E' UN NO.** Un evento non dichiarato non si
    // registra: la lista e' la promessa che la privacy policy fa.
    logger.info("segnaLEvento: nome non ammesso", {nome});
    return {segnato: false, motivo: "non_ammesso"};
  }
  const grezzo = (request.data as {contesto?: unknown})?.contesto;
  const contesto =
    typeof grezzo === "string" ? grezzo.trim().slice(0, CONTESTO_MASSIMO) : null;

  const giorno = giornoDiRoma(Date.now());
  const campo = contesto ? `${nome}__${contesto}` : nome;

  try {
    const suo = db
      .collection("users").doc(uid)
      .collection("ritorno").doc(giorno);
    const tutti = db.collection("ritorno").doc(giorno);
    // Due incrementi, nessuna lettura: e' un contatore, e due contatori non
    // hanno bisogno di sapere cosa c'era prima.
    await Promise.all([
      suo.set({[campo]: FieldValue.increment(1)}, {merge: true}),
      tutti.set(
        {[campo]: FieldValue.increment(1), quando: FieldValue.serverTimestamp()},
        {merge: true}
      ),
    ]);
    return {segnato: true};
  } catch (errore) {
    logger.warn("segnaLEvento: non registrato", {nome});
    return {segnato: false, motivo: "non_riuscito"};
  }
});
