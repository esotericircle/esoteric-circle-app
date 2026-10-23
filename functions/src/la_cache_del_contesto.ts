/**
 * LA CACHE DEL CONTESTO, CHE SI ACCENDE SOPRA LA SOGLIA E SI SPEGNE SOTTO.
 * Ordine EX Aggiunta 4, voce EX.05, 2 ottobre 2026.
 *
 * Il fondatore: *"una cache garantita che si accende sopra la soglia e si
 * spegne sotto, senza costi fissi quando non serve. La soglia la calcola
 * Code e la dichiara."*
 *
 * **La cache garantita e' quella esplicita di Vertex** (CachedContent):
 * l'inizio dell'istruzione della chat, uguale per tutte le persone che
 * parlano con lo stesso Maestro (la voce, le regole di lingua, la misura, la
 * forma, i due strati, il consiglio finale), si tiene in cache e si paga al
 * 10 per cento. La cache implicita c'e' gia', ma non e' garantita: con
 * richieste a dieci minuti l'una dall'altra prendeva da 0 a 65 per cento
 * (`docs/collaudo/EX/la_cache.txt`).
 *
 * **Le varianti sono sei**: i tre Maestri, nella chat col seguito e senza.
 * Il LIVE resta sulla via di sempre: risponde a flusso, e il template della
 * cache non scrive a flusso la risposta che si mostra mentre arriva.
 *
 * **La soglia, calcolata.** Ogni variante tiene in cache circa 4.820 token
 * (la parte comune misurata dall'ordine EX voce 05); sei varianti fanno
 * 28.920 token, che a 1 dollaro al milione di token all'ora costano 0,0289
 * dollari all'ora. Ogni richiesta che li prende dalla cache risparmia 4.820
 * token al 90 per cento di 0,30 dollari al milione, cioe' 0,0013 dollari. Il
 * pareggio e' a 0,0289 / 0,0013 = 22,2 richieste all'ora: la cache si
 * accende a **23 richieste all'ora** e si spegne sotto **18**, il 20 per
 * cento piu' in basso, perche' un traffico che oscilla intorno alla soglia
 * non la faccia accendere e spegnere a ogni giro (ogni accensione costa la
 * scrittura delle sei cache, 28.920 token a prezzo pieno). L'ordine diceva
 * "circa 33": era il conto con nove varianti, LIVE compreso.
 *
 * **Le richieste si contano dai messaggi.** Il conto e' quello dei messaggi
 * della chat salvati nell'ultima ora (gruppo `messages`, campo `createdAt`,
 * l'indice c'e' gia'), diviso per due: una domanda e una risposta. Un
 * conteggio di Firestore costa una lettura ogni mille voci dell'indice. Il
 * conto comprende anche i messaggi del LIVE, che la cache non usa: sbaglia
 * per eccesso, e la cache si accende un poco prima del pareggio.
 *
 * **Spenta, non costa niente.** Le cache nascono con venti minuti di vita e
 * il giro ogni dieci minuti le rinnova finche' la cache e' accesa; spenta,
 * il giro non le rinnova e scadono da sole. Se la funzione si fermasse,
 * scadrebbero lo stesso: nessun costo fisso resta acceso per sbaglio.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {applicationDefault} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {readFileSync} from "node:fs";
import {join} from "node:path";

/** I token di una variante in cache, misurati (`docs/collaudo/EX/la_cache.txt`). */
export const TOKEN_PER_VARIANTE = 4820;

/** Le varianti: tre Maestri, chat col seguito e senza. */
export const VARIANTI = 6;

/** Prezzi di Vertex in europe-west1 per gemini-2.5-flash, dollari. */
export const PREZZO_INGRESSO_AL_MILIONE = 0.30;
export const SCONTO_DELLA_CACHE = 0.90;
export const CONSERVAZIONE_AL_MILIONE_ALL_ORA = 1.0;

/** Il costo all'ora della cache accesa, tutte le varianti. */
export function costoDellaCacheAllOra(): number {
  return (VARIANTI * TOKEN_PER_VARIANTE * CONSERVAZIONE_AL_MILIONE_ALL_ORA) /
    1e6;
}

/** Il risparmio di una richiesta che prende l'inizio dalla cache. */
export function risparmioPerRichiesta(): number {
  return (TOKEN_PER_VARIANTE * PREZZO_INGRESSO_AL_MILIONE * SCONTO_DELLA_CACHE) /
    1e6;
}

/** Il pareggio, in richieste all'ora: 22,2. */
export function pareggio(): number {
  return costoDellaCacheAllOra() / risparmioPerRichiesta();
}

/** Sopra questa la cache si accende: il pareggio, arrotondato in su. */
export const SOGLIA_DI_ACCENSIONE = Math.ceil(pareggio());

/** Sotto questa si spegne: il 20 per cento piu' in basso. */
export const SOGLIA_DI_SPEGNIMENTO = Math.floor(SOGLIA_DI_ACCENSIONE * 0.8);

/**
 * La decisione, pura: con [richiesteNellUltimaOra] e lo stato di adesso,
 * se la cache resta, si accende o si spegne.
 */
export function decidi(
  richiesteNellUltimaOra: number,
  accesa: boolean
): boolean {
  if (accesa) return richiesteNellUltimaOra >= SOGLIA_DI_SPEGNIMENTO;
  return richiesteNellUltimaOra >= SOGLIA_DI_ACCENSIONE;
}

