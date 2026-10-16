import {test} from "node:test";
import assert from "node:assert/strict";
import * as fs from "fs";
import * as path from "path";
import {
  CollanaADueDati,
  DURATA_DEL_RESPIRO_INSIEME_MS,
  GIORNI_INDIETRO_DELLA_RICUCITURA,
  RICUCITURE_MASSIME_PER_CICLO,
  RIGHE_DELLA_RICUCITURA,
  collanaADueDa,
  dataCivileValida,
  decidiLaRicucitura,
  giorniFraDateCivili,
  idDellaCollanaADue,
} from "./il_cerchio_sociale";
import {EOS_DELLA_PERLA_RICUCITA, TETTI_DELLE_PORTE} from "./sociale";

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

// ---------------------------------------------------------------------------
// LA RICUCITURA VERA DI UNA PERLA, ordine FX aggiunta FXA.03
// ---------------------------------------------------------------------------

const OGGI = "2026-10-16";
const CICLO = "2026-10-10";

test("FXA.03 la ricucitura: i giorni civili si contano senza fusi", () => {
  assert.equal(giorniFraDateCivili("2026-10-09", "2026-10-16"), 7);
  assert.equal(giorniFraDateCivili("2026-10-16", "2026-10-09"), -7);
  // Il passaggio all'ora solare (25 ottobre 2026) non sposta il conto.
  assert.equal(giorniFraDateCivili("2026-10-24", "2026-10-26"), 2);
  assert.equal(giorniFraDateCivili("2026-02-28", "2026-03-01"), 1);
});

test("FXA.03 la ricucitura: un giorno valido della settimana passata e' nuovo", () => {
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: CICLO, oggi: OGGI, ricucite: {}}),
    {esito: "nuova"});
  // Il settimo giorno indietro e' l'ultimo ammesso, l'ottavo no.
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-09", inizioCiclo: "2026-10-01", oggi: OGGI,
      ricucite: {}}),
    {esito: "nuova"});
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-08", inizioCiclo: "2026-10-01", oggi: OGGI,
      ricucite: {}}),
    {esito: "rifiutata", perche: "troppoIndietro"});
});

test("FXA.03 la ricucitura: il futuro, il ciclo e il tetto si rifiutano", () => {
  const rifiuti = [
    decidiLaRicucitura({giorno: "2026-10-17", inizioCiclo: CICLO, oggi: OGGI, ricucite: {}}),
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: "2026-10-13", oggi: OGGI,
      ricucite: {}}),
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: "2026-09-01", oggi: OGGI,
      ricucite: {}}),
    decidiLaRicucitura({giorno: "2026-10-15", inizioCiclo: CICLO, oggi: OGGI,
      ricucite: {"2026-10-11": {}, "2026-10-12": {}, "2026-10-13": {}}}),
  ].map((d) => d.esito === "rifiutata" ? d.perche : d.esito);
  console.log(`FXA.03 MISURA i rifiuti: ${rifiuti.join(", ")}`);
  assert.deepEqual(rifiuti,
    ["futuro", "primaDelCiclo", "cicloTroppoLontano", "tettoDelCiclo"]);
  // Oggi stesso non e' futuro: chi sta in un fuso avanti rispetto a Roma
  // ricuce il suo ieri, che per il server e' ancora oggi.
  assert.deepEqual(
    decidiLaRicucitura({giorno: OGGI, inizioCiclo: CICLO, oggi: OGGI, ricucite: {}}),
    {esito: "nuova"});
  for (const perche of Object.keys(RIGHE_DELLA_RICUCITURA)) {
    assert.ok(RIGHE_DELLA_RICUCITURA[perche as keyof typeof RIGHE_DELLA_RICUCITURA].length > 0);
  }
});

