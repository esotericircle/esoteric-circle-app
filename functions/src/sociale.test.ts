import {test} from "node:test";
import assert from "node:assert/strict";
import * as fs from "node:fs";
import * as path from "node:path";
import {
  ALFABETO_DEL_SIGILLO,
  CAMPI_DEL_PROFILO_PUBBLICO,
  DURATE_DEL_CODICE,
  GIFT_MASSIMO_AL_GIORNO,
  INVITI_AL_GIORNO,
  POSTI_DEL_LEGAME,
  Presenza,
  SEGNI_AL_GIORNO,
  PORTA_CHE_RICEVE_L_ETA,
  RIGA_DEI_QUATTORDICI,
  QUANTE_ICONE,
  TETTI_DELLE_PORTE,
  codiceScritto,
  costruisciLIstantanea,
  decidiIlGift,
  decidiIlSegno,
  decidiIlTetto,
  decidiLInvito,
  istantaneaVecchia,
  donoPerIlPiano,
  eUnSigillo,
  leggiIlCodiceDellInvito,
  lettureAllOra,
  quattordiciDichiarati,
  quandoSiRiapreIlNome,
  reazioneValida,
  registraLoScambio,
  semaforoPer,
  sogliaDellEtaPassata,
  sigilloScritto,
  soloIlPubblico,
  somiglianti,
  unCodice,
  unSigillo,
  visibilitaEffettiva,
  iconaValida,
  iconaDelSegno,
  ARTI_DELLA_PRESENZA,
  FRAMMENTI_DELLA_PRESENZA,
  Istantanea,
  LETTURE_FISSE_DI_UN_APERTURA,
  LIMITE_DI_UN_DOCUMENTO,
  PRESENTI_PER_FRAMMENTO,
  PRESENZE_NELL_ISTANTANEA,
  SOGLIA_DELLE_LETTURE_PER_APERTURA,
  SchedaCompatta,
  byteDellIstantanea,
  byteDiUnaVoce,
  compatta,
  frammentoDi,
  lettureDegliAmici,
  lettureDellaRicostruzione,
} from "./sociale";
import {INDIRIZZI_DEGLI_STORE, RIGA_DEL_CODICE, laPagina} from "./la_pagina_dell_invito";

/**
 * IL MOTORE SOCIALE DEL CERCHIO, ordine EY: la parte senza database, provata
 * senza rete e senza emulatore.
 */
const GIORNO = 24 * 60 * 60 * 1000;

test("EY.01 il sigillo: trentadue simboli che non si confondono", () => {
  assert.equal(ALFABETO_DEL_SIGILLO.length, 32);
  assert.equal(new Set(ALFABETO_DEL_SIGILLO).size, 32);
  for (const vietata of ["O", "I", "L", "U"]) {
    assert.ok(!ALFABETO_DEL_SIGILLO.includes(vietata), `${vietata} si confonde`);
  }
  for (let i = 0; i < 500; i++) assert.ok(eUnSigillo(unSigillo()));
  // Chi copia a mano una O per uno zero o una L per un uno non sbaglia.
  assert.equal(sigilloScritto("k7qo"), "K7Q0");
  assert.equal(sigilloScritto("#L2AB"), "12AB");
  assert.equal(sigilloScritto("ABCDE"), null);
  console.log(`EY.01 SIGILLO: ${Math.pow(32, 4)} sigilli possibili`);
});

test("EY.01 la cadenza del nome: il primo cambio libero, poi trenta giorni", () => {
  const t0 = 1_000_000_000_000;
  assert.equal(quandoSiRiapreIlNome(0, null, t0), null);
  assert.equal(quandoSiRiapreIlNome(1, t0, t0 + 29 * GIORNO), t0 + 30 * GIORNO);
  assert.equal(quandoSiRiapreIlNome(1, t0, t0 + 30 * GIORNO), null);
});

