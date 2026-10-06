import {test} from "node:test";
import assert from "node:assert/strict";
import {
  giornoDi, titoloDa, chiaveDellaConversazione, ilRiassuntoDopo,
  LUNGHEZZA_DEL_TITOLO, VERSIONE_DEL_FORMATO, etichetteDi, Riga,
  ilMeseDelConfine, vaInArchivio, ilPercorsoDelMese, ilMeseDellaConversazione,
  unisciIlMese,
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
    {tutte: 2, conversazioni: 1, medora: 1, responsi: 1, aura: 1});
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

test("FE.22.15: in archivio va un mese intero, finito da dodici mesi", () => {
  const adesso = Date.UTC(2026, 9, 6, 19);
  assert.equal(ilMeseDelConfine(adesso), "2025-10");
  assert.equal(ilMeseDelConfine(Date.UTC(2026, 0, 15)), "2025-01");
  assert.equal(vaInArchivio(Date.UTC(2025, 8, 30, 12), adesso), true);
  assert.equal(vaInArchivio(Date.UTC(2025, 9, 1, 12), adesso), false,
    "un mese non ancora finito da dodici mesi si riscriverebbe ogni notte");
  // Le prime ore del primo ottobre a Roma sono ancora il 30 settembre UTC:
  // il confine e' sul mese di Roma.
  assert.equal(vaInArchivio(Date.UTC(2025, 8, 30, 23), adesso), false);
});

test("FE.22.15: un oggetto per persona e per mese, e la conversazione sta nel mese in cui e' nata", () => {
  assert.equal(ilPercorsoDelMese("u1", "2025-03"), "diario_archivio/u1/2025-03.json");
  const nata = Date.UTC(2025, 2, 31, 10);
  assert.equal(ilMeseDellaConversazione(`c${nata}`, Date.UTC(2025, 3, 2)), "2025-03");
  assert.equal(ilMeseDellaConversazione(null, Date.UTC(2025, 3, 2)), "2025-04");
});

test("FE.22.15: unire un mese tiene le voci e i messaggi, senza doppioni e in ordine", () => {
  const prima = {voci: {a: 1}, conversazioni: {k: [{id: "m2", quando: 2}]}};
  const dopo = unisciIlMese(prima, {b: 2},
    {k: [{id: "m1", quando: 1}, {id: "m2", quando: 2}], j: [{id: "m3", quando: 3}]});
  assert.deepEqual(Object.keys(dopo.voci).sort(), ["a", "b"]);
  assert.deepEqual(dopo.conversazioni.k.map((m) => m.id), ["m1", "m2"]);
  assert.deepEqual(dopo.conversazioni.j.map((m) => m.id), ["m3"]);
});
