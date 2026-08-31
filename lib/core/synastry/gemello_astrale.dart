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
    required this.terzo,
    required this.punteggioDelTerzo,
  });

  final Vip vip;
  final int punteggio;

  /// Chi viene subito dopo. Serve a dire quanto e' netta la vittoria, e a
  /// una prova per verificare che il primo sia davvero il primo.
  final Vip secondo;
  final int punteggioDelSecondo;

  /// **IL TERZO DEL PODIO.** Richiesta del fondatore del 31 agosto 2026: la
  /// classifica dei primi tre, col podio disegnato.
  final Vip terzo;
  final int punteggioDelTerzo;

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
    // **IL PODIO SI COSTRUISCE ORDINANDO, non con tre variabili. Richiesta
    // del fondatore del 31 agosto 2026.** Il conto teneva primo e secondo con
    // due coppie di variabili, e per il terzo ne sarebbe servita una terza:
    // tre coppie che si scambiano a mano sono il modo in cui un podio nasce
    // sbagliato. Cinquanta punteggi si ordinano in un soffio.
    final conto = <(Vip, int)>[
      for (final v in VipCatalog.vips)
        (v, SynastryReport.perCieli(tuo: tuo, vip: v).overall),
    ];
    // **A parita' di punteggio vince chi viene prima nel catalogo**, e non e'
    // un dettaglio: senza una regola di spareggio dichiarata due esecuzioni
    // potrebbero dare due gemelli diversi. `sort` in Dart e' stabile, quindi
    // l'ordine del catalogo regge da solo.
    conto.sort((a, b) => b.$2.compareTo(a.$2));
    if (conto.length < 3) return null;
    return GemelloAstrale(
      vip: conto[0].$1,
      punteggio: conto[0].$2,
      secondo: conto[1].$1,
      punteggioDelSecondo: conto[1].$2,
      terzo: conto[2].$1,
      punteggioDelTerzo: conto[2].$2,
    );
  }

  /// **IL PODIO, primo secondo e terzo.** Richiesta del fondatore del 31
  /// agosto 2026: "inserirei prima di tutto una classifica dei primi 3
  /// risultati/carte vip con una specie di podio graficamente, come in
  /// Formula uno".
  List<({Vip vip, int punteggio, int posto})> get podio => [
        (vip: vip, punteggio: punteggio, posto: 1),
        (vip: secondo, punteggio: punteggioDelSecondo, posto: 2),
        (vip: terzo, punteggio: punteggioDelTerzo, posto: 3),
      ];

  /// La riga che lo annuncia, col fatto invece di un superlativo.
  String get annuncio => distacco <= 1
      ? 'Il tuo gemello astrale è ${vip.name}, ma ${secondo.name} gli sta '
          'addosso: fra i due c\'è un punto solo.'
      : 'Il tuo gemello astrale è ${vip.name}, con $punteggio su cento. '
          'Stacca ${secondo.name} di $distacco punti.';
}
