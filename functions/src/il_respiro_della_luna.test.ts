import {test} from "node:test";
import assert from "node:assert/strict";
import {
  CollanaADueDati,
  DURATA_DEL_RESPIRO_INSIEME_MS,
  collanaADueDa,
  dataCivileValida,
  idDellaCollanaADue,
} from "./il_cerchio_sociale";
import {TETTI_DELLE_PORTE} from "./sociale";

/**
 * **IL RESPIRO DELLA LUNA SUL SERVER, ordine FX voce FX.09.** Le sole parti
 * pure delle sei porte nuove, nello stesso stile delle prove pure del
 * Calendario Lunare in `sociale.test.ts`: le callable vere (`onCall`)
 * toccano Firestore e qui non hanno un emulatore da chiamare, come succede
 * per le porte sorelle del Cerchio sociale.
 */

test("FX.09 la data civile valida: 'AAAA-MM-GG' e una data che esiste", () => {
  assert.equal(dataCivileValida("2026-11-24"), "2026-11-24");
  assert.equal(dataCivileValida("2026-02-30"), null, "il 30 febbraio non esiste");
  assert.equal(dataCivileValida("24-11-2026"), null, "il formato e' sbagliato");
  assert.equal(dataCivileValida(20261124), null, "non e' una stringa");
  assert.equal(dataCivileValida(undefined), null);
});

test("FX.09 l'identificativo della collana: la stessa coppia, sempre nello stesso ordine", () => {
  const a = idDellaCollanaADue("u-ambra", "u-stella", "2026-11-24");
  const b = idDellaCollanaADue("u-stella", "u-ambra", "2026-11-24");
  assert.equal(a, b, "chi invita e chi riceve devono trovare lo stesso documento");
  const altroCiclo = idDellaCollanaADue("u-ambra", "u-stella", "2026-12-24");
  assert.notEqual(a, altroCiclo, "un ciclo diverso e' una collana diversa");
});

test("FX.09 la perla si accende solo quando ENTRAMBI hanno segnalato il giorno", () => {
  const dati: Record<string, unknown> = {
    persone: ["u-ambra", "u-stella"],
    ciclo: "2026-11-24",
    stato: "attiva",
    da: "u-ambra",
    giorni: {
      "2026-11-20": {"u-ambra": true, "u-stella": true},
      "2026-11-21": {"u-ambra": true},
      "2026-11-22": {"u-stella": true},
    },
  };
  const collana = collanaADueDa(dati) as CollanaADueDati;
  assert.ok(collana !== null);
  const accesi = Object.entries(collana.giorni)
    .filter(([, chi]) => collana.persone.every((p) => chi?.[p] === true))
    .map(([giorno]) => giorno);
  console.log(`FX.09 MISURA la collana: giorni segnalati ${Object.keys(collana.giorni).length}, ` +
    `giorni con la perla accesa ${accesi.length}`);
  assert.deepEqual(accesi, ["2026-11-20"],
    "solo il giorno 20 ha il segnale di entrambe le persone");
  assert.equal(collanaADueDa(undefined), null);
  assert.equal(collanaADueDa({persone: ["u-ambra"]}), null, "manca ciclo e stato");
});

test("FX.09 il TTL del respiro insieme assorbe il ritardo di rete oltre il minuto", () => {
  assert.ok(DURATA_DEL_RESPIRO_INSIEME_MS > 60 * 1000,
    "il respiro guidato dura un minuto: il TTL deve superarlo");
  assert.ok(DURATA_DEL_RESPIRO_INSIEME_MS < 2 * 60 * 1000,
    "il margine resta breve, non un secondo respiro");
});

test("FX.09 GUARDIA: le sei porte del Respiro della Luna hanno il loro tetto", () => {
  const porte = [
    "respiroInsiemeEntra",
    "respiroInsiemeConteggio",
    "invitaCollanaADue",
    "rispondiCollanaADue",
    "segnalaRespiroDelGiornoPerLaCollanaADue",
    "leCollaneADue",
  ];
  for (const nome of porte) {
    assert.ok(TETTI_DELLE_PORTE[nome] !== undefined, `${nome} non ha un tetto`);
  }
  // Il conteggio, letto durante l'ora intera della finestra, resta il piu'
  // largo delle sei: e' quello che si chiama a ripetizione.
  assert.ok(TETTI_DELLE_PORTE.respiroInsiemeConteggio.quante >
    TETTI_DELLE_PORTE.respiroInsiemeEntra.quante);
});
