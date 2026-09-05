/**
 * LE SCADENZE DEI DATI. Ordine CB voce 05.
 *
 * **Parole del fondatore, 29 agosto 2026:** "sara' Code a decidere per quanto
 * tempo ogni dato o categoria di dati rimarra' memorizzato secondo il miglior
 * rapporto logica/costo, magari facendosi guidare dall'esperienza di altre
 * app. decide Code, non l'hai ancora capito? e chiaramente deve motivarlo."
 *
 * **Cosa NON e' questo file.** Non e' il ritorno dei trenta giorni di attesa
 * prima della cancellazione, che l'ordine BE voce 07 ha tolto per decisione
 * del fondatore: quella era un'ATTESA imposta a chi chiede di sparire, e resta
 * abolita. Qui si parla del contrario, cioe' di dati che nessuno ha chiesto di
 * cancellare e che, passato il loro tempo, non servono piu' a nessuno.
 *
 * **Il criterio, applicato voce per voce.** Un dato si tiene finche' vale piu'
 * di quanto costa. Vale se qualcuno lo rilegge, se regge un conto, se difende
 * da un abuso. Costa in storage, in righe da scorrere e in superficie esposta:
 * un dato che non c'e' piu' non si perde e non si ruba.
 *
 * **Ogni tempo qui sotto porta la sua ragione scritta**, che e' cio' che il
 * fondatore ha chiesto per nome. Una scadenza senza motivazione non e'
 * accettata.
 */
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

/** Un giorno in millesimi, che e' l'unita' con cui si ragiona qui. */
const GIORNO = 24 * 60 * 60 * 1000;

/** Cosa scade, dopo quanto, e perche'. */
export interface Scadenza {
  /** Il nome della categoria, come si legge nel manifesto e nella policy. */
  nome: string;
  /** Dopo quanti giorni il dato non serve piu' a nessuno. */
  giorni: number;
  /** Perche' proprio quel numero. Una riga, e non e' facoltativa. */
  perche: string;
}

/**
 * IL LISTINO DELLE SCADENZE, che e' la decisione presa e la sua ragione.
 *
 * I numeri seguono la pratica delle app che tengono memoria a lungo (un anno
 * di conversazioni, due anni di contabilita', un mese di contatori tecnici):
 * non sono presi da nessuno in particolare, ma nessuno di loro tiene per
 * sempre cio' che nessuno rilegge.
 */
export const SCADENZE: Record<string, Scadenza> = {
  consumi: {
    nome: "I segni dei consumi del giorno",
    giorni: 30,
    perche:
      "sono i segni che impediscono di pagare due volte lo stesso gesto, e " +
      "un identificativo di movimento non torna mai dopo un mese: passato " +
      "quello sono righe che nessuno legge e che si scorrono a ogni conto.",
  },
  messaggi: {
    nome: "La memoria delle conversazioni coi Maestri",
    giorni: 365,
    perche:
      "la memoria lunga e' il valore del prodotto, e un Maestro che ricorda " +
      "l'anno scorso vale; oltre l'anno nessuno rilegge e ogni messaggio in " +
      "piu' pesa sul contesto e sullo storage senza cambiare una risposta.",
  },
  movimenti: {
    nome: "Il registro dei movimenti degli Eos",
    giorni: 730,
    perche:
      "e' il registro con cui si spiega un saldo contestato: due anni " +
      "coprono ogni contestazione ragionevole, e il saldo resta comunque, " +
      "perche' quello non e' storia, e' un numero vivo.",
  },
  lapidi: {
    nome: "Le impronte antifrode del dono di benvenuto",
    giorni: 730,
    perche:
      "impediscono di incassare il benvenuto due volte cancellandosi e " +
      "tornando; dopo due anni chi torna e' una persona nuova per davvero, e " +
      "tenere un'impronta per sempre e' sproporzionato al fine.",
  },
  ricordi: {
    nome: "L'indice dei Ricordi del Cerchio",
    giorni: 730,
    perche:
      "e' la riga magra di cio' che hai fatto, e regge la timeline dei " +
      "Ricordi: DUE ANNI e non uno, cioe' piu' dei messaggi, perche' il " +
      "testo di una conversazione se ne va a 365 giorni mentre il fatto che " +
      "quel giorno tu abbia parlato con Caligo resta leggibile. E' la " +
      "memoria umana che l'ordine CG chiede: prima sfuma il dettaglio, poi " +
      "il ricordo. Due anni e non di piu' perche' e' lo stesso orizzonte dei " +
      "movimenti degli Eos, che nei Ricordi si leggono accanto: due " +
      "orizzonti diversi sulla stessa schermata mostrerebbero un movimento " +
      "senza il giorno in cui e' successo.",
  },
  congedi: {
    nome: "I perche' di chi se ne va",
    giorni: 730,
    perche:
      "servono a capire cosa non funziona, e si leggono a stagioni: dopo due " +
      "anni parlano di un'app che non esiste piu'.",
  },
};

