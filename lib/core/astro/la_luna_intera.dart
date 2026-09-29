// La Luna di Meeus, in Dart puro: nessun import di Flutter, solo dart:math.
//
// Fonte delle tabelle: le tabelle 47.A (i sessanta termini della longitudine)
// e 22.A (i sessantatre termini della nutazione) sono state copiate da un
// programma, non a mano, dal codice sorgente della libreria Python
// "astronomia" 3.0.5 (https://pypi.org/project/astronomia/, file
// astronomia/lunar.py e astronomia/nutation.py, di Tim Cera, derivata da
// Astrolabe di William McClain) e confrontate termine per termine con la
// libreria PyMeeus (https://github.com/architest/pymeeus, file
// pymeeus/Moon.py e pymeeus/Coordinates.py): coincidono tutte.
// I polinomi del Delta T vengono da Espenak e Meeus, "Five Millennium Canon
// of Solar Eclipses" (2006), pagina NASA
// https://eclipse.gsfc.nasa.gov/SEhelp/deltatpoly2004.html

import 'dart:math' as math;

/// La Luna di Meeus, Astronomical Algorithms, 2a ed. 1998, capitolo 47.
abstract final class LaLunaIntera {
  static const double _gradi = math.pi / 180.0;

  /// Tabella 47.A, solo la colonna della longitudine: D, M, M', F e il
  /// coefficiente del seno in milionesimi di grado.
  static const List<List<int>> _tabellaLongitudine = [
    [0, 0, 1, 0, 6288774],
    [2, 0, -1, 0, 1274027],
    [2, 0, 0, 0, 658314],
    [0, 0, 2, 0, 213618],
    [0, 1, 0, 0, -185116],
    [0, 0, 0, 2, -114332],
    [2, 0, -2, 0, 58793],
    [2, -1, -1, 0, 57066],
    [2, 0, 1, 0, 53322],
    [2, -1, 0, 0, 45758],
    [0, 1, -1, 0, -40923],
    [1, 0, 0, 0, -34720],
    [0, 1, 1, 0, -30383],
    [2, 0, 0, -2, 15327],
    [0, 0, 1, 2, -12528],
    [0, 0, 1, -2, 10980],
    [4, 0, -1, 0, 10675],
    [0, 0, 3, 0, 10034],
    [4, 0, -2, 0, 8548],
    [2, 1, -1, 0, -7888],
    [2, 1, 0, 0, -6766],
    [1, 0, -1, 0, -5163],
    [1, 1, 0, 0, 4987],
    [2, -1, 1, 0, 4036],
    [2, 0, 2, 0, 3994],
    [4, 0, 0, 0, 3861],
    [2, 0, -3, 0, 3665],
    [0, 1, -2, 0, -2689],
    [2, 0, -1, 2, -2602],
    [2, -1, -2, 0, 2390],
    [1, 0, 1, 0, -2348],
    [2, -2, 0, 0, 2236],
    [0, 1, 2, 0, -2120],
    [0, 2, 0, 0, -2069],
    [2, -2, -1, 0, 2048],
    [2, 0, 1, -2, -1773],
    [2, 0, 0, 2, -1595],
    [4, -1, -1, 0, 1215],
    [0, 0, 2, 2, -1110],
    [3, 0, -1, 0, -892],
    [2, 1, 1, 0, -810],
    [4, -1, -2, 0, 759],
    [0, 2, -1, 0, -713],
    [2, 2, -1, 0, -700],
    [2, 1, -2, 0, 691],
    [2, -1, 0, -2, 596],
    [4, 0, 1, 0, 549],
    [0, 0, 4, 0, 537],
    [4, -1, 0, 0, 520],
    [1, 0, -2, 0, -487],
    [2, 1, 0, -2, -399],
    [0, 0, 2, -2, -381],
    [1, 1, 1, 0, 351],
    [3, 0, -2, 0, -340],
    [4, 0, -3, 0, 330],
    [2, -1, 2, 0, 327],
    [0, 2, 1, 0, -323],
    [1, 1, -1, 0, 299],
    [2, 0, 3, 0, 294],
    [2, 0, -1, -2, 0],
  ];

