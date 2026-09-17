import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../tarot/tarot_card_art.dart';
import '../../design_system/theme/maestro_palette.dart';

/// **IL TAVOLO DEI VENTIDUE.** Ordine DU, 17 settembre 2026, seconda stesura.
///
/// **Perche' non e' il ventaglio della Stesa.** La prima stesura riusava
/// `StesaFan`, l'arco sfogliabile dei settantotto. Il fondatore l'ha bocciato
/// con una ragione che vale piu' del risparmio: *"e' identico alla Stesa dei
/// Tarocchi, voglio qualcosa di originale"*. Gli arcani maggiori sono
/// **ventidue**, cioe' pochi abbastanza da stare tutti a video insieme: non
/// c'e' niente da sfogliare, c'e' un tavolo da guardare.
///
/// **Come entra in scena.** Le carte nascono da un punto solo, si aprono a
/// spirale e si posano nelle righe, una dopo l'altra, lasciando dietro una
/// scia di stelline. Poi **non stanno ferme**: ogni carta respira per conto
/// suo, con una fase diversa dalle altre, cosi' il tavolo resta vivo mentre
/// chi guarda sceglie.
///
/// **Le righe.** Ventidue carte leggermente sovrapposte: **tre righe da otto,
/// sette e sette** sul telefono, dove servono carte grandi abbastanza da
/// toccarle; **due righe da undici** dove lo schermo e' largo. Il conto non e'
/// scritto a mano: viene da [righeDi], che si legge e si prova.
///
/// **Mischia e taglia non cambiano l'esito, e va detto.** I ventidue dorsi
/// sono lo stesso disegno e la carta si estrae dal caso sicuro **nel momento
/// del tocco**: mescolare o tagliare muove le figure sul tavolo, non il
/// risultato. Restano perche' sono il gesto che una persona fa con un mazzo
/// vero, e perche' aiutano ad aspettare un istante prima di scegliere.
class TavoloDeiVentidue extends StatefulWidget {
  const TavoloDeiVentidue({
    super.key,
    required this.palette,
    required this.onScegli,
    required this.rivelazione,
    required this.faccia,
    this.scelta,
    this.ridotto = false,
    this.quante = 22,
  });

  final MaestroPalette palette;

  /// Il dorso toccato. **Quale sia non decide niente**: lo dice la voce DU.07.
  final ValueChanged<int> onScegli;

  /// Da zero a uno: la carta scelta che sale al centro e si gira.
  final Animation<double> rivelazione;

  /// La faccia da mostrare dopo il mezzo giro, costruita da chi ci chiama.
  final WidgetBuilder faccia;

  /// L'indice della carta scelta, quando la scelta c'e' stata.
  final int? scelta;

  /// Con Riduci Movimento il tavolo si posa fermo: niente spirale, niente
  /// respiro, niente scia.
  final bool ridotto;

  final int quante;

  /// **COME SI DIVIDONO IN RIGHE, dato lo spazio.** Due righe da undici dove
  /// c'e' larghezza, tre righe da otto, sette e sette dove non ce n'e'.
  static List<int> righeDi(int quante, double larghezza) {
    if (larghezza >= 420) {
      final prima = (quante / 2).ceil();
      return [prima, quante - prima];
    }
    final base = quante ~/ 3;
    final resto = quante % 3;
    return [
      for (var r = 0; r < 3; r++) base + (r < resto ? 1 : 0),
    ];
  }

  @override
  State<TavoloDeiVentidue> createState() => _TavoloDeiVentidueState();
}

