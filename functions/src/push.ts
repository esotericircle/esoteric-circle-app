/**
 * LE PUSH DEI DONI DEL GIORNO. Ordine CG voce 16.
 *
 * **Il fatto che ha aperto la voce**, parole del fondatore del 30 agosto 2026:
 * "da quando ho iniziato a installare le varie build dell'APP NON HO MAI
 * RICEVUTO ALCUNA NOTIFICA PUSH PER I DONI, MAI!". La ragione era che il
 * canale non esisteva.
 *
 * **IL COSTO SI MISURA, NON SI STIMA, e qui sta il conto.**
 *
 * A un milione di persone con cinque Doni al giorno sono centocinquanta
 * milioni di messaggi al mese. Cloud Messaging non ha un costo per messaggio
 * sul listino pubblico, quindi i messaggi non si pagano: **si paga leggere chi
 * sono i destinatari**.
 *
 * - Il lavoro gira ogni QUINDICI minuti, cioe' 96 giri al giorno.
 * - Ogni giro chiede SOLO i destinatari di quel quarto d'ora, con una query
 *   sul campo `minutiUtc`: a un milione di persone con cinque Doni sparsi sulle
 *   96 fasce, un giro legge in media 5.000.000 / 96, cioe' circa 52.000
 *   documenti.
 * - Al giorno sono 5 milioni di letture, al mese 150 milioni.
 * - A 0,03 dollari ogni 100.000 letture fanno **45 dollari al mese**, che sta
 *   sotto il centinaio che l'ordine indica.
 * - Le chiamate delle funzioni sono 96 al giorno, cioe' 2.880 al mese: dentro
 *   i 2 milioni gratuiti, quindi zero.
 *
 * **E COSA SUCCEDEREBBE SCORRENDO TUTTI GLI UTENTI**, che e' il confronto che
 * l'ordine chiede: 1.000.000 di letture per giro, 96 milioni al giorno, 2,88
 * miliardi al mese, cioe' **864 dollari al mese**. Diciannove volte tanto. E'
 * per questo che la query sta sul minuto e non sulla persona.
 *
 * **LE ORE SI TENGONO IN UTC, e questa e' la scelta che rende possibile la
 * query.** Il telefono manda l'ora locale e il fuso; il server la converte una
 * volta e la scrive in minuti dalla mezzanotte UTC. Cosi' un giro chiede "chi
 * ha un Dono a questo minuto UTC" e non deve calcolare niente per nessuno: se
 * l'ora restasse locale, ogni giro dovrebbe leggere TUTTI e convertire, cioe'
 * il caso da 864 dollari.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

const OPZIONI = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
};

/** Ogni quanti minuti gira il lavoro. */
export const PASSO_IN_MINUTI = 15;

/** Quanti destinatari si servono al massimo in un giro. */
export const MASSIMI_DESTINATARI_PER_GIRO = 500;

/** I cinque Doni, coi nomi che il telefono manda. */
export const DONI = ["dawn", "breath", "oracle", "rune", "night"] as const;
export type Dono = typeof DONI[number];

/**
 * IL TESTO DI OGNI PUSH, NELLA VOCE DEL MAESTRO PROPRIETARIO.
 *
 * **Non e' un avviso di sistema**, ed e' il vincolo dell'ordine: "il testo di
 * ogni push e' nella voce del Maestro proprietario di quel Dono e non e' un
 * avviso di sistema".
 *
 * **Testi provvisori**: le parole che la persona legge le approva il fondatore.
 */
export const TESTI: Record<Dono, {titolo: string; corpo: string}> = {
  dawn: {
    titolo: "Medora",
    corpo: "La tua parola del giorno ti aspetta. Solleva l'alba.",
  },
  breath: {
    titolo: "Aura",
    corpo: "Un respiro, e il Soffio ti dice da che parte tira il vento.",
  },
  oracle: {
    titolo: "Medora",
    corpo: "L'Arcano di oggi è girato. Vieni a vedere quale.",
  },
  rune: {
    titolo: "Caligo",
    corpo: "Il sole scende e una runa è emersa. Guardala prima di sera.",
  },
  night: {
    titolo: "Caligo",
    corpo: "Prima del sonno, il Cerchio ha una cosa da dirti.",
  },
};