/**
 * Il costo al mese (730 ore) dell'inizio dell'istruzione, con [richiesteAllOra]
 * costanti: senza cache tutto a prezzo pieno; con la cache, il 10 per cento
 * piu' la conservazione; con l'interruttore, la cache solo se conviene.
 */
export function costoAlMese(
  richiesteAllOra: number,
  modo: "senza" | "sempre" | "interruttore"
): number {
  const ore = 730;
  const pieno =
    (richiesteAllOra * ore * TOKEN_PER_VARIANTE * PREZZO_INGRESSO_AL_MILIONE) /
    1e6;
  const conCache =
    pieno * (1 - SCONTO_DELLA_CACHE) + costoDellaCacheAllOra() * ore;
  if (modo === "senza") return pieno;
  if (modo === "sempre") return conCache;
  return decidi(richiesteAllOra, false) ? conCache : pieno;
}

/** La vita di una cache: venti minuti, il doppio del giro. */
export const VITA_DELLA_CACHE_SECONDI = 1200;

/**
 * Il documento che il telefono legge: `configurazione/cache`. La regola di
 * Firestore lo lascia leggere a chi ha l'accesso e non scrivere a nessuno;
 * lo scrive solo questa funzione.
 */
export const DOCUMENTO = "configurazione/cache";

const REGIONE = "europe-west1";
const PROGETTO = "esoteric-circle";
const MODELLO = "gemini-2.5-flash";

/** Le varianti e il loro inizio d'istruzione, scritti dall'app. */
interface IPrefissi {
  impronta: string;
  varianti: Record<string, string>;
}

function prefissi(): IPrefissi {
  return JSON.parse(
    readFileSync(join(__dirname, "..", "src", "la_cache_prefissi.json"), "utf8")
  ) as IPrefissi;
}

async function gettone(): Promise<string> {
  const c = await applicationDefault().getAccessToken();
  return c.access_token;
}

const BASE = `https://${REGIONE}-aiplatform.googleapis.com/v1beta1/projects/` +
  `${PROGETTO}/locations/${REGIONE}`;

/** Crea la cache di una variante; torna il suo nome. */
async function creaLaCache(variante: string, testo: string): Promise<string> {
  const r = await fetch(`${BASE}/cachedContents`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${await gettone()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: `projects/${PROGETTO}/locations/${REGIONE}/publishers/google/` +
        `models/${MODELLO}`,
      displayName: `maestro-${variante}`,
      systemInstruction: {parts: [{text: testo}]},
      ttl: `${VITA_DELLA_CACHE_SECONDI}s`,
    }),
  });
  if (!r.ok) throw new Error(`cache ${variante}: ${r.status} ${await r.text()}`);
  return ((await r.json()) as {name: string}).name;
}

/** Allunga la vita di una cache; falso se non c'e' piu'. */
async function rinnova(nome: string): Promise<boolean> {
  const r = await fetch(`https://${REGIONE}-aiplatform.googleapis.com/v1beta1/` +
    `${nome}?updateMask=ttl`, {
    method: "PATCH",
    headers: {
      "Authorization": `Bearer ${await gettone()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ttl: `${VITA_DELLA_CACHE_SECONDI}s`}),
  });
  return r.ok;
}

/** Lo stato pubblicato per il telefono. */
export interface IStatoDellaCache {
  accesa: boolean;
  impronta?: string;
  cache?: Record<string, string>;
  scade?: string;
}

async function leggiLoStato(): Promise<IStatoDellaCache> {
  const d = await getFirestore().doc(DOCUMENTO).get();
  return (d.data() as IStatoDellaCache | undefined) ?? {accesa: false};
}

async function pubblica(stato: IStatoDellaCache): Promise<void> {
  await getFirestore().doc(DOCUMENTO).set(stato);
}

/** Le richieste della chat nell'ultima ora: i messaggi diviso due. */
async function richiesteNellUltimaOra(adesso: number): Promise<number> {
  const da = Timestamp.fromMillis(adesso - 3600 * 1000);
  const c = await getFirestore()
    .collectionGroup("messages")
    .where("createdAt", ">=", da)
    .count()
    .get();
  return Math.round(c.data().count / 2);
}

export const laCacheDelContesto = onSchedule(
  {
    schedule: "every 10 minutes",
    timeZone: "Europe/Rome",
    region: REGIONE,
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const adesso = Date.now();
    const richieste = await richiesteNellUltimaOra(adesso);
    const prima = await leggiLoStato();
    const accesa = decidi(richieste, prima.accesa);
    if (!accesa) {
      if (prima.accesa) await pubblica({accesa: false});
      logger.info("laCacheDelContesto: spenta", {richieste, prima: prima.accesa});
      return;
    }
    const p = prefissi();
    const cache: Record<string, string> = {};
    for (const [variante, testo] of Object.entries(p.varianti)) {
      const vecchia = prima.impronta === p.impronta ?
        prima.cache?.[variante] :
        undefined;
      cache[variante] = vecchia && (await rinnova(vecchia)) ?
        vecchia :
        await creaLaCache(variante, testo);
    }
    await pubblica({
      accesa: true,
      impronta: p.impronta,
      cache,
      scade: new Date(adesso + VITA_DELLA_CACHE_SECONDI * 1000).toISOString(),
    });
    logger.info("laCacheDelContesto: accesa", {richieste});
  }
);
