/**
 * GLI ENIGMI DEL CERCHIO, la parte senza database. Ordine FF, 8 ottobre
 * 2026: il Ritratto (voce 02), Chi del Cerchio (04), la Prova (05), le
 * Sfide (06), i Tempi (07). Le porte vere stanno in `il_cerchio_sociale.ts`
 * accanto alle sorelle; qui c'e' cio' che si prova con `npm test`.
 *
 * Gli indizi nascono SOLO in `gli_indizi.ts` (voce 03), e qui si chiedono.
 */
import {Piano} from "./budget";
import {DatiDellaPersona, hash, elementoDelSegno} from "./gli_indizi";
import {ELEMENTI_DEL_RITRATTO} from "./il_ritratto_del_corpus";
import {FASCE_DELLE_PROVE, PESI_DELLE_PROVE} from "./le_prove_del_corpus";

// ---------------------------------------------------------------------------
// IL RITRATTO
// ---------------------------------------------------------------------------

/** Quante caratteristiche ha un Ritratto compilato. */
export const TRATTI_DEL_RITRATTO = 20;

/**
 * Il Ritratto che arriva dal telefono, se e' valido: venti numeri diversi
 * fra quelli del corpus (1-120). Nullo altrimenti: un Ritratto a meta' non
 * si scrive.
 */
export function ritrattoValido(valore: unknown): number[] | null {
  if (!Array.isArray(valore) || valore.length !== TRATTI_DEL_RITRATTO) {
    return null;
  }
  const numeri = valore.map((v) => Number(v));
  if (numeri.some((n) => !Number.isInteger(n) ||
    ELEMENTI_DEL_RITRATTO[n] === undefined)) return null;
  if (new Set(numeri).size !== TRATTI_DEL_RITRATTO) return null;
  return numeri;
}

// ---------------------------------------------------------------------------
// I LIMITI PER PIANO
// ---------------------------------------------------------------------------

/**
 * **GLI INDOVINELLI AL GIORNO.** L'ordine FF: tre al Viandante, dieci
 * all'Iniziato, "senza limite dall'Adepto in su". **Premessa abbattuta**:
 * l'ordine CE voce 08 ha tolto ogni illimitato ("illimitato mi espone
 * all'abuso o uso incontrollato o bot", `budget.ts`), e la regola del
 * fondatore viene prima: l'Adepto ha cinquanta, l'Illuminato il triplo,
 * molto sopra un uso umano.
 */
export const INDOVINELLI_AL_GIORNO: Record<Piano, number> = {
  free: 3, tier1: 10, tier2: 50, tier3: 150,
};

/** Le scommesse al giorno: una, tre, poi tetti ampi per la stessa ragione. */
export const SCOMMESSE_AL_GIORNO: Record<Piano, number> = {
  free: 1, tier1: 3, tier2: 15, tier3: 45,
};

/** La sfida a due vale dall'Iniziato in su. */
export function sfidaPerIlPiano(piano: Piano): boolean {
  return piano !== "free";
}

/** Il segno di chi ti ha indovinato costa venti Eos, uno alla volta. */
export const PREZZO_DEL_SEGNO = 20;

// ---------------------------------------------------------------------------
// CHI DEL CERCHIO
// ---------------------------------------------------------------------------

/** Cio' che il server sa di un volto del Cerchio, per l'indovinello. */
export interface Volto extends DatiDellaPersona {
  uid: string;
  /** L'archetipo dominante, solo se la persona l'ha pubblicato. */
  archetipo?: string | null;
}

/**
 * **CHI PUO' COMPARIRE NEI GIOCHI DEGLI ALTRI**, voce FF.04.4: chi ha il
 * Ritratto compilato, non ha spento l'interruttore e ha quattordici anni.
 */
export function puoComparire(p: {ritratto: unknown; fuoriDaiGiochi?: unknown;
  quattordici: boolean}): boolean {
  return ritrattoValido(p.ritratto) !== null && p.fuoriDaiGiochi !== true &&
    p.quattordici;
}

