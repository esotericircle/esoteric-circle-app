import {test} from "node:test";
import assert from "node:assert/strict";
import {chiaveDelGiorno, eOggi} from "./giorno";
import {decidi, limiteDi, restaOggi, TETTO_DI_CORRETTEZZA} from "./budget";
import {
  ACCREDITO_DEL_GIORNO,
  BENVENUTO,
  DOTE_DEL_PIANO,
  importoRichiesto,
  saldoDopo,
  VALORE_DEL_PREMIO,
  PREZZI_DEL_RISCATTO,
  budgetDelRiscatto,
} from "./borsellino";

/**
 * LE REGOLE DEL SERVER, provate senza rete e senza emulatore.
 *
 * Qui sta cio' che decide se una persona puo' fare una cosa oggi e quanto
 * vale un premio: e' la parte che il telefono non deve poter riscrivere,
 * quindi e' anche la parte che deve essere provata da sola, senza database
 * di mezzo. Si eseguono con `npm test` dentro functions/.
 */

test("il giorno e' quello di Roma, non quello di chi chiama", () => {
  // Le 22:30 UTC dell'11 agosto sono gia' il 12 a Roma (due ore avanti in
  // ora legale): se il confine fosse UTC, chi apre l'app a mezzanotte e
  // mezza italiana si vedrebbe ancora il giorno prima.
  assert.equal(
    chiaveDelGiorno(new Date("2026-08-11T22:30:00Z")),
    "2026-08-12"
  );
  // E le 21:30 UTC sono ancora l'11.
  assert.equal(
    chiaveDelGiorno(new Date("2026-08-11T21:30:00Z")),
    "2026-08-11"
  );
  // Il formato e' sempre AAAA-MM-GG, anche a gennaio.
  assert.equal(
    chiaveDelGiorno(new Date("2026-01-05T12:00:00Z")),
    "2026-01-05"
  );
  assert.ok(eOggi("2026-08-12", new Date("2026-08-11T22:30:00Z")));
  assert.ok(!eOggi("2026-08-11", new Date("2026-08-11T22:30:00Z")));
});

test("i limiti del giorno sono quelli del piano", () => {
  assert.equal(limiteDi("domande", "free"), 3);
  assert.equal(limiteDi("domande", "tier2"), 10);
  assert.equal(limiteDi("domande", "tier3"), null);
  assert.equal(limiteDi("gettate", "free"), 1);
  assert.equal(limiteDi("gettate", "tier1"), null);
  // "No" nella matrice vale ZERO, non "senza limite": e' l'errore che
  // regalerebbe una funzione a chi non l'ha nel piano.
  assert.equal(limiteDi("approfondimenti", "free"), 0);
  assert.equal(limiteDi("confronti", "free"), 0);
});

test("al quarto gesto il Viandante e' fermo", () => {
  assert.deepEqual(decidi("domande", "free", 0), {concesso: true, resta: 2});
  assert.deepEqual(decidi("domande", "free", 2), {concesso: true, resta: 0});
  const quarto = decidi("domande", "free", 3);
  assert.equal(quarto.concesso, false);
  assert.equal(quarto.resta, 0);
});

test("chi non ha la cosa nel piano non la consuma, la trova chiusa", () => {
  const esito = decidi("approfondimenti", "free", 0);
  assert.equal(esito.concesso, false);
  assert.match(esito.motivo ?? "", /piano/);
});

test("senza limite resta il tetto di correttezza, e le gettate no", () => {
  assert.equal(restaOggi("domande", "tier3", 0), TETTO_DI_CORRETTEZZA);
  assert.equal(decidi("domande", "tier3", TETTO_DI_CORRETTEZZA).concesso, false);
  // Le gettate sono un calcolo locale: nessun modello da difendere.
  assert.equal(restaOggi("gettate", "tier1", 100), null);
  assert.equal(decidi("gettate", "tier1", 100).concesso, true);
});

test("il valore di un premio lo dice il server, non chi lo chiede", () => {
  assert.equal(
    importoRichiesto("premio_sigillo", "sigillo_del_giorno", 999999),
    VALORE_DEL_PREMIO["sigillo_del_giorno"]
  );
  // Un premio che il listino non conosce non vale niente.
  assert.equal(importoRichiesto("premio_sigillo", "premio_inventato", 10), null);
});

