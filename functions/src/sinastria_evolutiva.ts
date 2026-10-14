/**
 * LA SINASTRIA EVOLUTIVA, IL CONTROLLO SUL SERVER. Ordine FT voce FT.04,
 * 14 ottobre 2026.
 *
 * **IL SERVER NON SI FIDA DELL'APP.** Il legame amore si apre solo se
 * entrambe le persone hanno almeno sedici anni compiuti al giorno della
 * lettura (il fondatore: "l'amore dai 16 anni in su"); gli altri tre legami
 * (amicizia, famiglia, lavoro) non hanno limite. Il controllo vive due
 * volte: qui, e in `lib/core/synastry_evolutiva/legame_e_eta.dart`
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

/**
 * IL CONSENSO DELLA NASCITA, LA LETTURA A DUE TELEFONI. Ordine FT voce
 * FT.03, 14 ottobre 2026.
 *
 * **LA FORMA DEL GESTO, scelta e motivata qui (R1 dell'ordine).** Non un QR
 * nuovo ne' un gesto di vicinanza nuovo: il progetto ha gia' un meccanismo
 * di codice opaco con due durate (`sociale.ts`, `unCodice`/`DURATE_DEL_
 * CODICE`, ordine EY voce 17), usato per gli inviti del Cerchio. La durata
 * "vicino" (sei caratteri, cinque minuti) e' gia' pensata per un gesto
 * fatto insieme, nella stessa stanza: e' esattamente la lettura a due
 * telefoni. Riusarla vuol dire lo stesso alfabeto senza lettere ambigue, la
 * stessa normalizzazione (`codiceScritto`), zero codice nuovo da fidarsi.
 *
 * **NON ENTRA MAI NEL PROFILO PUBBLICO.** Il consenso vive nella sua
 * collezione (`consensi_nascita/{codice}`, separata da `codici_invito`
 * perche' lo scopo e' diverso: un invito lega due account per sempre, un
 * consenso presta una nascita per una lettura sola), si consuma a una sola
 * lettura ([consumaConsenso] e' l'unico modo di leggerlo, e dopo il
 * documento non serve piu': lo cancella chi lo consuma, o un lavoro
 * programmato dopo la scadenza) e non scrive mai nulla nel profilo di chi
 * lo manda. Le due porte (`condividiLaNascita` e `leggiLaNascita`) stanno
 * in `il_cerchio_sociale.ts`, accanto a quelle del codice d'invito, scritte
 * e non pubblicate: la pubblicazione la decide il fondatore (R3). Qui c'e'
 * la logica pura, provata senza database.
 */
export const DURATA_DEL_CONSENSO_MS = 5 * 60 * 1000;

export interface NascitaCondivisa {
  /** ISO 8601, UTC. */
  nascita: string;
  /**
   * Il giorno di nascita nel calendario del luogo, AAAA-MM-GG: al confine
   * dei sedici anni conta questo, non il giorno in tempo universale.
   */
  giorno: string;
  /** Falso se l'ora non e' nota: la lettura ancora a mezzogiorno. */
  oraNota: boolean;
  nome: string;
}

const GIORNO = /^(\d{4})-(\d{2})-(\d{2})$/;

/** Il giorno AAAA-MM-GG come data a mezzanotte UTC, oppure null. */
export function giornoDa(valore: unknown): Date | null {
  if (typeof valore !== "string") return null;
  const m = GIORNO.exec(valore);
  if (m === null) return null;
  const d = new Date(Date.UTC(Number(m[1]), Number(m[2]) - 1, Number(m[3])));
  // Il 31 febbraio non esiste: Date lo sposterebbe a marzo senza dirlo.
  if (d.getUTCMonth() !== Number(m[2]) - 1 || d.getUTCDate() !== Number(m[3])) {
    return null;
  }
  return d;
}

/**
 * LA NASCITA CHE ARRIVA DAL TELEFONO, controllata campo per campo. Ogni
 * campo storto o mancante rende null: il consenso non nasce a meta'.
 */
