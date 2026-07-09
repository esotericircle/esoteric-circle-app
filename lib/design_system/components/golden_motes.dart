import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';

/// Particelle dorate che fluttuano lentamente verso l'alto, con leggera
/// oscillazione e scintillio. Danno vita allo spazio attorno ai campi
/// dell'onboarding. Regolate dal Quality Tier.
class GoldenMotes extends StatefulWidget {
  const GoldenMotes({super.key, this.count = 26});

  final int count;

  @override
  State<GoldenMotes> createState() => _GoldenMotesState();
}

class _GoldenMotesState extends State<GoldenMotes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<QualityTierController>().tier;
    final palette = context.palette;
    final count = switch (tier) {
      QualityTier.high => widget.count,
      QualityTier.medium => widget.count ~/ 2,
      QualityTier.low => 0,
    };
    if (count == 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _MotesPainter(
              t: _controller.value,
              count: count,
              color: palette.goldSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _MotesPainter extends CustomPainter {
  _MotesPainter({required this.t, required this.count, required this.color});

  final double t;
  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(19);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      final x0 = rng.nextDouble();
      final baseY = rng.nextDouble();
      final speed = 0.4 + rng.nextDouble() * 0.8;
      final radius = 0.6 + rng.nextDouble() * 1.8;
      final phase = rng.nextDouble();

      // Salita continua con avvolgimento.
      final y = (baseY - t * speed) % 1.0;
      final sway = math.sin(2 * math.pi * (t * speed + phase)) * 0.03;
      final x = (x0 + sway) % 1.0;
      final twinkle =
          0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + phase)));

      final pos = Offset(x * size.width, y * size.height);
      paint.color = color.withValues(alpha: 0.06 + 0.14 * twinkle);
      canvas.drawCircle(
          pos, radius * 2.2, paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      paint.maskFilter = null;
      paint.color = color.withValues(alpha: 0.2 + 0.4 * twinkle);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) => true;
}
