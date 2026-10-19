import 'dart:math' as math;
import 'dart:ui';

/// **LA CARTA DI UN ANIMALE, IN QUATTRO PEZZI ORIZZONTALI.** Ordine FZ voce
/// FZ.04, 17 ottobre 2026. Il fondatore, 11:38: *"una card tutta da scoprire
/// a pezzi, ma non l'animale da scoprire, ma una card intera, una schermata
/// quasi intera. La card dell'animale da grattare"*; 11:48: *"Stile A"*.
///
/// **SOSTITUISCE `IlVeloDellAnimale`** (ordine DI voce 10, DQ voce 05): non
/// piu' il velo sulla sola sagoma dell'animale, ma la cenere sopra la
/// fotografia intera (`*_carta_da_grattare_v1.jpg`), a quasi tutto schermo.
/// **La contabilita' per pezzi resta** (un pezzo per discesa, lo stesso
/// pennello: [raggioDelPennello], [chiarezza], [scoperteDa]), e cio' che
/// cambia e' la geometria: non una sagoma con la testa protetta fino alla
/// quarta, ma quattro fasce uguali, tutte da grattare col dito, **nessuna
/// che cade da sola**. Il volto sta nella fascia piu' alta e si scopre per
/// ultimo perche' e' l'ultimo pezzo a grattarsi, non perche' un cumulo lo
/// protegga: vedi [pezzoAttivo].
///
/// **NESSUN CUMULO, NESSUNA TESTA**: [cumulo] e [testa] restano per la
/// stessa porta di `PittoreDellaCenere`, che li legge per decidere se
/// ridipingere la nube sopra una zona protetta. Qui non c'e' zona protetta:
/// [cumulo] e' sempre nullo e [testa] sempre vuota, e il pittore non
/// disegna nessuna nube, senza bisogno di cambiare una riga sua.
///
/// Pura, senza disegno: una guardia la percorre cella per cella.
class LaCartaInQuattroPezzi {
  LaCartaInQuattroPezzi(this.nome, this.pezzoAttivo)
      : assert(pezzoAttivo >= 0 && pezzoAttivo < pezzi);

  final String nome;

  /// **IL PEZZO CHE QUESTA DISCESA PUO' GRATTARE**: 0 il piu' basso, 3 il
  /// volto in alto. Quante apparizioni c'erano prima di questa, alla
  /// lettera di `IlVeloCheSiScosta.quale` che l'ordine DQ aveva scritto per
  /// la sagoma: la stessa cifra, letta adesso come indice di fascia.
  final int pezzoAttivo;

  /// **QUATTRO PEZZI**, come l'ordine: FZ.04 dice "divisa in quattro pezzi".
  static const int pezzi = 4;

  /// Una griglia a ventiquattro colonne: fine abbastanza per un solco
  /// morbido, grossa abbastanza perche' la contabilita' resti leggera.
  static const int _colonne = 24;

  /// Otto righe per fascia: trentadue righe in tutto, divisibili esatte per
  /// [pezzi].
  static const int righePerPezzo = 8;
  static const int _righe = pezzi * righePerPezzo;

  static final List<int> _tutte = [
    for (var i = 0; i < _righe * _colonne; i++) i,
  ];

  /// Istanza e non statico: `PittoreDellaCenere` legge `velo.colonne` e
  /// `velo.righe` su qualunque velo, com'era per `IlVeloDellAnimale`.
  int get colonne => _colonne;
  int get righe => _righe;

  /// **TUTTA LA CARTA E' COPERTA**: non c'e' una sagoma da ritagliare, e' una
  /// fotografia intera a quasi tutto schermo.
  late final Set<int> corpo = Set.of(_tutte);
  late final Set<int> velato = corpo;

  /// Nessuna nube: vedi il commento di classe.
  ({Offset centro, double a, double b})? get cumulo => null;
  Set<int> get testa => const {};

  /// La fascia (0..3) a cui appartiene la cella [i]: 0 la piu' bassa (prima
  /// a scoprirsi), [pezzi]-1 il volto in alto (ultima a scoprirsi).
  static int fasciaDi(int i) {
    final r = i ~/ _colonne;
    final dallAlto = r ~/ righePerPezzo;
    return pezzi - 1 - dallAlto;
  }

  /// **LE CELLE DEL SOLO PEZZO ATTIVO**: le altre fasce non si toccano
  /// ancora, ne' quella sopra ne' quella sotto.
  late final Set<int> scostabile = {
    for (final i in _tutte) if (fasciaDi(i) == pezzoAttivo) i,
  };

