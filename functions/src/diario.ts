/**
 * IL DIARIO COSMICO, LATO SERVER. Ordine FE voce 22, 6 ottobre 2026.
 *
 * **Perche' nasce.** Prima di quest'ordine il menu' della chat leggeva i
 * messaggi sul server, mentre il Diario leggeva un indice tenuto sul
 * telefono (`ricordi.voci.*`), che saliva al server una volta sola per
 * installazione: le voci di settembre di Medora c'erano nel menu' e non nel
 * Diario (catture del fondatore in docs/collaudo/FE/catture_del_fondatore/).
 * Due fonti, e la seconda con dei buchi.
 *
 * **Come sta adesso, e il conto delle letture (FE.22.14 e FE.22.18).**
 * - `users/{uid}/diario/{AAAA}`: il riassunto dell'anno, una lettura:
 *   quante voci per mese e quante stelle per giorno.
 * - `users/{uid}/diario/{AAAA}/mesi/{MM}`: l'indice di un mese, una lettura:
 *   una riga per voce (titolo, quando, Maestro, tipo, arte, stella).
 * - `users/{uid}/diario_voci/{chiave}`: il contenuto di una voce che non e'
 *   una conversazione (il responso coi suoi dati, la riga della persona); si
 *   legge solo aprendo la voce. Il contenuto di una conversazione sono i
 *   suoi messaggi, che stanno gia' sul server.
 * Aprire il Diario costa il riassunto dell'anno e il mese corrente: due
 * letture, con cento voci come con mille.
 *
 * **Lo scrive il server, mai un gesto.** Ogni messaggio della persona che
 * passa da `scriviLaMemoria` aggiorna la riga della sua conversazione nella
 * stessa chiamata (FE.22.6); i responsi li annota l'app quando li mostra.
 */
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {
  getFirestore, FieldValue, DocumentReference,
} from "firebase-admin/firestore";

const OPZIONI = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
};

/**
 * La versione del formato dei dati di una voce. FE.22.12.
 * - 0: il formato piatto dello scrigno dei custoditi, prima dell'ordine FE
 *   (i campi del responso in cima, `q` in minuti);
 * - 1: la voce col suo `q` in millesimi e il responso intero in `c`.
 */
export const VERSIONE_DEL_FORMATO = 1;

/** I tipi di voce. */
export const I_TIPI = ["conversazione", "responso", "lettura"] as const;
export type Tipo = typeof I_TIPI[number];

/** Una riga dell'indice. */
export interface Riga {
  /** Il titolo: il tema della conversazione, o il titolo del responso. */
  t: string;
  /** Il Maestro, se c'e'. */
  m: string | null;
  /** Il tipo. */
  k: Tipo;
  /** L'arte. */
  a: string;
  /** Quando, in millesimi dall'epoca. */
  q: number;
  /** La stella, il segno della persona. FE.22.7. */
  s?: boolean;
}

/** Quanti caratteri porta il titolo di una riga. */
export const LUNGHEZZA_DEL_TITOLO = 120;

/** Quanto pesa al piu' il contenuto di una voce, in byte. */
export const MASSIMI_BYTE_DEL_CONTENUTO = 8000;

/** Quanto e' lunga al piu' la riga della persona. FE.22.10. */
export const LUNGHEZZA_DELLA_NOTA = 280;

const FORMA_DELLA_CHIAVE = /^[a-z0-9_.-]{3,120}$/;

/** Il giorno a Roma, `AAAA-MM-GG`: il Diario si legge col calendario
 * della persona, e il fuso del progetto e' quello. */
export function giornoDi(q: number): string {
  const parti = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Rome", year: "numeric", month: "2-digit",
    day: "2-digit",
  }).format(new Date(q));
  return parti; // en-CA scrive AAAA-MM-GG
}

/** Il titolo pulito: una riga, senza spazi doppi, al piu' 120 caratteri. */
export function titoloDa(testo: string): string {
  const t = testo.replace(/\s+/g, " ").trim();
  return t.length > LUNGHEZZA_DEL_TITOLO ?
    `${t.slice(0, LUNGHEZZA_DEL_TITOLO - 3).trimEnd()}...` :
    t;
}

/** La chiave della riga di una conversazione. */
export function chiaveDellaConversazione(
  maestro: string,
  conversazione: string | null
): string {
  const c = (conversazione ?? "prima").replace(/[^a-z0-9_-]/gi, "")
    .toLowerCase();
  return `conv.${maestro}.${c || "prima"}`;
}

/**
 * LE ETICHETTE DI UNA RIGA: i filtri del Diario per cui conta. "tutte",
 * il tipo ("conversazioni", "responsi" o "letture"), il Maestro, e
 * "stelle" se porta la stella. Sono i filtri del Diario sul telefono.
 */
