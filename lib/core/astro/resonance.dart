import '../maestro/maestro.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

/// Risonanza dell'utente con i tre Maestri, letta dalle segnature di dominio del
/// cielo (non dal solo elemento): quali pianeti, angoli, segni e case pesano di
/// piu', e verso quale voce inclinano.
class Resonance {
  const Resonance({
    required this.scores,
    required this.winner,
    required this.reason,
    required this.deciding,
    this.nearTie = false,
  });

  /// Punteggio normalizzato per Maestro, somma 1.
  final Map<Maestro, double> scores;
  final Maestro winner;

  /// Il fattore che ha deciso il vincitore, in forma leggibile.
  final String deciding;

  /// Vero quando le prime due voci sono quasi pari.
  final bool nearTie;
  final String reason;

  double scoreOf(Maestro m) => scores[m] ?? 0;
}

/// Un contributo con la sua etichetta, per poter spiegare il perche' con verita'.
class _Factor {
  const _Factor(this.maestro, this.weight, this.label);
  final Maestro maestro;
  final double weight;
  final String label;
}

/// Le segnature di dominio dei tre Maestri:
/// - Medora, le stelle: luminari, angoli, aria, Mercurio, destino.
/// - Aura, l'energia: Luna, Venere, acqua e terra, il corpo e la cura.
/// - Caligo, i riti: Saturno, Plutone, Scorpione, Capricorno, le case dell'ombra.
///
/// I pesi delle firme superano quelli degli elementi, cosi' e' la firma, non il
/// solo elemento, a decidere. L'archetipo resta predisposto per il futuro Test.
/// Quanto ogni Maestro prende IN MEDIA da un singolo pianeta, oltre al peso
/// fisso del pianeta stesso: elemento del segno, casa di firma, segno di
/// firma.
///
/// Serve a normalizzare, ed e' un valore ATTESO, non un massimo: il massimo
/// assoluto di Caligo pretenderebbe ogni pianeta in Scorpione e insieme in
/// casa dell'ombra e insieme in un segno di fuoco, che non capita mai, quindi
/// dividere per quello lo azzererebbe. I conti, con segni e case equiprobabili:
///
/// Medora: aria 0,5 per un quarto piu' fuoco 0,1 per un quarto, cioe' 0,15,
/// piu' due case su dodici a 0,5, cioe' 0,0833.
/// Aura: acqua 0,5 e terra 0,3 per un quarto ciascuno, cioe' 0,2, piu' due
/// case su dodici a 0,5.
/// Caligo: fuoco 0,3 e terra 0,2 per un quarto, cioe' 0,125, piu' Scorpione
/// 1,0 e Capricorno 0,7 su dodici, cioe' 0,1417, piu' due case su dodici a
/// 1,0, cioe' 0,1667.
///
/// Cosi' i tre si confrontano sulla stessa scala, e vince chi ha davvero il
/// cielo dalla sua parte invece di chi ha piu' voci in elenco.
const Map<Maestro, double> _attesoPerPianeta = {
  Maestro.medora: 0.2333,
  Maestro.aura: 0.2833,
  Maestro.caligo: 0.4334,
};

/// I pesi fissi: quanto un Maestro prende per il solo fatto che quel pianeta
/// esista nella carta, ovunque cada.
const Map<String, Map<Maestro, double>> _pesiFissi = {
  'sun': {Maestro.medora: 3},
  'moon': {Maestro.aura: 3, Maestro.medora: 1},
  'mercury': {Maestro.medora: 2},
  'venus': {Maestro.aura: 2},
  'mars': {Maestro.caligo: 1.5},
  'jupiter': {Maestro.medora: 1},
  'saturn': {Maestro.caligo: 2.5},
  'uranus': {Maestro.medora: 0.5},
  'neptune': {Maestro.aura: 1.5},
  'pluto': {Maestro.caligo: 2.5},
  'chiron': {Maestro.aura: 1},
  'lilith': {Maestro.caligo: 1},
  'north_node': {Maestro.medora: 1},
};

