/**
 * IL BORSELLINO EOS: il dato, corretto e inattaccabile. Nessuna schermata e
 * nessuna animazione, che arriveranno con un altro ordine.
 *
 * **Il saldo non e' un numero che si scrive: e' la somma dei movimenti.** Un
 * saldo scritto a mano diverge dalla sua storia alla prima scrittura persa, e
 * quando diverge non c'e' modo di sapere quale dei due ha ragione. Qui il
 * documento del saldo esiste per poterlo LEGGERE in fretta, ma nasce e cambia
 * solo dentro la stessa transazione che scrive il movimento, quindi le due
 * cose non possono discordare.
 *
 * **Ogni movimento ha un suo identificativo e si applica una volta sola.** Una
 * rete che ritenta e' la regola, non l'eccezione: senza idempotenza il premio
 * di un Sigillo si accredita due volte, e un saldo che cresce da solo e' un
 * saldo che non vale niente.
 */
import {Piano} from "./budget";

export type CausaleEos =
  | "premio_sigillo"
  | "premio_rituale"
  | "bonus_condivisione"
  | "acquisto"
  | "spesa"
  | "rettifica";

export const CAUSALI: CausaleEos[] = [
  "premio_sigillo",
  "premio_rituale",
  "bonus_condivisione",
  "acquisto",
  "spesa",
  "rettifica",
];

/** Le causali che il CLIENT puo' chiedere. Le altre le muove solo il server. */
export const CAUSALI_CHIEDIBILI: CausaleEos[] = [
  "premio_sigillo",
  "bonus_condivisione",
  "spesa",
];

/**
 * IL BONUS GRADUATO DELLA CONDIVISIONE, e questa e' l'unica logica che lo
 * decide.
 *
 * L'ordine O chiede che la celebrazione si appoggi al bonus graduato gia'
 * deciso senza scriverne un secondo. Quel bonus, verificato nel codice, NON
 * esisteva da nessuna parte: c'erano solo le card condivisibili e una riga
 * commerciale nella matrice dei piani. Quindi ne nasce UNO, qui, dove vive il
 * denaro, e tutte e due le forme della celebrazione passano da lui.
 *
 * La graduazione e' quella delle Linee Guida: massimo per l'invito che porta
 * un download, alto per il social pubblico, medio per la condivisione privata
 * verificabile, zero se non si condivide, col Sigillo comunque acceso. I
 * numeri sono provvisori come quelli dei premi e li fissera' l'ordine
 * dell'economia: quello che non e' provvisorio e' che li decide il server.
 */
export const BONUS_DELLA_CONDIVISIONE: Record<string, number> = {
  invito_con_download: 60,
  social_pubblico: 30,
  condivisione_privata: 15,
};

/**
 * IL TETTO GIORNALIERO ANTI FARMING: oltre questo numero di condivisioni
 * premiate in un giorno il Sigillo resta acceso e il bonus non si accredita
 * piu'. Senza, un pomeriggio di condivisioni finte varrebbe piu' di un mese
 * di cammino.
 */
export const TETTO_CONDIVISIONI_PREMIATE = 3;

/**
 * IL BENVENUTO, una volta sola nella vita del Cerchio. Ordine AN voce 07,
 * dall'economia approvata: 250 Eos alla prima apertura assoluta, perche'
 * bastano per un'esperienza premium vera e la persona capisce subito cosa
 * si perde restando gratis.
 */
export const BENVENUTO = 250;

/**
 * L'ACCREDITO DEL GIORNO, per piano, al primo avvio di ogni giornata.
 * Nell'ordine: Viandante, Iniziato, Adepto, Illuminato. In Demo vale il
 * Viandante. Il confine del giorno e' la mezzanotte locale che il server
 * gia' usa per i contatori: il SALDO non si azzera mai, si rinnovano solo i
 * tetti d'uso, e questo e' un accredito, non un ripristino.
 */
export const ACCREDITO_DEL_GIORNO: Record<Piano, number> = {
  free: 20,
  tier1: 40,
  tier2: 60,
  tier3: 100,
};

/**
 * LA DOTE DI SOTTOSCRIZIONE, alla PRIMA sottoscrizione di un piano. Il dato
 * e' pronto e la pagina dei Piani lo mostra come valore del piano;
 * l'accredito vero scattera' quando gli abbonamenti saranno acquistabili.
 */
export const DOTE_DEL_PIANO: Record<Piano, number> = {
  free: 0,
  tier1: 500,
  tier2: 1500,
  tier3: 3000,
};

/**
 * QUANTO VALE UN PREMIO lo decide il server, non chi lo chiede.
 *
 * Il client dice "ho compiuto questo", non "dammi cento": il valore sta qui.
 * Un premio con l'importo nel corpo della richiesta e' un borsellino aperto.
 */
