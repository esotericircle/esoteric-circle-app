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

  // --- IL PENNELLO, ordine DQ voce 05 ---------------------------------------

  /// **IL RAGGIO DEL PENNELLO, IN PUNTI LOGICI.** Ordine DQ voce 05, 15
  /// settembre 2026: *"il dito dipinge su una maschera alla risoluzione piena
  /// dello schermo, con un pennello a bordo morbido il cui raggio si misura in
  /// punti logici e non in celle"*. Diciotto punti: la punta di un dito.
  static const double raggioDelPennello = 18;

  /// **DOVE IL PENNELLO SCOPRE ABBASTANZA PER CONTARE**: a quattro quinti del
  /// raggio, dove la maschera e' a meta'. Vedi [chiarezza].
  static const double doveContaIlPennello = 0.8;

  /// **QUANTO IL PENNELLO SCOPRE**, da 1 a 0, a [distanza] punti dal tratto.
  /// Pieno fino a sei decimi del raggio, poi scende morbido fino al bordo:
  /// e' la maschera che il disegno dipinge, scritta come funzione.
  static double chiarezza(double distanza) {
    const r = raggioDelPennello;
    if (distanza <= r * 0.6) return 1;
    if (distanza >= r) return 0;
    final t = (r - distanza) / (r * 0.4);
    return t * t * (3 - 2 * t);
  }

  /// **LE CELLE CHE UN TRATTO DEL DITO SCOPRE**, dalla piu' vicina: le
  /// scostabili dove la maschera del pennello, campionata al centro della
  /// cella, e' almeno a meta'. **La griglia campiona la maschera, e non il
  /// contrario**: la quantita' consumata si ricava da cio' che il dito ha
  /// dipinto. [da] e [a] in frazioni dell'illustrazione, [illustrazione] la
  /// sua misura in punti.
  List<int> scoperteDa(Offset da, Offset a, Size illustrazione) {
    if (illustrazione.isEmpty) return const [];
    final w = illustrazione.width;
    final h = illustrazione.height;
    final p0 = Offset(da.dx * w, da.dy * h);
    final p1 = Offset(a.dx * w, a.dy * h);
    const quanto = raggioDelPennello * doveContaIlPennello;
    final cw = w / colonne;
    final ch = h / righe;
    final c0 = ((math.min(p0.dx, p1.dx) - quanto) / cw).floor().clamp(0, colonne - 1);
    final c1 = ((math.max(p0.dx, p1.dx) + quanto) / cw).ceil().clamp(0, colonne - 1);
    final r0 = ((math.min(p0.dy, p1.dy) - quanto) / ch).floor().clamp(0, righe - 1);
    final r1 = ((math.max(p0.dy, p1.dy) + quanto) / ch).ceil().clamp(0, righe - 1);
    final dentro = <(int, double)>[];
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        final i = r * colonne + c;
        if (!scostabile.contains(i)) continue;
        final d = _distanza(Offset((c + 0.5) * cw, (r + 0.5) * ch), p0, p1);
        if (d <= quanto) dentro.add((i, d));
      }
    }
    dentro.sort((x, y) => x.$2.compareTo(y.$2));
    return [for (final x in dentro) x.$1];
  }

  /// La distanza di [p] dal segmento da [a] a [b].
  static double _distanza(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final l2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (l2 == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / l2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}