test("EY.02 il profilo pubblico porta sette campi e niente altro", () => {
  assert.deepEqual([...CAMPI_DEL_PROFILO_PUBBLICO], [
    "nome", "sigillo", "icona", "segno", "gradino", "maestro", "ultimaPresenza",
  ]);
  const sporco = {
    nome: "Lunaria", sigillo: "K7Q0", icona: "animale:3", segno: "leo",
    gradino: 12, maestro: "aura", ultimaPresenza: 5,
    nomeProprio: "Maria", nascita: "1990-08-01", ora: "10:30",
    luogo: "Roma", email: "x@y.it", foto: "data:", posizione: [41, 12],
  };
  const pulito = soloIlPubblico(sporco);
  assert.deepEqual(Object.keys(pulito).sort(), [...CAMPI_DEL_PROFILO_PUBBLICO].sort());
  const testo = JSON.stringify(pulito);
  for (const vietato of ["Maria", "1990", "10:30", "Roma", "x@y.it", "data:", "41"]) {
    assert.ok(!testo.includes(vietato), `il profilo pubblico porta ${vietato}`);
  }
  // E la porta che lo scrive passa sempre da soloIlPubblico.
  const porte = fs.readFileSync(
    path.join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
  const scritture = porte.match(/profiloDi\(uid\)\.set\(([^)]*)\)/g) ?? [];
  assert.deepEqual(scritture, ["profiloDi(uid).set(pubblico)"]);
});

test("EY.05 il semaforo: quattro stati, e il rosso non esiste negli elenchi", () => {
  assert.equal(semaforoPer("a", null), "spento");
  assert.equal(semaforoPer("a", {stato: "amici", da: "b"}), "verde");
  assert.equal(semaforoPer("a", {stato: "invito", da: "a"}), "arancioneChiaro");
  assert.equal(semaforoPer("a", {stato: "invito", da: "b"}), "arancionePieno");
  // Il rifiuto non si annuncia: per chi ha invitato resta un invito che aspetta.
  assert.equal(semaforoPer("a", {stato: "rifiutato", da: "a"}), "arancioneChiaro");
  assert.equal(semaforoPer("b", {stato: "rifiutato", da: "a"}), "spento");
  const sorgente = fs.readFileSync(path.join(__dirname, "..", "src", "sociale.ts"), "utf8");
  const tipo = sorgente.match(/export type Semaforo =[^;]*;/)?.[0] ?? "";
  assert.ok(!/rosso/i.test(tipo), "il rosso e' entrato fra gli stati degli elenchi");
});

test("EY.04 ed EY.05 le difese dell'invito", () => {
  const base = {da: "a", a: "b", bloccati: false, legame: null, conIlSigillo: false,
    soloColSigillo: false, invitiOggi: 0, amiciDiChiInvita: 0, postiDiChiInvita: 3,
    adessoMs: 1000};
  assert.equal(decidiLInvito(base).concesso, true);
  assert.equal(decidiLInvito({...base, a: "a"}).perche, "teStesso");
  assert.equal(decidiLInvito({...base, bloccati: true}).perche, "nonRaggiungibile");
  assert.equal(decidiLInvito({...base, legame: {stato: "invito", da: "a"}}).perche,
    "aspettaRisposta");
  assert.equal(decidiLInvito({...base,
    legame: {stato: "rifiutato", da: "a", fino: 1000 + 30 * GIORNO}}).perche,
  "rifiutatoDiRecente");
  assert.equal(decidiLInvito({...base,
    legame: {stato: "rifiutato", da: "a", fino: 999}}).concesso, true);
  assert.equal(decidiLInvito({...base, soloColSigillo: true}).perche, "soloColSigillo");
  assert.equal(decidiLInvito({...base, soloColSigillo: true, conIlSigillo: true}).concesso,
    true);
  assert.equal(decidiLInvito({...base, invitiOggi: INVITI_AL_GIORNO}).perche, "invitiFiniti");
  assert.equal(decidiLInvito({...base, amiciDiChiInvita: 3}).perche, "postiFiniti");
});

test("EY.07 nessun senza limite: i posti hanno tutti un numero", () => {
  assert.deepEqual(POSTI_DEL_LEGAME, {free: 3, tier1: 15, tier2: 50, tier3: 150});
  for (const v of Object.values(POSTI_DEL_LEGAME)) assert.ok(Number.isInteger(v) && v > 0);
});

