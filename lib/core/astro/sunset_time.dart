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
    // La mezzanotte locale del giorno, espressa in UTC togliendo lo scarto di
    // fuso: cosi' l'indice del giorno si ancora al giorno LOCALE e non a quello
    // di Greenwich. Senza questo, a est e a ovest il giorno di calcolo scivola e
    // il tramonto puo' cadere nella data sbagliata.
    final mezzanotteLocaleUtc =
        DateTime.utc(giorno.year, giorno.month, giorno.day).subtract(offset);
    final jd0 = MoonPhase.julianDay(mezzanotteLocaleUtc);
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

  // ===========================================================================
  // IL SORGERE DEL SOLE, aggiunto il 5 agosto 2026
  // ===========================================================================

  /// L'ora vera del SORGERE del sole, stesso algoritmo NOAA del tramonto.
  ///
  /// **Perche' e' arrivato adesso.** Il Rito dell'Alba deve dichiarare alla
  /// persona una fascia oraria vera, calcolata per il suo luogo. Qui c'era solo
  /// il tramonto, e il sorgere non esisteva in nessun punto del progetto:
  /// l'ora dell'alba era l'unico dato del cielo che l'app non sapeva dire.
  ///
  /// **Sorgere e tramonto sono lo stesso calcolo con un segno diverso.** Sono
  /// simmetrici rispetto al mezzogiorno solare: il tramonto e' il transito piu'
  /// l'angolo orario, il sorgere e' il transito meno lo stesso angolo. Per
  /// questo vivono qui e non in un file nuovo: una porta sola sull'astronomia
  /// solare, come per tutto il resto.
  ///
  /// Nei casi polari, dove il Sole non sorge o non tramonta, torna null e il
  /// chiamante ripiega su [oraMediaAlba], senza eccezioni: stessa regola gia'
  /// in uso per il tramonto.
  static DateTime? albaPerData(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) =>
      _estremiSolari(giorno, lat: lat, lon: lon, offset: offset)?.alba;

  /// L'ora media del sorgere, per i casi polari o quando manca la posizione:
  /// le sei locali. E' la simmetrica delle diciotto gia' usate per il tramonto,
  /// e come quella e' sempre valida, mai un'eccezione.
  static DateTime oraMediaAlba(DateTime giorno) =>
      DateTime(giorno.year, giorno.month, giorno.day, 6, 0);

  /// I DUE estremi del giorno solare, dallo stesso transito e dallo stesso
  /// angolo orario.
  ///
  /// **Questa e' una seconda scrittura del nucleo NOAA, e va detto.** L'ordine
  /// che ha aggiunto il sorgere autorizzava solo aggiunte in coda, senza
  /// toccare una riga di [perData]: percio' il calcolo del transito e
  /// dell'angolo orario, che [perData] fa gia' al suo interno, e' ripetuto qui.
  /// Due copie della stessa formula sono la famiglia di difetti piu' cara di
  /// questo progetto, quindi la duplicazione e' **inchiodata da una prova**:
  /// `il_sorgere_del_sole_test.dart` pretende che il tramonto calcolato qui
  /// coincida al secondo con quello di [perData]. Se una delle due derivasse,
  /// la prova cade.
  ///
  /// Quando sara' permesso modificare il file, [perData] deve delegare a questo
  /// metodo e la duplicazione sparisce. E' l'unica cosa che manca, ed e' una
  /// riga.
  static ({DateTime alba, DateTime tramonto})? _estremiSolari(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) {
    final mezzanotteLocaleUtc =
        DateTime.utc(giorno.year, giorno.month, giorno.day).subtract(offset);
    final jd0 = MoonPhase.julianDay(mezzanotteLocaleUtc);
    final n = (jd0 - 2451545.0 + 0.0008).ceilToDouble();
    final lw = -lon;
    final jStar = n + lw / 360.0;
    final m = _norm360(357.5291 + 0.98560028 * jStar);
    final mr = _rad(m);
    final c = 1.9148 * sin(mr) + 0.0200 * sin(2 * mr) + 0.0003 * sin(3 * mr);
    final lambda = _norm360(m + c + 180 + 102.9372);
    final lr = _rad(lambda);
    final jTransit = 2451545.0 + jStar + 0.0053 * sin(mr) - 0.0069 * sin(2 * lr);
    final decl = asin(sin(lr) * sin(_rad(_obliquita)));
    final latR = _rad(lat);
    final cosH = (sin(_rad(_altezzaTramonto)) - sin(latR) * sin(decl)) /
        (cos(latR) * cos(decl));
    if (cosH > 1 || cosH < -1) return null; // notte polare o giorno polare
    final h = _deg(acos(cosH));

    // Qui sta tutta la differenza fra i due estremi: il tramonto somma
    // l'angolo orario al mezzogiorno solare, il sorgere lo sottrae.
    return (
      alba: _oraLocale(jTransit - h / 360.0, offset),
      tramonto: _oraLocale(jTransit + h / 360.0, offset),
    );
  }

  /// Da giorno giuliano a ora locale a muro, con lo scarto di fuso.
  static DateTime _oraLocale(double jd, Duration offset) {
    final s = _daJulianDay(jd).add(offset);
    return DateTime(s.year, s.month, s.day, s.hour, s.minute, s.second);
  }
}
