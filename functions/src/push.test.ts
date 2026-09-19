import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

import {
  DONI,
  ID_DEL_DONO,
  MASSIMI_DESTINATARI_PER_GIRO,
  PASSO_IN_MINUTI,
  TESTI,
  fasciaDi,
  minutiUtc,
} from "./push";

/**
 * LE PUSH DEI DONI. Ordine CG voce 16.
 *
 * **Cosa si prova qui e cosa no.** Qui si provano le DECISIONI e i CONTI: che
 * il giro chieda solo i destinatari del quarto d'ora e non tutti gli utenti,
 * che l'ora si converta una volta sola, che la push porti lo stesso
 * identificativo della chiamata locale, e che i cinque Doni ci siano tutti.
 * Che i messaggi arrivino davvero si vede sul telefono del fondatore.
 */

const sorgente = readFileSync(join(__dirname, "..", "src", "push.ts"), "utf8");

test("CG.16 d: il giro chiede solo i destinatari della fascia", () => {
  // **E' il conto che tiene il costo sotto i cinquanta dollari al mese a un
  // milione di persone.** Scorrendo tutti gli utenti sarebbero 864.
  assert.ok(
    sorgente.includes('.where("minutiUtc", ">=", fascia)'),
    "il giro non filtra sulla fascia: leggerebbe tutti gli utenti a ogni " +
      "giro, cioe' diciannove volte il costo"
  );
  assert.ok(
    sorgente.includes('.where("minutiUtc", "<", fascia + PASSO_IN_MINUTI)'),
    "il giro non chiude la fascia: prenderebbe tutti quelli dopo"
  );
  assert.ok(
    !sorgente.includes('db.collection("users").get()'),
    "il giro scorre tutti gli utenti"
  );
  assert.ok(
    sorgente.includes(".limit(MASSIMI_DESTINATARI_PER_GIRO)"),
    "il giro non ha un tetto"
  );
  assert.ok(MASSIMI_DESTINATARI_PER_GIRO > 0);
});

test("CG.16: novantasei giri al giorno, dentro le chiamate gratuite", () => {
  const giriAlGiorno = (24 * 60) / PASSO_IN_MINUTI;
  assert.equal(giriAlGiorno, 96);
  const alMese = giriAlGiorno * 30;
  assert.ok(
    alMese < 2000000,
    `${alMese} chiamate al mese: sopra i due milioni gratuiti del listino`
  );
});

test("CG.16 e la fascia: ogni minuto cade in una fascia sola", () => {
  const fasce = new Set<number>();
  for (let m = 0; m < 1440; m++) {
    const quando = new Date(Date.UTC(2026, 7, 31, Math.floor(m / 60), m % 60));
    fasce.add(fasciaDi(quando));
  }
  assert.equal(
    fasce.size,
    1440 / PASSO_IN_MINUTI,
    "le fasce non coprono la giornata: qualche minuto non riceverebbe mai"
  );
  assert.equal(fasciaDi(new Date(Date.UTC(2026, 7, 31, 7, 14))), 420);
  assert.equal(fasciaDi(new Date(Date.UTC(2026, 7, 31, 7, 15))), 435);
});

test("CG.16: l'ora si converte in UTC e resta dentro il giorno", () => {
  // **La conversione si fa UNA VOLTA, quando la persona sceglie.** Se l'ora
  // restasse locale, ogni giro dovrebbe leggere tutti e convertire.
  for (const fuso of ["Europe/Rome", "Asia/Tokyo", "America/New_York"]) {
    for (const minuti of [0, 419, 420, 1200, 1439]) {
      const utc = minutiUtc(minuti, fuso);
      assert.ok(
        utc >= 0 && utc < 1440,
        `${fuso} a ${minuti} da' ${utc}, fuori dal giorno`
      );
    }
  }
  // Tokyo sta avanti a Roma, quindi la stessa ora locale cade prima in UTC.
  const roma = minutiUtc(420, "Europe/Rome");
  const tokyo = minutiUtc(420, "Asia/Tokyo");
  assert.notEqual(
    roma,
    tokyo,
    "Roma e Tokyo convertono la stessa ora locale allo stesso minuto UTC: " +
      "vorrebbe dire che il fuso non entra nel conto, e a Tokyo la push " +
      "arriverebbe alle sette del mattino di Roma"
  );
});

test("CG.16 punto 4: la push porta lo STESSO identificativo della locale", () => {
  // **E' cosi' che si chiude il doppione.** Su Android un avviso con un tag
  // gia' presente sostituisce quello di prima invece di affiancarlo.
  assert.ok(
    sorgente.includes("tag: `dono_${ID_DEL_DONO[dono]}`"),
    "la push non porta il tag della chiamata locale: alla stessa ora la " +
      "persona riceverebbe due volte lo stesso Dono"
  );
  // E i numeri sono quelli veri di AvvisiDelRito, che parte da 1100.
  assert.equal(ID_DEL_DONO.dawn, 1100);
  assert.equal(
    new Set(Object.values(ID_DEL_DONO)).size,
    DONI.length,
    "due Doni condividono un identificativo: uno sostituirebbe l'altro"
  );
});

test("CG.16: tutti e cinque i Doni sono coperti, con la voce del Maestro", () => {
  assert.equal(DONI.length, 5, "i Doni sono cinque");
  for (const dono of DONI) {
    const testo = TESTI[dono];
    assert.ok(testo, `il Dono ${dono} non ha un testo`);
    assert.ok(
      ["Medora", "Aura", "Caligo"].includes(testo.titolo),
      `il Dono ${dono} non parla con la voce di un Maestro: dice ` +
        `"${testo.titolo}", e l'ordine vuole il Maestro proprietario e non ` +
        "un avviso di sistema"
    );
    assert.ok(testo.corpo.length > 20, `il testo di ${dono} e' troppo corto`);
    assert.ok(
      ID_DEL_DONO[dono] !== undefined,
      `il Dono ${dono} non ha un identificativo`
    );
  }
});

test("CG.16 e: spegnere un Dono lo toglie davvero dal server", () => {
  // Senza la cancellazione delle righe vecchie, spegnere un Dono lo
  // lascerebbe acceso sul server e la persona continuerebbe a ricevere cio'
  // che ha spento.
  assert.ok(
    sorgente.includes("vecchie.docs.forEach((d) => lotto.delete(d.ref));"),
    "le righe vecchie non si tolgono prima di scrivere le nuove"
  );
  assert.ok(
    sorgente.includes("togliLeScelteDellePush"),
    "manca la via che toglie il token quando la persona se ne va"
  );
});

test("CG.16: un token morto si toglie invece di riprovare per sempre", () => {
  assert.ok(
    sorgente.includes("await riga.ref.delete();"),
    "un token che rifiuta la spinta resta li' e il server riprova ogni " +
      "giorno verso un indirizzo che non esiste piu'"
  );
});

test("CG.16: l'uid viene dal token e mai dal corpo", () => {
  assert.ok(sorgente.includes("request.auth?.uid"));
  assert.ok(
    !/data\?\.\s*uid/.test(sorgente),
    "l'uid viene dal corpo: chiunque potrebbe scrivere le scelte di un altro"
  );
});

test("CG.16: le tre vie sono esportate", () => {
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  for (const nome of [
    "scriviLeScelteDellePush",
    "togliLeScelteDellePush",
    "spingiIDoni",
  ]) {
    assert.ok(indice.includes(nome), `${nome} non e' esportata`);
  }
});