test("EY.17 il codice: opaco, due durate, un meccanismo solo", () => {
  assert.equal(DURATE_DEL_CODICE.link, 30 * GIORNO);
  assert.equal(DURATE_DEL_CODICE.vicino, 5 * 60 * 1000);
  const link = unCodice("link");
  const vicino = unCodice("vicino");
  assert.equal(link.length, 8);
  assert.equal(vicino.length, 6);
  assert.equal(codiceScritto(link.toLowerCase()), link);
  // La forma nuova, col Maestro, e la vecchia con l'uid, dichiarata.
  assert.deepEqual(leggiIlCodiceDellInvito(`${link}.aura`),
    {forma: "nuova", codice: link, maestro: "aura"});
  const uid = "kJ3nX9aQ2bYt7Lm4Pq8Rs1Uv0WxZ";
  assert.deepEqual(leggiIlCodiceDellInvito(`${uid}.medora`),
    {forma: "vecchia", codice: uid, maestro: "medora"});
  assert.equal(leggiIlCodiceDellInvito("abc"), null);
});

test("EY.09 i minorenni restano visibili ai soli amici, l'invisibile resta invisibile", () => {
  assert.equal(visibilitaEffettiva("tutti", false), "amici");
  assert.equal(visibilitaEffettiva("tutti", true), "tutti");
  assert.equal(visibilitaEffettiva("invisibile", true), "invisibile");
  assert.equal(visibilitaEffettiva("invisibile", false), "invisibile");
});

function presenza(uid: string, cosa: Partial<Presenza> = {}): Presenza {
  return {uid, ultimo: 1, arte: "tarocchi", visibilita: "tutti", maggiorenne: true,
    nome: uid, icona: "segno:0", segno: "leo", maestro: "aura", gradino: 3,
    chiPuoInvitare: "tutti", sigillo: null, ...cosa};
}

/** Un'istantanea da un frammento solo, con le presenze date. */
function istantaneaDi(presenze: Presenza[], adessoMs = 10) {
  return costruisciLIstantanea({
    frammenti: [Object.fromEntries(presenze.map((p) =>
      [p.uid, {...compatta(p), u: p.ultimo}]))],
    adessoMs,
    confineMs: 0,
  });
}

test("FB.01 l'istantanea dai frammenti: tutti i presenti, gli invisibili solo nel conto", () => {
  // LAPIDE, ordine FB voce 01: con l'ordine EZ l'istantanea portava i soli
  // conteggi e una vetrina di ventiquattro; adesso porta tutti i presenti
  // non invisibili, letti dai frammenti, e il tetto e' quello del documento.
  const adesso = 10 * 60 * 60 * 1000;
  const fresco = adesso - 1000;
  const {istantanea: ist, scadute, vuoti} = costruisciLIstantanea({
    frammenti: [
      {
        a: {...compatta(presenza("a")), u: fresco},
        b: {...compatta(presenza("b", {arte: "viaggio"})), u: fresco},
        c: {...compatta(presenza("c", {visibilita: "invisibile"})), u: fresco},
        vecchia: {...compatta(presenza("vecchia")), u: adesso - 2 * 60 * 60 * 1000},
        fuoriFinestra: {...compatta(presenza("fuoriFinestra")), u: adesso - 5 * 60 * 1000},
        senzaScheda: {a: "tarocchi", u: fresco},
      },
      {d: {...compatta(presenza("d", {visibilita: "amici"})), u: fresco}},
      // Un frammento rimasto senza voci, uno che non esiste, uno con la sola
      // voce scaduta: il primo e il terzo si cancellano.
      {},
      undefined,
      {via: {...compatta(presenza("via")), u: adesso - 3 * 60 * 60 * 1000}},
    ],
    adessoMs: adesso,
    confineMs: adesso - 90 * 1000,
  });
  assert.deepEqual(Object.keys(ist.presenti).sort(), ["a", "b", "d"]);
  assert.deepEqual(ist.nascosti, ["c"]);
  assert.equal(ist.totale, 4);
  assert.deepEqual(ist.perArte, {tarocchi: 2, viaggio: 1});
  assert.deepEqual(scadute,
    [{frammento: 0, uid: "vecchia"}, {frammento: 4, uid: "via"}]);
  assert.deepEqual(vuoti, [2, 4]);
  assert.equal(ist.troncata, false);
  assert.equal(frammentoDi("u-1"), frammentoDi("u-1"));
  assert.ok(frammentoDi("u-1") < FRAMMENTI_DELLA_PRESENZA);
});

