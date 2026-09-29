/**
 * CHI E' NEL CERCHIO ADESSO. Ordine ES voce 15.
 *
 * **Parole del fondatore:** "in alto nella barra superiore al centro
 * bisogerà inserire "online" con lucina verde e n. di utenti online".
 *
 * Qui sta la parte del conto che non ha bisogno del database, cosi' si prova
 * con `npm test` senza emulatore: quanto e' larga la finestra e quale numero
 * torna al telefono. La porta vera, `chiEOnline`, sta in `cerchio.ts` accanto
 * alle sorelle, perche' usa il loro stesso uid preso dal token.
 */

/**
 * **OGNI QUANTO CHIEDE IL TELEFONO**: due minuti, finche' l'app e' davanti.
 * Il numero vive anche nel telefono (`ChiEOnline.ogni`), e la prova lato
 * Dart pretende che i due dicano lo stesso.
 */
export const OGNI_QUANTO_CHIEDE_MS = 120 * 1000;

/**
 * **LA FINESTRA DELLA PRESENZA**: due minuti e mezzo. E' piu' larga del
 * passo del telefono di mezzo minuto, cioe' del margine di una rete lenta:
 * chi c'e' rinnova la sua presenza prima di uscire dal conto, e chi chiude
 * l'app ne esce entro due minuti e mezzo. Una finestra uguale al passo
 * farebbe lampeggiare il numero a ogni ritardo di un secondo.
 */
export const FINESTRA_DELLA_PRESENZA_MS = OGNI_QUANTO_CHIEDE_MS + 30 * 1000;

/** Da quale istante in poi una presenza conta ancora. */
export function confineDellaPresenza(adesso: number): number {
  return adesso - FINESTRA_DELLA_PRESENZA_MS;
}

/**
 * Il numero che torna al telefono. **Mai sotto uno**: chi chiede e' dentro
 * per forza, anche se il conto aggregato arriva un attimo prima che la sua
 * presenza sia contata, e leggere "0 online" dentro l'app sarebbe falso.
 */
export function quantiDaMostrare(conto: number): number {
  if (!Number.isFinite(conto)) return 1;
  return Math.max(1, Math.floor(conto));
}
