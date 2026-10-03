/**
 * LA MISURA DEL RITORNO, sul server. Ordine CC voce 09.
 *
 * **Cosa misura, e cosa NON misura.** Conta i GESTI per giorno e per tipo:
 * quante aperture, quanti riti cominciati, quanti finiti, quante condivisioni.
 * Da qui si legge quante persone tornano il giorno dopo e quante dopo una
 * settimana. **Non costruisce nessun profilo**: non esiste una riga per
 * persona con dentro cosa ha fatto, esistono contatori.
 *
 * **UN POSTO SOLO, E ANONIMO. Ordine EA voce 12, 19 settembre 2026.** Qui si
 * scrivevano DUE documenti: l'aggregato `ritorno/{giorno}` e un contatore
 * sotto l'utente, `users/{uid}/ritorno/{giorno}`. Il secondo era l'unica cosa
 * che rendeva questi numeri riferibili a qualcuno, ed e' uscito: il fondatore
 * vuole *"soltanto numeri aggregati per giorno, anonimi, senza alcun
 * identificativo del telefono, dell'installazione o dell'utente"*. Resta
 * `ritorno/{giorno}`, che e' un conto e non un dato di nessuno.
 *
 * **La chiamata vuole ancora un account, anche anonimo, e non lo scrive.**
 * Senza quel cancello questa porta sarebbe aperta al mondo e chiunque potrebbe
 * gonfiare i contatori dall'esterno. L'uid serve a entrare e finisce li': non
 * viene scritto in nessun documento e non viene messo in nessun registro.
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
    const tutti = db.collection("ritorno").doc(giorno);
    // Un incremento, nessuna lettura: e' un contatore, e un contatore non ha
    // bisogno di sapere cosa c'era prima. Il campo `quando` serve anche alla
    // scadenza dei 24 mesi (`scadenze.ts`), che e' la promessa della policy.
    await tutti.set(
      {[campo]: FieldValue.increment(1), quando: FieldValue.serverTimestamp()},
      {merge: true}
    );
    return {segnato: true};
  } catch (errore) {
    logger.warn("segnaLEvento: non registrato", {nome});
    return {segnato: false, motivo: "non_riuscito"};
  }
});