export function etichetteDi(riga: Riga): string[] {
  const e = ["tutte", riga.k === "conversazione" ? "conversazioni" :
    riga.k === "responso" ? "responsi" : "letture"];
  if (riga.m) e.push(riga.m);
  if (riga.s) e.push("stelle");
  return e;
}

/** Il riassunto di un anno: per mese, quante righe per etichetta; per
 * giorno, quante stelle (il giorno eredita la stella, FE.22.8). */
export interface Riassunto {
  mesi: Record<string, Record<string, number>>;
  stelle: Record<string, number>;
}

/**
 * Il riassunto dell'anno dopo una riga nuova (+1) o tolta (-1), o una
 * stella messa (+1) o tolta (-1): [etichette] sono quelle che cambiano.
 * Puro: la prova lo chiama senza Firestore. Una lettura sola disegna
 * l'anno, anche filtrato (FE.22.18).
 */
export function ilRiassuntoDopo(
  prima: Record<string, any>,
  giorno: string,
  etichette: string[],
  delta: number
): Riassunto {
  const mesi: Record<string, Record<string, number>> = {};
  for (const [m, v] of Object.entries(prima.mesi ?? {})) {
    if (v && typeof v === "object") mesi[m] = {...(v as Record<string, number>)};
  }
  const stelle = {...((prima.stelle ?? {}) as Record<string, number>)};
  const mese = giorno.slice(5, 7);
  const g = giorno.slice(5);
  const conti = mesi[mese] ?? {};
  for (const e of etichette) {
    conti[e] = Math.max(0, (conti[e] ?? 0) + delta);
    if (conti[e] === 0) delete conti[e];
  }
  if (Object.keys(conti).length) mesi[mese] = conti; else delete mesi[mese];
  if (etichette.includes("stelle")) {
    stelle[g] = Math.max(0, (stelle[g] ?? 0) + delta);
    if (stelle[g] === 0) delete stelle[g];
  }
  return {mesi, stelle};
}

const db = () => getFirestore();
const annoDoc = (uid: string, anno: string) =>
  db().collection("users").doc(uid).collection("diario").doc(anno);
const meseDoc = (uid: string, giorno: string) =>
  annoDoc(uid, giorno.slice(0, 4)).collection("mesi").doc(giorno.slice(5, 7));
const vocePiena = (uid: string, chiave: string) =>
  db().collection("users").doc(uid).collection("diario_voci").doc(chiave);

/** Scrive una riga nuova, se non c'e' gia', e aggiorna il riassunto. */
async function scriviLaRiga(
  uid: string,
  chiave: string,
  riga: Riga
): Promise<{nuova: boolean; giorno: string}> {
  const giorno = giornoDi(riga.q);
  const mese = meseDoc(uid, giorno);
  const anno = annoDoc(uid, giorno.slice(0, 4));
  return db().runTransaction(async (t) => {
    const [m, a] = await Promise.all([t.get(mese), t.get(anno)]);
    const righe = (m.data()?.righe ?? {}) as Record<string, Riga>;
    if (righe[chiave]) return {nuova: false, giorno};
    t.set(mese, {righe: {[chiave]: riga}}, {merge: true});
    t.set(anno, ilRiassuntoDopo(a.data() ?? {}, giorno, etichetteDi(riga), 1),
      {mergeFields: ["mesi", "stelle"]});
    return {nuova: true, giorno};
  });
}

/**
 * LA RIGA DI UNA CONVERSAZIONE, scritta dal server col primo messaggio della
 * persona. Il titolo e' la domanda con cui il consulto comincia, cioe' il
 * tema della scheda dei punti fermi (FE.22.14). Una conversazione che
 * continua in un altro giorno resta una riga sola: si cerca nel mese del suo
 * primo giorno e in quello di oggi.
 */
export async function annotaLaConversazione(
  uid: string,
  maestro: string,
  campi: Record<string, unknown>,
  adesso: number = Date.now()
): Promise<void> {
  if (campi.role !== "user") return;
  const testo = typeof campi.text === "string" ? campi.text : "";
  if (!testo.trim()) return;
  const conversazione =
    typeof campi.conversazione === "string" ? campi.conversazione : null;
  const chiave = chiaveDellaConversazione(maestro, conversazione);
  // Una conversazione nata ieri ha la riga nel mese di ieri: il suo id
  // porta il momento della nascita ("c" e i millesimi), e da li' si trova.
  const nata = conversazione && /^c\d{12,}$/.test(conversazione) ?
    Number(conversazione.slice(1)) : adesso;
  const giornoNascita = giornoDi(nata);
  const giaNelMese = await meseDoc(uid, giornoNascita).get();
  const righe = (giaNelMese.data()?.righe ?? {}) as Record<string, Riga>;
  if (righe[chiave]) return;
  await scriviLaRiga(uid, chiave, {
    t: titoloDa(testo), m: maestro, k: "conversazione", a: "chat", q: nata,
  });
}

