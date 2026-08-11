import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';

/// Un punto della figura da unire: il nome (anatomico o del disegno) e la
/// posizione normalizzata 0..1 sulla tela della figura.
@immutable
class PuntoDaUnire {
  const PuntoDaUnire(this.nome, this.punto);

  final String nome;
  final Offset punto;
}

/// La figura da unire: i punti NELL'ORDINE del tocco e i fili da accendere.
@immutable
class FiguraDaUnire {
  const FiguraDaUnire({required this.punti, required this.fili});

  /// I punti nell'ordine in cui vanno toccati.
  final List<PuntoDaUnire> punti;

  /// I fili fra i punti, per indice: un filo si accende quando i suoi due
  /// capi sono stati toccati.
  final List<(int, int)> fili;
}

/// UNISCI LE STELLE E NASCE LA FIGURA, ordine L voce 3: il componente UNICO.
///
/// Lo usano il Rito del Sogno e la rivelazione dell'Animale Guida: due modi
/// diversi di fare la stessa cosa sono un difetto, non due funzioni.
///
/// **LE STELLE SI VEDONO.** Sono grandi, pulsano UNA ALLA VOLTA nell'ordine
/// in cui vanno toccate, e quella che aspetta il tocco e' l'unica accesa fra
/// le non unite: chi guarda non deve indovinare dove toccare. Toccata, resta
/// accesa e si accende la successiva. Le stelle che verranno dopo restano
/// puntini appena percepibili.
///
/// **Con Riduci Movimento** la pulsazione diventa uno stato acceso e fermo, e
/// nessuna informazione dipende dal moto.
class StelleDaUnire extends StatefulWidget {
  const StelleDaUnire({
    super.key,
    required this.figura,
    required this.palette,
    required this.mappa,
    this.keyPrefix = 'stella',
    this.onTocco,
    this.onCompleta,
    this.raggioTocco = 26,
    this.spostamento = Offset.zero,
  });

  final FiguraDaUnire figura;
  final MaestroPalette palette;

  /// Da coordinate normalizzate 0..1 alle coordinate locali del riquadro:
  /// ogni scena ha la sua fascia e la sua parallasse, e le porta da qui.
  final Offset Function(Offset normalizzato) mappa;

  /// Il prefisso delle chiavi delle zone toccabili: '<prefix>_<indice>'.
  final String keyPrefix;

  final void Function(int indice)? onTocco;
  final VoidCallback? onCompleta;

  /// Il raggio della zona toccabile, piu' largo della stella disegnata.
  final double raggioTocco;

  /// La parallasse della scena, gia' dentro [mappa]: qui serve solo perche'
  /// il painter sappia di dover ridipingere quando la vista si sposta.
  final Offset spostamento;

  /// QUANTO DEVE SPICCARE la stella che chiama il tocco: il suo bagliore vale
  /// almeno questo multiplo delle stelle spente. La prova a pixel lo misura.
  static const double kRisaltoMinimo = 2.0;

  @override
  State<StelleDaUnire> createState() => StelleDaUnireState();
}

/// PUBBLICO perche' le scene chiedono a che punto e' la figura (per i testi
/// di invito) e le prove leggono lo stato senza simulare pixel.
class StelleDaUnireState extends State<StelleDaUnire>
    with TickerProviderStateMixin {
  late final AnimationController _pulsa = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  late final AnimationController _lampo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  final List<int> _accese = [];

  bool _avviato = false;
  bool _riduciMovimento = false;

  /// Quante stelle sono gia' unite.
  int get unite => _accese.length;

  /// Vero quando la figura e' completa.
  bool get completa => _accese.length >= widget.figura.punti.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    if (_avviato) return;
    _avviato = true;
    if (_riduciMovimento) {
      // La pulsazione diventa uno stato acceso e fermo.
      _pulsa.value = 1.0;
    } else {
      _pulsa.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulsa.dispose();
    _lampo.dispose();
    super.dispose();
  }

  void _tocca(int indice) {
    if (completa) return;
    if (indice != _accese.length) return; // si uniscono in sequenza
    setState(() => _accese.add(indice));
    if (!_riduciMovimento) _lampo.forward(from: 0);
    widget.onTocco?.call(indice);
    if (completa) widget.onCompleta?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulsa, _lampo]),
              builder: (context, _) => CustomPaint(
                painter: _StelleDaUnirePainter(
                  figura: widget.figura,
                  palette: widget.palette,
                  mappa: widget.mappa,
                  accese: _accese,
                  completa: completa,
                  pulsa: _riduciMovimento ? 1.0 : _pulsa.value,
                  lampo: _lampo.isAnimating ? _lampo.value : -1,
                  spostamento: widget.spostamento,
                ),
              ),
            ),
          ),
        ),
        // Le zone toccabili, una per stella, sopra il disegno.
        for (var i = 0; i < widget.figura.punti.length; i++)
          _zona(i),
      ],
    );
  }

  Widget _zona(int i) {
    final p = widget.mappa(widget.figura.punti[i].punto);
    return Positioned(
      left: p.dx - widget.raggioTocco,
      top: p.dy - widget.raggioTocco,
      child: GestureDetector(
        key: Key('${widget.keyPrefix}_$i'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tocca(i),
        child: SizedBox(
            width: widget.raggioTocco * 2, height: widget.raggioTocco * 2),
      ),
    );
  }
}