/**
 * **LA SCOMMESSA SI PIAZZA FINCHE' L'AMICO NON HA FATTO LA PROVA**, voce
 * FF.05.3: dopo e' tardi e si vede il punteggio. Una sola per amico a
 * settimana, e dentro il limite del giorno.
 */
export function scommessaAmmessa(a: {provaDellAmico: boolean; gia: boolean;
  usateOggi: number; limite: number}):
  "ok" | "tardi" | "gia" | "limite" {
  if (a.provaDellAmico) return "tardi";
  if (a.gia) return "gia";
  if (a.usateOggi >= a.limite) return "limite";
  return "ok";
}

/** I tipi di domanda: tutte con la risposta da un dato vero. */
export type TipoDiDomanda = "tratto" | "elemento" | "archetipo" | "animale";

export interface Domanda {
  tipo: TipoDiDomanda;
  /** Il numero del tratto, l'elemento, l'archetipo o l'animale. */
  valore: string;
}

/** La chiave di una domanda, per il conto di chi ti ha indovinato. */
export function chiaveDellaDomanda(d: Domanda): string {
  return `${d.tipo}:${d.valore}`;
}

/** Il valore di un volto per un tipo di domanda, nullo se non c'e'. */
function valoriDi(v: Volto, tipo: TipoDiDomanda): string[] {
  switch (tipo) {
  case "tratto": return v.ritratto;
  case "elemento": {
    const e = elementoDelSegno(v.segno);
    return e ? [e] : [];
  }
  case "archetipo": return v.archetipo ? [v.archetipo] : [];
  case "animale": return v.animale ? [v.animale] : [];
  }
}

/**
 * **LA DOMANDA DELL'INDOVINELLO**, deterministica per il seme: un valore
 * che fra i quattro volti appartiene a UNO solo, cosi' la risposta giusta e'
 * una e viene da un dato vero. I tipi si provano in un ordine mescolato dal
 * seme; nullo se nessun valore distingue un volto dagli altri tre.
 */
export function laDomanda(volti: Volto[], seme: string):
  {domanda: Domanda; giusta: string} | null {
  const tipi: TipoDiDomanda[] = ["archetipo", "animale", "elemento", "tratto"];
  tipi.sort((a, b) => hash(`${seme}|${a}`) - hash(`${seme}|${b}`));
  for (const tipo of tipi) {
    const unici: {valore: string; uid: string}[] = [];
    for (const v of volti) {
      for (const valore of valoriDi(v, tipo)) {
        const chi = volti.filter((w) => valoriDi(w, tipo).includes(valore));
        if (chi.length === 1) unici.push({valore, uid: v.uid});
      }
    }
    if (unici.length === 0) continue;
    unici.sort((a, b) => hash(`${seme}|${a.valore}`) -
      hash(`${seme}|${b.valore}`));
    return {domanda: {tipo, valore: unici[0].valore}, giusta: unici[0].uid};
  }
  return null;
}

/**
 * Gli indizi non dicono la soluzione: si tolgono il tratto della domanda e,
 * per la domanda sull'elemento, l'elemento stesso.
 */
export function esclusiPerLaDomanda(d: Domanda): string[] {
  return [d.valore];
}

/**
 * **I QUATTRO VOLTI**, pescati dal seme fra i candidati: chi ha il Ritratto
 * compilato e non si e' tolto dai giochi (il filtro lo fa chi chiama).
 */
export function quattroVolti<T extends {uid: string}>(candidati: T[],
  seme: string, quanti = 4): T[] {
  return [...candidati]
    .sort((a, b) => hash(`${seme}|${a.uid}`) - hash(`${seme}|${b.uid}`))
    .slice(0, quanti);
}

/**
 * **LA RISPOSTA CHE TORNA AL TELEFONO**, e solo questa: il server non manda
 * mai chi ha indovinato a chi e' stato indovinato, e a chi gioca manda
 * soltanto l'esito della sua partita. La prova misura cosa viaggia.
 */
