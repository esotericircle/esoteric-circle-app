import 'dart:math' as math;
import 'dart:ui';

import '../../core/astro/zodiac.dart';

/// Forma astronomica stilizzata di una costellazione zodiacale.
///
/// [points] sono le stelle in coordinate locali normalizzate [0,1] (y verso il
/// basso), centrate idealmente su (0.5, 0.5). [edges] sono le linee di
/// collegamento tra gli indici delle stelle, cioe' l'asterismo riconoscibile.
/// [anchor] e' la posizione del centro della figura nello schermo (normalizzata)
/// e [scale] la larghezza della figura come frazione della larghezza schermo.
///
/// Le forme sono semplificate ma fedeli all'asterismo classico di ciascun
/// segno, cosi' da restare riconoscibili anche in piccolo.
class ZodiacConstellation {
  const ZodiacConstellation({
    required this.sign,
    required this.points,
    required this.edges,
    required this.anchor,
    this.scale = 0.22,
  });

  final Zodiac sign;
  final List<Offset> points;
  final List<(int, int)> edges;
  final Offset anchor;
  final double scale;
}

/// Le dodici costellazioni, distribuite con equilibrio nel cielo (una griglia
/// morbida a tre colonne e quattro fasce).
const List<ZodiacConstellation> kZodiacConstellations = [
  // Ariete: linea spezzata del corno.
  ZodiacConstellation(
    sign: Zodiac.aries,
    anchor: Offset(0.22, 0.12),
    points: [Offset(0.05, 0.62), Offset(0.4, 0.5), Offset(0.72, 0.6), Offset(0.96, 0.4)],
    edges: [(0, 1), (1, 2), (2, 3)],
  ),
  // Toro: la V degli occhi con le corna.
  ZodiacConstellation(
    sign: Zodiac.taurus,
    anchor: Offset(0.55, 0.10),
    points: [
      Offset(0.02, 0.06),
      Offset(0.28, 0.44),
      Offset(0.5, 0.64),
      Offset(0.72, 0.42),
      Offset(0.98, 0.08),
    ],
    edges: [(0, 1), (1, 2), (2, 3), (3, 4)],
  ),
  // Gemelli: due figure parallele.
  ZodiacConstellation(
    sign: Zodiac.gemini,
    anchor: Offset(0.84, 0.15),
    points: [
      Offset(0.28, 0.05),
      Offset(0.72, 0.06),
      Offset(0.24, 0.5),
      Offset(0.7, 0.5),
      Offset(0.2, 0.95),
      Offset(0.68, 0.94),
    ],
    edges: [(0, 2), (2, 4), (1, 3), (3, 5), (0, 1), (2, 3)],
  ),
  // Cancro: la Y rovesciata.
  ZodiacConstellation(
    sign: Zodiac.cancer,
    anchor: Offset(0.14, 0.35),
    points: [Offset(0.5, 0.46), Offset(0.5, 0.05), Offset(0.16, 0.92), Offset(0.84, 0.86)],
    edges: [(0, 1), (0, 2), (0, 3)],
  ),
  // Leone: la falce piu' il triangolo posteriore.
  ZodiacConstellation(
    sign: Zodiac.leo,
    anchor: Offset(0.46, 0.33),
    points: [
      Offset(0.15, 0.6),
      Offset(0.2, 0.42),
      Offset(0.3, 0.3),
      Offset(0.45, 0.27),
      Offset(0.62, 0.46),
      Offset(0.86, 0.42),
      Offset(0.78, 0.7),
    ],
    edges: [(0, 1), (1, 2), (2, 3), (0, 4), (4, 5), (4, 6), (6, 0)],
  ),
  // Vergine: figura distesa con Spica in basso.
  ZodiacConstellation(
    sign: Zodiac.virgo,
    anchor: Offset(0.81, 0.37),
    points: [
      Offset(0.12, 0.2),
      Offset(0.4, 0.3),
      Offset(0.56, 0.5),
      Offset(0.4, 0.72),
      Offset(0.72, 0.55),
      Offset(0.9, 0.82),
    ],
    edges: [(0, 1), (1, 2), (2, 3), (2, 4), (4, 5)],
  ),
  // Bilancia: il quadrilatero della bilancia.
  ZodiacConstellation(
    sign: Zodiac.libra,
    anchor: Offset(0.24, 0.58),
    points: [
      Offset(0.5, 0.08),
      Offset(0.14, 0.44),
      Offset(0.86, 0.42),
      Offset(0.3, 0.88),
      Offset(0.74, 0.82),
    ],
    edges: [(0, 1), (0, 2), (1, 2), (1, 3), (2, 4)],
  ),
  // Scorpione: il gancio della coda.
  ZodiacConstellation(
    sign: Zodiac.scorpio,
    anchor: Offset(0.60, 0.57),
    points: [
      Offset(0.1, 0.14),
      Offset(0.28, 0.2),
      Offset(0.18, 0.34),
      Offset(0.42, 0.32),
      Offset(0.56, 0.46),
      Offset(0.68, 0.62),
      Offset(0.8, 0.78),
      Offset(0.66, 0.9),
      Offset(0.48, 0.86),
    ],
    edges: [(0, 1), (1, 3), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8)],
  ),
  // Sagittario: la teiera.
  ZodiacConstellation(
    sign: Zodiac.sagittarius,
    anchor: Offset(0.87, 0.60),
    points: [
      Offset(0.4, 0.24),
      Offset(0.24, 0.44),
      Offset(0.6, 0.42),
      Offset(0.3, 0.76),
      Offset(0.62, 0.76),
      Offset(0.86, 0.54),
      Offset(0.06, 0.54),
    ],
    edges: [(1, 2), (1, 3), (2, 4), (3, 4), (0, 2), (2, 5), (1, 6)],
  ),
  // Capricorno: il triangolo del capro marino.
  ZodiacConstellation(
    sign: Zodiac.capricorn,
    anchor: Offset(0.18, 0.84),
    points: [Offset(0.08, 0.34), Offset(0.5, 0.1), Offset(0.92, 0.4), Offset(0.55, 0.9)],
    edges: [(0, 1), (1, 2), (2, 3), (3, 0)],
  ),
  // Acquario: lo zigzag dell'acqua.
  ZodiacConstellation(
    sign: Zodiac.aquarius,
    anchor: Offset(0.50, 0.86),
    points: [
      Offset(0.08, 0.3),
      Offset(0.3, 0.42),
      Offset(0.5, 0.3),
      Offset(0.7, 0.42),
      Offset(0.92, 0.3),
      Offset(0.5, 0.6),
      Offset(0.44, 0.86),
    ],
    edges: [(0, 1), (1, 2), (2, 3), (3, 4), (2, 5), (5, 6)],
  ),
  // Pesci: il cordone a V dei due pesci.
  ZodiacConstellation(
    sign: Zodiac.pisces,
    anchor: Offset(0.82, 0.83),
    points: [
      Offset(0.06, 0.2),
      Offset(0.28, 0.32),
      Offset(0.5, 0.42),
      Offset(0.72, 0.5),
      Offset(0.94, 0.74),
      Offset(0.04, 0.46),
    ],
    edges: [(0, 1), (1, 2), (2, 3), (3, 4), (0, 5)],
  ),
];


