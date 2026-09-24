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
  /**
   * **LA FORMA DI CORTESIA, e il server la buttava via.** Ordine EE voce 13.
   *
   * Il telefono la spedisce dall'ordine CF voce 07, `cammino_da_custodire`
   * riga 228, e la riadotta al ritorno in `custode_del_cammino`: ma questa
   * interfaccia dichiarava sette campi su nove, quindi `forma` e `scarto`
   * venivano scartati al primo parsing e non tornavano mai. **Il ramo che li
   * riadotta non si e' mai acceso in vita sua**, e il codice del telefono e'
   * scritto e commentato come se funzionasse: chi legge il repository
   * conclude che il difetto dell'ordine CF sia chiuso, e non lo e'.
   *
   * Effetto sulla persona: chi reinstalla si sente chiamare col genere
   * sbagliato, che e' esattamente cio' che l'ordine CF voleva impedire.
   */
  forma?: string;
  /**
   * Lo scarto dall'UTC del luogo di nascita, in minuti. Stessa storia della
   * `forma`: spedito a riga 236 e scartato qui. Senza di lui chi e' nato in
   * una citta' fuori dal catalogo prende l'ora di Roma.
   */
  scarto?: number;
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
  /**
   * **IL DIARIO DELL'ARCANO DELL'ALBA**, ordine DT voce 05: il sacchetto dei
   * quarantaquattro stati, le code delle letture, i registri del ciclo e il
   * seme della persona. Il Cerchio non lo interpreta: lo custodisce intero e,
   * fra due copie, tiene quella piu' avanti.
   */
  arcanoDellAlba?: Record<string, unknown>;
  /**
   * **IL DIARIO DEL VIAGGIO DELLO SCIAMANO**, ordine EE voce 13.
   *
   * **Il fatto che l'ha fatto nascere.** Il Viaggio viveva su sette chiavi di
   * `SharedPreferences` e **non aveva nessuna porta verso il Cerchio**: zero
   * chiamate in novecento righe di `diario_dei_viaggi.dart`. Il fondatore ha
   * aggiornato l'app e si e' ritrovato da rifare da zero un viaggio che
   * aveva concluso, e che per sua stessa dichiarazione **costa quattro
   * giorni**: quattro discese, una al giorno.
   *
   * Come per l'Alba, il Cerchio non lo interpreta: lo custodisce intero e,
   * fra due copie, tiene quella piu' avanti.
   */
  viaggioDelloSciamano?: Record<string, unknown>;
}

/** Quanto puo' pesare il diario dell'Alba, scritto: un ciclo pieno sta sotto. */
export const PESO_MASSIMO_DEL_DIARIO_DELL_ALBA = 20000;

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
      // Ordine EE voce 13: questi due il telefono li mandava gia', e si
      // fermavano qui.
      forma: testo(i.forma, 16),
      scarto: numero(i.scarto),
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

  const alba = c.arcanoDellAlba;
  if (
    alba &&
    typeof alba === "object" &&
    !Array.isArray(alba) &&
    JSON.stringify(alba).length <= PESO_MASSIMO_DEL_DIARIO_DELL_ALBA
  ) {
    fuori.arcanoDellAlba = alba as Record<string, unknown>;
  }

  // Ordine EE voce 13: lo stesso trattamento per il Viaggio dello Sciamano.
  const viaggio = c.viaggioDelloSciamano;
  if (
    viaggio &&
    typeof viaggio === "object" &&
    !Array.isArray(viaggio) &&
    JSON.stringify(viaggio).length <= PESO_MASSIMO_DEL_DIARIO_DELL_ALBA
  ) {
    fuori.viaggioDelloSciamano = viaggio as Record<string, unknown>;
  }
  return fuori;
}

/**
 * **QUANTO E' AVANTI UN DIARIO DELL'ALBA**: il giorno dell'ultima estrazione,
 * poi il ciclo, poi gli stati gia' usciti nel ciclo. Si confronta nell'ordine.
 */
function avanzamentoDellAlba(
  d: Record<string, unknown> | undefined
): [string, number, number] {
  if (!d) return ["", 0, 0];
  const ultima = d.ultima as Record<string, unknown> | undefined;
  const giorno = typeof ultima?.giorno === "string" ? ultima.giorno : "";
  const sacchetto = d.sacchetto as Record<string, unknown> | undefined;
  const ciclo = typeof sacchetto?.ciclo === "number" ? sacchetto.ciclo : 0;
  const rimasti = Array.isArray(sacchetto?.rimasti) ?
    sacchetto.rimasti.length :
    44;
  return [giorno, ciclo, 44 - rimasti];
}

/**
 * **FRA DUE DIARI DELL'ALBA VINCE IL PIU' AVANTI**, e a parita' il server. Non
 * si fondono pezzo per pezzo: un sacchetto e' un tutto, e mescolarne due
 * farebbe uscire uno stato due volte nello stesso ciclo.
 */
export function ilDiarioPiuAvanti(
  server: Record<string, unknown> | undefined,
  telefono: Record<string, unknown> | undefined
): Record<string, unknown> | undefined {
  if (!server) return telefono;
  if (!telefono) return server;
  const a = avanzamentoDellAlba(server);
  const b = avanzamentoDellAlba(telefono);
  for (let i = 0; i < a.length; i++) {
    if (a[i] > b[i]) return server;
    if (a[i] < b[i]) return telefono;
  }
  return server;
}