class _TavoloDeiVentidueState extends State<TavoloDeiVentidue>
    with TickerProviderStateMixin {
  /// L'ingresso a spirale, una volta sola.
  late final AnimationController _ingresso;

  /// Il respiro del tavolo: gira per sempre, piano.
  late final AnimationController _respiro;

  /// I due gesti del mazzo, che muovono le figure e non l'esito.
  late final AnimationController _mischia;
  late final AnimationController _taglio;

  /// Dove sta ogni carta sul tavolo: la posizione nella griglia. Mischiare
  /// rimescola questo, e siccome i dorsi sono uguali cambia la scena, non la
  /// sorte.
  late List<int> _posti = [for (var i = 0; i < widget.quante; i++) i];

  static const Duration _durataIngresso = Duration(milliseconds: 1500);
  static const Duration _durataRespiro = Duration(seconds: 7);
  static const Duration _durataMischia = Duration(milliseconds: 1100);
  static const Duration _durataTaglio = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _ingresso = AnimationController(vsync: this, duration: _durataIngresso);
    _respiro = AnimationController(vsync: this, duration: _durataRespiro);
    _mischia = AnimationController(vsync: this, duration: _durataMischia);
    _taglio = AnimationController(vsync: this, duration: _durataTaglio);
    if (widget.ridotto) {
      _ingresso.value = 1;
    } else {
      _ingresso.forward();
      _respiro.repeat();
    }
  }

  @override
  void dispose() {
    _ingresso.dispose();
    _respiro.dispose();
    _mischia.dispose();
    _taglio.dispose();
    super.dispose();
  }

  bool get _sceglibile => widget.scelta == null;

  /// **CHI TOCCA MENTRE LE CARTE ENTRANO NON ASPETTA.** L'ingresso si chiude
  /// subito: nessuno deve guardare un'animazione che non ha chiesto.
  void _saltaLIngresso() {
    if (_ingresso.isCompleted) return;
    _ingresso.value = 1;
  }

  Future<void> _mescola() async {
    if (!_sceglibile || _mischia.isAnimating || _taglio.isAnimating) return;
    _saltaLIngresso();
    if (widget.ridotto) {
      setState(() => _posti = _mescolati());
      return;
    }
    await _mischia.forward(from: 0);
    if (!mounted) return;
    setState(() => _posti = _mescolati());
    _mischia.value = 0;
  }

  Future<void> _taglia() async {
    if (!_sceglibile || _mischia.isAnimating || _taglio.isAnimating) return;
    _saltaLIngresso();
    if (widget.ridotto) {
      setState(() => _posti = _tagliati());
      return;
    }
    await _taglio.forward(from: 0);
    if (!mounted) return;
    setState(() => _posti = _tagliati());
    _taglio.value = 0;
  }

  List<int> _mescolati() {
    final caso = math.Random();
    final lista = [..._posti];
    for (var i = lista.length - 1; i > 0; i--) {
      final j = caso.nextInt(i + 1);
      final t = lista[i];
      lista[i] = lista[j];
      lista[j] = t;
    }
    return lista;
  }

  /// Il taglio vero: il mazzo si divide in due e la meta' di sotto passa
  /// sopra.
  List<int> _tagliati() {
    final meta = _posti.length ~/ 2;
    return [..._posti.sublist(meta), ..._posti.sublist(0, meta)];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, spazio) {
        final larghezza = spazio.maxWidth;
        final righe = TavoloDeiVentidue.righeDi(widget.quante, larghezza);
        final disegno = _DisegnoDelTavolo(
          righe: righe,
          larghezza: larghezza,
          quante: widget.quante,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **LA LARGHEZZA VA DICHIARATA.** Con la sola altezza, la pila
            // delle carte non aveva niente che la tenesse larga e si
            // stringeva al centro: le carte finivano tutte spostate a destra
            // di mezza schermata. Visto sulla sonda, non dedotto.
            SizedBox(
              width: larghezza,
              height: disegno.altezza + _Stelline.alone,
              child: _tavolo(disegno),
            ),
            const SizedBox(height: 6),
            _ComandiDelMazzo(
              palette: widget.palette,
              attivi: _sceglibile,
              onMischia: _mescola,
              onTaglia: _taglia,
            ),
          ],
        );
      },
    );
  }

  Widget _tavolo(_DisegnoDelTavolo disegno) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapDown: (_) => _saltaLIngresso(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ingresso,
          _respiro,
          _mischia,
          _taglio,
          widget.rivelazione,
        ]),
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            // Le stelline del tavolo, dietro le carte.
            Positioned.fill(
              child: CustomPaint(
                painter: _Stelline(
                  t: _respiro.value,
                  palette: widget.palette,
                  scia: _sciaDellaScelta(disegno),
                  acceso: !widget.ridotto,
                ),
              ),
            ),
            for (var posto = 0; posto < widget.quante; posto++)
              _carta(disegno, posto),
            if (widget.scelta != null) _cartaScelta(disegno),
          ],
        ),
      ),
    );
  }

  /// La scia di stelline dietro la carta che sale: i punti dove e' passata.
  List<Offset> _sciaDellaScelta(_DisegnoDelTavolo disegno) {
    if (widget.scelta == null || widget.ridotto) return const [];
    final t = widget.rivelazione.value;
    if (t <= 0 || t >= 0.92) return const [];
    return [
      for (var k = 1; k <= 7; k++)
        if (t - k * 0.035 > 0) _puntoDelVolo(disegno, t - k * 0.035),
    ];
  }

  /// Dove si trova il centro della carta scelta al tempo [t] del volo.
  Offset _puntoDelVolo(_DisegnoDelTavolo disegno, double t) {
    final partenza = disegno.centroDi(_postoDi(widget.scelta!));
    final arrivo = disegno.centroDelTavolo;
    final avanti = Curves.easeOutCubic.transform((t / 0.45).clamp(0.0, 1.0));
    return Offset.lerp(partenza, arrivo, avanti)!;
  }

  /// In che posto della griglia sta la carta [carta] adesso.
  int _postoDi(int carta) {
    final posto = _posti.indexOf(carta);
    return posto < 0 ? carta : posto;
  }

  Widget _carta(_DisegnoDelTavolo disegno, int posto) {
    final carta = _posti[posto];
    final scelta = widget.scelta;
    // La carta scelta esce dalla griglia: la disegna _cartaScelta.
    if (scelta != null && carta == scelta) return const SizedBox.shrink();

    var centro = disegno.centroDi(posto);
    var scala = 1.0;
    var angolo = 0.0;
    var opacita = 1.0;

    if (!widget.ridotto) {
      // **L'INGRESSO A SPIRALE**, una carta dopo l'altra.
      final ritardo = posto / widget.quante * 0.45;
      final avanti = ((_ingresso.value - ritardo) / (1 - 0.45)).clamp(0.0, 1.0);
      if (avanti < 1) {
        final curva = Curves.easeOutBack.transform(avanti);
        final giro = (1 - curva) * math.pi * 1.2;
        final raggio = (1 - curva) * disegno.larghezza * 0.42;
        centro = Offset(
          centro.dx + math.cos(giro + posto) * raggio,
          centro.dy + math.sin(giro + posto) * raggio * 0.5 - (1 - curva) * 40,
        );
        scala = 0.35 + 0.65 * curva;
        angolo = (1 - curva) * math.pi * 0.8;
        opacita = avanti.clamp(0.0, 1.0);
      } else {
        // **IL RESPIRO DEL TAVOLO**: ogni carta con la sua fase.
        final fase = posto * 0.37;
        final onda = math.sin((_respiro.value + fase) * 2 * math.pi);
        centro = Offset(centro.dx, centro.dy + onda * 3.2);
        angolo = math.sin((_respiro.value * 1.3 + fase) * 2 * math.pi) * 0.022;
        scala = 1 + onda * 0.008;
      }

      // Il mescolamento: le carte si raccolgono in cerchio e tornano.
      if (_mischia.value > 0) {
        final onda = math.sin(_mischia.value * math.pi);
        final giro = posto / widget.quante * 2 * math.pi + _mischia.value * 4;
        final raggio = disegno.larghezza * 0.3 * onda;
        centro = Offset(
          centro.dx + math.cos(giro) * raggio,
          centro.dy + math.sin(giro) * raggio * 0.45,
        );
        angolo += onda * 0.5;
      }

      // Il taglio: le due meta' si scostano e si scambiano di quota.
      if (_taglio.value > 0) {
        final onda = math.sin(_taglio.value * math.pi);
        final sopra = posto < widget.quante / 2;
        centro = Offset(
          centro.dx + (sopra ? 1 : -1) * disegno.larghezza * 0.22 * onda,
          centro.dy + (sopra ? -1 : 1) * 26 * onda,
        );
      }
    }

    // Quando una carta e' stata scelta, le altre si spengono piano e
    // lasciano la scena a lei.
    if (widget.scelta != null) {
      opacita *= (1 - (widget.rivelazione.value / 0.3)).clamp(0.0, 1.0);
    }

    return _posata(
      disegno: disegno,
      centro: centro,
      scala: scala,
      angolo: angolo,
      opacita: opacita,
      figlio: _Dorso(
        indice: carta,
        attivo: _sceglibile,
        onTap: () => widget.onScegli(carta),
      ),
    );
  }

  /// La carta scelta: sale al centro, cresce e si gira. **La faccia compare
  /// solo dopo il mezzo giro**, cosi' il verso non si sa mai in anticipo.
  Widget _cartaScelta(_DisegnoDelTavolo disegno) {
    final t = widget.rivelazione.value;
    final centro = _puntoDelVolo(disegno, t);
    final salita = Curves.easeOutCubic.transform((t / 0.45).clamp(0.0, 1.0));
    final giro = Curves.easeInOut.transform(((t - 0.35) / 0.5).clamp(0.0, 1.0));
    final scala = 1 + (disegno.scalaDellaRivelazione - 1) * salita;
    final mostraLaFaccia = giro >= 0.5;
    return _posata(
      disegno: disegno,
      centro: centro,
      scala: scala,
      angolo: 0,
      opacita: 1,
      trasforma: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(giro * math.pi),
      figlio: mostraLaFaccia
          ? Transform(
              alignment: Alignment.center,
              // La faccia si rimette dritta: senza, dopo il mezzo giro si
              // vedrebbe specchiata.
              transform: Matrix4.identity()..rotateY(math.pi),
              child: Builder(builder: widget.faccia),
            )
          : _Dorso(indice: widget.scelta!, attivo: false, onTap: () {}),
    );
  }

  Widget _posata({
    required _DisegnoDelTavolo disegno,
    required Offset centro,
    required double scala,
    required double angolo,
    required double opacita,
    required Widget figlio,
    Matrix4? trasforma,
  }) {
    final w = disegno.larghezzaCarta;
    final h = disegno.altezzaCarta;
    Widget corpo = SizedBox(width: w, height: h, child: figlio);
    if (trasforma != null) {
      corpo = Transform(
          alignment: Alignment.center, transform: trasforma, child: corpo);
    }
    return Positioned(
      left: centro.dx - w / 2,
      top: centro.dy - h / 2,
      width: w,
      height: h,
      child: Opacity(
        opacity: opacita.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: angolo,
          child: Transform.scale(scale: scala, child: corpo),
        ),
      ),
    );
  }
}

