import {test} from "node:test";
import assert from "node:assert/strict";

import {
  LUNGHEZZA_MASSIMA,
  LUNGHEZZA_MINIMA,
  LuogoNonValido,
  QUANTI,
  chiaveDellaDomanda,
  indirizzoDellaDomanda,
  traduci,
  validaLaDomanda,
  COME_CI_PRESENTIAMO,
} from "./luoghi";

/**
 * LE GUARDIE DELLA RICERCA NEL MONDO. Ordine DR voce 10.
 *
 * Girano nella seconda suite, quella del server, che fino al 16 settembre
 * 2026 non era mai stata eseguita su nessuna macchina di build: adesso lo e',
 * ed e' la ragione per cui queste prove hanno senso qui.
 */

test("la domanda si ricostruisce, e gli spazi in mezzo non contano", () => {
  assert.equal(validaLaDomanda({query: "  borgo   di rivalta "}),
    "borgo di rivalta");
  assert.equal(validaLaDomanda({query: "Roma"}), "Roma");
});

test("una domanda troppo corta non parte verso il mondo", () => {
  assert.throws(() => validaLaDomanda({query: "ro"}), LuogoNonValido);
  assert.throws(() => validaLaDomanda({query: "  "}), LuogoNonValido);
  // Tre lettere e' il pavimento dichiarato, e deve passare.
  assert.equal(validaLaDomanda({query: "rom"}).length, LUNGHEZZA_MINIMA);
});

test("una domanda lunghissima non passa", () => {
  const troppo = "a".repeat(LUNGHEZZA_MASSIMA + 1);
  assert.throws(() => validaLaDomanda({query: troppo}), LuogoNonValido);
});

test("cio' che un nome di luogo non ha, non passa", () => {
  for (const cattiva of [
    "roma<script>", "roma\nborgo", "roma&q=altro", "roma|ls", "roma{}",
  ]) {
    assert.throws(() => validaLaDomanda({query: cattiva}), LuogoNonValido,
      `sarebbe dovuta cadere: ${cattiva}`);
  }
});

test("i nomi veri con apostrofi, accenti e trattini passano", () => {
  for (const buona of [
    "L'Aquila", "Cefalù", "Reggio nell'Emilia", "Sant'Angelo in Vado",
    "Vaux-sur-Seine", "Frankfurt (Oder)", "Bagno a Ripoli",
  ]) {
    assert.equal(validaLaDomanda({query: buona}), buona);
  }
});

test("un corpo che non e' un oggetto non porta niente dentro", () => {
  for (const niente of [null, 42, "roma", [], undefined]) {
    assert.throws(() => validaLaDomanda(niente), LuogoNonValido);
  }
});

test("la chiave ritrova la stessa domanda scritta in un altro modo", () => {
  const a = chiaveDellaDomanda(validaLaDomanda({query: "Cefalù"}));
  const b = chiaveDellaDomanda(validaLaDomanda({query: "  cefalu  "}));
  assert.equal(a, b);
  assert.equal(a, "cefalu");
  // **E LA CHIAVE NON PUO' CONTENERE UNA BARRA**, o non sarebbe un documento
  // solo: sarebbe una collezione dentro un'altra.
  const strana = chiaveDellaDomanda("Reggio nell'Emilia / RE");
  assert.ok(!strana.includes("/"), strana);
  assert.ok(strana.length > 0);
});

test("l'indirizzo della domanda porta il nome e non porta altro", () => {
  const url = new URL(indirizzoDellaDomanda("borgo di rivalta"));
  assert.equal(url.hostname, "nominatim.openstreetmap.org");
  assert.equal(url.searchParams.get("q"), "borgo di rivalta");
  assert.equal(url.searchParams.get("limit"), String(QUANTI));
  assert.equal(url.searchParams.get("accept-language"), "it");
});

test("ci si presenta con un nome e un recapito", () => {
  assert.ok(COME_CI_PRESENTIAMO.includes("EsotericCircle"));
  assert.ok(/@|https?:/.test(COME_CI_PRESENTIAMO),
    "la regola d'uso di OpenStreetMap vuole un modo per raggiungerci");
});