  /// **FIN DOVE SI GRATTA OGGI**, in frazione dall'alto: il pezzo attivo e
  /// quelli gia' grattati sotto di lui, mai i pezzi dei giorni dopo. Sopra
  /// questa riga la cenere resta piena anche se il dito ci passa: la
  /// contabilita' contava gia' solo il pezzo attivo, ma il solco scavava
  /// ovunque, e la simulazione del 20 ottobre 2026 ha visto la Lince intera,
  /// volto compreso, alla prima discesa.
  double get cimaDelGrattabile => (pezzi - 1 - pezzoAttivo) / pezzi;

  /// Se il punto [frazione] della carta sta dove oggi si puo' grattare.
  bool siGratta(Offset frazione) => frazione.dy >= cimaDelGrattabile;

  /// **IL TRATTO DEL DITO, TAGLIATO SUL BORDO DEL PEZZO DI OGGI**: il pezzo
  /// di [da]..[a] che sta dove si gratta, o nullo se il tratto e' tutto
  /// sopra. Un tratto che arriva da sopra comincia sul bordo, non si perde:
  /// un dito veloce manda pochi punti, e il primo dentro puo' gia' essere in
  /// fondo alla carta.
  (Offset, Offset)? tagliaSulBordo(Offset da, Offset a) {
    final c = cimaDelGrattabile;
    final dentroDa = da.dy >= c;
    final dentroA = a.dy >= c;
    if (dentroDa && dentroA) return (da, a);
    if (!dentroDa && !dentroA) return null;
    final t = (c - da.dy) / (a.dy - da.dy);
    final bordo = Offset(da.dx + (a.dx - da.dx) * t, c);
    return dentroDa ? (da, bordo) : (bordo, a);
  }

  /// **QUANTO SI PUO' SCOPRIRE IN UNA DISCESA**: un pezzo intero, cioe' una
  /// fascia. A differenza della sagoma, qui la quota e' sempre esatta: non
  /// resta mai un'area scostabile piu' piccola della quota, perche' ogni
  /// pezzo e' la stessa misura.
  int get perDiscesa => _righe ~/ pezzi * _colonne;

  /// Il rettangolo di una cella, in frazione della carta.
  Rect cella(int i) {
    final r = i ~/ _colonne;
    final c = i % _colonne;
    return Rect.fromLTWH(c / _colonne, r / _righe, 1 / _colonne, 1 / _righe);
  }

  /// Il centro di una cella, in frazione della carta.
  Offset centro(int i) => cella(i).center;

  /// **IL RAGGIO DEL PENNELLO, IN PUNTI LOGICI.** Stessa misura dell'ordine
  /// DQ voce 05: il dito dipinge su una maschera alla risoluzione piena
  /// dello schermo, con un pennello a bordo morbido.
  static const double raggioDelPennello = 18;

  /// **DOVE IL PENNELLO SCOPRE ABBASTANZA PER CONTARE.**
  static const double doveContaIlPennello = 0.8;

  /// **QUANTO IL PENNELLO SCOPRE**, da 1 a 0, a [distanza] punti dal tratto.
  static double chiarezza(double distanza) {
    const r = raggioDelPennello;
    if (distanza <= r * 0.6) return 1;
    if (distanza >= r) return 0;
    final t = (r - distanza) / (r * 0.4);
    return t * t * (3 - 2 * t);
  }

  /// **LE CELLE CHE UN TRATTO DEL DITO SCOPRE**, dalla piu' vicina: le
  /// scostabili (del solo pezzo attivo) dove la maschera del pennello,
  /// campionata al centro della cella, e' almeno a meta'.
  List<int> scoperteDa(Offset da, Offset a, Size illustrazione) {
    if (illustrazione.isEmpty) return const [];
    final w = illustrazione.width;
    final h = illustrazione.height;
    final p0 = Offset(da.dx * w, da.dy * h);
    final p1 = Offset(a.dx * w, a.dy * h);
    const quanto = raggioDelPennello * doveContaIlPennello;
    final cw = w / _colonne;
    final ch = h / _righe;
    final c0 = ((math.min(p0.dx, p1.dx) - quanto) / cw)
        .floor()
        .clamp(0, _colonne - 1);
    final c1 = ((math.max(p0.dx, p1.dx) + quanto) / cw)
        .ceil()
        .clamp(0, _colonne - 1);
    final r0 = ((math.min(p0.dy, p1.dy) - quanto) / ch)
        .floor()
        .clamp(0, _righe - 1);
    final r1 = ((math.max(p0.dy, p1.dy) + quanto) / ch)
        .ceil()
        .clamp(0, _righe - 1);
    final dentro = <(int, double)>[];
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        final i = r * _colonne + c;
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
