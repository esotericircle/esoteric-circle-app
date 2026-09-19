import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";

import {SCADENZE, QUANTI_PER_GIRO} from "./scadenze";

/**
 * LE SCADENZE DEI DATI. Ordine CB voce 05.
 *
 * **Cosa si prova qui e cosa no.** Qui si prova la DECISIONE: che ogni
 * categoria abbia un tempo, che ogni tempo porti la sua ragione scritta, e che
 * la condizione che sceglie i documenti sia quella e non un'altra. Che il
 * lavoro notturno cancelli davvero si vede sull'emulatore, e la riga per
 * lanciarlo sta nel manifesto dell'ordine.
 *
 * Si eseguono con `npm test` dentro functions/.
 */

test("ogni categoria ha un tempo, e nessuno e' per sempre", () => {
  const nomi = Object.keys(SCADENZE);
  assert.ok(nomi.length >= 5, "le categorie censite sono meno di cinque");
  for (const nome of nomi) {
    const s = SCADENZE[nome];
    assert.ok(s.giorni > 0, `${nome} non ha un tempo`);
    assert.ok(
      s.giorni <= 730,
      `${nome} tiene ${s.giorni} giorni: oltre i due anni serve una ragione ` +
        "che nessuno ha ancora scritto"
    );
  }
  console.log(
    "ORDINE CB VOCE 05: categorie con scadenza",
    nomi.map((n) => `${n} ${SCADENZE[n].giorni}g`).join(", ")
  );
});

test("ogni scadenza porta la sua motivazione, e non e' una frase vuota", () => {
  // **E' IL FONDATORE A CHIEDERLO**: "ogni tempo scelto porta con se' la sua
  // motivazione scritta in una riga. Una scadenza senza motivazione non e'
  // accettata".
  for (const [nome, s] of Object.entries(SCADENZE)) {
    assert.ok(
      s.perche.length > 60,
      `${nome} scade senza dire perche': "${s.perche}"`
    );
    assert.ok(s.nome.length > 3, `${nome} non ha un nome leggibile`);
  }
});

test("il giro ha un tetto, altrimenti muore a meta'", () => {
  assert.ok(QUANTI_PER_GIRO > 0 && QUANTI_PER_GIRO <= 500);
});

test("si cerca il campo della data che quella collezione scrive davvero", () => {
  // **UN CAMPO SBAGLIATO NON DA' ERRORE**: la query trova zero documenti e la
  // pulizia non cancella niente, per sempre, in silenzio. I messaggi portano
  // `createdAt`, tutto il resto porta `quando`: si legge il codice che scrive
  // e quello che cancella, e si confrontano.
  const scadenze = readFileSync(join(__dirname, "..", "src", "scadenze.ts"), "utf8");
  const cerchio = readFileSync(join(__dirname, "..", "src", "cerchio.ts"), "utf8");

  assert.ok(
    cerchio.includes("createdAt: FieldValue.serverTimestamp()"),
    "i messaggi non portano piu' createdAt"
  );
  assert.ok(
    scadenze.includes('.where("createdAt", "<", confineDi("messaggi"'),
    "la pulizia dei messaggi non cerca createdAt"
  );
  for (const collezione of ["consumi", "movimenti", "lapidi", "congedi", "ricordi"]) {
    assert.ok(
      scadenze.includes(`.where("quando", "<", confineDi("${collezione}"`),
      `la pulizia di ${collezione} non cerca il campo quando`
    );
  }
});

test("il lavoro notturno esiste, ha un'ora e un fuso", () => {
  const pulizia = readFileSync(join(__dirname, "..", "src", "pulizia.ts"), "utf8");
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  assert.ok(pulizia.includes("onSchedule"), "non e' un lavoro a orario");
  assert.ok(
    pulizia.includes('timeZone: "Europe/Rome"'),
    "senza fuso l'ora notturna cade in mezzo alla giornata di qualcuno"
  );
  assert.ok(
    indice.includes("pulisciLeScadenze"),
    "il lavoro non e' esportato, quindi Firebase non lo conosce"
  );
});

test("la cancellazione immediata resta abolita", () => {
  // **NON SI REINTRODUCE CIO' CHE IL FONDATORE HA TOLTO.** L'ordine BE voce 07
  // ha abolito i trenta giorni di attesa prima della cancellazione: questa
  // voce parla di dati che nessuno ha chiesto di cancellare, e non deve
  // riportare indietro nessuna attesa.
  const indice = readFileSync(join(__dirname, "..", "src", "index.ts"), "utf8");
  for (const morto of ["chiediLOblio", "annullaLOblio", "cancellaGliOblioScaduti"]) {
    assert.ok(
      !indice.includes(`export {${morto}`),
      `${morto} e' tornato: i trenta giorni di attesa erano stati aboliti`
    );
  }
});

test("ogni gruppo di collezioni interrogato ha il suo indice dichiarato", () => {
  // **GLI INDICI CHE NESSUN FILE DICHIARA NON ESISTONO PER CHI RIFA' IL
  // PROGETTO.** Ordine CQ voce 1.12, 3 settembre 2026.
  //
  // Su Firestore c'erano TRE eccezioni di indice a campo singolo create a
  // mano dalla console, per `consumi/quando`, `messages/createdAt` e
  // `movimenti/quando`. Senza di loro le interrogazioni per gruppo di
  // collezioni del giro notturno falliscono, quindi il giro non cancella
  // niente e i dati scaduti restano.
  //
  // **Un indice creato a mano e' un pezzo di infrastruttura che vive solo
  // dentro un progetto Google**, e non dentro il repository: chi ricostruisse
  // il progetto da zero, o chi ne aprisse uno di prova, si troverebbe il giro
  // notturno rotto senza nessuna traccia del perche'. Qui si pretende che
  // ogni gruppo interrogato dal codice abbia la sua riga in
  // `firestore.indexes.json`.
  const scadenze = readFileSync(join(__dirname, "..", "src", "scadenze.ts"), "utf8");
  const chiesti = new Set<string>();
  const cerca = /collectionGroup\("(\w+)"\)\s*\.where\("(\w+)"/g;
  for (const trovato of scadenze.matchAll(cerca)) {
    chiesti.add(`${trovato[1]}/${trovato[2]}`);
  }
  const dichiarazione = JSON.parse(
    readFileSync(join(__dirname, "..", "..", "firestore.indexes.json"), "utf8")
  ) as {fieldOverrides?: {collectionGroup: string; fieldPath: string;
    indexes: {order?: string; queryScope?: string}[]}[]};
  const dichiarati = new Set(
    (dichiarazione.fieldOverrides ?? [])
      .filter((v) => v.indexes.some(
        (i) => i.queryScope === "COLLECTION_GROUP" && i.order === "ASCENDING"
      ))
      .map((v) => `${v.collectionGroup}/${v.fieldPath}`)
  );
  console.log(
    "ORDINE CQ VOCE 1.12: gruppi interrogati", [...chiesti],
    "dichiarati", [...dichiarati]
  );
  assert.ok(
    chiesti.size >= 3,
    `i gruppi interrogati sono ${chiesti.size}: la ricerca non trova piu' ` +
      "le interrogazioni, e questa prova sarebbe verde senza guardare niente"
  );
  const mancanti = [...chiesti].filter((c) => !dichiarati.has(c));
  assert.deepEqual(
    mancanti, [],
    `questi gruppi si interrogano e nessun file dichiara il loro indice: ` +
      `${mancanti.join(", ")}. Su un progetto nuovo il giro notturno non ` +
      "cancellerebbe niente, e nessuno saprebbe perche'"
  );
});