test("FB.01 L'ISTANTANEA STA NEL SUO DOCUMENTO: cade prima del mebibyte", () => {
  // La voce piu' grande possibile: identificativo di 28 caratteri, nome di
  // venti lettere accentate (due byte l'una), l'icona e il segno piu' lunghi.
  const arteLunga = [...ARTI_DELLA_PRESENZA].sort((x, y) => y.length - x.length)[0];
  const grande = (i: number): [string, SchedaCompatta] => [
    `${"x".repeat(22)}${String(i).padStart(6, "0")}`,
    {n: "è".repeat(20), s: "W9TP", i: "archetipo:11", z: "sagittarius",
      m: "caligo", g: 999, a: arteLunga, v: "tutti", M: true, c: "sigillo",
      u: 1},
  ];
  const voce = byteDiUnaVoce(...grande(0));
  const piena: Istantanea = {
    quando: 1, totale: PRESENZE_NELL_ISTANTANEA, perArte: Object.fromEntries(
      ARTI_DELLA_PRESENZA.map((a) => [a, 1_000_000])),
    presenti: Object.fromEntries(Array.from({length: PRESENZE_NELL_ISTANTANEA},
      (_, i) => grande(i))),
    nascosti: [], troncata: false,
  };
  const byte = byteDellIstantanea(piena);
  const stanno = Math.floor(LIMITE_DI_UN_DOCUMENTO / voce);
  console.log(`FB.01 IL DOCUMENTO DELL'ISTANTANEA: una voce al massimo ${voce} ` +
    `byte, ne starebbero ${stanno} in un mebibyte; il tetto dichiarato ` +
    `${PRESENZE_NELL_ISTANTANEA} occupa ${byte} byte, il ` +
    `${(100 * byte / LIMITE_DI_UN_DOCUMENTO).toFixed(1)} per cento`);
  assert.ok(byte <= 0.85 * LIMITE_DI_UN_DOCUMENTO,
    `l'istantanea piena occupa ${byte} byte: oltre l'85 per cento del limite`);
  // Oltre il tetto l'istantanea si tronca e lo dice.
  const {istantanea: troppa} = costruisciLIstantanea({
    frammenti: [Object.fromEntries(Array.from(
      {length: PRESENZE_NELL_ISTANTANEA + 3}, (_, i) => grande(i)))],
    adessoMs: 10, confineMs: 0,
  });
  assert.equal(Object.keys(troppa.presenti).length, PRESENZE_NELL_ISTANTANEA);
  assert.equal(troppa.troncata, true);
  assert.equal(troppa.totale, PRESENZE_NELL_ISTANTANEA + 3);
});

test("FB.01 I FRAMMENTI REGGONO IL TETTO DELL'ISTANTANEA", () => {
  // Un passo al minuto per persona, una scrittura al secondo per frammento:
  // i frammenti devono reggere tutti i presenti che l'istantanea promette.
  const reggono = FRAMMENTI_DELLA_PRESENZA * PRESENTI_PER_FRAMMENTO;
  console.log(`FB.01 I FRAMMENTI: ${FRAMMENTI_DELLA_PRESENZA} frammenti reggono ` +
    `${reggono} presenti, l'istantanea ne promette ${PRESENZE_NELL_ISTANTANEA}`);
  assert.ok(reggono >= PRESENZE_NELL_ISTANTANEA,
    `${FRAMMENTI_DELLA_PRESENZA} frammenti reggono ${reggono} presenti, meno ` +
    `dei ${PRESENZE_NELL_ISTANTANEA} dell'istantanea`);
  // Le voci si spargono sui frammenti: diecimila identificativi, nessun
  // frammento oltre il doppio della media.
  const conti = new Array<number>(FRAMMENTI_DELLA_PRESENZA).fill(0);
  for (let i = 0; i < 10_000; i++) conti[frammentoDi(`persona-${i}`)]++;
  const media = 10_000 / FRAMMENTI_DELLA_PRESENZA;
  assert.equal(conti.filter((c) => c === 0).length, 0);
  assert.ok(Math.max(...conti) < 2 * media, `un frammento ne ha ${Math.max(...conti)}`);
});

