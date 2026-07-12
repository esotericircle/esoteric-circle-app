import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import 'zodiac_figures.dart';

/// Sfondo cosmico immersivo full-bleed.
///
/// Compone, dal fondo alla superficie:
/// - un cielo quasi nero che vira verso l'accento del Maestro attivo;
/// - tre piani di parallasse (stelle lontane e costellazioni, nebulose media,
///   particelle vicine) che rispondono allo scorrimento e a una leggera
///   inclinazione del dispositivo;
/// - le dodici costellazioni zodiacali con linee sottili dorate che respirano
///   in opacita', con la costellazione del segno solare evidenziata in oro;
/// - nebulose soffuse e pittoriche tinte verso l'accento del Maestro;
/// - stelle che pulsano e ogni tanto una stella cadente lenta.
///
/// Tutto e' regolato dal Quality Tier: pieno in alto, ridotto in medio, quasi
/// statico in basso per garantire fluidita' e batteria.
class CosmosBackground extends StatefulWidget {
  const CosmosBackground({
    super.key,
    required this.child,
    this.showZodiac = true,
  });

  final Widget child;

  /// Se falso, il cosmo non disegna le dodici costellazioni zodiacali ne'
  /// l'evidenziazione del segno solare. Le superfici di lettura, come la chat,
  /// lo spengono per restare pulite: nessuna forma stilizzata, nessun rettangolo
  /// a portale dietro l'interfaccia. Restano stelle, nebulose e stelle cadenti.
  final bool showZodiac;

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
    final sunSign = context.watch<ZodiacController>().sunSign;

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
                  Color.lerp(
                      palette.deepest, palette.backgroundGradient[1], 0.6)!,
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
                highlighted: sunSign,
                showZodiac: widget.showZodiac,
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
    required this.highlighted,
    required this.showZodiac,
  }) : super(repaint: Listenable.merge([animation, parallax]));

  final Animation<double> animation;
  final ParallaxController parallax;
  final MaestroPalette palette;
  final QualityTier tier;
  final Zodiac? highlighted;
  final bool showZodiac;

  int get _fieldStars => switch (tier) {
        QualityTier.high => 70,
        QualityTier.medium => 40,
        QualityTier.low => 18,
      };
  int get _nearCount => switch (tier) {
        QualityTier.high => 12,
        QualityTier.medium => 6,
        QualityTier.low => 0,
      };
  int get _nebulaClusters => switch (tier) {
        QualityTier.high => 3,
        QualityTier.medium => 2,
        QualityTier.low => 0,
      };
  bool get _shootingStars => tier != QualityTier.low;
  bool get _animate => tier != QualityTier.low;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animate ? animation.value : 0.0;

    // Offset dei tre piani (lontano si muove poco, vicino di piu').
    final farOff = parallax.layerOffset(0.15);
    final midOff = parallax.layerOffset(0.45);
    final nearOff = parallax.layerOffset(0.95);

    if (_nebulaClusters > 0) _paintNebula(canvas, size, midOff, t);
    _paintFieldStars(canvas, size, farOff, t);
    if (showZodiac) _paintZodiac(canvas, size, farOff, t);
    if (_nearCount > 0) _paintNearParticles(canvas, size, nearOff, t);
    if (_shootingStars) _paintShootingStars(canvas, size, farOff, t);
  }

  // --- Stelle di fondo, pulsazione dolce ---

  void _paintFieldStars(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(7);
    final stars = List<_Star>.generate(_fieldStars, (_) {
      return _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        0.4 + rng.nextDouble() * 1.5,
        rng.nextDouble(),
        0.14 + rng.nextDouble() * 0.5,
      );
    });
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final twinkle = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 6 + s.phase))
          : 0.7;
      final alpha = (s.baseAlpha * (0.45 + 0.55 * twinkle)).clamp(0.0, 1.0);
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
      canvas.drawCircle(
          Offset(s.x * size.width, s.y * size.height) + off, s.radius, paint);
    }
  }

  // --- Le dodici costellazioni zodiacali ---

  void _paintZodiac(Canvas canvas, Size size, Offset off, double t) {
    for (var i = 0; i < kZodiacConstellations.length; i++) {
      final c = kZodiacConstellations[i];
      final bool isHi = c.sign == highlighted;

      final breath =
          0.5 + 0.5 * math.sin(2 * math.pi * (t + i * 0.11));

      // Mappa i punti locali nello schermo.
      final center =
          Offset(c.anchor.dx * size.width, c.anchor.dy * size.height) + off;
      final fig = size.width * c.scale;
      final pts = [
        for (final p in c.points)
          center + Offset((p.dx - 0.5) * fig, (p.dy - 0.5) * fig),
      ];

      final double lineAlpha =
          isHi ? 0.6 + 0.3 * breath : 0.10 + 0.10 * breath;
      final double dotAlpha =
          isHi ? 0.8 + 0.2 * breath : 0.32 + 0.22 * breath;
      final Color lineColor =
          isHi ? palette.goldSoft : palette.gold;

      // Alone dorato sotto la costellazione evidenziata.
      if (isHi && tier != QualityTier.low) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft.withValues(alpha: 0.38 * (0.6 + 0.4 * breath))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
        for (final (a, b) in c.edges) {
          canvas.drawLine(pts[a], pts[b], glow);
        }
      }

      // Linee dell'asterismo.
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHi ? 1.3 : 0.8
        ..strokeCap = StrokeCap.round
        ..color = lineColor.withValues(alpha: lineAlpha);
      for (final (a, b) in c.edges) {
        canvas.drawLine(pts[a], pts[b], linePaint);
      }

      // Stelle ai vertici.
      final dotPaint = Paint()
        ..color = palette.goldSoft.withValues(alpha: dotAlpha);
      final double r = isHi ? 2.0 : 1.3;
      for (final p in pts) {
        canvas.drawCircle(p, r, dotPaint);
      }
    }
  }

  // --- Nebulose soffuse e pittoriche, piano intermedio ---

  void _paintNebula(Canvas canvas, Size size, Offset off, double t) {
    const centers = [
      Offset(0.22, 0.24),
      Offset(0.80, 0.5),
      Offset(0.5, 0.8),
    ];
    final drift = _animate ? math.sin(2 * math.pi * t) * 10 : 0.0;
    final blur = tier == QualityTier.high ? 90.0 : 46.0;
    final rng = math.Random(53);

    for (var i = 0; i < _nebulaClusters; i++) {
      final base = Offset(centers[i].dx * size.width, centers[i].dy * size.height) +
          off +
          Offset(drift, -drift);
      // Ogni nebulosa e' un grappolo di macchie morbide sovrapposte, cosi'
      // il bordo e' irregolare e pittorico, non un cerchio da sfondo.
      const blobs = 4;
      for (var b = 0; b < blobs; b++) {
        final dx = (rng.nextDouble() - 0.5) * size.width * 0.28;
        final dy = (rng.nextDouble() - 0.5) * size.height * 0.14;
        final radius = size.width * (0.16 + rng.nextDouble() * 0.22);
        final color = b.isEven ? palette.primary : palette.glow;
        final paint = Paint()
          ..color = color.withValues(alpha: 0.06 + rng.nextDouble() * 0.03)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
        canvas.drawCircle(base + Offset(dx, dy), radius, paint);
      }
    }
  }

  // --- Particelle vicine (bokeh) ---

  void _paintNearParticles(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(31);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _nearCount; i++) {
      final baseX = rng.nextDouble();
      final baseY = rng.nextDouble();
      final radius = 0.6 + rng.nextDouble() * 1.6;
      final dy = _animate ? (t + rng.nextDouble()) % 1.0 : baseY;
      final y = (baseY + dy * 0.12) % 1.0;
      final p = Offset(baseX * size.width, y * size.height) + off;
      canvas.drawCircle(
        p,
        radius * 2.6,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      paint.color = palette.goldSoft.withValues(alpha: 0.5);
      canvas.drawCircle(p, radius * 1.3, paint);
    }
  }

  // --- Stelle cadenti occasionali ---

  void _paintShootingStars(Canvas canvas, Size size, Offset off, double t) {
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
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..shader = shader
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        head,
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_CosmosPainter old) =>
      old.palette != palette ||
      old.tier != tier ||
      old.highlighted != highlighted ||
      old.showZodiac != showZodiac;
}
