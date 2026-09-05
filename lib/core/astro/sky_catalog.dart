import 'dart:ui' show Offset;

import 'zodiac.dart';

/// Forma riconoscibile di un asterismo, codificata a mano.
///
/// Nel repo non c'e' un catalogo J2000 completo con le coordinate equatoriali,
/// quindi qui le costellazioni sono disegnate a mano nelle loro forme classiche
/// e riconoscibili, in un riquadro locale normalizzato [0,1] con y verso il
/// basso. [stars] sono le stelle, [mag] la loro luminosita' relativa (0..1, le
/// piu' alte piu' grandi e brillanti), [lines] le linee dell'asterismo. Le
/// proporzioni rispettano la figura reale: il Sagittario e' una teiera, lo
/// Scorpione un gancio, il Leone una falce.
class Asterism {
  const Asterism({
    required this.id,
    required this.label,
    required this.stars,
    required this.lines,
    required this.mag,
  });

  final String id;
  final String label;
  final List<Offset> stars;
  final List<(int, int)> lines;
  final List<double> mag;
}

/// Asterismi dei dodici segni, nelle loro forme corrette.
const Map<Zodiac, Asterism> kZodiacAsterisms = {
  Zodiac.aries: Asterism(
    id: 'aries',
    label: 'Ariete',
    stars: [
      Offset(0.12, 0.62),
      Offset(0.42, 0.5),
      Offset(0.68, 0.54),
      Offset(0.9, 0.4)
    ],
    lines: [(0, 1), (1, 2), (2, 3)],
    mag: [0.9, 1.0, 0.6, 0.7],
  ),
  Zodiac.taurus: Asterism(
    id: 'taurus',
    label: 'Toro',
    // La V delle Iadi con Aldebaran, piu' le due corna.
    stars: [
      Offset(0.5, 0.55), // Aldebaran
      Offset(0.3, 0.66),
      Offset(0.6, 0.6),
      Offset(0.12, 0.16), // corno
      Offset(0.9, 0.22), // corno
    ],
    lines: [(1, 0), (0, 2), (1, 3), (2, 4)],
    mag: [1.0, 0.7, 0.7, 0.6, 0.6],
  ),
  Zodiac.gemini: Asterism(
    id: 'gemini',
    label: 'Gemelli',
    // Castore e Polluce in alto, due figure parallele.
    stars: [
      Offset(0.36, 0.14), // Castore
      Offset(0.64, 0.12), // Polluce
      Offset(0.33, 0.46),
      Offset(0.62, 0.46),
      Offset(0.24, 0.84),
      Offset(0.72, 0.86),
    ],
    lines: [(0, 2), (2, 4), (1, 3), (3, 5), (0, 1), (2, 3)],
    mag: [1.0, 1.0, 0.6, 0.6, 0.6, 0.6],
  ),
  Zodiac.cancer: Asterism(
    id: 'cancer',
    label: 'Cancro',
    // La Y rovesciata, tenue.
    stars: [
      Offset(0.5, 0.5),
      Offset(0.3, 0.2),
      Offset(0.72, 0.24),
      Offset(0.55, 0.86)
    ],
    lines: [(0, 1), (0, 2), (0, 3)],
    mag: [0.7, 0.5, 0.5, 0.5],
  ),
  Zodiac.leo: Asterism(
    id: 'leo',
    label: 'Leone',
    // La falce (punto interrogativo rovescio) piu' il triangolo posteriore.
    stars: [
      Offset(0.2, 0.72), // Regolo
      Offset(0.22, 0.52),
      Offset(0.3, 0.34),
      Offset(0.44, 0.26),
      Offset(0.52, 0.36),
      Offset(0.86, 0.5), // Denebola
      Offset(0.64, 0.44),
      Offset(0.72, 0.7),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (3, 4), (0, 6), (6, 5), (5, 7), (7, 0)],
    mag: [1.0, 0.6, 0.6, 0.7, 0.6, 0.9, 0.6, 0.6],
  ),
  Zodiac.virgo: Asterism(
    id: 'virgo',
    label: 'Vergine',
    // Figura ampia con Spica in basso.
    stars: [
      Offset(0.2, 0.32),
      Offset(0.42, 0.44),
      Offset(0.58, 0.4),
      Offset(0.74, 0.5),
      Offset(0.5, 0.62),
      Offset(0.4, 0.86), // Spica
    ],
    lines: [(0, 1), (1, 2), (2, 3), (1, 4), (4, 5)],
    mag: [0.6, 0.6, 0.6, 0.6, 0.6, 1.0],
  ),
  Zodiac.libra: Asterism(
    id: 'libra',
    label: 'Bilancia',
    // Il quadrilatero della bilancia coi due piatti.
    stars: [
      Offset(0.5, 0.2),
      Offset(0.22, 0.5),
      Offset(0.78, 0.46),
      Offset(0.3, 0.84),
      Offset(0.72, 0.8),
    ],
    lines: [(0, 1), (0, 2), (1, 2), (1, 3), (2, 4)],
    mag: [0.8, 0.8, 0.8, 0.5, 0.5],
  ),
  Zodiac.scorpio: Asterism(
    id: 'scorpio',
    label: 'Scorpione',
    // Testa, corpo e gancio della coda, con Antares nel petto.
    stars: [
      Offset(0.12, 0.22),
      Offset(0.26, 0.16),
      Offset(0.2, 0.34),
      Offset(0.36, 0.4), // Antares
      Offset(0.47, 0.55),
      Offset(0.56, 0.68),
      Offset(0.66, 0.8),
      Offset(0.74, 0.88),
      Offset(0.62, 0.94),
    ],
    lines: [(0, 2), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8)],
    mag: [0.6, 0.6, 0.6, 1.0, 0.7, 0.7, 0.7, 0.7, 0.7],
  ),
  Zodiac.sagittarius: Asterism(
    id: 'sagittarius',
    label: 'Sagittario',
    // La teiera: coperchio, corpo, beccuccio a sinistra, manico a destra.
    stars: [
      Offset(0.5, 0.12), // vertice del coperchio
      Offset(0.32, 0.42), // corpo alto sinistra
      Offset(0.68, 0.42), // corpo alto destra
      Offset(0.36, 0.74), // corpo basso sinistra
      Offset(0.64, 0.74), // corpo basso destra
      Offset(0.08, 0.6), // punta del beccuccio
      Offset(0.94, 0.56), // manico
    ],
    lines: [
      (1, 0), (0, 2), // coperchio
      (1, 2), (1, 3), (2, 4), (3, 4), // corpo
      (1, 5), (5, 3), // beccuccio
      (2, 6), (6, 4), // manico
    ],
    mag: [0.7, 0.9, 0.9, 0.7, 0.7, 0.8, 0.6],
  ),
  Zodiac.capricorn: Asterism(
    id: 'capricorn',
    label: 'Capricorno',
    // Il triangolo del capro marino, con la punta in basso.
    stars: [
      Offset(0.14, 0.34),
      Offset(0.86, 0.28),
      Offset(0.6, 0.64),
      Offset(0.5, 0.88),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (3, 0)],
    mag: [0.8, 0.8, 0.6, 0.7],
  ),
  Zodiac.aquarius: Asterism(
    id: 'aquarius',
    label: 'Acquario',
    // La brocca in alto e l'acqua che scende.
    stars: [
      Offset(0.24, 0.3),
      Offset(0.42, 0.24),
      Offset(0.58, 0.32),
      Offset(0.72, 0.26),
      Offset(0.5, 0.52),
      Offset(0.46, 0.8),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (2, 4), (4, 5)],
    mag: [0.6, 0.7, 0.7, 0.6, 0.6, 0.6],
  ),
  Zodiac.pisces: Asterism(
    id: 'pisces',
    label: 'Pesci',
    // Il lungo cordone a V che lega i due pesci.
    stars: [
      Offset(0.08, 0.26),
      Offset(0.3, 0.34),
      Offset(0.52, 0.42),
      Offset(0.72, 0.52), // nodo
      Offset(0.82, 0.28),
      Offset(0.9, 0.74),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (3, 4), (3, 5)],
    mag: [0.6, 0.6, 0.6, 0.8, 0.6, 0.6],
  ),
};