test("una spesa e' un numero positivo e ragionevole, o non e' una spesa", () => {
  assert.equal(importoRichiesto("spesa", "stesa_completa", 30), -30);
  // Una spesa negativa sarebbe un accredito travestito.
  assert.equal(importoRichiesto("spesa", "stesa_completa", -30), null);
  assert.equal(importoRichiesto("spesa", "stesa_completa", 0), null);
  assert.equal(importoRichiesto("spesa", "stesa_completa", 10_000_000), null);
  assert.equal(importoRichiesto("spesa", "stesa_completa", 1.5), null);
});

test("il saldo non scende sotto zero", () => {
  assert.equal(saldoDopo(10, -10), 0);
  assert.equal(saldoDopo(10, -11), null);
  assert.equal(saldoDopo(0, 10), 10);
});

// --- ORDINE AN VOCE 07: il benvenuto, il giorno e la dote ---

test("il benvenuto vale 250 Eos, e uno solo", () => {
  assert.equal(BENVENUTO, 250);
});

test("l'accredito del giorno cresce col piano", () => {
  assert.equal(ACCREDITO_DEL_GIORNO.free, 20);
  assert.equal(ACCREDITO_DEL_GIORNO.tier1, 40);
  assert.equal(ACCREDITO_DEL_GIORNO.tier2, 60);
  assert.equal(ACCREDITO_DEL_GIORNO.tier3, 100);
  // Il Viandante prende il meno di tutti ma prende: un giorno di gioco
  // gratuito senza niente in tasca non insegna cosa siano gli Eos.
  assert.ok(ACCREDITO_DEL_GIORNO.free > 0);
});

test("la dote cresce col piano e il gratuito non ne ha", () => {
  assert.equal(DOTE_DEL_PIANO.free, 0);
  assert.equal(DOTE_DEL_PIANO.tier1, 500);
  assert.equal(DOTE_DEL_PIANO.tier2, 1500);
  assert.equal(DOTE_DEL_PIANO.tier3, 3000);
});

test("le azioni premiate non esistono nel listino del server", () => {
  // Decisione di Mauro del 18 agosto: login, oracolo, soffio, mood,
  // meditazione e video NON premiano. Se qualcuno ne aggiungesse una, il
  // suo motivo comparirebbe qui e questa prova cadrebbe.
  const vietati = ["login", "oracolo", "soffio", "mood", "meditazione",
    "video"];
  for (const motivo of vietati) {
    assert.equal(
      importoRichiesto("premio_sigillo", motivo, null),
      null,
      `il motivo ${motivo} premia: le azioni premiate sono state eliminate`
    );
  }
});

// --- ORDINE BF VOCE 01: la dote racconta la sua storia ---

test("statoDelCerchio dichiara gli accrediti compiuti nella chiamata", () => {
  // Il fondatore ha letto i 270 Eos della dote di nascita come il borsellino
  // vecchio che tornava dopo la cancellazione. La cura: la risposta porta
  // `accreditati` e il client li scrive nel registro dei movimenti. Questa
  // prova guarda il sorgente perche' la callable vera chiede l'emulatore:
  // pretende che l'elenco si riempia dentro la transazione, si svuoti a ogni
  // ripartenza e viaggi nella risposta.
  const fs = require("fs");
  const sorgente = fs.readFileSync(require("path").join(__dirname, "..", "src", "cerchio.ts"), "utf8");
  assert.ok(
    sorgente.includes("accreditati.push({motivo: voce.motivo"),
    "gli accrediti compiuti non si raccolgono piu' dentro la transazione"
  );
  assert.ok(
    sorgente.includes("accreditati.length = 0;"),
    "la transazione che riparte non svuota piu' l'elenco: accrediti fantasma"
  );
  const risposta = sorgente.substring(
    sorgente.indexOf("listinoDellaCondivisione: BONUS_DELLA_CONDIVISIONE")
  );
  assert.ok(
    risposta.includes("accreditati,"),
    "la risposta di statoDelCerchio non porta piu' gli accrediti"
  );
});

// --- ORDINE BF VOCE 05.k: il runtime non torna al 20 morente ---

