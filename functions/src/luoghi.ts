/**
 * LA RICERCA DEL LUOGO NEL MONDO INTERO. Ordine DR voce 10.
 *
 * **Il fatto del fondatore**: le frazioni e i paesi piccoli non si trovano, e
 * la prova che decide e' "Borgo di Rivalta". Misurato: quel nome **non esiste
 * in GeoNames a nessuna soglia di abitanti**, perche' GeoNames quella
 * localita' non ce l'ha proprio. Abbassare la soglia del catalogo offline
 * sarebbe stato pesare l'app di otto megabyte per non trovarlo lo stesso: la
 * leva non era la soglia, era la fonte, ed e' la decisione del fondatore del
 * 16 settembre 2026, verbatim: *"devi cambiare fonte a Openstreetmap, ci deve
 * essere tutto il mondo perche' un'utente potrebbe vivere ovunque"*.
 *
 * **Perche' non un asset piu' grande.** L'unico dump di GeoNames che contiene
 * ogni cosa, `allCountries.zip`, pesa 421.682.512 byte compresso: non e' un
 * file che si mette dentro un'app. Il mondo intero si puo' solo chiedere.
 *
 * **Perche' passa di qui e non dal telefono.** Verso OpenStreetMap ci si
 * presenta con **una identita' sola**, non con un telefono per persona; i
 * risultati si mettono da parte una volta per tutti invece che una volta per
 * ciascuno; e il giorno che servisse un fornitore con una chiave, la chiave
 * sta nel server e non dentro un'app che vive su un repository pubblico. E'
 * la stessa forma del ponte verso il motore astrologico.
 *
 * Questo file non importa niente di Firebase, cosi' si prova con `node --test`
 * senza accendere nessun emulatore: qui stanno la validazione, la chiamata e
 * la traduzione della risposta, e in `index.ts` resta solo la porta.
 */

/** Il motivo per cui una domanda non passa, in italiano, per il messaggio. */
export class LuogoNonValido extends Error {}

/** Un luogo trovato nel mondo, nella forma che l'app si aspetta. */
export interface LuogoDelMondo {
  /** Il nome da mostrare, il piu' corto che identifichi il posto. */
  nome: string;
  /** L'area che distingue gli omonimi: provincia, regione o nazione. */
  area: string;
  /** L'indirizzo per esteso, per chi deve scegliere fra due somiglianti. */
  perEsteso: string;
  latitudine: number;
  longitudine: number;
}

/**
 * IL TETTO DELLA DOMANDA.
 *
 * Non e' un capriccio: dall'altra parte c'e' un servizio pubblico e gratuito,
 * e una domanda lunga e' una domanda che qualcuno sta usando per altro.
 */
export const LUNGHEZZA_MASSIMA = 120;

/**
 * IL PAVIMENTO.
 *
 * Sotto le tre lettere il catalogo offline risponde gia', e una domanda di due
 * lettere al mondo intero torna con mezzo pianeta: non serve a chi cerca e
 * costa a chi risponde.
 */
export const LUNGHEZZA_MINIMA = 3;

/** Quanti risultati si chiedono, e quanti se ne mostrano. */
export const QUANTI = 6;

/**
 * La domanda, ricostruita invece che filtrata: cio' che parte verso
 * OpenStreetMap e' solo quello che questa funzione ha scritto.
 */
export function validaLaDomanda(grezza: unknown): string {
  if (typeof grezza !== "object" || grezza === null) {
    throw new LuogoNonValido("La domanda non e' un oggetto.");
  }
  const q = (grezza as Record<string, unknown>).query;
  if (typeof q !== "string") {
    throw new LuogoNonValido("Manca il nome del luogo da cercare.");
  }
  // **I CARATTERI DI CONTROLLO SI GUARDANO PRIMA**, e questa riga l'ha
  // scritta una prova caduta. Ridurre gli spazi trasforma un a capo in uno
  // spazio, quindi "roma\nborgo" diventava "roma borgo" e passava il
  // controllo sui caratteri **senza che nessuno lo vedesse**: cio' che il
  // controllo doveva fermare era gia' sparito quando il controllo arrivava.
  // Un nome di luogo non contiene caratteri di controllo, mai.
  if (/[\u0000-\u001f\u007f]/.test(q)) {
    throw new LuogoNonValido("Il nome contiene caratteri che un luogo non ha.");
  }
  // Gli spazi in mezzo si riducono a uno: "  borgo   di rivalta " e
  // "borgo di rivalta" sono la stessa domanda, e devono trovare la stessa
  // risposta gia' messa da parte.
  const pulita = q.trim().replace(/\s+/g, " ");
  if (pulita.length < LUNGHEZZA_MINIMA) {
    throw new LuogoNonValido(
      `Il nome da cercare vuole almeno ${LUNGHEZZA_MINIMA} lettere.`);
  }
  if (pulita.length > LUNGHEZZA_MASSIMA) {
    throw new LuogoNonValido(
      `Il nome da cercare supera ${LUNGHEZZA_MASSIMA} caratteri.`);
  }
  // **NIENTE CHE NON SIA UN NOME DI LUOGO.** I nomi veri hanno lettere,
  // cifre, spazi, apostrofi, trattini, punti e virgole. Tutto il resto non
  // serve a cercare un paese e serve a provare qualcos'altro.
  if (!/^[\p{L}\p{N} '’.,()\-/]+$/u.test(pulita)) {
    throw new LuogoNonValido("Il nome contiene caratteri che un luogo non ha.");
  }
  return pulita;
}

/**
 * LA CHIAVE CON CUI IL RISULTATO SI RITROVA.
 *
 * Minuscole e accenti tolti, cosi' "Cefalù" e "cefalu" non fanno due
 * chiamate. Il documento di Firestore vuole una chiave senza barre.
 */
export function chiaveDellaDomanda(pulita: string): string {
  return pulita
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 100);
}

