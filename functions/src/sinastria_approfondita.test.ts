import {test} from "node:test";
import assert from "node:assert/strict";
import {
  anniCompiuti,
  consumaConsenso,
  creaConsenso,
  DURATA_DEL_CONSENSO_MS,
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

/**
 * FT.03, IL CONSENSO DELLA NASCITA (LETTURA A DUE TELEFONI), LATO SERVER.
 */

const dati = {
  nascita: "1995-06-20T10:00:00.000Z",
  oraNota: true,
  nome: "Giulia",
};

test("il consenso appena creato si consuma e restituisce i dati, una volta", () => {
  const creato = oggi;
  const consenso = creaConsenso(dati, creato, "AB12CD");
  assert.equal(consenso.codice, "AB12CD");
  assert.equal(consenso.consumato, false);
  assert.equal(
    consenso.scadenza.getTime() - consenso.creato.getTime(),
    DURATA_DEL_CONSENSO_MS
  );
  const dopoUnMinuto = new Date(creato.getTime() + 60 * 1000);
  const {datiLetti, consensoAggiornato} = consumaConsenso(consenso, dopoUnMinuto);
  assert.deepEqual(datiLetti, dati);
  assert.equal(consensoAggiornato?.consumato, true);
});

test("consumato una volta, la seconda lettura non ottiene niente", () => {
  const creato = oggi;
  let consenso = creaConsenso(dati, creato, "AB12CD");
  const primo = consumaConsenso(consenso, creato);
  assert.ok(primo.datiLetti !== null);
  consenso = primo.consensoAggiornato!;
  const secondo = consumaConsenso(consenso, creato);
  assert.equal(secondo.datiLetti, null);
});

test("scaduto (oltre cinque minuti), niente dati anche se mai consumato", () => {
  const creato = oggi;
  const consenso = creaConsenso(dati, creato, "AB12CD");
  const seiMinutiDopo = new Date(creato.getTime() + 6 * 60 * 1000);
  const {datiLetti} = consumaConsenso(consenso, seiMinutiDopo);
  assert.equal(datiLetti, null);
});

test("a quattro minuti e mezzo (dentro i cinque) i dati arrivano ancora", () => {
  const creato = oggi;
  const consenso = creaConsenso(dati, creato, "AB12CD");
  const dentro = new Date(creato.getTime() + 4.5 * 60 * 1000);
  const {datiLetti} = consumaConsenso(consenso, dentro);
  assert.deepEqual(datiLetti, dati);
});

test("un consenso inesistente (null) non da' mai dati, senza distinguere il motivo", () => {
  const {datiLetti, consensoAggiornato} = consumaConsenso(null, oggi);
  assert.equal(datiLetti, null);
  assert.equal(consensoAggiornato, null);
});

test("il consenso non porta nessun campo da profilo pubblico", () => {
  const consenso = creaConsenso(dati, oggi, "AB12CD");
  const chiavi = Object.keys(consenso.dati).sort();
  assert.deepEqual(chiavi, ["nascita", "nome", "oraNota"]);
});
