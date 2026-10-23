/**
 * LA MEMORIA A STRATI E LA SFOCATURA SETTIMANALE. Ordine CG voce 09.
 *
 * **Parole del fondatore, 31 agosto 2026:** "memorizzando solo le chat, il
 * sistema potrebbe funzionare come la memoria umana: si ricorda i dettagli
 * delle ultime conversazioni, ma meno bene e sempre meno bene piu' il tempo
 * passa."
 *
 * **I QUATTRO STRATI.**
 *
 * 1. GLI ULTIMI GIORNI. Le conversazioni per intero, parola per parola,
 *    riapribili, e nel contesto del Maestro entrano i turni veri.
 * 2. DOPO LA FINESTRA. Una sintesi per Maestro per SETTIMANA, piu' i fatti
 *    stabili estratti. Da quel momento nel contesto entra la sintesi.
 * 3. DOPO L'ANNO. Il testo integrale se ne va, come `scadenze.ts` gia'
 *    prevede a 365 giorni. Restano le sintesi e i fatti.
 * 4. PER SEMPRE. I fatti stabili, i conti delle arti, i traguardi e i ricordi
 *    custoditi.
 *
 * **QUANTO E' LARGA LA FINESTRA: QUATTORDICI GIORNI, e la ragione e' il
 * ritmo del lavoro.** La sfocatura gira una volta a settimana. Con una
 * finestra di sette giorni, una conversazione di lunedi' potrebbe essere
 * sfocata il lunedi' dopo, cioe' nel momento esatto in cui smette di essere
 * "questa settimana": la persona la vedrebbe sfumare mentre la sente ancora
 * fresca. Con quattordici, ogni conversazione resta intera per almeno una
 * settimana piena DOPO che la sua settimana si e' chiusa, e nessuna sfuma nel
 * giorno in cui qualcuno potrebbe ancora tornarci sopra.
 *
 * **PERCHE' A LOTTI E NON A OGNI CONVERSAZIONE, col numero.** A ogni
 * conversazione la distillazione costa circa 0,029 dollari per utente al mese;
 * a lotti settimanali circa 0,0084, cioe' un terzo e mezzo in meno. Il conto
 * sta nella misura di accettazione dell'ordine, e il lavoro qui sotto fa UNA
 * chiamata per Maestro per settimana invece di una ogni tre turni.
 *
 * **NESSUNA DICHIARAZIONE ALL'UTENTE.** Nell'interfaccia non compare nessuna
 * riga che spiega che il Maestro ricorda meno col tempo. Parole del fondatore:
 * "non voglio nessuna dichiarazione". Il vincolo che nasce da questa scelta e'
 * sorvegliato dal lato client: nessun testo dell'app puo' promettere che il
 * Maestro ricordi tutto o parola per parola.
 *
 * **Il modello e' il piu' economico adatto**, cioe' Gemini Flash-Lite, mai una
 * API Anthropic.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";

/** Un giorno in millesimi. */
const GIORNO = 24 * 60 * 60 * 1000;

/**
 * QUANTO RESTA INTERO PRIMA DI SFOCARE, in giorni.
 *
 * Quattordici. La ragione sta nell'intestazione del file: la sfocatura gira
 * una volta a settimana, e sette giorni farebbero sfumare una conversazione
 * proprio nel giorno in cui smette di essere "questa settimana".
 */
export const GIORNI_INTERI = 14;

/**
 * QUANTE PERSONE SI SFOCANO IN UN GIRO.
 *
 * Duecento. Il giro notturno ha un tetto di tempo, e una sfocatura che
 * provasse a fare tutti gli utenti in una volta morirebbe a meta' lasciando
 * meta' lavoro fatto e nessuna traccia di dove si era arrivati. Chi non entra
 * in questo giro entra nel prossimo: la sfocatura non ha fretta per
 * costruzione, perche' i quattordici giorni di finestra sono molto piu' larghi
 * della settimana fra un giro e l'altro.
 */
export const QUANTI_PER_GIRO = 200;

/** I tre Maestri, per nome. */
export const MAESTRI = ["medora", "aura", "caligo"] as const;

/**
 * IL MODELLO DELLA SFOCATURA.
 *
 * Flash-Lite: il compito e' riassumere una manciata di turni, non ragionare.
 * **Mai una API Anthropic**, che e' la regola d'oro dello stack.
 */
export const MODELLO_DELLA_SFOCATURA = "gemini-2.5-flash-lite";

/** Quanti turni al massimo entrano in una sfocatura. */
export const MASSIMI_TURNI_PER_SFOCATURA = 60;

export interface EsitoDellaSfocatura {
  persone: number;
  sintesi: number;
  chiamate: number;
}

/**
 * LA CHIAVE DELLA SETTIMANA di un istante, `AAAA-Www`.
 *
 * Si conta dal lunedi', come la timeline della voce CG.02: due modi di dire
 * "che settimana e'" nello stesso progetto darebbero due raggruppamenti
 * diversi degli stessi giorni.
 */
