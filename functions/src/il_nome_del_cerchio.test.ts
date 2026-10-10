import {test} from "node:test";
import assert from "node:assert/strict";
import {
  REGOLE_DEL_NOME,
  eOffensivo,
  eRiservato,
  formeDiConfronto,
  verdettoDelNome,
} from "./il_nome_del_cerchio";

/**
 * IL NOME NEL CERCHIO, ordine EY voce 01. La guardia dei nomi riservati e la
 * prova che le regole non cadano sui nomi veri delle persone.
 */

/** Le forme in cui qualcuno prova a prendersi un nome del Cerchio. */
function travestimenti(nome: string): string[] {
  const cifre: Record<string, string> = {e: "3", a: "4", o: "0", i: "1", s: "5", t: "7"};
  const unaCifra = [...nome].map((c, i) => {
    const sost = cifre[c.toLowerCase()];
    return sost === undefined ? null :
      nome.slice(0, i) + sost + nome.slice(i + 1);
  }).filter((x): x is string => x !== null);
  const tutteLeCifre = [...nome].map((c) => cifre[c.toLowerCase()] ?? c).join("");
  return [
    nome,
    nome.toLowerCase(),
    nome.toUpperCase(),
    `${nome}.`,
    `.${nome}`,
    `${nome}_`,
    `${nome}77`,
    `${nome} 1`,
    nome.replace(/ /g, "."),
    nome.replace(/ /g, "_"),
    nome.replace(/ /g, ""),
    tutteLeCifre,
    ...unaCifra,
    // L'accento sulla lettera non cambia il nome per l'occhio.
    nome.replace(/a/, "à").replace(/e/, "è").replace(/i/, "ì").replace(/o/, "ò"),
  ].filter((x) => [...x].length >= 3 && [...x].length <= 20);
}

test("GUARDIA EY.01: nessun nome riservato passa, in nessuna sua forma", () => {
  const passati: string[] = [];
  let provati = 0;
  for (const riservato of REGOLE_DEL_NOME.riservati) {
    for (const forma of travestimenti(riservato)) {
      provati++;
      if (verdettoDelNome(forma).ok) passati.push(forma);
    }
  }
  // L'elenco chiuso dell'ordine, enumerato: se qualcuno ne toglie uno dal
  // dato, questa prova lo dice.
  assert.deepEqual(REGOLE_DEL_NOME.riservati, [
    "Medora", "Aura", "Caligo", "Esoteric", "Circle", "Esoteric Circle", "Eos",
    "staff", "admin", "amministratore", "moderatore", "supporto", "assistenza",
    "ufficiale", "verificato",
  ]);
  console.log(`EY.01 RISERVATI: ${REGOLE_DEL_NOME.riservati.length} nomi, ` +
    `${provati} forme provate, passate ${passati.length}`);
  assert.ok(provati >= 200, `troppo poche forme provate: ${provati}`);
  assert.deepEqual(passati, []);
});

test("i travestimenti dell'ordine cadono col controllo dei riservati", () => {
  for (const n of ["M3dora", "medora.", "MEDORA", "Calìgo", "ca1igo",
    "Medora77", "staff medora", "LaMedora", "Esoteric_Circle", "EsotericCircle",
    "4ura", "E0s", "Medora ufficiale"]) {
    assert.equal(eRiservato(n), true, `${n} dovrebbe essere del Cerchio`);
    assert.equal(verdettoDelNome(n).perche, "riservato", n);
  }
});

test("la e cirillica non apre un nome del Cerchio", () => {
  // "Меdora" con la M e la e cirilliche: per l'occhio e' Medora.
  const cirillico = "Меdora";
  assert.ok(formeDiConfronto(cirillico).includes("medora"));
  assert.equal(eRiservato(cirillico), true);
  assert.equal(verdettoDelNome(cirillico).ok, false);
});

