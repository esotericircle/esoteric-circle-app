/**
 * IL MOTORE DEGLI INDIZI, porta unica. Ordine FF voce 03, 7 ottobre 2026.
 *
 * **Parole del fondatore:** "andare a tentativi non ha senso ed è
 * frustrante, ci vorrebbero degli indizi, una sorta di caccia al tesoro".
 *
 * **Un punto solo.** Gli indizi nascono qui e i tre giochi del Cerchio li
 * chiedono a questo file: un gioco che ne costruisse uno per conto suo cade
 * sulla guardia `gli_indizi_hanno_una_porta_sola`.
 *
 * **Da dove viene un indizio, e da dove mai.** Un indizio e' una
 * caratteristica del Ritratto della persona da indovinare, oppure un dato
 * vero che l'app possiede: l'elemento e la modalita' del suo segno, il suo
 * animale guida se l'ha gia' nominato, l'archetipo secondario se l'ha
 * pubblicato. **Mai un comportamento osservato nell'app** (a che ora apre,
 * quante volte entra, cosa chiede ai Maestri): le FONTI sono un elenco
 * chiuso, e la guardia pretende che nessuna parli di comportamento.
 *
 * File senza database, cosi' si prova con `npm test`.
 */

/** Le sole fonti ammesse, in elenco chiuso. */
export const FONTI_DEGLI_INDIZI = [
  "ritratto",
  "elemento",
  "modalita",
  "animale",
  "archetipoSecondario",
] as const;
export type FonteDellIndizio = typeof FONTI_DEGLI_INDIZI[number];

/** Un indizio: la fonte e il valore, che il telefono traduce in parole. */
export interface Indizio {
  fonte: FonteDellIndizio;
  /** L'identificativo della caratteristica, del segno o dell'archetipo. */
  valore: string;
}

/** Quanti indizi al massimo prima di rispondere. */
export const INDIZI_MASSIMI = 3;

/**
 * **IL COSTO DI OGNI INDIZIO, in Eos**: il primo e' gratis, dal secondo
 * cinque. Lo stesso numero sta nel listino del telefono
 * (`ListinoDegliEos.indizio`), e la prova pretende che coincidano.
 */
export const PREZZO_DELL_INDIZIO = 5;

/** Quanto costa l'indizio numero `n` (da 1). */
export function costoDellIndizio(n: number): number {
  if (!Number.isInteger(n) || n < 1 || n > INDIZI_MASSIMI) {
    throw new RangeError(`indizio ${n} fuori da 1-${INDIZI_MASSIMI}`);
  }
  return n === 1 ? 0 : PREZZO_DELL_INDIZIO;
}

/**
 * **IL PUNTEGGIO SCENDE COGLI INDIZI**: tre punti senza indizi, due con
 * uno, uno con due, mezzo con tre. Chi sbaglia non prende niente.
 */
export const PUNTI_PER_INDIZI = [3, 2, 1, 0.5] as const;

export function puntiDellaRisposta(indiziChiesti: number,
  giusta: boolean): number {
  if (!giusta) return 0;
  const n = Math.max(0, Math.min(INDIZI_MASSIMI, Math.floor(indiziChiesti)));
  return PUNTI_PER_INDIZI[n];
}

/** I segni nell'ordine dello zodiaco, come li scrive il telefono. */
const SEGNI_ORDINATI = ["aries", "taurus", "gemini", "cancer", "leo",
  "virgo", "libra", "scorpio", "sagittarius", "capricorn", "aquarius",
  "pisces"];

/** L'elemento del segno: fuoco, terra, aria, acqua; nullo se sconosciuto. */
export function elementoDelSegno(segno: unknown): string | null {
  const i = SEGNI_ORDINATI.indexOf(String(segno));
  return i < 0 ? null : ["fuoco", "terra", "aria", "acqua"][i % 4];
}

/** La modalita' del segno: cardinale, fisso, mobile; nulla se sconosciuto. */
export function modalitaDelSegno(segno: unknown): string | null {
  const i = SEGNI_ORDINATI.indexOf(String(segno));
  return i < 0 ? null : ["cardinale", "fisso", "mobile"][i % 3];
}

/** Cio' che il server sa della persona da indovinare, e niente altro. */
export interface DatiDellaPersona {
  /** Le caratteristiche del Ritratto fotografato all'inizio del gioco. */
  ritratto: string[];
  segno?: string | null;
  /** Solo se l'ha gia' nominato (le quattro discese). */
  animale?: string | null;
  /** Solo se l'ha pubblicato nel suo Cerchio. */
  archetipoSecondario?: string | null;
}

/**
 * **TUTTI GLI INDIZI POSSIBILI per una persona**, in un ordine fisso: prima
 * i dati veri, poi le caratteristiche del Ritratto. Le caratteristiche che
 * sono gia' la risposta della domanda si tolgono (`esclusi`), cosi' un
 * indizio non dice la soluzione.
 */
export function indiziPossibili(dati: DatiDellaPersona,
  esclusi: readonly string[] = []): Indizio[] {
  const fuori = new Set(esclusi);
  const tutti: Indizio[] = [];
  const elemento = elementoDelSegno(dati.segno);
  if (elemento) tutti.push({fonte: "elemento", valore: elemento});
  const modalita = modalitaDelSegno(dati.segno);
  if (modalita) tutti.push({fonte: "modalita", valore: modalita});
  if (dati.animale) tutti.push({fonte: "animale", valore: dati.animale});
  if (dati.archetipoSecondario) {
    tutti.push({fonte: "archetipoSecondario", valore: dati.archetipoSecondario});
  }
  for (const c of dati.ritratto) tutti.push({fonte: "ritratto", valore: c});
  return tutti.filter((i) => !fuori.has(i.valore));
}

/**
 * **L'INDIZIO NUMERO `n` DI UNA PARTITA**, deterministico: lo stesso seme
 * della partita da' gli stessi indizi nello stesso ordine, cosi' chiederlo
 * due volte (una rete che ritenta) non ne regala un altro.
 */
export function indizioDellaPartita(dati: DatiDellaPersona, seme: string,
  n: number, esclusi: readonly string[] = []): Indizio | null {
  costoDellIndizio(n);
  const possibili = indiziPossibili(dati, esclusi);
  if (possibili.length === 0) return null;
  const ordinati = [...possibili].sort((a, b) =>
    hash(`${seme}|${a.fonte}|${a.valore}`) -
      hash(`${seme}|${b.fonte}|${b.valore}`));
  return ordinati[n - 1] ?? null;
}

/** Un hash a 32 bit, stabile fra le versioni di Node (FNV-1a). */
export function hash(s: string): number {
  let h = 0x811c9dc5;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h;
}