/** Toglie una riga e il suo contenuto, ovunque stia. FE.22.17. */
export async function togliDalDiario(
  uid: string,
  chiave: string,
  q: number
): Promise<boolean> {
  const giorno = giornoDi(q);
  const mese = meseDoc(uid, giorno);
  const anno = annoDoc(uid, giorno.slice(0, 4));
  const tolta = await db().runTransaction(async (t) => {
    const [m, a] = await Promise.all([t.get(mese), t.get(anno)]);
    const righe = (m.data()?.righe ?? {}) as Record<string, Riga>;
    const riga = righe[chiave];
    if (!riga) return false;
    t.update(mese, {[`righe.${chiave}`]: FieldValue.delete()});
    t.set(anno, ilRiassuntoDopo(a.data() ?? {}, giorno, etichetteDi(riga), -1),
      {mergeFields: ["mesi", "stelle"]});
    return true;
  });
  await vocePiena(uid, chiave).delete();
  return tolta;
}

/** L'uid dal token, mai dal corpo. */
function uidDi(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Serve un account.");
  }
  return uid;
}

function chiaveValida(x: unknown): string {
  const c = String(x ?? "").trim();
  if (!FORMA_DELLA_CHIAVE.test(c)) {
    throw new HttpsError("invalid-argument", "Chiave non valida.");
  }
  return c;
}

function quandoValido(x: unknown): number {
  const q = Number(x);
  if (!Number.isFinite(q) || q < Date.UTC(2025, 0, 1) ||
      q > Date.now() + 24 * 3600 * 1000) {
    throw new HttpsError("invalid-argument", "Momento non valido.");
  }
  return Math.floor(q);
}

/**
 * ANNOTA UN RESPONSO O UNA LETTURA, coi suoi dati. FE.22.6 e FE.22.11: lo
 * chiama l'app quando il responso si mostra, senza che la persona prema
 * niente. Del responso si conservano i dati che lo generano (le carte, la
 * runa, il segno, il transito, il testo), mai un'immagine: la card si
 * ridisegna dai dati con la grafica di quel momento.
 */
export const annotaNelDiario = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const d = (request.data ?? {}) as Record<string, unknown>;
  const chiave = chiaveValida(d.chiave);
  const q = quandoValido(d.q);
  const k = String(d.k ?? "responso") as Tipo;
  if (!I_TIPI.includes(k) || k === "conversazione") {
    throw new HttpsError("invalid-argument", "Tipo non valido.");
  }
  const a = String(d.a ?? "").slice(0, 40);
  const m = typeof d.m === "string" && d.m ? d.m.slice(0, 20) : null;
  const contenuto = d.contenuto;
  if (contenuto === null || typeof contenuto !== "object" ||
      Array.isArray(contenuto)) {
    throw new HttpsError("invalid-argument", "Contenuto non valido.");
  }
  if (JSON.stringify(contenuto).length > MASSIMI_BYTE_DEL_CONTENUTO) {
    throw new HttpsError("invalid-argument", "Contenuto troppo grande.");
  }
  const {nuova} = await scriviLaRiga(uid, chiave, {
    t: titoloDa(String(d.t ?? "")), m, k, a, q,
  });
  if (nuova) {
    // Il contenuto sta in `c`, mai aperto dentro la voce: i suoi campi (il
    // responso porta `q` in minuti) non devono coprire quelli della voce,
    // che la pulizia notturna legge in millesimi.
    await vocePiena(uid, chiave).set({
      v: VERSIONE_DEL_FORMATO, k, a, m, q, c: contenuto,
    }, {merge: true});
  }
  return {annotata: nuova};
});

/**
 * LA STELLA, da qualunque dei due posti. FE.22.7: un campo solo, `s` nella
 * riga dell'indice; la riga della persona (FE.22.10) sta col contenuto, e
 * non la legge nessun modello.
 */
