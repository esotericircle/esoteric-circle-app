import {test, before, after} from "node:test";
import * as fs from "fs";
import * as path from "path";
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  collection,
  addDoc,
} from "firebase/firestore";

/**
 * LE REGOLE VERE, provate contro l'emulatore Firestore e non contro
 * un'ipotesi.
 *
 * Questa prova carica `firestore.rules`, cioe' lo stesso file che viene
 * distribuito, e prova a fare dal lato client cio' che un client non deve
 * poter fare: scriversi i contatori del giorno e il saldo Eos. Se un giorno
 * qualcuno riaprisse la scrittura "solo per comodita'", questa cade.
 *
 * Si esegue con `npm run test:regole` dentro functions/, che avvia
 * l'emulatore attorno alla prova. Serve un JDK: su questa macchina c'e'
 * quello di Android Studio, e il comando lo dichiara.
 */
let ambiente: RulesTestEnvironment;

const MIO = "utente-del-cerchio";
const ALTRO = "un-altro-utente";

before(async () => {
  const regole = fs.readFileSync(
    path.join(__dirname, "..", "..", "firestore.rules"),
    "utf8"
  );
  ambiente = await initializeTestEnvironment({
    projectId: "demo-esoteric-circle",
    firestore: {rules: regole},
  });
});

after(async () => {
  await ambiente?.cleanup();
});

test("il client NON puo' scriversi i contatori del giorno", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(
    setDoc(doc(db, `users/${MIO}/stato/contatori`), {
      giorno: "2026-08-11",
      spesi: {domande: 0, gettate: 0},
    })
  );
});

test("il client NON puo' scriversi il saldo Eos", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(
    setDoc(doc(db, `users/${MIO}/stato/borsellino`), {saldo: 1000000})
  );
  await assertFails(
    addDoc(collection(db, `users/${MIO}/movimenti`), {
      causale: "premio_sigillo",
      importo: 999999,
    })
  );
});

test("e nemmeno il piano, che decide quanto puo' fare", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(
    setDoc(doc(db, `users/${MIO}/stato/abbonamento`), {piano: "tier3"})
  );
});

test("la memoria si legge ma non si scrive dal telefono", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  // La lettura del proprio ramo e' concessa, ed e' quella che deve essere
  // veloce e funzionare con la cache.
  await assertSucceeds(getDoc(doc(db, `users/${MIO}`)));
  await assertSucceeds(
    getDoc(doc(db, `users/${MIO}/maestri/medora`))
  );
  // Le scritture no, in nessuna forma.
  await assertFails(setDoc(doc(db, `users/${MIO}`), {displayName: "Sofia"}));
  await assertFails(
    setDoc(doc(db, `users/${MIO}/maestri/medora`), {facts: ["inventato"]})
  );
  await assertFails(
    addDoc(collection(db, `users/${MIO}/maestri/medora/messages`), {
      role: "user",
      text: "ciao",
    })
  );
});

test("il ramo di un altro non si legge e non si tocca", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(getDoc(doc(db, `users/${ALTRO}`)));
  await assertFails(
    getDoc(doc(db, `users/${ALTRO}/stato/borsellino`))
  );
  await assertFails(
    setDoc(doc(db, `users/${ALTRO}/stato/borsellino`), {saldo: 0})
  );
});

test("senza account non si legge niente", async () => {
  const db = ambiente.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, `users/${MIO}`)));
  await assertFails(setDoc(doc(db, `users/${MIO}`), {displayName: "chiunque"}));
});

test("nemmeno cancellare o aggiornare, che sono scritture pure loro", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(deleteDoc(doc(db, `users/${MIO}/stato/contatori`)));
  await assertFails(
    updateDoc(doc(db, `users/${MIO}/stato/contatori`), {spesi: {}})
  );
});

test("fuori da users non c'e' niente da toccare", async () => {
  const db = ambiente.authenticatedContext(MIO).firestore();
  await assertFails(getDoc(doc(db, "listino/eos")));
  await assertFails(setDoc(doc(db, "listino/eos"), {sigillo: 999}));
});