export function rispostaDellIndovinello(args: {
  giusta: boolean; punti: number; uidGiusto: string;
}): {giusta: boolean; punti: number; era: string} {
  return {giusta: args.giusta, punti: args.punti, era: args.uidGiusto};
}

/**
 * Cio' che la persona indovinata legge: per ogni domanda quante persone
 * l'hanno indovinata, e i segni gia' scoperti. Mai un identificativo.
 */
export function ilRitornoDi(doc: Record<string, unknown> | undefined):
  {chiave: string; quanti: number; segni: string[]; daScoprire: number}[] {
  const per = (doc?.perDomanda ?? {}) as Record<string,
    {quanti?: number; segni?: string[]; rivelati?: number}>;
  return Object.entries(per).map(([chiave, v]) => {
    const segni = Array.isArray(v.segni) ? v.segni.map(String) : [];
    const rivelati = Math.min(segni.length, Number(v.rivelati ?? 0));
    return {chiave, quanti: Number(v.quanti ?? 0),
      segni: segni.slice(0, rivelati), daScoprire: segni.length - rivelati};
  }).sort((a, b) => a.chiave.localeCompare(b.chiave));
}

// ---------------------------------------------------------------------------
// LA PROVA
// ---------------------------------------------------------------------------

/** La settimana si scrive col suo lunedi', AAAA-MM-GG. */
export function settimanaValida(valore: unknown): string | null {
  const s = String(valore ?? "");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) return null;
  const d = new Date(`${s}T12:00:00Z`);
  if (Number.isNaN(d.getTime()) || d.getUTCDay() !== 1) return null;
  return s;
}

/** Il numero ISO della settimana del lunedi' dato (lo stesso del telefono). */
export function numeroDellaSettimana(lunedi: string): number {
  const g = new Date(`${lunedi}T00:00:00Z`);
  const giovedi = new Date(g.getTime() + (4 - (g.getUTCDay() || 7)) * 864e5);
  const primo = Date.UTC(giovedi.getUTCFullYear(), 0, 1);
  return Math.floor((giovedi.getTime() - primo) / 864e5 / 7) + 1;
}

/** Le dieci domande della settimana: le dodici meno r e r+1, r = n % 12. */
export function domandeDellaSettimana(lunedi: string): number[] {
  const r = numeroDellaSettimana(lunedi) % 12;
  const salta = new Set([r, (r + 1) % 12]);
  const fuori: number[] = [];
  for (let i = 0; i < 12; i++) if (!salta.has(i)) fuori.push(i + 1);
  return fuori;
}

/**
 * **IL PUNTEGGIO DELLA PROVA**, dal server e non dal telefono: le scelte
 * (0-3, la posizione della risposta nel corpus, qualunque sia l'ordine in
 * cui il telefono le ha mostrate) si traducono nei pesi del corpus. Nullo se
 * le scelte non sono dieci risposte valide.
 */
export function punteggioDi(tema: number, lunedi: string,
  scelte: unknown): number | null {
  const pesi = PESI_DELLE_PROVE[tema];
  if (!pesi || !Array.isArray(scelte) || scelte.length !== 10) return null;
  const domande = domandeDellaSettimana(lunedi);
  let somma = 0;
  for (let i = 0; i < 10; i++) {
    const s = Number(scelte[i]);
    if (!Number.isInteger(s) || s < 0 || s > 3) return null;
    somma += pesi[domande[i] - 1][s];
  }
  return Math.round(somma * 100 / 30);
}

/** La figura della fascia del punteggio. */
export function figuraDi(tema: number, punteggio: number): string | null {
  const f = (FASCE_DELLE_PROVE[tema] ?? [])
    .find(([da, a]) => punteggio >= da && punteggio <= a);
  return f ? f[2] : null;
}

/**
 * **CHI SI AVVICINA DI PIU'.** Fra le stime sullo stesso punteggio vince la
 * distanza minima; a pari distanza vincono tutti.
 */
