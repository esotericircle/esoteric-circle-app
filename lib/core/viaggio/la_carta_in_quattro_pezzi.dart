import 'dart:math' as math;
import 'dart:ui';

/// **LA CARTA DI UN ANIMALE, IN QUATTRO PEZZI, COL VOLTO PER ULTIMO.** Ordine
/// FZ voce FZ.04, 17 ottobre 2026. Il fondatore, 11:38: *"una card tutta da
/// scoprire a pezzi, ma non l'animale da scoprire, ma una card intera, una
/// schermata quasi intera. La card dell'animale da grattare"*; 11:48:
/// *"Stile A"*. E l'ordine: *"Il volto dell'animale sta nel quarto pezzo e si
/// scopre per ultimo"*.
///
/// **SOSTITUISCE `IlVeloDellAnimale`** (ordine DI voce 10, DQ voce 05): la
/// cenere copre tutta l'immagine dell'animale di lato
/// (`assets/img/animali/ani_*_v1.webp`), con la sua proporzione vera, per
/// decisione del fondatore del 20 ottobre 2026 (*"non devi usare il video,
/// ma l'immagine dell'animale di lato"*). **La contabilita' per pezzi resta**
/// (un pezzo per discesa, lo stesso pennello: [raggioDelPennello],
/// [chiarezza], [scoperteDa]), **nessun pezzo cade da solo**.
///
/// **LA GEOMETRIA, RIFATTA DALLA SIMULAZIONE DA PERSONA DEL 20 OTTOBRE
/// 2026.** Fino a quel giorno i pezzi erano quattro fasce uguali scoperte dal
/// basso, e il volto doveva stare in quella piu' alta: sul Realme la testa
/// del Cavallo si vedeva gia' al terzo pezzo. Adesso **il quarto pezzo e' il
/// volto di ciascun animale**, il rettangolo misurato immagine per immagine
/// in [volti]; il resto si divide in tre fasce, dal basso: le stesse tre
/// discese di prima, ma nessuna tocca il volto.
///
/// **NESSUN CUMULO, NESSUNA TESTA**: [cumulo] e [testa] restano per la
/// stessa porta di `PittoreDellaCenere`, che li legge per decidere se
/// ridipingere la nube sopra una zona protetta. Qui non c'e' zona protetta:
/// il volto si protegge perche' non e' scostabile prima della quarta, non
/// con una nube.
///
/// Pura, senza disegno: una guardia la percorre cella per cella.
class LaCartaInQuattroPezzi {
  LaCartaInQuattroPezzi(this.nome, this.pezzoAttivo)
      : assert(pezzoAttivo >= 0 && pezzoAttivo < pezzi);

  final String nome;

  /// **IL PEZZO CHE QUESTA DISCESA PUO' GRATTARE**: 0 la fascia piu' bassa,
  /// 1 quella di mezzo, 2 quella in cima, 3 il volto. Quante volte questo
  /// animale era stato seguito prima di questa discesa.
  final int pezzoAttivo;

  /// **QUATTRO PEZZI**, come l'ordine: FZ.04 dice "divisa in quattro pezzi".
  static const int pezzi = 4;

  /// Una griglia a ventiquattro colonne: fine abbastanza per un solco
  /// morbido, grossa abbastanza perche' la contabilita' resti leggera.
  static const int _colonne = 24;

  /// Trentadue righe: la griglia di sempre, che i Diari scritti prima
  /// conoscono.
  static const int _righe = 32;

  /// **DOVE COMINCIANO LE TRE FASCE**, in righe dall'alto: la fascia in cima
  /// va da 0 a 10, quella di mezzo da 11 a 20, quella in basso da 21 a 31.
  static const int _cimaDiMezzo = 11;
  static const int _cimaDelBasso = 21;