/**
 * LA RISPOSTA VERA, presa il 16 settembre 2026 da
 * `nominatim.openstreetmap.org/search?q=Borgo+di+Rivalta`, ridotta ai campi
 * che si leggono. **Non e' inventata**: e' la prova che decide dell'ordine.
 */
const RISPOSTA_VERA = [
  {
    name: "Loc. Borgo di Rivalta",
    display_name: "Loc. Borgo di Rivalta, Rivalta Trebbia, Gazzola, " +
      "Piacenza, Emilia-Romagna, 29010, Italia",
    lat: "44.9502818",
    lon: "9.5909568",
    address: {
      county: "Piacenza",
      state: "Emilia-Romagna",
      country: "Italia",
    },
  },
  {
    name: "Loc. Borgo di Rivalta",
    display_name: "Loc. Borgo di Rivalta, Rivalta Trebbia, Gazzola, " +
      "Piacenza, Emilia-Romagna, 29010, Italia",
    lat: "44.949883",
    lon: "9.5898841",
    address: {county: "Piacenza", country: "Italia"},
  },
  {
    name: "Castello di Rivalta",
    display_name: "Castello di Rivalta, Gazzola, Piacenza, Italia",
    lat: "44.9508787",
    lon: "9.5907907",
    address: {county: "Piacenza", country: "Italia"},
  },
];

test("BORGO DI RIVALTA SI TROVA, ed e' la prova che decide", () => {
  const fatti = traduci(RISPOSTA_VERA);
  const trovato = fatti.find((l) => l.nome === "Loc. Borgo di Rivalta");
  assert.ok(trovato, "il luogo che i fondatori non trovavano non si trova");
  assert.equal(trovato.area, "Piacenza");
  assert.ok(Math.abs(trovato.latitudine - 44.9502818) < 1e-6);
  assert.ok(Math.abs(trovato.longitudine - 9.5909568) < 1e-6);
  assert.ok(trovato.perEsteso.includes("Gazzola"),
    "l'indirizzo per esteso serve a distinguere due somiglianti");
});

test("I DOPPIONI NON ARRIVANO ALL'ELENCO", () => {
  // OpenStreetMap conosce i luoghi per oggetti: lo stesso nome torna una
  // volta per ogni edificio che lo porta. Tre righe identiche in un elenco
  // non sono tre scelte.
  const fatti = traduci(RISPOSTA_VERA);
  const nomi = fatti.map((l) => `${l.nome}|${l.area}`);
  assert.equal(new Set(nomi).size, nomi.length, `doppioni: ${nomi}`);
  assert.equal(fatti.length, 2, "restano il borgo e il castello");
});

test("una riga senza coordinate valide non entra", () => {
  const fatti = traduci([
    {name: "Senza", display_name: "Senza", lat: "niente", lon: "9"},
    {name: "Fuori", display_name: "Fuori", lat: "91", lon: "9"},
    {name: "Fuori2", display_name: "Fuori2", lat: "10", lon: "181"},
    {name: "", display_name: "", lat: "10", lon: "10"},
    null,
    "roba",
  ]);
  assert.deepEqual(fatti, []);
});

test("cio' che non e' un elenco non fa cadere niente", () => {
  assert.deepEqual(traduci(null), []);
  assert.deepEqual(traduci({}), []);
  assert.deepEqual(traduci("errore"), []);
});

test("l'elenco non supera mai il tetto dichiarato", () => {
  const tante = Array.from({length: 40}, (_, i) => ({
    name: `Posto ${i}`,
    display_name: `Posto ${i}, Nazione`,
    lat: "45",
    lon: "9",
    address: {country: "Italia"},
  }));
  assert.equal(traduci(tante).length, QUANTI);
});

test("quando il nome manca si prende il primo pezzo dell'indirizzo", () => {
  const fatti = traduci([
    {
      display_name: "Rivalta Trebbia, Gazzola, Piacenza, Italia",
      lat: "44.95",
      lon: "9.59",
      address: {county: "Piacenza"},
    },
  ]);
  assert.equal(fatti.length, 1);
  assert.equal(fatti[0].nome, "Rivalta Trebbia");
});