/// Poche costellazioni brillanti non zodiacali, per popolare il cielo con
/// figure riconoscibili anche fuori dallo zodiaco.
const List<Asterism> kBrightAsterisms = [
  Asterism(
    id: 'orion',
    label: 'Orione',
    // Spalle, cintura di tre stelle, piedi.
    stars: [
      Offset(0.3, 0.28), // Bellatrix
      Offset(0.72, 0.24), // Betelgeuse
      Offset(0.44, 0.5),
      Offset(0.5, 0.52), // cintura
      Offset(0.56, 0.54),
      Offset(0.32, 0.82), // Rigel
      Offset(0.66, 0.84), // Saiph
    ],
    lines: [(0, 2), (1, 4), (2, 3), (3, 4), (2, 5), (4, 6), (0, 1)],
    mag: [0.9, 1.0, 0.8, 0.8, 0.8, 1.0, 0.8],
  ),
  Asterism(
    id: 'ursa_major',
    label: 'Orsa Maggiore',
    // Il Grande Carro: coppa e timone.
    stars: [
      Offset(0.16, 0.42),
      Offset(0.34, 0.36),
      Offset(0.38, 0.56),
      Offset(0.2, 0.62),
      Offset(0.5, 0.3),
      Offset(0.66, 0.3),
      Offset(0.82, 0.38),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (3, 0), (1, 4), (4, 5), (5, 6)],
    mag: [0.9, 0.9, 0.8, 0.8, 0.9, 0.9, 0.9],
  ),
  Asterism(
    id: 'cassiopeia',
    label: 'Cassiopea',
    // La W.
    stars: [
      Offset(0.1, 0.42),
      Offset(0.3, 0.62),
      Offset(0.5, 0.36),
      Offset(0.7, 0.62),
      Offset(0.9, 0.4),
    ],
    lines: [(0, 1), (1, 2), (2, 3), (3, 4)],
    mag: [0.9, 0.8, 0.9, 0.8, 0.9],
  ),
  Asterism(
    id: 'cygnus',
    label: 'Cigno',
    // La croce del Nord.
    stars: [
      Offset(0.5, 0.14), // Deneb
      Offset(0.5, 0.5),
      Offset(0.5, 0.86),
      Offset(0.18, 0.56),
      Offset(0.82, 0.48),
    ],
    lines: [(0, 1), (1, 2), (3, 1), (1, 4)],
    mag: [1.0, 0.7, 0.7, 0.7, 0.7],
  ),
];
