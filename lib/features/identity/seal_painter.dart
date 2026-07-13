import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/identity/circle_seal.dart';

/// Disegna il Sigillo del Cerchio in modo procedurale e deterministico.
///
/// Ruota dello zodiaco a dodici raggi con il segno solare acceso, una corona di
/// tacche pari al Numero della vita, una geometria sacra a simmetria derivata
/// dallo stesso numero, e la cifra al centro. Tutto nel colore dell'elemento
/// piu' l'oro. Il parametro [progress] compone il sigillo, da 0 a 1.
class SealPainter extends CustomPainter {
  SealPainter({required this.seal, this.progress = 1.0});

  final CircleSeal seal;
  final double progress;

  int get _symmetry {
    final n = seal.lifePath;
    if (n >= 11) return (n ~/ 11) + 5; // maestri: forme piu' ricche
    return n.clamp(3, 9);
  }

  double _phase(double start, double end) {
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return (progress - start) / (end - start);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.9;
    final color = seal.color;
    const gold = Color(0xFFE8C463);

    // Alone dell'elemento.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: 0.28 * progress),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // Anello esterno, si traccia per primo.
    final ringP = _phase(0.0, 0.45);
    if (ringP > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.92),
        -math.pi / 2,
        2 * math.pi * ringP,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = gold.withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        center,
        r * 0.82,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.5 * ringP),
      );
    }

    // Ruota dello zodiaco: dodici raggi, il segno solare acceso.
    final wheelP = _phase(0.3, 0.7);
    if (wheelP > 0) {
      final signIndex = Zodiac.values.indexOf(seal.sign);
      for (var i = 0; i < 12; i++) {
        final a = 2 * math.pi * i / 12 - math.pi / 2;
        final dir = Offset(math.cos(a), math.sin(a));
        final lit = i == signIndex;
        canvas.drawLine(
          center + dir * r * 0.5,
          center + dir * r * 0.82,
          Paint()
            ..strokeWidth = lit ? 2.2 : 0.8
            ..color = (lit ? gold : color)
                .withValues(alpha: (lit ? 0.9 : 0.35) * wheelP),
        );
        canvas.drawCircle(
          center + dir * r * 0.82,
          lit ? 4.5 * wheelP : 2.0 * wheelP,
          Paint()
            ..color = (lit ? gold : color).withValues(alpha: 0.9 * wheelP),
        );
      }
    }

    // Geometria sacra centrale, simmetria dal Numero della vita.
    final geoP = _phase(0.45, 0.85);
    if (geoP > 0) {
      final sym = _symmetry;
      final path = Path();
      for (var i = 0; i <= sym; i++) {
        final a = 2 * math.pi * i / sym - math.pi / 2;
        final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.42 * geoP;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round
          ..color = gold.withValues(alpha: 0.7 * geoP),
      );
      // Corona di tacche pari al Numero della vita.
      final ticks = seal.lifePath.clamp(1, 33);
      for (var i = 0; i < ticks; i++) {
        final a = 2 * math.pi * i / ticks - math.pi / 2;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawCircle(center + dir * r * 0.6, 1.6 * geoP,
            Paint()..color = color.withValues(alpha: 0.7 * geoP));
      }
    }

    // Cifra del Numero della vita al centro, per ultima.
    final numP = _phase(0.7, 1.0);
    if (numP > 0) {
      canvas.drawCircle(
        center,
        r * 0.26,
        Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: 0.45 * numP),
            const Color(0x00000000),
          ]).createShader(Rect.fromCircle(center: center, radius: r * 0.3)),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${seal.lifePath}',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: r * 0.42,
            color: Colors.white.withValues(alpha: numP),
            shadows: [
              Shadow(color: gold.withValues(alpha: 0.8 * numP), blurRadius: 16),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(SealPainter old) =>
      old.progress != progress || old.seal != seal;
}
