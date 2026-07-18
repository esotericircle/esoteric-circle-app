import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/horoscope/horoscope.dart';
import '../../design_system/theme/maestro_palette.dart';

/// Una forma viva per ogni dominio, diversa dalle altre, che rende il valore
/// deterministico da due a cinque senza ripetere la stessa grafica (regola 21
/// delle Linee Guida UX). Il valore resta il dato interno; qui cambia solo la
/// resa: energia ad anello, affinita' a orbite, spinta a scia di stelle, sorte a
/// quadrifoglio.
class DomainVisual extends StatefulWidget {
  const DomainVisual({
    super.key,
    required this.domain,
    required this.value,
    required this.palette,
    required this.pulse,
    this.size = 46,
    this.animateFill = true,
  });

  final HoroscopeDomain domain;

  /// Il valore deterministico da 2 a 5.
  final int value;
  final MaestroPalette palette;

  /// Pulsazione lenta condivisa (0..1), per il respiro delle forme.
  final Animation<double> pulse;
  final double size;

  /// Se falso la forma parte gia' piena (per la card statica).
  final bool animateFill;

  @override
  State<DomainVisual> createState() => _DomainVisualState();
}

class _DomainVisualState extends State<DomainVisual> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        // Micro-animazione di riempimento all'apertura.
        key: ValueKey(widget.value),
        tween: Tween(begin: widget.animateFill ? 0.0 : 1.0, end: 1.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, fill, _) {
          return AnimatedBuilder(
            animation: widget.pulse,
            builder: (context, __) => CustomPaint(
              painter: _painterFor(
                  widget.domain, widget.value, fill, widget.pulse.value,
                  widget.palette),
            ),
          );
        },
      ),
    );
  }
}

CustomPainter _painterFor(HoroscopeDomain domain, int value, double fill,
    double pulse, MaestroPalette palette) {
  switch (domain) {
    case HoroscopeDomain.generale:
      return _AuraPainter(value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.amore:
      return _OrbitsPainter(value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.carriera:
      return _TrailPainter(value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.fortuna:
      return _BloomPainter(value: value, fill: fill, pulse: pulse, palette: palette);
  }
}

abstract class _VisualPainter extends CustomPainter {
  _VisualPainter(
      {required this.value,
      required this.fill,
      required this.pulse,
      required this.palette});

  final int value;
  final double fill;
  final double pulse;
  final MaestroPalette palette;

  double get ratio => (value / Horoscope.indicatorMax).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(_VisualPainter old) =>
      old.value != value ||
      old.fill != fill ||
      old.pulse != pulse ||
      old.palette != palette;
}

/// Generale, energia: un anello che si riempie fino al valore e pulsa piano.
class _AuraPainter extends _VisualPainter {
  _AuraPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.36;
    final breathe = 0.85 + 0.15 * math.sin(pulse * 2 * math.pi);

    // Alone che respira.
    canvas.drawCircle(
      c,
      r * (1.2 + 0.15 * breathe),
      Paint()
        ..color = palette.goldSoft.withValues(alpha: 0.18 * breathe)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Traccia di fondo.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.08
        ..color = palette.gold.withValues(alpha: 0.22),
    );
    // Arco che si riempie fino al valore.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * ratio * fill,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.08
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [palette.gold, palette.goldSoft, palette.gold],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Nucleo caldo.
    canvas.drawCircle(
        c,
        r * 0.32 * breathe,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.5 + 0.3 * ratio));
  }
}

/// Amore, affinita': due orbite che si incrociano, con un nodo a cuore che si
/// accende in proporzione al valore.
class _OrbitsPainter extends _VisualPainter {
  _OrbitsPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rx = size.width * 0.36;
    final ry = size.height * 0.2;
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.05
      ..color = palette.gold.withValues(alpha: 0.5);

    for (final sign in const [1.0, -1.0]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(sign * math.pi / 5);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
          orbit);
      canvas.restore();
    }

    // Nodo a cuore al centro, acceso in proporzione al valore.
    final beat = 0.9 + 0.1 * math.sin(pulse * 2 * math.pi);
    final scale = fill * beat * (0.7 + 0.3 * ratio);
    final heartAlpha = (0.35 + 0.65 * ratio).clamp(0.0, 1.0);
    final hs = size.shortestSide * 0.22 * scale;
    final path = Path()
      ..moveTo(c.dx, c.dy + hs * 0.9)
      ..cubicTo(c.dx - hs * 1.4, c.dy - hs * 0.2, c.dx - hs * 0.5,
          c.dy - hs * 1.1, c.dx, c.dy - hs * 0.35)
      ..cubicTo(c.dx + hs * 0.5, c.dy - hs * 1.1, c.dx + hs * 1.4,
          c.dy - hs * 0.2, c.dx, c.dy + hs * 0.9)
      ..close();
    canvas.drawPath(
        path, Paint()..color = palette.goldSoft.withValues(alpha: heartAlpha));
  }
}

/// Carriera, spinta: una scia di stelle che sale, il numero di stelle accese
/// segue il valore.
class _TrailPainter extends _VisualPainter {
  _TrailPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    const total = Horoscope.indicatorMax;
    for (var i = 0; i < total; i++) {
      final t = i / (total - 1);
      // Dal basso-sinistra all'alto-destra.
      final pos = Offset(
        size.width * (0.2 + 0.6 * t),
        size.height * (0.82 - 0.64 * t),
      );
      final lit = i < value;
      // Comparsa progressiva con il riempimento, ma le stelle accese hanno un
      // minimo di presenza: non spariscono mai del tutto, cosi' il valore si
      // legge anche a riposo.
      final appear = ((fill * total) - i).clamp(0.0, 1.0);
      final twinkle = 0.85 + 0.15 * math.sin(pulse * 2 * math.pi + i);
      final r =
          size.shortestSide * (lit ? 0.11 : 0.07) * (0.7 + 0.3 * appear);
      final color = lit
          ? palette.goldSoft.withValues(alpha: (0.45 + 0.55 * appear) * twinkle)
          : palette.gold.withValues(alpha: 0.18);
      _star(canvas, pos, r, color);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var k = 0; k < 5; k++) {
      final ao = -math.pi / 2 + k * 2 * math.pi / 5;
      final ai = ao + math.pi / 5;
      final outer = c + Offset(math.cos(ao), math.sin(ao)) * r;
      final inner = c + Offset(math.cos(ai), math.sin(ai)) * r * 0.45;
      if (k == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

/// Fortuna, sorte: un quadrifoglio che sboccia e ruota dolcemente, l'intensita'
/// segue il valore.
class _BloomPainter extends _VisualPainter {
  _BloomPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.2 * (0.5 + 0.5 * fill);
    final rot = pulse * 2 * math.pi * 0.15; // rotazione lenta
    final alpha = (0.4 + 0.6 * ratio).clamp(0.0, 1.0);
    final paint = Paint()..color = palette.goldSoft.withValues(alpha: alpha);

    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4 + rot;
      final petal = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(petal, r * 1.05, paint);
    }
    // Cuore del fiore.
    canvas.drawCircle(
        c, r * 0.5, Paint()..color = palette.gold.withValues(alpha: alpha));
    // Stelo.
    canvas.drawLine(
      c + Offset(0, r * 0.4),
      c + Offset(0, size.height * 0.4),
      Paint()
        ..color = palette.gold.withValues(alpha: alpha * 0.8)
        ..strokeWidth = size.shortestSide * 0.05
        ..strokeCap = StrokeCap.round,
    );
  }
}