export const stellaNelDiario = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const d = (request.data ?? {}) as Record<string, unknown>;
  const chiave = chiaveValida(d.chiave);
  const q = quandoValido(d.q);
  const stella = d.stella === true;
  const giorno = giornoDi(q);
  const mese = meseDoc(uid, giorno);
  const anno = annoDoc(uid, giorno.slice(0, 4));
  const fatto = await db().runTransaction(async (t) => {
    const [m, a] = await Promise.all([t.get(mese), t.get(anno)]);
    const righe = (m.data()?.righe ?? {}) as Record<string, Riga>;
    const riga = righe[chiave];
    if (!riga) return false;
    const prima = riga.s === true;
    if (prima !== stella) {
      t.update(mese, {[`righe.${chiave}.s`]: stella});
      t.set(anno, ilRiassuntoDopo(a.data() ?? {}, giorno, ["stelle"],
        stella ? 1 : -1), {mergeFields: ["mesi", "stelle"]});
    }
    return true;
  });
  if (!fatto) throw new HttpsError("not-found", "Voce sconosciuta.");
  if (typeof d.nota === "string") {
    const nota = d.nota.trim().slice(0, LUNGHEZZA_DELLA_NOTA);
    await vocePiena(uid, chiave).set(
      {nota: nota || FieldValue.delete()}, {merge: true});
  }
  return {stella};
});

/** Il riferimento al contenuto di una voce, per le prove. */
export function rifDelContenuto(uid: string, chiave: string): DocumentReference {
  return vocePiena(uid, chiave);
}

/**
 * Trova il giorno di una riga senza saperlo: scorre i mesi con dati. Serve
 * al cestino di una conversazione nata prima della marcatura col momento.
 */
export async function ilGiornoDellaRiga(
  uid: string,
  chiave: string
): Promise<number | null> {
  const anni = await db().collection("users").doc(uid)
    .collection("diario").listDocuments();
  for (const anno of anni) {
    const mesi = await anno.collection("mesi").get();
    for (const m of mesi.docs) {
      const riga = (m.data().righe ?? {})[chiave] as Riga | undefined;
      if (riga) return riga.q;
    }
  }
  return null;
}

/** Toglie una riga dovunque stia. */
export async function togliDalDiarioOvunque(
  uid: string,
  chiave: string
): Promise<boolean> {
  const q = await ilGiornoDellaRiga(uid, chiave);
  if (q === null) {
    await vocePiena(uid, chiave).delete();
    return false;
  }
  return togliDalDiario(uid, chiave, q);
}

/**
 * IL DIARIO SI RIEMPIE DELLE CONVERSAZIONI DI PRIMA. FE.22.6: le
 * conversazioni nate prima di questo Diario non hanno la riga, e senza
 * questo passo non l'avrebbero mai. Una volta per persona: legge i messaggi
 * dei tre Maestri, prende per ogni conversazione la prima domanda, e segna
 * `riempito` nel profilo.
 */
export const riempiIlDiario = onCall(
  {...OPZIONI, timeoutSeconds: 120},
  async (request) => {
    const uid = uidDi(request);
    const profilo = db().collection("users").doc(uid);
    const gia = (await profilo.get()).data()?.diarioRiempito === true;
    if (gia) return {righe: 0, gia: true};
    let righe = 0;
    for (const maestro of ["medora", "aura", "caligo"]) {
      const snap = await profilo.collection("maestri").doc(maestro)
        .collection("messages").orderBy("createdAt").get();
      const viste = new Set<string>();
      for (const d of snap.docs) {
        const dati = d.data();
        if (dati.role !== "user") continue;
        const c = typeof dati.conversazione === "string" ?
          dati.conversazione : null;
        const chiave = chiaveDellaConversazione(maestro, c);
        if (viste.has(chiave)) continue;
        viste.add(chiave);
        const quando = dati.createdAt?.toMillis?.() ?? Date.now();
        const nata = c && /^c\d{12,}$/.test(c) ? Number(c.slice(1)) : quando;
        const {nuova} = await scriviLaRiga(uid, chiave, {
          t: titoloDa(String(dati.text ?? "")), m: maestro,
          k: "conversazione", a: "chat", q: nata,
        });
        if (nuova) righe++;
      }
    }
    // I RESPONSI CUSTODITI DI PRIMA diventano voci con la stella, sulla
    // stessa chiave del responso (minuto e arte): una voce sola, un segno
    // solo (FE.22.7). Il contenuto resta nel formato di prima, versione 0.
    const custoditi = await profilo.collection("custoditi").get();
    for (const d of custoditi.docs) {
      const c = d.data();
      const minuti = Number(c.q);
      if (!Number.isFinite(minuti) || !FORMA_DELLA_CHIAVE.test(d.id)) continue;
      const {nuova} = await scriviLaRiga(uid, d.id, {
        t: titoloDa(String(c.i ?? "")), m: typeof c.m === "string" ? c.m : null,
        k: "responso", a: String(c.a ?? ""), q: minuti * 60000, s: true,
      });
      if (nuova) {
        righe++;
        const {custoditoIl: _, ...contenuto} = c;
        await vocePiena(uid, d.id).set({
          v: VERSIONE_DEL_FORMATO, k: "responso", a: String(c.a ?? ""),
          m: typeof c.m === "string" ? c.m : null, q: minuti * 60000,
          c: contenuto,
        }, {merge: true});
      }
    }
    // LE RIGHE DEL VECCHIO INDICE (users/{uid}/ricordi/{AAAA-MM}): le arti
    // e i responsi; le conversazioni no, che vengono dai messaggi.
    const vecchi = await profilo.collection("ricordi").get();
    for (const mese of vecchi.docs) {
      const r = (mese.data().righe ?? {}) as Record<string, any>;
      for (const vecchia of Object.values(r)) {
        if (!vecchia || vecchia.k === "c") continue;
        const minuti = Number(vecchia.q);
        if (!Number.isFinite(minuti)) continue;
        const rif = typeof vecchia.r === "string" ? vecchia.r : "";
        const chiave = /^\d+\.[a-z_]+$/.test(rif) ? rif :
          `v.${minuti}.${String(vecchia.a ?? "").replace(/[^a-z_]/g, "")}`;
        if (!FORMA_DELLA_CHIAVE.test(chiave)) continue;
        const {nuova} = await scriviLaRiga(uid, chiave, {
          t: titoloDa(String(vecchia.t ?? "")),
          m: typeof vecchia.m === "string" && vecchia.m ? vecchia.m : null,
          k: vecchia.k === "r" ? "responso" : "lettura",
          a: String(vecchia.a ?? ""), q: minuti * 60000,
        });
        if (nuova) righe++;
      }
    }
    await profilo.set({diarioRiempito: true}, {merge: true});
    return {righe, gia: false};
  }
);

