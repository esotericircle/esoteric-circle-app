import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

import 'birth_details.dart';
import 'birth_place.dart';
import 'celestial.dart';

/// Una costellazione del catalogo: stelle in coordinate equatoriali J2000 e le
/// linee che le uniscono.
class CatalogConstellation {
  const CatalogConstellation({
    required this.name,
    required this.stars,
    required this.lines,
  });

  final String name;

  /// Ogni stella e' [ascensione retta gradi, declinazione gradi, magnitudine].
  final List<List<double>> stars;
  final List<List<int>> lines;
}

/// Il catalogo di stelle luminose, caricato una volta dal bundle.
class SkyCatalog {
  SkyCatalog(this.constellations);
  final List<CatalogConstellation> constellations;

  static SkyCatalog? _cache;

  static Future<SkyCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/bright_stars.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = <CatalogConstellation>[];
    for (final c in data['constellations'] as List) {
      final m = c as Map<String, dynamic>;
      list.add(CatalogConstellation(
        name: m['name'] as String,
        stars: [
          for (final s in m['stars'] as List)
            [for (final v in s as List) (v as num).toDouble()]
        ],
        lines: [
          for (final l in m['lines'] as List)
            [for (final v in l as List) (v as num).toInt()]
        ],
      ));
    }
    return _cache = SkyCatalog(list);
  }
}

/// Una stella proiettata sull'orizzonte dell'osservatore.
class SkyStar {
  const SkyStar({required this.altDeg, required this.azDeg, required this.mag});
  final double altDeg;
  final double azDeg;
  final double mag;
}

class SkyConstellation {
  const SkyConstellation({
    required this.name,
    required this.stars,
    required this.lines,
  });
  final String name;
  final List<SkyStar> stars;
  final List<List<int>> lines;

  /// Vera se almeno una stella e' sopra l'orizzonte.
  bool get anyVisible => stars.any((s) => s.altDeg > -2);
}

/// Il cielo autentico di un istante, visto da un luogo: costellazioni proiettate,
/// Luna nella sua posizione e fase reali, e l'azimut su cui centrare lo sguardo.
class SkySnapshot {
  const SkySnapshot({
    required this.constellations,
    required this.moon,
    required this.moonPhase,
    required this.centerAzDeg,
    required this.hasTime,
    required this.latitude,
  });

  final List<SkyConstellation> constellations;
  final SkyStar? moon;
  final MoonIllumination moonPhase;

  /// Azimut su cui e' bello centrare lo sguardo iniziale (la Luna se e' alta,
  /// altrimenti la regione di cielo piu' ricca).
  final double centerAzDeg;
  final bool hasTime;

  /// La latitudine da cui questa volta e' vista. Vive qui, e non si ripesca dai
  /// dati di nascita, perche' una volta celeste sa da dove e' guardata: chi ne
  /// compone i testi, per esempio per l'emisfero della stagione, la trova qui.
  final double latitude;
}

/// Costruisce l'istantanea del cielo per i dati di nascita, visto da [place].
///
/// Il fuso civile non e' noto in locale come offset: si usa il tempo medio
/// locale del luogo (dalla longitudine), che colloca il cielo con buona fedelta'
/// senza dipendere da tabelle esterne. Se l'ora manca, si usa la notte simbolica
/// (mezzanotte) del giorno.
///
/// Il luogo e' un parametro a se', obbligatorio, e non si prende piu' da
/// [details], dove ora puo' mancare: una volta celeste senza un punto da cui
/// guardarla non esiste, e chi il luogo non ce l'ha deve fermarsi prima invece
/// di riceverne una calcolata su coordinate inventate.
SkySnapshot buildSkySnapshot(
    SkyCatalog catalog, BirthDetails details, BirthPlace place) {
  final lat = place.latitude;
  final lon = place.longitude;

  // Istante locale: ora reale se c'e', altrimenti la mezzanotte simbolica.
  final local = details.hasTime
      ? DateTime(details.date.year, details.date.month, details.date.day,
          details.time!.hour, details.time!.minute)
      : DateTime(details.date.year, details.date.month, details.date.day, 0, 0);

  // Tempo medio locale verso UT: sottrai l'offset di longitudine.
  final offsetMinutes = (lon / 15.0 * 60.0).round();
  final utc = local.subtract(Duration(minutes: offsetMinutes));

  final jd = Celestial.julianDay(utc);
  final lst = Celestial.localSiderealDegrees(jd, lon);

  SkyStar project(double ra, double dec, double mag) {
    final h = Celestial.equatorialToHorizontal(
        raDeg: ra, decDeg: dec, latDeg: lat, lstDeg: lst);
    return SkyStar(altDeg: h.altDeg, azDeg: h.azDeg, mag: mag);
  }

  final constellations = <SkyConstellation>[];
  for (final c in catalog.constellations) {
    final stars = [
      for (final s in c.stars) project(s[0], s[1], s[2]),
    ];
    final con =
        SkyConstellation(name: c.name, stars: stars, lines: c.lines);
    if (con.anyVisible) constellations.add(con);
  }

  // Luna: posizione e fase reali.
  final moonEq = Celestial.moonEquatorial(jd);
  final moonH = Celestial.equatorialToHorizontal(
      raDeg: moonEq.raDeg, decDeg: moonEq.decDeg, latDeg: lat, lstDeg: lst);
  final moon = SkyStar(altDeg: moonH.altDeg, azDeg: moonH.azDeg, mag: -12);
  final moonPhase = Celestial.moonIllumination(jd);

  // Centro dello sguardo: la Luna se e' alta, altrimenti la media pesata degli
  // azimut delle stelle luminose piu' alte.
  double centerAz;
  if (moon.altDeg > 12) {
    centerAz = moon.azDeg;
  } else {
    var sx = 0.0, sy = 0.0, wsum = 0.0;
    for (final con in constellations) {
      for (final s in con.stars) {
        if (s.altDeg <= 5) continue;
        final w = (3.0 - s.mag).clamp(0.3, 4.0) * (s.altDeg / 90.0);
        final a = s.azDeg * math.pi / 180.0;
        sx += w * math.cos(a);
        sy += w * math.sin(a);
        wsum += w;
      }
    }
    centerAz = wsum > 0 ? math.atan2(sy, sx) * 180.0 / math.pi : 180.0;
    if (centerAz < 0) centerAz += 360.0;
  }

  return SkySnapshot(
    constellations: constellations,
    moon: moon.altDeg > -3 ? moon : null,
    moonPhase: moonPhase,
    centerAzDeg: centerAz,
    hasTime: details.hasTime,
    latitude: lat,
  );
}