  /// **IL VOLTO DI OGNI ANIMALE**, in frazioni dell'immagine dell'animale di
  /// lato (`assets/img/animali/ani_*_v1.webp`), misurato a occhio su ogni
  /// immagine con una griglia di decimi e controllato disegnandoci sopra il
  /// rettangolo, il 20 ottobre 2026: dalle orecchie (o dalla cresta) al mento
  /// (o al becco), con un margine. Le corna del Cervo restano fuori. Un nome
  /// che non c'e' prende [voltoMedio], cosi' nessun pezzo resta mai senza
  /// volto.
  ///
  /// **Sull'immagine di lato e non sulla carta del video**: parola del
  /// fondatore dello stesso giorno, vista la lente col fotogramma frontale,
  /// *"Per la cenere da scostare, non devi usare il video, ma l'immagine
  /// dell'animale di lato"*.
  static const Map<String, Rect> volti = {
    'Aquila': Rect.fromLTRB(0.0, 0.0, 0.38, 0.22),
    'Cavallo': Rect.fromLTRB(0.0, 0.0, 0.22, 0.36),
    'Cervo': Rect.fromLTRB(0.55, 0.06, 0.79, 0.32),
    'Corvo': Rect.fromLTRB(0.58, 0.0, 1.0, 0.28),
    'Falco': Rect.fromLTRB(0.0, 0.0, 0.32, 0.22),
    'Gufo': Rect.fromLTRB(0.27, 0.0, 0.88, 0.32),
    'Lince': Rect.fromLTRB(0.52, 0.0, 0.94, 0.33),
    'Lupo': Rect.fromLTRB(0.0, 0.0, 0.27, 0.33),
    'Orso': Rect.fromLTRB(0.67, 0.0, 1.0, 0.36),
    'Serpente': Rect.fromLTRB(0.45, 0.06, 0.72, 0.27),
    'Tartaruga': Rect.fromLTRB(0.70, 0.0, 0.94, 0.31),
    'Volpe': Rect.fromLTRB(0.76, 0.0, 1.0, 0.45),
  };

  /// Il volto di chi non e' fra i dodici: la parte alta e centrale.
  static const Rect voltoMedio = Rect.fromLTRB(0.35, 0.0, 0.65, 0.3);

  /// Il volto di questa carta.
  Rect get volto => volti[nome] ?? voltoMedio;

  /// **LA MISURA VERA DELL'IMMAGINE DI LATO**, in pixel: la carta prende la
  /// sua proporzione, mai una stirata. Fino al 20 ottobre 2026 la lente la
  /// disegnava in un rettangolo 1080x1920 con `BoxFit.fill`, e un Cavallo
  /// quasi quadrato diventava alto il doppio. La guardia
  /// `il_volto_si_scopre_per_ultimo_test` confronta questi numeri coi file.
  static const Map<String, Size> misure = {
    'Aquila': Size(688, 807),
    'Cavallo': Size(878, 844),
    'Cervo': Size(765, 933),
    'Corvo': Size(847, 704),
    'Falco': Size(805, 749),
    'Gufo': Size(537, 865),
    'Lince': Size(689, 875),
    'Lupo': Size(898, 760),
    'Orso': Size(900, 736),
    'Serpente': Size(808, 772),
    'Tartaruga': Size(936, 688),
    'Volpe': Size(894, 575),
  };

  /// La misura di questa carta.
  Size get misura => misure[nome] ?? const Size(800, 800);

  static final List<int> _tutte = [
    for (var i = 0; i < _righe * _colonne; i++) i,
  ];

  /// Istanza e non statico: `PittoreDellaCenere` legge `velo.colonne` e
  /// `velo.righe` su qualunque velo, com'era per `IlVeloDellAnimale`.
  int get colonne => _colonne;
  int get righe => _righe;

  /// **TUTTA LA CARTA E' COPERTA**: non c'e' una sagoma da ritagliare, e' una
  /// carta intera a quasi tutto schermo.
  late final Set<int> corpo = Set.of(_tutte);
  late final Set<int> velato = corpo;