test("il runtime delle functions e' nodejs22, fissato in firebase.json", () => {
  // Node 20 viene dismesso il 30 ottobre 2026. Il runtime del cloud sta in
  // firebase.json (il campo engines e' elastico apposta, cosi' il PC del
  // fondatore con Node 24 non riceve EBADENGINE a ogni install).
  const fs = require("fs");
  const path = require("path");
  const radice = path.join(__dirname, "..", "..");
  const firebase = JSON.parse(
    fs.readFileSync(path.join(radice, "firebase.json"), "utf8")
  );
  assert.equal(firebase.functions[0].runtime, "nodejs22");
  const pacchetto = JSON.parse(
    fs.readFileSync(path.join(radice, "functions", "package.json"), "utf8")
  );
  assert.equal(pacchetto.engines.node, ">=22");
});

// --- ORDINE BG VOCE 05: il riscatto coi prezzi del server ---

test("il listino del riscatto e' il server a deciderlo", () => {
  assert.equal(PREZZI_DEL_RISCATTO.domande, 80);
  assert.equal(PREZZI_DEL_RISCATTO.approfondimenti, 60);
  assert.equal(PREZZI_DEL_RISCATTO.confronti, 150);
  assert.equal(PREZZI_DEL_RISCATTO.gettate, 60);
  // ORDINE BN VOCE 09: la stesa completa, allo stesso scaffale della
  // sinastria in piu' del listino approvato con AN, che il Briefing Progetto
  // le mette accanto spiegando il benvenuto di 250 Eos.
  assert.equal(PREZZI_DEL_RISCATTO.stese, 150);
});

// --- ORDINE BN VOCE 09: il budget delle stese complete ---

test("le stese hanno il budget del listino, e non quello della carta singola", () => {
  // **I NUMERI SEGUONO IL DATO, ordine BV voce 03**: il fondatore ha portato
  // le stese a una, quattro, sette e venti al giorno, e niente e' piu'
  // illimitato su questa riga. La pretesa non cambia: le stese hanno un
  // budget proprio, diverso da quello delle gettate.
  //
  // **Queste due prove sono rimaste rosse per un ordine intero**, perche' la
  // suite di Flutter non esegue le prove del server: l'ha trovato l'ordine BX
  // voce 02 mentre lavorava qui accanto, ed e' il motivo per cui adesso la
  // legge di consegna le include.
  assert.equal(limiteDi("stese", "free"), 1);
  assert.equal(limiteDi("stese", "tier1"), 4);
  assert.equal(limiteDi("stese", "tier2"), 7);
  assert.equal(limiteDi("stese", "tier3"), 20);
  // E non e' il budget delle gettate: due contatori, due promesse.
  assert.notDeepEqual(
    ["free", "tier1", "tier2", "tier3"].map((p) => limiteDi("stese", p as never)),
    ["free", "tier1", "tier2", "tier3"].map((p) => limiteDi("gettate", p as never))
  );
});

test("il limite zero cede al credito comprato, e una volta sola", () => {
  // **IL BUDGET A ZERO NON E' PIU' QUELLO DELLE STESE**, ordine BV voce 03:
  // il Viandante ha una stesa al giorno. La pretesa resta identica e si
  // misura su un budget che a zero ci sta davvero, gli approfondimenti.
  assert.equal(decidi("approfondimenti", "free", 0).concesso, false);
  // Col riscatto lo speso e' andato a meno uno: adesso e' concesso, e dopo
  // averlo usato si richiude. Prima di questa voce lo zero rifiutava PRIMA
  // di guardare lo speso, quindi il server annullava un acquisto pagato.
  const comprata = decidi("approfondimenti", "free", -1);
  assert.equal(comprata.concesso, true);
  assert.equal(comprata.resta, 0);
  assert.equal(decidi("approfondimenti", "free", 0).concesso, false);
  // E la stesa comprata oltre il proprio limite si comporta allo stesso modo.
  assert.equal(decidi("stese", "free", 1).concesso, false);
  assert.equal(decidi("stese", "free", 0).concesso, true);
});

test("il riscatto ignora il numero del client e usa il listino", () => {
  // Il client dichiara 5: il server preleva comunque il prezzo pieno.
  assert.equal(importoRichiesto("spesa", "riscatto_gettate", 5), -60);
  assert.equal(importoRichiesto("spesa", "riscatto_domande", undefined), -80);
  // Un riscatto di un budget inesistente non e' un movimento.
  assert.equal(budgetDelRiscatto("riscatto_regali"), null);
  // Le spese normali restano come prima: importo del client, con tetto.
  assert.equal(importoRichiesto("spesa", "altra_cosa", 40), -40);
});

