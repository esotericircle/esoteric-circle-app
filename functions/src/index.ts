import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {validateNatalInput, ValidationError, NatalInput} from "./validate";

/**
 * Chiave del motore astrologico FreeAstroAPI.
 *
 * Vive SOLO in Secret Manager: si dichiara qui con defineSecret e si legge a
 * runtime con .value(). Non e' mai scritta nel codice ne in file versionati, e
 * l'app non la vede piu'. Il valore si imposta a mano (fuori dal repo):
 *   firebase functions:secrets:set FREEASTRO_API_KEY
 */
const FREEASTRO_API_KEY = defineSecret("FREEASTRO_API_KEY");

/**
 * Base URL del servizio FreeAstroAPI. Da confermare sul piano di Mauro
 * (freeastroapi.com oppure api.freeastroapi.com): sta in un'unica costante,
 * cosi' si aggiorna in un punto solo.
 */
const FREEASTRO_BASE_URL = "https://api.freeastroapi.com";
const NATAL_PATH = "/api/v1/natal/calculate";

/** Timeout della chiamata verso FreeAstroAPI. */
const UPSTREAM_TIMEOUT_MS = 15000;

/**
 * Callable "natalChart": ponte lato server verso FreeAstroAPI.
 *
 * L'app invia i dati di nascita (year, month, day, hour, minute, lat, lng,
 * tz_str) e riceve il JSON di FreeAstroAPI cosi' com'e'. La chiave resta nel
 * server (header x-api-key dal secret). App Check e' imposto: senza un token
 * valido la chiamata e' rifiutata. Gli errori tornano puliti, cosi' il client
 * puo' ripiegare sul cielo essenziale senza mostrare dettagli tecnici.
 */
export const natalChart = onCall(
  {
    region: "europe-west1",
    // APP CHECK SPENTO IL 31 LUGLIO 2026, ed e' un COMPROMESSO DICHIARATO.
    //
    // PERCHE'. I log del servizio mostravano nove avvisi con
    // "verifications.app: INVALID": la chiamata arrivava, Firebase trovava il
    // token non valido e respingeva PRIMA che il corpo della funzione partisse.
    // Ecco perche' nei log non compariva nessuna riga "natalChart: ...": quel
    // codice non era mai stato eseguito, neanche una volta, e la carta natale
    // non ha mai funzionato per nessuno in nessuna build.
    //
    // Il fornitore registrato e' Play Integrity, che attesta le app riconosciute
    // da Google Play. Questa arriva da App Distribution, quindi e' installata
    // fuori dal Play Store e Play Integrity non puo' attestarla. Registrare
    // l'app in App Check era necessario e non sufficiente.
    //
    // COSA COSTA. Senza imposizione chiunque conosca l'indirizzo puo' far
    // chiamare una funzione che consuma un servizio a pagamento. Il validatore
    // in validate.ts limita il danno, perche' rifiuta qualunque corpo
    // malformato, e non lo annulla.
    //
    // QUANDO SI RIACCENDE. Appena l'app sara' su una traccia di test interno
    // del Play Store: da li' Play Integrity la riconosce e l'imposizione torna
    // a costare nulla. Il debito e' scritto in docs/ordini/RIPRESA.md.
    enforceAppCheck: false,
    secrets: [FREEASTRO_API_KEY],
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    // Il corpo si ricostruisce campo per campo, non si inoltra com'e':
    // dietro c'e' un servizio che si paga a chiamata, e un token App Check
    // valido lo ottiene chiunque installi l'app.
    let data: NatalInput;
    try {
      data = validateNatalInput(request.data, new Date().getUTCFullYear());
    } catch (err) {
      const motivo = err instanceof ValidationError ?
        err.message : "Dati di nascita non validi.";
      logger.warn("natalChart: corpo rifiutato", {motivo});
      throw new HttpsError("invalid-argument", motivo);
    }

    let res: Response;
    try {
      res = await fetch(`${FREEASTRO_BASE_URL}${NATAL_PATH}`, {
        method: "POST",
        headers: {
          "x-api-key": FREEASTRO_API_KEY.value(),
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: JSON.stringify(data),
        signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
      });
    } catch (err) {
      // Rete giu', DNS, o timeout: errore pulito, il client ripiega.
      logger.warn("natalChart: motore non raggiungibile", {err: String(err)});
      throw new HttpsError(
        "unavailable",
        "Il motore astrologico non risponde in questo momento."
      );
    }

    if (!res.ok) {
      // 4xx: richiesta o chiave; 5xx: guasto a monte. In entrambi i casi un
      // messaggio in tono, senza svelare dettagli, e il client ripiega.
      logger.warn("natalChart: risposta non ok", {status: res.status});
      const code = res.status >= 500 ? "unavailable" : "failed-precondition";
      throw new HttpsError(code, "Il motore astrologico ha risposto con un imprevisto.");
    }

    try {
      const carta = await res.json();
      // ANCHE IL BUON ESITO SI SCRIVE. Qui si registravano solo i fallimenti,
      // quindi una chiamata riuscita non lasciava traccia: guardando i log non
      // si poteva distinguere "ha funzionato" da "non e' mai partita", ed e'
      // proprio la distinzione che serviva per capire che App Check respingeva
      // tutto prima del corpo della funzione.
      const pianeti = Array.isArray((carta as {planets?: unknown[]})?.planets) ?
        (carta as {planets: unknown[]}).planets.length :
        0;
      logger.info("natalChart: carta calcolata", {pianeti});
      return carta;
    } catch (err) {
      logger.error("natalChart: risposta non leggibile", {err: String(err)});
      throw new HttpsError("internal", "La risposta del cielo non e' leggibile.");
    }
  }
);