export function nascitaDaCorpo(corpo: unknown, adesso: Date): NascitaCondivisa | null {
  if (typeof corpo !== "object" || corpo === null) return null;
  const c = corpo as Record<string, unknown>;
  if (typeof c.nascita !== "string" || typeof c.oraNota !== "boolean") return null;
  const istante = new Date(c.nascita);
  if (isNaN(istante.getTime()) || istante.getTime() > adesso.getTime()) return null;
  if (istante.getUTCFullYear() < 1900) return null;
  const giorno = giornoDa(c.giorno);
  if (giorno === null || giorno.getTime() > adesso.getTime()) return null;
  // Il giorno del luogo e quello in tempo universale stanno a un giorno al
  // massimo: un fuso orario non sposta di piu'.
  if (Math.abs(giorno.getTime() - istante.getTime()) > 2 * 24 * 3600 * 1000) return null;
  const nome = typeof c.nome === "string" ? c.nome.trim() : "";
  if (nome.length === 0 || nome.length > 40) return null;
  return {nascita: istante.toISOString(), giorno: c.giorno as string, oraNota: c.oraNota, nome};
}

/**
 * LA LETTURA DEL CONSENSO, e il secondo controllo dell'eta' (FT.04). Chi
 * legge manda il proprio giorno di nascita (il server non lo conserva: il
 * Cerchio tiene solo il segno e la maggiore eta'); la nascita condivisa la
 * prende dal consenso, mai dal telefono che legge. Null se il codice non
 * vale piu', senza dire perche' (vedi [consumaConsenso]).
 */
export function esitoDellaLettura(
  consenso: ConsensoDellaNascita | null,
  giornoDiChiLegge: unknown,
  adesso: Date
): {
  esito: {nascita: NascitaCondivisa; amoreApribile: boolean} | null;
  consensoAggiornato: ConsensoDellaNascita | null;
} {
  const {datiLetti, consensoAggiornato} = consumaConsenso(consenso, adesso);
  if (datiLetti === null) return {esito: null, consensoAggiornato};
  const mio = giornoDa(giornoDiChiLegge);
  const suo = giornoDa(datiLetti.giorno);
  // Senza un giorno valido di chi legge l'amore resta chiuso: nel dubbio il
  // server non apre.
  const amoreApribile = mio !== null && suo !== null &&
    legameApribile("amore", mio, suo, adesso);
  return {esito: {nascita: datiLetti, amoreApribile}, consensoAggiornato};
}

export interface ConsensoDellaNascita {
  codice: string;
  dati: NascitaCondivisa;
  creato: Date;
  scadenza: Date;
  consumato: boolean;
}

/**
 * Crea un nuovo consenso, pronto per essere scritto in
 * `consensi_nascita/{codice}`. Il codice e' quello "vicino" (sei caratteri,
 * cinque minuti): chi lo riceve ha pochi minuti per usarlo, come un codice
 * mostrato e letto nella stessa stanza.
 */
export function creaConsenso(
  dati: NascitaCondivisa,
  adesso: Date,
  codice: string
): ConsensoDellaNascita {
  return {
    codice,
    dati,
    creato: adesso,
    scadenza: new Date(adesso.getTime() + DURATA_DEL_CONSENSO_MS),
    consumato: false,
  };
}

/**
 * Prova a consumare il consenso: restituisce i dati UNA SOLA VOLTA. Scaduto
 * o gia' consumato, restituisce null senza dire quale dei due (chi chiede
 * non deve poter distinguere "scaduto" da "mai esistito" o "gia' usato da
 * un altro": l'informazione in piu' non serve a nessuno, tranne a chi
 * indovina codici).
 */
export function consumaConsenso(
  consenso: ConsensoDellaNascita | null,
  adesso: Date
): {datiLetti: NascitaCondivisa | null; consensoAggiornato: ConsensoDellaNascita | null} {
  if (consenso === null) return {datiLetti: null, consensoAggiornato: null};
  const scaduto = adesso.getTime() > consenso.scadenza.getTime();
  if (consenso.consumato || scaduto) {
    return {datiLetti: null, consensoAggiornato: consenso};
  }
  return {
    datiLetti: consenso.dati,
    consensoAggiornato: {...consenso, consumato: true},
  };
}
