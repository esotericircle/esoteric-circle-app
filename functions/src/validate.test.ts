import {test} from "node:test";
import assert from "node:assert/strict";
import {validateNatalInput, ValidationError, giorniDelMese} from "./validate";

/**
 * La callable inoltrava a un servizio a consumo quello che il client le
 * mandava. Questi test tengono chiusa quella porta: ogni caso qui sotto e' un
 * corpo che PRIMA sarebbe passato.
 *
 * Si eseguono con `npm test` dentro functions/, senza emulatori.
 */

const ANNO = 2026;

const buono = {
  year: 1985,
  month: 3,
  day: 3,
  hour: 7,
  minute: 20,
  lat: 45.6122,
  lng: 8.8427,
  tz_str: "Europe/Rome",
};

test("un corpo buono passa e torna pulito", () => {
  const out = validateNatalInput(buono, ANNO);
  assert.deepEqual(out, buono);
});

test("campo mancante: senza minute non passa", () => {
  const {minute, ...senzaMinute} = buono;
  void minute;
  assert.throws(
    () => validateNatalInput(senzaMinute, ANNO),
    ValidationError
  );
});

test("tipo sbagliato: l'anno come stringa non passa", () => {
  assert.throws(
    () => validateNatalInput({...buono, year: "1985"}, ANNO),
    ValidationError
  );
});

test("latitudine fuori intervallo", () => {
  assert.throws(
    () => validateNatalInput({...buono, lat: 91}, ANNO),
    ValidationError
  );
  assert.throws(
    () => validateNatalInput({...buono, lat: -90.1}, ANNO),
    ValidationError
  );
});

test("longitudine fuori intervallo", () => {
  assert.throws(
    () => validateNatalInput({...buono, lng: 180.5}, ANNO),
    ValidationError
  );
  assert.throws(
    () => validateNatalInput({...buono, lng: -181}, ANNO),
    ValidationError
  );
});

test("mese impossibile", () => {
  assert.throws(
    () => validateNatalInput({...buono, month: 13}, ANNO),
    ValidationError
  );
  assert.throws(
    () => validateNatalInput({...buono, month: 0}, ANNO),
    ValidationError
  );
});

test("campo estraneo: non si inoltra quello che non conosciamo", () => {
  assert.throws(
    () => validateNatalInput({...buono, callback_url: "http://x"}, ANNO),
    ValidationError
  );
});

test("il giorno deve esistere in quel mese di quell'anno", () => {
  // Il 30 febbraio non esiste mai.
  assert.throws(
    () => validateNatalInput({...buono, month: 2, day: 30}, ANNO),
    ValidationError
  );
  // Il 29 febbraio esiste solo negli anni bisestili.
  assert.throws(
    () => validateNatalInput({...buono, year: 1985, month: 2, day: 29}, ANNO),
    ValidationError
  );
  assert.doesNotThrow(
    () => validateNatalInput({...buono, year: 1984, month: 2, day: 29}, ANNO)
  );
  assert.equal(giorniDelMese(2000, 2), 29);
  assert.equal(giorniDelMese(1900, 2), 28);
});

test("il fuso deve essere un nome IANA", () => {
  assert.throws(
    () => validateNatalInput({...buono, tz_str: "+01:00"}, ANNO),
    ValidationError
  );
  assert.throws(
    () => validateNatalInput({...buono, tz_str: ""}, ANNO),
    ValidationError
  );
  assert.doesNotThrow(
    () => validateNatalInput({...buono, tz_str: "UTC"}, ANNO)
  );
  assert.doesNotThrow(
    () => validateNatalInput(
      {...buono, tz_str: "America/Argentina/Buenos_Aires"}, ANNO)
  );
});

test("anni fuori dal plausibile", () => {
  assert.throws(
    () => validateNatalInput({...buono, year: 1899}, ANNO),
    ValidationError
  );
  assert.throws(
    () => validateNatalInput({...buono, year: ANNO + 2}, ANNO),
    ValidationError
  );
});

test("un corpo che non e' un oggetto", () => {
  assert.throws(() => validateNatalInput(null, ANNO), ValidationError);
  assert.throws(() => validateNatalInput([1, 2], ANNO), ValidationError);
  assert.throws(() => validateNatalInput("ciao", ANNO), ValidationError);
});
