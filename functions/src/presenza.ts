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
 * **OGNI QUANTO CHIEDE IL TELEFONO**: un minuto, finche' l'app e' davanti.
 * Erano due fino all'ordine EV voce 06: chi arrivava si vedeva dagli altri
 * fino a due minuti dopo, e il fondatore leggeva "ONLINE 1" su un telefono e
 * 2 sull'altro.
 * Il numero vive anche nel telefono (`ChiEOnline.ogni`), e la prova lato
 * Dart pretende che i due dicano lo stesso.
 */
export const OGNI_QUANTO_CHIEDE_MS = 60 * 1000;

/**
 * **LA FINESTRA DELLA PRESENZA**: cinque minuti, dall'ordine FF voce 01 del
 * 7 ottobre 2026 (un minuto e mezzo dall'ordine EV voce 06, due e mezzo
 * prima). Il fondatore: *"fino a quando l'app è aperta anche in background,
 * quell'utente deve risultare online"*. Con un minuto e mezzo chi rispondeva
 * a un messaggio usciva dall'elenco e rientrava subito dopo.
 *
 * Sullo sfondo il telefono non lascia all'app dire ancora "sono qui": il
 * suo ultimo segno e' quello che lascia uscendo (`chiEOnline` con `esce`,
 * che dall'ordine FF scrive l'ora invece di togliere la presenza), e da li'
 * si contano i cinque minuti. Resta piu' larga del passo del telefono, cosi'
 * chi ha l'app davanti non esce mai dal conto fra una domanda e l'altra.
 */
export const FINESTRA_DELLA_PRESENZA_MS = 5 * 60 * 1000;

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