/** Il confine oltre il quale quella categoria non serve piu' a nessuno. */
export function confineDi(
  chiave: keyof typeof SCADENZE,
  adesso: number
): Timestamp {
  return Timestamp.fromMillis(adesso - SCADENZE[chiave].giorni * GIORNO);
}

/**
 * QUANTO SI CANCELLA IN UN GIRO.
 *
 * **Non e' un limite di comodo, e' cio' che rende il lavoro ripetibile.** Un
 * giro che provasse a cancellare tutto in una volta morirebbe sul tempo
 * massimo della funzione lasciando il lavoro a meta', e senza sapere dove si
 * era fermato. Con un tetto, ogni notte se ne porta via un pezzo e il giorno
 * dopo riprende da dove il tetto l'ha fermato.
 */
export const QUANTI_PER_GIRO = 400;

/** Il conto di un giro, cosi' il registro dice cosa e' stato fatto. */
export interface EsitoDellaPulizia {
  [categoria: string]: number;
}

/**
 * Cancella cio' che e' scaduto, categoria per categoria.
 *
 * Il tempo arriva da fuori, che e' la sola forma in cui una scadenza si puo'
 * provare: una funzione che leggesse l'orologio da sola si potrebbe provare
 * solo aspettando due anni.
 */
export async function pulisciCioCheEScaduto(
  adesso: number
): Promise<EsitoDellaPulizia> {
  const db = getFirestore();
  const fatto: EsitoDellaPulizia = {};

  async function portaVia(
    categoria: keyof typeof SCADENZE,
    query: FirebaseFirestore.Query
  ): Promise<void> {
    const scaduti = await query.limit(QUANTI_PER_GIRO).get();
    if (scaduti.empty) {
      fatto[categoria] = 0;
      return;
    }
    const lotto = db.batch();
    scaduti.docs.forEach((d) => lotto.delete(d.ref));
    await lotto.commit();
    fatto[categoria] = scaduti.size;
  }

  // I gruppi di collezioni si scorrono per NOME, che e' l'unico modo di
  // arrivare a `users/*/consumi` senza elencare gli utenti uno per uno.
  await portaVia(
    "consumi",
    db.collectionGroup("consumi")
      .where("quando", "<", confineDi("consumi", adesso))
  );
  // **I MESSAGGI PORTANO `createdAt`, non `quando`**, ed e' il nome che
  // `scriviLaMemoria` scrive: cercare il campo sbagliato non avrebbe dato
  // errore, avrebbe cancellato zero righe per sempre in silenzio.
  await portaVia(
    "messaggi",
    db.collectionGroup("messages")
      .where("createdAt", "<", confineDi("messaggi", adesso))
  );
  await portaVia(
    "movimenti",
    db.collectionGroup("movimenti")
      .where("quando", "<", confineDi("movimenti", adesso))
  );
  await portaVia(
    "lapidi",
    db.collection("lapidi_del_benvenuto")
      .where("quando", "<", confineDi("lapidi", adesso))
  );
  // **L'indice dei Ricordi, ordine CG voce 03.** Il campo `quando` di un mese
  // e' il primo istante di quel mese e non la data dell'ultima sincronia: un
  // mese vecchio risincronizzato oggi non deve tornare giovane.
  await portaVia(
    "ricordi",
    db.collectionGroup("ricordi")
      .where("quando", "<", confineDi("ricordi", adesso))
  );
  await portaVia(
    "congedi",
    db.collection("congedi")
      .where("quando", "<", confineDi("congedi", adesso))
  );

  logger.info("scadenze: giro finito", fatto);
  return fatto;
}
