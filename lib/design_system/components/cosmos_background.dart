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
    this.starKeepOut,
    this.showPlanets = true,
  });

  final Widget child;

  /// Se falso, il cosmo non disegna le dodici costellazioni zodiacali ne'
  /// l'evidenziazione del segno solare. Le superfici di lettura, come la chat,
  /// lo spengono per restare pulite: nessuna forma stilizzata, nessun rettangolo
  /// a portale dietro l'interfaccia. Restano stelle, nebulose e stelle cadenti.
  final bool showZodiac;

  /// Zona franca, in coordinate normalizzate (0..1), dove non nascono stelle di
  /// fondo ne' particelle vicine. Serve a tenere il cielo lontano dal testo del
  /// titolo, cosi' nessuna stella cade su una lettera. Null per nessuna zona.
  final Rect? starKeepOut;

  /// Se falso, il cosmo non disegna i dischi dei pianeti soffusi. Lo spegne chi
  /// mette in scena un corpo celeste suo, come il Rito del Sogno con la Luna e
  /// il suo pianeta lontano, per non sovrapporre due sfere. Default acceso:
  /// nessuna altra schermata cambia.
  final bool showPlanets;

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
    // Riduci Movimento: cosmo fermo, niente stella cadente, parallasse minima.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // In qualita' bassa o con Riduci Movimento il cosmo e' quasi statico.
    if (quality == QualityTier.low || reduceMotion) {
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
                reduceMotion: reduceMotion,
                keepOut: widget.starKeepOut,
                showPlanets: widget.showPlanets,
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
        // Vignettatura: scurisce i bordi per incorniciare la scena e spingere
        // indietro il fondo. Sta sotto il primo piano, cosi' le carte al centro
        // non perdono leggibilita'.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    palette.deepest.withValues(alpha: 0.55),
                  ],
                  stops: const [0.0, 0.6, 1.0],
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

/// Le tinte fredde delle nebulose del cosmo, esposte come fonte di verita' unica
/// e per i test: un indaco-viola luminoso col nucleo piu' chiaro, scelto apposta
/// per staccare dall'accento di qualsiasi Maestro invece di confondersi con esso.
class CosmosNebula {
  const CosmosNebula._();

  /// Nucleo chiaro della nebulosa.
  static const Color core = Color(0xFFB9B0FF);

  /// Corpo indaco-viola.
  static const Color mid = Color(0xFF6E5FE0);