/// La geometria del tavolo: quante righe, quanto sono grandi le carte, dove
/// sta ognuna. Sta a parte perche' e' cio' che le prove misurano.
class _DisegnoDelTavolo {
  _DisegnoDelTavolo({
    required this.righe,
    required this.larghezza,
    required this.quante,
  });

  final List<int> righe;
  final double larghezza;
  final int quante;

  /// Quanto una carta copre quella accanto: **leggermente sovrapposte**.
  static const double sovrapposizione = 0.74;

  static const double _margine = 6;
  static const double _passoVerticale = 0.96;

  double get larghezzaCarta {
    final perRiga = righe.reduce(math.max);
    final utile = larghezza - _margine * 2;
    return utile / (1 + (perRiga - 1) * sovrapposizione);
  }

  double get altezzaCarta => larghezzaCarta / TarotFrame.aspect;

  double get altezza =>
      altezzaCarta * (1 + (righe.length - 1) * _passoVerticale) + 16;

  Offset get centroDelTavolo => Offset(larghezza / 2, altezza / 2);

  /// Quanto cresce la carta quando sale al centro.
  double get scalaDellaRivelazione =>
      math.min(2.6, (larghezza * 0.62) / larghezzaCarta);

  /// Il centro della casella [posto], contate riga per riga.
  Offset centroDi(int posto) {
    var scorso = 0;
    for (var r = 0; r < righe.length; r++) {
      if (posto < scorso + righe[r]) {
        final j = posto - scorso;
        final n = righe[r];
        final passo = larghezzaCarta * sovrapposizione;
        final largaRiga = larghezzaCarta + (n - 1) * passo;
        final sinistra = (larghezza - largaRiga) / 2;
        return Offset(
          sinistra + j * passo + larghezzaCarta / 2,
          8 + altezzaCarta * (0.5 + r * _passoVerticale),
        );
      }
      scorso += righe[r];
    }
    return centroDelTavolo;
  }
}

