import {test} from "node:test";
import assert from "node:assert/strict";
import {
  confineDellaPresenza,
  FINESTRA_DELLA_PRESENZA_MS,
  OGNI_QUANTO_CHIEDE_MS,
  quantiDaMostrare,
} from "./presenza";

/**
 * CHI E' NEL CERCHIO ADESSO, la parte senza database. Ordine ES voce 15.
 */
test("la finestra e' piu' larga del passo del telefono", () => {
  // Se fosse uguale o piu' stretta, chi ha l'app aperta uscirebbe dal conto
  // fra una domanda e l'altra, e il numero lampeggerebbe.
  assert.ok(FINESTRA_DELLA_PRESENZA_MS > OGNI_QUANTO_CHIEDE_MS);
  // E non tanto piu' larga da contare per minuti chi ha chiuso l'app.
  assert.ok(FINESTRA_DELLA_PRESENZA_MS <= 3 * 60 * 1000);
  // Un minuto e mezzo dall'ordine EV voce 06 (era due minuti e mezzo).
  assert.equal(confineDellaPresenza(1_000_000), 1_000_000 - 90_000);
});

test("il numero non scende mai sotto uno", () => {
  assert.equal(quantiDaMostrare(0), 1);
  assert.equal(quantiDaMostrare(-3), 1);
  assert.equal(quantiDaMostrare(Number.NaN), 1);
  assert.equal(quantiDaMostrare(1), 1);
  assert.equal(quantiDaMostrare(37), 37);
});