/// Il segno solare quando la carta e' essenziale, cioe' quando c'e' il solo
/// Sole: dodici segni divisi in tre gruppi da quattro, per dominio.
///
/// Col ripiego l'informazione e' povera, e la formula piena darebbe Medora
/// sempre, perche' il Sole e' suo: cento per cento su cento carte. Qui la
/// lettura resta vera, perche' il segno dice davvero qualcosa, e nessun
/// Maestro resta senza nessuno.
const Map<Zodiac, Maestro> _maestroDelSegno = {
  // L'aria e il Leone, che e' la casa del Sole: le stelle e la mente.
  Zodiac.gemini: Maestro.medora,
  Zodiac.libra: Maestro.medora,
  Zodiac.aquarius: Maestro.medora,
  Zodiac.leo: Maestro.medora,
  // L'acqua che cura e la terra che nutre: l'energia e il corpo.
  Zodiac.cancer: Maestro.aura,
  Zodiac.pisces: Maestro.aura,
  Zodiac.taurus: Maestro.aura,
  Zodiac.virgo: Maestro.aura,
  // Le firme di Caligo piu' il fuoco che agisce: i riti e l'ombra.
  Zodiac.scorpio: Maestro.caligo,
  Zodiac.capricorn: Maestro.caligo,
  Zodiac.aries: Maestro.caligo,
  Zodiac.sagittarius: Maestro.caligo,
};

Resonance computeResonance(NatalChart chart, {String? archetype}) {
  // Il ripiego, cioe' la carta col solo Sole: la formula piena darebbe Medora
  // sempre, perche' il Sole e' suo. Il segno solare basta a dire qualcosa, e i
  // dodici segni si dividono in tre gruppi da quattro.
  if (chart.isEssential || chart.planets.length <= 1) {
    return _dalSoloSegno(chart.sunSign);
  }

  final raw = <Maestro, double>{for (final m in Maestro.values) m: 0.0};
  final factors = <_Factor>[];

  // Aggiunge un fattore con firma (pesa e si puo' citare nel perche').
  void sign(Maestro m, double w, String label) {
    raw[m] = raw[m]! + w;
    factors.add(_Factor(m, w, label));
  }

  // Aggiunge solo peso di elemento, senza diventare un fattore citabile.
  void element(ZodiacElement e) {
    switch (e) {
      case ZodiacElement.air:
        raw[Maestro.medora] = raw[Maestro.medora]! + 0.5;
      case ZodiacElement.water:
        raw[Maestro.aura] = raw[Maestro.aura]! + 0.5;
      case ZodiacElement.earth:
        raw[Maestro.aura] = raw[Maestro.aura]! + 0.3;
        raw[Maestro.caligo] = raw[Maestro.caligo]! + 0.2;
      case ZodiacElement.fire:
        raw[Maestro.caligo] = raw[Maestro.caligo]! + 0.3;
        raw[Maestro.medora] = raw[Maestro.medora]! + 0.1;
    }
  }

  for (final p in chart.planets) {
    final s = p.sign.italianName;
    switch (p.id) {
      case 'sun':
        sign(Maestro.medora, 3, 'il Sole in $s, luce del tuo cielo');
      case 'moon':
        sign(Maestro.aura, 3, 'la Luna in $s, marea dei tuoi bisogni');
        sign(Maestro.medora, 1, 'la Luna, luce della notte');
      case 'mercury':
        sign(Maestro.medora, 2, 'Mercurio in $s, la tua mente');
      case 'venus':
        sign(Maestro.aura, 2, 'Venere in $s, il tuo modo di amare');
      case 'mars':
        sign(Maestro.caligo, 1.5, 'Marte in $s, il tuo fuoco d\'azione');
      case 'jupiter':
        sign(Maestro.medora, 1, 'Giove in $s, il respiro del destino');
      case 'saturn':
        sign(Maestro.caligo, 2.5, 'Saturno in $s, maestro del limite');
      case 'uranus':
        sign(Maestro.medora, 0.5, 'Urano in $s, il lampo del cambiamento');
      case 'neptune':
        sign(Maestro.aura, 1.5, 'Nettuno in $s, il tuo sogno');
      case 'pluto':
        sign(Maestro.caligo, 2.5, 'Plutone in $s, signore della trasformazione');
      case 'chiron':
        sign(Maestro.aura, 1, 'Chirone in $s, la ferita che guarisce');
      case 'lilith':
        sign(Maestro.caligo, 1, 'Lilith in $s, la tua ombra');
      case 'north_node':
        sign(Maestro.medora, 1, 'il Nodo in $s, la direzione dell\'anima');
    }

    element(p.sign.element);

    // Segni firma di Caligo, ovunque cadano.
    if (p.sign == Zodiac.scorpio) {
      sign(Maestro.caligo, 1.0, 'lo Scorpione nel tuo cielo');
    } else if (p.sign == Zodiac.capricorn) {
      sign(Maestro.caligo, 0.7, 'il Capricorno nel tuo cielo');
    }

    // Case firma.
    switch (p.house) {
      case 3:
      case 9:
        sign(Maestro.medora, 0.5, 'le case del pensiero e del viaggio');
      case 4:
      case 6:
        sign(Maestro.aura, 0.5, 'le case della casa e del corpo');
      case 8:
      case 12:
        sign(Maestro.caligo, 1.0, 'le case dell\'ombra');
    }
  }

  // Angoli: firma forte di Medora.
  if (chart.ascendant != null) {
    sign(Maestro.medora, 2,
        'l\'Ascendente in ${chart.ascendant!.italianName}, la soglia da cui ti mostri');
    element(chart.ascendant!.element);
  }
  if (chart.midheaven != null) {
    sign(Maestro.medora, 1,
        'il Medio Cielo in ${chart.midheaven!.italianName}, la tua vetta');
  }

  // Ogni Maestro si misura sul PROPRIO massimo, non sui punti grezzi: conta
  // quanta parte del suo dominio la carta ha acceso, non quanti indicatori quel
  // dominio possieda. Senza questo vince chi ha piu' voci in elenco, ed e'
  // esattamente quel che accadeva a Medora.
  final attesi = <Maestro, double>{for (final m in Maestro.values) m: 0.0};
  for (final p in chart.planets) {
    final fissi = _pesiFissi[p.id];
    if (fissi != null) {
      for (final e in fissi.entries) {
        attesi[e.key] = attesi[e.key]! + e.value;
      }
    }
    for (final m in Maestro.values) {
      attesi[m] = attesi[m]! + _attesoPerPianeta[m]!;
    }
  }
  // Gli angoli sono di Medora, quindi entrano nel suo atteso solo se ci sono.
  // L'Ascendente vale 2 di firma piu' il suo elemento, che come per i pianeti
  // si conta al valore atteso, 0,15, non al massimo dell'aria: contarlo a 0,5
  // gonfiava il divisore di Medora di un terzo di punto, quel che bastava a
  // tenerla sotto il minimo.
  if (chart.ascendant != null) {
    attesi[Maestro.medora] = attesi[Maestro.medora]! + 2.15;
  }
  if (chart.midheaven != null) {
    attesi[Maestro.medora] = attesi[Maestro.medora]! + 1;
  }

  final quota = <Maestro, double>{
    for (final m in Maestro.values)
      m: attesi[m]! > 0 ? raw[m]! / attesi[m]! : 0.0,
  };
  final total = quota.values.fold<double>(0, (a, b) => a + b);
  final scores = <Maestro, double>{
    for (final e in quota.entries)
      e.key: total > 0 ? e.value / total : 1 / 3,
  };

  final ranked = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final winner = ranked.first.key;
  final nearTie = ranked.length > 1 && (ranked.first.value - ranked[1].value) < 0.06;

  // Il fattore decisivo: la firma piu' pesante del vincitore.
  final winnerFactors = factors.where((f) => f.maestro == winner).toList()
    ..sort((a, b) => b.weight.compareTo(a.weight));
  final deciding = winnerFactors.isNotEmpty
      ? winnerFactors.first.label
      : 'il tuo cielo';

  final reason = _reason(winner, deciding, nearTie);
  return Resonance(
    scores: scores,
    winner: winner,
    reason: reason,
    deciding: deciding,
    nearTie: nearTie,
  );
}

