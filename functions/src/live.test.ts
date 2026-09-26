import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import {
  I_MODELLI_DELLA_VOCE, LE_CANDIDATE, LE_VOCI_DI_PARTENZA, eUnaVoceChirp,
  laStanzaE,
} from "./live";

/**
 * LA SESSIONE DEL LIVE SI CHIUDE, E SOLO DA CHI L'HA APERTA. Ordine EK, guasto
 * trovato fuori dal perimetro e curato col permesso del fondatore: uscendo,
 * il telefono lasciava la stanza ma la sessione di Protoface restava accesa
 * sessanta secondi, e 13 secondi a video sono stati fatturati 70.
 */
const sorgente = readFileSync(join(__dirname, "..", "src", "live.ts"), "utf8");

/** Il corpo di una funzione esportata, fino alla successiva. */
function corpoDi(nome: string): string {
  const inizio = sorgente.indexOf(`export const ${nome} =`);
  assert.ok(inizio >= 0, `${nome} non c'e' piu' in live.ts`);
  const dopo = sorgente.indexOf("\nexport ", inizio + 10);
  return sorgente.slice(inizio, dopo < 0 ? undefined : dopo);
}

test("la stanza si riconosce solo per chi l'ha aperta", () => {
  assert.equal(laStanzaE("abc", "live_abc_1790238356244"), true);
  assert.equal(laStanzaE("abc", "live_abcd_1790238356244"), false);
  assert.equal(laStanzaE("abc", "live_xyz_1790238356244"), false);
  assert.equal(laStanzaE("", "live__1790238356244"), false);
  assert.equal(laStanzaE("abc", ""), false);
});

test("la chiusura chiede a Protoface di finire la sessione, dopo aver guardato di chi e'", () => {
  const corpo = corpoDi("chiudiLaSessioneLive");
  assert.match(corpo, /\/sessions\/\$\{id\}\/end/);
  assert.match(corpo, /method: "POST"/);
  const guarda = corpo.indexOf("laStanzaE(uid, stanza)");
  const chiude = corpo.indexOf("/end`");
  assert.ok(guarda > 0 && chiude > guarda,
    "la sessione si chiude solo dopo aver verificato che e' della persona");
});

test("l'apertura legge l'avatar da Firestore, con la tabella come riserva", () => {
  const corpo = corpoDi("apriUnaSessioneLive");
  assert.match(corpo, /await lAvatarDi\(maestro\)/);
  assert.match(sorgente, /doc\("configurazione\/live"\)[\s\S]{0,200}avatar/);
});

/**
 * LE VOCI LE SCEGLIE IL FONDATORE, fra tutte. 24 settembre 2026, durante
 * l'ordine EK: "vorrei un selettore con le voci in modo che posso sceglierle
 * io. Quelle sentite finora fanno schifo".
 */
test("le candidate sono tutte le voci di Gemini del genere del Maestro, e le stesse in Chirp 3 HD", () => {
  // **Ordine EM voce 02**: alle voci di Gemini si aggiungono le stesse in
  // Chirp 3 HD, trenta voci italiane lette da /v1/voices sull'endpoint "eu"
  // il 25 settembre 2026, con lo stesso nome e lo stesso genere.
  const nomi = (m: string) => (LE_CANDIDATE[m] ?? [])
    .filter((c) => c.famiglia === "Gemini").map((c) => c.voce);
  const chirp = (m: string) => (LE_CANDIDATE[m] ?? [])
    .filter((c) => c.famiglia === "Chirp 3 HD");
  assert.equal(nomi("medora").length, 14);
  assert.equal(nomi("aura").length, 14);
  assert.equal(nomi("caligo").length, 16);
  for (const m of ["medora", "aura", "caligo"]) {
    assert.equal(chirp(m).length, nomi(m).length,
      `${m}: le voci Chirp non sono le stesse di Gemini`);
    for (const c of chirp(m)) {
      assert.ok(eUnaVoceChirp(c.voce), `${c.voce} non porta il prefisso Chirp`);
      assert.equal(c.voce, `Chirp3-HD-${c.nome}`);
      assert.ok(nomi(m).includes(c.nome),
        `${c.nome} in Chirp non ha la sua gemella in Gemini, cioe' il genere non torna`);
    }
    assert.equal((LE_CANDIDATE[m] ?? []).length, 2 * nomi(m).length);
  }
  assert.deepEqual(nomi("medora"), nomi("aura"));
  for (const v of ["Gacrux", "Sulafat", "Kore", "Leda", "Autonoe"]) {
    assert.ok(nomi("medora").includes(v), `${v} manca fra le voci di Medora`);
  }
  for (const v of ["Charon", "Algenib", "Rasalgethi", "Orus"]) {
    assert.ok(nomi("caligo").includes(v), `${v} manca fra le voci di Caligo`);
  }
  assert.ok(!nomi("caligo").some((v) => nomi("medora").includes(v)),
    "una voce femminile e' finita fra quelle di Caligo");
});

test("EO.15: la voce di partenza e' quella scelta dal fondatore, fra le candidate, ed e' Gemini", () => {
  // Il fondatore, 26 settembre 2026: "allego le voci da lasciare di default,
  // gia' scelte". Parla la partenza quando in configurazione/live.voci la
  // scelta manca: un profilo nuovo sente queste.
  const attese: Record<string, string> = {
    medora: "Erinome", aura: "Sulafat", caligo: "Algenib",
  };
  for (const [maestro, voce] of Object.entries(attese)) {
    assert.equal(LE_VOCI_DI_PARTENZA[maestro]?.voce, voce,
      `${maestro}: la voce di partenza non e' ${voce}`);
    const candidata = (LE_CANDIDATE[maestro] ?? []).find((c) => c.voce === voce);
    assert.ok(candidata, `${voce} non e' fra le candidate di ${maestro}`);
    assert.equal(candidata?.famiglia, "Gemini");
    assert.ok(!eUnaVoceChirp(voce));
  }
  assert.deepEqual(Object.keys(LE_VOCI_DI_PARTENZA).sort(),
    ["aura", "caligo", "medora"]);
  // E la partenza e' davvero cio' che parla quando la scelta manca.
  assert.match(sorgente, /const voce = valida \? scelta : partenza\.voce;/);
});

