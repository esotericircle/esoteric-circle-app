import '../astro/celestial.dart';
import 'archetype_transits.dart';

/// I pianeti del giorno che il dispositivo sa calcolare DAVVERO.
///
/// Va detto con chiarezza, perche' cambia cosa si puo' promettere: nel progetto
/// non esiste un motore di effemeridi per i dieci pianeti. `Celestial` calcola
/// in locale il Sole e la Luna e nient'altro (`sunEclipticLongitude`,
/// `moonEquatorial`, `moonIllumination`); la carta natale coi dieci pianeti
/// arriva da FreeAstroAPI, che non e' ancora deployata, ed e' comunque il cielo
/// di NASCITA, non i transiti di oggi.
///
/// Quindi qui si restituisce solo quel che e' vero: Sole e Luna, calcolati
/// davvero dalla data. Gli altri otto entreranno da soli il giorno in cui il
/// motore ci sara', perche' la modulazione del cuore accetta un insieme
/// qualunque di pianeti e non va riscritta.
///
/// Preferiamo due pianeti veri a dieci inventati: un transito finto sarebbe una
/// bugia detta bene, e il Cerchio poggia su tradizioni reali.
class ArchetypeSky {
  const ArchetypeSky._();

  /// I pianeti attivi nel giorno dato, fra quelli che sappiamo calcolare.
  ///
  /// Deterministico sul GIORNO: stessa data, stesso insieme. L'ora non entra,
  /// cosi' due esecuzioni nello stesso giorno danno lo stesso esito, come
  /// promette la modalita' legata ai transiti.
  static Set<Pianeta> pianetiDelGiorno(DateTime quando) {
    // Il Sole c'e' sempre: e' il centro del giorno.
    final attivi = <Pianeta>{Pianeta.sole};

    // La Luna entra quando e' abbastanza piena da farsi sentire, cioe' dalla
    // meta' in su. E' una soglia dichiarata, non un caso: sotto meta' la sua
    // luce non guida la notte.
    final giorno = DateTime.utc(quando.year, quando.month, quando.day, 12);
    final luce = Celestial.moonIllumination(Celestial.julianDay(giorno));
    if (luce.fraction >= 0.5) attivi.add(Pianeta.luna);

    return attivi;
  }

  /// Quanti pianeti dei dieci il dispositivo sa calcolare, oggi. Serve alla
  /// schermata per dire la verita' a chi legge, invece di far credere che il
  /// cielo intero sia stato interrogato.
  static const int pianetiCalcolabili = 2;
}
