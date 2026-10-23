import {test} from "node:test";
import assert from "node:assert/strict";
import {
  confineDellaPresenza,
  FINESTRA_DELLA_PRESENZA_MS,
  OGNI_QUANTO_CHIEDE_MS,
  quantiDaMostrare,
} from "./presenza";
import {costruisciLIstantanea, SchedaCompatta} from "./sociale";

/**
 * CHI E' NEL CERCHIO ADESSO, la parte senza database. Ordine ES voce 15.
 */
test("la finestra e' piu' larga del passo del telefono", () => {
  // Se fosse uguale o piu' stretta, chi ha l'app aperta uscirebbe dal conto
  // fra una domanda e l'altra, e il numero lampeggerebbe.
  assert.ok(FINESTRA_DELLA_PRESENZA_MS > OGNI_QUANTO_CHIEDE_MS);
  // LAPIDE, ordine FF voce 01 (7 ottobre 2026): qui si pretendeva una
  // finestra di al piu' tre minuti, "da non contare per minuti chi ha chiuso
  // l'app", e il confine a novanta secondi. Il fondatore vuole online chi ha
  // l'app aperta anche sullo sfondo: cinque minuti dall'ultimo segno.
  assert.equal(FINESTRA_DELLA_PRESENZA_MS, 5 * 60 * 1000);
  assert.equal(confineDellaPresenza(1_000_000), 1_000_000 - 300_000);
});

/** Una voce con la scheda, viva all'istante dato. */
const voce = (u: number): SchedaCompatta => ({v: "amici", a: "tarocchi", u});

/** Quanti online conta l'istantanea all'istante dato. */
function onlineA(voci: Record<string, SchedaCompatta>, adesso: number) {
  return costruisciLIstantanea({
    frammenti: [voci],
    adessoMs: adesso,
    confineMs: confineDellaPresenza(adesso),
  }).istantanea.totale;
}

test("FF.01 a) sullo sfondo da quattro minuti resta online, da sei no", () => {
  const uscita = 10 * 60 * 60 * 1000;
  // L'ultimo segno e' l'ora dell'uscita, scritta da scriviLUscita.
  const voci = {a: voce(uscita)};
  assert.equal(onlineA(voci, uscita + 4 * 60 * 1000), 1);
  assert.equal(onlineA(voci, uscita + 6 * 60 * 1000), 0);
});

test("FF.01 c) il numero non lampeggia: due sessioni, una passa a un'altra app e torna entro il minuto", () => {
  // A e B hanno l'app davanti e chiedono ogni minuto. Al secondo 0 A passa
  // a un'altra app: il telefono dice "esce" e il server scrive l'ora. B
  // chiede al secondo 20 e al secondo 50; A torna al secondo 55 e chiede.
  const t = 10 * 60 * 60 * 1000;
  const conB: number[] = [];
  const prima: number[] = [];
  const voci: Record<string, SchedaCompatta> = {
    a: voce(t - 30_000), b: voce(t - 10_000)};
  conB.push(onlineA(voci, t - 1));
  prima.push(onlineA(voci, t - 1));
  // L'uscita di A: l'ora, dall'ordine FF; prima dell'ordine FF la voce si
  // toglieva (scriviLaPresenza(uid, null)).
  const dopo: Record<string, SchedaCompatta> = {...voci, a: voce(t)};
  const vecchie: Record<string, SchedaCompatta> = {b: voci.b};
  for (const s of [20, 50]) {
    voci.b = voce(t + s * 1000);
    dopo.b = voci.b;
    vecchie.b = voci.b;
    conB.push(onlineA(dopo, t + s * 1000));
    prima.push(onlineA(vecchie, t + s * 1000));
  }
  dopo.a = voce(t + 55_000);
  vecchie.a = dopo.a;
  conB.push(onlineA(dopo, t + 60_000));
  prima.push(onlineA(vecchie, t + 60_000));
  console.log(`ORDINE FF VOCE 01: il numero che legge B, prima ${prima.join(", ")}, dopo ${conB.join(", ")}`);
  assert.deepEqual(conB, [2, 2, 2, 2]);
  assert.deepEqual(prima, [2, 1, 1, 2]);
});

test("il numero non scende mai sotto uno", () => {
  assert.equal(quantiDaMostrare(0), 1);
  assert.equal(quantiDaMostrare(-3), 1);
  assert.equal(quantiDaMostrare(Number.NaN), 1);
  assert.equal(quantiDaMostrare(1), 1);
  assert.equal(quantiDaMostrare(37), 37);
});
