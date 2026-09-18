import {test} from "node:test";
import assert from "node:assert/strict";

import {
  CollezioneDeiMessaggi,
  doppioniDa,
  idDelMessaggio,
  MessaggioSalvato,
  scriviIlMessaggio,
} from "./doppioni";

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

/**
 * LA SECONDA DIFESA. Ordine DV voce 09: lo stesso messaggio mandato due
 * volte, con lo stesso identificativo, e' un documento solo.
 */
class CollezioneFinta implements CollezioneDeiMessaggi {
  documenti = new Map<string, Record<string, unknown>>();
  private prossimo = 0;
  async add(dati: Record<string, unknown>) {
    const id = `auto${this.prossimo++}`;
    this.documenti.set(id, dati);
    return {id};
  }
  doc(id: string) {
    return {
      create: async (dati: Record<string, unknown>) => {
        if (this.documenti.has(id)) {
          throw Object.assign(new Error("6 ALREADY_EXISTS"), {code: 6});
        }
        this.documenti.set(id, dati);
      },
    };
  }
}
const colTempo = (d: Record<string, unknown>) => ({...d, createdAt: "adesso"});

test("DV.09: lo stesso messaggio mandato due volte e' un documento solo",
  async () => {
    const col = new CollezioneFinta();
    const campi = {role: "user", text: "Tira una carta per me",
      idMessaggio: "AbCdEf0123456789XyZw"};
    const primo = await scriviIlMessaggio(col, campi, colTempo);
    const secondo = await scriviIlMessaggio(col, campi, colTempo);
    assert.equal(col.documenti.size, 1);
    assert.equal(primo.gia, false);
    assert.equal(secondo.gia, true);
    assert.equal(secondo.id, "AbCdEf0123456789XyZw");
    // L'identificativo decide il nome del documento, non entra nei dati.
    const salvato = col.documenti.get("AbCdEf0123456789XyZw")!;
    assert.equal("idMessaggio" in salvato, false);
    assert.equal(salvato.createdAt, "adesso");
  });

test("DV.09: un telefono vecchio senza identificativo scrive come prima",
  async () => {
    const col = new CollezioneFinta();
    await scriviIlMessaggio(col, {role: "user", text: "ciao"}, colTempo);
    await scriviIlMessaggio(col, {role: "user", text: "ciao"}, colTempo);
    assert.equal(col.documenti.size, 2);
  });

test("DV.09: un identificativo che non ha la forma giusta non si usa", () => {
  assert.equal(idDelMessaggio("../../altro/ramo"), null);
  assert.equal(idDelMessaggio(""), null);
  assert.equal(idDelMessaggio(42), null);
  assert.equal(idDelMessaggio("AbCdEf0123456789XyZw"), "AbCdEf0123456789XyZw");
});

test("DV.09: un errore che non e' un doppione non si inghiotte", async () => {
  const col = new CollezioneFinta();
  col.doc = () => ({create: async () => {
    throw Object.assign(new Error("permesso negato"), {code: 7});
  }});
  await assert.rejects(scriviIlMessaggio(col,
    {text: "x", idMessaggio: "AbCdEf0123456789XyZw"}, colTempo));
});
