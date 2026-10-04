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
  TETTI_DELLE_PORTE,
  codiceScritto,
  costruisciLIstantanea,
  decidiIlGift,
  decidiIlSegno,
  decidiIlTetto,
  decidiLInvito,
  donoPerIlPiano,
  eUnSigillo,
  leggiIlCodiceDellInvito,
  lettureAllOra,
  quandoSiRiapreIlNome,
  reazioneValida,
  registraLoScambio,
  semaforoPer,
  sigilloScritto,
  soloIlPubblico,
  somiglianti,
  unCodice,
  unSigillo,
  visibilitaEffettiva,
} from "./sociale";
import {laPagina} from "./la_pagina_dell_invito";

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
    chiPuoInvitare: "tutti", ...cosa};
}

test("EY.08 l'istantanea: aggregato per arte senza gli invisibili", () => {
  const ist = costruisciLIstantanea([
    presenza("a"), presenza("b", {arte: "viaggio"}),
    presenza("c", {visibilita: "invisibile"}), presenza("d", {visibilita: "amici"}),
  ], 10);
  assert.deepEqual(ist.perArte, {tarocchi: 2, viaggio: 1});
  assert.deepEqual(ist.presenti.map((p) => p.uid), ["a", "b", "d"]);
});

test("EY.08 le persone simili: al massimo dodici, mescolate per giorno e per chi guarda", () => {
  const molte = Array.from({length: 40}, (_, i) => presenza(`p${i}`));
  molte.push(presenza("minore", {maggiorenne: false}));
  molte.push(presenza("soloAmici", {visibilita: "amici"}));
  molte.push(presenza("amico"));
  const ist = costruisciLIstantanea(molte, 10);
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

test("EY.08 LA MISURA DELLE LETTURE: istantanea contro via ingenua, mille presenti", () => {
  // Un telefono con la tendina aperta che la chiede una volta al minuto per
  // un'ora, con cento telefoni che la chiedono nello stesso mezzo minuto.
  const m = lettureAllOra({presenti: 1000, aperturePerOra: 60, telefoniCheChiedono: 100});
  console.log(`EY.08 LETTURE PER TELEFONO IN UN'ORA con mille presenti: ` +
    `istantanea ${m.conLIstantanea}, via ingenua ${m.viaIngenua}`);
  assert.equal(m.viaIngenua, 120000);
  assert.ok(m.conLIstantanea < 1000, `troppe letture: ${m.conLIstantanea}`);
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
