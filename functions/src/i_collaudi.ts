/**
 * IL REGISTRO DEI COLLAUDI. Ordine FD voce 05.
 *
 * **Perche' esiste.** Il giro del Cerchio popolato fra due telefoni di
 * collaudo passava dalle presenze condivise: il server leggeva i novantasei
 * frammenti di tutti, riscriveva l'istantanea con tutti i presenti, e la
 * tendina mandava al telefono fino a dodici schede di utenti reali. La regola
 * R8 dell'ordine FD vieta di leggere o scrivere un documento di un utente
 * reale in qualunque momento, e il fondatore ha scelto, il 5 ottobre 2026,
 * di isolare i collaudi.
 *
 * **Cosa fa.** Gli account scritti qui vivono in uno spazio proprio della
 * presenza: `collaudo_cerchio_presenze` e `collaudo_cerchio_adesso` invece di
 * `cerchio_presenze` e `cerchio_adesso`. Non compaiono agli utenti reali, e
 * gli utenti reali non compaiono a loro.
 *
 * **La copia leggibile** sta in `docs/collaudo/registro_dei_collaudi.md`, e
 * la prova `i_collaudi_sono_registrati_test.dart` pretende che le due copie
 * dicano gli stessi account.
 */
export const ACCOUNT_DI_COLLAUDO: Readonly<Record<string, string>> = {
  "iToukegmg2P3LBmlyYGJjkxvFbs1": "Realme 767f596c, nome nel Cerchio Collaudo",
};

/** Vero se [uid] e' un account di collaudo. */
export function eUnCollaudo(uid: string): boolean {
  return Object.prototype.hasOwnProperty.call(ACCOUNT_DI_COLLAUDO, uid);
}

/** Lo spazio della presenza: vuoto per gli utenti, `collaudo_` per i collaudi. */
export type SpazioDellaPresenza = "" | "collaudo_";

/** Lo spazio della presenza di [uid]. */
export function spazioDi(uid: string): SpazioDellaPresenza {
  return eUnCollaudo(uid) ? "collaudo_" : "";
}