String _voice(Maestro winner) => switch (winner) {
      Maestro.medora => 'Medora, che legge le stelle',
      Maestro.aura => 'Aura, che custodisce l\'energia',
      Maestro.caligo => 'Caligo, che conosce i riti',
    };

String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _reason(Maestro winner, String deciding, bool nearTie) {
  final voice = _voice(winner);
  if (nearTie) {
    return 'Le tre voci sono vicine, ma $deciding fa pendere la bilancia verso $voice.';
  }
  return '${_cap(deciding)} chiama più forte la voce di $voice.';
}

/// La Risonanza quando si ha il solo segno solare.
///
/// Deterministica come il resto: lo stesso segno da' sempre lo stesso Maestro.
/// I punteggi sono dichiarati invece che calcolati, perche' con un dato solo
/// una percentuale fingerebbe una precisione che non c'e'. La frase lo dice.
Resonance _dalSoloSegno(Zodiac sunSign) {
  final winner = _maestroDelSegno[sunSign] ?? Maestro.medora;
  final scores = <Maestro, double>{
    for (final m in Maestro.values) m: m == winner ? 0.5 : 0.25,
  };
  final deciding = 'il Sole in ${sunSign.italianName}';
  return Resonance(
    scores: scores,
    winner: winner,
    reason: '${_cap(deciding)} chiama la voce di ${_voice(winner)}. '
        'Con l\'ora di nascita la lettura si fara\' piu\' precisa.',
    deciding: deciding,
    nearTie: false,
  );
}