  /// Tabella 22.A: D, M, M', F, Omega, coefficiente costante e coefficiente
  /// in T del seno, in decimillesimi di secondo d'arco (il secondo, in T,
  /// gia' moltiplicato per dieci: -1742 vale -174,2 T).
  static const List<List<int>> _tabellaNutazione = [
    [0, 0, 0, 0, 1, -171996, -1742],
    [-2, 0, 0, 2, 2, -13187, -16],
    [0, 0, 0, 2, 2, -2274, -2],
    [0, 0, 0, 0, 2, 2062, 2],
    [0, 1, 0, 0, 0, 1426, -34],
    [0, 0, 1, 0, 0, 712, 1],
    [-2, 1, 0, 2, 2, -517, 12],
    [0, 0, 0, 2, 1, -386, -4],
    [0, 0, 1, 2, 2, -301, 0],
    [-2, -1, 0, 2, 2, 217, -5],
    [-2, 0, 1, 0, 0, -158, 0],
    [-2, 0, 0, 2, 1, 129, 1],
    [0, 0, -1, 2, 2, 123, 0],
    [2, 0, 0, 0, 0, 63, 0],
    [0, 0, 1, 0, 1, 63, 1],
    [2, 0, -1, 2, 2, -59, 0],
    [0, 0, -1, 0, 1, -58, -1],
    [0, 0, 1, 2, 1, -51, 0],
    [-2, 0, 2, 0, 0, 48, 0],
    [0, 0, -2, 2, 1, 46, 0],
    [2, 0, 0, 2, 2, -38, 0],
    [0, 0, 2, 2, 2, -31, 0],
    [0, 0, 2, 0, 0, 29, 0],
    [-2, 0, 1, 2, 2, 29, 0],
    [0, 0, 0, 2, 0, 26, 0],
    [-2, 0, 0, 2, 0, -22, 0],
    [0, 0, -1, 2, 1, 21, 0],
    [0, 2, 0, 0, 0, 17, -1],
    [2, 0, -1, 0, 1, 16, 0],
    [-2, 2, 0, 2, 2, -16, 1],
    [0, 1, 0, 0, 1, -15, 0],
    [-2, 0, 1, 0, 1, -13, 0],
    [0, -1, 0, 0, 1, -12, 0],
    [0, 0, 2, -2, 0, 11, 0],
    [2, 0, -1, 2, 1, -10, 0],
    [2, 0, 1, 2, 2, -8, 0],
    [0, 1, 0, 2, 2, 7, 0],
    [-2, 1, 1, 0, 0, -7, 0],
    [0, -1, 0, 2, 2, -7, 0],
    [2, 0, 0, 2, 1, -7, 0],
    [2, 0, 1, 0, 0, 6, 0],
    [-2, 0, 2, 2, 2, 6, 0],
    [-2, 0, 1, 2, 1, 6, 0],
    [2, 0, -2, 0, 1, -6, 0],
    [2, 0, 0, 0, 1, -6, 0],
    [0, -1, 1, 0, 0, 5, 0],
    [-2, -1, 0, 2, 1, -5, 0],
    [-2, 0, 0, 0, 1, -5, 0],
    [0, 0, 2, 2, 1, -5, 0],
    [-2, 0, 2, 0, 1, 4, 0],
    [-2, 1, 0, 2, 1, 4, 0],
    [0, 0, 1, -2, 0, 4, 0],
    [-1, 0, 1, 0, 0, -4, 0],
    [-2, 1, 0, 0, 0, -4, 0],
    [1, 0, 0, 0, 0, -4, 0],
    [0, 0, 1, 2, 0, 3, 0],
    [0, 0, -2, 2, 2, -3, 0],
    [-1, -1, 1, 0, 0, -3, 0],
    [0, 1, 1, 0, 0, -3, 0],
    [0, -1, 1, 2, 2, -3, 0],
    [2, -1, -1, 2, 2, -3, 0],
    [0, 0, 3, 2, 2, -3, 0],
    [2, -1, 0, 2, 2, -3, 0],
  ];

