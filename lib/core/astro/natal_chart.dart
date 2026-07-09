import 'zodiac.dart';

/// Tipo di aspetto tra due pianeti.
enum AspectType {
  conjunction('Congiunzione', AspectHarmony.neutral),
  sextile('Sestile', AspectHarmony.soft),
  square('Quadratura', AspectHarmony.hard),
  trine('Trigono', AspectHarmony.soft),
  opposition('Opposizione', AspectHarmony.hard);

  const AspectType(this.italianName, this.harmony);
  final String italianName;
  final AspectHarmony harmony;

  static AspectType? fromId(String id) {
    switch (id.toLowerCase()) {
      case 'conjunction':
        return AspectType.conjunction;
      case 'sextile':
        return AspectType.sextile;
      case 'square':
        return AspectType.square;
      case 'trine':
        return AspectType.trine;
      case 'opposition':
        return AspectType.opposition;
    }
    return null;
  }
}

enum AspectHarmony { soft, hard, neutral }

/// Un aspetto tra due punti della carta (per longitudine eclittica).
class ChartAspect {
  const ChartAspect({
    required this.aLongitude,
    required this.bLongitude,
    required this.type,
  });

  final double aLongitude;
  final double bLongitude;
  final AspectType type;
}

/// Una cuspide di casa.
class HouseCusp {
  const HouseCusp({required this.number, required this.longitude});
  final int number;
  final double longitude;
}

/// Posizione di un pianeta (o punto) nella carta natale.
class PlanetPosition {
  const PlanetPosition({
    required this.id,
    required this.name,
    required this.glyph,
    required this.longitude,
    required this.sign,
    this.retrograde = false,
    this.house,
  });

  final String id;

  /// Nome in italiano (Sole, Luna, Mercurio, ...).
  final String name;

  /// Glifo astronomico (font NotoSansSymbols).
  final String glyph;

  /// Longitudine eclittica in gradi [0, 360).
  final double longitude;
  final Zodiac sign;
  final bool retrograde;
  final int? house;
}

/// La carta natale calcolata.
///
/// Puo' essere:
/// - completa: pianeti, angoli, case e aspetti;
/// - parziale: senza ora, quindi senza Ascendente ne Case;
/// - essenziale: costruita in locale quando l'API non e' disponibile, col solo
///   segno solare deterministico. Mai un errore: sempre un cielo.
class NatalChart {
  const NatalChart({
    required this.sunSign,
    required this.planets,
    this.moonSign,
    this.ascendant,
    this.ascendantLongitude,
    this.midheaven,
    this.midheavenLongitude,
    this.houses = const [],
    this.aspects = const [],
    this.hasTime = false,
    this.isEssential = false,
  });

  final Zodiac sunSign;
  final Zodiac? moonSign;
  final Zodiac? ascendant;
  final double? ascendantLongitude;
  final Zodiac? midheaven;
  final double? midheavenLongitude;
  final List<HouseCusp> houses;
  final List<ChartAspect> aspects;
  final List<PlanetPosition> planets;
  final bool hasTime;
  final bool isEssential;

  bool get isPartial => !hasTime;

  /// Longitudine dell'Ascendente da usare per orientare la ruota (0 se assente,
  /// cosi' l'Ariete resta a sinistra).
  double get orientationLongitude => ascendantLongitude ?? 0;

  /// Cielo essenziale: solo il Sole nel suo segno, calcolato in locale.
  factory NatalChart.essential({required Zodiac sunSign, required bool hasTime}) {
    final longitude = Zodiac.values.indexOf(sunSign) * 30.0 + 15.0;
    return NatalChart(
      sunSign: sunSign,
      hasTime: hasTime,
      isEssential: true,
      planets: [
        PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: longitude,
          sign: sunSign,
        ),
      ],
    );
  }
}