/**
 * **FRA DUE VIAGGI DELLO SCIAMANO, QUELLO PIU' AVANTI.** Ordine EE voce 13.
 *
 * **Il criterio non e' quello dell'Alba, e non poteva esserlo.** L'Alba si
 * misura sul suo ciclo di quarantaquattro stati; il Viaggio ha una soglia
 * sola che conta davvero, **il riconoscimento**, che arriva dopo quattro
 * discese in quattro giorni. Quindi: chi ha riconosciuto batte chi no, e a
 * parita' vince chi ha fatto piu' discese.
 *
 * **A parita' piena vince il server**, come per il resto di questa fusione:
 * e' la copia che sopravvive ai telefoni.
 */
export function ilViaggioPiuAvanti(
  server: Record<string, unknown> | undefined,
  telefono: Record<string, unknown> | undefined
): Record<string, unknown> | undefined {
  if (!server) return telefono;
  if (!telefono) return server;
  const passo = (v: Record<string, unknown>): [number, number] => [
    v.riconosciuto === true ? 1 : 0,
    typeof v.quante === "number" ? v.quante : 0,
  ];
  const a = passo(server);
  const b = passo(telefono);
  for (let i = 0; i < a.length; i++) {
    if (a[i] > b[i]) return server;
    if (a[i] < b[i]) return telefono;
  }
  return server;
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
      forma: uno.forma ?? due.forma,
      scarto: uno.scarto ?? due.scarto,
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

  const alba = ilDiarioPiuAvanti(a.arcanoDellAlba, b.arcanoDellAlba);
  if (alba) fuori.arcanoDellAlba = alba;
  const viaggio = ilViaggioPiuAvanti(
    a.viaggioDelloSciamano,
    b.viaggioDelloSciamano
  );
  if (viaggio) fuori.viaggioDelloSciamano = viaggio;

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

/**
 * **FIRESTORE NON ACCETTA UNA LISTA DENTRO UNA LISTA.** Guasto trovato
 * nell'ordine EK il 24 settembre 2026, fuori dal perimetro, e curato col
 * permesso del fondatore.
 *
 * Il diario dell'Alba porta `registro`, una lista di consegne che sono a loro
 * volta liste di marche (ordine DU, commit b8cf8106). Firestore rifiuta di
 * scriverlo con *"Property arcanoDellAlba contains an invalid nested
 * entity"*, e con lui cadeva `statoDelCerchio` intera: dal 23 settembre 2026
 * alle 11:50 UTC chi aveva pescato una carta dell'Alba non riceveva piu' ne'
 * il piano ne' i residui ne' il giorno, 182 cadute il primo giorno.
 *
 * **Il telefono continua a mandare la sua forma e continua a riceverla.** La
 * traduzione vive solo sul bordo col database: una lista dentro una lista
 * diventa `{"_lista_annidata": [...]}` quando si scrive, e torna lista quando
 * si legge. Vale per il documento intero e non solo per il registro, cosi' il
 * prossimo diario con una lista annidata non fa cadere di nuovo tutto.
 *
 * **La chiave non e' `__lista__`, e c'e' una ragione misurata.** La prima
 * versione pubblicata la usava, e Firestore l'ha respinta con *"field name
 * '__lista__' is reserved"*: i nomi fra due doppi trattini bassi sono suoi.
 * Nessuna prova in locale poteva saperlo; l'ha detto il registro del server
 * alla prima apertura del Realme, e adesso la prova lo pretende.
 */
export const CHIAVE_DELLA_LISTA = "_lista_annidata";

function oggettoSemplice(v: unknown): v is Record<string, unknown> {
  if (v === null || typeof v !== "object" || Array.isArray(v)) return false;
  const proto = Object.getPrototypeOf(v);
  return proto === Object.prototype || proto === null;
}

function codifica(v: unknown, inUnaLista: boolean): unknown {
  if (Array.isArray(v)) {
    const lista = v.map((x) => codifica(x, true));
    return inUnaLista ? {[CHIAVE_DELLA_LISTA]: lista} : lista;
  }
  // Solo gli oggetti semplici: un Timestamp o un FieldValue passano intatti.
  if (oggettoSemplice(v)) {
    const fuori: Record<string, unknown> = {};
    for (const [chiave, valore] of Object.entries(v)) {
      fuori[chiave] = codifica(valore, false);
    }
    return fuori;
  }
  return v;
}

function decodifica(v: unknown): unknown {
  if (Array.isArray(v)) return v.map(decodifica);
  if (oggettoSemplice(v)) {
    const chiavi = Object.keys(v);
    const lista = v[CHIAVE_DELLA_LISTA];
    if (chiavi.length === 1 && Array.isArray(lista)) {
      return lista.map(decodifica);
    }
    const fuori: Record<string, unknown> = {};
    for (const [chiave, valore] of Object.entries(v)) {
      fuori[chiave] = decodifica(valore);
    }
    return fuori;
  }
  return v;
}

/** Cio' che si scrive su Firestore: nessuna lista dentro una lista. */
export function perFirestore<T>(dato: T): T {
  return codifica(dato, false) as T;
}

/** Cio' che si legge da Firestore, riportato alla forma del telefono. */
export function daFirestore<T>(dato: T): T {
  return decodifica(dato) as T;
}
