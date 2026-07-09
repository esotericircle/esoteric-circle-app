import 'zodiac.dart';

/// Posizione di un pianeta nella carta natale.
class PlanetPosition {
  const PlanetPosition({
    required this.name,
    required this.symbol,
    required this.longitude,
    required this.sign,
  });

  /// Nome in italiano (Sole, Luna, Mercurio, ...).
  final String name;

  /// Simbolo astronomico (usato come etichetta breve).
  final String symbol;

  /// Longitudine eclittica in gradi [0, 360).
  final double longitude;

  final Zodiac sign;
}

/// La carta natale calcolata.
///
/// Puo' essere:
/// - completa: pianeti, segno solare e, se l'ora e' nota, Ascendente;
/// - parziale: senza ora, quindi senza Ascendente ne Case (invito a completare);
/// - essenziale: costruita in locale quando l'API non e' disponibile, con il
///   solo segno solare deterministico. Mai un errore tecnico: sempre un cielo.
class NatalChart {
  const NatalChart({
    required this.sunSign,
    required this.planets,
    this.moonSign,
    this.ascendant,
    this.hasTime = false,
    this.isEssential = false,
  });

  final Zodiac sunSign;
  final Zodiac? moonSign;

  /// Ascendente, disponibile solo con l'ora di nascita e il calcolo completo.
  final Zodiac? ascendant;

  final List<PlanetPosition> planets;

  /// Vero se l'ora era nota (quindi Ascendente e Case sono significativi).
  final bool hasTime;

  /// Vero se la carta e' il cielo essenziale locale (API non disponibile).
  final bool isEssential;

  bool get isPartial => !hasTime;

  /// Cielo essenziale: solo il Sole nel suo segno, calcolato in locale.
  /// Usato come fallback elegante quando l'API non risponde o la chiave manca.
  factory NatalChart.essential({required Zodiac sunSign, required bool hasTime}) {
    // Il Sole si colloca a meta' del proprio segno come posizione simbolica.
    final longitude = Zodiac.values.indexOf(sunSign) * 30.0 + 15.0;
    return NatalChart(
      sunSign: sunSign,
      hasTime: hasTime,
      isEssential: true,
      planets: [
        PlanetPosition(
          name: 'Sole',
          symbol: '☉',
          longitude: longitude,
          sign: sunSign,
        ),
      ],
    );
  }
}
