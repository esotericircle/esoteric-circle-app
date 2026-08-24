import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {createHash, randomInt} from "node:crypto";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {createTransport} from "nodemailer";
import {chiaveDelGiorno} from "./giorno";

/**
 * IL SECONDO FATTORE COL CODICE NUMERICO. Ordine BI voce 04.
 *
 * Parole del fondatore: "vorrei che la registrazione con email sia
 * vincolata a un'autenticazione a 2 fattori, con invio all'email del
 * codice numerico". Una callable sola, due operazioni:
 *
 * - "manda": genera un codice di sei cifre, ne conserva l'IMPRONTA (mai il
 *   codice in chiaro) con una scadenza di dieci minuti, e lo spedisce
 *   all'email dell'account dal mittente configurato in Secret Manager
 *   (SMTP_URL). Senza mittente risponde mandato:false col motivo, e il
 *   client ripiega sull'email di verifica di Firebase: mai un codice
 *   promesso che non arriva.
 * - "verifica": confronta l'impronta entro la scadenza, con un tetto di
 *   cinque tentativi. Alla verifica riuscita l'email dell'account diventa
 *   VERIFICATA (updateUser): da quel momento il gettone rinfrescato porta
 *   la verita' e il benvenuto arriva dalle regole che gia' esistono
 *   (ordine BH voce 01). Il codice numerico e la verifica via
 *   collegamento sono due strade per la stessa porta.
 *
 * I limiti, contati in transazione: cinque invii al giorno per account,
 * cinque tentativi per codice. Il codice vale per l'email del TOKEN, mai
 * per una email arrivata nel corpo.
 */
const SMTP_URL = defineSecret("SMTP_URL");

const INVII_AL_GIORNO = 5;
const TENTATIVI_PER_CODICE = 5;
const MINUTI_DI_VITA = 10;

const db = getFirestore();

function improntaDelCodice(uid: string, codice: string): string {
  return createHash("sha256").update(uid + ":" + codice).digest("hex");
}

export const secondoFattore = onCall(
  {
    region: "europe-west1",
    enforceAppCheck: false,
    timeoutSeconds: 30,
    memory: "256MiB" as const,
    secrets: [SMTP_URL],
  },
  async (request: CallableRequest) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Serve un account.");
    }
    const email =
      typeof request.auth?.token?.email === "string" ?
        request.auth.token.email.trim().toLowerCase() :
        null;
    if (email === null) {
      throw new HttpsError(
        "failed-precondition",
        "Questo account non ha una email da verificare."
      );
    }
    const operazione = (request.data as {operazione?: unknown} | undefined)
      ?.operazione;
    const doc = db
      .collection("users").doc(uid)
      .collection("stato").doc("secondo_fattore");

    if (operazione === "manda") {
      const mittente = (process.env.SMTP_URL ?? "").trim();
      // Il segreto esiste sempre (il deploy lo pretende): e' il VALORE a
      // dire se il mittente c'e'. Un segnaposto senza :// non e' un
      // indirizzo SMTP, e si dichiara come mancante.
      if (!mittente.includes('://')) {
        // Il mittente non e' configurato: lo si DICHIARA invece di far
        // aspettare un codice che non partira' mai.
        return {mandato: false, motivo: "mittente_non_configurato"};
      }
      const giorno = chiaveDelGiorno();
      const codice = randomInt(0, 1000000).toString().padStart(6, "0");
      const concesso = await db.runTransaction(async (tx) => {
        const snap = await tx.get(doc);
        const dati = snap.data();
        const inviati = dati?.giorno === giorno ?
          ((dati?.inviati as number) ?? 0) : 0;
        if (inviati >= INVII_AL_GIORNO) return false;
        tx.set(doc, {
          giorno,
          inviati: inviati + 1,
          impronta: improntaDelCodice(uid, codice),
          scade: Date.now() + MINUTI_DI_VITA * 60 * 1000,
          tentativi: 0,
          quando: FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (!concesso) {
        throw new HttpsError("resource-exhausted",
          "Troppi codici per oggi. Riprova domani, oppure usa il " +
          "collegamento nell'email di verifica.");
      }
      try {
        const posta = createTransport(mittente);
        const daChi = decodeURIComponent(
          new URL(mittente).username || "noreply@esotericircle.app");
        await posta.sendMail({
          from: `Esoteric Circle <${daChi}>`,
          to: email,
          subject: `${codice} è il tuo codice per il Cerchio`,
          text:
            `Il tuo codice di verifica è: ${codice}\n\n` +
            `Vale ${MINUTI_DI_VITA} minuti. Se non hai chiesto tu questo ` +
            "codice, ignora questa email: senza il codice nessuno entra.",
        });
      } catch (errore) {
        logger.error("secondoFattore: invio non riuscito", {
          errore: String(errore),
        });
        throw new HttpsError("unavailable",
          "Non sono riuscito a mandare il codice. Riprova fra poco.");
      }
      logger.info("secondoFattore: codice mandato", {uid});
      return {mandato: true};
    }

    if (operazione === "verifica") {
      const grezzo = (request.data as {codice?: unknown} | undefined)?.codice;
      if (typeof grezzo !== "string" || !/^\d{6}$/.test(grezzo.trim())) {
        throw new HttpsError("invalid-argument",
          "Il codice è di sei cifre.");
      }
      const codice = grezzo.trim();
      const esito = await db.runTransaction(async (tx) => {
        const snap = await tx.get(doc);
        const dati = snap.data();
        if (!dati || typeof dati.impronta !== "string") return "assente";
        if (Date.now() > ((dati.scade as number) ?? 0)) return "scaduto";
        const tentativi = ((dati.tentativi as number) ?? 0) + 1;
        if (tentativi > TENTATIVI_PER_CODICE) return "esaurito";
        if (dati.impronta !== improntaDelCodice(uid, codice)) {
          tx.set(doc, {tentativi}, {merge: true});
          return "sbagliato";
        }
        // Il codice buono si consuma: non vale due volte.
        tx.set(doc, {impronta: FieldValue.delete(), tentativi},
          {merge: true});
        return "giusto";
      });
      if (esito !== "giusto") return {verificato: false, motivo: esito};
      // **LA VERIFICA DIVENTA VERA SULL'ACCOUNT**: da qui il gettone
      // rinfrescato porta email_verified e il benvenuto arriva dalle
      // regole di BH.01, senza una seconda strada per il premio.
      await getAuth().updateUser(uid, {emailVerified: true});
      logger.info("secondoFattore: email verificata col codice", {uid});
      return {verificato: true};
    }

    throw new HttpsError("invalid-argument", "Operazione sconosciuta.");
  }
);
