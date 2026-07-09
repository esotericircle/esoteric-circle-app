import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';

/// Sfondo cosmico immersivo full-bleed.
///
/// Compone, dal fondo alla superficie:
/// - un cielo quasi nero che vira verso l'accento del Maestro attivo;
/// - tre piani di parallasse (stelle lontane, nebulosa e polvere media,
///   particelle vicine) che rispondono allo scorrimento e a una leggera
///   inclinazione del dispositivo;
/// - stelle che pulsano dolcemente, costellazioni sottili che respirano in
///   opacita' e ogni tanto una stella cadente lenta;
/// - un alone del colore del Maestro in alto.
///
/// Tutto e' regolato dal Quality Tier: pieno in alto, ridotto in medio, quasi
/// statico in basso per garantire fluidita' e batteria.
class CosmosBackground extends StatefulWidget {
  const CosmosBackground({super.key, required this.child});

  final Widget child;

  @override
  State<CosmosBackground> createState() => _CosmosBackgroundState();
}

class _CosmosBackgroundState extends State<CosmosBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Un unico ciclo lungo governa pulsazione, respiro e stelle cadenti.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final quality = context.watch<QualityTierController>().tier;
    final parallax = context.watch<ParallaxController>();

    // In qualita' bassa il cosmo e' quasi statico: fermiamo il ciclo.
    if (quality == QualityTier.low) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      if (!_controller.isAnimating) _controller.repeat();
    }

    return Stack(
      children: [
        // Cielo di fondo, tinto verso l'accento del Maestro.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.deepest,
                  Color.lerp(palette.deepest, palette.backgroundGradient[1],
                      0.6)!,
                  palette.deepest,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        // Piani cosmici animati.
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _CosmosPainter(
                animation: _controller,
                parallax: parallax,
                palette: palette,
                tier: quality,
              ),
            ),
          ),
        ),
        // Alone del Maestro in alto.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.9),
                  radius: 1.15,
                  colors: [
                    palette.glow.withValues(
                        alpha: quality == QualityTier.high ? 0.26 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  const _Star(this.x, this.y, this.radius, this.phase, this.baseAlpha);
  final double x; // 0..1
  final double y; // 0..1
  final double radius;
  final double phase;
  final double baseAlpha;
}

class _CosmosPainter extends CustomPainter {
  _CosmosPainter({
    required this.animation,
    required this.parallax,
    required this.palette,
    required this.tier,
  }) : super(repaint: Listenable.merge([animation, parallax]));

  final Animation<double> animation;
  final ParallaxController parallax;
  final MaestroPalette palette;
  final QualityTier tier;

  // Conteggi per tier.
  int get _farCount => switch (tier) {
        QualityTier.high => 120,
        QualityTier.medium => 60,
        QualityTier.low => 24,
      };
  int get _nearCount => switch (tier) {
        QualityTier.high => 12,
        QualityTier.medium => 6,
        QualityTier.low => 0,
      };
  int get _constellations => switch (tier) {
        QualityTier.high => 4,
        QualityTier.medium => 2,
        QualityTier.low => 1,
      };
  bool get _nebula => tier != QualityTier.low;
  bool get _shootingStars => tier != QualityTier.low;
  bool get _animate => tier != QualityTier.low;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animate ? animation.value : 0.0;

    // Offset dei tre piani (lontano si muove poco, vicino di piu').
    final farOff = parallax.layerOffset(0.15);
    final midOff = parallax.layerOffset(0.45);
    final nearOff = parallax.layerOffset(0.95);

    if (_nebula) _paintNebula(canvas, size, midOff, t);
    _paintFarStarsAndConstellations(canvas, size, farOff, t);
    if (_nearCount > 0) _paintNearParticles(canvas, size, nearOff, t);
    if (_shootingStars) _paintShootingStars(canvas, size, farOff, t);
  }

  List<_Star> _buildStars(int count, int seed, Size size) {
    final rng = math.Random(seed);
    return List<_Star>.generate(count, (_) {
      return _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        0.4 + rng.nextDouble() * 1.7,
        rng.nextDouble(),
        0.18 + rng.nextDouble() * 0.6,
      );
    });
  }

  void _paintFarStarsAndConstellations(
      Canvas canvas, Size size, Offset off, double t) {
    final stars = _buildStars(_farCount, 7, size);
    final paint = Paint()..style = PaintingStyle.fill;

    // Costellazioni: piccoli grappoli compatti di stelle vicine, collegati da
    // linee sottili che respirano in opacita'. Ogni grappolo ha un centro e
    // punti entro un raggio breve, cosi' le linee restano delicate, non un
    // reticolo che attraversa lo schermo.
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final crng = math.Random(101);
    for (var c = 0; c < _constellations; c++) {
      final breath = 0.08 +
          0.12 *
              (0.5 + 0.5 * math.sin(2 * math.pi * (t + c / _constellations)));
      linePaint.color = palette.goldSoft.withValues(alpha: breath);
      final dotPaint = Paint()
        ..color = palette.goldSoft.withValues(alpha: breath + 0.15);

      final center = Offset(
        (0.15 + crng.nextDouble() * 0.7) * size.width,
        (0.10 + crng.nextDouble() * 0.5) * size.height,
      );
      final points = <Offset>[];
      final n = 4 + crng.nextInt(3);
      for (var k = 0; k < n; k++) {
        final angle = crng.nextDouble() * 2 * math.pi;
        final dist = 16 + crng.nextDouble() * 46;
        points.add(center +
            Offset(math.cos(angle) * dist, math.sin(angle) * dist) +
            off);
      }
      for (var k = 1; k < points.length; k++) {
        canvas.drawLine(points[k - 1], points[k], linePaint);
      }
      for (final p in points) {
        canvas.drawCircle(p, 1.2, dotPaint);
      }
    }

    // Stelle che pulsano dolcemente.
    for (final s in stars) {
      final twinkle = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 6 + s.phase))
          : 0.7;
      final alpha = (s.baseAlpha * (0.45 + 0.55 * twinkle)).clamp(0.0, 1.0);
      final color = s.phase > 0.85 ? palette.goldSoft : const Color(0xFFFFFFFF);
      paint.color = color.withValues(alpha: alpha);
      final p = Offset(s.x * size.width, s.y * size.height) + off;
      canvas.drawCircle(p, s.radius, paint);
    }
  }

  void _paintNebula(Canvas canvas, Size size, Offset off, double t) {
    final blobs = tier == QualityTier.high ? 3 : 1;
    final drift = _animate ? math.sin(2 * math.pi * t) * 12 : 0.0;
    final paint = Paint();
    if (tier == QualityTier.high) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    }
    final spots = <Offset>[
      Offset(size.width * 0.25, size.height * 0.30),
      Offset(size.width * 0.80, size.height * 0.48),
      Offset(size.width * 0.50, size.height * 0.72),
    ];
    final colors = <Color>[palette.primary, palette.glow, palette.primary];
    for (var i = 0; i < blobs; i++) {
      final center = spots[i] + off + Offset(drift, -drift);
      paint.color = colors[i].withValues(alpha: 0.10);
      canvas.drawCircle(center, size.width * 0.35, paint);
    }
  }

  void _paintNearParticles(Canvas canvas, Size size, Offset off, double t) {
    final stars = _buildStars(_nearCount, 31, size);
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      // Deriva verticale lenta e continua.
      final dy = _animate ? (t + s.phase) % 1.0 : s.y;
      final y = (s.y + dy * 0.12) % 1.0;
      final p = Offset(s.x * size.width, y * size.height) + off;
      final glow = Paint()
        ..color = palette.goldSoft.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(p, s.radius * 2.6, glow);
      paint.color = palette.goldSoft.withValues(alpha: 0.5);
      canvas.drawCircle(p, s.radius * 1.4, paint);
    }
  }

  void _paintShootingStars(Canvas canvas, Size size, Offset off, double t) {
    // Due passaggi per ciclo, in finestre brevi.
    const windows = [0.18, 0.68];
    const dur = 0.06;
    for (var i = 0; i < windows.length; i++) {
      final w0 = windows[i];
      if (t < w0 || t > w0 + dur) continue;
      final p = (t - w0) / dur; // 0..1
      final startX = size.width * (0.1 + i * 0.5);
      final startY = size.height * 0.12;
      final head = Offset(
            startX + p * size.width * 0.7,
            startY + p * size.height * 0.35,
          ) +
          off;
      final tail = head - const Offset(90, 45);
      final shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.goldSoft.withValues(alpha: 0.9 * (1 - p)),
        ],
      ).createShader(Rect.fromPoints(tail, head));
      final streak = Paint()
        ..shader = shader
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(tail, head, streak);
      canvas.drawCircle(
        head,
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_CosmosPainter old) =>
      old.palette != palette || old.tier != tier;
}
