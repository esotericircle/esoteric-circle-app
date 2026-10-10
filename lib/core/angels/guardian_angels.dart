import '../astro/birth_details.dart';
import '../astro/celestial.dart';
import 'angel_catalog.dart';

/// I tre Angeli di una persona, con la ragione di ciascuno.
///
/// La tradizione dello Shemhamphorash assegna tre angeli, da tre sorgenti
/// diverse: il grado del Sole alla nascita, il giorno, l'ora. Sono tre strati
/// della stessa persona, non tre alternative.
class AngelTriad {
  const AngelTriad({
    required this.guardian,
    required this.heart,
    this.intellect,
    required this.sunLongitude,
    required this.dayOfYear,
    this.minuteOfDay,
  });

  /// Angelo Custode, detto del corpo fisico: dal grado del Sole alla nascita.
  final Angel guardian;

  /// Angelo del Cuore, detto del corpo astrale: dal giorno di nascita.
  final Angel heart;

  /// Angelo dell'Intelletto, detto delle missioni: dall'ora di nascita. Nullo
  /// quando l'ora non e' nota, e allora non si mostra come noto: si invita a
  /// inserire l'ora, come gia' si fa per Ascendente e case.
  final Angel? intellect;

  /// I dati da cui i tre nascono, per la riga di trasparenza a video.
  final double sunLongitude;
  final int dayOfYear;
  final int? minuteOfDay;

  bool get hasIntellect => intellect != null;

  /// I tre in ordine, saltando quello che non c'e'.
  List<Angel> get known => [guardian, heart, if (intellect != null) intellect!];
}

/// Le tre regole di attribuzione, in un punto solo.
///
/// Fonte: tradizione cabalistica dello Shemhamphorash, i settantadue nomi
/// ricavati dal versetto triplice dell'Esodo. Le regole sono quelle correnti
/// nella tradizione angelologica, e sono qui scritte per esteso perche' nessuno
/// debba andarle a cercare altrove.
class GuardianAngels {
  const GuardianAngels._();

  /// Quanti gradi dello zodiaco governa ogni angelo: 360 diviso 72.
  static const double degreesPerAngel = 5.0;

  /// Quanti minuti governa ogni angelo: 24 ore, cioe' 1440 minuti, diviso 72.
  static const int minutesPerAngel = 20;

  /// **Angelo Custode**, dal grado del Sole alla nascita.
  ///
  /// I settantadue governano cinque gradi ciascuno partendo da zero gradi
  /// dell'Ariete: il primo da 0 a 5, il secondo da 5 a 10, fino a chiudere il
  /// cerchio a 360. La longitudine arriva dal motore astronomico, non dalla
  /// data di calendario: fra le due c'e' quasi sempre un giorno di scarto,
  /// perche' i confini dei segni non cadono a mezzanotte.
  static Angel guardianFor(double sunEclipticLongitude) {
    final lon = _norm360(sunEclipticLongitude);
    final index = (lon / degreesPerAngel).floor();
    // Il floor di 359,999 vale 71, ma un arrotondamento potrebbe dare 72:
    // il modulo del catalogo riporta comunque dentro.
    return AngelCatalog.byNumber(index + 1);
  }

  /// **Angelo del Cuore**, dal giorno di nascita.
  ///
  /// I settantadue si susseguono un giorno ciascuno e il ciclo si ripete lungo
  /// l'anno: il primo giorno dell'anno tocca al primo angelo, il settantatreesimo
  /// di nuovo al primo.
  ///
  /// Il giorno dell'anno si conta sul calendario civile, sommando i giorni dei
  /// mesi, e non sottraendo due istanti: una differenza in ore fra due DateTime
  /// locali sbaglia di un giorno intero attraversando il cambio dell'ora legale,
  /// perche' quella giornata dura ventitre' ore oppure venticinque.
  static Angel heartFor(DateTime birthDate) {
    final day = dayOfYear(birthDate);
    return AngelCatalog.byNumber(((day - 1) % 72) + 1);
  }

  /// **Angelo dell'Intelletto**, dall'ora di nascita.
  ///
  /// Ventiquattro ore divise per settantadue danno venti minuti per angelo: il
  /// primo governa da mezzanotte alle 00:20, il secondo dalle 00:20 alle 00:40.
  /// Senza ora di nascita questo angelo non esiste, e chi chiama riceve nullo.
  static Angel? intellectFor(int? hour, int? minute) {
    if (hour == null) return null;
    final total = hour * 60 + (minute ?? 0);
    if (total < 0 || total >= 1440) return null;
    return AngelCatalog.byNumber((total ~/ minutesPerAngel) + 1);
  }

  /// Il giorno dell'anno, da 1 a 365 oppure 366, contato sul calendario.
  static int dayOfYear(DateTime date) {
    const cumulative = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    final bisestile = _isLeap(date.year);
    final extra = (bisestile && date.month > 2) ? 1 : 0;
    return cumulative[date.month - 1] + date.day + extra;
  }

  static bool _isLeap(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static double _norm360(double x) {
    final v = x % 360.0;
    return v < 0 ? v + 360.0 : v;
  }

  /// I tre angeli dai dati di nascita.
  ///
  /// La longitudine del Sole si prende da [sunLongitude] quando la carta natale
  /// l'ha gia' calcolata; altrimenti si ricava dallo stesso motore astronomico
  /// che disegna il cielo, sull'istante di nascita in tempo universale.
  static AngelTriad forBirth(BirthDetails details, {double? sunLongitude}) {
    final lon = sunLongitude ?? _sunAtBirth(details);
    final time = details.time;
    return AngelTriad(
      guardian: guardianFor(lon),
      heart: heartFor(details.date),
      intellect: intellectFor(time?.hour, time?.minute),
      sunLongitude: _norm360(lon),
      dayOfYear: dayOfYear(details.date),
      minuteOfDay: time == null ? null : time.hour * 60 + time.minute,
    );
  }

  /// La longitudine del Sole all'istante di nascita.
  ///
  /// Il fuso si applica quando il luogo c'e'; quando manca si resta sul tempo
  /// universale. Sul Sole lo scarto e' minimo, meno di un centesimo di grado
  /// per ora, quindi non sposta l'angelo se non a ridosso esatto del confine
  /// dei cinque gradi, e in quel caso e' l'ora a mancare, non il calcolo a
  /// sbagliare.
  static double _sunAtBirth(BirthDetails details) {
    final local = details.dateTime;
    final offsetMinutes =
        ((details.place?.longitude ?? 0) / 15.0 * 60.0).round();
    final utc = DateTime.utc(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    ).subtract(Duration(minutes: offsetMinutes));
    return Celestial.sunEclipticLongitude(Celestial.julianDay(utc));
  }
}