test("il modello della voce si sceglie solo fra quelli verificati, e lo usano il LIVE e l'ascolto", () => {
  assert.deepEqual(I_MODELLI_DELLA_VOCE,
    ["gemini-2.5-flash-tts", "gemini-2.5-pro-tts"]);
  assert.match(sorgente,
    /I_MODELLI_DELLA_VOCE\.includes\(modello\) \?\s*modello : MODELLO_DELLA_VOCE/);
  assert.match(corpoDi("laVoceDelMaestro"),
    /publishers\/google\/models\/\$\{come\.modello\}:/);
  assert.match(corpoDi("ascoltaUnaVoce"),
    /laVoceIntera\([\s\S]*?voce, modello\)/);
});

test("la porta degli avatar nuovi e' chiusa dall'IAM e aggancia solo un avatar pronto", () => {
  const corpo = corpoDi("gliAvatarNuoviDiProtoface");
  assert.match(corpo, /invoker: "private"/);
  const pronto = corpo.indexOf('a.status !== "ready"');
  const scrive = corpo.indexOf('doc("configurazione/live").set(');
  assert.ok(pronto > 0 && scrive > pronto,
    "l'aggancio scrive su Firestore solo dopo aver visto l'avatar pronto");
});

/**
 * **LE VOCI CHIRP PARLANO SOLO DALL'ENDPOINT "eu"**, a flusso e senza il
 * modo. Ordine EM voce 02: l'eccezione alla regione dei dati vale solo per
 * la voce e solo per "eu", mai per "global"; la sintesi intera voleva
 * 1.150-1.611 millesimi per il primo suono, quella a flusso 210-318.
 */
test("le voci Chirp parlano solo dall'endpoint eu, a flusso e senza modo", () => {
  assert.match(sorgente,
    /const PUNTO_DELLE_VOCI_CHIRP = "eu-texttospeech\.googleapis\.com";/);
  assert.match(sorgente, /streamingSynthesize\(\)/);
  // Nessun indirizzo della voce senza la sua regione: "global" e' vietato.
  const globali = sorgente.match(/(?<![a-z0-9-])texttospeech\.googleapis\.com/g) ?? [];
  assert.equal(globali.length, 0, "c'e' un indirizzo di Text-to-Speech senza regione");
  const corpo = corpoDi("laVoceDelMaestro");
  assert.match(corpo, /laVoceChirpAFlusso\(testo, come\.voce,/,
    "la voce Chirp del LIVE riceve il testo senza il modo");
  assert.match(corpoDi("ascoltaUnaVoce"),
    /laVoceChirpAFlusso\(LA_FRASE_DI_PROVA\[maestro\], voce,/);
});

/**
 * **LA VOCE SCELTA VALE SUBITO, E IL REGISTRO DICE QUALE VOCE HA PARLATO.**
 * Ordine EM voce 06: la scelta restava in memoria un minuto per servizio, e
 * nessun registro diceva la voce usata.
 */
test("la voce scelta si rilegge entro tre secondi e il registro dice quale voce ha parlato", () => {
  const vale = /const LA_SCELTA_VALE_MS = (\d+);/.exec(sorgente);
  assert.ok(vale, "manca il tempo per cui una lettura della scelta vale");
  assert.ok(Number(vale[1]) <= 5000,
    `la scelta resta in memoria ${vale[1]} millesimi: il LIVE parlerebbe con la voce vecchia`);
  assert.match(sorgente, /ora - scelteInCache\.quando > LA_SCELTA_VALE_MS/);
  const corpo = corpoDi("laVoceDelMaestro");
  const registri = corpo.match(/logger\.info\("voce del Maestro", \{[^}]*\}/g) ?? [];
  assert.equal(registri.length, 2, "servono due registri della voce, Gemini e Chirp");
  for (const r of registri) {
    assert.match(r, /voce: come\.voce/, "il registro della voce non dice quale voce");
    assert.match(r, /punto:/, "il registro della voce non dice da quale endpoint");
  }
});

/**
 * **CALÌGO NON RALLENTA.** Ordine EM voce 12: col modo "voce grave e matura
 * di uomo, con calma naturale" le sue sedici voci parlavano fra 9,1 e 11,1
 * caratteri al secondo; qualunque parola sul timbro rallenta.
 */
test("il modo di Calìgo non porta le parole che lo rallentano", () => {
  const modo = /caligo: "([^"]*)" \+\s*"([^"]*)"/.exec(
    sorgente.slice(sorgente.indexOf("const I_MODI")));
  assert.ok(modo, "il modo di Calìgo non si trova in I_MODI");
  const testo = (modo[1] + modo[2]).toLowerCase();
  for (const parola of ["grave", "matur", "calma", "lent", "profond", "anzian"]) {
    assert.ok(!testo.includes(parola),
      `il modo di Calìgo dice "${parola}", e le sue voci rallentano`);
  }
  assert.ok(testo.includes("madrelingua"),
    "il modo di Calìgo ha perso la pronuncia di madrelingua");
});
