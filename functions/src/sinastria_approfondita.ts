/**
 * LA SINASTRIA APPROFONDITA, IL CONTROLLO SUL SERVER. Ordine FT voce FT.04,
 * 14 ottobre 2026.
 *
 * **IL SERVER NON SI FIDA DELL'APP.** Il legame amore si apre solo se
 * entrambe le persone hanno almeno sedici anni compiuti al giorno della
 * lettura (il fondatore: "l'amore dai 16 anni in su"); gli altri tre legami
 * (amicizia, famiglia, lavoro) non hanno limite. Il controllo vive due
 * volte: qui, e in `lib/core/synastry_approfondita/legame_e_eta.dart`
 * (stesso algoritmo, stessa soglia). Un client modificato potrebbe mandare
 * una data di nascita falsa o saltare il controllo dell'app del tutto: la
 * decisione vera sta qui.
 */

/** I quattro legami, stessi nomi del lato app. */
export type Legame = "amore" | "amicizia" | "famiglia" | "lavoro";

/** Sedici anni, non un giorno di meno. */
export const ETA_MINIMA_PER_L_AMORE = 16;

/**
 * Quanti anni compiuti ha chi e' nato il [nascita], al giorno [adesso].
 * Stesso algoritmo del lato app: si confronta mese e giorno, mai "sottrai
 * l'anno", cosi' un nato il 29 febbraio non cade in un anno che non ce l'ha.
 */
export function anniCompiuti(nascita: Date, adesso: Date): number {
  let anni = adesso.getUTCFullYear() - nascita.getUTCFullYear();
  const meseNascita = nascita.getUTCMonth();
  const giornoNascita = nascita.getUTCDate();
  const meseAdesso = adesso.getUTCMonth();
  const giornoAdesso = adesso.getUTCDate();
  const compleannoGiaPassato =
    meseAdesso > meseNascita ||
    (meseAdesso === meseNascita && giornoAdesso >= giornoNascita);
  if (!compleannoGiaPassato) anni--;
  return anni;
}

/** Vero se [nascita] ha compiuto almeno sedici anni al giorno [adesso]. */
export function haAlmeno16Anni(nascita: Date, adesso: Date): boolean {
  return anniCompiuti(nascita, adesso) >= ETA_MINIMA_PER_L_AMORE;
}

/**
 * Vero se il [legame] si puo' aprire fra due persone nate [nascitaTua] e
 * [nascitaSua], al giorno [adesso]. Solo il legame amore ha un limite.
 */
export function legameApribile(
  legame: Legame,
  nascitaTua: Date,
  nascitaSua: Date,
  adesso: Date
): boolean {
  if (legame !== "amore") return true;
  return haAlmeno16Anni(nascitaTua, adesso) && haAlmeno16Anni(nascitaSua, adesso);
}
