import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

import {
  LAPIDI_DA_SISTEMARE,
  improntaColPepe,
  improntaSenzaSale,
} from "./lapidi";

/**
 * LE LAPIDI VECCHIE. Ordine CG voce 15.
 *
 * **Cosa si prova qui e cosa no.** Qui si provano le DECISIONI: che i due
 * gesti siano quelli che il fondatore ha ordinato, che il lavoro non apra
 * nessuna superficie nuova su un dato antifrode, e che il ripesamento
 * conservi la data. Che le lapidi vengano davvero sistemate si vede sul dato
 * vero, e il rapporto porta il conto prima e dopo.
 */

const sorgente = readFileSync(join(__dirname, "..", "src", "lapidi.ts"), "utf8");

test("i due gesti sono quelli che il fondatore ha ordinato", () => {
  const perEmail = new Map(LAPIDI_DA_SISTEMARE.map((v) => [v.email, v.gesto]));
  assert.equal(
    perEmail.get("maobatta@gmail.com"),
    "cancella",
    "la lapide del fondatore SI CANCELLA e non si ricalcola: cancellarla gli " +
      "restituisce il benvenuto quando rifa' l'onboarding"
  );
  assert.equal(
    perEmail.get("cloud@esotericircle.app"),
    "ripesa",
    "l'altra lapide col sale vuoto si RIPESA col pepe: finche' resta col " +
      "sale vuoto, chiunque conosca l'indirizzo sa se ha gia' incassato"
  );
});

test("l'impronta col sale vuoto e' quella delle lapidi vecchie", () => {
  // La debolezza che il pepe e' venuto a chiudere: chiunque conosca
  // l'indirizzo puo' calcolare l'identificativo.
  assert.equal(
    improntaSenzaSale("cloud@esotericircle.app"),
    "b24dc7957aecb2ec0aa3902815fa0e46d762655d165d8646078d068101fee0b5",
    "l'impronta col sale vuoto non coincide piu' con la lapide vera letta " +
      "da Firestore il 31 agosto 2026: o il calcolo e' cambiato, o la " +
      "lapide non e' quella"
  );
  assert.equal(
    improntaSenzaSale("maobatta@gmail.com"),
    "e79399895e1db263174386b98c3fb3d6f45ab3f12752c570898419caee2dcd3e"
  );
});

test("col pepe l'impronta cambia, e il pepe non si stampa", () => {
  const prima = process.env.BENVENUTO_PEPPER;
  process.env.BENVENUTO_PEPPER = "un-pepe-di-prova";
  try {
    const conPepe = improntaColPepe("cloud@esotericircle.app");
    assert.notEqual(
      conPepe,
      improntaSenzaSale("cloud@esotericircle.app"),
      "col pepe l'impronta deve cambiare, altrimenti il pepe non e' montato"
    );
    assert.ok(!conPepe.includes("un-pepe-di-prova"), "il pepe non esce");
  } finally {
    if (prima === undefined) {
      delete process.env.BENVENUTO_PEPPER;
    } else {
      process.env.BENVENUTO_PEPPER = prima;
    }
  }
});

test("nessuna superficie nuova: e' un lavoro a orario, non una callable", () => {
  // **La ragione, e vale piu' della scelta.** Una callable che accettasse un
  // indirizzo e riscrivesse una lapide sarebbe una superficie nuova su un
  // dato antifrode: chiunque la raggiungesse potrebbe provare indirizzi e
  // leggere dalle risposte chi ha gia' incassato il benvenuto.
  assert.ok(
    sorgente.includes("onSchedule"),
    "il lavoro non e' a orario"
  );
  assert.ok(
    !sorgente.includes("onCall"),
    "e' nata una callable sulle lapidi: e' una superficie nuova su un dato " +
      "antifrode, e l'ordine CF voce 17 aveva gia' rifiutato di aprirla"
  );
  assert.ok(
    !sorgente.includes("request.data"),
    "entra qualcosa dal di fuori: gli indirizzi da sistemare sono dichiarati " +
      "nel codice e non arrivano da nessuno"
  );
});

test("il ripesamento CONSERVA la data della lapide", () => {
  // La scadenza delle lapidi si conta da `quando`: rimetterla a oggi
  // allungherebbe di due anni la vita di un dato antifrode che avrebbe
  // dovuto scadere prima.
  assert.ok(
    sorgente.includes("{...dati, ripesataIl: new Date()}"),
    "il ripesamento non conserva i campi della lapide vecchia"
  );
  assert.ok(
    !sorgente.includes("quando: new Date()"),
    "il ripesamento rimette la data a oggi"
  );
});

test("prima si scrive la nuova, poi si cancella la vecchia", () => {
  // Se il giro morisse in mezzo, resterebbe una lapide di troppo e non una di
  // meno: l'antifrode resta piu' stretto e mai piu' largo.
  const scrive = sorgente.indexOf("await nuova.set(");
  const cancella = sorgente.indexOf("await vecchia.delete();", scrive);
  assert.ok(scrive > 0 && cancella > scrive,
    "la vecchia si cancella prima che la nuova sia scritta: un giro " +
      "interrotto lascerebbe l'antifrode piu' largo");
});

test("il registro non nomina nessuna email", () => {
  // Un registro che nominasse le email rimetterebbe in chiaro cio' che
  // l'impronta esiste per nascondere.
  const righeDiLog = sorgente
    .split("\n")
    .filter((r) => r.includes("logger."));
  for (const riga of righeDiLog) {
    assert.ok(
      !riga.includes("voce.email") && !riga.includes("${email"),
      `una riga di registro nomina un indirizzo: ${riga.trim()}`
    );
  }
});

test("il lavoro e' esportato e chiede il segreto del pepe", () => {
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  assert.ok(
    indice.includes("sistemaLeLapidi"),
    "il lavoro non e' esportato, quindi Firebase non lo conosce"
  );
  assert.ok(
    sorgente.includes('secrets: ["BENVENUTO_PEPPER"]'),
    "senza dichiarare il segreto, in functions v2 process.env resta vuoto e " +
      "il ripesamento scriverebbe un'altra impronta col sale vuoto"
  );
});