test("EY.08 le persone simili: al massimo dodici, mescolate per giorno e per chi guarda", () => {
  const molte = Array.from({length: 40}, (_, i) => presenza(`p${i}`));
  molte.push(presenza("minore", {maggiorenne: false}));
  molte.push(presenza("soloAmici", {visibilita: "amici"}));
  molte.push(presenza("amico"));
  const {istantanea: ist} = istantaneaDi(molte);
  const chiedi = (giorno: string, chi: string) => somiglianti({
    istantanea: ist, chiGuarda: chi, giorno, mioSegno: "leo", mioMaestro: null,
    mioGradino: 0, esclusi: new Set(["amico"]), affinitaAlta: () => false,
  }).map((x) => x.persona.uid);
  const oggi = chiedi("2026-10-04", "io");
  assert.equal(oggi.length, 12);
  assert.deepEqual(chiedi("2026-10-04", "io"), oggi, "cambia a ogni sguardo");
  assert.notDeepEqual(chiedi("2026-10-05", "io"), oggi, "non cambia col giorno");
  assert.notDeepEqual(chiedi("2026-10-04", "altro"), oggi, "uguale per tutti: classifica");
  for (const escluso of ["minore", "soloAmici", "amico", "io"]) {
    assert.ok(!oggi.includes(escluso), `${escluso} non doveva comparire`);
  }
});

test("EY.08 l'istantanea si rifa' al massimo ogni trenta secondi, non a ogni domanda", () => {
  // Nata dalla Regola A (A20): la misura delle letture non vedeva il passo,
  // perche' la ricostruzione si divide fra chi chiede. Qui si pretende il
  // passo stesso.
  const t0 = 5_000_000;
  assert.equal(istantaneaVecchia(null, t0), true);
  assert.equal(istantaneaVecchia(t0, t0 + 29_999), false);
  assert.equal(istantaneaVecchia(t0, t0 + 30_000), true);
});

test("FB.01 LE LETTURE DI UN'APERTURA non dipendono dagli amici presenti", () => {
  const dieci = lettureAllOra({presenti: 1000, aperturePerOra: 60,
    telefoniCheChiedono: 100, amici: 150, amiciPresenti: 10});
  const centocinquanta = lettureAllOra({presenti: 1000, aperturePerOra: 60,
    telefoniCheChiedono: 100, amici: 150, amiciPresenti: 150});
  console.log(`FB.01 LETTURE DI UN'APERTURA con 10 amici presenti ` +
    `${LETTURE_FISSE_DI_UN_APERTURA + lettureDegliAmici(150, 10)}, con 150 ` +
    `${LETTURE_FISSE_DI_UN_APERTURA + lettureDegliAmici(150, 150)}; con ` +
    `l'istantanea da rileggere ${dieci.unAperturaDopo} e ` +
    `${centocinquanta.unAperturaDopo}; soglia ${SOGLIA_DELLE_LETTURE_PER_APERTURA}`);
  assert.equal(lettureDegliAmici(150, 10), lettureDegliAmici(150, 150));
  assert.equal(dieci.unAperturaDopo, centocinquanta.unAperturaDopo);
  // Anche l'apertura peggiore, quella che rilegge l'istantanea, sta sotto la
  // soglia: la ricostruzione non e' mai sua (la fa il passo della presenza).
  assert.ok(centocinquanta.unAperturaDopo <= SOGLIA_DELLE_LETTURE_PER_APERTURA,
    `un'apertura legge ${centocinquanta.unAperturaDopo} documenti`);
  // La ricostruzione legge i frammenti che esistono, non le persone: con
  // una persona sola il turno e un frammento, con mille come con centomila
  // il turno e i novantasei.
  assert.equal(lettureDellaRicostruzione(1000).dopo,
    lettureDellaRicostruzione(100_000).dopo);
  assert.equal(lettureDellaRicostruzione(1).dopo, 2);
  assert.equal(lettureDellaRicostruzione(0).dopo, 2);
});