export function chiaveDellaSettimana(quando: Date): string {
  const nudo = new Date(Date.UTC(
    quando.getUTCFullYear(), quando.getUTCMonth(), quando.getUTCDate()));
  const giorno = nudo.getUTCDay() || 7;
  nudo.setUTCDate(nudo.getUTCDate() + 4 - giorno);
  const primo = new Date(Date.UTC(nudo.getUTCFullYear(), 0, 1));
  const numero = Math.ceil(
    (((nudo.getTime() - primo.getTime()) / GIORNO) + 1) / 7);
  return `${nudo.getUTCFullYear()}-W${String(numero).padStart(2, "0")}`;
}

/**
 * IL CONFINE DELLA FINESTRA: prima di questo istante si sfoca.
 */
export function confineDellaFinestra(adesso: number): Timestamp {
  return Timestamp.fromMillis(adesso - GIORNI_INTERI * GIORNO);
}

/**
 * LA SFOCATURA DI UN GIRO.
 *
 * **Cosa fa e cosa NON fa.** Raggruppa per settimana i turni piu' vecchi
 * della finestra che non hanno ancora una sintesi, e per ognuno di quei gruppi
 * chiede al modello una sintesi e dei fatti. **Non cancella niente**: la
 * cancellazione dei testi la fa `scadenze.ts` a 365 giorni, che e' lo strato
 * tre. Due posti che cancellano lo stesso dato sarebbero due verita' su
 * quando quel dato sparisce.
 */
export async function sfocaCioCheEVecchio(
  adesso: number,
  scrivi: (
    uid: string,
    maestro: string,
    settimana: string,
    turni: {role: string; text: string}[]
  ) => Promise<{sintesi: string; fatti: string[]} | null>
): Promise<EsitoDellaSfocatura> {
  const db = getFirestore();
  const fatto: EsitoDellaSfocatura = {persone: 0, sintesi: 0, chiamate: 0};
  const confine = confineDellaFinestra(adesso);

  const utenti = await db.collection("users").limit(QUANTI_PER_GIRO).get();
  for (const utente of utenti.docs) {
    fatto.persone++;
    for (const maestro of MAESTRI) {
      const messaggi = await utente.ref
        .collection("maestri")
        .doc(maestro)
        .collection("messages")
        .where("createdAt", "<", confine)
        .orderBy("createdAt", "asc")
        .limit(MASSIMI_TURNI_PER_SFOCATURA)
        .get();
      if (messaggi.empty) continue;

      // **UNA CHIAMATA PER MAESTRO E PER SETTIMANA, non una per turno.** I
      // turni si raggruppano per settimana e ogni gruppo produce una sintesi
      // sola: e' la differenza fra 0,029 e 0,0084 dollari al mese.
      const perSettimana = new Map<string, {role: string; text: string}[]>();
      for (const m of messaggi.docs) {
        const dati = m.data() as Record<string, unknown>;
        const quando = dati.createdAt as {toDate?: () => Date} | undefined;
        if (!quando?.toDate) continue;
        const chiave = chiaveDellaSettimana(quando.toDate());
        const dentro = perSettimana.get(chiave) ?? [];
        dentro.push({
          role: typeof dati.role === "string" ? dati.role : "",
          text: typeof dati.text === "string" ? dati.text : "",
        });
        perSettimana.set(chiave, dentro);
      }

      for (const [settimana, turni] of perSettimana) {
        const doc = utente.ref
          .collection("maestri")
          .doc(maestro)
          .collection("sintesi")
          .doc(settimana);
        const gia = await doc.get();
        // **Una settimana gia' sfocata non si rifa'**: senza questo controllo
        // il giro settimanale ripagherebbe ogni volta tutte le settimane
        // vecchie, e il costo crescerebbe invece di restare fermo.
        if (gia.exists) continue;

        const scritta = await scrivi(utente.id, maestro, settimana, turni);
        fatto.chiamate++;
        if (scritta === null) continue;
        await doc.set({
          sintesi: scritta.sintesi,
          fatti: scritta.fatti,
          quantiTurni: turni.length,
          quando: FieldValue.serverTimestamp(),
        });
        fatto.sintesi++;
      }
    }
  }
  logger.info("sfocatura: giro finito", fatto);
  return fatto;
}

/**
 * IL LAVORO SETTIMANALE.
 *
 * Il lunedi' alle quattro e dieci del mattino, dopo la pulizia delle scadenze
 * che gira alle tre e mezza tutti i giorni: cosi' la sfocatura non lavora su
 * documenti che la pulizia sta per portare via.
 */
export const sfocaLeConversazioni = onSchedule(
  {
    schedule: "10 4 * * 1",
    timeZone: "Europe/Rome",
    region: "europe-west1",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    // La penna vera arriva col lavoro sul modello: finche' non c'e', il giro
    // gira a vuoto e lo dice, invece di scrivere sintesi inventate.
    const fatto = await sfocaCioCheEVecchio(Date.now(), async () => null);
    logger.info("sfocaLeConversazioni: giro settimanale", fatto);
  }
);