/** Legge il contenuto di una voce aperta. FE.22.14. */
export const leggiLaVoce = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const chiave = chiaveValida(request.data?.chiave);
  const doc = await vocePiena(uid, chiave).get();
  if (!doc.exists) return {voce: null};
  const dati = doc.data() ?? {};
  // Una voce in archivio si riprende da li', con la riga della persona.
  if (typeof dati.archiviata === "string") {
    const piena = await laVoceInArchivio(dati.archiviata, chiave);
    return {
      voce: {...(piena ?? {}), ...(typeof dati.nota === "string" ?
        {nota: dati.nota} : {})},
      dallArchivio: true,
    };
  }
  return {voce: dati, dallArchivio: false};
});

/**
 * L'ARCHIVIO PIU' ECONOMICO. Ordine FE voce 22.15.
 *
 * Il contenuto delle voci e i messaggi delle conversazioni piu' vecchi di
 * dodici mesi passano in Cloud Storage, nel bucket di Firebase del progetto
 * (europe-west1), con la classe Archive impostata oggetto per oggetto;
 * l'indice resta dov'e', e le voci restano visibili nel Diario come tutte le
 * altre. Aprendone una, il contenuto si recupera (`leggiLaVoce`), e intanto
 * l'app dice "Sto riprendendo questo giorno.".
 *
 * **UN OGGETTO PER PERSONA E PER MESE, non uno per voce.** Il listino del
 * Belgio letto il 6 ottobre 2026 (cloud.google.com/storage/pricing): la
 * classe Archive costa 0,0012 USD per GiB al mese da tenere, ma 0,05 USD
 * ogni mille scritture, 0,05 USD ogni mille letture, 0,05 USD per GiB
 * recuperato, e chi sostituisce o cancella un oggetto prima di 365 giorni
 * paga i 365 giorni. Una voce pesa sotto il chilobyte: con un oggetto per
 * voce la sola scrittura costava piu' di vent'anni della stessa voce su
 * Firestore. Con un oggetto per mese la scrittura si paga una volta per
 * persona e per mese, e un mese si archivia solo quando e' finito da dodici
 * mesi, cosi' l'oggetto si scrive una volta e non si riscrive ogni notte.
 *
 * Dentro l'oggetto: `voci` (il contenuto per chiave) e `conversazioni` (i
 * messaggi per chiave di conversazione, nel mese in cui la conversazione e'
 * nata).
 */
export const IL_BUCKET_DELL_ARCHIVIO = "esoteric-circle.firebasestorage.app";
export const LA_CLASSE_DELL_ARCHIVIO = "ARCHIVE";
export const MESI_PRIMA_DELL_ARCHIVIO = 12;

/** Il mese a Roma di un momento, `AAAA-MM`. */
export function ilMeseDi(q: number): string {
  return giornoDi(q).slice(0, 7);
}