/**
 * L'IDENTIFICATIVO DELL'AVVISO, LO STESSO DELLA CHIAMATA LOCALE.
 *
 * **E' QUI CHE SI CHIUDE IL DOPPIONE**, che e' la decisione delegata piu'
 * delicata di questa voce. Le chiamate locali restano accese per tutti; se
 * arrivasse anche la push, alla stessa ora la persona riceverebbe due volte lo
 * stesso Dono.
 *
 * **La cura non e' spegnere le locali, e' dare alla push lo STESSO
 * identificativo.** Su Android un avviso con un identificativo gia' presente
 * SOSTITUISCE quello di prima invece di affiancarlo: e' lo stesso meccanismo
 * che l'ordine BC voce 05 usa gia' per l'Alba, dove due porte programmano lo
 * stesso avviso e una sola arriva.
 *
 * **Perche' non spegnere le locali a chi ha le push.** Perche' una push puo'
 * non arrivare, e in quel caso la persona non riceverebbe niente: la locale e'
 * la rete di sicurezza, ed e' gratuita. Spegnerla vorrebbe dire scambiare una
 * consegna sicura con una probabile. E in nessun caso le locali si spengono
 * per chi le push non le ha, che e' il vincolo esplicito dell'ordine.
 *
 * I numeri sono gli stessi di `AvvisiDelRito.idDelDono`, che parte da 1100.
 */
export const ID_DEL_DONO: Record<Dono, number> = {
  dawn: 1100,
  breath: 1101,
  oracle: 1102,
  rune: 1103,
  night: 1104,
};

/**
 * IL MAGAZZINO, PRESO PIGRAMENTE.
 *
 * **Chiamare `getFirestore()` al caricamento del modulo lo lega all'app di
 * Firebase nel momento sbagliato**: una prova che importa questo file per
 * leggere una costante muore prima di arrivare al primo `assert`, con un
 * errore che parla di `initializeApp` e non del codice. Preso qui, si prende
 * quando serve davvero.
 */
function db() {
  return getFirestore();
}

/** L'uid dal token, mai dal corpo. */
function uidDi(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Serve un account per parlare col Cerchio."
    );
  }
  return uid;
}

/**
 * I MINUTI DALLA MEZZANOTTE UTC di un'ora locale in un fuso.
 *
 * **Si converte UNA VOLTA, quando la persona sceglie**, e non a ogni giro per
 * ogni persona: e' la differenza fra 45 e 864 dollari al mese.
 */
export function minutiUtc(minutiLocali: number, fuso: string): number {
  // Lo scarto del fuso si legge da una data vera, cosi' l'ora legale entra nel
  // conto invece di essere un errore di sessanta minuti per meta' anno.
  const adesso = new Date();
  const locale = new Date(
    adesso.toLocaleString("en-US", {timeZone: fuso})
  );
  const utc = new Date(adesso.toLocaleString("en-US", {timeZone: "UTC"}));
  const scartoInMinuti = Math.round((locale.getTime() - utc.getTime()) / 60000);
  const fuoriDalGiorno = minutiLocali - scartoInMinuti;
  return ((fuoriDalGiorno % 1440) + 1440) % 1440;
}

/** La fascia di quindici minuti in cui cade un istante. */
export function fasciaDi(adesso: Date): number {
  const minuti = adesso.getUTCHours() * 60 + adesso.getUTCMinutes();
  return Math.floor(minuti / PASSO_IN_MINUTI) * PASSO_IN_MINUTI;
}

/**
 * SCRIVE LE SCELTE DELLE PUSH.
 *
 * Il telefono manda il token, il fuso e i Doni accesi con la loro ora locale.
 * Il server converte in minuti UTC e scrive UN documento per Dono acceso,
 * sotto `push_dei_doni`: e' la forma che permette al giro di chiedere solo i
 * destinatari del quarto d'ora.
 */