export const VALORE_DEL_PREMIO: Record<string, number> = {
  // I TRAGUARDI DEL CAMMINO, ordine O: il client dice quale traguardo ha
  // raggiunto e il server sa quanto vale, perche' il valore dipende solo
  // dalla posizione sul sentiero e dalla curva decisa. Un premio con
  // l'importo nel corpo della richiesta sarebbe un borsellino aperto.
  // **IL LISTINO E' LA CURVA DEL CORPUS, ordine AR voce 05.** Prima c'erano
  // due soli scaglioni piu' cinque grandi alle posizioni 10, 20, 30, 40 e 50:
  // col corpus della revisione C i grandi stanno su 11, 22, 33, 44 e 55 e i
  // piccoli valgono di piu' salendo. Un listino fermo avrebbe fatto due
  // danni insieme: l'accredito dei grandi tornava errore, perche' il motivo
  // non esisteva piu, e i piccoli venivano pagati dieci Eos anche quando il
  // corpus ne prometteva cinquantacinque. Qui il valore dipende SOLO dalla
  // posizione sul sentiero, che nei tre sentieri paga uguale, e la somma di
  // un sentiero intero fa 2.010 Eos come dice il corpus.
  traguardo_gradino_1: 10,
  traguardo_gradino_2: 10,
  traguardo_gradino_3: 10,
  traguardo_gradino_4: 10,
  traguardo_gradino_5: 10,
  traguardo_gradino_6: 10,
  traguardo_gradino_7: 10,
  traguardo_gradino_8: 10,
  traguardo_gradino_9: 10,
  traguardo_gradino_10: 10,
  traguardo_gradino_11: 40,
  traguardo_gradino_12: 20,
  traguardo_gradino_13: 20,
  traguardo_gradino_14: 20,
  traguardo_gradino_15: 20,
  traguardo_gradino_16: 20,
  traguardo_gradino_17: 20,
  traguardo_gradino_18: 20,
  traguardo_gradino_19: 20,
  traguardo_gradino_20: 20,
  traguardo_gradino_21: 20,
  traguardo_gradino_22: 60,
  traguardo_gradino_23: 30,
  traguardo_gradino_24: 30,
  traguardo_gradino_25: 30,
  traguardo_gradino_26: 30,
  traguardo_gradino_27: 30,
  traguardo_gradino_28: 30,
  traguardo_gradino_29: 30,
  traguardo_gradino_30: 30,
  traguardo_gradino_31: 30,
  traguardo_gradino_32: 30,
  traguardo_gradino_33: 80,
  traguardo_gradino_34: 45,
  traguardo_gradino_35: 45,
  traguardo_gradino_36: 45,
  traguardo_gradino_37: 45,
  traguardo_gradino_38: 45,
  traguardo_gradino_39: 45,
  traguardo_gradino_40: 45,
  traguardo_gradino_41: 45,
  traguardo_gradino_42: 45,
  traguardo_gradino_43: 45,
  traguardo_gradino_44: 100,
  traguardo_gradino_45: 55,
  traguardo_gradino_46: 55,
  traguardo_gradino_47: 55,
  traguardo_gradino_48: 55,
  traguardo_gradino_49: 55,
  traguardo_gradino_50: 55,
  traguardo_gradino_51: 55,
  traguardo_gradino_52: 55,
  traguardo_gradino_53: 55,
  traguardo_gradino_54: 55,
  traguardo_gradino_55: 130,
  // Il Sigillo del giorno, cioe' il rito compiuto: il numero e' provvisorio e
  // lo fissera' l'ordine dell'economia, ma deve gia' essere un numero del
  // server perche' il cammino sia inattaccabile fin da adesso.
  sigillo_del_giorno: 10,
  rito_dell_alba: 5,
  runa_del_tramonto: 5,
};

export function causaleValida(valore: unknown): CausaleEos | null {
  return CAUSALI.includes(valore as CausaleEos) ?
    (valore as CausaleEos) :
    null;
}

/**
 * L'IMPORTO di un movimento chiesto dal client, col segno giusto, oppure null
 * se non e' una richiesta legittima.
 *
 * Le spese arrivano con un importo, ma solo positivo e con un tetto: un
 * numero negativo o enorme in una spesa e' un accredito travestito.
 */
export const SPESA_MASSIMA = 10000;

export function importoRichiesto(
  causale: CausaleEos,
  motivo: string,
  quanti: unknown
): number | null {
  if (causale === "premio_sigillo" || causale === "premio_rituale") {
    const valore = VALORE_DEL_PREMIO[motivo];
    return typeof valore === "number" ? valore : null;
  }
  if (causale === "bonus_condivisione") {
    const valore = BONUS_DELLA_CONDIVISIONE[motivo];
    return typeof valore === "number" ? valore : null;
  }
  if (causale === "spesa") {
    if (typeof quanti !== "number" || !Number.isInteger(quanti)) return null;
    if (quanti <= 0 || quanti > SPESA_MASSIMA) return null;
    return -quanti;
  }
  // acquisto e rettifica non passano di qui: li muove il server per conto suo.
  return null;
}

/** Il saldo dopo un movimento, che non puo' mai scendere sotto zero. */
export function saldoDopo(saldo: number, importo: number): number | null {
  const dopo = saldo + importo;
  if (dopo < 0) return null;
  return dopo;
}