  /// Nessuna nube: vedi il commento di classe.
  ({Offset centro, double a, double b})? get cumulo => null;
  Set<int> get testa => const {};

  /// **IL PEZZO A CUI APPARTIENE LA CELLA [i]** su questa carta: 3 se tocca
  /// il volto, anche solo con un lembo (cosi' nessun pezzo del volto cade in
  /// una fascia che si gratta prima), altrimenti la sua fascia (0 in basso, 1
  /// in mezzo, 2 in cima).
  int pezzoDi(int i) {
    if (cella(i).overlaps(volto)) return pezzi - 1;
    final r = i ~/ _colonne;
    if (r >= _cimaDelBasso) return 0;
    if (r >= _cimaDiMezzo) return 1;
    return 2;
  }

  late final List<int> _pezzoDiOgniCella = [for (final i in _tutte) pezzoDi(i)];

  /// **LE CELLE DEL SOLO PEZZO ATTIVO**: gli altri pezzi non si contano.
  late final Set<int> scostabile = {
    for (final i in _tutte)
      if (_pezzoDiOgniCella[i] == pezzoAttivo) i,
  };

  /// **DOVE OGGI IL DITO PUO' SCAVARE**: il pezzo attivo e quelli dei giorni
  /// prima, mai i pezzi dei giorni dopo. La simulazione del 20 ottobre 2026
  /// ha visto la Lince intera, volto compreso, alla prima discesa: la
  /// contabilita' contava solo il pezzo attivo, ma il solco scavava ovunque.
  late final Set<int> grattabile = {
    for (final i in _tutte)
      if (_pezzoDiOgniCella[i] <= pezzoAttivo) i,
  };

  /// La cella sotto il punto [frazione] della carta, dentro i bordi.
  int cellaSotto(Offset frazione) {
    final c = (frazione.dx * _colonne).floor().clamp(0, _colonne - 1);
    final r = (frazione.dy * _righe).floor().clamp(0, _righe - 1);
    return r * _colonne + c;
  }

  /// Se il punto [frazione] della carta sta dove oggi si puo' grattare.
  bool siGratta(Offset frazione) => grattabile.contains(cellaSotto(frazione));

  /// **IL TRATTO DEL DITO, SOLO DOVE OGGI SI GRATTA**: i pezzi di [da]..[a]
  /// che stanno sul grattabile, in ordine, campionati ogni mezza cella. Un
  /// tratto che passa sopra il volto (o sopra un pezzo dei giorni dopo) si
  /// spezza in due e non lo attraversa; un tratto che entra da fuori comincia
  /// dove entra, non si perde: un dito veloce manda pochi punti.
  List<(Offset, Offset)> trattiDentro(Offset da, Offset a) =>
      _trattiDove(da, a, siGratta);

  /// I pezzi di [da]..[a] dove [dentro] vale, campionati ogni mezza cella.
  static List<(Offset, Offset)> _trattiDove(
      Offset da, Offset a, bool Function(Offset) dentro) {
    final passo = 0.5 / math.max(_colonne, _righe);
    final lungo = (a - da).distance;
    final n = math.max(1, (lungo / passo).ceil());
    final fuori = <(Offset, Offset)>[];
    Offset? inizio;
    var ultimo = da;
    for (var k = 0; k <= n; k++) {
      final p = Offset.lerp(da, a, k / n)!;
      if (dentro(p)) {
        inizio ??= p;
        ultimo = p;
      } else if (inizio != null) {
        fuori.add((inizio, ultimo));
        inizio = null;
      }
    }
    if (inizio != null) fuori.add((inizio, ultimo));
    return fuori;
  }

