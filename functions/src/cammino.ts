/**
 * IL CAMMINO CUSTODITO DAL CERCHIO. Ordine AP voce 01.
 *
 * **Il fatto che apre quest'ordine.** Mauro ha disinstallato e reinstallato
 * l'app sulla 2183, e' rientrato con lo stesso account Google, e il
 * borsellino e' tornato solo visitando il Passport mentre i traguardi accesi
 * non sono tornati affatto. La ragione e' che il Cerchio ricordava il DENARO
 * e non il CAMMINO: il diario dei gesti, i Sigilli accesi, l'identita' di
 * nascita e l'archetipo vivevano solo dentro il telefono, in
 * SharedPreferences, e con l'app se ne andavano.
 *
 * **Cosa custodisce, e perche' proprio questo.** Tutto cio' che una persona
 * non deve poter perdere e che il server non puo' ricalcolare da solo:
 * l'identita' di nascita, i conti dei gesti su cui maturano i traguardi, i
 * Sigilli accesi con la data in cui si sono accesi, l'archetipo con la data
 * del test (che governa i tre mesi dell'ordine AO voce 06) e le arti
 * preferite. Non custodisce cio' che si ricalcola, come la carta natale, che
 * nasce dai dati di nascita ogni volta uguale.
 *
 * **UNA PORTA SOLA, e nessuna callable nuova.** Il cammino viaggia dentro
 * `statoDelCerchio`, che il client chiede gia' a ogni apertura: manda cio'
 * che ha, il server fonde e risponde con cio' che vale. Aprire una callable
 * nuova avrebbe voluto dire un secondo canale sullo stesso momento, cioe' la
 * famiglia di difetti piu' numerosa di questo progetto.
 *
 * **LA FUSIONE VIVE QUI E SOLO QUI.** Il client non fonde niente: manda e
 * adotta. Se la regola vivesse anche in Dart sarebbero due regole, e il
 * giorno che una cambia il cammino di qualcuno si spezzerebbe a meta'.
 *
 * **La forma si estende senza rompere chi legge una versione vecchia**: ogni
 * campo e' opzionale, chi non lo conosce lo ignora, e la versione dichiarata
 * dice a chi legge quanto e' vecchio cio' che ha in mano.
 */

/** La versione della forma. Sale quando si aggiunge, mai quando si toglie. */
export const VERSIONE_DEL_CAMMINO = 1;

/** L'identita' di nascita, cioe' cio' che la persona ha dato. */
export interface IdentitaCustodita {
  nome?: string;
  /** Il giorno di nascita in ISO, solo la data. */
  giorno?: string;
  /** L'ora di nascita, "HH:MM", assente se non l'ha data. */
  ora?: string;
  luogo?: string;
  latitudine?: number;
  longitudine?: number;
  fuso?: string;
}

/** Il cammino intero, come viaggia fra telefono e Cerchio. */
export interface CamminoCustodito {
  versione?: number;
  identita?: IdentitaCustodita;
  /** Quante volte ogni gesto e' stato compiuto. */
  gesti?: Record<string, number>;
  /** In quanti giorni diversi ogni gesto e' stato compiuto. */
  giorni?: Record<string, number>;
  /** Quante volte ogni gesto e' caduto nella sua ora rituale. */
  oreGiuste?: Record<string, number>;
  /** I giorni di seguito per rito. */
  serie?: Record<string, number>;
  /** I Sigilli accesi: id del traguardo, data ISO in cui si e' acceso. */
  sigilli?: Record<string, string>;
  /** L'archetipo e il giorno del test, che governa i tre mesi. */
  archetipo?: {dominante?: string; quando?: string};
  /** Le arti preferite, nell'ordine scelto. */
  artiPreferite?: string[];
  /** Il primo e l'ultimo giorno di cammino, in ISO. */
  primoGiorno?: string;
  ultimoGiorno?: string;
}

/** Vero se e' una mappa di numeri utilizzabile. */
function mappaDiNumeri(v: unknown): Record<string, number> {
  const fuori: Record<string, number> = {};
  if (!v || typeof v !== "object") return fuori;
  for (const [chiave, valore] of Object.entries(v as Record<string, unknown>)) {
    if (typeof valore === "number" && Number.isFinite(valore) && valore >= 0) {
      fuori[chiave] = Math.floor(valore);
    }
  }
  return fuori;
}

/** Vero se e' una mappa di testi utilizzabile. */
function mappaDiTesti(v: unknown): Record<string, string> {
  const fuori: Record<string, string> = {};
  if (!v || typeof v !== "object") return fuori;
  for (const [chiave, valore] of Object.entries(v as Record<string, unknown>)) {
    if (typeof valore === "string" && valore.length > 0 && valore.length < 64) {
      fuori[chiave] = valore;
    }
  }
  return fuori;
}