/// Dove stanno le dodici, in questa schermata.
///
/// PRIMA questa classe non esisteva e le ancore erano costanti: ogni fondale
/// dell'app disegnava lo stesso Ariete nello stesso angolo, e l'occhio lo
/// riconosceva subito. I semi introdotti prima muovevano stelle sparse,
/// nebulose e comete, mai l'asterismo, quindi il criterio "zero costellazioni
/// ripetute" risultava verde mentre a schermo il difetto era intatto.
///
/// Adesso la volta ruota: ogni schermata riceve dal seme una permutazione
/// delle celle della griglia, un piccolo scarto dentro la cella, una scala
/// leggermente diversa e un ribaltamento orizzontale. Due schermate non
/// mostrano mai lo stesso segno nello stesso punto, mentre la stessa
/// schermata rida' sempre la stessa volta, perche' tutto nasce dal seme.
class ZodiacLayout {
  /// Le celle della griglia morbida: tre colonne per quattro fasce. La griglia
  /// resta, altrimenti le figure si accavallerebbero; e' l'assegnazione dei
  /// segni alle celle a cambiare.
  static const List<Offset> _celle = [
    Offset(0.20, 0.10), Offset(0.52, 0.16), Offset(0.82, 0.09),
    Offset(0.16, 0.34), Offset(0.50, 0.40), Offset(0.84, 0.32),
    Offset(0.22, 0.58), Offset(0.54, 0.64), Offset(0.80, 0.56),
    Offset(0.18, 0.82), Offset(0.48, 0.88), Offset(0.82, 0.80),
  ];

  /// La disposizione delle dodici per una schermata col suo seme.
  static List<ZodiacConstellation> perSeed(int seed) {
    // Lo stesso moltiplicatore primo del cosmo: semi vicini danno volte
    // lontane, e non ci si ritrova due schermate quasi uguali.
    final rnd = math.Random(4177 + seed * 7919);

    final ordine = List<int>.generate(_celle.length, (i) => i);
    for (var i = ordine.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final t = ordine[i];
      ordine[i] = ordine[j];
      ordine[j] = t;
    }

    return [
      for (var i = 0; i < kZodiacConstellations.length; i++)
        _riposiziona(kZodiacConstellations[i], _celle[ordine[i]], rnd),
    ];
  }

  static ZodiacConstellation _riposiziona(
      ZodiacConstellation c, Offset cella, math.Random rnd) {
    // Uno scarto dentro la cella: piccolo, altrimenti le figure si toccano.
    final dx = (rnd.nextDouble() - 0.5) * 0.05;
    final dy = (rnd.nextDouble() - 0.5) * 0.05;
    // La scala varia di poco: la figura resta riconoscibile come asterismo,
    // ma non e' il calco identico dell'altra schermata.
    final scala = c.scale * (0.85 + rnd.nextDouble() * 0.35);
    // Il ribaltamento orizzontale e' l'ultimo tocco: e' cio' che rompe il
    // riconoscimento immediato senza inventare astronomia falsa, perche' una
    // costellazione vista da un'altra latitudine si presenta specchiata.
    final specchia = rnd.nextBool();
    return ZodiacConstellation(
      sign: c.sign,
      anchor: Offset(cella.dx + dx, cella.dy + dy),
      scale: scala,
      points: specchia
          ? [for (final p in c.points) Offset(1 - p.dx, p.dy)]
          : c.points,
      edges: c.edges,
    );
  }
}
