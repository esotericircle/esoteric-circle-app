import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import {ACCOUNT_DI_COLLAUDO, eUnCollaudo, spazioDi} from "./i_collaudi";

/**
 * I COLLAUDI HANNO UNO SPAZIO PROPRIO DELLA PRESENZA. Ordine FD voce 05.
 *
 * Il giro del Cerchio popolato fra due telefoni di collaudo non deve leggere
 * ne' scrivere documenti di utenti reali: le presenze e l'istantanea dei
 * collaudi stanno in `collaudo_cerchio_presenze` e `collaudo_cerchio_adesso`.
 */
const SOCIALE = readFileSync(join(__dirname, "..", "src", "il_cerchio_sociale.ts"), "utf8");
const CERCHIO = readFileSync(join(__dirname, "..", "src", "cerchio.ts"), "utf8");

test("gli account del registro sono collaudi, gli altri no", () => {
  const uids = Object.keys(ACCOUNT_DI_COLLAUDO);
  assert.ok(uids.length >= 1, "il registro dei collaudi e' vuoto");
  for (const uid of uids) {
    assert.equal(eUnCollaudo(uid), true);
    assert.equal(spazioDi(uid), "collaudo_");
  }
  assert.equal(spazioDi("un-utente-qualunque"), "");
  assert.equal(eUnCollaudo("toString"), false,
    "un nome ereditato dall'oggetto non e' un collaudo");
});

test("ogni via alla presenza condivisa passa dallo spazio di chi chiama", () => {
  // Nessun nome di raccolta della presenza scritto senza lo spazio davanti.
  for (const [nome, s] of [["il_cerchio_sociale.ts", SOCIALE], ["cerchio.ts", CERCHIO]]) {
    const nudi = s.split("\n").filter((r) =>
      !r.trim().startsWith("*") && !r.trim().startsWith("//") &&
      /["'`](cerchio_presenze|cerchio_adesso)["'`]/.test(r));
    assert.deepEqual(nudi, [], `${nome}: una raccolta della presenza senza lo spazio`);
  }
  const conLoSpazio = SOCIALE.match(/\$\{spazio\}cerchio_(presenze|adesso)/g) ?? [];
  assert.ok(conLoSpazio.length >= 4,
    `le raccolte con lo spazio dovevano essere almeno 4, sono ${conLoSpazio.length}`);
  // Chi legge l'istantanea dice sempre lo spazio di chi chiama.
  const chiamate = [...SOCIALE.matchAll(/istantanea\(\{ricostruisci: (true|false)([^}]*)\}\)/g),
    ...CERCHIO.matchAll(/istantanea\(\{ricostruisci: (true|false)([^}]*)\}\)/g)];
  assert.ok(chiamate.length >= 3, `le letture dell'istantanea sono ${chiamate.length}`);
  for (const c of chiamate) {
    assert.match(c[2], /spazio: spazioDi\(/, `una lettura senza lo spazio: ${c[0]}`);
  }
  assert.match(SOCIALE, /const doc = FRAMMENTO\(frammentoDi\(uid\), spazioDi\(uid\)\);/);
});
