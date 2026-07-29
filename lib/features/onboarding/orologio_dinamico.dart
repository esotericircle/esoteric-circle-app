import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// Il quadrante della schermata dell'ora, con le lancette che si muovono.
///
/// Prima qui c'era un orizzonte disegnato, bello ma muto: girando i selettori
/// non cambiava nulla, quindi la scelta non aveva un riscontro. Un orologio
/// invece dice sempre, senza parole, quale ora hai scelto.
///
/// Tre cose lo rendono un orologio e non due segmenti che ruotano.
/// 1. La lancetta delle ore avanza IN PROPORZIONE ai minuti, come su un
///    quadrante vero: alle sette e mezza sta fra il sette e l'otto, non
///    ancora sul sette.
/// 2. Va sempre per la strada piu' corta. Da undici a uno gira in avanti di
///    due ore, non indietro di dieci.
/// 3. Cambiando scelta a meta' corsa riparte da dove si trova adesso, non da
///    zero: e' cio' che distingue un movimento da uno scatto.
class OrologioDinamico extends StatefulWidget {
  const OrologioDinamico({
    super.key,
    required this.ora,
    required this.minuto,
    required this.palette,
    this.attivo = true,
    this.reduceMotion = false,
  });

  /// L'ora scelta nei selettori, da 0 a 23.
  final int ora;

  /// Il minuto scelto, da 0 a 59.
  final int minuto;

  final MaestroPalette palette;

  /// Falso quando la persona ha detto di non sapere l'ora: il quadrante resta
  /// visibile ma in penombra, invece di sparire e lasciare un buco.
  final bool attivo;

  final bool reduceMotion;

  /// Quanto dura lo spostamento delle lancette.
  static const Duration corsa = Duration(milliseconds: 700);

  /// L'angolo della lancetta delle ore, in giri (0..1), per un dato orario.
  ///
  /// Il quadrante ha dodici ore, quindi le ore si contano modulo dodici, e i
  /// minuti aggiungono la loro frazione: e' quello che rende l'orologio vero.
  static double giroOre(int ora, int minuto) =>
      ((ora % 12) + minuto / 60.0) / 12.0;

  /// L'angolo della lancetta dei minuti, in giri.
  static double giroMinuti(int minuto) => minuto / 60.0;

  /// Il rappresentante di [bersaglio] piu' vicino a [da], contando che dopo
  /// un giro intero si torna al punto di partenza. Senza, da 11 a 1 la
  /// lancetta tornerebbe indietro attraversando tutto il quadrante.
  static double piuVicino(double bersaglio, double da) {
    var b = bersaglio;
    while (b - da > 0.5) {
      b -= 1;
    }
    while (da - b > 0.5) {
      b += 1;
    }
    return b;
  }

  @override
  State<OrologioDinamico> createState() => _OrologioDinamicoState();
}

class _OrologioDinamicoState extends State<OrologioDinamico>
    with SingleTickerProviderStateMixin {
  late final AnimationController _moto;
  late double _ore;
  late double _minuti;
  double _oreDa = 0;
  double _minutiDa = 0;
  double _oreA = 0;
  double _minutiA = 0;

  @override
  void initState() {
    super.initState();
    _ore = OrologioDinamico.giroOre(widget.ora, widget.minuto);
    _minuti = OrologioDinamico.giroMinuti(widget.minuto);
    _moto = AnimationController(vsync: this, duration: OrologioDinamico.corsa)
      ..addListener(() {
        final k = Curves.easeInOutCubic.transform(_moto.value);
        setState(() {
          _ore = _oreDa + (_oreA - _oreDa) * k;
          _minuti = _minutiDa + (_minutiA - _minutiDa) * k;
        });
      });
  }

  @override
  void didUpdateWidget(covariant OrologioDinamico old) {
    super.didUpdateWidget(old);
    if (old.ora != widget.ora || old.minuto != widget.minuto) _vai();
  }

  void _vai() {
    final ore = OrologioDinamico.piuVicino(
        OrologioDinamico.giroOre(widget.ora, widget.minuto), _ore);
    final minuti = OrologioDinamico.piuVicino(
        OrologioDinamico.giroMinuti(widget.minuto), _minuti);

    if (widget.reduceMotion) {
      setState(() {
        _ore = ore;
        _minuti = minuti;
      });
      return;
    }
    // Si riparte da DOVE SI E' ADESSO, non dal vecchio bersaglio: cambiando
    // scelta a meta' corsa la lancetta prosegue invece di scattare indietro.
    _oreDa = _ore;
    _minutiDa = _minuti;
    _oreA = ore;
    _minutiA = minuti;
    _moto
      ..stop()
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _moto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // 0,55 e non 0,35 quando l'ora e' dichiarata ignota: il quadrante resta
      // leggibile invece di sparire in un grigio indistinto.
      opacity: widget.attivo ? 1 : 0.55,
      child: CustomPaint(
        painter: QuadrantePainter(
          giroOre: _ore,
          giroMinuti: _minuti,
          palette: widget.palette,
        ),
      ),
    );
  }
}

/// Il disegno del quadrante. Pubblico apposta: la posizione della lancetta e'
/// l'unica cosa che un test possa misurare senza guardare i pixel, e leggerla
/// da qui e' piu' onesto che dedurla.
class QuadrantePainter extends CustomPainter {
  QuadrantePainter({
    required this.giroOre,
    required this.giroMinuti,
    required this.palette,
  });

  final double giroOre;
  final double giroMinuti;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 8;
    if (r <= 0) return;

    // Il cerchio del quadrante.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        // Contrasto alzato: a 0,45 il cerchio del quadrante si perdeva nel
        // fondo del cosmo, e l'orologio sembrava un'ombra invece di un
        // riscontro alla scelta appena fatta.
        ..color = palette.gold.withValues(alpha: 0.75),
    );

    // Le dodici tacche: piu' lunghe alle quattro cardinali.
    for (var i = 0; i < 12; i++) {
      final a = -math.pi / 2 + i * math.pi / 6;
      final d = Offset(math.cos(a), math.sin(a));
      final lunga = i % 3 == 0;
      canvas.drawLine(
        c + d * (r - (lunga ? 11 : 6)),
        c + d * (r - 2),
        Paint()
          ..strokeWidth = lunga ? 1.8 : 1.0
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft.withValues(alpha: lunga ? 0.95 : 0.65),
      );
    }

    void lancetta(double giro, double lunghezza, double spessore, double alfa) {
      // Il giro parte dalle dodici e va in senso orario, come un orologio.
      final a = -math.pi / 2 + giro * 2 * math.pi;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c - d * (r * 0.10),
        c + d * lunghezza,
        Paint()
          ..strokeWidth = spessore
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft.withValues(alpha: alfa),
      );
    }

    lancetta(giroOre, r * 0.52, 3.4, 0.95);
    lancetta(giroMinuti, r * 0.78, 2.2, 0.8);

    // Il perno.
    canvas.drawCircle(c, 3.4, Paint()..color = palette.goldSoft);
  }

  @override
  bool shouldRepaint(QuadrantePainter old) =>
      old.giroOre != giroOre || old.giroMinuti != giroMinuti;
}
