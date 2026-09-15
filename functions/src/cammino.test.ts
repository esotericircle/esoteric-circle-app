import {test} from "node:test";
import assert from "node:assert/strict";
import {
  CamminoCustodito,
  VERSIONE_DEL_CAMMINO,
  fondiCammini,
  leggiCammino,
} from "./cammino";

/**
 * IL CAMMINO CUSTODITO E LA SUA FUSIONE. Ordine AP voci 01 e 03.
 *
 * **Cosa provano queste righe, e perche' senza database.** La fusione e' la
 * regola che decide cosa resta di una persona quando il telefono e il Cerchio
 * dicono due cose diverse: e' la parte che, sbagliata, cancella una storia.
 * Va provata da sola, sui dati, senza emulatori di mezzo. Si eseguono con
 * `npm test` dentro functions/.
 */

const vuoto: CamminoCustodito = {};

test("la lettura tiene solo cio' che ha senso", () => {
  const letto = leggiCammino({
    identita: {nome: "Sofia", giorno: "1990-04-12", ora: "07:30"},
    gesti: {stesa: 3, gettata: "molte", rune: -2},
    sigilli: {med_1: "2026-08-01T10:00:00.000", rotto: 42},
    artiPreferite: ["horoscope", "tarot_spread_three", 7],
    archetipo: {dominante: "mago", quando: "2026-05-01T09:00:00.000"},
  });
  assert.equal(letto.identita?.nome, "Sofia");
  assert.deepEqual(letto.gesti, {stesa: 3});
  assert.deepEqual(letto.sigilli, {med_1: "2026-08-01T10:00:00.000"});
  assert.deepEqual(letto.artiPreferite, ["horoscope", "tarot_spread_three"]);
  assert.equal(letto.archetipo?.dominante, "mago");
});

test("una richiesta che non e' un oggetto non porta niente dentro", () => {
  assert.deepEqual(leggiCammino(null), {});
  assert.deepEqual(leggiCammino("tutto il cammino"), {});
  assert.deepEqual(leggiCammino(42), {});
});

test("CASO 1, telefono pieno e server vuoto: non si perde niente", () => {
  const telefono: CamminoCustodito = {
    identita: {nome: "Sofia", giorno: "1990-04-12"},
    gesti: {stesa: 5, gettata: 2},
    sigilli: {med_1: "2026-08-01T10:00:00.000"},
    primoGiorno: "2026-07-01T08:00:00.000",
  };
  const fuso = fondiCammini(vuoto, telefono);
  assert.equal(fuso.identita?.nome, "Sofia");
  assert.deepEqual(fuso.gesti, {stesa: 5, gettata: 2});
  assert.deepEqual(fuso.sigilli, {med_1: "2026-08-01T10:00:00.000"});
  assert.equal(fuso.primoGiorno, "2026-07-01T08:00:00.000");
  assert.equal(fuso.versione, VERSIONE_DEL_CAMMINO);
});

test("CASO 2, telefono vuoto e server pieno: il telefono nuovo riceve tutto", () => {
  // E' il caso di Mauro: disinstalla, reinstalla, rientra con lo stesso
  // account. Il telefono non sa niente e il Cerchio sa tutto.
  const server: CamminoCustodito = {
    identita: {nome: "Sofia", giorno: "1990-04-12", ora: "07:30"},
    gesti: {stesa: 9},
    sigilli: {med_1: "2026-08-01T10:00:00.000", cal_1: "2026-08-03T21:00:00.000"},
    archetipo: {dominante: "mago", quando: "2026-05-01T09:00:00.000"},
    artiPreferite: ["horoscope"],
  };
  const fuso = fondiCammini(server, vuoto);
  assert.deepEqual(fuso.gesti, {stesa: 9});
  assert.equal(Object.keys(fuso.sigilli ?? {}).length, 2);
  assert.equal(fuso.identita?.ora, "07:30");
  assert.equal(fuso.archetipo?.quando, "2026-05-01T09:00:00.000");
  assert.deepEqual(fuso.artiPreferite, ["horoscope"]);
});

