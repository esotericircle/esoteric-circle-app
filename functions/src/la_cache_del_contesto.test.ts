import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

import {
  SOGLIA_DI_ACCENSIONE,
  SOGLIA_DI_SPEGNIMENTO,
  VITA_DELLA_CACHE_SECONDI,
  costoAlMese,
  costoDellaCacheAllOra,
  decidi,
  pareggio,
  risparmioPerRichiesta,
} from "./la_cache_del_contesto";

/**
 * LA CACHE DEL CONTESTO. Ordine EX Aggiunta 4, voce EX.05.
 *
 * Qui si prova la DECISIONE e il suo conto: la soglia calcolata e dichiarata,
 * il traffico simulato sotto e sopra la soglia (i due casi che l'ordine
 * chiede), il costo al mese a 10, 50 e 200 richieste all'ora. Che la cache
 * nasca davvero su Vertex si vede solo dopo la pubblicazione del fondatore.
 *
 * Si eseguono con `npm test` dentro functions/.
 */

test("la soglia e' il pareggio fra la conservazione e il risparmio", () => {
  assert.equal(costoDellaCacheAllOra().toFixed(4), "0.0289");
  assert.equal(risparmioPerRichiesta().toFixed(5), "0.00130");
  assert.equal(pareggio().toFixed(1), "22.2");
  assert.equal(SOGLIA_DI_ACCENSIONE, 23);
  assert.equal(SOGLIA_DI_SPEGNIMENTO, 18);
});

/**
 * Un giorno di traffico, un giro ogni dieci minuti, come la funzione: quante
 * ore la cache resta accesa.
 */
function unGiorno(richiesteAllOra: (ora: number) => number): {
  oreAccesa: number;
  accensioni: number;
} {
  let accesa = false;
  let giriAccesa = 0;
  let accensioni = 0;
  for (let giro = 0; giro < 24 * 6; giro++) {
    const prima = accesa;
    accesa = decidi(richiesteAllOra(Math.floor(giro / 6)), accesa);
    if (accesa && !prima) accensioni++;
    if (accesa) giriAccesa++;
  }
  return {oreAccesa: giriAccesa / 6, accensioni};
}

test("CASO 1, sotto la soglia: un giorno a 10 richieste all'ora, sempre spenta",
  () => {
    const g = unGiorno(() => 10);
    assert.equal(g.oreAccesa, 0);
    assert.equal(g.accensioni, 0);
    // Spenta non costa niente: il costo e' quello senza cache.
    assert.equal(costoAlMese(10, "interruttore"), costoAlMese(10, "senza"));
  });

test("CASO 2, sopra la soglia: un giorno a 50 richieste all'ora, sempre accesa",
  () => {
    const g = unGiorno(() => 50);
    assert.equal(g.oreAccesa, 24);
    assert.equal(g.accensioni, 1);
    assert.ok(costoAlMese(50, "interruttore") < costoAlMese(50, "senza"));
  });

test("un giorno vero: si accende la sera e si spegne la notte, una volta", () => {
  // Poco la notte, 40 all'ora dalle 18 alle 23, 20 alle 23.
  const g = unGiorno((ora) => (ora >= 18 && ora < 23 ? 40 : ora === 23 ? 20 : 5));
  assert.equal(g.accensioni, 1);
  // Accesa dalle 18 a mezzanotte: alle 23 i 20 stanno sopra lo spegnimento.
  assert.equal(g.oreAccesa, 6);
});

test("il traffico che oscilla intorno alla soglia non la fa ballare", () => {
  const g = unGiorno((ora) => (ora % 2 === 0 ? 24 : 19));
  assert.equal(g.accensioni, 1, "si e' accesa e spenta piu' volte");
});

test("i costi al mese a 10, 50 e 200 richieste all'ora", () => {
  const righe = [10, 50, 200].map((n) => ({
    n,
    senza: costoAlMese(n, "senza"),
    sempre: costoAlMese(n, "sempre"),
    interruttore: costoAlMese(n, "interruttore"),
  }));
  for (const r of righe) {
    console.log(
      `${r.n} richieste all'ora: senza cache ${r.senza.toFixed(2)} $, ` +
        `cache sempre accesa ${r.sempre.toFixed(2)} $, con l'interruttore ` +
        `${r.interruttore.toFixed(2)} $, risparmio ` +
        `${(100 * (1 - r.interruttore / r.senza)).toFixed(0)} per cento`
    );
  }
  // Sotto la soglia la cache sempre accesa costerebbe di piu': l'interruttore
  // la tiene spenta.
  assert.ok(righe[0].sempre > righe[0].senza);
  assert.equal(righe[0].interruttore, righe[0].senza);
  // Sopra, risparmia: a 200 richieste all'ora oltre il 70 per cento
  // dell'inizio dell'istruzione.
  assert.ok(righe[2].interruttore < righe[2].senza * 0.3);
});

test("spenta, le cache scadono da sole: la vita e' il doppio del giro", () => {
  const sorgente = readFileSync(
    join(__dirname, "..", "src", "la_cache_del_contesto.ts"),
    "utf8"
  );
  assert.ok(sorgente.includes('schedule: "every 10 minutes"'));
  assert.equal(VITA_DELLA_CACHE_SECONDI, 20 * 60);
  // Da spenta il giro non rinnova e non crea niente.
  const spenta = sorgente.slice(
    sorgente.indexOf("if (!accesa) {"),
    sorgente.indexOf("const p = prefissi();")
  );
  assert.ok(!spenta.includes("creaLaCache"));
  assert.ok(!spenta.includes("rinnova("));
});