/** Nomi veri e parole innocue che contengono pezzi dei riservati o degli insulti. */
const NOMI_VERI = [
  "Laura", "Aurora", "Leos", "Eosforo", "Medoro", "Ignazio", "Montenegro",
  "Produce", "Magnifica", "Pacifica", "Calcolo", "Troiano", "Dickens",
  "Assunta", "Scunthorpe", "Cassandra", "Duccio", "Federica", "Francesca",
  "Giulia", "Sofia", "Aurelio", "Mauro", "Marco", "Luca", "Giovanni", "Anna",
  "Chiara", "Elena", "Paolo", "Stefano", "Alessandra", "Valentina", "Martina",
  "Lunaria", "Stella Lieve", "Lince Serena", "Volpe.Ardente", "Corvo_Quieto",
  "Seme di Luna", "Eco 2026", "Fiamma Gentile", "Sognatrice", "Roberta",
  "Circe", "Eolo", "Aureliano", "Paura", "Taurus", "Restaurato", "Centauro",
  "Stafford", "Cristina", "Benedetta", "Assistente Lunare",
];

test("le regole non cadono sui nomi veri e sulle parole innocue", () => {
  const caduti = NOMI_VERI.filter((n) => !verdettoDelNome(n).ok)
    .map((n) => `${n} (${verdettoDelNome(n).perche})`);
  console.log(`EY.01 NOMI VERI: ${NOMI_VERI.length} provati, caduti ${caduti.length}`);
  assert.deepEqual(caduti, []);
});

test("il filtro delle parole offensive cade sulle sue voci", () => {
  const provate = [
    ...REGOLE_DEL_NOME.offensiveContenute.map((r) => `Xx${r}xX`),
    ...REGOLE_DEL_NOME.offensiveParola.map((p) => `Sono ${p}`),
    ...REGOLE_DEL_NOME.offensiveParola,
  ].filter((n) => [...n].length >= 3 && [...n].length <= 20);
  const passate = provate.filter((n) => !eOffensivo(n));
  console.log(`EY.01 OFFENSIVE: ${REGOLE_DEL_NOME.offensiveContenute.length} ` +
    `radici e ${REGOLE_DEL_NOME.offensiveParola.length} parole, ` +
    `${provate.length} forme provate, passate ${passate.length}`);
  assert.deepEqual(passate, []);
});

test("la forma del nome: lunghezza, caratteri, spazi", () => {
  assert.equal(verdettoDelNome("Lu").perche, "corto");
  assert.equal(verdettoDelNome("Un nome lungo davvero troppo").perche, "lungo");
  assert.equal(verdettoDelNome("Luna​ria").perche, "caratteri");
  assert.equal(verdettoDelNome("Luna\nria").perche, "caratteri");
  assert.equal(verdettoDelNome("Luna-ria").perche, "caratteri");
  assert.equal(verdettoDelNome("Luna  ria").perche, "spazi");
  assert.equal(verdettoDelNome("  Lunaria  ").ok, true);
  assert.equal(verdettoDelNome("  Lunaria  ").nome, "Lunaria");
  assert.equal(verdettoDelNome("Lunà_ria.7").ok, true);
});

test("i verdetti condivisi col telefono: stessi nomi, stessa decisione", () => {
  const prove = JSON.parse(
    require("node:fs").readFileSync(
      require("node:path").join(__dirname, "..", "src", "il_nome_del_cerchio_prove.json"),
      "utf8")) as {casi: [string, string | null][]};
  const diversi = prove.casi
    .filter(([nome, atteso]) => verdettoDelNome(nome).perche !== atteso)
    .map(([nome, atteso]) => `${JSON.stringify(nome)}: atteso ${atteso}, ` +
      `dato ${verdettoDelNome(nome).perche}`);
  console.log(`EY.01 VERDETTI CONDIVISI: ${prove.casi.length} casi, diversi ${diversi.length}`);
  assert.ok(prove.casi.length >= 40);
  assert.deepEqual(diversi, []);
});
