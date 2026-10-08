import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {
  domandeDellaSettimana,
  esitoDellaSfida,
  figuraDi,
  ilRitornoDi,
  INDOVINELLI_AL_GIORNO,
  laClassifica,
  laDomanda,
  lunaValida,
  metaDelPellegrinaggio,
  numeroDellaSettimana,
  piuVicini,
  punteggioDi,
  puoComparire,
  quattroVolti,
  rispostaDellIndovinello,
  ritrattoValido,
  SCOMMESSE_AL_GIORNO,
  scommessaAmmessa,
  settimanaValida,
  sfidaPerIlPiano,
  Volto,
} from "./gli_enigmi";

/**
 * GLI ENIGMI DEL CERCHIO, la parte senza database. Ordine FF.
 */
const venti = Array.from({length: 20}, (_, i) => i + 1);

test("FF.02 c) il Ritratto si scrive solo con venti tratti diversi del corpus", () => {
  assert.deepEqual(ritrattoValido(venti), venti);
  assert.equal(ritrattoValido(venti.slice(0, 19)), null);
  assert.equal(ritrattoValido([...venti.slice(0, 19), 1]), null);
  assert.equal(ritrattoValido([...venti.slice(0, 19), 121]), null);
  assert.equal(ritrattoValido("1,2,3"), null);
});

const volti: Volto[] = [
  {uid: "a", ritratto: [1, 2, 3].map(String), segno: "leo", archetipo: null},
  {uid: "b", ritratto: [1, 2, 4].map(String), segno: "aries", archetipo: "mago"},
  {uid: "c", ritratto: [1, 5, 3].map(String), segno: "taurus", animale: "lupo"},
  {uid: "d", ritratto: [2, 4, 5].map(String), segno: "cancer"},
];

test("FF.04 b) la risposta giusta viene da un dato vero e appartiene a uno solo", () => {
  for (let i = 0; i < 40; i++) {
    const r = laDomanda(volti, `seme-${i}`);
    assert.ok(r);
    const giusta = volti.find((v) => v.uid === r.giusta);
    assert.ok(giusta);
    const chi = volti.filter((v) => {
      switch (r.domanda.tipo) {
      case "tratto": return v.ritratto.includes(r.domanda.valore);
      case "archetipo": return v.archetipo === r.domanda.valore;
      case "animale": return v.animale === r.domanda.valore;
      case "elemento": return ["leo", "aries"].includes(String(v.segno)) ?
        r.domanda.valore === "fuoco" : true;
      }
    });
    if (r.domanda.tipo !== "elemento") {
      assert.deepEqual(chi.map((v) => v.uid), [r.giusta]);
    }
  }
  // Lo stesso seme, la stessa domanda.
  assert.deepEqual(laDomanda(volti, "x"), laDomanda(volti, "x"));
  // Il Mago esce solo per chi ha pubblicato l'archetipo.
  const tipi = new Set(Array.from({length: 60},
    (_, i) => laDomanda(volti, `t${i}`)?.domanda.tipo));
  assert.ok(tipi.size >= 3, `tipi visti: ${[...tipi]}`);
});

test("FF.04 i quattro volti vengono dai candidati e sono fissi per il seme", () => {
  const otto = Array.from({length: 8}, (_, i) => ({uid: `p${i}`}));
  const q = quattroVolti(otto, "s");
  assert.equal(q.length, 4);
  assert.deepEqual(q, quattroVolti(otto, "s"));
  assert.ok(q.every((v) => otto.includes(v)));
});

test("FF.04 d) la risposta al giocatore e il ritorno all'indovinato non portano chi gioca", () => {
  const r = rispostaDellIndovinello({giusta: true, punti: 3, uidGiusto: "b"});
  assert.deepEqual(Object.keys(r).sort(), ["era", "giusta", "punti"]);
  const ritorno = ilRitornoDi({perDomanda: {"archetipo:mago": {quanti: 2,
    segni: ["leo", "virgo"], rivelati: 1}}});
  assert.deepEqual(ritorno, [{chiave: "archetipo:mago", quanti: 2,
    segni: ["leo"], daScoprire: 1}]);
  // Nessun identificativo viaggia nel ritorno.
  assert.ok(!JSON.stringify(ritorno).includes("uid"));
});

test("FF.04 e) e FF.05 e) i limiti per piano: tre, dieci, poi tetti ampi", () => {
  assert.deepEqual(INDOVINELLI_AL_GIORNO, {free: 3, tier1: 10, tier2: 50, tier3: 150});
  assert.deepEqual(SCOMMESSE_AL_GIORNO, {free: 1, tier1: 3, tier2: 15, tier3: 45});
  assert.equal(sfidaPerIlPiano("free"), false);
  assert.equal(sfidaPerIlPiano("tier1"), true);
});

test("FF.05 la settimana, le domande e il punteggio come sul telefono", () => {
  assert.equal(settimanaValida("2026-10-12"), "2026-10-12");
  assert.equal(settimanaValida("2026-10-13"), null);
  assert.equal(numeroDellaSettimana("2026-10-12"), 42);
  assert.equal(numeroDellaSettimana("2026-01-05"), 2);
  // Settimana 42: 42 % 12 = 6, si saltano la settima e l'ottava domanda.
  assert.deepEqual(domandeDellaSettimana("2026-10-12"),
    [1, 2, 3, 4, 5, 6, 9, 10, 11, 12]);
  // Tutte le risposte d (posizione 3): nel tema 1 pesano tutte 3.
  assert.equal(punteggioDi(1, "2026-10-12", Array(10).fill(3)), 100);
  assert.equal(punteggioDi(1, "2026-10-12", Array(10).fill(0)), 0);
  assert.equal(punteggioDi(1, "2026-10-12", Array(9).fill(0)), null);
  assert.equal(punteggioDi(9, "2026-10-12", Array(10).fill(0)), null);
  assert.equal(figuraDi(1, 30), "La Soglia");
  assert.equal(figuraDi(2, 80), "Il Fuoco");
});