function testo(v: unknown, max = 200): string | undefined {
  if (typeof v !== "string") return undefined;
  const pulito = v.trim();
  if (pulito.length === 0 || pulito.length > max) return undefined;
  return pulito;
}

function numero(v: unknown): number | undefined {
  return typeof v === "number" && Number.isFinite(v) ? v : undefined;
}

/**
 * LEGGE UN CAMMINO ARRIVATO DA FUORI, tenendo solo cio' che ha senso.
 *
 * **Non si fida di niente**, e non e' diffidenza verso la persona: e' che un
 * client vecchio, un client rotto o una richiesta costruita a mano possono
 * mandare qualunque cosa, e cio' che entra nel Cerchio ci resta.
 */
export function leggiCammino(grezzo: unknown): CamminoCustodito {
  if (!grezzo || typeof grezzo !== "object") return {};
  const c = grezzo as Record<string, unknown>;
  const fuori: CamminoCustodito = {};

  const identita = c.identita;
  if (identita && typeof identita === "object") {
    const i = identita as Record<string, unknown>;
    const dentro: IdentitaCustodita = {
      nome: testo(i.nome, 80),
      giorno: testo(i.giorno, 32),
      ora: testo(i.ora, 8),
      luogo: testo(i.luogo, 120),
      latitudine: numero(i.latitudine),
      longitudine: numero(i.longitudine),
      fuso: testo(i.fuso, 64),
    };
    // Si tiene solo se qualcosa c'e' davvero: un guscio vuoto in piu' nel
    // documento non dice niente a nessuno.
    if (Object.values(dentro).some((v) => v !== undefined)) {
      fuori.identita = dentro;
    }
  }

  const gesti = mappaDiNumeri(c.gesti);
  if (Object.keys(gesti).length > 0) fuori.gesti = gesti;
  const giorni = mappaDiNumeri(c.giorni);
  if (Object.keys(giorni).length > 0) fuori.giorni = giorni;
  const oreGiuste = mappaDiNumeri(c.oreGiuste);
  if (Object.keys(oreGiuste).length > 0) fuori.oreGiuste = oreGiuste;
  const serie = mappaDiNumeri(c.serie);
  if (Object.keys(serie).length > 0) fuori.serie = serie;
  const sigilli = mappaDiTesti(c.sigilli);
  if (Object.keys(sigilli).length > 0) fuori.sigilli = sigilli;

  const archetipo = c.archetipo;
  if (archetipo && typeof archetipo === "object") {
    const a = archetipo as Record<string, unknown>;
    const dominante = testo(a.dominante, 32);
    const quando = testo(a.quando, 32);
    if (dominante || quando) fuori.archetipo = {dominante, quando};
  }

  if (Array.isArray(c.artiPreferite)) {
    const arti = c.artiPreferite
      .filter((v): v is string => typeof v === "string" && v.length < 64)
      .slice(0, 40);
    if (arti.length > 0) fuori.artiPreferite = arti;
  }

  fuori.primoGiorno = testo(c.primoGiorno, 32);
  fuori.ultimoGiorno = testo(c.ultimoGiorno, 32);
  return fuori;
}

/** Il piu' alto fra due conteggi, chiave per chiave. */
function ilPiuAlto(
  a: Record<string, number> | undefined,
  b: Record<string, number> | undefined
): Record<string, number> | undefined {
  if (!a && !b) return undefined;
  const fuori: Record<string, number> = {...(a ?? {})};
  for (const [chiave, valore] of Object.entries(b ?? {})) {
    const gia = fuori[chiave] ?? 0;
    if (valore > gia) fuori[chiave] = valore;
  }
  return Object.keys(fuori).length > 0 ? fuori : undefined;
}

/** La data piu' vecchia fra due ISO, quella che tiene il primato. */
function laPiuVecchia(a?: string, b?: string): string | undefined {
  if (!a) return b;
  if (!b) return a;
  return a <= b ? a : b;
}

/** La data piu' recente fra due ISO. */
function laPiuRecente(a?: string, b?: string): string | undefined {
  if (!a) return b;
  if (!b) return a;
  return a >= b ? a : b;
}

