import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cielo stellato dorato dipinto proceduralmente, comune a tutti i temi.
///
/// La disposizione delle stelle e' deterministica (seed fisso), quindi stabile
/// tra i frame e i rebuild. Il numero di stelle e' governato dal Quality Tier:
/// a 0 il painter non disegna nulla. Nessun asset binario coinvolto.
class Starfield extends StatelessWidget {
  const Starfield({
    super.key,
    required this.starCount,
    required this.color,
    this.seed = 7,
  });

  final int starCount;
  final Color color;
  final int seed;

  @override
  Widget build(BuildContext context) {
    if (starCount <= 0) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _StarfieldPainter(
          starCount: starCount,
          color: color,
          seed: seed,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({
    required this.starCount,
    required this.color,
    required this.seed,
  });

  final int starCount;
  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < starCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final radius = 0.4 + rng.nextDouble() * 1.6;
      final opacity = 0.15 + rng.nextDouble() * 0.65;
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.starCount != starCount || old.color != color || old.seed != seed;
}
