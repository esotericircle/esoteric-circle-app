import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import {laStanzaE} from "./live";

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

test("la porta degli avatar nuovi e' chiusa dall'IAM e aggancia solo un avatar pronto", () => {
  const corpo = corpoDi("gliAvatarNuoviDiProtoface");
  assert.match(corpo, /invoker: "private"/);
  const pronto = corpo.indexOf('a.status !== "ready"');
  const scrive = corpo.indexOf('doc("configurazione/live").set(');
  assert.ok(pronto > 0 && scrive > pronto,
    "l'aggancio scrive su Firestore solo dopo aver visto l'avatar pronto");
});
