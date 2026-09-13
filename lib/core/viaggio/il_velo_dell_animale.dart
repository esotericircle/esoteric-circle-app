import 'dart:math' as math;
import 'dart:ui';

import 'dove_sta_la_testa.dart';
import 'le_sagome_in_celle.dart';

/// **IL VELO DI UN ANIMALE, IN CELLE: cosa si puo' scostare, e quanto.**
/// Ordine DI voce 10, 12 settembre 2026.
///
/// **La misura dell'ordine:** *"la lente scopre fasce orizzontali larghe tutta
/// l'immagine: il corpo sotto la testa e' diviso in tre fasce di uguale
/// altezza, scoperte dal basso verso l'alto una per discesa. Il bordo netto
/// orizzontale taglia zampe e coda, e si vede."*
///
/// **Adesso la maschera non e' piu' geometrica**: il velo sta sulla sagoma
/// vera dell'animale, cella per cella, e il bordo lo disegna la mano. Le due
/// regole che tengono in piedi le quattro apparizioni stanno qui, e non nel
/// disegno:
///
/// - **ogni discesa concede una quantita' di superficie, non una zona**: un
///   quarto dell'area del corpo, come dice l'ordine, testa compresa nel
///   conto. Esaurita la quantita', il dito non scopre piu' e il velo residuo
///   resta. Poiche' la testa non si scosta, dopo tre discese resta sempre
///   velato almeno il volto; nel Gufo e nella Volpe, che hanno la testa
///   grande, **soltanto** il volto;
/// - **la testa e' protetta fino alla quarta** e non si scosta: alla quarta il
///   velo cade da solo. La testa e' quella gia' tabulata per i dodici animali,
///   `DoveStaLaTesta`, e sopra non c'e' la sua forma ma **un cumulo di cenere
///   informe** che la contiene: vedi [testa].
///
/// Pura, senza disegno: una guardia la percorre cella per cella.
class IlVeloDellAnimale {
  IlVeloDellAnimale(this.nome) : _righe = LeSagome.griglie[nome] ?? const [];

  final String nome;
  final List<String> _righe;

  int get colonne => LeSagome.colonne;
  int get righe => _righe.length;

  /// **LE CELLE DI CORPO**, dalla sagoma.
  late final Set<int> corpo = {
    for (var r = 0; r < righe; r++)
      for (var c = 0; c < colonne; c++)
        if (_righe[r].length > c && _righe[r][c] == '#') r * colonne + c,
  };

  /// **LE CELLE SOTTO IL CUMULO DELLA TESTA**: di corpo o di vuoto, quelle
  /// che **toccano anche di poco** il rettangolo della testa gia' tabulato,
  /// allargato del margine di sicurezza, piu' quelle col centro dentro il
  /// [cumulo]. Non si scostano, e cadono alla quarta.
  ///
  /// **Toccano, e non "hanno il centro dentro".** Una cella scostata mostra
  /// tutti i suoi pixel: se una cella col centro fuori entrasse nel
  /// rettangolo anche di un filo, quel filo di testa si vedrebbe prima della
  /// quarta. Cosi' invece la regola si dimostra senza guardare i pixel:
  /// nessuna cella scostabile ha un punto in comune col rettangolo.
  ///
  /// **DI CORPO O DI VUOTO, e non soltanto di corpo.** La prima stesura
  /// copriva la testa con le sole celle della sua sagoma, e la cenere
  /// disegnava la testa: sul Cervo, alla prima discesa, **due palchi di
  /// cenere** dicevano il nome tre discese prima. Adesso sulla testa c'e' un
  /// cumulo, e il cumulo non ha palchi, ne' orecchie, ne' becco.
  ///
  late final Set<int> testa = () {
    final t = DoveStaLaTesta.di(nome);
    final n = cumulo;
    if (t == null || n == null) return <int>{};
    const m = DoveStaLaTesta.margineDiSicurezza;
    final allargata =
        Rect.fromLTRB(t.left - m, t.top - m, t.right + m, t.bottom + m);
    return {
      for (var i = 0; i < righe * colonne; i++)
        if (allargata.overlaps(cella(i)) ||
            math.pow((centro(i).dx - n.centro.dx) / n.a, 2) +
                    math.pow((centro(i).dy - n.centro.dy) / n.b, 2) <=
                1)
          i,
    };
  }();

