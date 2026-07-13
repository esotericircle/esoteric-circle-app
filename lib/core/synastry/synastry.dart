import '../astro/zodiac.dart';
import '../identity/circle_seal.dart' show SealElement;

/// L'esito di una sinastria: una percentuale di affinita', un titolo e una riga
/// di lettura. Deterministico dai due segni, senza AI.
class SynastryResult {
  const SynastryResult({
    required this.percent,
    required this.title,
    required this.reading,
  });

  final int percent;
  final String title;
  final String reading;
}

/// Calcolo deterministico dell'affinita' fra due segni, per elemento.
///
/// Non e' una promessa sul futuro: e' un gioco simbolico di intrattenimento,
/// nella tradizione dell'astrologia relazionale. Lo stesso paio di segni da'
/// sempre lo stesso esito.
class Synastry {
  const Synastry._();

  static SynastryResult between(Zodiac a, Zodiac b) {
    final nudge = (a.index + b.index) % 5;
    if (a == b) {
      return SynastryResult(
        percent: (95 + (nudge % 3)).clamp(0, 99),
        title: 'Anime gemelle',
        reading:
            'Stesso segno, stesso passo: vi riconoscete al volo. La sfida è non specchiarvi troppo.',
      );
    }
    final ea = SealElement.of(a);
    final eb = SealElement.of(b);
    if (ea == eb) {
      return SynastryResult(
        percent: (86 + nudge).clamp(0, 98),
        title: 'Stesso elemento',
        reading:
            'Vi muovete allo stesso ritmo: intesa naturale, calore che non serve spiegare.',
      );
    }
    if (_complementary(ea, eb)) {
      return SynastryResult(
        percent: (80 + nudge).clamp(0, 96),
        title: 'Complementari',
        reading:
            'Vi accendete a vicenda: uno dà slancio, l\'altro respiro. Un bell\'equilibrio.',
      );
    }
    if (_tension(ea, eb)) {
      return SynastryResult(
        percent: (64 + nudge).clamp(0, 90),
        title: 'Tensione feconda',
        reading:
            'Attrazione e attrito insieme: vi tirate fuori il meglio, se restate curiosi.',
      );
    }
    return SynastryResult(
      percent: (72 + nudge).clamp(0, 92),
      title: 'Cammino di crescita',
      reading:
          'Elementi diversi, lezioni preziose: imparate l\'uno dall\'altro, un passo per volta.',
    );
  }

  // Fuoco con Aria, Terra con Acqua: si alimentano.
  static bool _complementary(SealElement a, SealElement b) {
    final s = {a, b};
    return s.containsAll({SealElement.fuoco, SealElement.aria}) ||
        s.containsAll({SealElement.terra, SealElement.acqua});
  }

  // Fuoco con Acqua, Aria con Terra: opposti che si sfidano.
  static bool _tension(SealElement a, SealElement b) {
    final s = {a, b};
    return s.containsAll({SealElement.fuoco, SealElement.acqua}) ||
        s.containsAll({SealElement.aria, SealElement.terra});
  }
}
