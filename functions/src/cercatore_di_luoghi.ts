import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

import {
  COME_CI_PRESENTIAMO,
  LuogoDelMondo,
  LuogoNonValido,
  chiaveDellaDomanda,
  indirizzoDellaDomanda,
  traduci,
  validaLaDomanda,
} from "./luoghi";

/**
 * LA PORTA VERSO IL MONDO INTERO. Ordine DR voce 10.
 *
 * Qui c'e' solo la porta: la validazione, l'indirizzo e la traduzione stanno
 * in `luoghi.ts`, che non importa niente di Firebase e si prova con
 * `node --test`. Questo file ha l'unica cosa che le prove non possono girare
 * da sole, cioe' la rete e la memoria condivisa.
 *
 * **LA MEMORIA CONDIVISA E' IL PEZZO CHE CONTA.** Dall'altra parte c'e' un
 * servizio pubblico tenuto in piedi da una fondazione, e la regola d'uso
 * chiede di non ripetere una domanda gia' fatta. Le domande di chi cerca il
 * proprio paese si somigliano tutte, quindi la seconda persona che cerca
 * "Borgo di Rivalta" non fa partire nessuna chiamata: legge cio' che ha
 * trovato la prima. E' anche la ragione per cui questa strada passa dal
 * server e non dal telefono: una memoria per telefono non e' una memoria.
 */

/** Dove si mettono da parte le risposte. Una riga per domanda normalizzata. */
const CASSETTO = "luoghi_del_mondo";

/** Quanto si aspetta il servizio prima di lasciar perdere. */
const ATTESA_MASSIMA_MS = 8000;

/** La forma della risposta, uguale da rete e da cassetto. */
interface Risposta {
  luoghi: LuogoDelMondo[];
  /** Vero quando la risposta viene dal cassetto e non dalla rete. */
  giaSaputo: boolean;
}

export const cercaIlLuogoNelMondo = onCall(
  {
    region: "europe-west1",
    // Spento per la stessa ragione scritta in `index.ts` sopra natalChart:
    // l'app arriva da App Distribution e Play Integrity non la attesta.
    // Qui il danno possibile e' piu' piccolo che sulla carta natale, perche'
    // dietro non c'e' un servizio che si paga a chiamata; resta il dovere di
    // non pesare su OpenStreetMap, e lo tengono il validatore e il cassetto.
    enforceAppCheck: false,
    timeoutSeconds: 20,
    memory: "256MiB",
  },
  async (request): Promise<Risposta> => {
    let domanda: string;
    try {
      domanda = validaLaDomanda(request.data);
    } catch (err) {
      const motivo = err instanceof LuogoNonValido ?
        err.message : "Il luogo da cercare non e' valido.";
      logger.warn("cercaIlLuogoNelMondo: domanda rifiutata", {motivo});
      throw new HttpsError("invalid-argument", motivo);
    }

    const chiave = chiaveDellaDomanda(domanda);
    const db = getFirestore();
    const riga = db.collection(CASSETTO).doc(chiave);

    // **PRIMA IL CASSETTO**, sempre. Una domanda gia' fatta non si rifa'.
    try {
      const gia = await riga.get();
      if (gia.exists) {
        const dentro = gia.data()?.luoghi;
        if (Array.isArray(dentro)) {
          // Il conto delle volte serve a sapere, un giorno, se il cassetto
          // sta lavorando: senza, "la memoria serve" resterebbe un'opinione.
          riga.update({volte: FieldValue.increment(1)}).catch(() => {});
          return {luoghi: dentro as LuogoDelMondo[], giaSaputo: true};
        }
      }
    } catch (err) {
      // Un cassetto che non si apre non e' una ragione per non rispondere:
      // si va in rete e si dice nel registro che il cassetto ha fallito.
      logger.warn("cercaIlLuogoNelMondo: cassetto non letto",
        {err: String(err)});
    }

    let grezza: unknown;
    try {
      const taglio = AbortSignal.timeout(ATTESA_MASSIMA_MS);
      const res = await fetch(indirizzoDellaDomanda(domanda), {
        headers: {
          "User-Agent": COME_CI_PRESENTIAMO,
          "Accept": "application/json",
        },
        signal: taglio,
      });
      if (!res.ok) {
        logger.warn("cercaIlLuogoNelMondo: il mondo ha risposto male",
          {stato: res.status});
        throw new HttpsError(
          "unavailable", "La ricerca nel mondo non risponde.");
      }
      grezza = await res.json();
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      logger.warn("cercaIlLuogoNelMondo: il mondo non risponde",
        {err: String(err)});
      throw new HttpsError("unavailable", "La ricerca nel mondo non risponde.");
    }

    const luoghi = traduci(grezza);

    // **ANCHE UN ELENCO VUOTO SI METTE DA PARTE.** Un nome che il mondo non
    // conosce e' proprio quello che qualcuno riscrivera' tre volte: ripetere
    // la domanda tre volte non cambierebbe la risposta e peserebbe su chi
    // risponde. Si riscrive intera, cosi' il giorno che il fornitore cambia
    // il cassetto si riempie di nuovo da se'.
    riga.set({
      domanda,
      luoghi,
      quando: FieldValue.serverTimestamp(),
      volte: 1,
    }).catch((err) => {
      logger.warn("cercaIlLuogoNelMondo: cassetto non scritto",
        {err: String(err)});
    });

    logger.info("cercaIlLuogoNelMondo: risposto dalla rete",
      {chiave, quanti: luoghi.length});
    return {luoghi, giaSaputo: false};
  }
);