/**
 * Il primo mese che NON va ancora in archivio: quello di dodici mesi fa.
 * Il 6 ottobre 2026 e' `2025-10`, quindi si archiviano i mesi fino a
 * settembre 2025 compreso, tutti finiti da piu' di dodici mesi.
 */
export function ilMeseDelConfine(adesso: number): string {
  const [a, m] = ilMeseDi(adesso).split("-").map(Number);
  const indice = a * 12 + (m - 1) - MESI_PRIMA_DELL_ARCHIVIO;
  const anno = Math.floor(indice / 12);
  return `${anno}-${String((indice % 12) + 1).padStart(2, "0")}`;
}

/**
 * Il confine per le query, in millesimi: la mezzanotte UTC del primo giorno
 * del mese del confine. Prende anche le prime ore di quel mese a Roma, che
 * poi [ilMeseDi] rimanda indietro: il confine vero e' sul mese di Roma.
 */
export function ilConfineDellArchivio(adesso: number): number {
  const [a, m] = ilMeseDelConfine(adesso).split("-").map(Number);
  return Date.UTC(a, m - 1, 1);
}

/** Vero se il momento sta in un mese gia' da archiviare. */
export function vaInArchivio(q: number, adesso: number): boolean {
  return ilMeseDi(q) < ilMeseDelConfine(adesso);
}

/** Dove sta in archivio il mese di una persona. */
export function ilPercorsoDelMese(uid: string, mese: string): string {
  return `diario_archivio/${uid}/${mese}.json`;
}

/**
 * Il mese in cui una conversazione sta in archivio: quello della sua
 * nascita, che il suo id porta ("c" e i millesimi); per la prima
 * conversazione, senza marcatura, il mese del messaggio.
 */
export function ilMeseDellaConversazione(
  conversazione: string | null,
  quandoDelMessaggio: number
): string {
  const nata = conversazione && /^c\d{12,}$/.test(conversazione) ?
    Number(conversazione.slice(1)) : quandoDelMessaggio;
  return ilMeseDi(nata);
}

/** Un mese in archivio: il contenuto delle voci e i messaggi. */
export interface MeseInArchivio {
  voci: Record<string, unknown>;
  conversazioni: Record<string, any[]>;
}

/**
 * Unisce cio' che arriva a cio' che il mese aveva gia': le voci per
 * chiave, i messaggi per id, in ordine di tempo. Pura, per le prove.
 */
export function unisciIlMese(
  prima: MeseInArchivio | null,
  voci: Record<string, unknown>,
  conversazioni: Record<string, any[]>
): MeseInArchivio {
  const fuori: MeseInArchivio = {
    voci: {...(prima?.voci ?? {}), ...voci},
    conversazioni: {...(prima?.conversazioni ?? {})},
  };
  for (const [chiave, nuovi] of Object.entries(conversazioni)) {
    const gia = fuori.conversazioni[chiave] ?? [];
    const visti = new Set(gia.map((m) => m.id));
    fuori.conversazioni[chiave] = [
      ...gia, ...nuovi.filter((m) => !visti.has(m.id)),
    ].sort((a, b) => (a.quando ?? 0) - (b.quando ?? 0));
  }
  return fuori;
}

async function scriviInArchivio(percorso: string, dati: unknown): Promise<void> {
  const {getStorage} = await import("firebase-admin/storage");
  await getStorage().bucket(IL_BUCKET_DELL_ARCHIVIO).file(percorso).save(
    JSON.stringify(dati),
    {
      contentType: "application/json",
      resumable: false,
      metadata: {storageClass: LA_CLASSE_DELL_ARCHIVIO},
    }
  );
}

async function leggiDallArchivio(percorso: string): Promise<any | null> {
  const {getStorage} = await import("firebase-admin/storage");
  const file = getStorage().bucket(IL_BUCKET_DELL_ARCHIVIO).file(percorso);
  const [esiste] = await file.exists();
  if (!esiste) return null;
  const [byte] = await file.download();
  return JSON.parse(byte.toString("utf8"));
}

/** Scrive i gruppi di un giro, un oggetto per persona e per mese. */
async function scriviIMesi(
  gruppi: Map<string, {voci: Record<string, unknown>;
    conversazioni: Record<string, any[]>}>
): Promise<void> {
  for (const [percorso, g] of gruppi) {
    const prima = (await leggiDallArchivio(percorso)) as MeseInArchivio | null;
    await scriviInArchivio(percorso, unisciIlMese(prima, g.voci, g.conversazioni));
  }
}

/**
 * Porta in archivio il contenuto delle voci dei mesi finiti da dodici mesi:
 * una pagina per giro (la pulizia notturna lo chiama ogni notte).
 */
