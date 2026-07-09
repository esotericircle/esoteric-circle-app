import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// L'oggetto rituale vivo su cui si soffia, diverso per ciascun Maestro:
/// una vera sfera di cristallo per Medora, una candela accesa per Caligo, un
/// soffione per Aura. Ha profondita', riflessi e movimento interno continuo, e
/// reagisce al soffio o al dito ([level]) mentre il rito procede ([progress]).
class RitualObject extends StatefulWidget {
  const RitualObject({
    super.key,
    required this.maestro,
    required this.palette,
    required this.progress,
    required this.level,
    this.size = 190,
  });

  final Maestro maestro;
  final MaestroPalette palette;

  /// Avanzamento del rito, 0..1.
  final double progress;

  /// Intensita' istantanea del soffio o del dito, 0..1.
  final double level;
  final double size;

  @override
  State<RitualObject> createState() => _RitualObjectState();
}

class _RitualObjectState extends State<RitualObject>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _RitualPainter(
            maestro: widget.maestro,
            palette: widget.palette,
            t: _controller.value,
            progress: widget.progress,
            level: widget.level,
          ),
        ),
      ),
    );
  }
}

class _RitualPainter extends CustomPainter {
  _RitualPainter({
    required this.maestro,
    required this.palette,
    required this.t,
    required this.progress,
    required this.level,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final double t;
  final double progress;
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    switch (maestro) {
      case Maestro.medora:
        _crystalSphere(canvas, size);
      case Maestro.caligo:
        _candle(canvas, size);
      case Maestro.aura:
        _dandelion(canvas, size);
    }
  }

  // --- Medora: sfera di cristallo ---
  void _crystalSphere(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.42;

    // Alone esterno che reagisce.
    canvas.drawCircle(
        c,
        r * (1.25 + 0.15 * level),
        Paint()
          ..color = palette.glow
              .withValues(alpha: 0.12 + 0.28 * level + 0.1 * progress)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 22 + 12 * level));

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // Corpo del vetro: gradiente radiale, luce in alto a sinistra.
    final light = c + Offset(-r * 0.35, -r * 0.35);
    canvas.drawRect(
      Rect.fromCircle(center: c, radius: r),
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
              (light.dx - c.dx) / r, (light.dy - c.dy) / r),
          radius: 1.1,
          colors: [
            Color.lerp(palette.surfaceElevated, Colors.white,
                0.25 + 0.25 * progress)!,
            palette.surface,
            palette.deepest,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // Nebbia interna che si muove (si dirada col progresso).
    final fogAlpha = (0.5 - 0.4 * progress).clamp(0.0, 0.5);
    for (var i = 0; i < 3; i++) {
      final ph = t * 2 * math.pi + i * 2.1;
      final fp = c +
          Offset(math.cos(ph) * r * 0.3, math.sin(ph * 0.8) * r * 0.28);
      canvas.drawCircle(
          fp,
          r * (0.5 + 0.1 * math.sin(ph)),
          Paint()
            ..color = Colors.white.withValues(alpha: fogAlpha * 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));
    }

    // Riflesso speculare.
    canvas.drawCircle(
        light,
        r * 0.16,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.restore();

    // Bordo del vetro e luce riflessa in basso a destra.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = palette.gold.withValues(alpha: 0.6));
    final rim = Rect.fromCircle(center: c, radius: r * 0.98);
    canvas.drawArc(
        rim,
        0.4,
        1.4,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = palette.goldSoft.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  // --- Caligo: candela accesa ---
  void _candle(Canvas canvas, Size size) {
    final w = size.width;
    final cx = size.width / 2;
    final bodyTop = size.height * 0.5;
    final bodyBottom = size.height * 0.9;
    final bodyW = w * 0.2;

    // Pozza di luce alla base.
    canvas.drawCircle(
        Offset(cx, bodyBottom),
        bodyW * 1.8,
        Paint()
          ..color = const Color(0xFFE0733A).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Corpo della candela.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - bodyW / 2, bodyTop, cx + bodyW / 2, bodyBottom),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            palette.deepest,
            Color.lerp(palette.surfaceElevated, Colors.white, 0.5)!,
            palette.deepest,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(bodyRect.outerRect),
    );
    canvas.drawRRect(
        bodyRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.gold.withValues(alpha: 0.4));

    // Stoppino.
    final wickTop = bodyTop - w * 0.03;
    canvas.drawLine(Offset(cx, bodyTop), Offset(cx, wickTop),
        Paint()..strokeWidth = 2..color = const Color(0xFF201510));

    // Fiamma viva, che il soffio piega e il progresso spegne.
    final alive = (1 - progress).clamp(0.0, 1.0);
    if (alive > 0.02) {
      final flicker = 1 + 0.12 * math.sin(t * 2 * math.pi * 5);
      final lean = level * w * 0.12 * math.sin(t * 40);
      final flameH = w * 0.28 * alive * flicker;
      final flameW = w * 0.12 * alive;
      final baseP = Offset(cx, wickTop);
      final tipP = Offset(cx + lean, wickTop - flameH);

      // Bagliore.
      canvas.drawCircle(
          Offset(cx, wickTop - flameH * 0.4),
          flameH * (0.9 + 0.4 * level),
          Paint()
            ..color = const Color(0xFFFFB055).withValues(alpha: 0.3 * alive)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + 10 * level));

      Path flame(double scale, Offset tip) => Path()
        ..moveTo(baseP.dx - flameW * scale / 2, baseP.dy)
        ..quadraticBezierTo(baseP.dx - flameW * scale / 2,
            (baseP.dy + tip.dy) / 2, tip.dx, tip.dy)
        ..quadraticBezierTo(baseP.dx + flameW * scale / 2,
            (baseP.dy + tip.dy) / 2, baseP.dx + flameW * scale / 2, baseP.dy)
        ..close();

      canvas.drawPath(flame(1.0, tipP),
          Paint()..color = const Color(0xFFE0733A).withValues(alpha: alive));
      canvas.drawPath(flame(0.62, Offset(tipP.dx, tipP.dy + flameH * 0.28)),
          Paint()..color = const Color(0xFFFFD86B).withValues(alpha: alive));
      canvas.drawPath(flame(0.28, Offset(tipP.dx, tipP.dy + flameH * 0.5)),
          Paint()..color = Colors.white.withValues(alpha: 0.9 * alive));
    } else {
      // Fumo che sale quando la candela e' spenta.
      final smoke = Path()..moveTo(cx, wickTop);
      for (var k = 1; k <= 6; k++) {
        final yy = wickTop - k * w * 0.05;
        final xx = cx + math.sin(t * 2 * math.pi + k) * w * 0.03;
        smoke.lineTo(xx, yy);
      }
      canvas.drawPath(
          smoke,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  // --- Aura: soffione ---
  void _dandelion(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.42);
    final headR = size.width * 0.3;
    const total = 46;
    final remaining = (total * (1 - progress)).round();

    // Stelo.
    canvas.drawLine(
        c,
        Offset(c.dx + size.width * 0.04, size.height * 0.95),
        Paint()
          ..strokeWidth = 2
          ..color = palette.gold.withValues(alpha: 0.5));

    final rng = math.Random(11);
    for (var i = 0; i < total; i++) {
      final ang = (i / total) * 2 * math.pi + rng.nextDouble() * 0.1;
      final sway = math.sin(t * 2 * math.pi + i) * 0.05 * (0.4 + level);
      final a = ang + sway;
      if (i < remaining) {
        // Filamento ancora attaccato.
        final end = c + Offset(math.cos(a), math.sin(a)) * headR;
        canvas.drawLine(
            c,
            end,
            Paint()
              ..strokeWidth = 0.7
              ..color = palette.goldSoft.withValues(alpha: 0.5));
        _tuft(canvas, end, a, palette.goldSoft.withValues(alpha: 0.8));
      } else {
        // Seme che si e' staccato e vola via.
        final fly = (progress - (total - i) / total).clamp(0.0, 1.0);
        final drift = c +
            Offset(math.cos(a), math.sin(a)) * headR +
            Offset(math.cos(a) * fly * size.width * 0.4,
                -fly * size.height * 0.35);
        _tuft(canvas, drift, a,
            palette.goldSoft.withValues(alpha: (0.8 * (1 - fly)).clamp(0.0, 0.8)));
      }
    }

    // Centro luminoso.
    canvas.drawCircle(
        c,
        6,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  void _tuft(Canvas canvas, Offset p, double a, Color color) {
    final paint = Paint()
      ..strokeWidth = 0.6
      ..color = color;
    for (var k = -1; k <= 1; k++) {
      final aa = a + k * 0.28;
      canvas.drawLine(p, p + Offset(math.cos(aa), math.sin(aa)) * 5, paint);
    }
    canvas.drawCircle(p, 0.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RitualPainter old) => true;
}