  /// Tono freddo secondario.
  static const Color cool = Color(0xFF4B6BE0);
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
    required this.reduceMotion,
    required this.keepOut,
    required this.showPlanets,
  }) : super(repaint: Listenable.merge([animation, parallax]));

  final Animation<double> animation;
  final ParallaxController parallax;
  final MaestroPalette palette;
  final QualityTier tier;
  final Zodiac? highlighted;
  final bool showZodiac;
  final bool showPlanets;
  final bool reduceMotion;

  /// Zona franca normalizzata dove non nascono stelle ne' particelle.
  final Rect? keepOut;

  int get _fieldStars => QualityTierController.fieldStarsFor(tier);
  int get _dustStars => switch (tier) {
        QualityTier.high => 90,
        QualityTier.medium => 40,
        QualityTier.low => 0,
      };
  int get _heroStars => switch (tier) {
        QualityTier.high => 7,
        QualityTier.medium => 4,
        QualityTier.low => 2,
      };
  int get _planetCount => switch (tier) {
        QualityTier.high => 2,
        QualityTier.medium => 1,
        QualityTier.low => 0,
      };
  int get _nearCount => switch (tier) {
        QualityTier.high => 14,
        QualityTier.medium => 7,
        QualityTier.low => 0,
      };
  int get _nebulaClusters => switch (tier) {
        QualityTier.high => 3,
        QualityTier.medium => 2,
        QualityTier.low => 1,
      };
  bool get _shootingStars => tier != QualityTier.low && !reduceMotion;
  bool get _animate => tier != QualityTier.low && !reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animate ? animation.value : 0.0;

    // Offset dei tre piani (lontano si muove poco, vicino di piu'). Se il
    // giroscopio non contribuisce, una deriva lenta automatica tiene comunque
    // vivo il cosmo, salvo Riduci Movimento.
    Offset off(double depth) {
      final base = parallax.layerOffset(depth);
      if (_animate && !parallax.sensorActive) {
        return base + parallax.autoDrift(depth, t);
      }
      return base;
    }

    // Separazione ampia tra i piani: il lontano quasi fermo, il vicino molto
    // reattivo, cosi' il movimento si sente come profondita' reale.
    final deepOff = off(0.06);
    final farOff = off(0.16);
    final midOff = off(0.5);
    final nearOff = off(1.3);

    if (_nebulaClusters > 0) _paintNebula(canvas, size, midOff, t);
    if (_dustStars > 0) _paintStarDust(canvas, size, deepOff, t);
    _paintFieldStars(canvas, size, farOff, t);
    _paintHeroStars(canvas, size, farOff, t);
    if (showPlanets && _planetCount > 0) _paintPlanets(canvas, size, midOff);
    if (showZodiac) _paintZodiac(canvas, size, farOff, t);
    if (_nearCount > 0) _paintNearParticles(canvas, size, nearOff, t);
    if (_shootingStars) _paintShootingStars(canvas, size, farOff, t);
  }

  // --- Polvere stellare fine sul piano piu' lontano ---

  void _paintStarDust(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(91);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _dustStars; i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      if (keepOut != null && keepOut!.contains(Offset(x, y))) continue;
      final twinkle = _animate
          ? 0.4 + 0.6 * math.sin(2 * math.pi * (t * 4 + rng.nextDouble()))
          : 0.6;
      final alpha = (0.05 + 0.13 * twinkle).clamp(0.0, 1.0);
      paint.color = const Color(0xFFEAF0FF).withValues(alpha: alpha);
      // Polvere lontana: deriva ridotta, si muove pochissimo.
      canvas.drawCircle(
          Offset(x * size.width, y * size.height) + off * 0.5,
          0.3 + rng.nextDouble() * 0.5,
          paint);
    }
  }

  // --- Stelle protagoniste: grandi, con alone e scintillio a croce ---

  void _paintHeroStars(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(313);
    for (var i = 0; i < _heroStars; i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble() * 0.7; // in alto, dove il cielo respira
      if (keepOut != null && keepOut!.contains(Offset(x, y))) continue;
      final center = Offset(x * size.width, y * size.height) + off;
      final baseR = 1.6 + rng.nextDouble() * 1.4;
      final tw = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + rng.nextDouble()))
          : 0.85;
      final a = (0.6 + 0.4 * tw).clamp(0.0, 1.0);

      // Alone morbido.
      canvas.drawCircle(
        center,
        baseR * 4.5,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.22 * a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Scintillio a croce.
      final spike = baseR * (5 + 3 * tw);
      final crossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * a)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          center - Offset(spike, 0), center + Offset(spike, 0), crossPaint);
      canvas.drawLine(
          center - Offset(0, spike), center + Offset(0, spike), crossPaint);
      // Nucleo bianco brillante.
      canvas.drawCircle(
          center, baseR, Paint()..color = Colors.white.withValues(alpha: a));
    }
  }

  // --- Pianeti soffusi, dischi tenui con luce radente, per dare scala ---

  void _paintPlanets(Canvas canvas, Size size, Offset off) {
    const spots = [
      (Offset(0.16, 0.2), 10.0),
      (Offset(0.82, 0.3), 7.0),
    ];
    for (var i = 0; i < _planetCount && i < spots.length; i++) {
      final (pos, r) = spots[i];
      final center = Offset(pos.dx * size.width, pos.dy * size.height) + off;
      // Alone.
      canvas.drawCircle(
        center,
        r * 2.4,
        Paint()
          ..color = (i.isEven ? CosmosNebula.cool : palette.glow)
              .withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Disco con luce radente: chiaro su un lato, in ombra sull'altro.
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.5, -0.5),
            radius: 1.1,
            colors: [
              Colors.white.withValues(alpha: 0.5),
              (i.isEven ? CosmosNebula.mid : palette.primary)
                  .withValues(alpha: 0.35),
              palette.deepest.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  // --- Stelle di fondo, pulsazione dolce ---

  void _paintFieldStars(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(7);
    final stars = List<_Star>.generate(_fieldStars, (_) {
      // Intervallo di dimensioni piu' ampio: da minute a decise, per profondita'.
      final rr = rng.nextDouble();
      return _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        0.4 + rr * rr * 2.6,
        rng.nextDouble(),
        0.28 + rng.nextDouble() * 0.62,
      );
    });
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      // Zona franca: nessuna stella sul testo del titolo in alto.
      if (keepOut != null && keepOut!.contains(Offset(s.x, s.y))) continue;
      final twinkle = _animate
          ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 6 + s.phase))
          : 0.8;
      final alpha = (s.baseAlpha * (0.55 + 0.45 * twinkle)).clamp(0.0, 1.0);
      final center = Offset(s.x * size.width, s.y * size.height) + off;
      // Alone tenue sulle stelle piu' grandi, cosi' spiccano di piu'.
      if (s.radius > 1.4) {
        canvas.drawCircle(
          center,
          s.radius * 2.6,
          Paint()
            ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
      canvas.drawCircle(center, s.radius, paint);
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
      Offset(0.22, 0.22),
      Offset(0.80, 0.46),
      Offset(0.52, 0.74),
    ];
    final drift = _animate ? math.sin(2 * math.pi * t) * 12 : 0.0;
    final rng = math.Random(53);

    for (var i = 0; i < _nebulaClusters; i++) {
      final base = Offset(
              centers[i].dx * size.width, centers[i].dy * size.height) +
          off +
          Offset(drift, -drift);
      // Ogni nebulosa e' un grappolo di macchie morbide sovrapposte con un
      // nucleo piu' chiaro: nubi di luce fredda che staccano dall'accento del
      // dominio, non aloni impercettibili tinti come il fondo.
      const blobs = 5;
      for (var b = 0; b < blobs; b++) {
        final dx = (rng.nextDouble() - 0.5) * size.width * 0.34;
        final dy = (rng.nextDouble() - 0.5) * size.height * 0.16;
        final radius = size.width * (0.16 + rng.nextDouble() * 0.24);
        final c = Offset(base.dx + dx, base.dy + dy);
        // Nucleo chiaro, corpo indaco-viola, bordo che si dissolve morbido.
        final coreAlpha = 0.18 + rng.nextDouble() * 0.12; // 0,18..0,30
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              CosmosNebula.core.withValues(alpha: coreAlpha),
              (b.isEven ? CosmosNebula.mid : CosmosNebula.cool)
                  .withValues(alpha: coreAlpha * 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: radius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
        canvas.drawCircle(c, radius, paint);
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
      // Zona franca anche per le particelle vicine.
      if (keepOut != null && keepOut!.contains(Offset(baseX, y))) continue;
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
      old.showZodiac != showZodiac ||
      old.reduceMotion != reduceMotion ||
      old.keepOut != keepOut;
}
