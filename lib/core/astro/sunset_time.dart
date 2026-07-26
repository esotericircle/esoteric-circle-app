import 'dart:math';

import 'moon_phase.dart';

/// L'ora vera del tramonto, calcolata offline con l'algoritmo NOAA, senza rete.
///
/// Riusa il giorno giuliano gia' in `MoonPhase.julianDay`, non riscrive
/// l'astronomia di base. La longitudine e' est positivo, la latitudine in gradi,
/// e il risultato e' l'ora locale a muro dato lo scarto di fuso. Nei casi polari,
/// dove il Sole non tramonta o non sorge, ritorna null e il chiamante ripiega
/// sull'ora media, senza eccezioni.
class SunsetTime {
  const SunsetTime._();

  /// Obliquita' dell'eclittica, in gradi.
  static const double _obliquita = 23.4397;

  /// Altezza del centro del Sole al tramonto, rifrazione piu' raggio, in gradi.
  static const double _altezzaTramonto = -0.833;

  /// Latitudine di ripiego quando la posizione non e' attiva.
  static const double latDiRipiego = 45.0;

  /// Il tramonto per il giorno di calendario [giorno], di cui si usa solo la
  /// data, alla posizione data, reso nell'ora locale con lo scarto [offset].
  /// Null nei casi polari.
  static DateTime? perData(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) {
    final jd0 = MoonPhase.julianDay(
        DateTime.utc(giorno.year, giorno.month, giorno.day));
    // Conteggio intero dei giorni da J2000 (che cade a mezzogiorno): il ceil
    // snappa al giorno e centra il calcolo sul mezzogiorno solare.
    final n = (jd0 - 2451545.0 + 0.0008).ceilToDouble();
    final lw = -lon; // longitudine ovest, come vuole l'algoritmo NOAA
    // Mezzogiorno solare medio: piu' presto a est, piu' tardi a ovest.
    final jStar = n + lw / 360.0;
    final m = _norm360(357.5291 + 0.98560028 * jStar); // anomalia media, gradi
    final mr = _rad(m);
    final c = 1.9148 * sin(mr) + 0.0200 * sin(2 * mr) + 0.0003 * sin(3 * mr);
    final lambda = _norm360(m + c + 180 + 102.9372); // longitudine eclittica
    final lr = _rad(lambda);
    final jTransit = 2451545.0 + jStar + 0.0053 * sin(mr) - 0.0069 * sin(2 * lr);
    final decl = asin(sin(lr) * sin(_rad(_obliquita)));
    final latR = _rad(lat);
    final cosH = (sin(_rad(_altezzaTramonto)) - sin(latR) * sin(decl)) /
        (cos(latR) * cos(decl));
    if (cosH > 1 || cosH < -1) return null; // notte polare o giorno polare
    final h = _deg(acos(cosH)); // angolo orario del tramonto, gradi
    final jSet = jTransit + h / 360.0;
    final utc = _daJulianDay(jSet);
    final s = utc.add(offset); // spostato all'ora locale a muro
    return DateTime(s.year, s.month, s.day, s.hour, s.minute, s.second);
  }

  /// L'ora media del tramonto, per i casi polari o quando manca la posizione:
  /// le diciotto locali del giorno rituale. Sempre valida, mai un'eccezione.
  static DateTime oraMedia(DateTime giorno) =>
      DateTime(giorno.year, giorno.month, giorno.day, 18, 0);

  /// La longitudine stimata dal solo fuso, quando la posizione non e' attiva:
  /// quindici gradi per ogni ora di scarto.
  static double longitudineDaFuso(Duration offset) =>
      offset.inMinutes / 60.0 * 15.0;

  static DateTime _daJulianDay(double jd) {
    // JD 2440587.5 e' l'epoch unix, 1970-01-01T00:00Z.
    final ms = (jd - 2440587.5) * 86400000.0;
    return DateTime.fromMillisecondsSinceEpoch(ms.round(), isUtc: true);
  }

  static double _rad(double gradi) => gradi * pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / pi;

  static double _norm360(double gradi) {
    final r = gradi % 360.0;
    return r < 0 ? r + 360.0 : r;
  }
}
