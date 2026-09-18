import {test} from "node:test";
import assert from "node:assert/strict";

import {doppioniDa, MessaggioSalvato} from "./doppioni";

/**
 * I DOPPIONI DELLA CRONOLOGIA. Ordine DV.
 *
 * Gli stessi casi della prova del telefono,
 * `test/la_chat_non_raddoppia_le_domande_test.dart`, gruppo *il riconoscitore
 * dei doppioni*: la regola e' una sola e deve dire la stessa cosa da tutte e
 * due le parti.
 */

let n = 0;
const u = (text: string, conversazione?: string): MessaggioSalvato => ({
  id: `m${n++}`,
  role: "user",
  text,
  conversazione,
});
const m = (text: string): MessaggioSalvato => ({
  id: `m${n++}`,
  role: "maestro",
  text,
});

test("toglie la domanda che ripete quella subito prima", () => {
  const lista = [u("a"), u("a"), m("r"), u("b"), u("b"), u("b"), m("s")];
  assert.deepEqual(doppioniDa(lista), [lista[1].id, lista[4].id, lista[5].id]);
});

test("com'e' davvero sul server: la carta del giorno due volte", () => {
  const lista = [
    u("Carta del giorno"),
    u("Carta del giorno"),
    m("La tua carta di oggi"),
  ];
  assert.deepEqual(doppioniDa(lista), [lista[1].id]);
});

test("non tocca una domanda ripetuta con la risposta in mezzo", () => {
  assert.deepEqual(doppioniDa([u("a"), m("r"), u("a"), m("r2")]), []);
});

test("non unisce due conversazioni diverse", () => {
  assert.deepEqual(doppioniDa([u("a", "c1"), u("a", "c2")]), []);
});

test("non unisce due risposte uguali del Maestro", () => {
  assert.deepEqual(doppioniDa([u("a"), m("r"), m("r")]), []);
});

test("gli spazi in coda non fanno due domande diverse", () => {
  const lista = [u("Estrai una runa per me"), u("Estrai una runa per me ")];
  assert.deepEqual(doppioniDa(lista), [lista[1].id]);
});