  /// **I SOLCHI DEI GIORNI PRIMA CHE VALGONO SU QUESTA CARTA**: i loro
  /// tratti sui soli pezzi gia' fatti, prima di quello attivo.
  ///
  /// Visto sul Realme il 20 ottobre 2026, alla quarta discesa del Cavallo: la
  /// testa era gia' scoperta all'arrivo. Le celle vecchie non valevano piu'
  /// ([valide]), ma i solchi vecchi si', e il dito dei giorni scorsi era
  /// passato anche dove oggi c'e' il volto: al quarto pezzo il taglio del
  /// pennello lascia scavare il volto, e i solchi di ieri lo aprivano da
  /// soli. Il pezzo di oggi si apre col dito di oggi.
  List<List<Offset>> solchiValidi(List<List<Offset>> solchi) {
    bool fatto(Offset p) => _pezzoDiOgniCella[cellaSotto(p)] < pezzoAttivo;
    final fuori = <List<Offset>>[];
    for (final s in solchi) {
      if (s.isEmpty) continue;
      if (s.length == 1) {
        if (fatto(s.first)) fuori.add([s.first]);
        continue;
      }
      List<Offset>? corrente;
      for (var k = 1; k < s.length; k++) {
        for (final (da, a) in _trattiDove(s[k - 1], s[k], fatto)) {
          if (corrente == null || (corrente.last - da).distance > 1e-6) {
            corrente = [da];
            fuori.add(corrente);
          }
          if ((a - da).distance > 1e-9) corrente.add(a);
        }
        if (!fatto(s[k])) corrente = null;
      }
    }
    return fuori;
  }

  /// **LA FORMA DEL GRATTABILE** in una carta grande [size], allargata di
  /// [margine] punti oltre i bordi della carta: il pennello del disegno non
  /// passa fuori da qui. Una riga di celle alla volta, a strisce.
  Path regione(Size size, {double margine = 0}) {
    final p = Path();
    final cw = size.width / _colonne;
    final ch = size.height / _righe;
    for (var r = 0; r < _righe; r++) {
      var c = 0;
      while (c < _colonne) {
        if (!grattabile.contains(r * _colonne + c)) {
          c++;
          continue;
        }
        final da = c;
        while (c < _colonne && grattabile.contains(r * _colonne + c)) {
          c++;
        }
        p.addRect(Rect.fromLTRB(
          da == 0 ? -margine : da * cw,
          r == 0 ? -margine : r * ch,
          c == _colonne ? size.width + margine : c * cw,
          r == _righe - 1 ? size.height + margine : (r + 1) * ch,
        ));
      }
    }
    return p;
  }

  /// **QUANTO SI PUO' SCOPRIRE IN UNA DISCESA**: il pezzo intero. I pezzi
  /// non hanno piu' la stessa misura (il volto e' piccolo), quindi la quota
  /// e' quella del pezzo di oggi.
  int get perDiscesa => scostabile.length;

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

  /// **LE CELLE GIA' SCOPERTE CHE VALGONO SU QUESTA CARTA**: quelle dei pezzi
  /// gia' fatti, prima di quello attivo. Un Diario scritto con le fasce
  /// uguali di prima porta celle che adesso stanno nel volto o in un pezzo
  /// dei giorni dopo: aperte, mostrerebbero il volto prima del tempo.
  ///
  /// **E NEMMENO QUELLE DEL PEZZO DI OGGI.** Prima stesura: valevano le
  /// celle fino al pezzo attivo compreso, e sul Realme, alla quarta discesa
  /// del Cavallo, il volto si e' aperto da solo all'arrivo (le celle vecchie
  /// ci stavano sopra) con la scritta "Per oggi hai scostato abbastanza".
  /// Il pezzo di oggi si gratta oggi: si perde soltanto cio' che una discesa
  /// interrotta a meta' aveva gia' scostato, e lo si riscosta.
  Set<int> valide(Set<int> scoperte) => {
        for (final i in scoperte)
          if (i >= 0 &&
              i < _pezzoDiOgniCella.length &&
              _pezzoDiOgniCella[i] < pezzoAttivo)
            i
      };

  /// La distanza di [p] dal segmento da [a] a [b].
  static double _distanza(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final l2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (l2 == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / l2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}
