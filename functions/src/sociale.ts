import {createHash, randomInt} from "node:crypto";
import {Piano} from "./budget";

/**
 * IL MOTORE SOCIALE DEL CERCHIO, ordine EY. La parte senza database: numeri,
 * decisioni e forme. Le porte che scrivono stanno in `il_cerchio_sociale.ts`
 * e si limitano a leggere, chiedere a queste funzioni e scrivere l'esito.
 *
 * **Tutto qui e' deterministico** e nessuna riga chiama un modello (regola R11
 * dell'ordine): il motore sociale decide con regole scritte.
 *
 * **Nessun cancello sociale** (legge L1): nessuna funzione dell'app si apre
 * invitando qualcuno. L'invito si premia, mai si impone.
 */

// ---------------------------------------------------------------------------
// IL SIGILLO, EY.01 punto 4
// ---------------------------------------------------------------------------

/**
 * L'ALFABETO DEL SIGILLO: trentadue simboli che non si confondono all'occhio.
 * Mancano la I e la L (che si scambiano con l'uno), la O (che si scambia con
 * lo zero) e la U (che si scambia con la V). E' l'alfabeto di Crockford.
 */
export const ALFABETO_DEL_SIGILLO = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
export const LUNGHEZZA_DEL_SIGILLO = 4;

/**
 * Un sigillo candidato. Lo sceglie il caso e non una formula sull'uid: un
 * sigillo calcolato dall'uid sarebbe un pezzo dell'uid a vista. L'unicita' la
 * garantisce la transazione che lo scrive in `sigilli/{sigillo}`, mai il
 * telefono.
 */
export function unSigillo(caso: (n: number) => number = randomInt): string {
  let fuori = "";
  for (let i = 0; i < LUNGHEZZA_DEL_SIGILLO; i++) {
    fuori += ALFABETO_DEL_SIGILLO[caso(ALFABETO_DEL_SIGILLO.length)];
  }
  return fuori;
}

export function eUnSigillo(valore: unknown): valore is string {
  if (typeof valore !== "string") return false;
  if (valore.length !== LUNGHEZZA_DEL_SIGILLO) return false;
  return [...valore].every((c) => ALFABETO_DEL_SIGILLO.includes(c));
}

/**
 * Il sigillo scritto da una persona: maiuscole, e le lettere che l'alfabeto
 * non ha lette come quelle che ha (O come zero, I e L come uno, U come V).
 * Chi copia un sigillo a mano non deve sbagliarlo per una lettera storta.
 */