test("FF.05 la scommessa: vince chi si avvicina di piu', a pari tutti", () => {
  assert.deepEqual(piuVicini([{chi: "x", valore: 40}, {chi: "y", valore: 70}], 60), ["y"]);
  assert.deepEqual(piuVicini([{chi: "x", valore: 50}, {chi: "y", valore: 70}], 60), ["x", "y"]);
  assert.deepEqual(piuVicini([], 60), []);
});

test("FF.06 d) la sfida a due si chiude dopo ventiquattro ore e il punto va a chi ha giocato", () => {
  const base = {da: "x", a: "y", scade: 1000, punteggioDa: 60, stimaDa: 50};
  assert.equal(esitoDellaSfida(base, 999), null);
  assert.deepEqual(esitoDellaSfida(base, 1000), {vincitori: ["x"], perche: "tempo"});
  assert.deepEqual(esitoDellaSfida({...base, punteggioA: 52, stimaA: 70}, 10),
    {vincitori: ["x"], perche: "stime"});
  assert.deepEqual(esitoDellaSfida({...base, punteggioA: 40, stimaA: 61}, 10),
    {vincitori: ["y"], perche: "stime"});
});

test("FF.06 la classifica ordina solo per indovinelli azzeccati", () => {
  const c = laClassifica([{uid: "a", indovinati: 2}, {uid: "b", indovinati: 5},
    {uid: "c", indovinati: 2}]);
  assert.deepEqual(c.map((p) => p.uid), ["b", "a", "c"]);
});

test("FF.06 la meta del Pellegrinaggio non si raggiunge da soli", () => {
  assert.ok(metaDelPellegrinaggio(1) > 7);
  assert.equal(metaDelPellegrinaggio(5), 20);
  assert.equal(lunaValida("2026-10-26", "2026-10-20"), "2026-10-26");
  assert.equal(lunaValida("2026-10-27", "2026-10-20"), null);
  assert.equal(lunaValida("2026-10-19", "2026-10-20"), null);
});

test("FF.04 c) chi spegne l'interruttore non compare in nessun gioco, su un Cerchio di otto", () => {
  const otto = Array.from({length: 8}, (_, i) => ({
    uid: `p${i}`,
    ritratto: Array.from({length: 20}, (_, k) => k + 1),
    // Due persone si sono tolte dai giochi, una non ha il Ritratto.
    fuoriDaiGiochi: i === 2 || i === 5,
    quattordici: true,
  }));
  otto[7].ritratto = [1, 2, 3];
  const candidati = otto.filter((p) => puoComparire(p));
  assert.deepEqual(candidati.map((p) => p.uid), ["p0", "p1", "p3", "p4", "p6"]);
  const viste = new Set<string>();
  for (let s = 0; s < 200; s++) {
    for (const v of quattroVolti(candidati, `seme-${s}`)) viste.add(v.uid);
  }
  for (const fuori of ["p2", "p5", "p7"]) assert.ok(!viste.has(fuori), fuori);
  assert.equal(puoComparire({ritratto: otto[0].ritratto, quattordici: false}), false);
});

test("FF.05 d) la scommessa non si piazza dopo che l'amico ha fatto la Prova", () => {
  assert.equal(scommessaAmmessa({provaDellAmico: true, gia: false, usateOggi: 0, limite: 3}), "tardi");
  assert.equal(scommessaAmmessa({provaDellAmico: false, gia: true, usateOggi: 0, limite: 3}), "gia");
  assert.equal(scommessaAmmessa({provaDellAmico: false, gia: false, usateOggi: 1, limite: 1}), "limite");
  assert.equal(scommessaAmmessa({provaDellAmico: false, gia: false, usateOggi: 0, limite: 1}), "ok");
});

test("FF.04 d) cio' che viaggia verso chi e' indovinato non porta chi indovina", () => {
  // La porta scrive nel ramo dell'indovinato solo il numero e il segno: la
  // misura legge la scrittura vera nel sorgente della porta.
  const porta = readFileSync("src/il_cerchio_sociale.ts", "utf8");
  const i = porta.indexOf("tx.set(statoDi(giustaUid, \"indovinato\")");
  assert.ok(i > 0, "la scrittura del ritorno non si trova");
  const scrittura = porta.slice(i, porta.indexOf("{merge: true});", i));
  assert.ok(!/\buid\b/.test(scrittura.replace("giustaUid", "")),
    `il ritorno porta un identificativo: ${scrittura}`);
  assert.ok(scrittura.includes("io.segno"));
  // E la partita che torna a chi gioca non porta il Ritratto fotografato.
  const vista = porta.slice(porta.indexOf("function vistaDellaPartita"),
    porta.indexOf("export const scopriUnSegno"));
  assert.ok(!vista.includes("dati"), "la vista della partita porta il Ritratto altrui");
});
