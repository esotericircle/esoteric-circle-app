import {test} from "node:test";
import assert from "node:assert/strict";
import {
  anniCompiuti,
  consumaConsenso,
  creaConsenso,
  DURATA_DEL_CONSENSO_MS,
  esitoDellaLettura,
  giornoDa,
  nascitaDaCorpo,
  haAlmeno16Anni,
  legameApribile,
} from "./sinastria_evolutiva";
import {limiteDi} from "./budget";
import {LISTINO_DEL_RISCATTO} from "./borsellino";

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
  giorno: "1995-06-20",
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
  assert.deepEqual(chiavi, ["giorno", "nascita", "nome", "oraNota"]);
});

test("la nascita dal telefono si controlla campo per campo", () => {
  assert.deepEqual(nascitaDaCorpo({...dati, nome: "  Giulia "}, oggi), dati);
  assert.equal(nascitaDaCorpo(null, oggi), null);
  assert.equal(nascitaDaCorpo({...dati, oraNota: "si"}, oggi), null);
  assert.equal(nascitaDaCorpo({...dati, nome: ""}, oggi), null);
  assert.equal(nascitaDaCorpo({...dati, nome: "x".repeat(41)}, oggi), null);
  assert.equal(nascitaDaCorpo({...dati, giorno: "1995-02-31"}, oggi), null,
    "il 31 febbraio non esiste");
  assert.equal(nascitaDaCorpo({...dati, giorno: "1995-06-25"}, oggi), null,
    "il giorno del luogo sta a piu' di un giorno dall'istante");
  assert.equal(nascitaDaCorpo({...dati, nascita: "2030-01-01T00:00:00Z",
    giorno: "2030-01-01"}, oggi), null, "una nascita nel futuro");
  assert.equal(giornoDa("2010-10-15")?.toISOString(), "2010-10-15T00:00:00.000Z");
});

test("FT.04 sul server alla lettura: quindici anni e 364 giorni chiudono l'amore, " +
  "da tutti e due i lati", () => {
  const quindicenne = {...dati, nascita: "2010-10-15T12:00:00.000Z", giorno: "2010-10-15"};
  const sedicenne = {...dati, nascita: "2010-10-14T12:00:00.000Z", giorno: "2010-10-14"};
  const leggi = (d: typeof dati, giornoMio: unknown) =>
    esitoDellaLettura(creaConsenso(d, oggi, "AB12CD"), giornoMio, oggi).esito;
  assert.equal(leggi(quindicenne, "1990-05-12")?.amoreApribile, false);
  assert.equal(leggi(sedicenne, "1990-05-12")?.amoreApribile, true);
  assert.equal(leggi(dati, "2010-10-15")?.amoreApribile, false);
  assert.equal(leggi(dati, "2010-10-14")?.amoreApribile, true);
  // Senza il giorno di chi legge il server non apre.
  assert.equal(leggi(dati, undefined)?.amoreApribile, false);
  assert.deepEqual(leggi(dati, "1990-05-12")?.nascita, dati);
});

test("la lettura di un codice scaduto o gia' letto non da' niente", () => {
  const consenso = creaConsenso(dati, oggi, "AB12CD");
  const tardi = new Date(oggi.getTime() + 6 * 60 * 1000);
  assert.equal(esitoDellaLettura(consenso, "1990-05-12", tardi).esito, null);
  assert.equal(esitoDellaLettura(null, "1990-05-12", oggi).esito, null);
  const letto = {...consenso, consumato: true};
  assert.equal(esitoDellaLettura(letto, "1990-05-12", oggi).esito, null);
});

/**
 * FT.13, IL BUDGET DELLA SINASTRIA EVOLUTIVA SUL SERVER.
 */
test("le coppie nuove al giorno: uno, due, cinque, quindici", () => {
  assert.equal(limiteDi("sinastrieEvolutive", "free"), 1);
  assert.equal(limiteDi("sinastrieEvolutive", "tier1"), 2);
  assert.equal(limiteDi("sinastrieEvolutive", "tier2"), 5);
  assert.equal(limiteDi("sinastrieEvolutive", "tier3"), 15);
});

test("il listino porta la sinastria evolutiva in piu' a 150 Eos", () => {
  assert.equal(LISTINO_DEL_RISCATTO["sinastrieEvolutive"], 150);
});
