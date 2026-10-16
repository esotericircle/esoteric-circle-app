import {test} from "node:test";
import assert from "node:assert/strict";

import {fondiCammini, leggiCammino} from "./cammino";
import {fondiMemorie, leggiMemorie, PESO_MASSIMO_DI_UNA_FAMIGLIA} from "./memorie";

/**
 * Ordine EV, il fondatore: "Avevo già accumulato 5 "runa del tramonto" e
 * adesso devo ricominciare da 1". La settimana del Tramonto custodita con
 * cinque sere, il telefono reinstallato con una sera nuova: la fusione le
 * tiene tutte e sei.
 */
test("EV: le sere del Tramonto custodite non si perdono con una reinstallazione", () => {
  const sera = (g: string) => ({giorno: g, runa: "Algiz"});
  const server = {
    sunset_rune: {
      "sunset_rune.settimana": {
        t: "s" as const,
        v: JSON.stringify(["2026-09-25", "2026-09-26", "2026-09-27",
          "2026-09-28", "2026-09-29"].map(sera)),
      },
    },
  };
  const telefono = {
    sunset_rune: {
      "sunset_rune.settimana": {
        t: "s" as const,
        v: JSON.stringify([sera("2026-10-01")]),
      },
    },
  };
  const fuso = fondiMemorie(server, telefono)!;
  const sere = JSON.parse(fuso.sunset_rune["sunset_rune.settimana"].v as string);
  assert.equal(sere.length, 6);
  // E un telefono che non manda niente non toglie niente.
  assert.deepEqual(fondiMemorie(server, undefined), server);
});

test("EV: liste, numeri, vero o falso e oggetti JSON si fondono senza perdere", () => {
  const fuso = fondiMemorie(
    {f: {
      l: {t: "l", v: ["a", "b"]},
      n: {t: "i", v: 7},
      b: {t: "b", v: true},
      j: {t: "s", v: JSON.stringify({x: 1, lista: [1, 2]})},
      testo: {t: "s", v: "vecchio"},
    }},
    {f: {
      l: {t: "l", v: ["c", "a"]},
      n: {t: "i", v: 3},
      b: {t: "b", v: false},
      j: {t: "s", v: JSON.stringify({y: 2, lista: [2, 3]})},
      testo: {t: "s", v: "nuovo"},
    }}
  )!;
  assert.deepEqual(fuso.f.l.v, ["c", "a", "b"]);
  assert.equal(fuso.f.n.v, 7);
  assert.equal(fuso.f.b.v, true);
  assert.deepEqual(JSON.parse(fuso.f.j.v as string), {x: 1, y: 2, lista: [2, 3, 1]});
  assert.equal(fuso.f.testo.v, "nuovo");
});

test("EV: le memorie passano dal cammino, e una famiglia troppo pesante resta fuori", () => {
  const letto = leggiCammino({
    memorie: {
      sogni: {"sogni.diario": {t: "l", v: ["uno"]}},
      "Non-Valida!": {x: {t: "s", v: "y"}},
      enorme: {k: {t: "s", v: "x".repeat(PESO_MASSIMO_DI_UNA_FAMIGLIA + 10)}},
      storta: {k: {t: "l", v: [["annidata"]]}},
    },
  });
  assert.deepEqual(Object.keys(letto.memorie ?? {}), ["sogni"]);
  const fuso = fondiCammini(
    {memorie: {sogni: {"sogni.diario": {t: "l", v: ["vecchio"]}}}},
    letto
  );
  assert.deepEqual(fuso.memorie?.sogni["sogni.diario"].v, ["uno", "vecchio"]);
  assert.equal(leggiMemorie(undefined), undefined);
});

test("EV: un elemento con la stessa identita' resta uno, nella versione del telefono", () => {
  const fuso = fondiMemorie(
    {sigilli: {"sigilli.libro": {t: "s", v: JSON.stringify([
      {id: "s1", stato: "vivo"}, {id: "s2", stato: "vivo"}])}}},
    {sigilli: {"sigilli.libro": {t: "s", v: JSON.stringify([
      {id: "s1", stato: "lasciato"}])}}}
  )!;
  const libro = JSON.parse(fuso.sigilli["sigilli.libro"].v as string);
  assert.deepEqual(libro, [{id: "s1", stato: "lasciato"}, {id: "s2", stato: "vivo"}]);
  const storico = fondiMemorie(
    {archetipo: {"archetipo.storico": {t: "l", v: [
      JSON.stringify({quando: "2026-09-01", dominante: "mago"})]}}},
    {archetipo: {"archetipo.storico": {t: "l", v: [
      JSON.stringify({quando: "2026-09-01", dominante: "mago"}),
      JSON.stringify({quando: "2026-10-01", dominante: "saggio"})]}}}
  )!;
  assert.equal((storico.archetipo["archetipo.storico"].v as string[]).length, 2);
});
