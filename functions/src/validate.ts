/**
 * Validazione del corpo della callable natalChart.
 *
 * La funzione inoltrava a un servizio a consumo quello che il client le
 * mandava, senza guardarlo: chi ha un token App Check valido, che si ottiene
 * installando l'app, poteva far fare al progetto chiamate arbitrarie verso un
 * servizio che si paga a chiamata.
 *
 * Qui il corpo viene ricostruito campo per campo invece che filtrato: quel che
 * parte verso il motore e' solo cio' che questa funzione ha scritto, quindi un
 * campo estraneo non puo' passare nemmeno per distrazione.
 *
 * Sta in un file suo, senza dipendenze da Firebase, cosi' si prova con
 * `node --test` senza avviare emulatori.
 */

/** I campi che il motore astrologico accetta, nella forma che si attende. */
export interface NatalInput {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  lat: number;
  lng: number;
  tz_str: string;
  /**
   * IL SISTEMA DI CASE, CHIESTO E NON SPERATO. Ordine 2170, voce 4.
   *
   * Fino a oggi non lo mandava nessuno, quindi arrivava il default del
   * fornitore: il giorno che quel default cambia, TUTTE le carte cambiano
   * sotto i piedi delle persone e nessuno se ne accorge, perche' nessun
   * numero nel nostro codice dice quale ci aspettiamo.
   *
   * Facoltativo, e resta facoltativo apposta: le app gia' installate non
   * lo mandano, e devono continuare a funzionare. Quando manca vale
   * "placidus", che e' quello che il fornitore restituisce oggi, verificato
   * sulle tre risposte conservate nel repository.
   */
  house_system: string;
}

/** Il motivo per cui un corpo non passa, in italiano, per il messaggio. */
export class ValidationError extends Error {}

function intero(
  data: Record<string, unknown>,
  campo: string,
  min: number,
  max: number
): number {
  const v = data[campo];
  if (typeof v !== "number" || !Number.isFinite(v)) {
    throw new ValidationError(`Il campo ${campo} manca oppure non e' un numero.`);
  }
  if (!Number.isInteger(v)) {
    throw new ValidationError(`Il campo ${campo} deve essere un intero.`);
  }
  if (v < min || v > max) {
    throw new ValidationError(
      `Il campo ${campo} sta fuori dall'intervallo ${min}..${max}.`
    );
  }
  return v;
}

function decimale(
  data: Record<string, unknown>,
  campo: string,
  min: number,
  max: number
): number {
  const v = data[campo];
  if (typeof v !== "number" || !Number.isFinite(v)) {
    throw new ValidationError(`Il campo ${campo} manca oppure non e' un numero.`);
  }
  if (v < min || v > max) {
    throw new ValidationError(
      `Il campo ${campo} sta fuori dall'intervallo ${min}..${max}.`
    );
  }
  return v;
}

/** Quanti giorni ha quel mese di quell'anno, bisestili compresi. */
export function giorniDelMese(year: number, month: number): number {
  const lunghezze = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month === 2) {
    const bisestile =
      (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
    return bisestile ? 29 : 28;
  }
  return lunghezze[month - 1];
}

/**
 * Legge il corpo e ne ricostruisce uno pulito, oppure solleva.
 *
 * Gli intervalli sono quelli plausibili per una nascita: gli anni si fermano
 * al 1900 perche' prima le ore di nascita registrate non reggono un calcolo di
 * case, e non vanno oltre l'anno prossimo perche' una carta natale nel futuro
 * non e' una carta natale.
 */
export function validateNatalInput(
  raw: unknown,
  annoCorrente: number
): NatalInput {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new ValidationError("Dati di nascita mancanti.");
  }
  const data = raw as Record<string, unknown>;

  const ammessi = [
    "year", "month", "day", "hour", "minute", "lat", "lng", "tz_str",
    "house_system",
  ];
  const estranei = Object.keys(data).filter((k) => !ammessi.includes(k));
  if (estranei.length > 0) {
    throw new ValidationError(
      `Campi non ammessi: ${estranei.join(", ")}.`
    );
  }

  const year = intero(data, "year", 1900, annoCorrente + 1);
  const month = intero(data, "month", 1, 12);
  const day = intero(data, "day", 1, 31);
  if (day > giorniDelMese(year, month)) {
    throw new ValidationError(
      `Il giorno ${day} non esiste nel mese ${month} del ${year}.`
    );
  }
  const hour = intero(data, "hour", 0, 23);
  const minute = intero(data, "minute", 0, 59);
  const lat = decimale(data, "lat", -90, 90);
  const lng = decimale(data, "lng", -180, 180);

  const tz = data["tz_str"];
  if (typeof tz !== "string" || tz.length === 0 || tz.length > 64) {
    throw new ValidationError("Il fuso orario manca oppure non e' valido.");
  }
  // Forma di un identificativo IANA: Area/Citta, con al piu' tre livelli.
  if (!/^[A-Za-z_]+(\/[A-Za-z_+-]+){1,2}$/.test(tz) && tz !== "UTC") {
    throw new ValidationError(`Il fuso orario ${tz} non e' un nome IANA.`);
  }

  // Il sistema di case: una sigla di una lettera, come vuole Swiss Ephemeris
  // (P sta per Placidus). Si accetta solo cio' che sappiamo interpretare:
  // una sigla sconosciuta darebbe cuspidi che nessuna nostra prova sorveglia.
  const sigleNote = ["P", "K", "O", "R", "C", "W"];
  const grezzoCase = data["house_system"];
  let houseSystem = "P";
  if (grezzoCase !== undefined) {
    if (typeof grezzoCase !== "string" || !sigleNote.includes(grezzoCase)) {
      throw new ValidationError(
        `Il sistema di case ${String(grezzoCase)} non e' fra quelli noti ` +
        `(${sigleNote.join(", ")}).`
      );
    }
    houseSystem = grezzoCase;
  }

  return {
    year, month, day, hour, minute, lat, lng, tz_str: tz,
    house_system: houseSystem,
  };
}
