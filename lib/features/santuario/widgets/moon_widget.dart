import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/astro/moon_phase.dart';

/// La Luna del Santuario, in alto, nella sua fase reale attuale.
///
/// Disegna il disco con il terminatore corretto e un alone morbido che
/// illumina la parte alta della scena. Se la fase non e' calcolabile ripiega su
/// una Luna neutra (disco tenue senza terminatore).
class MoonWidget extends StatelessWidget {
  const MoonWidget({
    super.key,
    required this.phase,
    this.size = 96,
    this.glowColor = const Color(0xFFF4F1E8),
  });

  /// Fase corrente, oppure null per la Luna neutra di ripiego.
  final MoonPhase? phase;
  final double size;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.6,
      height: size * 2.6,
      child: CustomPaint(
        painter: _MoonPainter(phase: phase, glow: glowColor),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  _MoonPainter({required this.phase, required this.glow});

  final MoonPhase? phase;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 / 2.6; // il disco occupa il centro dell'area alone

    // Alone diffuso che illumina la parte alta della scena.
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glow.withValues(alpha: 0.28),
          glow.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, glowPaint);

    // Disco in ombra, sempre presente.
    final shadowPaint = Paint()..color = const Color(0xFF141726);
    canvas.drawCircle(center, r, shadowPaint);

    final litPaint = Paint()
      ..shader = RadialGradient(
        colors: [glow, glow.withValues(alpha: 0.82)],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    final p = phase;
    if (p == null) {
      // Luna neutra: disco tenue, senza fase.
      canvas.drawCircle(
        center,
        r,
        Paint()..color = glow.withValues(alpha: 0.35),
      );
      _rim(canvas, center, r);
      return;
    }

    final f = p.fraction;
    if (p.illumination < 0.01) {
      // Luna nuova: solo il cerchio in ombra con un filo di luce sul bordo.
      _rim(canvas, center, r);
      return;
    }

    final rx = (math.cos(2 * math.pi * f)).abs() * r;
    final waxing = p.waxing;
    final gibbous = p.illumination > 0.5;
    final top = Offset(center.dx, center.dy - r);
    final bottom = Offset(center.dx, center.dy + r);
    final termClockwise = gibbous ? waxing : !waxing;

    final lit = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(bottom, radius: Radius.circular(r), clockwise: waxing)
      ..arcToPoint(top,
          radius: Radius.elliptical(rx, r), clockwise: termClockwise)
      ..close();
    canvas.drawPath(lit, litPaint);
    _rim(canvas, center, r);
  }

  void _rim(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = glow.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_MoonPainter old) =>
      old.phase?.fraction != phase?.fraction || old.glow != glow;
}