export const scriviLeScelteDellePush = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const token = String(request.data?.token ?? "").trim();
  const fuso = String(request.data?.fuso ?? "").trim();
  const doni = request.data?.doni;

  if (token.length < 20 || token.length > 500) {
    throw new HttpsError("invalid-argument", "Token non valido.");
  }
  if (!/^[A-Za-z]+\/[A-Za-z_\-+0-9/]+$/.test(fuso)) {
    throw new HttpsError("invalid-argument", "Fuso non valido.");
  }
  if (doni === null || typeof doni !== "object" || Array.isArray(doni)) {
    throw new HttpsError("invalid-argument", "Doni non validi.");
  }

  const lotto = db().batch();
  // Prima si tolgono le righe vecchie di questa persona, poi si scrivono
  // quelle nuove: senza, spegnere un Dono lo lascerebbe acceso sul server e
  // la persona continuerebbe a ricevere cio' che ha spento.
  const vecchie = await db()
    .collection("push_dei_doni")
    .where("uid", "==", uid)
    .get();
  vecchie.docs.forEach((d) => lotto.delete(d.ref));

  let quanti = 0;
  for (const [dono, minuti] of Object.entries(
    doni as Record<string, unknown>
  )) {
    if (!DONI.includes(dono as Dono)) continue;
    if (typeof minuti !== "number" || minuti < 0 || minuti >= 1440) continue;
    quanti++;
    lotto.set(db().collection("push_dei_doni").doc(`${uid}_${dono}`), {
      uid,
      dono,
      token,
      fuso,
      minutiLocali: minuti,
      minutiUtc: minutiUtc(minuti, fuso),
      aggiornatoIl: FieldValue.serverTimestamp(),
    });
  }
  await lotto.commit();
  return {scritte: quanti};
});

/** Toglie il token e le righe di questa persona. */
export const togliLeScelteDellePush = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const righe = await db()
    .collection("push_dei_doni")
    .where("uid", "==", uid)
    .get();
  const lotto = db().batch();
  righe.docs.forEach((d) => lotto.delete(d.ref));
  await lotto.commit();
  return {tolte: righe.size};
});

export interface EsitoDelGiro {
  fascia: number;
  destinatari: number;
  letture: number;
  spinte: number;
}

/**
 * UN GIRO DI PUSH.
 *
 * **Chiede SOLO i destinatari di questa fascia**, ed e' il conto che tiene il
 * costo sotto i cinquanta dollari al mese a un milione di persone.
 */
export async function spingiLaFascia(adesso: Date): Promise<EsitoDelGiro> {
  const fascia = fasciaDi(adesso);
  const righe = await db()
    .collection("push_dei_doni")
    .where("minutiUtc", ">=", fascia)
    .where("minutiUtc", "<", fascia + PASSO_IN_MINUTI)
    .limit(MASSIMI_DESTINATARI_PER_GIRO)
    .get();

  const fatto: EsitoDelGiro = {
    fascia,
    destinatari: righe.size,
    // **Le letture sono i documenti letti, e sono la grandezza che si paga.**
    letture: righe.size,
    spinte: 0,
  };
  if (righe.empty) return fatto;

  for (const riga of righe.docs) {
    const dati = riga.data() as Record<string, unknown>;
    const dono = dati.dono as Dono;
    const testo = TESTI[dono];
    if (!testo) continue;
    try {
      await getMessaging().send({
        token: String(dati.token),
        notification: {title: testo.titolo, body: testo.corpo},
        android: {
          notification: {
            channelId: "rito_alba",
            // **LO STESSO IDENTIFICATIVO DELLA CHIAMATA LOCALE**: su Android
            // un avviso con un tag gia' presente SOSTITUISCE quello di prima,
            // quindi la persona ne vede uno solo anche quando arrivano tutte
            // e due. La ragione intera sta su ID_DEL_DONO.
            tag: `dono_${ID_DEL_DONO[dono]}`,
          },
        },
        data: {dono},
      });
      fatto.spinte++;
    } catch (errore) {
      // **Un token morto non ferma il giro**, e va tolto: senza, il server
      // riproverebbe ogni giorno verso un indirizzo che non esiste piu'.
      logger.warn("push: un token non ha accettato la spinta", {dono});
      await riga.ref.delete();
    }
  }
  logger.info("push: giro finito", fatto);
  return fatto;
}

/**
 * IL LAVORO, ogni quindici minuti.
 *
 * **Novantasei giri al giorno**, cioe' 2.880 al mese: dentro i due milioni di
 * chiamate gratuite del listino.
 */
export const spingiIDoni = onSchedule(
  {
    schedule: `every ${PASSO_IN_MINUTI} minutes`,
    timeZone: "Europe/Rome",
    region: "europe-west1",
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async () => {
    const fatto = await spingiLaFascia(new Date());
    logger.info("spingiIDoni: giro", fatto);
  }
);