test("CASO 3, i due diversi: vince il piu' alto e nessun Sigillo sparisce", () => {
  const server: CamminoCustodito = {
    gesti: {stesa: 9, gettata: 1},
    giorni: {stesa: 4},
    sigilli: {med_1: "2026-08-01T10:00:00.000", cal_1: "2026-08-03T21:00:00.000"},
    primoGiorno: "2026-06-01T08:00:00.000",
    ultimoGiorno: "2026-08-03T21:00:00.000",
  };
  const telefono: CamminoCustodito = {
    gesti: {stesa: 3, gettata: 7, oroscopo: 2},
    giorni: {stesa: 6},
    sigilli: {med_1: "2026-07-20T09:00:00.000", aur_1: "2026-08-10T07:00:00.000"},
    primoGiorno: "2026-07-01T08:00:00.000",
    ultimoGiorno: "2026-08-12T22:00:00.000",
  };
  const fuso = fondiCammini(server, telefono);

  // Per ogni contatore vince il piu' alto, chiave per chiave e non a blocchi.
  assert.deepEqual(fuso.gesti, {stesa: 9, gettata: 7, oroscopo: 2});
  assert.deepEqual(fuso.giorni, {stesa: 6});

  // I Sigilli si uniscono, e per quelli in comune resta la data PIU' VECCHIA,
  // perche' un Sigillo si accende una volta sola e quel giorno e' un primato.
  assert.equal(Object.keys(fuso.sigilli ?? {}).length, 3);
  assert.equal(fuso.sigilli?.med_1, "2026-07-20T09:00:00.000");
  assert.equal(fuso.sigilli?.aur_1, "2026-08-10T07:00:00.000");

  // Il primo giorno e' il piu' vecchio, l'ultimo il piu' recente.
  assert.equal(fuso.primoGiorno, "2026-06-01T08:00:00.000");
  assert.equal(fuso.ultimoGiorno, "2026-08-12T22:00:00.000");
});

test("NESSUNA STORIA SI CANCELLA: fondere non toglie mai una chiave", () => {
  // **La lezione della voce AO.04, scritta come prova.** Li' un conto povero
  // scritto sopra una storia ricca aveva azzerato il cammino. Qui si prova
  // l'opposto in generale: qualunque coppia si fonda, ogni chiave presente
  // in uno dei due si ritrova nel risultato, e nessun valore scende.
  const server: CamminoCustodito = {gesti: {a: 5, b: 1}, sigilli: {s1: "2026-01-01"}};
  const telefono: CamminoCustodito = {gesti: {b: 9, c: 2}, sigilli: {s2: "2026-02-02"}};
  const fuso = fondiCammini(server, telefono);
  for (const [chiave, valore] of Object.entries(server.gesti ?? {})) {
    assert.ok((fuso.gesti?.[chiave] ?? 0) >= valore, `${chiave} e' sceso`);
  }
  for (const [chiave, valore] of Object.entries(telefono.gesti ?? {})) {
    assert.ok((fuso.gesti?.[chiave] ?? 0) >= valore, `${chiave} e' sceso`);
  }
  assert.ok(fuso.sigilli?.s1);
  assert.ok(fuso.sigilli?.s2);
});

test("l'archetipo tiene la data PIU' VECCHIA, col suo dominante", () => {
  // Chi cambia telefono non deve ricominciare i tre mesi dell'ordine AO voce
  // 06: la data del test e' un primato, e il dominante che vince e' quello di
  // quella data, non quello dell'altra.
  const server: CamminoCustodito = {
    archetipo: {dominante: "realista", quando: "2026-08-15T10:00:00.000"},
  };
  const telefono: CamminoCustodito = {
    archetipo: {dominante: "mago", quando: "2026-05-01T09:00:00.000"},
  };
  const fuso = fondiCammini(server, telefono);
  assert.equal(fuso.archetipo?.quando, "2026-05-01T09:00:00.000");
  assert.equal(fuso.archetipo?.dominante, "mago");
});

test("l'ora di nascita arriva da chi ce l'ha", () => {
  const server: CamminoCustodito = {identita: {nome: "Sofia", giorno: "1990-04-12"}};
  const telefono: CamminoCustodito = {identita: {ora: "07:30", luogo: "Roma"}};
  const fuso = fondiCammini(server, telefono);
  assert.equal(fuso.identita?.nome, "Sofia");
  assert.equal(fuso.identita?.ora, "07:30");
  assert.equal(fuso.identita?.luogo, "Roma");
});

test("due cammini vuoti danno un cammino vuoto, con la sola versione", () => {
  const fuso = fondiCammini(vuoto, vuoto);
  assert.deepEqual(fuso, {versione: VERSIONE_DEL_CAMMINO});
});
