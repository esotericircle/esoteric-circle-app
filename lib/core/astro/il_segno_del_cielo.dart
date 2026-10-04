import 'effemeridi.dart';
import 'il_fuso_della_nascita.dart';
import 'il_sole_di_nascita.dart';
import 'la_luna_intera.dart';
import 'moon_phase.dart';
import 'zodiac.dart';

/// **IL SEGNO DEL CIELO, LA PORTA SOLA. Ordine FC voce 10, 5 ottobre 2026.**
///
/// Il fondatore: *"Il segno solare si ricava dalla posizione reale del Sole,
/// cioe' dalla sua longitudine eclittica alla data di nascita: il segno e' il
/// settore di trenta gradi in cui il Sole si trova. Non si usano date fisse
/// del calendario."* Le date di passaggio fra i segni si spostano di un
/// giorno secondo l'anno: una tabella di date fisse sbaglia il segno a chi
/// nasce in cuspide (1084 giorni su 73414 fra il 1900 e il 2100, misurati in
/// `docs/collaudo/FC/le_cuspidi_del_segno.txt`).
///
/// **QUI E SOLO QUI una data diventa un segno**, e una longitudine diventa un
/// segno. Prima dell'ordine FC le strade erano parecchie: `Zodiac.fromDate`,
/// a date fisse; `NightSky.sunSign` e `NightSky.moonSign`;
/// `IlCieloDelSegno.segnoDi` e il `_segnoDi` del cielo detto, gemelle del
/// segno di un corpo a una data; e la stessa aritmetica dei trenta gradi
/// scritta a mano in tredici punti (le tabelle sono nel rapporto dell'ordine
/// FC). Sono tutte cancellate o portate qui. La guardia
/// `il_segno_ha_una_porta_sola` cade se ne nasce una seconda.
///
/// **IL SOLE DI NASCITA** e' [IlSoleDiNascita], nella libreria del cielo: il
/// Sole di Meeus (*Astronomical Algorithms*, cap. 25), misurato contro il JPL
/// DE440s su quaranta istanti fra il 1900 e il 2100. Il motore dei transiti
/// ([Effemeridi]) e' verificato dal 2020 al 2030, e la guardia
/// `il_motore_locale_e_per_oggi` vieta giustamente di usarlo per una
/// nascita: per il Sole non serve, perche' quello di Meeus vale per tutti e
/// due. **L'ORA**: quella di nascita quando c'e', mezzogiorno dell'ora locale
/// quando manca; il fuso del luogo di nascita, o quello di ripiego di
/// [IlFusoDellaNascita].
///
/// **LA LUNA E I PIANETI** restano al motore dei transiti, come prima: i
/// valori non si muovono, cambia la porta da cui passano.
abstract final class IlSegnoDelCielo {
  /// La frase del metodo, per il pannello delle fonti. Testo del fondatore.
  static const String metodo =
      'Il segno è calcolato dalla posizione reale del Sole alla data di '
      'nascita. In assenza dell\'ora di nascita si usa mezzogiorno.';

  /// Il segno di una longitudine eclittica in gradi: il settore di trenta
  /// gradi che la contiene, dall'inizio dell'Ariete. Vale per lo zodiaco
  /// tropicale e, con la longitudine siderale, per i rashi vedici.
  static Zodiac dellaLongitudine(double gradi) {
    final v = gradi % 360.0;
    return Zodiac.values[((v < 0 ? v + 360.0 : v) ~/ 30) % 12];
  }

  /// Il segno in cui sta il Sole all'istante [istante] (in qualunque fuso:
  /// conta l'istante, non l'ora scritta).
  static Zodiac delSole(DateTime istante) =>
      dellaLongitudine(IlSoleDiNascita.longitudine(
          LaLunaIntera.giornoGiuliano(istante.toUtc())));

  /// Il segno solare di una nascita: il giorno [locale] (anno, mese,
  /// giorno), l'ora di [locale] se [oraNota] e mezzogiorno altrimenti, nel
  /// fuso [fuso] del luogo di nascita.
  static Zodiac diNascita(DateTime locale,
      {required bool oraNota, String? fuso}) {
    final momento = DateTime(locale.year, locale.month, locale.day,
        oraNota ? locale.hour : 12, oraNota ? locale.minute : 0);
    return delSole(IlFusoDellaNascita.inUtc(momento, fuso));
  }

  /// Il segno in cui sta la Luna all'istante [istante] (tropicale).
  static Zodiac dellaLuna(DateTime istante) =>
      delCorpo(CorpoCeleste.luna, istante);

  /// Il segno in cui sta [corpo] all'istante [istante]: il Sole dal suo
  /// calcolo misurato, la Luna e i pianeti dal motore dei transiti.
  static Zodiac delCorpo(CorpoCeleste corpo, DateTime istante) => corpo ==
          CorpoCeleste.sole
      ? delSole(istante)
      : dellaLongitudine(
          Effemeridi.longitudineEclittica(corpo, MoonPhase.julianDay(istante)));
}
