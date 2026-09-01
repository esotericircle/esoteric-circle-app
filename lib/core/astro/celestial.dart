import 'dart:math' as math;

import 'effemeridi.dart';

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
    final day = u.day + (u.hour + u.minute / 60.0 + u.second / 3600.0) / 24.0;
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

  /// L'OBLIQUITA' DELL'ECLITTICA in gradi, la stessa che il cielo del giorno
  /// gia' usa.
  ///
  /// Era privata perche' finora la voleva solo questo file. L'Ascendente della
  /// Sinastria, ordine BO voce 02, ha bisogno dello stesso numero: aprirlo
  /// costa una riga, riscriverlo altrove sarebbe la seconda definizione di una
  /// costante che deve restare una.
  static double obliquitaEclittica(double jd) => _obliquity(jd);

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
    final sinAlt = math.sin(dec) * math.sin(lat) +
        math.cos(dec) * math.cos(lat) * math.cos(ha);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));
    final cosAz = (math.sin(dec) - math.sin(alt) * math.sin(lat)) /
        (math.cos(alt) * math.cos(lat));
    var az = math.acos(cosAz.clamp(-1.0, 1.0));
    if (math.sin(ha) > 0) az = 2 * math.pi - az;
    return HorizontalCoord(altDeg: alt / _deg, azDeg: az / _deg);
  }

  /// Longitudine eclittica del Sole in gradi.
  ///
  /// **La firma resta, il calcolo no.** Il corpo di questa funzione era una
  /// delle DUE copie della stessa formula, l'altra in `NightSky`. Adesso
  /// entrambe chiedono a `Effemeridi`, che e' la porta sola. La formula la'
  /// dentro e' identica a quella che stava qui, quindi i valori verificati il
  /// 1 agosto 2026 non si sono mossi di un millesimo.
  static double sunEclipticLongitude(double jd) =>
      Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd);

  /// Posizione equatoriale della Luna.
  ///
  /// La LONGITUDINE arriva da `Effemeridi`, la latitudine resta qui: e' una
  /// serie diversa, che nessun altro calcolava, quindi non c'era niente da
  /// unificare.
  static EquatorialCoord moonEquatorial(double jd) {
    final n = _n(jd);
    final mp = (134.963 + 13.064993 * n) * _deg; // anomalia media lunare
    final d = (297.8502 + 12.1907491 * n) * _deg; // elongazione media
    final f = (93.272 + 13.229350 * n) * _deg; // argomento di latitudine

    final lon = Effemeridi.longitudineEclittica(CorpoCeleste.luna, jd);
    final lat = 5.128 * math.sin(f) +
        0.281 * math.sin(mp + f) +
        0.278 * math.sin(f - mp) +
        0.173 * math.sin(2 * d - f);

    return _eclipticToEquatorial(lon, lat, _obliquity(jd));
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
    // Prima queste due righe erano la TERZA copia della longitudine lunare, e
    // la piu' povera: tre termini contro i sei di `moonEquatorial` e i dieci di
    // `NightSky`. Tre troncature diverse della stessa serie davano tre Lune
    // leggermente diverse nella stessa app.
    final sun = Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd);
    final moonLon = Effemeridi.longitudineEclittica(CorpoCeleste.luna, jd);
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