test("EZ.03 LA MISURA DELLE LETTURE, prima e dopo, mille presenti", () => {
  // Lo scenario dell'ordine EY, per poter confrontare: un telefono che apre
  // la tendina una volta al minuto per un'ora, cento telefoni che la chiedono
  // nello stesso mezzo minuto; in piu' quindici amici, uno presente.
  const ey = lettureAllOra({presenti: 1000, aperturePerOra: 60,
    telefoniCheChiedono: 100, amici: 15, amiciPresenti: 1});
  // Uno scenario d'uso: la tendina aperta sei volte in un'ora.
  const uso = lettureAllOra({presenti: 1000, aperturePerOra: 6,
    telefoniCheChiedono: 100, amici: 15, amiciPresenti: 1});
  console.log(`EZ.03 LETTURE DELLA TENDINA in un'ora con mille presenti, ` +
    `60 aperture: prima ${ey.prima}, dopo ${ey.dopo}; 6 aperture: prima ` +
    `${uso.prima}, dopo ${uso.dopo}; UNA APERTURA che trova l'istantanea ` +
    `vecchia: prima ${ey.unAperturaPrima}, dopo ${ey.unAperturaDopo}; ` +
    `il passo della presenza in un'ora: prima ${ey.passoPrima}, dopo ` +
    `${ey.passoDopo}; via ingenua ${ey.viaIngenua}`);
  assert.equal(ey.viaIngenua, 120000);
  // La ricostruzione non legge piu' una presenza per persona.
  assert.ok(ey.unAperturaDopo <= 50, `un'apertura costa ${ey.unAperturaDopo}`);
  assert.ok(ey.dopo < ey.prima / 2, `dopo ${ey.dopo}, prima ${ey.prima}`);
  assert.ok(uso.dopo <= 150, `sei aperture costano ${uso.dopo}`);
  assert.ok(ey.passoDopo < ey.passoPrima);
});

test("EY.10 i tetti dei segni: piano, stessa persona, non ricambiati, amici", () => {
  assert.deepEqual(SEGNI_AL_GIORNO, {free: 5, tier1: 20, tier2: 40, tier3: 60});
  const base = {piano: "free" as const, mandatiOggi: 0, allaStessaOggi: 0,
    nonRicambiati: 0, amici: true};
  assert.equal(decidiIlSegno(base).concesso, true);
  assert.equal(decidiIlSegno({...base, mandatiOggi: 5}).perche, "segniFiniti");
  assert.equal(decidiIlSegno({...base, allaStessaOggi: 3}).perche, "troppiAllaStessaPersona");
  assert.equal(decidiIlSegno({...base, nonRicambiati: 2}).perche, "aspettaCheRisponda");
  assert.equal(decidiIlSegno({...base, amici: false}).perche, "nonAmici");
});