export function piuVicini(stime: {chi: string; valore: number}[],
  punteggio: number): string[] {
  if (stime.length === 0) return [];
  const min = Math.min(...stime.map((s) => Math.abs(s.valore - punteggio)));
  return stime.filter((s) => Math.abs(s.valore - punteggio) === min)
    .map((s) => s.chi);
}

/** I punti di chi si avvicina di piu' in una scommessa. */
export const PUNTI_DELLA_SCOMMESSA = 3;

// ---------------------------------------------------------------------------
// LE SFIDE
// ---------------------------------------------------------------------------

/** La sfida a due resta aperta ventiquattro ore. */
export const DURATA_DELLA_SFIDA_MS = 24 * 60 * 60 * 1000;

/**
 * **L'ESITO DI UNA SFIDA A DUE.** Si invita una persona sulla Prova della
 * settimana e ciascuno stima il punteggio dell'altro: vince chi si avvicina
 * di piu' (si sfida quello che le persone fanno, mai quello che sono). Se
 * l'invitato non gioca entro ventiquattro ore la sfida si chiude e il punto
 * va a chi ha giocato. Nullo se la sfida e' ancora aperta.
 */
export function esitoDellaSfida(s: {
  da: string; a: string; scade: number;
  punteggioDa?: number | null; punteggioA?: number | null;
  stimaDa?: number | null; stimaA?: number | null;
}, adesso: number): {vincitori: string[]; perche: "stime" | "tempo"} | null {
  const completa = s.punteggioA != null && s.stimaA != null &&
    s.punteggioDa != null && s.stimaDa != null;
  if (completa) {
    const errDa = Math.abs((s.stimaDa as number) - (s.punteggioA as number));
    const errA = Math.abs((s.stimaA as number) - (s.punteggioDa as number));
    const vincitori = errDa < errA ? [s.da] : errA < errDa ? [s.a] :
      [s.da, s.a];
    return {vincitori, perche: "stime"};
  }
  if (adesso >= s.scade) return {vincitori: [s.da], perche: "tempo"};
  return null;
}

/**
 * **LA LEGGE DELLE SFIDE**, voce FF.06.1: le classifiche si fanno solo su
 * gesti compiuti e indovinelli azzeccati. Questo e' l'elenco chiuso dei
 * campi su cui una classifica puo' ordinare; la guardia
 * `le_sfide_non_giudicano_le_persone` pretende che nessun altro ci entri.
 */
export const CAMPI_DELLE_CLASSIFICHE = ["indovinati", "passi"] as const;

/** La classifica del Cerchio: chi conosce di piu' le sue persone. */
export function laClassifica<T extends {uid: string; indovinati: number}>(
  persone: T[]): T[] {
  return [...persone].sort((a, b) =>
    b.indovinati - a.indovinati || a.uid.localeCompare(b.uid));
}

// ---------------------------------------------------------------------------
// IL PELLEGRINAGGIO
// ---------------------------------------------------------------------------

/**
 * **LA META DEL PELLEGRINAGGIO**: un passo per persona al giorno, nella
 * settimana che porta alla luna piena, e una meta che nessuno raggiunge da
 * solo: da solo si fanno al massimo sette passi, la meta e' almeno quindici
 * e cresce di quattro per ogni persona del Cerchio.
 */
export function metaDelPellegrinaggio(persone: number): number {
  return Math.max(15, 4 * Math.max(1, persone));
}

/**
 * La luna piena che il telefono dichiara, dalla porta unica del cielo: il
 * server non ha un secondo motore del cielo, controlla solo che la data
 * cada nella settimana che comincia oggi.
 */
export function lunaValida(valore: unknown, oggi: string): string | null {
  const s = String(valore ?? "");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) return null;
  const giorni = (Date.parse(`${s}T00:00:00Z`) -
    Date.parse(`${oggi}T00:00:00Z`)) / 864e5;
  return giorni >= 0 && giorni < 7 ? s : null;
}