  /// **IL CUMULO DI CENERE SULLA TESTA**, in frazioni dell'illustrazione:
  /// l'ellisse che passa per gli angoli del rettangolo della testa allargato,
  /// cioe' la piu' piccola ellisse con le sue proporzioni che lo contiene
  /// tutto. Chi lo disegna ci aggiunge le gobbe e le scaglie del contorno.
  ///
  /// **UN'ELLISSE E NON LE CELLE**, perche' le celle stanno dentro la griglia:
  /// la prima stesura faceva il cumulo di celle, e dove la testa tocca il bordo
  /// alto dell'illustrazione, come i palchi del Cervo, il cumulo aveva **la
  /// cima tagliata dritta**. Un rettangolo di cenere e' ancora una maschera
  /// geometrica. L'ellisse invece puo' uscire dall'illustrazione, e sopra la
  /// testa resta una nube.
  late final ({Offset centro, double a, double b})? cumulo = () {
    final t = DoveStaLaTesta.di(nome);
    if (t == null) return null;
    const m = DoveStaLaTesta.margineDiSicurezza;
    final allargata =
        Rect.fromLTRB(t.left - m, t.top - m, t.right + m, t.bottom + m);
    return (
      centro: allargata.center,
      a: allargata.width / 2 * math.sqrt2,
      b: allargata.height / 2 * math.sqrt2,
    );
  }();

  /// **CIO' CHE LA CENERE COPRE ALLA PRIMA DISCESA**: il corpo e il cumulo
  /// sulla testa.
  late final Set<int> velato = corpo.union(testa);

  /// **CIO' CHE SI PUO' SCOSTARE**: il corpo senza il cumulo della testa.
  late final Set<int> scostabile = corpo.difference(testa);

  /// **QUANTO SI PUO' SCOSTARE IN UNA DISCESA**: un quarto dell'area del
  /// corpo, arrotondato per eccesso. **Del corpo intero**, alla lettera
  /// dell'ordine: la prima stesura contava il corpo senza la testa, e dava a
  /// ogni discesa meno di quanto l'ordine concede.
  int get perDiscesa => (corpo.length / 4).ceil();

  /// Il rettangolo di una cella, in frazione dell'illustrazione.
  Rect cella(int i) {
    final r = i ~/ colonne;
    final c = i % colonne;
    return Rect.fromLTWH(c / colonne, r / righe, 1 / colonne, 1 / righe);
  }

  /// Il centro di una cella, in frazione dell'illustrazione.
  Offset centro(int i) => cella(i).center;

  /// **LE CELLE SCOSTABILI VICINE A UN PUNTO**, entro [raggio] celle, dalla
  /// piu' vicina: e' l'ordine in cui la mano le scosta.
  List<int> vicine(Offset punto, double raggio) {
    final cx = punto.dx * colonne;
    final cy = punto.dy * righe;
    final dentro = <(int, double)>[];
    final r0 = (cy - raggio).floor().clamp(0, righe - 1);
    final r1 = (cy + raggio).ceil().clamp(0, righe - 1);
    final c0 = (cx - raggio).floor().clamp(0, colonne - 1);
    final c1 = (cx + raggio).ceil().clamp(0, colonne - 1);
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        final i = r * colonne + c;
        if (!scostabile.contains(i)) continue;
        final d = math.sqrt(math.pow(c + 0.5 - cx, 2) + math.pow(r + 0.5 - cy, 2));
        if (d <= raggio) dentro.add((i, d));
      }
    }
    dentro.sort((a, b) => a.$2.compareTo(b.$2));
    return [for (final x in dentro) x.$1];
  }

  /// **QUANTE DISCESE DI CENERE CI SONO**: tre, poi alla quarta cade da sola.
  static const int discesePrimaDellaTesta = 3;
}
