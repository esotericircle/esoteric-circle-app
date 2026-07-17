import 'dart:ui';

import '../../core/astro/zodiac.dart';

/// L'asterismo reale e riconoscibile di una costellazione zodiacale.
///
/// [points] sono le stelle in coordinate locali normalizzate [0,1] (y verso il
/// basso), ricavate dalle coordinate equatoriali J2000 vere e con la forma
/// preservata: e' lo stesso cielo autentico del cielo di nascita, non una forma
/// stilizzata. [edges] e' l'asterismo. [anchor] e [scale] collocano la figura
/// sullo schermo (frazioni della larghezza e altezza).
class RealZodiac {
  const RealZodiac(
    this.sign,
    this.points,
    this.edges, {
    required this.anchor,
    this.scale = 0.22,
  });

  final Zodiac sign;
  final List<Offset> points;
  final List<(int, int)> edges;
  final Offset anchor;
  final double scale;
}

/// Cerca l'asterismo reale di un segno.
RealZodiac? realZodiacFor(Zodiac sign) {
  for (final z in kRealZodiac) {
    if (z.sign == sign) return z;
  }
  return null;
}

/// Le dodici costellazioni zodiacali con la loro forma reale, distribuite nel
/// cielo con equilibrio.
const List<RealZodiac> kRealZodiac = [
  RealZodiac(Zodiac.aries, [Offset(0.091, 0), Offset(0.842, 0.635), Offset(0.909, 1)], [(0, 1), (1, 2)], anchor: Offset(0.22, 0.12)),
  RealZodiac(Zodiac.taurus, [Offset(0.793, 0.788), Offset(0.146, 0.166), Offset(1, 0.834), Offset(0.887, 0.651), Offset(0, 0.55)], [(0, 3), (3, 1), (0, 2), (0, 4)], anchor: Offset(0.55, 0.10)),
  RealZodiac(Zodiac.gemini, [Offset(0, 0.311), Offset(0.13, 0.124), Offset(0.821, 0.876), Offset(0.306, 0.605), Offset(0.746, 0.452), Offset(1, 0.579)], [(0, 1), (0, 3), (3, 2), (1, 4), (4, 5)], anchor: Offset(0.84, 0.15)),
  RealZodiac(Zodiac.cancer, [Offset(0.232, 0.864), Offset(0.768, 1), Offset(0.408, 0.542), Offset(0.426, 0.373), Offset(0.383, 0)], [(1, 2), (2, 3), (2, 0), (3, 4)], anchor: Offset(0.14, 0.35)),
  RealZodiac(Zodiac.leo, [Offset(0.99, 0.725), Offset(0, 0.623), Offset(0.876, 0.416), Offset(0.343, 0.389), Offset(0.342, 0.589), Offset(1, 0.537), Offset(0.908, 0.275)], [(0, 5), (5, 2), (2, 6), (2, 3), (3, 1), (3, 4), (4, 0)], anchor: Offset(0.46, 0.33)),
  RealZodiac(Zodiac.virgo, [Offset(0.308, 1), Offset(0.8, 0.561), Offset(0.568, 0), Offset(0.2, 0.523)], [(0, 3), (3, 1), (1, 2)], anchor: Offset(0.81, 0.37)),
  RealZodiac(Zodiac.libra, [Offset(0.851, 0.419), Offset(0.44, 0), Offset(0.149, 0.34), Offset(0.643, 1)], [(0, 1), (1, 2), (2, 0), (0, 3)], anchor: Offset(0.24, 0.58)),
  RealZodiac(Zodiac.scorpio, [Offset(0.69, 0.298), Offset(0.038, 0.732), Offset(0, 0.971), Offset(0.985, 0.143), Offset(0.933, 0.029), Offset(1, 0.285), Offset(0.461, 0.617), Offset(0.434, 0.77), Offset(0.067, 0.74)], [(4, 3), (3, 5), (5, 0), (0, 6), (6, 7), (7, 8), (8, 1), (1, 2)], anchor: Offset(0.60, 0.57)),
  RealZodiac(Zodiac.sagittarius, [Offset(0.924, 0.931), Offset(0.176, 0.154), Offset(0, 0.498), Offset(1, 0.493), Offset(0.833, 0.069), Offset(0.408, 0.22)], [(4, 3), (3, 0), (0, 2), (2, 1), (1, 5), (5, 4)], anchor: Offset(0.87, 0.60)),
  RealZodiac(Zodiac.capricorn, [Offset(1, 0.177), Offset(0.967, 0.278), Offset(0, 0.338), Offset(0.078, 0.362), Offset(0.621, 0.823), Offset(0.229, 0.62)], [(0, 1), (1, 4), (4, 5), (5, 2), (2, 3), (3, 1)], anchor: Offset(0.18, 0.84)),
  RealZodiac(Zodiac.aquarius, [Offset(1, 0.388), Offset(0.588, 0.135), Offset(0, 0.881), Offset(0.397, 0.187), Offset(0.311, 0.119)], [(0, 1), (1, 2), (1, 3), (3, 4)], anchor: Offset(0.50, 0.86)),
  RealZodiac(Zodiac.pisces, [Offset(0, 0.653), Offset(0.185, 0.347), Offset(0.744, 0.553), Offset(1, 0.64)], [(0, 1), (0, 2), (2, 3)], anchor: Offset(0.82, 0.83)),
];