export async function archiviaLeVociVecchie(
  adesso: number,
  quante = 200
): Promise<number> {
  const snap = await db().collectionGroup("diario_voci")
    .where("q", "<", ilConfineDellArchivio(adesso)).limit(quante).get();
  const gruppi = new Map<string, {voci: Record<string, unknown>;
    conversazioni: Record<string, any[]>}>();
  const daSegnare: {ref: DocumentReference; dati: any; percorso: string}[] = [];
  for (const d of snap.docs) {
    const dati = d.data();
    if (typeof dati.archiviata === "string") continue;
    if (typeof dati.q !== "number" || !vaInArchivio(dati.q, adesso)) continue;
    const uid = d.ref.parent.parent?.id;
    if (!uid) continue;
    const percorso = ilPercorsoDelMese(uid, ilMeseDi(dati.q));
    const g = gruppi.get(percorso) ?? {voci: {}, conversazioni: {}};
    g.voci[d.id] = dati;
    gruppi.set(percorso, g);
    daSegnare.push({ref: d.ref, dati, percorso});
  }
  // Prima l'archivio, poi l'indice: se l'archivio non risponde, la voce
  // resta piena su Firestore e si riprova la notte dopo.
  await scriviIMesi(gruppi);
  for (const {ref, dati, percorso} of daSegnare) {
    await ref.set({
      v: dati.v ?? 0, k: dati.k ?? null, a: dati.a ?? null,
      m: dati.m ?? null, q: dati.q, archiviata: percorso,
      ...(typeof dati.nota === "string" ? {nota: dati.nota} : {}),
    });
  }
  return daSegnare.length;
}

/**
 * Porta in archivio i messaggi dei mesi finiti da dodici mesi, raggruppati
 * per persona, per mese e per conversazione, e torna i documenti archiviati:
 * la pulizia notturna cancella da Firestore QUELLI, e nessun altro.
 */
export async function archiviaIMessaggi(
  documenti: FirebaseFirestore.QueryDocumentSnapshot[],
  adesso: number
): Promise<FirebaseFirestore.QueryDocumentSnapshot[]> {
  const gruppi = new Map<string, {voci: Record<string, unknown>;
    conversazioni: Record<string, any[]>}>();
  const archiviati: FirebaseFirestore.QueryDocumentSnapshot[] = [];
  for (const d of documenti) {
    // users/{uid}/maestri/{maestro}/messages/{id}
    const maestro = d.ref.parent.parent?.id;
    const uid = d.ref.parent.parent?.parent.parent?.id;
    if (!uid || !maestro) continue;
    const dati = d.data();
    const quando: number | null = dati.createdAt?.toMillis?.() ?? null;
    if (quando === null || !vaInArchivio(quando, adesso)) continue;
    const c = typeof dati.conversazione === "string" ? dati.conversazione : null;
    const chiave = chiaveDellaConversazione(maestro, c);
    const percorso = ilPercorsoDelMese(uid, ilMeseDellaConversazione(c, quando));
    const g = gruppi.get(percorso) ?? {voci: {}, conversazioni: {}};
    (g.conversazioni[chiave] ??= []).push({
      id: d.id, role: dati.role, text: dati.text, autore: dati.autore ?? null,
      conversazione: c, quando,
    });
    gruppi.set(percorso, g);
    archiviati.push(d);
  }
  await scriviIMesi(gruppi);
  return archiviati;
}

/** Legge il contenuto di una voce archiviata dal suo mese. */
async function laVoceInArchivio(percorso: string, chiave: string):
  Promise<any | null> {
  const mese = (await leggiDallArchivio(percorso)) as MeseInArchivio | null;
  return (mese?.voci?.[chiave] as any) ?? null;
}

/**
 * I MESSAGGI DI UNA CONVERSAZIONE IN ARCHIVIO, per riaprirla dal Diario o
 * dal menu' della chat. FE.22.15. Si leggono il mese della nascita e i due
 * dopo (una conversazione che continua oltre il mese della nascita ha i
 * suoi messaggi li'); la prima conversazione, senza marcatura, puo' stare
 * in ogni mese, e si leggono i mesi che la persona ha in archivio.
 */
