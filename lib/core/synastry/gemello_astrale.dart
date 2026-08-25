import 'cielo_della_sinastria.dart';
import 'synastry_report.dart';
import 'vip_catalog.dart';

/// IL GEMELLO ASTRALE. Ordine BO voce 10.
///
/// **Quale dei cinquanta ha il cielo piu' vicino al tuo.** Non e' un gioco a
/// parte: e' la stessa sinastria, chiesta a tutti e cinquanta invece che a
/// uno, e vinta da chi fa il punteggio piu' alto.
///
/// **E' deterministico per costruzione**, perche' lo e' ogni responso: la
/// stessa persona trova sempre lo stesso gemello, e non c'e' nessun sorteggio
/// da nessuna parte.
class GemelloAstrale {
  const GemelloAstrale({
    required this.vip,
    required this.punteggio,
    required this.secondo,
    required this.punteggioDelSecondo,
  });

  final Vip vip;
  final int punteggio;

  /// Chi viene subito dopo. Serve a dire quanto e' netta la vittoria, e a
  /// una prova per verificare che il primo sia davvero il primo.
  final Vip secondo;
  final int punteggioDelSecondo;

  /// Di quanto il gemello stacca il secondo.
  int get distacco => punteggio - punteggioDelSecondo;

  /// **IL CONTO SU TUTTI E CINQUANTA.** Nessuna scorciatoia, nessun
  /// campionamento: si calcola il responso per ognuno e si prende il migliore.
  /// Il cielo di un VIP costa un pugno di moltiplicazioni, quindi cinquanta
  /// costano quanto uno per cinquanta volte, e sta comodamente dentro il tetto.
  ///
  /// **A parita' di punteggio vince chi viene prima nel catalogo**, e non e'
  /// un dettaglio: senza una regola di spareggio dichiarata due esecuzioni
  /// potrebbero dare due gemelli diversi, che e' esattamente cio' che
  /// "deterministico" esclude.
  static GemelloAstrale? per(CieloDiSinastria tuo) {
    Vip? primo;
    var punteggioPrimo = -1;
    Vip? secondo;
    var punteggioSecondo = -1;
    for (final v in VipCatalog.vips) {
      final p = SynastryReport.perCieli(tuo: tuo, vip: v).overall;
      if (p > punteggioPrimo) {
        secondo = primo;
        punteggioSecondo = punteggioPrimo;
        primo = v;
        punteggioPrimo = p;
      } else if (p > punteggioSecondo) {
        secondo = v;
        punteggioSecondo = p;
      }
    }
    if (primo == null || secondo == null) return null;
    return GemelloAstrale(
      vip: primo,
      punteggio: punteggioPrimo,
      secondo: secondo,
      punteggioDelSecondo: punteggioSecondo,
    );
  }

  /// La riga che lo annuncia, col fatto invece di un superlativo.
  String get annuncio => distacco <= 1
      ? 'Il tuo gemello astrale è ${vip.name}, ma ${secondo.name} gli sta '
          'addosso: fra i due c\'è un punto solo.'
      : 'Il tuo gemello astrale è ${vip.name}, con $punteggio su cento. '
          'Stacca ${secondo.name} di $distacco punti.';
}