/// Un dorso del mazzo. **Sono tutti lo stesso disegno**, e il dorso e'
/// simmetrico al mezzo giro: una carta coperta non puo' dire il verso.
class _Dorso extends StatelessWidget {
  const _Dorso({
    required this.indice,
    required this.attivo,
    required this.onTap,
  });

  final int indice;
  final bool attivo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final immagine = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        TarotDeck.dorsoFull,
        key: Key('arcano_alba_dorso_$indice'),
        fit: BoxFit.cover,
      ),
    );
    if (!attivo) return immagine;
    return GestureDetector(
      key: Key('arcano_alba_carta_$indice'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: immagine,
    );
  }
}

/// **LE STELLINE**: il pulviscolo del tavolo e la scia della carta che sale.
class _Stelline extends CustomPainter {
  _Stelline({
    required this.t,
    required this.palette,
    required this.scia,
    required this.acceso,
  });

  final double t;
  final MaestroPalette palette;

  /// I punti dove la carta scelta e' passata poco fa.
  final List<Offset> scia;
  final bool acceso;

  /// Quanto spazio lasciano le stelline oltre le carte.
  static const double alone = 18;

  static const int quante = 46;

  @override
  void paint(Canvas canvas, Size size) {
    final caso = math.Random(7);
    final pennello = Paint()..style = PaintingStyle.fill;
    if (acceso) {
      for (var i = 0; i < quante; i++) {
        final x = caso.nextDouble() * size.width;
        final y = caso.nextDouble() * size.height;
        final fase = caso.nextDouble();
        final battito =
            (math.sin((t + fase) * 2 * math.pi) + 1) / 2; // da zero a uno
        final raggio = 0.7 + battito * 1.6;
        pennello.color =
            palette.goldSoft.withValues(alpha: 0.10 + battito * 0.35);
        _stella(canvas, Offset(x, y), raggio, pennello);
      }
    }
    for (var i = 0; i < scia.length; i++) {
      final quanto = 1 - i / scia.length;
      final punto = scia[i];
      for (var k = 0; k < 3; k++) {
        final sparso = Offset(
          punto.dx + (caso.nextDouble() - 0.5) * 26,
          punto.dy + (caso.nextDouble() - 0.5) * 26,
        );
        pennello.color = palette.gold.withValues(alpha: 0.55 * quanto);
        _stella(canvas, sparso, 1.2 + 2.2 * quanto, pennello);
      }
    }
  }

