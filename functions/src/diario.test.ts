import {test} from "node:test";
import assert from "node:assert/strict";
import {
  giornoDi, titoloDa, chiaveDellaConversazione, ilRiassuntoDopo,
  LUNGHEZZA_DEL_TITOLO, VERSIONE_DEL_FORMATO, etichetteDi, Riga,
} from "./diario";

/**
 * IL DIARIO COSMICO SUL SERVER. Ordine FE voce 22: le parti pure, che si
 * provano senza Firestore.
 */
test("il giorno del Diario e' quello di Roma, non quello di Greenwich", () => {
  // Le 23:30 del 5 ottobre 2026 in UTC sono l'1:30 del 6 a Roma.
  assert.equal(giornoDi(Date.UTC(2026, 9, 5, 23, 30)), "2026-10-06");
  assert.equal(giornoDi(Date.UTC(2026, 9, 5, 12, 0)), "2026-10-05");
});

test("il titolo e' una riga sola, e si taglia oltre la misura", () => {
  assert.equal(titoloDa("  Quando  riceverò\nla promozione?  "),
    "Quando riceverò la promozione?");
  const lungo = titoloDa("a".repeat(500));
  assert.equal(lungo.length, LUNGHEZZA_DEL_TITOLO);
  assert.ok(lungo.endsWith("..."));
});

test("la chiave di una conversazione e' stabile e senza caratteri strani", () => {
  assert.equal(chiaveDellaConversazione("medora", "c1759700000000"),
    "conv.medora.c1759700000000");
  assert.equal(chiaveDellaConversazione("aura", null), "conv.aura.prima");
  assert.equal(chiaveDellaConversazione("caligo", "c1/../x"),
    "conv.caligo.c1x");
});

test("FE.22.8: il giorno porta la stella finche' una sua voce la porta", () => {
  let anno: Record<string, any> = {};
  const conv: Riga = {t: "x", m: "medora", k: "conversazione", a: "chat", q: 0};
  const resp: Riga = {t: "y", m: "aura", k: "responso", a: "rune", q: 0};
  anno = ilRiassuntoDopo(anno, "2026-10-06", etichetteDi(conv), 1);
  anno = ilRiassuntoDopo(anno, "2026-10-06", etichetteDi(resp), 1);
  assert.deepEqual(anno.mesi["10"],
    {tutte: 2, conversazioni: 1, medora: 1, arti: 1, aura: 1});
  // La stella messa su una voce: il giorno la porta.
  anno = ilRiassuntoDopo(anno, "2026-10-06", ["stelle"], 1);
  assert.deepEqual(anno.stelle, {"10-06": 1});
  assert.equal(anno.mesi["10"].stelle, 1);
  // La stella tolta: il giorno la perde.
  anno = ilRiassuntoDopo(anno, "2026-10-06", ["stelle"], -1);
  assert.deepEqual(anno.stelle, {});
  // Il cestino: le etichette scendono, e a zero il mese sparisce.
  anno = ilRiassuntoDopo(anno, "2026-10-06", etichetteDi(conv), -1);
  anno = ilRiassuntoDopo(anno, "2026-10-06", etichetteDi(resp), -1);
  assert.deepEqual(anno.mesi, {});
});

test("FE.22.12: le voci portano la versione del formato", () => {
  assert.equal(VERSIONE_DEL_FORMATO, 1);
});
