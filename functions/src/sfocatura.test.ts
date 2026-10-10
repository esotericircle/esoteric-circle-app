import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

import {
  GIORNI_INTERI,
  MAESTRI,
  MASSIMI_TURNI_PER_SFOCATURA,
  MODELLO_DELLA_SFOCATURA,
  QUANTI_PER_GIRO,
  chiaveDellaSettimana,
  confineDellaFinestra,
} from "./sfocatura";

/**
 * LA MEMORIA A STRATI E LA SFOCATURA SETTIMANALE. Ordine CG voce 09.
 *
 * **Cosa si prova qui e cosa no.** Qui si provano le DECISIONI e i CONFINI:
 * quanto e' larga la finestra, come si raggruppa una settimana, che il lavoro
 * giri una volta a settimana e non a ogni conversazione, e che il modello sia
 * quello economico. Che le sintesi vengano scritte davvero si vede
 * sull'emulatore.
 */

const sorgente = readFileSync(
  join(__dirname, "..", "src", "sfocatura.ts"),
  "utf8"
);

test("la finestra e' larga il doppio del ritmo del lavoro", () => {
  // **La ragione, e non solo il numero.** Il lavoro gira una volta a
  // settimana: con sette giorni di finestra una conversazione di lunedi'
  // potrebbe essere sfocata il lunedi' dopo, cioe' nel momento esatto in cui
  // smette di essere "questa settimana".
  assert.equal(GIORNI_INTERI, 14);
  assert.ok(
    GIORNI_INTERI >= 14,
    `la finestra e' ${GIORNI_INTERI} giorni: sotto i quattordici una ` +
      "conversazione puo' sfumare nella settimana in cui qualcuno potrebbe " +
      "ancora tornarci sopra"
  );

  const adesso = Date.UTC(2026, 7, 31);
  const confine = confineDellaFinestra(adesso);
  const giorniIndietro = (adesso - confine.toMillis()) / (24 * 60 * 60 * 1000);
  assert.equal(giorniIndietro, 14);
});

test("il lavoro gira UNA VOLTA A SETTIMANA, non a ogni conversazione", () => {
  // **E' la differenza fra 0,029 e 0,0084 dollari per utente al mese.**
  assert.ok(
    sorgente.includes('schedule: "10 4 * * 1"'),
    "il lavoro non gira il lunedi': la sfocatura a lotti settimanali e' la " +
      "decisione che regge il conto del costo"
  );
  assert.ok(
    sorgente.includes('timeZone: "Europe/Rome"'),
    "senza fuso l'ora notturna cade in mezzo alla giornata di qualcuno"
  );
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  assert.ok(
    indice.includes("sfocaLeConversazioni"),
    "il lavoro non e' esportato, quindi Firebase non lo conosce"
  );
});

test("una settimana gia' sfocata non si rifa'", () => {
  // Senza questo controllo il giro settimanale ripagherebbe ogni volta tutte
  // le settimane vecchie, e il costo crescerebbe invece di restare fermo.
  assert.ok(
    sorgente.includes("if (gia.exists) continue;"),
    "manca il controllo sulla settimana gia' sfocata"
  );
});

test("le settimane si contano dal lunedi', come la timeline", () => {
  // Due modi di dire "che settimana e'" nello stesso progetto darebbero due
  // raggruppamenti diversi degli stessi giorni.
  const lunedi = new Date(Date.UTC(2026, 7, 24));
  const domenica = new Date(Date.UTC(2026, 7, 30));
  const lunediDopo = new Date(Date.UTC(2026, 7, 31));
  assert.equal(
    chiaveDellaSettimana(lunedi),
    chiaveDellaSettimana(domenica),
    "lunedi' e domenica della stessa settimana devono cadere insieme"
  );
  assert.notEqual(
    chiaveDellaSettimana(domenica),
    chiaveDellaSettimana(lunediDopo),
    "domenica e il lunedi' dopo sono due settimane diverse"
  );
});

test("il modello e' il piu' economico, e non e' Anthropic", () => {
  assert.ok(
    MODELLO_DELLA_SFOCATURA.includes("flash-lite"),
    `il modello e' ${MODELLO_DELLA_SFOCATURA}: il compito e' riassumere una ` +
      "manciata di turni, non ragionare"
  );
  // Si guarda il CODICE e non i commenti: la regola d'oro dello stack si
  // spiega scrivendo "mai una API Anthropic", e una guardia che cercasse
  // quella parola nel file intero cadrebbe sulla riga che dichiara la regola.
  const soloCodice = sorgente
    .split("\n")
    .filter((r) => {
      const t = r.trimStart();
      return !t.startsWith("//") && !t.startsWith("*") && !t.startsWith("/*");
    })
    .join("\n");
  for (const vietato of ["anthropic", "Anthropic", "claude"]) {
    assert.ok(
      !soloCodice.includes(vietato),
      `il codice nomina ${vietato}: il runtime resta Google`
    );
  }
});

test("i tetti del giro esistono e sono coerenti", () => {
  assert.ok(QUANTI_PER_GIRO > 0 && QUANTI_PER_GIRO <= 500);
  assert.ok(
    MASSIMI_TURNI_PER_SFOCATURA > 0,
    "senza tetto sui turni una persona molto attiva farebbe morire il giro"
  );
  assert.equal(MAESTRI.length, 3, "i Maestri sono tre");
});

test("la sfocatura NON cancella niente", () => {
  // La cancellazione dei testi la fa scadenze.ts a 365 giorni, che e' lo
  // strato tre. Due posti che cancellano lo stesso dato sarebbero due verita'
  // su quando quel dato sparisce.
  assert.ok(
    !sorgente.includes(".delete()"),
    "la sfocatura cancella qualcosa: il suo mestiere e' riassumere, e la " +
      "cancellazione vive in scadenze.ts"
  );
  const scadenze = readFileSync(
    join(__dirname, "..", "src", "scadenze.ts"),
    "utf8"
  );
  assert.ok(
    scadenze.includes('giorni: 365'),
    "i messaggi non scadono piu' a un anno: lo strato tre e' cambiato senza " +
      "che nessuno lo abbia scritto"
  );
});