export const leggiLaConversazioneArchiviata = onCall(OPZIONI, async (request) => {
  const uid = uidDi(request);
  const chiave = chiaveValida(request.data?.chiave);
  if (!chiave.startsWith("conv.")) {
    throw new HttpsError("invalid-argument", "Non e' una conversazione.");
  }
  const id = chiave.slice(chiave.lastIndexOf(".") + 1);
  let percorsi: string[];
  if (/^c\d{12,}$/.test(id)) {
    const nata = ilMeseDi(Number(id.slice(1)));
    const [a, m] = nata.split("-").map(Number);
    percorsi = [0, 1, 2].map((i) => {
      const indice = a * 12 + (m - 1) + i;
      return ilPercorsoDelMese(uid, `${Math.floor(indice / 12)}-` +
        String((indice % 12) + 1).padStart(2, "0"));
    });
  } else {
    const {getStorage} = await import("firebase-admin/storage");
    const [file] = await getStorage().bucket(IL_BUCKET_DELL_ARCHIVIO)
      .getFiles({prefix: `diario_archivio/${uid}/`});
    percorsi = file.map((f) => f.name);
  }
  const messaggi: any[] = [];
  for (const p of percorsi) {
    const mese = (await leggiDallArchivio(p)) as MeseInArchivio | null;
    messaggi.push(...(mese?.conversazioni?.[chiave] ?? []));
  }
  messaggi.sort((a, b) => (a.quando ?? 0) - (b.quando ?? 0));
  return {messaggi};
});

/**
 * I mesi in archivio dove puo' stare una conversazione: quello della nascita
 * e i due dopo per una conversazione marcata ("c" e i millesimi), ogni mese
 * della persona per la prima, senza marcatura. Pura, per le prove.
 */
export function iMesiDellaConversazione(
  chiave: string,
  meseDiOgniOggetto: string[]
): string[] {
  const id = chiave.slice(chiave.lastIndexOf(".") + 1);
  if (!/^c\d{12,}$/.test(id)) return meseDiOgniOggetto;
  const [a, m] = ilMeseDi(Number(id.slice(1))).split("-").map(Number);
  return [0, 1, 2].map((i) => {
    const indice = a * 12 + (m - 1) + i;
    return `${Math.floor(indice / 12)}-` +
      String((indice % 12) + 1).padStart(2, "0");
  });
}

/** Il mese senza quella conversazione. Pura, per le prove. */
export function senzaLaConversazione(
  mese: MeseInArchivio,
  chiave: string
): MeseInArchivio {
  const conversazioni = {...mese.conversazioni};
  delete conversazioni[chiave];
  return {voci: {...mese.voci}, conversazioni};
}

/**
 * **IL CESTINO ARRIVA ANCHE ALL'ARCHIVIO. Ordine FE voce 22.17.** Prima il
 * cestino toglieva la riga del Diario e il contenuto su Firestore, e i
 * messaggi gia' passati nell'archivio restavano nell'oggetto del mese (padre
 * FE.22.15, commit 693a68d6 e bc10833f). Adesso si riscrivono senza quella
 * conversazione i mesi che la contengono, e un mese rimasto vuoto si
 * cancella. Torna quanti mesi ha toccato.
 */
export async function togliLaConversazioneDallArchivio(
  uid: string,
  chiave: string
): Promise<number> {
  const {getStorage} = await import("firebase-admin/storage");
  const bucket = getStorage().bucket(IL_BUCKET_DELL_ARCHIVIO);
  const [file] = await bucket.getFiles({prefix: `diario_archivio/${uid}/`});
  const tutti = file.map((f) => f.name.slice(f.name.lastIndexOf("/") + 1)
    .replace(/\.json$/, ""));
  let toccati = 0;
  for (const mese of iMesiDellaConversazione(chiave, tutti)) {
    if (!tutti.includes(mese)) continue;
    const percorso = ilPercorsoDelMese(uid, mese);
    const letto = (await leggiDallArchivio(percorso)) as MeseInArchivio | null;
    if (!letto?.conversazioni?.[chiave]) continue;
    const dopo = senzaLaConversazione(letto, chiave);
    if (Object.keys(dopo.voci).length === 0 &&
        Object.keys(dopo.conversazioni).length === 0) {
      await bucket.file(percorso).delete({ignoreNotFound: true});
    } else {
      await scriviInArchivio(percorso, dopo);
    }
    toccati++;
  }
  return toccati;
}

/**
 * **CHI CANCELLA I SUOI DATI CANCELLA ANCHE L'ARCHIVIO.** Ordine FE voce
 * 22.15. L'azzeramento dei dati e la cancellazione dell'account toglievano
 * il ramo su Firestore e lasciavano in Cloud Storage i mesi archiviati
 * (padre FE.22.15, commit 693a68d6 e bc10833f): adesso li tolgono tutti.
 * La classe Archive fa pagare i giorni che mancano ai 365 a chi cancella
 * prima: e' il prezzo di una cancellazione vera, ed e' minimo.
 */
export async function cancellaLArchivio(uid: string): Promise<void> {
  const {getStorage} = await import("firebase-admin/storage");
  await getStorage().bucket(IL_BUCKET_DELL_ARCHIVIO)
    .deleteFiles({prefix: `diario_archivio/${uid}/`});
}
