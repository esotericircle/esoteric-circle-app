import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

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
const FREEASTRO_BASE_URL = "https://freeastroapi.com";
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
    enforceAppCheck: true,
    secrets: [FREEASTRO_API_KEY],
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const data = request.data as Record<string, unknown> | undefined;
    if (!data || typeof data !== "object") {
      throw new HttpsError("invalid-argument", "Dati di nascita mancanti.");
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
      return await res.json();
    } catch (err) {
      logger.error("natalChart: risposta non leggibile", {err: String(err)});
      throw new HttpsError("internal", "La risposta del cielo non e' leggibile.");
    }
  }
);
