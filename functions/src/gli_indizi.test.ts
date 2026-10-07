import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {
  costoDellIndizio,
  elementoDelSegno,
  FONTI_DEGLI_INDIZI,
  indiziPossibili,
  indizioDellaPartita,
  modalitaDelSegno,
  PUNTI_PER_INDIZI,
  puntiDellaRisposta,
} from "./gli_indizi";

/**
 * IL MOTORE DEGLI INDIZI. Ordine FF voce 03.
 */
test("FF.03 c) il primo indizio e' gratis, dal secondo cinque Eos", () => {
  assert.deepEqual([1, 2, 3].map(costoDellIndizio), [0, 5, 5]);
  assert.throws(() => costoDellIndizio(4));
  assert.throws(() => costoDellIndizio(0));
});

test("FF.03 d) il punteggio scende secondo gli indizi chiesti", () => {
  assert.deepEqual([0, 1, 2, 3].map((n) => puntiDellaRisposta(n, true)),
    [3, 2, 1, 0.5]);
  assert.deepEqual(PUNTI_PER_INDIZI, [3, 2, 1, 0.5]);
  assert.equal(puntiDellaRisposta(0, false), 0);
});

test("FF.03 elemento e modalita' vengono dal segno", () => {
  assert.equal(elementoDelSegno("aries"), "fuoco");
  assert.equal(elementoDelSegno("scorpio"), "acqua");
  assert.equal(modalitaDelSegno("taurus"), "fisso");
  assert.equal(modalitaDelSegno("pisces"), "mobile");
  assert.equal(elementoDelSegno("boh"), null);
});

test("FF.03 b) nessuna fonte parla di comportamento nell'app", () => {
  // Le fonti sono un elenco chiuso: dati veri e Ritratto. Una fonte che
  // nominasse l'ora, le aperture, gli ingressi o le domande ai Maestri e'
  // un comportamento osservato, e qui cade.
  const vietate = /ora|orari|apre|apertur|access|ingress|entra|domand|chat|maestr|sessio|uso|attivit/i;
  for (const f of FONTI_DEGLI_INDIZI) {
    assert.ok(!vietate.test(f), `la fonte ${f} sa di comportamento`);
  }
  // E il motore non legge altro che i dati della persona.
  const motore = readFileSync("src/gli_indizi.ts", "utf8");
  const interfaccia = motore.slice(motore.indexOf("export interface DatiDellaPersona"),
    motore.indexOf("}", motore.indexOf("export interface DatiDellaPersona")));
  const campi = [...interfaccia.matchAll(/^\s+(\w+)\??:/gm)].map((m) => m[1]);
  assert.deepEqual(campi, ["ritratto", "segno", "animale", "archetipoSecondario"]);
});

test("FF.03 gli indizi della partita sono fissi per il seme e non dicono la risposta", () => {
  const dati = {ritratto: ["t01", "t02", "t03"], segno: "leo", animale: null};
  const a = [1, 2, 3].map((n) => indizioDellaPartita(dati, "partita-1", n, ["t02"]));
  const b = [1, 2, 3].map((n) => indizioDellaPartita(dati, "partita-1", n, ["t02"]));
  assert.deepEqual(a, b);
  assert.ok(a.every((i) => i !== null && i.valore !== "t02"));
  assert.equal(new Set(a.map((i) => `${i?.fonte}${i?.valore}`)).size, 3);
  assert.equal(indiziPossibili(dati, ["t02"]).length, 4);
});
