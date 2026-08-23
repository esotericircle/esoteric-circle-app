import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

/**
 * IL LAVORO NOTTURNO CHE MANTIENE LA PROMESSA DEI TRENTA GIORNI.
 * Ordine BC voce 02.
 *
 * **Decisione del fondatore**: "Cancella l'account, in fondo, con la
 * schermata che elenca cosa sparisce davvero, e trenta giorni di
 * ripensamento prima della cancellazione definitiva."
 *
 * La callable `chiediLOblio` segna soltanto una data. **Senza qualcuno che
 * torni a guardarla, quella data non sarebbe una promessa ma un promemoria
 * che nessuno legge**: chi chiede di sparire e poi non riapre piu' l'app
 * resterebbe scritto nel Cerchio per sempre, ed e' esattamente cio' che il
 * GDPR non consente.
 *
 * Percio' ogni notte si guarda chi ha passato i trenta giorni e lo si
 * cancella davvero: prima i dati, poi l'account, nello stesso ordine della
 * callable.
 *
 * **PERCHE' UN LAVORO E NON UNA CANCELLAZIONE AL RIENTRO.** Cancellare alla
 * prima apertura dopo la scadenza sarebbe costato molto meno, e sarebbe stata
 * una promessa a meta': chi disinstalla l'app subito dopo aver chiesto
 * l'oblio, che e' il caso piu' probabile di tutti, non la riaprirebbe mai.
 */

/** Quanti se ne cancellano in una notte. */
const TETTO_PER_NOTTE = 200;

const db = admin.firestore();

export const cancellaGliOblioScaduti = onSchedule(
  {
    region: "europe-west1",
    // **Alle 3:15 di notte, ora d'Europa.** Un'ora in cui nessuno sta usando
    // l'app: una cancellazione a meta' mentre qualcuno naviga lascerebbe la
    // sua sessione parlare di un account che non c'e' piu'.
    schedule: "15 3 * * *",
    timeZone: "Europe/Rome",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async () => {
    const adesso = admin.firestore.Timestamp.now();
    // **UNA RICERCA SU TUTTI I RAMI `oblio`**, che e' il motivo per cui quel
    // documento si chiama sempre cosi': un `collectionGroup` trova i figli
    // con lo stesso nome sotto qualunque genitore, senza dover scorrere tutti
    // gli utenti uno per uno.
    const scaduti = await db
      .collectionGroup("stato")
      .where("cancellaDopo", "<=", adesso)
      .limit(TETTO_PER_NOTTE)
      .get();

    let cancellati = 0;
    let falliti = 0;
    for (const doc of scaduti.docs) {
      // Il documento e' `users/{uid}/stato/oblio`: l'uid e' il nonno.
      if (doc.id !== "oblio") continue;
      const uid = doc.ref.parent.parent?.id;
      if (!uid) continue;
      try {
        // **PRIMA I DATI, POI L'ACCOUNT**, come nella callable: cancellando
        // prima l'account il token diventerebbe invalido e la cancellazione
        // dei dati resterebbe a meta'.
        await db.recursiveDelete(db.collection("users").doc(uid));
        await admin.auth().deleteUser(uid);
        cancellati++;
      } catch (err) {
        // **UN GUASTO SU UNO NON FERMA GLI ALTRI, e si registra col suo uid.**
        // Se l'account e' gia' sparito per altra via, i dati sono comunque
        // andati: quello che resta e' una riga nel registro, non una persona
        // scritta nel Cerchio.
        falliti++;
        logger.error("cancellaGliOblioScaduti: uno non e' andato", {
          uid, err: String(err),
        });
      }
    }
    logger.info("cancellaGliOblioScaduti: giro finito", {
      trovati: scaduti.size, cancellati, falliti,
    });
  }
);
