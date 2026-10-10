import {readFileSync} from "node:fs";
import {join} from "node:path";

/**
 * IL NOME NEL CERCHIO, ordine EY voce 01. La parte senza database.
 *
 * **Il nome visibile NON e' unico**: due persone possono chiamarsi uguale. Cio'
 * che e' unico e' il sigillo, quattro caratteri che assegna il server e che non
 * cambia mai (`sociale.ts`). Qui vivono le tre domande che si fanno a un nome
 * prima di accettarlo: ha la forma giusta, e' un nome del Cerchio, e' un
 * insulto.
 *
 * **Le regole stanno nel dato**, `il_nome_del_cerchio.json`, e non in questo
 * file: il telefono ne porta una copia per rispondere mentre si scrive, e una
 * prova pretende che le due copie siano uguali. Il server resta sovrano: il
 * telefono propone, `scegliIlNome` decide.
 */
interface RegoleDelNome {
  lunghezzaMinima: number;
  lunghezzaMassima: number;
  riservati: string[];
  riservatiInTestaOInCoda: string[];
  offensiveContenute: string[];
  offensiveParola: string[];
  confondibili: Record<string, string>;
  cifreComeLettere: Record<string, string>;
  unoAncheComeElle: boolean;
}

export const REGOLE_DEL_NOME: RegoleDelNome = JSON.parse(
  readFileSync(join(__dirname, "..", "src", "il_nome_del_cerchio.json"), "utf8")
) as RegoleDelNome;

/**
 * LA FORMA AMMESSA: lettere latine (anche accentate), cifre, spazio, punto e
 * underscore. Tutto il resto cade qui, compresi i caratteri invisibili (lo
 * spazio di larghezza zero, il separatore che non si vede, l'a capo) e le
 * lettere di altri alfabeti.
 */
const CARATTERI_AMMESSI = /^[A-Za-z0-9 ._À-ÖØ-öø-ÿ]+$/u;

export type PercheNo =
  | "corto"
  | "lungo"
  | "caratteri"
  | "spazi"
  | "riservato"
  | "offensivo";

export interface VerdettoDelNome {
  ok: boolean;
  perche: PercheNo | null;
  /** Il nome come si scrive davvero, senza spazi ai bordi. */
  nome: string;
}

/**
 * LA FORMA DI CONFRONTO. Minuscole, accenti tolti, i caratteri di altri
 * alfabeti che si scrivono come i latini riportati al latino, le cifre che
 * fanno le lettere riportate a lettere, punteggiatura e spazi tolti.
 *
 * **Perche' serve.** Un nome con la "e" cirillica e' un altro nome per il
 * computer e lo stesso per l'occhio; "M3dora" e "medora." sono Medora per
 * chiunque li legga. La forma di confronto serve ai nomi riservati e alle
 * parole offensive, NON all'unicita': il nome non e' unico.
 *
 * Restituisce le forme possibili, e basta che una cada: la cifra 1 si legge
 * sia "i" sia "l" ("ca1igo" da' "caiigo" e "caligo"), e le cifre si leggono
 * anche come se non ci fossero ("Aura77" e' Aura, non "auratt").
 */
export function formeDiConfronto(nome: string): string[] {
  const forme = [riduci(nome, "i")];
  if (REGOLE_DEL_NOME.unoAncheComeElle && nome.includes("1")) {
    forme.push(riduci(nome, "l"));
  }
  forme.push(riduci(nome.replace(/[0-9]/g, ""), "i"));
  return [...new Set(forme)].filter((f) => f.length > 0);
}

function riduci(nome: string, uno: string): string {
  let fuori = "";
  for (const carattere of nome.toLowerCase()) {
    if (carattere === "1") {
      fuori += uno;
      continue;
    }
    const cifra = REGOLE_DEL_NOME.cifreComeLettere[carattere];
    if (cifra !== undefined) {
      fuori += cifra;
      continue;
    }
    const simile = REGOLE_DEL_NOME.confondibili[carattere];
    if (simile !== undefined) {
      fuori += simile;
      continue;
    }
    fuori += carattere;
  }
  // Gli accenti si tolgono scomponendo la lettera e buttando il segno.
  return fuori
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]/g, "");
}