  /// Una stellina a quattro punte, non un cerchio.
  void _stella(Canvas canvas, Offset centro, double raggio, Paint pennello) {
    final strada = Path();
    final piccolo = raggio * 0.32;
    strada.moveTo(centro.dx, centro.dy - raggio);
    strada.quadraticBezierTo(centro.dx + piccolo, centro.dy - piccolo,
        centro.dx + raggio, centro.dy);
    strada.quadraticBezierTo(centro.dx + piccolo, centro.dy + piccolo,
        centro.dx, centro.dy + raggio);
    strada.quadraticBezierTo(centro.dx - piccolo, centro.dy + piccolo,
        centro.dx - raggio, centro.dy);
    strada.quadraticBezierTo(centro.dx - piccolo, centro.dy - piccolo,
        centro.dx, centro.dy - raggio);
    canvas.drawPath(strada, pennello);
  }

  @override
  bool shouldRepaint(_Stelline vecchio) =>
      vecchio.t != t || vecchio.scia != scia || vecchio.acceso != acceso;
}

/// I due gesti del mazzo. **Non cambiano l'esito**, e il commento della
/// classe lo dice per esteso.
class _ComandiDelMazzo extends StatelessWidget {
  const _ComandiDelMazzo({
    required this.palette,
    required this.attivi,
    required this.onMischia,
    required this.onTaglia,
  });

  final MaestroPalette palette;
  final bool attivi;
  final VoidCallback onMischia;
  final VoidCallback onTaglia;

  @override
  Widget build(BuildContext context) {
    if (!attivi) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Gesto(
            chiave: 'arcano_alba_mischia',
            testo: 'Mischia',
            icona: Icons.shuffle_rounded,
            palette: palette,
            onTap: onMischia),
        const SizedBox(width: 18),
        _Gesto(
            chiave: 'arcano_alba_taglia',
            testo: 'Taglia',
            icona: Icons.content_cut_rounded,
            palette: palette,
            onTap: onTaglia),
      ],
    );
  }
}

class _Gesto extends StatelessWidget {
  const _Gesto({
    required this.chiave,
    required this.testo,
    required this.icona,
    required this.palette,
    required this.onTap,
  });

  final String chiave;
  final String testo;
  final IconData icona;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: Key(chiave),
      onPressed: onTap,
      icon: Icon(icona, size: 18, color: palette.goldSoft),
      label:
          Text(testo, style: TextStyle(color: palette.goldSoft, fontSize: 16)),
      style: TextButton.styleFrom(
        // L'area di tocco resta comoda anche con l'etichetta corta.
        minimumSize: const Size(96, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
