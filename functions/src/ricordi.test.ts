import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

/**
 * L'INDICE DEI RICORDI, LATO SERVER. Ordine CG voce 03.
 *
 * **Cosa si prova qui e cosa no.** Qui si provano la FORMA e i TETTI, cioe' le
 * decisioni: che il mese si scriva con `merge` su una mappa e non su una
 * lista, che i tetti esistano e siano coerenti col tetto piu' alto della
 * matrice, che la data che la pulizia legge sia il mese e non la sincronia.
 * Che due apparecchi si fondano davvero si vede sull'emulatore.
 *
 * Si eseguono con `npm test` dentro functions/.
 */

const sorgente = readFileSync(
  join(__dirname, "..", "src", "ricordi.ts"),
  "utf8"
);

test("il mese si scrive con merge su una MAPPA, non su una lista", () => {
  // **E' la decisione che regge i due apparecchi.** Con una lista, il secondo
  // che sincronizza cancella le righe del primo; con una mappa e `merge` si
  // sommano. Una prova sul sorgente perche' e' una scelta di forma, e una
  // scelta di forma si rovescia con una riga distratta.
  assert.ok(
    sorgente.includes("{merge: true}"),
    "la scrittura del mese non fonde: un secondo apparecchio cancellerebbe " +
      "le righe del primo"
  );
  assert.ok(
    !sorgente.includes("FieldValue.arrayUnion"),
    "le righe sono tornate una lista: la fusione per chiave non funziona piu'"
  );
});

test("la data che la pulizia legge e' il MESE, non la sincronia", () => {
  // **Senza questo, un mese del 2024 risincronizzato oggi non scadrebbe mai.**
  assert.ok(
    sorgente.includes("quando: primoIstanteDel(mese)"),
    "il campo quando non porta il primo istante del mese"
  );
  const scadenze = readFileSync(
    join(__dirname, "..", "src", "scadenze.ts"),
    "utf8"
  );
  assert.ok(
    scadenze.includes('.where("quando", "<", confineDi("ricordi"'),
    "la pulizia dei Ricordi non cerca il campo quando"
  );
  assert.ok(
    scadenze.includes('db.collectionGroup("ricordi")'),
    "la pulizia non arriva ai Ricordi di tutti gli utenti"
  );
});

test("i tetti esistono e stanno sopra il tetto piu' alto della matrice", () => {
  // L'Illuminato ha 250 voci al giorno: in un mese di trentun giorni sono
  // 7.750. Un tetto sotto quel numero rifiuterebbe la sincronia di una
  // persona che usa l'app come il piano le permette.
  const massimeRighe = /MASSIME_RIGHE_PER_MESE = (\d+)/.exec(sorgente);
  assert.ok(massimeRighe, "il tetto delle righe non e' dichiarato");
  const tetto = Number(massimeRighe![1]);
  assert.ok(
    tetto >= 250 * 31,
    `il tetto e' ${tetto}, sotto le ${250 * 31} voci che un Illuminato puo' ` +
      "fare in un mese: la sua sincronia verrebbe rifiutata"
  );

  const massimiByte = /MASSIMI_BYTE_PER_CHIAMATA = (\d+)/.exec(sorgente);
  assert.ok(massimiByte, "il tetto dei byte non e' dichiarato");
  assert.ok(
    Number(massimiByte![1]) < 1048576,
    "il tetto dei byte sta sopra il limite di un documento Firestore: una " +
      "sincronia accettata qui verrebbe poi rifiutata dalla scrittura"
  );
});

test("il nome del mese si valida, e non finisce dritto in un percorso", () => {
  // Un nome di documento che arriva dal client senza controllo e' una via per
  // scrivere dove non si deve.
  assert.ok(
    sorgente.includes("FORMA_DEL_MESE") &&
      sorgente.includes("/^\\d{4}-\\d{2}$/"),
    "il nome del mese non e' vincolato alla forma AAAA-MM"
  );
  assert.ok(
    sorgente.includes("FORMA_DEL_MESE.test(mese)"),
    "la forma e' dichiarata e non usata"
  );
});

test("l'uid viene dal token e mai dal corpo", () => {
  assert.ok(
    sorgente.includes("request.auth?.uid"),
    "l'uid non viene dal token"
  );
  assert.ok(
    !/data\?\.\s*uid/.test(sorgente),
    "l'uid viene letto dal corpo: chiunque potrebbe scrivere sui Ricordi " +
      "di un altro"
  );
});

test("le tre callable sono esportate, altrimenti Firebase non le conosce", () => {
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  for (const nome of ["scriviIRicordi", "leggiIRicordi", "leggiIMovimenti"]) {
    assert.ok(indice.includes(nome), `${nome} non e' esportata`);
  }
});

test("i movimenti si leggono dal server, ordinati e con un tetto", () => {
  // **La voce CG.10 chiede i DUE ANNI del server, non gli otto del
  // telefono.** Senza l'ordinamento decrescente la lettura restituirebbe i
  // movimenti piu' vecchi, cioe' esattamente quelli che non servono.
  assert.ok(
    sorgente.includes('.orderBy("quando", "desc")'),
    "i movimenti non sono ordinati dal piu' recente"
  );
  const tetto = /QUANTI_MOVIMENTI_PER_GIRO = (\d+)/.exec(sorgente);
  assert.ok(tetto, "il tetto dei movimenti non e' dichiarato");
  assert.ok(
    Number(tetto![1]) > 8,
    `il tetto e' ${tetto![1]}: gli otto del telefono bastano al borsellino e ` +
      "non ai Ricordi, e questa voce esiste per superarli"
  );
  assert.ok(
    sorgente.includes(".limit(quanti)"),
    "la lettura non ha un tetto: una persona di due anni la pagherebbe a peso"
  );
});
