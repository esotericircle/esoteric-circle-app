/**
 * IL LAVORO NOTTURNO CHE PORTA VIA CIO' CHE E' SCADUTO. Ordine CB voce 05.
 *
 * **Perche' una funzione a orario e non una cancellazione alla lettura.**
 * Cancellare mentre qualcuno legge farebbe pagare a quella persona, e in quel
 * momento, un lavoro che non le serve: la sua risposta arriverebbe piu' tardi
 * perche' il Cerchio stava facendo pulizia. Di notte non aspetta nessuno.
 *
 * **Perche' un tetto per giro.** Un giro senza tetto morirebbe sul tempo
 * massimo lasciando il lavoro a meta' e senza sapere dove: col tetto ogni
 * notte se ne porta via un pezzo e la notte dopo riprende, perche' la
 * condizione che sceglie i documenti e' sempre la stessa.
 *
 * **L'ora e' le 03:30 di Roma**, che e' l'ora in cui il Cerchio ha meno gente
 * dentro: e' la stessa ragione per cui i doni del giorno cominciano alle sette.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import {pulisciCioCheEScaduto} from "./scadenze";

export const pulisciLeScadenze = onSchedule(
  {
    schedule: "30 3 * * *",
    timeZone: "Europe/Rome",
    region: "europe-west1",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async () => {
    const fatto = await pulisciCioCheEScaduto(Date.now());
    logger.info("pulisciLeScadenze: giro notturno", fatto);
  }
);