  /// Porta un angolo in gradi dentro [0, 360).
  static double _normalizza(double gradi) {
    final r = gradi % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  /// Giorno giuliano da un DateTime UTC.
  static double giornoGiuliano(DateTime utc) {
    final u = utc.toUtc();
    return 2440587.5 + u.microsecondsSinceEpoch / 86400000000.0;
  }

  /// Delta T in secondi per l'anno decimale [anno] (Espenak e Meeus 2006,
  /// polinomi NASA), 1900-2150. Fuori dall'intervallo usa i due rami
  /// estremi della stessa pagina (1860-1900 e dopo il 2150).
  static double deltaT(double anno) {
    final y = anno;
    if (y < 1900) {
      final t = y - 1860;
      return 7.62 +
          0.5737 * t -
          0.251754 * t * t +
          0.01680668 * t * t * t -
          0.0004473624 * math.pow(t, 4) +
          math.pow(t, 5) / 233174;
    }
    if (y < 1920) {
      final t = y - 1900;
      return -2.79 +
          1.494119 * t -
          0.0598939 * t * t +
          0.0061966 * t * t * t -
          0.000197 * math.pow(t, 4);
    }
    if (y < 1941) {
      final t = y - 1920;
      return 21.20 + 0.84493 * t - 0.076100 * t * t + 0.0020936 * t * t * t;
    }
    if (y < 1961) {
      final t = y - 1950;
      return 29.07 + 0.407 * t - t * t / 233 + t * t * t / 2547;
    }
    if (y < 1986) {
      final t = y - 1975;
      return 45.45 + 1.067 * t - t * t / 260 - t * t * t / 718;
    }
    if (y < 2005) {
      final t = y - 2000;
      return 63.86 +
          0.3345 * t -
          0.060374 * t * t +
          0.0017275 * t * t * t +
          0.000651814 * math.pow(t, 4) +
          0.00002373599 * math.pow(t, 5);
    }
    if (y < 2050) {
      final t = y - 2000;
      return 62.92 + 0.32217 * t + 0.005589 * t * t;
    }
    final u = (y - 1820) / 100;
    if (y < 2150) {
      return -20 + 32 * u * u - 0.5628 * (2150 - y);
    }
    return -20 + 32 * u * u;
  }

  /// La nutazione in longitudine, in gradi (Meeus cap. 22, tabella 22.A
  /// completa, sessantatre termini), per il giorno giuliano [jde] in tempo
  /// dinamico.
  static double nutazioneInLongitudine(double jde) {
    final t = (jde - 2451545.0) / 36525.0;
    // Argomenti fondamentali del capitolo 22, in gradi.
    final d = 297.85036 + t * (445267.111480 + t * (-0.0019142 + t / 189474.0));
    final m = 357.52772 + t * (35999.050340 + t * (-0.0001603 - t / 300000.0));
    final m1 = 134.96298 + t * (477198.867398 + t * (0.0086972 + t / 56250.0));
    final f = 93.27191 + t * (483202.017538 + t * (-0.0036825 + t / 327270.0));
    final om = 125.04452 + t * (-1934.136261 + t * (0.0020708 + t / 450000.0));
    final dr = _normalizza(d) * _gradi;
    final mr = _normalizza(m) * _gradi;
    final m1r = _normalizza(m1) * _gradi;
    final fr = _normalizza(f) * _gradi;
    final omr = _normalizza(om) * _gradi;
    var somma = 0.0; // in decimillesimi di secondo d'arco
    for (final r in _tabellaNutazione) {
      final argomento =
          r[0] * dr + r[1] * mr + r[2] * m1r + r[3] * fr + r[4] * omr;
      somma += (r[5] + r[6] / 10.0 * t) * math.sin(argomento);
    }
    return somma / 10000.0 / 3600.0;
  }

  /// Longitudine eclittica geocentrica apparente della Luna, in gradi [0, 360),
  /// riferita all'equinozio vero della data (zodiaco tropicale), per il giorno
  /// giuliano [jdUt] in tempo universale.
  static double longitudine(double jdUt) {
    final anno = 2000.0 + (jdUt - 2451545.0) / 365.25;
    final jde = jdUt + deltaT(anno) / 86400.0;
    return _longitudineDaJde(jde);
  }

  /// La stessa longitudine apparente, ma per un giorno giuliano gia' in tempo
  /// dinamico (serve all'esempio 47.a di Meeus, dato in TD).
  static double longitudineTd(double jde) => _longitudineDaJde(jde);

  static double _longitudineDaJde(double jde) {
    final t = (jde - 2451545.0) / 36525.0;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;
    // Formule 47.1, 47.2, 47.3, 47.4, 47.5.
    final l1 = 218.3164477 +
        481267.88123421 * t -
        0.0015786 * t2 +
        t3 / 538841.0 -
        t4 / 65194000.0;
    final d = 297.8501921 +
        445267.1114034 * t -
        0.0018819 * t2 +
        t3 / 545868.0 -
        t4 / 113065000.0;
    final m =
        357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0;
    final m1 = 134.9633964 +
        477198.8675055 * t +
        0.0087414 * t2 +
        t3 / 69699.0 -
        t4 / 14712000.0;
    final f = 93.2720950 +
        483202.0175233 * t -
        0.0036539 * t2 -
        t3 / 3526000.0 +
        t4 / 863310000.0;
    // Argomenti delle correzioni additive: A1 per Venere, A2 per Giove.
    // A3 (313,45 + 481266,484 T) entra solo nella latitudine, qui non serve;
    // la terza correzione della longitudine, l'appiattimento della Terra,
    // usa L' - F.
    final a1 = 119.75 + 131.849 * t;
    final a2 = 53.09 + 479264.290 * t;
    // Eccentricita' dell'orbita terrestre, formula 47.6.
    final e = 1.0 - 0.002516 * t - 0.0000074 * t2;

    final l1r = _normalizza(l1) * _gradi;
    final dr = _normalizza(d) * _gradi;
    final mr = _normalizza(m) * _gradi;
    final m1r = _normalizza(m1) * _gradi;
    final fr = _normalizza(f) * _gradi;

    var sigmaL = 0.0; // milionesimi di grado
    for (final r in _tabellaLongitudine) {
      final argomento = r[0] * dr + r[1] * mr + r[2] * m1r + r[3] * fr;
      var coefficiente = r[4].toDouble();
      final am = r[1].abs();
      if (am == 1) {
        coefficiente *= e;
      } else if (am == 2) {
        coefficiente *= e * e;
      }
      sigmaL += coefficiente * math.sin(argomento);
    }
    // Termini additivi della longitudine (Meeus p. 338): Venere (A1),
    // appiattimento della Terra (L' - F), Giove (A2).
    sigmaL += 3958.0 * math.sin(_normalizza(a1) * _gradi) +
        1962.0 * math.sin(l1r - fr) +
        318.0 * math.sin(_normalizza(a2) * _gradi);

    final lambdaMedia = l1 + sigmaL / 1000000.0;
    return _normalizza(lambdaMedia + nutazioneInLongitudine(jde));
  }
}
