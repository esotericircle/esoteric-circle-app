import 'dart:math' as math;

/// Motore astronomico leggero per il cielo reale della nascita.
///
/// Nessuna rete, nessun LLM: sono formule di posizione classiche (tempo
/// siderale, proiezione di ascensione retta e declinazione sull'orizzonte
/// dell'osservatore, posizione e fase della Luna a bassa precisione). La
/// precisione basta a mostrare le costellazioni nelle loro posizioni vere viste
/// da quel luogo, non un cielo decorativo.
class Celestial {
  Celestial._();

  static const double _deg = math.pi / 180.0;

  static double _norm360(double x) {
    var v = x % 360.0;
    if (v < 0) v += 360.0;
    return v;
  }

  /// Giorno giuliano da un istante UTC.
  static double julianDay(DateTime utc) {
    final u = utc.toUtc();
    var y = u.year;
    var m = u.month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final day = u.day +
        (u.hour + u.minute / 60.0 + u.second / 3600.0) / 24.0;
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Giorni dall'epoca J2000.0.
  static double _n(double jd) => jd - 2451545.0;

  /// Obliquita' dell'eclittica in gradi.
  static double _obliquity(double jd) => 23.439 - 0.0000004 * _n(jd);

  /// Tempo siderale medio di Greenwich in gradi.
  static double gmstDegrees(double jd) {
    final n = _n(jd);
    return _norm360(280.46061837 + 360.98564736629 * n);
  }

  /// Tempo siderale locale in gradi (longitudine est positiva).
  static double localSiderealDegrees(double jd, double longitudeEast) =>
      _norm360(gmstDegrees(jd) + longitudeEast);

  /// Proietta ascensione retta e declinazione (gradi) sull'orizzonte
  /// dell'osservatore, restituendo altezza e azimut in gradi. Azimut da nord
  /// verso est.
  static HorizontalCoord equatorialToHorizontal({
    required double raDeg,
    required double decDeg,
    required double latDeg,
    required double lstDeg,
  }) {
    final ha = (lstDeg - raDeg) * _deg; // angolo orario
    final dec = decDeg * _deg;
    final lat = latDeg * _deg;
    final sinAlt =
        math.sin(dec) * math.sin(lat) + math.cos(dec) * math.cos(lat) * math.cos(ha);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));
    final cosAz = (math.sin(dec) - math.sin(alt) * math.sin(lat)) /
        (math.cos(alt) * math.cos(lat));
    var az = math.acos(cosAz.clamp(-1.0, 1.0));
    if (math.sin(ha) > 0) az = 2 * math.pi - az;
    return HorizontalCoord(altDeg: alt / _deg, azDeg: az / _deg);
  }

  /// Longitudine eclittica del Sole in gradi (bassa precisione).
  static double sunEclipticLongitude(double jd) {
    final n = _n(jd);
    final l = _norm360(280.460 + 0.9856474 * n);
    final g = (357.528 + 0.9856003 * n) * _deg;
    return _norm360(l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g));
  }

  /// Posizione equatoriale della Luna (bassa precisione, errore tipico sotto il
  /// mezzo grado, piu' che sufficiente per il colpo d'occhio).
  static EquatorialCoord moonEquatorial(double jd) {
    final n = _n(jd);
    final lp = 218.316 + 13.176396 * n; // longitudine media
    final mp = (134.963 + 13.064993 * n) * _deg; // anomalia media lunare
    final m = (357.529 + 0.985600 * n) * _deg; // anomalia media solare
    final d = (297.8502 + 12.1907491 * n) * _deg; // elongazione media
    final f = (93.272 + 13.229350 * n) * _deg; // argomento di latitudine

    final lon = lp +
        6.289 * math.sin(mp) +
        1.274 * math.sin(2 * d - mp) +
        0.658 * math.sin(2 * d) +
        0.214 * math.sin(2 * mp) -
        0.186 * math.sin(m) -
        0.114 * math.sin(2 * f);
    final lat = 5.128 * math.sin(f) +
        0.281 * math.sin(mp + f) +
        0.278 * math.sin(f - mp) +
        0.173 * math.sin(2 * d - f);

    return _eclipticToEquatorial(_norm360(lon), lat, _obliquity(jd));
  }

  static EquatorialCoord _eclipticToEquatorial(
      double lonDeg, double latDeg, double oblDeg) {
    final lon = lonDeg * _deg;
    final lat = latDeg * _deg;
    final obl = oblDeg * _deg;
    final sinDec = math.sin(lat) * math.cos(obl) +
        math.cos(lat) * math.sin(obl) * math.sin(lon);
    final dec = math.asin(sinDec.clamp(-1.0, 1.0));
    final y = math.sin(lon) * math.cos(obl) - math.tan(lat) * math.sin(obl);
    final x = math.cos(lon);
    final ra = _norm360(math.atan2(y, x) / _deg);
    return EquatorialCoord(raDeg: ra, decDeg: dec / _deg);
  }

  /// Illuminazione della Luna a una data: frazione illuminata [0,1] e se e' in
  /// fase crescente (lembo luminoso a destra nell'emisfero nord).
  static MoonIllumination moonIllumination(double jd) {
    final sun = sunEclipticLongitude(jd);
    final n = _n(jd);
    final lp = _norm360(218.316 + 13.176396 * n);
    final mp = (134.963 + 13.064993 * n) * _deg;
    final d = (297.8502 + 12.1907491 * n) * _deg;
    final moonLon = _norm360(lp +
        6.289 * math.sin(mp) +
        1.274 * math.sin(2 * d - mp) +
        0.658 * math.sin(2 * d));
    final elong = _norm360(moonLon - sun); // 0 novilunio, 180 plenilunio
    final fraction = (1 - math.cos(elong * _deg)) / 2;
    final waxing = elong < 180;
    return MoonIllumination(
        fraction: fraction, waxing: waxing, elongationDeg: elong);
  }
}

class EquatorialCoord {
  const EquatorialCoord({required this.raDeg, required this.decDeg});
  final double raDeg;
  final double decDeg;
}

class HorizontalCoord {
  const HorizontalCoord({required this.altDeg, required this.azDeg});

  /// Altezza sull'orizzonte in gradi (negativa sotto l'orizzonte).
  final double altDeg;

  /// Azimut in gradi, da nord (0) verso est (90).
  final double azDeg;
}

class MoonIllumination {
  const MoonIllumination({
    required this.fraction,
    required this.waxing,
    required this.elongationDeg,
  });

  /// Frazione illuminata del disco, da 0 (nuova) a 1 (piena).
  final double fraction;

  /// Vero in fase crescente.
  final bool waxing;

  /// L'elongazione Luna meno Sole in gradi: 0 al novilunio, 180 al plenilunio.
  ///
  /// Serve a chi deve sapere DOVE si e' nel ciclo e non solo quanta luce c'e':
  /// l'illuminazione da sola non distingue una crescente da una calante, e
  /// nemmeno dice quanto manca alla sizigia. La posizione nel ciclo e'
  /// `elongationDeg / 360`.
  final double elongationDeg;
}