/** Le parole del nome, ciascuna nella sua forma di confronto. */
function paroleDi(nome: string): string[][] {
  return nome
    .split(/[ ._]+/u)
    .filter((p) => p.length > 0)
    .map((p) => formeDiConfronto(p));
}

const RISERVATI = REGOLE_DEL_NOME.riservati.map((r) => riduci(r, "i"));
const IN_TESTA_O_IN_CODA =
  REGOLE_DEL_NOME.riservatiInTestaOInCoda.map((r) => riduci(r, "i"));

/**
 * E' UN NOME DEL CERCHIO? Cade se una forma del nome intero e' un nome
 * riservato, anche con le cifre ("Medora77"), se una sua parola lo e'
 * ("staff medora"), oppure se uno dei nomi propri del Cerchio
 * (`riservatiInTestaOInCoda`: Medora, Caligo, Esoteric, Circle) sta in testa
 * o in coda ("LaMedora"). Gli altri cadono solo interi: altrimenti Laura,
 * Leos e Stafford non potrebbero chiamarsi col loro nome.
 */
export function eRiservato(nome: string): boolean {
  for (const forma of formeDiConfronto(nome)) {
    if (RISERVATI.includes(forma)) return true;
    for (const r of IN_TESTA_O_IN_CODA) {
      if (forma.startsWith(r) || forma.endsWith(r)) return true;
    }
  }
  for (const parola of paroleDi(nome)) {
    for (const forma of parola) {
      if (RISERVATI.includes(forma)) return true;
    }
  }
  return false;
}

/**
 * E' UN INSULTO? Le radici lunghe cadono ovunque stiano dentro il nome; le
 * parole corte cadono solo quando sono una parola intera o il nome intero,
 * perche' "nazi" sta dentro Ignazio e "negro" dentro Montenegro.
 */
export function eOffensivo(nome: string): boolean {
  for (const forma of formeDiConfronto(nome)) {
    for (const radice of REGOLE_DEL_NOME.offensiveContenute) {
      if (forma.includes(radice)) return true;
    }
    if (REGOLE_DEL_NOME.offensiveParola.includes(forma)) return true;
  }
  for (const parola of paroleDi(nome)) {
    for (const forma of parola) {
      if (REGOLE_DEL_NOME.offensiveParola.includes(forma)) return true;
    }
  }
  return false;
}

/** IL VERDETTO su un nome proposto, nell'ordine in cui le domande contano. */
export function verdettoDelNome(proposto: unknown): VerdettoDelNome {
  const nome = String(proposto ?? "").trim();
  const lunghezza = [...nome].length;
  if (lunghezza < REGOLE_DEL_NOME.lunghezzaMinima) {
    return {ok: false, perche: "corto", nome};
  }
  if (lunghezza > REGOLE_DEL_NOME.lunghezzaMassima) {
    return {ok: false, perche: "lungo", nome};
  }
  if (!CARATTERI_AMMESSI.test(nome)) {
    return {ok: false, perche: "caratteri", nome};
  }
  if (nome.includes("  ")) return {ok: false, perche: "spazi", nome};
  if (eRiservato(nome)) return {ok: false, perche: "riservato", nome};
  if (eOffensivo(nome)) return {ok: false, perche: "offensivo", nome};
  return {ok: true, perche: null, nome};
}

/**
 * LA RIGA CHE LA PERSONA LEGGE quando il nome non passa. Una per motivo, e
 * quella del nome riservato dice di chi e' il nome, come chiede l'ordine.
 */
export const RIGHE_DEL_RIFIUTO: Record<PercheNo, string> = {
  corto: "Il nome vuole almeno tre caratteri.",
  lungo: "Il nome sta in venti caratteri al massimo.",
  caratteri: "Il nome si scrive con lettere, cifre, spazio, punto e trattino basso.",
  spazi: "Un solo spazio fra una parola e l’altra.",
  riservato: "Questo nome è del Cerchio: scegline un altro.",
  offensivo: "Questo nome non può stare nel Cerchio.",
};