/**
 * FONDE DUE CAMMINI, e non ne cancella mai nessuno. Ordine AP voce 03.
 *
 * **La regola, in tre righe.** Per ogni contatore vince IL PIU' ALTO, perche'
 * un conto piu' basso e' sempre un conto piu' vecchio o piu' povero, mai piu'
 * vero. I Sigilli accesi si UNISCONO, e per quelli in comune resta la data
 * PIU' VECCHIA, perche' un Sigillo si accende una volta sola e quel giorno e'
 * un primato. Le date di primato, il primo giorno di cammino e la data del
 * test dell'archetipo, seguono la stessa regola.
 *
 * **Perche' questa e non la sostituzione.** E' la lezione della voce AO.04,
 * dove un conto povero scritto sopra una storia ricca aveva azzerato il
 * cammino di chi apriva l'app e faceva subito un gesto: il difetto non era
 * l'ordine delle scritture, era che una scrittura potesse distruggere.
 */
export function fondiCammini(
  server: CamminoCustodito | undefined,
  telefono: CamminoCustodito | undefined
): CamminoCustodito {
  const a = server ?? {};
  const b = telefono ?? {};
  const fuori: CamminoCustodito = {versione: VERSIONE_DEL_CAMMINO};

  // L'IDENTITA': campo per campo, vince chi ce l'ha. Se tutti e due ce
  // l'hanno, vince il server, che e' la copia che sopravvive ai telefoni.
  if (a.identita || b.identita) {
    const uno = a.identita ?? {};
    const due = b.identita ?? {};
    const dentro: IdentitaCustodita = {
      nome: uno.nome ?? due.nome,
      giorno: uno.giorno ?? due.giorno,
      ora: uno.ora ?? due.ora,
      luogo: uno.luogo ?? due.luogo,
      latitudine: uno.latitudine ?? due.latitudine,
      longitudine: uno.longitudine ?? due.longitudine,
      fuso: uno.fuso ?? due.fuso,
    };
    for (const chiave of Object.keys(dentro) as (keyof IdentitaCustodita)[]) {
      if (dentro[chiave] === undefined) delete dentro[chiave];
    }
    if (Object.keys(dentro).length > 0) fuori.identita = dentro;
  }

  const gesti = ilPiuAlto(a.gesti, b.gesti);
  if (gesti) fuori.gesti = gesti;
  const giorni = ilPiuAlto(a.giorni, b.giorni);
  if (giorni) fuori.giorni = giorni;
  const oreGiuste = ilPiuAlto(a.oreGiuste, b.oreGiuste);
  if (oreGiuste) fuori.oreGiuste = oreGiuste;
  const serie = ilPiuAlto(a.serie, b.serie);
  if (serie) fuori.serie = serie;

  if (a.sigilli || b.sigilli) {
    const sigilli: Record<string, string> = {...(a.sigilli ?? {})};
    for (const [id, quando] of Object.entries(b.sigilli ?? {})) {
      const gia = sigilli[id];
      const vince = laPiuVecchia(gia, quando);
      if (vince) sigilli[id] = vince;
    }
    if (Object.keys(sigilli).length > 0) fuori.sigilli = sigilli;
  }

  if (a.archetipo || b.archetipo) {
    const uno = a.archetipo ?? {};
    const due = b.archetipo ?? {};
    // **LA DATA PIU' VECCHIA VINCE, e non e' un dettaglio**: e' quella che
    // decide quando si potra' rifare il test, e prendere la piu' recente
    // regalerebbe tre mesi di attesa a chi cambia telefono.
    const quando = laPiuVecchia(uno.quando, due.quando);
    const dominante =
      (uno.quando && uno.quando === quando ? uno.dominante : undefined) ??
      (due.quando && due.quando === quando ? due.dominante : undefined) ??
      uno.dominante ??
      due.dominante;
    const archetipo: {dominante?: string; quando?: string} = {};
    if (dominante) archetipo.dominante = dominante;
    if (quando) archetipo.quando = quando;
    if (Object.keys(archetipo).length > 0) fuori.archetipo = archetipo;
  }

  // LE ARTI PREFERITE: vince chi ne ha, e a parita' il server. Non si
  // uniscono, perche' sono un ORDINE scelto dalla persona e un'unione
  // inventerebbe un ordine che nessuno ha scelto.
  const arti = a.artiPreferite ?? b.artiPreferite;
  if (arti && arti.length > 0) fuori.artiPreferite = arti;

  const primo = laPiuVecchia(a.primoGiorno, b.primoGiorno);
  if (primo) fuori.primoGiorno = primo;
  const ultimo = laPiuRecente(a.ultimoGiorno, b.ultimoGiorno);
  if (ultimo) fuori.ultimoGiorno = ultimo;

  return fuori;
}

/** Toglie i campi non definiti, che Firestore rifiuta di scrivere. */
export function senzaVuoti<T extends Record<string, unknown>>(dato: T): T {
  const fuori = {...dato};
  for (const chiave of Object.keys(fuori)) {
    if (fuori[chiave] === undefined) delete fuori[chiave];
  }
  return fuori;
}