/**
 * COME CI SI PRESENTA A OPENSTREETMAP.
 *
 * La loro regola d'uso chiede un'intestazione che dica chi sta chiamando e
 * come lo si raggiunge. Un'applicazione che non si presenta viene bloccata, ed
 * e' giusto: il servizio e' gratuito e lo tiene in piedi una fondazione.
 */
export const COME_CI_PRESENTIAMO =
  "EsotericCircle/1.0 (https://esotericircle.com; cloud@esotericircle.app)";

/** L'indirizzo del servizio, in una costante sola: qui si cambia fornitore. */
export const BASE_DI_OPENSTREETMAP = "https://nominatim.openstreetmap.org";

/** L'indirizzo completo della domanda, nella lingua di chi usa l'app. */
export function indirizzoDellaDomanda(pulita: string): string {
  const p = new URLSearchParams({
    q: pulita,
    format: "jsonv2",
    limit: String(QUANTI),
    addressdetails: "1",
    "accept-language": "it",
  });
  return `${BASE_DI_OPENSTREETMAP}/search?${p.toString()}`;
}

/** Una riga come la scrive Nominatim, nei soli campi che si leggono. */
interface RigaDiNominatim {
  name?: unknown;
  display_name?: unknown;
  lat?: unknown;
  lon?: unknown;
  address?: Record<string, unknown>;
}

/** Il primo campo presente fra quelli nominati, come stringa non vuota. */
function primo(
  a: Record<string, unknown> | undefined, chiavi: string[]): string {
  if (!a) return "";
  for (const k of chiavi) {
    const v = a[k];
    if (typeof v === "string" && v.trim() !== "") return v.trim();
  }
  return "";
}

/**
 * LA TRADUZIONE, ed e' la parte dove si decide cosa legge una persona.
 *
 * Nominatim risponde con un indirizzo lungo: *"Loc. Borgo di Rivalta, Rivalta
 * Trebbia, Gazzola, Piacenza, Emilia-Romagna, 29010, Italia"*. Mostrarlo tutto
 * in un elenco di suggerimenti vuol dire non far leggere niente a nessuno.
 * Qui si tiene il **nome** e l'**area** che distingue gli omonimi, con
 * l'indirizzo per esteso sotto per chi deve scegliere fra due somiglianti: e'
 * la stessa forma che ha il catalogo offline, cosi' le due sorgenti si
 * mescolano in un elenco solo senza che si veda la cucitura.
 */
export function traduci(righe: unknown): LuogoDelMondo[] {
  if (!Array.isArray(righe)) return [];
  const fatti: LuogoDelMondo[] = [];
  const visti = new Set<string>();
  for (const grezza of righe) {
    if (typeof grezza !== "object" || grezza === null) continue;
    const r = grezza as RigaDiNominatim;
    const lat = Number(r.lat);
    const lon = Number(r.lon);
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) continue;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
    const perEsteso =
      typeof r.display_name === "string" ? r.display_name : "";
    const nome = (typeof r.name === "string" && r.name.trim() !== "") ?
      r.name.trim() :
      perEsteso.split(",")[0].trim();
    if (nome === "") continue;
    const area = primo(r.address, [
      "county", "state_district", "province", "state", "region", "country",
    ]) || primo(r.address, ["country"]);
    // **I DOPPIONI SI TOLGONO QUI**, perche' OpenStreetMap conosce i luoghi
    // per oggetti e non per nomi: "Loc. Borgo di Rivalta" torna tre volte, una
    // per ogni edificio che porta quel nome. Tre righe identiche in un elenco
    // non sono tre scelte, sono una scelta scritta male.
    const impronta = `${nome.toLowerCase()}|${area.toLowerCase()}`;
    if (visti.has(impronta)) continue;
    visti.add(impronta);
    fatti.push({
      nome,
      area,
      perEsteso,
      latitudine: lat,
      longitudine: lon,
    });
    if (fatti.length >= QUANTI) break;
  }
  return fatti;
}
