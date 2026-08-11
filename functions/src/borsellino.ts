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
  traguardo_mini_primi_tre: 20,
  traguardo_mini: 10,
  traguardo_grande_10: 80,
  traguardo_grande_20: 150,
  traguardo_grande_30: 250,
  traguardo_grande_40: 400,
  traguardo_grande_50: 600,
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