export function sigilloScritto(valore: unknown): string | null {
  const pulito = String(valore ?? "")
    .toUpperCase()
    .replace(/[\s#·-]/g, "")
    .replace(/O/g, "0")
    .replace(/[IL]/g, "1")
    .replace(/U/g, "V");
  return eUnSigillo(pulito) ? pulito : null;
}

// ---------------------------------------------------------------------------
// IL CAMBIO DEL NOME, EY.01 punto 8
// ---------------------------------------------------------------------------

const GIORNO_MS = 24 * 60 * 60 * 1000;

/**
 * **LA CADENZA DEL NOME: libero la prima volta, poi una volta ogni trenta
 * giorni.** Il blocco agisce sull'identificativo e non sul nome, quindi
 * cambiare nome non evade un blocco; e un nome che cambia ogni giorno rende
 * le persone irriconoscibili a chi le ha accanto.
 */
export const GIORNI_FRA_DUE_CAMBI = 30;

/**
 * **IL NOME LASCIATO RESTA DI CHI LO LASCIA per novanta giorni**: nessun altro
 * lo prende, cosi' chi ti conosceva con quel nome non trova un altro al tuo
 * posto il giorno dopo.
 */
export const GIORNI_DEL_NOME_LASCIATO = 90;

/** Il sigillo di un account cancellato resta fermo novanta giorni. */
export const GIORNI_DEL_SIGILLO_IN_QUARANTENA = 90;

/**
 * Quando si riapre il cambio del nome. `cambiFatti` conta i cambi DOPO il
 * primo nome: il primo nome scelto non e' un cambio, e il primo cambio e'
 * libero. Restituisce null se si puo' cambiare adesso.
 */
export function quandoSiRiapreIlNome(
  cambiFatti: number,
  ultimoCambioMs: number | null,
  adessoMs: number
): number | null {
  if (cambiFatti < 1 || ultimoCambioMs === null) return null;
  const riapre = ultimoCambioMs + GIORNI_FRA_DUE_CAMBI * GIORNO_MS;
  return adessoMs >= riapre ? null : riapre;
}

export function scadenzaDelNomeLasciato(adessoMs: number): number {
  return adessoMs + GIORNI_DEL_NOME_LASCIATO * GIORNO_MS;
}

export function fineDellaQuarantena(adessoMs: number): number {
  return adessoMs + GIORNI_DEL_SIGILLO_IN_QUARANTENA * GIORNO_MS;
}

// ---------------------------------------------------------------------------
// IL PROFILO PUBBLICO, EY.02
// ---------------------------------------------------------------------------

export const SEGNI = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
] as const;
export const MAESTRI = ["medora", "aura", "caligo"] as const;
export const FAMIGLIE_DELLE_ICONE =
  ["segno", "animale", "archetipo"] as const;

/**
 * **L'ICONA DEL PROFILO si sceglie fra tre set disegnati**, mai una foto. La
 * forma e' `famiglia:indice`: dodici segni, dodici animali, dodici
 * archetipi. **Gli Arcani sono usciti dalle icone** con l'ordine FA voce 01
 * (4 ottobre 2026): una carta intera dentro il tondo non si riconosce. Un
 * codice `arcano:N` non e' piu' valido e ricade sul segno della persona
 * (`iconaDelSegno`).
 */
export const QUANTE_ICONE: Record<string, number> = {
  segno: 12,
  animale: 12,
  archetipo: 12,
};

/**
 * IL RIPIEGO DELL'ICONA E' IL SEGNO DELLA PERSONA, ordine FA voce 01: un
 * codice che non vale piu' diventa l'emblema del suo segno solare, e solo se
 * il segno non si conosce il primo della lista. Lo stesso del telefono
 * (`IconaDelProfilo.valida`).
 */
export function iconaDelSegno(segno: unknown): string {
  const i = (SEGNI as readonly string[]).indexOf(String(segno));
  return `segno:${i < 0 ? 0 : i}`;
}

export function iconaValida(valore: unknown): string | null {
  const testo = String(valore ?? "");
  const [famiglia, indice] = testo.split(":");
  const quante = QUANTE_ICONE[famiglia];
  if (quante === undefined) return null;
  const n = Number(indice);
  if (!Number.isInteger(n) || n < 0 || n >= quante) return null;
  return `${famiglia}:${n}`;
}

export function segnoValido(valore: unknown): string | null {
  return (SEGNI as readonly string[]).includes(String(valore)) ?
    String(valore) :
    null;
}

export function maestroValido(valore: unknown): string | null {
  return (MAESTRI as readonly string[]).includes(String(valore)) ?
    String(valore) :
    null;
}

export function gradinoValido(valore: unknown): number | null {
  const n = Number(valore);
  return Number.isInteger(n) && n >= 0 && n <= 1000 ? n : null;
}

/**
 * IL PROFILO PUBBLICO, e cio' che NON contiene mai.
 *
 * Dentro: lo pseudonimo, il sigillo, l'icona scelta, il segno solare, il
 * gradino del Cammino, il Maestro di riferimento, l'istante dell'ultima
 * presenza. Nient'altro.
 *
 * **Fuori, sempre, nemmeno abbreviati**: il nome proprio, la data, l'ora e il
 * luogo di nascita, l'email, la foto, la posizione. Il segno arriva come
 * SEGNO, mai come data: dal segno non si risale al giorno.
 */
export interface ProfiloPubblico {
  nome: string;
  sigillo: string;
  icona: string;
  segno: string | null;
  gradino: number;
  maestro: string | null;
  ultimaPresenza: number | null;
}

/** I soli campi che il profilo pubblico puo' portare, e una prova li conta. */
export const CAMPI_DEL_PROFILO_PUBBLICO = [
  "nome",
  "sigillo",
  "icona",
  "segno",
  "gradino",
  "maestro",
  "ultimaPresenza",
] as const;

/** Toglie da un documento tutto cio' che il profilo pubblico non porta. */
export function soloIlPubblico(dati: Record<string, unknown>): ProfiloPubblico {
  return {
    nome: String(dati.nome ?? ""),
    sigillo: String(dati.sigillo ?? ""),
    icona: iconaValida(dati.icona) ?? iconaDelSegno(dati.segno),
    segno: segnoValido(dati.segno),
    gradino: gradinoValido(dati.gradino) ?? 0,
    maestro: maestroValido(dati.maestro),
    ultimaPresenza: typeof dati.ultimaPresenza === "number" ?
      dati.ultimaPresenza :
      null,
  };
}

// ---------------------------------------------------------------------------
// IL LEGAME, EY.04, EY.05, EY.07
// ---------------------------------------------------------------------------

/** L'identificativo della coppia: lo stesso da entrambi i lati. */
export function coppia(a: string, b: string): string {
  return a < b ? `${a}__${b}` : `${b}__${a}`;
}

/**
 * I POSTI DEL LEGAME FRA ACCOUNT, per piano. E' cosa diversa dagli amici
 * offline. Il numero lo promette la matrice dei piani del telefono
 * (`RigaDelPiano.legami`) e una prova pretende che questi siano gli stessi.
 *
 * **NESSUN SENZA LIMITE, nemmeno all'Illuminato.** L'illimitato e' stato
 * eliminato ovunque per decisione del fondatore del 29 agosto 2026, e qui
 * l'abuso sarebbe raccogliere migliaia di persone.
 */
export const POSTI_DEL_LEGAME: Record<Piano, number> = {
  free: 3,
  tier1: 15,
  tier2: 50,
  tier3: 150,
};

/** Il prezzo del posto in piu': la voce `amicoInPiu` del listino, 100 Eos. */
export const EOS_DEL_POSTO_IN_PIU = 100;

/** Al massimo venti inviti mandati al giorno per identita'. */
export const INVITI_AL_GIORNO = 20;

/**
 * **IL RIFIUTO NON E' UN BLOCCO**: non dice niente a chi ha invitato, e
 * impedisce un secondo invito dalla stessa persona per trenta giorni.
 */
export const GIORNI_DOPO_UN_RIFIUTO = 30;

export type StatoDelLegame = "invito" | "amici" | "rifiutato";

/**
 * IL SEMAFORINO, come lo vede CHI GUARDA. Quattro stati e non cinque:
 * - spento: nessuna relazione;
 * - arancioneChiaro: l'ho invitato io e aspetto;
 * - arancionePieno: mi ha invitato lui, e il tocco apre accetta o rifiuta;
 * - verde: amici.
 *
 * **IL ROSSO NON ESISTE NEGLI ELENCHI.** Dire a una persona che e' stata
 * bloccata produce il ritorno con un altro account, e un account oggi costa
 * zero. Il rosso vive solo nell'elenco delle persone bloccate del profilo.
 */
export type Semaforo = "spento" | "arancioneChiaro" | "arancionePieno" | "verde";

export function semaforoPer(
  chiGuarda: string,
  legame: {stato: StatoDelLegame; da: string} | null
): Semaforo {
  if (legame === null) return "spento";
  if (legame.stato === "amici") return "verde";
  if (legame.stato === "invito") {
    return legame.da === chiGuarda ? "arancioneChiaro" : "arancionePieno";
  }
  // Un rifiuto, per chi ha invitato, resta un invito che aspetta: il rifiuto
  // non si annuncia.
  return legame.da === chiGuarda ? "arancioneChiaro" : "spento";
}

export type PercheNoAlLegame =
  | "teStesso"
  | "giaAmici"
  | "giaInvitato"
  | "aspettaRisposta"
  | "rifiutatoDiRecente"
  | "nonRaggiungibile"
  | "postiFiniti"
  | "invitiFiniti"
  | "soloColSigillo";

/**
 * LA DECISIONE SU UN INVITO AL LEGAME. Le difese, in ordine:
 * - chi ha bloccato o e' stato bloccato non e' raggiungibile, e la risposta
 *   non dice quale dei due (nonRaggiungibile vale anche per chi non esiste);
 * - mai due inviti alla stessa persona se il primo non ha avuto risposta;
 * - dopo un rifiuto, trenta giorni;
 * - chi ha scelto "solo chi ha il mio sigillo" non si invita da un elenco;
 * - venti inviti al giorno;
 * - i posti del piano, contati su chi invita.
 */
export function decidiLInvito(args: {
  da: string;
  a: string;
  bloccati: boolean;
  legame: {stato: StatoDelLegame; da: string; fino?: number | null} | null;
  conIlSigillo: boolean;
  soloColSigillo: boolean;
  invitiOggi: number;
  amiciDiChiInvita: number;
  postiDiChiInvita: number;
  adessoMs: number;
}): {concesso: boolean; perche: PercheNoAlLegame | null} {
  const no = (perche: PercheNoAlLegame) => ({concesso: false, perche});
  if (args.da === args.a) return no("teStesso");
  if (args.bloccati) return no("nonRaggiungibile");
  const l = args.legame;
  if (l !== null) {
    if (l.stato === "amici") return no("giaAmici");
    if (l.stato === "invito") {
      return l.da === args.da ? no("aspettaRisposta") : no("giaInvitato");
    }
    if (l.stato === "rifiutato" && l.da === args.da &&
      typeof l.fino === "number" && args.adessoMs < l.fino) {
      return no("rifiutatoDiRecente");
    }
  }
  if (args.soloColSigillo && !args.conIlSigillo) return no("soloColSigillo");
  if (args.invitiOggi >= INVITI_AL_GIORNO) return no("invitiFiniti");
  if (args.amiciDiChiInvita >= args.postiDiChiInvita) return no("postiFiniti");
  return {concesso: true, perche: null};
}

export function fineDelRifiuto(adessoMs: number): number {
  return adessoMs + GIORNI_DOPO_UN_RIFIUTO * GIORNO_MS;
}

// ---------------------------------------------------------------------------
// IL CODICE DELL'INVITO, EY.17 ed EY.04 punto 3
// ---------------------------------------------------------------------------

/**
 * **UN MECCANISMO SOLO, DUE DURATE.** Il codice del link vale trenta giorni,
 * si rinnova e si revoca dal profilo; il codice da inquadrare quando i due
 * telefoni sono vicini vale cinque minuti. Tutti e due sono opachi: li genera
 * il server, li lega a chi invita, e il server e' il solo che sa tradurli in
 * uid, e li traduce solo al riscatto. Nel codice non ci va l'uid, non ci va
 * l'email, non ci vanno i dati di nascita: una fotografia del codice non vale
 * niente domani.
 */
export const DURATE_DEL_CODICE = {
  link: 30 * GIORNO_MS,
  vicino: 5 * 60 * 1000,
} as const;
export type TipoDelCodice = keyof typeof DURATE_DEL_CODICE;

/** Le lunghezze: il link ne porta otto, quello da inquadrare sei. */
export const LUNGHEZZE_DEL_CODICE: Record<TipoDelCodice, number> = {
  link: 8,
  vicino: 6,
};

export function unCodice(
  tipo: TipoDelCodice,
  caso: (n: number) => number = randomInt
): string {
  let fuori = "";
  for (let i = 0; i < LUNGHEZZE_DEL_CODICE[tipo]; i++) {
    fuori += ALFABETO_DEL_SIGILLO[caso(ALFABETO_DEL_SIGILLO.length)];
  }
  return fuori;
}

/** Il codice nella forma che il server conserva, oppure null. */
export function codiceScritto(valore: unknown): string | null {
  const pulito = String(valore ?? "")
    .toUpperCase()
    .replace(/[\s-]/g, "")
    .replace(/O/g, "0")
    .replace(/[IL]/g, "1")
    .replace(/U/g, "V");
  if (pulito.length !== LUNGHEZZE_DEL_CODICE.link &&
    pulito.length !== LUNGHEZZE_DEL_CODICE.vicino) {
    return null;
  }
  return [...pulito].every((c) => ALFABETO_DEL_SIGILLO.includes(c)) ?
    pulito :
    null;
}

/**
 * IL CODICE CHE ARRIVA AL RISCATTO, nelle due forme che girano.
 *
 * - **La forma nuova**, `CODICE` oppure `CODICE.maestro`: opaca, la traduce
 *   `codici_invito/{CODICE}`.
 * - **La forma vecchia**, `uid.maestro`, quella dei link gia' in giro prima
 *   dell'ordine EY. **E' UNA COMPATIBILITA' DICHIARATA**: si potra' togliere
 *   trenta giorni dopo la prima build che porta il codice nuovo (la 2296, se
 *   e' quella che lo consegna), cioe' quando l'ultimo link vecchio ha l'eta'
 *   del piu' vecchio dei codici nuovi. La data esatta si scrive qui il giorno
 *   della consegna, in `FINE_DELLA_COMPATIBILITA`.
 */
export const FINE_DELLA_COMPATIBILITA = "30 giorni dopo la consegna della build 2296";

export function leggiIlCodiceDellInvito(grezzo: string): {
  forma: "nuova" | "vecchia";
  codice: string;
  maestro: string | null;
} | null {
  const pulito = grezzo.trim();
  const punto = pulito.lastIndexOf(".");
  const corpo = punto > 0 ? pulito.slice(0, punto) : pulito;
  const porta = punto > 0 ? pulito.slice(punto + 1).toLowerCase() : "";
  const maestro = maestroValido(porta);
  const nuovo = codiceScritto(corpo);
  if (nuovo !== null) return {forma: "nuova", codice: nuovo, maestro};
  if (corpo.length >= 20 && corpo.length <= 200 &&
    /^[A-Za-z0-9]+$/.test(corpo)) {
    return {forma: "vecchia", codice: corpo, maestro};
  }
  return null;
}

// ---------------------------------------------------------------------------
// LA PRESENZA, EY.08 ed EY.09
// ---------------------------------------------------------------------------

/**
 * L'ARTE CHE UNA PERSONA STA USANDO, sempre come CATEGORIA di un elenco
 * chiuso e mai come testo libero. Nella tendina si legge in forma generica,
 * "ai tarocchi": mai il nome del responso, mai la domanda.
 */
export const ARTI_DELLA_PRESENZA = [
  "cerchio",
  "oroscopo",
  "tarocchi",
  "rune",
  "angeli",
  "archetipi",
  "viso",
  "meditazione",
  "viaggio",
  "sigilli",
  "maestri",
  "sinastria",
  "riti",
  "santuario",
] as const;
export type ArteDellaPresenza = typeof ARTI_DELLA_PRESENZA[number];

export function arteValida(valore: unknown): ArteDellaPresenza {
  return (ARTI_DELLA_PRESENZA as readonly string[]).includes(String(valore)) ?
    (String(valore) as ArteDellaPresenza) :
    "cerchio";
}

/**
 * **LA VISIBILITA'. Il valore predefinito, per tutti, e' "amici".** La
 * presenza pubblica si accende dal profilo con una scelta esplicita.
 * **L'invisibilita' e' gratuita per tutti i piani** e non compare in nessun
 * listino: la privacy non si vende.
 */
export const VISIBILITA = ["amici", "tutti", "invisibile"] as const;
export type Visibilita = typeof VISIBILITA[number];
export const VISIBILITA_PREDEFINITA: Visibilita = "amici";

export function visibilitaValida(valore: unknown): Visibilita | null {
  return (VISIBILITA as readonly string[]).includes(String(valore)) ?
    (String(valore) as Visibilita) :
    null;
}

/**
 * **I MINORENNI.** Per chi ha meno di diciotto anni la presenza pubblica non
 * si apre: resta visibile ai soli amici, e i gesti da chi non e' amico non
 * arrivano.
 *
 * Tutto il resto dell'app resta intero: un minorenne invita i suoi amici col
 * link o col codice, diventa loro amico, e fa con loro ogni confronto e ogni
 * compatibilita'. Questa regola non e' un divieto sulle arti.
 */
export function visibilitaEffettiva(
  scelta: Visibilita,
  maggiorenne: boolean
): Visibilita {
  if (scelta === "invisibile") return "invisibile";
  if (!maggiorenne) return "amici";
  return scelta;
}

/** Una presenza come la legge chi costruisce l'istantanea. */
export interface Presenza {
  uid: string;
  ultimo: number;
  arte: ArteDellaPresenza;
  visibilita: Visibilita;
  maggiorenne: boolean;
  nome: string | null;
  icona: string | null;
  segno: string | null;
  maestro: string | null;
  gradino: number;
  chiPuoInvitare: "tutti" | "sigillo";
  /**
   * Il sigillo viaggia con la presenza perche' la tendina lo mostri accanto
   * al nome quando due nomi coincidono (ordine FA voce 04); mai da solo.
   */
  sigillo: string | null;
}

/**
 * **L'ISTANTANEA DEL CERCHIO.** La lista dei presenti NON si calcola su
 * richiesta per ogni telefono: il server la tiene precalcolata, la rifa' al
 * massimo una volta ogni trenta secondi, e la serve a tutti dalla stessa
 * fonte. La presenza individuale resta quella di `presenza.ts`, col passo di
 * sessanta secondi e la finestra di novanta.
 */
export const OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS = 30 * 1000;

/**
 * **I FRAMMENTI DELLA PRESENZA, ordine FB voce 01.** La presenza non si scrive
 * piu' in un documento per persona: si scrive nella sua voce dentro uno di
 * `FRAMMENTI_DELLA_PRESENZA` documenti condivisi (`cerchio_presenze/{k}`),
 * scelto dall'identificativo. Il passo del telefono scrive una volta al
 * minuto come prima, ma nel frammento; e la ricostruzione dell'istantanea
 * legge i frammenti, non le persone: novantasei letture con mille presenti
 * come con centomila. Prima (ordine EZ) erano quattordici aggregazioni per
 * arte e una vetrina di ventiquattro, perche' leggere le persone costava
 * una lettura per persona; e gli amici presenti si leggevano a parte, una
 * lettura per amico (ordine FA, chiusa a sei).
 *
 * **Quanto regge un frammento.** Firestore regge circa una scrittura al
 * secondo per documento in modo continuo: con un passo al minuto, un
 * frammento regge sessanta persone presenti nello stesso momento, e
 * novantasei frammenti ne reggono 5.760, piu' del tetto dell'istantanea
 * (`PRESENZE_NELL_ISTANTANEA`). I due tetti stanno insieme, e la prova
 * `I FRAMMENTI REGGONO IL TETTO DELL'ISTANTANEA` cade se si separano: con
 * trentadue frammenti (la prima stesura di questa voce) il Cerchio ne
 * reggeva 1.920, e fra 1.920 e 5.000 presenti le scritture sarebbero andate
 * in contesa senza che nessun numero lo dicesse. Ogni frammento in piu'
 * costa una lettura per ricostruzione: novantasei frammenti, con qualcuno
 * presente a ogni ora del mese, costano circa 2,90 euro al mese (rapporto FB).
 */
export const FRAMMENTI_DELLA_PRESENZA = 96;

/** Le persone presenti che un frammento regge: un passo al minuto ciascuna. */
export const PRESENTI_PER_FRAMMENTO = 60;

export function frammentoDi(uid: string): number {
  return createHash("sha256").update(uid).digest()
    .readUInt32BE(0) % FRAMMENTI_DELLA_PRESENZA;
}

/**
 * LA SCHEDA COMPATTA di una persona presente, con chiavi di una lettera: e'
 * quella che sta nel frammento e nell'istantanea, e ogni byte conta perche'
 * un documento ha un tetto di un mebibyte. `u` e' l'ultimo passo, in
 * millisecondi.
 */
export interface SchedaCompatta {
  n?: string | null; // nome
  s?: string | null; // sigillo
  i?: string | null; // icona
  z?: string | null; // segno
  m?: string | null; // Maestro
  g?: number; // gradino
  a?: string; // arte di adesso
  v?: string; // visibilita'
  M?: boolean; // maggiorenne
  c?: string; // chi puo' invitare
  u?: number; // ultimo passo
}

export function compatta(p: Omit<Presenza, "uid" | "ultimo">): SchedaCompatta {
  return {n: p.nome, s: p.sigillo, i: p.icona, z: p.segno, m: p.maestro,
    g: p.gradino, a: p.arte, v: p.visibilita, M: p.maggiorenne,
    c: p.chiPuoInvitare};
}

/** Dalla scheda compatta alla presenza; nulla se manca il passo o il nome. */
export function scompatta(uid: string, c: SchedaCompatta | undefined):
  Presenza | null {
  if (!c || typeof c.u !== "number" || typeof c.v !== "string") return null;
  return {
    uid,
    ultimo: c.u,
    arte: arteValida(c.a),
    visibilita: visibilitaValida(c.v) ?? "amici",
    maggiorenne: c.M === true,
    nome: typeof c.n === "string" ? c.n : null,
    icona: iconaValida(c.i) ?? iconaDelSegno(c.z),
    segno: segnoValido(c.z),
    maestro: maestroValido(c.m),
    gradino: gradinoValido(c.g) ?? 0,
    chiPuoInvitare: c.c === "sigillo" ? "sigillo" : "tutti",
    sigillo: typeof c.s === "string" ? c.s : null,
  };
}

/**
 * **I BYTE, coi conti di Firestore**: una stringa vale i suoi byte UTF-8 piu'
 * uno, un numero otto, un booleano uno, un nulla uno, una mappa la somma dei
 * nomi dei campi (byte piu' uno) e dei valori. Una voce dell'istantanea e'
 * l'identificativo (nome del campo) e la sua scheda.
 */
function byteDi(valore: unknown): number {
  if (valore === null || valore === undefined) return 1;
  if (typeof valore === "string") return Buffer.byteLength(valore, "utf8") + 1;
  if (typeof valore === "number") return 8;
  if (typeof valore === "boolean") return 1;
  if (Array.isArray(valore)) return valore.reduce((n, v) => n + byteDi(v), 0);
  if (typeof valore === "object") {
    return Object.entries(valore as Record<string, unknown>).reduce(
      (n, [k, v]) => n + Buffer.byteLength(k, "utf8") + 1 + byteDi(v), 0);
  }
  return 8;
}

export function byteDiUnaVoce(uid: string, c: SchedaCompatta): number {
  return Buffer.byteLength(uid, "utf8") + 1 + byteDi(c);
}

export function byteDellIstantanea(ist: Istantanea): number {
  // Il nome del documento e i 32 byte che Firestore aggiunge a ogni documento.
  return Buffer.byteLength("cerchio_adesso/istantanea", "utf8") + 1 + 32 +
    byteDi(ist);
}

export const LIMITE_DI_UN_DOCUMENTO = 1_048_576;

/**
 * **QUANTI PRESENTI STANNO NELL'ISTANTANEA, misurati.** La voce piu' grande
 * possibile (identificativo di 28 caratteri, nome di 20 lettere accentate,
 * sigillo, l'icona e il segno piu' lunghi, l'arte piu' lunga) pesa 172 byte:
 * un mebibyte ne terrebbe 6.096. Il tetto dichiarato e' cinquemila, che
 * pieni di voci grandi occupano l'82 per cento del limite: la prova
 * `L'ISTANTANEA STA NEL SUO DOCUMENTO` misura l'istantanea piena e cade
 * sopra l'85 per cento, PRIMA del limite (basta un campo in piu' per voce). Oltre i
 * cinquemila presenti l'istantanea si tronca (e lo dice, `troncata`), e il
 * giorno che serviranno andra' spezzata come la presenza: in frammenti.
 */
export const PRESENZE_NELL_ISTANTANEA = 5000;

export interface Istantanea {
  quando: number;
  /** Tutti i presenti dentro la finestra, invisibili compresi. */
  totale: number;
  /** Le presenze aggregate per arte: chi e' invisibile non conta. */
  perArte: Record<string, number>;
  /**
   * I presenti non invisibili, con la loro scheda compatta. **Non esce mai
   * dal server**: la tendina ne restituisce solo gli amici di chi chiede.
   */
  presenti: Record<string, SchedaCompatta>;
  /** Chi e' presente ma invisibile: solo l'identificativo, per il conto. */
  nascosti: string[];
  troncata: boolean;
}

/**
 * Costruisce l'istantanea dai frammenti, e dice quali voci sono scadute da
 * piu' di un'ora (le toglie la ricostruzione, cosi' i frammenti non crescono)
 * e quali frammenti restano VUOTI (senza voci, oppure con le sole voci
 * scadute): la ricostruzione li cancella. Un frammento che non esiste e'
 * `undefined` nell'elenco.
 *
 * **PERCHE' I VUOTI SI CANCELLANO, ordine FB voce 01.** La ricostruzione legge
 * i frammenti che esistono, non tutti e novantasei: con una persona sola
 * presente legge il turno e un frammento. Nella prima stesura di questa voce
 * li leggeva sempre tutti, e con pochi presenti costava piu' dell'ordine FA:
 * 2,90 euro al mese contro 0,51 con una persona presente tutto il mese, 6,81
 * contro 6,50 con cento (`docs/collaudo/FB/i_costi_in_euro.txt`). R14 vuole
 * che nessuna voce aumenti il costo, a nessuna scala.
 */
export function costruisciLIstantanea(args: {
  frammenti: (Record<string, SchedaCompatta> | undefined)[];
  adessoMs: number;
  confineMs: number;
}): {
  istantanea: Istantanea;
  scadute: {frammento: number; uid: string}[];
  vuoti: number[];
} {
  const perArte: Record<string, number> = {};
  const presenti: Record<string, SchedaCompatta> = {};
  const nascosti: string[] = [];
  const scadute: {frammento: number; uid: string}[] = [];
  let totale = 0;
  let quanti = 0;
  let troncata = false;
  const vuoti: number[] = [];
  args.frammenti.forEach((voci, frammento) => {
    if (voci === undefined) return;
    const tutte = Object.keys(voci).length;
    let viaDaQui = 0;
    for (const [uid, c] of Object.entries(voci)) {
      const u = typeof c?.u === "number" ? c.u : null;
      if (u === null || u < args.confineMs) {
        if (u === null || u < args.adessoMs - 60 * 60 * 1000) {
          scadute.push({frammento, uid});
          viaDaQui++;
        }
        continue;
      }
      if (typeof c.v !== "string") continue;
      totale++;
      if (c.v === "invisibile") {
        nascosti.push(uid);
        continue;
      }
      const arte = arteValida(c.a);
      perArte[arte] = (perArte[arte] ?? 0) + 1;
      if (quanti >= PRESENZE_NELL_ISTANTANEA) {
        troncata = true;
        continue;
      }
      presenti[uid] = c;
      quanti++;
    }
    if (viaDaQui === tutte) vuoti.push(frammento);
  });
  return {
    istantanea: {quando: args.adessoMs, totale, perArte, presenti, nascosti,
      troncata},
    scadute,
    vuoti,
  };
}

/** I presenti dell'istantanea, come presenze. */
export function presentiDi(ist: Istantanea): Presenza[] {
  return Object.entries(ist.presenti ?? {}).flatMap(([uid, c]) => {
    const p = scompatta(uid, c);
    return p ? [p] : [];
  });
}

/**
 * **IL CERCHIO SOCIALE SI APRE A QUATTORDICI ANNI, ordine EZ voce 04.** In
 * Italia chi ha compiuto quattordici anni presta da se' il consenso per i
 * servizi della societa' dell'informazione; sotto, lo presta chi esercita la
 * responsabilita' genitoriale. Il fondatore il 4 ottobre 2026 ha approvato la
 * scelta dell'Architetto: nessun meccanismo di consenso genitoriale, che
 * sarebbe pesante, aggirabile da chiunque, e sposterebbe sull'app una
 * responsabilita' che non sa verificare. Sotto i quattordici anni le funzioni
 * SOCIALI non si aprono: nessun profilo pubblico, nessuna presenza, nessun
 * legame, nessun segno, nessun dono, nessun confronto con un'altra persona.
 *
 * **TUTTO IL RESTO DELL'APP RESTA INTERO.** Nessuna arte si chiude, nessun
 * responso si tocca, nessun limite cambia: questa regola vale soltanto per le
 * porte del Cerchio sociale, e non e' un divieto sulle arti.
 *
 * L'eta' la ricava il telefono dalla data di nascita che il profilo ha gia',
 * senza chiedere niente e senza documenti, e la dichiara alla porta del
 * profilo, l'unica che resta aperta perche' e' quella che la riceve. Nessuna
 * etichetta dice a nessuno che una persona e' minorenne: chi e' sotto i
 * quattordici semplicemente non compare e non riceve.
 */
export const ETA_DEL_CERCHIO = 14;
export const RIGA_DEI_QUATTORDICI = "Il Cerchio si apre a quattordici anni";
export const PORTA_CHE_RICEVE_L_ETA = "ilMioProfiloNelCerchio";

/** Se una porta sociale risponde a chi chiama. */
export function sogliaDellEtaPassata(porta: string, quattordici: unknown): boolean {
  return porta === PORTA_CHE_RICEVE_L_ETA || quattordici === true;
}

/**
 * I quattordici anni dichiarati dal telefono. Un telefono di prima
 * dell'ordine EZ dice solo se e' maggiorenne: chi lo e' ha certo quattordici
 * anni, chi non lo e' resta fuori finche' il telefono nuovo non lo dice.
 */
export function quattordiciDichiarati(corpo: {
  quattordici?: unknown;
  maggiorenne?: unknown;
}): boolean {
  if (typeof corpo.quattordici === "boolean") return corpo.quattordici;
  return corpo.maggiorenne === true;
}

export function istantaneaVecchia(
  quando: number | null,
  adessoMs: number
): boolean {
  return quando === null || adessoMs - quando >= OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS;
}

/** Perche' una persona somiglia a chi guarda: il criterio si dichiara. */
export type CriterioDiSomiglianza =
  | "stessoSegno"
  | "stessoMaestro"
  | "stessoGradino"
  | "affinitaAlta";

export const SOMIGLIANTI_AL_MASSIMO = 12;

/**
 * LE PERSONE PRESENTI CHE SOMIGLIANO A CHI GUARDA. Al massimo dodici,
 * mescolate in modo deterministico sul giorno e sull'identita' di chi guarda:
 * non e' una classifica e non cambia a ogni sguardo.
 *
 * Entrano solo le persone visibili a tutti e maggiorenni, mai chi e' amico
 * (quelli stanno nel primo piano), mai chi e' bloccato in un verso o
 * nell'altro. **Non esiste una via per scorrere tutti i presenti.**
 */
export function somiglianti(args: {
  istantanea: Istantanea;
  chiGuarda: string;
  giorno: string;
  mioSegno: string | null;
  mioMaestro: string | null;
  mioGradino: number;
  esclusi: Set<string>;
  affinitaAlta: (segnoA: string, segnoB: string) => boolean;
}): {persona: Presenza; criterio: CriterioDiSomiglianza}[] {
  const fuori: {persona: Presenza; criterio: CriterioDiSomiglianza}[] = [];
  for (const p of presentiDi(args.istantanea)) {
    if (p.uid === args.chiGuarda || args.esclusi.has(p.uid)) continue;
    if (p.visibilita !== "tutti" || !p.maggiorenne) continue;
    let criterio: CriterioDiSomiglianza | null = null;
    if (args.mioSegno !== null && p.segno === args.mioSegno) {
      criterio = "stessoSegno";
    } else if (args.mioMaestro !== null && p.maestro === args.mioMaestro) {
      criterio = "stessoMaestro";
    } else if (p.gradino === args.mioGradino) {
      criterio = "stessoGradino";
    } else if (args.mioSegno !== null && p.segno !== null &&
      args.affinitaAlta(args.mioSegno, p.segno)) {
      criterio = "affinitaAlta";
    }
    if (criterio !== null) fuori.push({persona: p, criterio});
  }
  const peso = (uid: string) =>
    createHash("sha256")
      .update(`${args.giorno}|${args.chiGuarda}|${uid}`)
      .digest()
      .readUInt32BE(0);
  fuori.sort((x, y) => peso(x.persona.uid) - peso(y.persona.uid));
  return fuori.slice(0, SOMIGLIANTI_AL_MASSIMO);
}

/**
 * LE LETTURE DI FIRESTORE, ordine EZ voce 03: la misura prima e dopo, col
 * metodo scritto. Una lettura e' quella che Firestore fattura: un documento
 * letto, oppure un'aggregazione ogni mille voci d'indice, oppure una domanda
 * che non trova niente (che costa comunque una lettura).
 *
 * **UN'APERTURA DELLA TENDINA** legge, in tutte e due le vie, il tetto della
 * porta (EY.16, una lettura in transazione), la propria identita', i propri
 * legami e i propri blocchi: quattro letture fisse.
 * - **Prima** leggeva anche l'istantanea, e se l'istantanea aveva piu' di
 *   trenta secondi la RICOSTRUIVA leggendo una presenza per persona: mille
 *   letture e una con mille presenti, pagate da chi apriva per primo.
 * - **Dopo** l'istantanea si tiene anche in memoria per trenta secondi (una
 *   lettura per istanza del server, non per apertura), la ricostruzione
 *   costa un'aggregazione per arte (quattordici) piu' la vetrina (al massimo
 *   ventiquattro), e gli amici presenti si leggono con una domanda mirata:
 *   una lettura per ogni gruppo di trenta amici, oppure una per ogni amico
 *   presente se sono di piu'.
 *
 * **IL PASSO DELLA PRESENZA**, ogni sessanta secondi, fuori dalla tendina:
 * prima leggeva l'identita' e contava i presenti (due letture), dopo legge
 * l'identita' solo al primo passo dopo l'avvio (una lettura al minuto).
 *
 * **La quota della ricostruzione** si divide fra i telefoni che chiedono nello
 * stesso mezzo minuto: chi apre per primo la paga, gli altri la trovano.
 */
export const LETTURE_FISSE_DI_UN_APERTURA = 4;

/**
 * **TUTTI GLI AMICI NELLA TENDINA, ordine FB voce 01.** Il tetto dei sei amici
 * dell'ordine FA e' tolto: gli amici presenti il server li trova INCROCIANDO
 * IN MEMORIA l'istantanea con i legami di chi chiede, che legge gia'. Un
 * amico presente costa zero letture, sei come centocinquanta. La soglia
 * dell'Architetto resta dieci letture per apertura, e adesso vale davvero per
 * qualunque numero di amici: le letture di un'apertura sono le quattro fisse.
 * La ricostruzione dell'istantanea non conta: una sola ogni trenta secondi
 * per tutto il Cerchio, condivisa.
 */
export const SOGLIA_DELLE_LETTURE_PER_APERTURA = 10;

/** Gli amici presenti costano zero letture: si incrociano in memoria. */
export function lettureDegliAmici(_amici: number, _amiciPresenti: number): number {
  return 0;
}

/**
 * Le letture di una ricostruzione: prima (ordine EZ) una per persona; poi
 * (ordine EZ voce 03) quattordici aggregazioni e la vetrina; adesso (ordine
 * FB) il turno della ricostruzione e i frammenti che esistono: al piu' uno
 * per presente e al piu' novantasei, qualunque sia il numero dei presenti
 * (una domanda che non trova niente costa comunque una lettura).
 */
export function lettureDellaRicostruzione(presenti: number): {
  prima: number;
  dopo: number;
} {
  return {
    prima: presenti + 1,
    dopo: 1 + Math.max(1, Math.min(FRAMMENTI_DELLA_PRESENZA, presenti)),
  };
}

export function lettureAllOra(args: {
  presenti: number;
  aperturePerOra: number;
  telefoniCheChiedono: number;
  amici: number;
  amiciPresenti: number;
}): {
  prima: number;
  dopo: number;
  unAperturaPrima: number;
  unAperturaDopo: number;
  passoPrima: number;
  passoDopo: number;
  viaIngenua: number;
} {
  const ricostruzioniAllOra = 3600 / (OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS / 1000);
  const quota =
    Math.min(args.aperturePerOra, ricostruzioniAllOra) /
    Math.max(1, args.telefoniCheChiedono);
  const ricostruzione = lettureDellaRicostruzione(args.presenti);
  const unAperturaPrima = LETTURE_FISSE_DI_UN_APERTURA + 1;
  const unAperturaDopo =
    LETTURE_FISSE_DI_UN_APERTURA + lettureDegliAmici(args.amici, args.amiciPresenti);
  // L'istantanea l'apertura la rilegge al massimo (una per istanza ogni
  // trenta secondi) e non la ricostruisce mai: la ricostruzione la fa il
  // passo della presenza (ordine FB voce 01).
  const conteggioDelPasso = Math.max(1, Math.ceil(args.presenti / 1000));
  return {
    prima: Math.round(args.aperturePerOra * unAperturaPrima + quota * ricostruzione.prima),
    dopo: Math.round(args.aperturePerOra * unAperturaDopo +
      quota * (1 + ricostruzione.dopo)),
    unAperturaPrima: unAperturaPrima + ricostruzione.prima,
    unAperturaDopo: unAperturaDopo + 1,
    passoPrima: 60 * (1 + conteggioDelPasso),
    // Il primo passo legge l'identita'; il numero dei presenti viene
    // dall'istantanea in memoria (ordine FB), non da un'aggregazione.
    passoDopo: 1 + 0 * conteggioDelPasso,
    viaIngenua: args.aperturePerOra * args.presenti * 2,
  };
}

// ---------------------------------------------------------------------------
// I SEGNI E LE REAZIONI, EY.10 ed EY.11
// ---------------------------------------------------------------------------

/** I segni al giorno per piano: il numero lo promette la matrice dei piani. */
export const SEGNI_AL_GIORNO: Record<Piano, number> = {
  free: 5,
  tier1: 20,
  tier2: 40,
  tier3: 60,
};

/**
 * **DUE TETTI CHE NON DIPENDONO DAL PIANO**, per tutti: al massimo tre segni
 * al giorno alla stessa persona, e dopo due segni non ricambiati a quella
 * persona non se ne mandano piu' finche' non risponde. E' la difesa contro
 * l'insistenza, e costa nulla a chi usa l'app normalmente.
 */
export const SEGNI_ALLA_STESSA_PERSONA = 3;
export const NON_RICAMBIATI_AL_MASSIMO = 2;

export type PercheNoAlSegno =
  | "segniFiniti"
  | "troppiAllaStessaPersona"
  | "aspettaCheRisponda"
  | "nonAmici";

export function decidiIlSegno(args: {
  piano: Piano;
  mandatiOggi: number;
  allaStessaOggi: number;
  nonRicambiati: number;
  amici: boolean;
}): {concesso: boolean; perche: PercheNoAlSegno | null} {
  if (!args.amici) return {concesso: false, perche: "nonAmici"};
  if (args.mandatiOggi >= SEGNI_AL_GIORNO[args.piano]) {
    return {concesso: false, perche: "segniFiniti"};
  }
  if (args.allaStessaOggi >= SEGNI_ALLA_STESSA_PERSONA) {
    return {concesso: false, perche: "troppiAllaStessaPersona"};
  }
  if (args.nonRicambiati >= NON_RICAMBIATI_AL_MASSIMO) {
    return {concesso: false, perche: "aspettaCheRisponda"};
  }
  return {concesso: true, perche: null};
}

/**
 * **UNA REAZIONE RISPONDE A UN SEGNO RICEVUTO, un gesto PARTE da zero.** Il
 * verso negativo esiste solo fra le reazioni: non c'e' una porta che lo
 * manda senza un segno a cui rispondere, perche' l'unica porta delle
 * reazioni pretende l'identificativo di un segno ricevuto.
 */
export const REAZIONI = {
  luce: "positiva",
  abbraccio: "positiva",
  grazie: "positiva",
  sorriso: "positiva",
  pensiero: "neutra",
  pernacchia: "negativa",
  occhiAlCielo: "negativa",
} as const;
export type Reazione = keyof typeof REAZIONI;

export function reazioneValida(valore: unknown): Reazione | null {
  return Object.prototype.hasOwnProperty.call(REAZIONI, String(valore)) ?
    (String(valore) as Reazione) :
    null;
}

/**
 * I SEGNI E LE LORO RISPOSTE: l'identificativo e quante risposte ha. Il testo
 * sta nel file di dati del telefono; qui serve solo sapere cosa esiste, per
 * rifiutare cio' che non esiste. Una prova pretende che i due elenchi siano
 * gli stessi.
 */
// Ordine EZ voce 08: i testi dell'Architetto hanno tre risposte per "Ti
// penso" e due per tutti gli altri. Nessun numero e' salito: il server di
// prima accettava gia' tutte le risposte nuove.
export const RISPOSTE_PER_SEGNO: Record<string, number> = {
  tiPenso: 3,
  miManchi: 2,
  buonCammino: 2,
  sonoQui: 2,
  coraggio: 2,
  grazieDiEsserci: 2,
  ilTuoCielo: 2,
  martePerTe: 2,
  lunaPerTe: 2,
  venerePerTe: 2,
  ilSoleTiCerca: 2,
  stelleDiStanotte: 2,
  confrontiamoICieli: 2,
  facciamoLaSinastria: 2,
  stessaCarta: 2,
  stessaRuna: 2,
  respiriamoInsieme: 2,
  alzaLoSguardo: 2,
};

/**
 * LO SCAMBIO DEL GIORNO, per il glifo del legame (EY.14): un tratto si
 * accende in ogni giorno in cui TUTTI E DUE hanno mandato qualcosa all'altro.
 * Restituisce lo stato nuovo e se un tratto si e' acceso adesso.
 */
export function registraLoScambio(args: {
  giorno: string;
  chiManda: string;
  scambio: {giorno: string; chi: string[]} | null;
  giorniAccesi: string[];
}): {scambio: {giorno: string; chi: string[]}; giorniAccesi: string[];
  accesoOra: boolean} {
  const oggi = args.scambio !== null && args.scambio.giorno === args.giorno ?
    args.scambio.chi :
    [];
  const chi = oggi.includes(args.chiManda) ? oggi : [...oggi, args.chiManda];
  const giaAcceso = args.giorniAccesi.includes(args.giorno);
  const accesoOra = chi.length >= 2 && !giaAcceso;
  return {
    scambio: {giorno: args.giorno, chi},
    giorniAccesi: accesoOra ? [...args.giorniAccesi, args.giorno] : args.giorniAccesi,
    accesoOra,
  };
}

// ---------------------------------------------------------------------------
// I DONI E IL GIFT EOS, EY.12
// ---------------------------------------------------------------------------

/**
 * I TRE DONI, tutti nel verso positivo. I prezzi li promette il listino del
 * telefono (`listino_degli_eos.dart`) e una prova pretende che siano questi.
 *
 * **IL DONO NON CONIA EOS A CHI LO RICEVE, MAI.** Chi riceve ottiene l'oggetto,
 * che resta nel suo profilo come ornamento. Due account che si scambiano doni
 * fabbricherebbero valuta.
 */
export const PREZZI_DEI_DONI = {
  cenno: 0,
  scintilla: 30,
  sigillo: 80,
} as const;
export type Dono = keyof typeof PREZZI_DEI_DONI;

export function donoValido(valore: unknown): Dono | null {
  return Object.prototype.hasOwnProperty.call(PREZZI_DEI_DONI, String(valore)) ?
    (String(valore) as Dono) :
    null;
}

/** Il cenno e' per tutti i piani, scintilla e sigillo dall'Adepto in su. */
export function donoPerIlPiano(dono: Dono, piano: Piano): boolean {
  if (dono === "cenno") return true;
  return piano === "tier2" || piano === "tier3";
}

/**
 * **IL GIFT EOS**: minimo cento, massimo cinquecento al giorno, e SOLO a
 * valere su Eos comprati oppure sulla dote del piano, mai su quelli
 * guadagnati gratis. Altrimenti si creano account per raccogliere Eos gratuiti
 * e travasarli su uno solo.
 *
 * Gli Eos regalabili stanno in `borsellino.regalabili` e li alza soltanto un
 * accredito di acquisto o di dote. **Oggi nessuno dei due esiste**: la dote
 * "scattera' quando gli abbonamenti saranno acquistabili" (`borsellino.ts`) e
 * gli acquisti non hanno una porta. Quindi oggi i regalabili valgono zero per
 * tutti, e la porta lo dice invece di inventarsi una fonte.
 */
export const GIFT_MINIMO = 100;
export const GIFT_MASSIMO_AL_GIORNO = 500;

export function decidiIlGift(args: {
  quanti: number;
  regalatiOggi: number;
  regalabili: number;
  saldo: number;
}): {concesso: boolean; perche: "importo" | "tetto" | "nonRegalabili" | null} {
  if (!Number.isInteger(args.quanti) || args.quanti < GIFT_MINIMO) {
    return {concesso: false, perche: "importo"};
  }
  if (args.regalatiOggi + args.quanti > GIFT_MASSIMO_AL_GIORNO) {
    return {concesso: false, perche: "tetto"};
  }
  if (args.quanti > args.regalabili || args.quanti > args.saldo) {
    return {concesso: false, perche: "nonRegalabili"};
  }
  return {concesso: true, perche: null};
}

// ---------------------------------------------------------------------------
// IL TETTO PER IDENTITA' SULLE PORTE SOCIALI, EY.16
// ---------------------------------------------------------------------------

/**
 * OGNI PORTA SOCIALE HA IL SUO TETTO, per identita' e per finestra di tempo.
 * Il rifiuto dice quanto manca, invece di tacere. La porta che restituisce i
 * presenti ha il tetto piu' stretto di tutte, perche' e' quella che espone
 * persone.
 */
export const TETTI_DELLE_PORTE: Record<string, {quante: number; finestraMs: number}> = {
  laTendinaDelCerchio: {quante: 30, finestraMs: 60 * 60 * 1000},
  ilMioProfiloNelCerchio: {quante: 120, finestraMs: 60 * 60 * 1000},
  scegliIlNome: {quante: 20, finestraMs: 60 * 60 * 1000},
  aggiornaIlProfiloNelCerchio: {quante: 120, finestraMs: 60 * 60 * 1000},
  ilCodiceDellInvito: {quante: 40, finestraMs: 60 * 60 * 1000},
  leggiIlCodice: {quante: 60, finestraMs: 60 * 60 * 1000},
  chiediIlLegame: {quante: 60, finestraMs: 60 * 60 * 1000},
  rispondiAlLegame: {quante: 120, finestraMs: 60 * 60 * 1000},
  bloccaUnaPersona: {quante: 60, finestraMs: 60 * 60 * 1000},
  ilMioCerchio: {quante: 120, finestraMs: 60 * 60 * 1000},
  mandaUnSegno: {quante: 120, finestraMs: 60 * 60 * 1000},
  rispondiAlSegno: {quante: 120, finestraMs: 60 * 60 * 1000},
  mandaUnDono: {quante: 60, finestraMs: 60 * 60 * 1000},
  regalaGliEos: {quante: 20, finestraMs: 60 * 60 * 1000},
  compraUnPostoNelCerchio: {quante: 20, finestraMs: 60 * 60 * 1000},
  scriviIlTokenDelCerchio: {quante: 30, finestraMs: 60 * 60 * 1000},
  // Gli Enigmi del Cerchio, ordine FF.
  ilMioRitratto: {quante: 120, finestraMs: 60 * 60 * 1000},
  gliEnigmi: {quante: 120, finestraMs: 60 * 60 * 1000},
  unIndovinello: {quante: 600, finestraMs: 60 * 60 * 1000},
  scopriUnSegno: {quante: 60, finestraMs: 60 * 60 * 1000},
  laProva: {quante: 120, finestraMs: 60 * 60 * 1000},
  unPassoDelPellegrinaggio: {quante: 60, finestraMs: 60 * 60 * 1000},
};

/**
 * La decisione del tetto su una finestra che scorre a blocchi: dentro la
 * stessa finestra si conta, alla finestra dopo si riparte. Restituisce quanto
 * manca alla riapertura quando il tetto e' pieno.
 */
export function decidiIlTetto(args: {
  porta: string;
  inizio: number | null;
  quante: number;
  adessoMs: number;
}): {concesso: boolean; inizio: number; quante: number; mancaMs: number} {
  const tetto = TETTI_DELLE_PORTE[args.porta];
  if (tetto === undefined) {
    // Una porta senza tetto non deve esistere: la prova che enumera le porte
    // lo impedisce, e qui per prudenza si chiude.
    return {concesso: false, inizio: args.adessoMs, quante: 0, mancaMs: 0};
  }
  const stessa = args.inizio !== null &&
    args.adessoMs - args.inizio < tetto.finestraMs;
  const inizio = stessa ? (args.inizio as number) : args.adessoMs;
  const quante = stessa ? args.quante : 0;
  if (quante >= tetto.quante) {
    return {concesso: false, inizio, quante,
      mancaMs: inizio + tetto.finestraMs - args.adessoMs};
  }
  return {concesso: true, inizio, quante: quante + 1, mancaMs: 0};
}

/** La riga del rifiuto per tetto, che dice quanto manca. */
export function rigaDelTetto(mancaMs: number): string {
  const minuti = Math.max(1, Math.ceil(mancaMs / 60000));
  return minuti === 1 ?
    "Hai bussato molte volte: riprova fra un minuto." :
    `Hai bussato molte volte: riprova fra ${minuti} minuti.`;
}
