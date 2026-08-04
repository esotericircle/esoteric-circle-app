import 'zodiac.dart';

/// Tipo di aspetto tra due pianeti.
///
/// Sono i cinque aspetti tolemaici, e gli angoli non sono una convenzione
/// moderna: Tolomeo, *Tetrabiblos* I.13, li ricava dividendo il cerchio per
/// uno, due, tre, quattro e sei. Da qui congiunzione 0, opposizione 180,
/// trigono 120, quadratura 90, sestile 60. La distinzione fra aspetti duri e
/// morbidi viene dalla stessa tradizione.
enum AspectType {
  conjunction('Congiunzione', AspectHarmony.neutral, 0.0),
  sextile('Sestile', AspectHarmony.soft, 60.0),
  square('Quadratura', AspectHarmony.hard, 90.0),
  trine('Trigono', AspectHarmony.soft, 120.0),
  opposition('Opposizione', AspectHarmony.hard, 180.0);

  const AspectType(this.italianName, this.harmony, this.angoloEsatto);
  final String italianName;
  final AspectHarmony harmony;

  /// L'angolo esatto in gradi, da Tolomeo. Un aspetto e' attivo quando la
  /// distanza fra i due corpi si avvicina a questo valore entro l'orbo.
  final double angoloEsatto;

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
///
/// **Questo modello serve DUE usi, ed e' voluto che sia uno solo.** Gli aspetti
/// interni alla carta natale, che arrivano gia' calcolati dalle effemeridi
/// svizzere, e gli aspetti fra il cielo di oggi e la carta, che si calcolano sul
/// dispositivo. Scriverne un secondo per i transiti avrebbe voluto dire due
/// geometrie dello stesso concetto da tenere d'accordo.
///
/// **La convenzione sui due lati, quando l'aspetto e' un transito**: `a` e' il
/// corpo IN TRANSITO, `b` e' il corpo NATALE. Fuori dai transiti i due lati sono
/// simmetrici e gli identificatori restano nulli, come erano.
class ChartAspect {
  const ChartAspect({
    required this.aLongitude,
    required this.bLongitude,
    required this.type,
    this.aId,
    this.bId,
    this.applicativo,
  });

  /// Se l'aspetto si sta FORMANDO (vero) oppure SCIOGLIENDO (falso).
  ///
  /// Nella tradizione e' una distinzione che cambia il senso: un aspetto
  /// applicativo e' una cosa che sta arrivando, uno separativo e' una cosa che
  /// e' gia' passata e sta perdendo forza. Si misura confrontando l'orbo di
  /// oggi con quello di domani, non si legge da una tabella.
  ///
  /// Nullo quando non e' stato calcolato, per esempio negli aspetti interni
  /// alla carta natale, dove la domanda non ha senso: la carta e' ferma.
  final bool? applicativo;

  final double aLongitude;
  final double bLongitude;
  final AspectType type;

  /// L'identificatore del primo corpo (`PlanetPosition.id`), quando si sa quale
  /// e'. Nullo per gli aspetti interni alla carta, dove non serviva.
  final String? aId;

  /// L'identificatore del secondo corpo.
  final String? bId;

  /// La distanza angolare fra i due corpi, sempre da 0 a 180 gradi.
  double get separazione {
    final d = (aLongitude - bLongitude).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }

  /// L'ORBO: di quanto l'aspetto e' lontano dall'angolo esatto.
  ///
  /// Zero vuol dire aspetto esatto al grado. Piu' l'orbo e' stretto piu'
  /// l'aspetto e' forte, ed e' la ragione per cui l'elenco dei transiti si
  /// ordina per orbo crescente.
  double get orbe => (separazione - type.angoloEsatto).abs();
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