test("il riscatto scala il contatore dentro la transazione del saldo", () => {
  const fs = require("fs");
  const path = require("path");
  const sorgente = fs.readFileSync(
    path.join(__dirname, "..", "src", "cerchio.ts"),
    "utf8"
  );
  const transazione = sorgente.substring(
    sorgente.indexOf("export const muoviGliEos"),
    sorgente.indexOf("SCRIVE LA MEMORIA")
  );
  assert.ok(
    transazione.includes("budgetDelRiscatto(motivo)"),
    "il riscatto non passa piu' dal budget del motivo"
  );
  assert.ok(
    transazione.includes("spesiOggi[budgetRiscattato] ?? 0) - 1"),
    "il contatore del giorno non viene piu' scalato dal riscatto"
  );
  // E il listino viaggia con lo stato.
  assert.ok(
    sorgente.includes("listinoDelRiscatto: PREZZI_DEL_RISCATTO"),
    "statoDelCerchio non porta piu' il listino del riscatto"
  );
});

// --- ORDINE BH VOCI 01 E 05: il benvenuto della registrazione, con la lapide ---

test("il benvenuto si accredita solo a chi e' registrato", () => {
  // Decisione del fondatore: chi non si registra non viene premiato. La voce
  // del benvenuto entra in daAccreditare solo dentro il ramo registrato, e
  // la registrazione si legge dal token (provider non anonimo con email;
  // il provider password pretende l'email verificata).
  const fs = require("fs");
  const sorgente = fs.readFileSync(require("path").join(__dirname, "..", "src", "cerchio.ts"), "utf8");
  const blocco = sorgente.substring(
    sorgente.indexOf("if (registrazione.registrato) {"),
    sorgente.indexOf("const delGiorno = ACCREDITO_DEL_GIORNO")
  );
  assert.ok(
    blocco.includes("id: \"benvenuto\""),
    "il benvenuto non sta piu' dietro la registrazione: torna a essere dote di nascita"
  );
  assert.ok(
    sorgente.includes("provider !== \"anonymous\""),
    "la registrazione non esclude piu' l'anonimo"
  );
  assert.ok(
    sorgente.includes("provider !== \"password\" || verificata"),
    "il provider password non pretende piu' l'email verificata: il premio si comprerebbe con un indirizzo inventato"
  );
});

test("il premio della registrazione viaggia nel listino del server", () => {
  const fs = require("fs");
  const sorgente = fs.readFileSync(require("path").join(__dirname, "..", "src", "cerchio.ts"), "utf8");
  assert.ok(
    sorgente.includes("listinoDellaRegistrazione: {benvenuto: BENVENUTO}"),
    "la risposta non dichiara piu' il premio della registrazione: il client dovrebbe cablarlo"
  );
});

test("la lapide ferma il secondo benvenuto e sopravvive all'oblio", () => {
  // Il buco visto dal fondatore: cancella, registrati di nuovo, incassa
  // altri 250. La lapide e' l'impronta dell'email in una collezione fuori
  // dal ramo utente: la cancellazione non la tocca, le regole la chiudono
  // al client, e si legge nella fase delle letture della transazione.
  const fs = require("fs");
  const sorgente = fs.readFileSync(require("path").join(__dirname, "..", "src", "cerchio.ts"), "utf8");
  assert.ok(
    sorgente.includes("db.collection(\"lapidi_del_benvenuto\")"),
    "la collezione delle lapidi e' sparita"
  );
  assert.ok(
    sorgente.includes("createHash(\"sha256\")"),
    "la lapide non usa piu' l'impronta: un'email in chiaro sopravviverebbe all'oblio"
  );
  assert.ok(
    sorgente.includes("if (lapideSnap !== null && lapideSnap.exists) continue;"),
    "la lapide non ferma piu' il secondo benvenuto"
  );
  // Il retrofit: chi ha gia' il benvenuto di nascita riceve la lapide alla
  // prima sincronia registrata, o i Cerchi vecchi resterebbero liberi.
  assert.ok(
    sorgente.includes("!lapideSnap.exists") && sorgente.includes("voce.id === \"benvenuto\" &&"),
    "il retrofit della lapide per i Cerchi vecchi e' sparito"
  );
  // E la cancellazione non deve mai toccare le lapidi: si cancella solo il
  // ramo utente.
  const cancella = sorgente.substring(sorgente.indexOf("export const cancellaIlCerchio"));
  assert.ok(
    !cancella.includes("lapidi_del_benvenuto"),
    "la cancellazione tocca le lapidi: il buco della frode si riapre"
  );
});