test("FXA.03 la ricucitura: il tetto conta i giorni, non l'etichetta del ciclo", () => {
  // Tre perle gia' ricucite nel ciclo; il telefono sposta l'inizio di un
  // giorno sperando in un tetto nuovo: i giorni cadono ancora nella
  // finestra, e il tetto tiene.
  const ricucite = {"2026-10-11": {ciclo: CICLO}, "2026-10-12": {ciclo: CICLO},
    "2026-10-13": {ciclo: CICLO}};
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-15", inizioCiclo: "2026-10-11", oggi: OGGI,
      ricucite}),
    {esito: "rifiutata", perche: "tettoDelCiclo"});
  // Le perle di un ciclo chiuso non pesano sul ciclo nuovo.
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: CICLO, oggi: OGGI,
      ricucite: {"2026-09-20": {}, "2026-09-21": {}, "2026-09-22": {}}}),
    {esito: "nuova"});
});

test("FXA.03 la ricucitura: lo stesso giorno due volte e' idempotente, mai un rifiuto", () => {
  const ricucite = {"2026-10-11": {}, "2026-10-12": {}, "2026-10-13": {}};
  // Anche col tetto pieno e anche dopo l'uscita dalla finestra dei sette
  // giorni, il giorno gia' ricucito torna "gia": niente seconda spesa.
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: CICLO, oggi: OGGI, ricucite}),
    {esito: "gia"});
  assert.deepEqual(
    decidiLaRicucitura({giorno: "2026-10-12", inizioCiclo: CICLO, oggi: "2026-10-25",
      ricucite}),
    {esito: "gia"});
});

test("FXA.03 GUARDIA: il prezzo e le regole del server sono quelli del telefono", () => {
  const radice = path.join(__dirname, "..", "..");
  const listino = fs.readFileSync(
    path.join(radice, "lib", "core", "entitlement", "listino_degli_eos.dart"), "utf8");
  const voce = /static const perlaRicucita = VoceDelListino\([\s\S]*?costo: (\d+),/.exec(listino);
  assert.ok(voce !== null, "la voce perlaRicucita non si trova nel listino del telefono");
  const respiro = fs.readFileSync(
    path.join(radice, "lib", "core", "lunario", "il_listino_del_respiro.dart"), "utf8");
  const numero = (nome: string) => {
    const m = new RegExp(`static const int ${nome} = ([0-9]+);`).exec(respiro);
    assert.ok(m !== null, `${nome} non si trova in il_listino_del_respiro.dart`);
    return Number(m[1]);
  };
  console.log(`FXA.03 MISURA il prezzo: server ${EOS_DELLA_PERLA_RICUCITA}, ` +
    `telefono ${voce[1]}`);
  assert.equal(EOS_DELLA_PERLA_RICUCITA, Number(voce[1]));
  assert.equal(EOS_DELLA_PERLA_RICUCITA, numero("costoRicucituraInEos"));
  assert.equal(RICUCITURE_MASSIME_PER_CICLO, numero("massimePerleRicucitePerCiclo"));
  assert.equal(GIORNI_INDIETRO_DELLA_RICUCITURA, numero("massimoGiorniIndietro"));
});

test("FXA.03 GUARDIA: la porta spende col prezzo del server e il giorno del server", () => {
  const porte = fs.readFileSync(
    path.join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
  const i = porte.indexOf("export const ricuciUnaPerlaDelRespiro = onCall(");
  assert.ok(i >= 0, "la porta non esiste, o non sta su una riga sola (EY.16)");
  const corpo = porte.slice(i, porte.indexOf("\n});", i));
  assert.ok(corpo.includes("await tettoDellaPorta(uid, \"ricuciUnaPerlaDelRespiro\");"));
  assert.ok(corpo.includes("chiaveDelGiorno()"), "oggi deve essere quello del server");
  assert.ok(corpo.includes("db().runTransaction"), "spesa e ricucitura in una transazione");
  assert.ok(corpo.includes("importo: -EOS_DELLA_PERLA_RICUCITA"));
  assert.ok(!/request\.data\?\.(importo|costo|prezzo)/.test(corpo),
    "il prezzo non arriva mai dal telefono");
  assert.ok(TETTI_DELLE_PORTE.ricuciUnaPerlaDelRespiro !== undefined);
  const indice = fs.readFileSync(path.join(__dirname, "..", "src", "index.ts"), "utf8");
  assert.ok(/^\s*ricuciUnaPerlaDelRespiro,$/m.test(indice),
    "index.ts non la riesporta: il deploy non la vedrebbe (ordine FW)");
});
