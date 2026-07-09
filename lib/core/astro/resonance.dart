import '../maestro/maestro.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

/// Risonanza dell'utente con i tre Maestri, calcolata dai fattori del cielo.
class Resonance {
  const Resonance({
    required this.scores,
    required this.winner,
    required this.dominantElement,
    required this.reason,
  });

  /// Punteggio normalizzato per Maestro, somma 1.
  final Map<Maestro, double> scores;
  final Maestro winner;
  final ZodiacElement dominantElement;
  final String reason;

  double scoreOf(Maestro m) => scores[m] ?? 0;
}

/// Calcola la risonanza dai fattori del cielo: elemento dominante (pesato su
/// Sole, Luna e Ascendente), piu' il segno solare. L'archetipo e' predisposto
/// come parametro per il futuro: quando arrivera' il Test Archetipo, entrera'
/// qui come fattore aggiuntivo.
Resonance computeResonance(NatalChart chart, {String? archetype}) {
  final weights = <ZodiacElement, double>{
    for (final e in ZodiacElement.values) e: 0,
  };

  for (final p in chart.planets) {
    final w = switch (p.id) {
      'sun' => 3.0,
      'moon' => 3.0,
      _ => 1.0,
    };
    weights[p.sign.element] = weights[p.sign.element]! + w;
  }
  if (chart.ascendant != null) {
    weights[chart.ascendant!.element] =
        weights[chart.ascendant!.element]! + 2.0;
  }

  final fire = weights[ZodiacElement.fire]!;
  final earth = weights[ZodiacElement.earth]!;
  final air = weights[ZodiacElement.air]!;
  final water = weights[ZodiacElement.water]!;

  // Ogni Maestro ha un elemento portante, con qualche affinita' secondaria.
  final raw = <Maestro, double>{
    Maestro.medora: air * 1.0 + fire * 0.2, // aria, mente, destino
    Maestro.caligo: fire * 1.0 + earth * 0.2, // fuoco, rito
    Maestro.aura: water * 1.0 + earth * 0.6, // acqua, corpo, energia
  };
  final total = raw.values.fold<double>(0, (a, b) => a + b);
  final scores = <Maestro, double>{
    for (final e in raw.entries)
      e.key: total > 0 ? e.value / total : 1 / 3,
  };

  final winner = scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  // L'elemento che spiega il vincitore: quello portante col peso maggiore.
  final winnerElement = _winnerElement(winner, weights);

  final reason = _reason(winner, winnerElement, chart);
  return Resonance(
    scores: scores,
    winner: winner,
    dominantElement: winnerElement,
    reason: reason,
  );
}

ZodiacElement _winnerElement(Maestro winner, Map<ZodiacElement, double> w) {
  final candidates = switch (winner) {
    Maestro.medora => [ZodiacElement.air, ZodiacElement.fire],
    Maestro.caligo => [ZodiacElement.fire, ZodiacElement.earth],
    Maestro.aura => [ZodiacElement.water, ZodiacElement.earth],
  };
  return candidates.reduce((a, b) => w[a]! >= w[b]! ? a : b);
}

String _elementName(ZodiacElement e) => switch (e) {
      ZodiacElement.fire => 'il fuoco',
      ZodiacElement.earth => 'la terra',
      ZodiacElement.air => 'l\'aria',
      ZodiacElement.water => 'l\'acqua',
    };

String _reason(Maestro winner, ZodiacElement dominant, NatalChart chart) {
  final el = _elementName(dominant);
  final sun = chart.sunSign.italianName;
  final voice = switch (winner) {
    Maestro.medora => 'Medora, che legge le stelle',
    Maestro.aura => 'Aura, che custodisce l\'energia',
    Maestro.caligo => 'Caligo, che conosce i riti',
  };
  return 'Nel tuo cielo prevale $el, e con il Sole in $sun risuona piu\' forte la voce di $voice.';
}
