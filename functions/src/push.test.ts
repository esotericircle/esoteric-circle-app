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
  finestraDi,
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
  // LAPIDE, ordine ES voce 17: la finestra era [fascia, fascia + 15), e col
  // giro fuori dal quarto d'ora un'ora scelta partiva prima dell'ora. Adesso
  // la finestra e' [fascia - 14, fascia], dalla funzione finestraDi.
  assert.ok(
    sorgente.includes('.where("minutiUtc", ">=", da)'),
    "il giro non filtra sulla finestra: leggerebbe tutti gli utenti a ogni " +
      "giro, cioe' diciannove volte il costo"
  );
  assert.ok(
    sorgente.includes('.where("minutiUtc", "<=", a)'),
    "il giro non chiude la finestra: prenderebbe tutti quelli dopo"
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

test("ES.17: la push arriva come dato, e la notifica la fa l'app", () => {
  // LAPIDE, ordine ES voce 17: qui si pretendeva il tag `dono_<id>` sulla
  // notifica della push, creduto la cura del doppione. Su Android un avviso
  // si riconosce dalla coppia tag e identificativo: la locale e' (nessun tag,
  // 1104), la push mostrata dal sistema era (dono_1104, 0), e il fondatore ne
  // ha ricevute tre per un Dono. Adesso la push porta solo il Dono, e l'app la
  // mostra con l'identificativo della locale (AvvisiDelRito.allaPushDelDono).
  const invio = sorgente.slice(sorgente.indexOf("getMessaging().send({"));
  const corpoDellInvio = invio.slice(0, invio.indexOf("});"));
  assert.ok(
    !corpoDellInvio.includes("notification:"),
    "la push porta di nuovo una notifica fatta: il sistema la mostrerebbe " +
      "accanto alla chiamata locale, e la persona riceverebbe due volte lo " +
      "stesso Dono"
  );
  assert.ok(corpoDellInvio.includes("data: {dono}"), "la push non dice il Dono");
  assert.ok(
    sorgente.includes("const spinti = new Set<string>();"),
    "due righe con lo stesso telefono spingerebbero due volte lo stesso Dono"
  );
  assert.ok(
    sorgente.includes('.where("token", "==", token)'),
    "le righe di altri account con lo stesso telefono restano"
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
    // LAPIDE, ordine ES voce 17: "Caligo" si scrive con l'accento.
    assert.ok(
      ["Medora", "Aura", "Calìgo"].includes(testo.titolo),
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

test("ES.17: nessuna push prima dell'ora del menu', e la mezzanotte", () => {
  // Il giro serve gli ultimi quindici minuti fino al suo: un'ora scelta
  // alle 22:40 (1240 in UTC d'estate si sposta, qui conta il minuto) parte
  // al giro delle 22:45, mai a quello delle 22:30.
  const servito = (minuto: number, fascia: number) =>
    finestraDi(fascia).some(([da, a]) => minuto >= da && minuto <= a);
  for (let minuto = 0; minuto < 1440; minuto++) {
    const giri = [];
    for (let fascia = 0; fascia < 1440; fascia += 15) {
      if (servito(minuto, fascia)) giri.push(fascia);
    }
    assert.equal(giri.length, 1, `il minuto ${minuto} e' servito ${giri.length} volte`);
    const giro = giri[0];
    const ritardo = (giro - minuto + 1440) % 1440;
    assert.ok(ritardo >= 0 && ritardo <= 14,
      `il minuto ${minuto} parte al giro ${giro}, ${ritardo} minuti dopo`);
  }
  assert.deepEqual(finestraDi(0), [[1426, 1439], [0, 0]]);
  assert.deepEqual(finestraDi(1230), [[1216, 1230]]);
});

test("ES.17: il giro gira sul quarto d'ora dell'orologio", () => {
  // "every 15 minutes" partiva da quando il lavoro era nato: 22:43.
  assert.ok(sorgente.includes("schedule: `*/${PASSO_IN_MINUTI} * * * *`"),
    "il giro non gira sul quarto d'ora");
  assert.ok(!sorgente.includes("schedule: `every"),
    "il giro gira ancora da quando e' nato");
});

test("ES.17: il Sigillo del Sogno e' di Medora", () => {
  assert.equal(TESTI.night.titolo, "Medora");
  assert.equal(TESTI.rune.titolo, "Calìgo");
});
