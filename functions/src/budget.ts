/**
 * I BUDGET DEL GIORNO, decisi dal server e non dal telefono.
 *
 * Qui vive la sola copia server dei limiti giornalieri. La copia di prodotto
 * resta la matrice dei piani nel client (`lib/core/entitlement/plan_catalog.dart`),
 * che e' cio' che si PROMETTE alla persona: due copie della stessa promessa
 * divergono sempre, quindi la prova
 * `test/i_limiti_del_server_sono_quelli_promessi_test.dart` legge QUESTO file e
 * la matrice e cade se un numero non coincide. Chi cambia un limite lo cambia
 * in tutti e due i posti, oppure la suite lo ferma.
 *
 * `null` vuol dire senza limite; `0` vuol dire che il piano non comprende
 * quella cosa, e non e' la stessa cosa: la cella "No" della matrice vale zero,
 * non infinito, ed e' un errore gia' fatto una volta.
 */
export type Piano = "free" | "tier1" | "tier2" | "tier3";
export type Budget =
  | "domande"
  | "approfondimenti"
  | "confronti"
  | "gettate"
  | "stese";

export const PIANI: Piano[] = ["free", "tier1", "tier2", "tier3"];
export const BUDGET: Budget[] = [
  "domande",
  "approfondimenti",
  "confronti",
  "gettate",
  "stese",
];

/** Nell'ordine dei piani: Viandante, Iniziato, Adepto, Illuminato. */
const LIMITI: Record<Budget, (number | null)[]> = {
  domande: [3, 5, 10, null],
  approfondimenti: [0, 3, 10, null],
  confronti: [0, 3, 5, null],
  gettate: [1, null, null, null],
  /**
   * LE STESE COMPLETE DI TAROCCHI, ordine BN voce 09.
   *
   * **Un budget PROPRIO, separato da quello delle gettate di rune**, perche'
   * il listino le tiene su due righe distinte e tenerle sullo stesso
   * contatore vorrebbe dire che chi ha gettato le rune non puo' piu' stendere
   * le carte.
   *
   * **I NUMERI SONO QUELLI DELLA RIGA "Stese complete tarocchi", e non quelli
   * della riga "Tarocchi carta singola".** L'ordine BN citava "una carta di
   * tarocchi al giorno" del Viandante credendo di citare la stesa: quella
   * frase e' l'altra riga, la carta singola. Il Briefing Progetto dice
   * "carta singola quotidiana e stese complete, dalla tre carte alla Croce
   * Celtica", quindi la stesa a tre carte e' una stesa COMPLETA, e il
   * listino le promette cosi': Eos pieno, Eos scontati, cinque al giorno,
   * illimitate. Zero non e' un vicolo cieco: e' il presupposto della strada
   * degli Eos, che si apre al primo tocco.
   *
   * Prima dell'ordine BN la stesa non aveva nessun gating: le stese erano
   * infinite e gratuite su tutti i piani, mentre il listino prometteva altro.
   */
  stese: [0, 0, 5, null],
};

/**
 * IL TETTO DI CORRETTEZZA per chi non ha limite, lo stesso numero che il
 * client dichiara: non e' una restrizione commerciale, e' la difesa contro il
 * tocco ripetuto. Vale sui budget che costano una chiamata al modello.
 */
export const TETTO_DI_CORRETTEZZA = 30;

/** I budget che, senza limite di piano, restano sotto il tetto di correttezza. */
const CON_TETTO: Budget[] = ["domande", "approfondimenti", "confronti"];

export function pianoValido(valore: unknown): Piano {
  return PIANI.includes(valore as Piano) ? (valore as Piano) : "free";
}

export function budgetValido(valore: unknown): Budget | null {
  return BUDGET.includes(valore as Budget) ? (valore as Budget) : null;
}

/** Il limite del piano per quel budget, oppure null se senza limite. */
export function limiteDi(budget: Budget, piano: Piano): number | null {
  return LIMITI[budget][PIANI.indexOf(piano)];
}

/**
 * Quanto resta oggi, dato quanto e' gia' stato speso.
 *
 * Senza limite di piano si torna il residuo sotto il tetto di correttezza per
 * i budget che costano una chiamata, e `null` per gli altri: le gettate sono
 * un calcolo locale, non c'e' nessun modello da difendere.
 */
export function restaOggi(
  budget: Budget,
  piano: Piano,
  speso: number
): number | null {
  const limite = limiteDi(budget, piano);
  if (limite === null) {
    if (!CON_TETTO.includes(budget)) return null;
    return Math.max(0, TETTO_DI_CORRETTEZZA - speso);
  }
  return Math.max(0, limite - speso);
}

/**
 * LA DECISIONE, pura e senza database: si puo' consumare, e con che residuo.
 *
 * Sta fuori dalla transazione apposta, cosi' si prova senza emulatore e senza
 * rete: la transazione la chiama e si limita a scrivere.
 */
export function decidi(
  budget: Budget,
  piano: Piano,
  speso: number
): {concesso: boolean; resta: number | null; motivo?: string} {
  const limite = limiteDi(budget, piano);
  // **IL LIMITE ZERO CEDE AL CREDITO COMPRATO, ordine BN voce 09.**
  //
  // Chi riscatta un uso con gli Eos porta lo speso a meno uno nella stessa
  // transazione del saldo: e' il credito comprato in anticipo sul proprio
  // piano, ed e' il modo in cui il riscatto funziona da BG voce 05. Qui
  // pero' lo zero rifiutava PRIMA di guardare lo speso, quindi su un budget
  // che il piano non comprende il server diceva di no anche a chi aveva
  // appena pagato: il telefono concedeva il gesto, la chiamata tornava un
  // no, e il conto locale si allineava buttando via l'acquisto. Valeva gia'
  // per gli approfondimenti e i confronti del Viandante, e con le stese
  // sarebbe stata la strada NORMALE, non l'eccezione.
  //
  // Adesso lo zero rifiuta solo quando non c'e' credito, cioe' quando lo
  // speso non e' andato sotto zero.
  if (limite === 0 && speso >= 0) {
    return {
      concesso: false,
      resta: 0,
      motivo: "Questo piano non comprende questa cosa.",
    };
  }
  const resta = restaOggi(budget, piano, speso);
  if (resta !== null && resta <= 0) {
    return {
      concesso: false,
      resta: 0,
      motivo: "Il budget di oggi e' finito.",
    };
  }
  const dopo = restaOggi(budget, piano, speso + 1);
  return {concesso: true, resta: dopo};
}
