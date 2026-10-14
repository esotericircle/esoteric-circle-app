import {test} from "node:test";
import assert from "node:assert/strict";
import {
  anniCompiuti,
  haAlmeno16Anni,
  legameApribile,
} from "./sinastria_approfondita";

/**
 * FT.04, LO SBARRAMENTO DI ETA' SUL LEGAME AMORE, LATO SERVER. Ordine FT,
 * 14 ottobre 2026. Guardia dichiarata dall'ordine: rossa con una persona di
 * 15 anni e 364 giorni, verde a 16 anni e 0 giorni, sui due lati della
 * coppia. Stesso confine della prova gemella lato app,
 * test/lo_sbarramento_di_eta_sul_legame_amore_test.dart.
 */

const oggi = new Date("2026-10-14T00:00:00.000Z");

test("15 anni e 364 giorni: non ancora sedici", () => {
  const nascita = new Date("2010-10-15T00:00:00.000Z");
  assert.equal(anniCompiuti(nascita, oggi), 15);
  assert.equal(haAlmeno16Anni(nascita, oggi), false);
});

test("16 anni e 0 giorni: il compleanno e oggi", () => {
  const nascita = new Date("2010-10-14T00:00:00.000Z");
  assert.equal(anniCompiuti(nascita, oggi), 16);
  assert.equal(haAlmeno16Anni(nascita, oggi), true);
});

test("29 febbraio: il compleanno in un anno non bisestile cade il primo marzo", () => {
  const nata = new Date("2008-02-29T00:00:00.000Z");
  const il28 = new Date("2026-02-28T00:00:00.000Z");
  const il1marzo = new Date("2026-03-01T00:00:00.000Z");
  assert.equal(anniCompiuti(nata, il28), anniCompiuti(nata, il1marzo) - 1);
});

test("il legame amore: entrambi sopra i sedici, aperto", () => {
  const maggiorenne = new Date("1990-01-01T00:00:00.000Z");
  const appenaSedici = new Date("2010-10-14T00:00:00.000Z");
  assert.equal(
    legameApribile("amore", maggiorenne, appenaSedici, oggi),
    true
  );
});

test("il legame amore: tu sotto i sedici, chiuso", () => {
  const maggiorenne = new Date("1990-01-01T00:00:00.000Z");
  const quasiSedici = new Date("2010-10-15T00:00:00.000Z");
  assert.equal(legameApribile("amore", quasiSedici, maggiorenne, oggi), false);
});

test("il legame amore: lei sotto i sedici, chiuso", () => {
  const maggiorenne = new Date("1990-01-01T00:00:00.000Z");
  const quasiSedici = new Date("2010-10-15T00:00:00.000Z");
  assert.equal(legameApribile("amore", maggiorenne, quasiSedici, oggi), false);
});

test("il legame amore: entrambi sotto i sedici, chiuso", () => {
  const quasiSedici = new Date("2010-10-15T00:00:00.000Z");
  assert.equal(legameApribile("amore", quasiSedici, quasiSedici, oggi), false);
});

test("gli altri tre legami non hanno limite di eta", () => {
  const bambino = new Date("2020-01-01T00:00:00.000Z");
  for (const legame of ["amicizia", "famiglia", "lavoro"] as const) {
    assert.equal(legameApribile(legame, bambino, bambino, oggi), true);
  }
});

test("il server non si fida di un client che manda solo 'true'", () => {
  // La firma di legameApribile pretende le due date vere: non esiste un
  // modo di chiamarla dicendo solo "ho gia' controllato io".
  const quasiSedici = new Date("2010-10-15T00:00:00.000Z");
  const maggiorenne = new Date("1990-01-01T00:00:00.000Z");
  assert.equal(legameApribile("amore", quasiSedici, maggiorenne, oggi), false);
});
