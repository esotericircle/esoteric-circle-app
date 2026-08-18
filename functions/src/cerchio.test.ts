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