test("EY.11 la reazione negativa si manda solo rispondendo a un segno", () => {
  assert.equal(reazioneValida("pernacchia"), "pernacchia");
  assert.equal(reazioneValida("insulto"), null);
  // L'unica porta che accetta una reazione e' quella che risponde a un
  // segno, e pretende un segno ricevuto prima di guardare la reazione.
  const porte = fs.readFileSync(
    path.join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
  const chiamanti = porte.split("reazioneValida(").length - 1;
  assert.equal(chiamanti, 1, "una seconda porta accetta reazioni");
  const i = porte.indexOf("export const rispondiAlSegno");
  const corpo = porte.slice(i, porte.indexOf("\n});", i));
  assert.ok(corpo.indexOf("d.verso !== \"ricevuto\"") < corpo.indexOf("reazioneValida("),
    "la reazione si accetta prima di aver visto il segno ricevuto");
});

test("EY.14 il glifo si accende quando tutti e due hanno mandato, una volta al giorno", () => {
  let s = registraLoScambio({giorno: "g1", chiManda: "a", scambio: null, giorniAccesi: []});
  assert.equal(s.accesoOra, false);
  s = registraLoScambio({giorno: "g1", chiManda: "a", scambio: s.scambio, giorniAccesi: s.giorniAccesi});
  assert.equal(s.accesoOra, false, "uno solo che insiste accende il glifo");
  s = registraLoScambio({giorno: "g1", chiManda: "b", scambio: s.scambio, giorniAccesi: s.giorniAccesi});
  assert.equal(s.accesoOra, true);
  s = registraLoScambio({giorno: "g1", chiManda: "a", scambio: s.scambio, giorniAccesi: s.giorniAccesi});
  assert.deepEqual(s.giorniAccesi, ["g1"]);
  s = registraLoScambio({giorno: "g2", chiManda: "b", scambio: s.scambio, giorniAccesi: s.giorniAccesi});
  assert.equal(s.accesoOra, false, "lo scambio di ieri vale oggi");
});

test("EY.12 i doni e il gift: piani, tetti, solo Eos regalabili", () => {
  assert.equal(donoPerIlPiano("cenno", "free"), true);
  assert.equal(donoPerIlPiano("scintilla", "tier1"), false);
  assert.equal(donoPerIlPiano("sigillo", "tier2"), true);
  assert.equal(decidiIlGift({quanti: 99, regalatiOggi: 0, regalabili: 1000, saldo: 1000}).perche,
    "importo");
  assert.equal(decidiIlGift({quanti: 200, regalatiOggi: 400, regalabili: 1000, saldo: 1000}).perche,
    "tetto");
  assert.equal(decidiIlGift({quanti: 200, regalatiOggi: 0, regalabili: 0, saldo: 5000}).perche,
    "nonRegalabili", "si regalano Eos guadagnati gratis");
  assert.equal(decidiIlGift({quanti: 500, regalatiOggi: 0, regalabili: 500, saldo: 500}).concesso,
    true);
  assert.equal(GIFT_MASSIMO_AL_GIORNO, 500);
  // Il dono non conia Eos a chi lo riceve: la porta dei doni non tocca il
  // borsellino di chi riceve.
  const porte = fs.readFileSync(
    path.join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
  const i = porte.indexOf("export const mandaUnDono");
  const corpo = porte.slice(i, porte.indexOf("\n});", i));
  assert.ok(!corpo.includes("statoDi(a, \"borsellino\")"), "il dono conia Eos a chi lo riceve");
});

test("EY.16 il tetto della porta conta, chiude e dice quanto manca", () => {
  const t = TETTI_DELLE_PORTE.laTendinaDelCerchio;
  let stato = {inizio: null as number | null, quante: 0};
  for (let i = 0; i < t.quante; i++) {
    const d = decidiIlTetto({porta: "laTendinaDelCerchio", ...stato, adessoMs: 1000 + i});
    assert.equal(d.concesso, true);
    stato = {inizio: d.inizio, quante: d.quante};
  }
  const no = decidiIlTetto({porta: "laTendinaDelCerchio", ...stato, adessoMs: 2000});
  assert.equal(no.concesso, false);
  assert.ok(no.mancaMs > 0);
  const dopo = decidiIlTetto({porta: "laTendinaDelCerchio", ...stato,
    adessoMs: 1000 + t.finestraMs});
  assert.equal(dopo.concesso, true);
  // La porta dei presenti ha il tetto piu' stretto di tutte.
  const altre = Object.entries(TETTI_DELLE_PORTE).filter(([n]) => n !== "laTendinaDelCerchio");
  for (const [nome, tetto] of altre) {
    assert.ok(tetto.quante / tetto.finestraMs >= t.quante / t.finestraMs || nome === "scegliIlNome" ||
      nome === "regalaGliEos" || nome === "compraUnPostoNelCerchio",
    `${nome} e' piu' stretta della tendina`);
  }
});

test("EY.16 GUARDIA: ogni porta del motore sociale ha il suo tetto", () => {
  const porte = fs.readFileSync(
    path.join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
  const nomi = [...porte.matchAll(/^export const (\w+) = onCall\(/gm)].map((m) => m[1]);
  const senza: string[] = [];
  for (const nome of nomi) {
    const i = porte.indexOf(`export const ${nome} = onCall(`);
    const corpo = porte.slice(i, porte.indexOf("\n});", i));
    if (!corpo.includes(`await tettoDellaPorta(uid, "${nome}");`)) senza.push(nome);
    if (TETTI_DELLE_PORTE[nome] === undefined) senza.push(`${nome} (nessun numero)`);
  }
  console.log(`EY.16 PORTE SOCIALI: ${nomi.length}, senza tetto ${senza.length}`);
  assert.equal(nomi.length, 16);
  assert.deepEqual(senza, []);
  assert.deepEqual(nomi.sort(), Object.keys(TETTI_DELLE_PORTE).sort());
  // E App Check resta spento, come dichiara la premessa P9.
  assert.ok(porte.includes("enforceAppCheck: false"));
});

test("EY.04 la pagina del link non si apre a chi ci scrive dentro", () => {
  const p = laPagina("<script>x</script>", "AB12CD34");
  assert.ok(!p.includes("<script>x"));
  assert.ok(p.includes("&lt;script&gt;"));
  assert.ok(p.includes("esotericircle://i/AB12CD34"));
  const scaduto = laPagina(null, null);
  assert.ok(scaduto.includes("non vale più"));
});

test("EZ.07 la pagina del link senza store non rimanda a uno store, col dato pieno si'", () => {
  const vuoti = {android: "", iphone: ""};
  const senza = laPagina("Lunaria", "AB12CD34", vuoti);
  const rimandi = (p: string) =>
    ["play.google.com", "apps.apple.com", "class=\"pulsante store\""]
      .filter((r) => p.includes(r));
  console.log(`EZ.07 LA PAGINA SENZA STORE: rimandi ${rimandi(senza).length}; ` +
    `il dato di oggi ${JSON.stringify(INDIRIZZI_DEGLI_STORE)}`);
  assert.deepEqual(rimandi(senza), []);
  assert.ok(senza.includes(RIGA_DEL_CODICE));
  assert.ok(senza.includes("AB12CD34"));
  assert.deepEqual(rimandi(laPagina(null, null, vuoti)), []);
  // Il dato di oggi e' vuoto: la pagina pubblicata non porta store.
  assert.deepEqual(rimandi(laPagina("Lunaria", "AB12CD34")), []);
  const pieno = laPagina("Lunaria", "AB12CD34", {
    android: "https://play.google.com/store/apps/details?id=com.esotericircle.esoteric_circle",
    iphone: "https://apps.apple.com/app/id1",
  });
  assert.equal((pieno.match(/class="pulsante store"/g) ?? []).length, 2);
});

test("EZ.04 la soglia dei quattordici anni: ogni porta sociale tranne quella che riceve l'eta'", () => {
  const porte = Object.keys(TETTI_DELLE_PORTE);
  assert.equal(porte.length, 16);
  const aperteSotto = porte.filter((p) => sogliaDellEtaPassata(p, false) ||
    sogliaDellEtaPassata(p, undefined));
  console.log(`EZ.04 LE PORTE APERTE SOTTO I QUATTORDICI ANNI: ${aperteSotto}`);
  assert.deepEqual(aperteSotto, [PORTA_CHE_RICEVE_L_ETA]);
  assert.ok(porte.every((p) => sogliaDellEtaPassata(p, true)));
  assert.equal(quattordiciDichiarati({quattordici: false, maggiorenne: true}), false);
  assert.equal(quattordiciDichiarati({maggiorenne: true}), true);
  assert.equal(quattordiciDichiarati({}), false);
  assert.equal(RIGA_DEI_QUATTORDICI, "Il Cerchio si apre a quattordici anni");
});

test("FA.01 le icone sono tre famiglie, e un Arcano ricade sul segno della persona", () => {
  assert.deepEqual(QUANTE_ICONE, {segno: 12, animale: 12, archetipo: 12});
  assert.equal(iconaValida("arcano:1"), null);
  assert.equal(iconaValida("archetipo:11"), "archetipo:11");
  assert.equal(iconaDelSegno("pisces"), "segno:11");
  assert.equal(iconaDelSegno(null), "segno:0");
  const pubblico = soloIlPubblico({nome: "Luce", icona: "arcano:1", segno: "pisces"});
  console.log(`FA.01 IL PROFILO PUBBLICO CON UN ARCANO: ${pubblico.icona}`);
  assert.equal(pubblico.icona, "segno:11");
});