class _StelleDaUnirePainter extends CustomPainter {
  _StelleDaUnirePainter({
    required this.figura,
    required this.palette,
    required this.mappa,
    required this.accese,
    required this.completa,
    required this.pulsa,
    required this.lampo,
    required this.spostamento,
  });

  final FiguraDaUnire figura;
  final MaestroPalette palette;
  final Offset Function(Offset) mappa;
  final List<int> accese;
  final bool completa;
  final double pulsa;
  final double lampo;
  final Offset spostamento;

  @override
  void paint(Canvas canvas, Size size) {
    final respiro =
        completa ? 0.75 + 0.25 * math.sin(pulsa * math.pi * 2) : 1.0;

    // I FILI: alone morbido piu' cuore luminoso, fusi e non tratti uniformi.
    final aloneFilo = Paint()
      ..style = PaintingStyle.fill
      ..color = palette.gold.withValues(alpha: 0.20 * respiro)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final cuoreFilo = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF0C4).withValues(alpha: 0.92 * respiro);
    final pienoFilo = completa ? 1.35 : 1.05;
    for (final (a, b) in figura.fili) {
      if (!accese.contains(a) || !accese.contains(b)) continue;
      final pa = mappa(figura.punti[a].punto);
      final pb = mappa(figura.punti[b].punto);
      canvas.drawPath(_fuso(pa, pb, 1.1, 3.4), aloneFilo);
      canvas.drawPath(_fuso(pa, pb, 0.3, pienoFilo), cuoreFilo);
    }

    // LE STELLE, grandi e leggibili.
    for (var i = 0; i < figura.punti.length; i++) {
      final p = mappa(figura.punti[i].punto);
      if (accese.contains(i)) {
        // Unita: accesa e ferma. L'ultima unita porta il lampo del tocco.
        final ultima = accese.isNotEmpty && accese.last == i;
        final onda = ultima && lampo >= 0 ? lampo : -1.0;
        canvas.drawCircle(
            p,
            11,
            Paint()
              ..color = palette.gold.withValues(alpha: 0.45)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        canvas.drawCircle(
            p, 5.2, Paint()..color = const Color(0xFFFFF6D8));
        if (onda >= 0) {
          canvas.drawCircle(
              p,
              8 + 22 * onda,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2 * (1 - onda)
                ..color =
                    palette.goldSoft.withValues(alpha: 0.7 * (1 - onda)));
        }
      } else if (i == accese.length && !completa) {
        // LA STELLA CHE CHIAMA IL TOCCO: l'unica accesa fra le non unite.
        // Pulsa; con Riduci Movimento resta accesa piena e ferma.
        final battito = 0.55 + 0.45 * pulsa;
        canvas.drawCircle(
            p,
            16 + 6 * pulsa,
            Paint()
              ..color = palette.goldSoft.withValues(alpha: 0.38 * battito)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
        canvas.drawCircle(
            p,
            7.5,
            Paint()..color = const Color(0xFFFFFBEA));
        canvas.drawCircle(
            p,
            11.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = palette.goldSoft.withValues(alpha: 0.85 * battito));
      } else {
        // In attesa del proprio turno: un puntino appena percepibile, cosi'
        // la scena non e' un cielo di bersagli tutti uguali.
        canvas.drawCircle(
            p, 2.2, Paint()..color = Colors.white.withValues(alpha: 0.22));
      }
    }
  }

  /// Un tratto a fuso: sottile ai capi, appena piu' pieno al centro.
  Path _fuso(Offset a, Offset b, double vitaAiCapi, double vitaAlCentro) {
    final dir = b - a;
    final len = dir.distance;
    if (len < 0.001) return Path();
    final n = Offset(-dir.dy, dir.dx) / len;
    final m = Offset.lerp(a, b, 0.5)!;
    return Path()
      ..moveTo(a.dx + n.dx * vitaAiCapi, a.dy + n.dy * vitaAiCapi)
      ..quadraticBezierTo(
          m.dx + n.dx * vitaAlCentro, m.dy + n.dy * vitaAlCentro,
          b.dx + n.dx * vitaAiCapi, b.dy + n.dy * vitaAiCapi)
      ..lineTo(b.dx - n.dx * vitaAiCapi, b.dy - n.dy * vitaAiCapi)
      ..quadraticBezierTo(
          m.dx - n.dx * vitaAlCentro, m.dy - n.dy * vitaAlCentro,
          a.dx - n.dx * vitaAiCapi, a.dy - n.dy * vitaAiCapi)
      ..close();
  }

  @override
  bool shouldRepaint(_StelleDaUnirePainter old) =>
      old.accese.length != accese.length ||
      old.pulsa != pulsa ||
      old.lampo != lampo ||
      old.completa != completa ||
      old.spostamento != spostamento;
}
