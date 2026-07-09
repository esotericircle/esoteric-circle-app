import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// L'oggetto rituale vivo su cui si soffia, diverso per ciascun Maestro:
/// una vera sfera di cristallo su piedistallo per Medora, una candela accesa per
/// Caligo, un soffione per Aura. Ha profondita', riflessi e movimento interno
/// continuo, e reagisce al soffio o al dito ([level]) mentre il rito procede
/// ([progress]). Con Riduci Movimento resta su un fotogramma fermo ma pieno.
class RitualObject extends StatefulWidget {
  const RitualObject({
    super.key,
    required this.maestro,
    required this.palette,
    required this.progress,
    required this.level,
    this.reduceMotion = false,
    this.size = 240,
  });

  final Maestro maestro;
  final MaestroPalette palette;

  /// Avanzamento del rito, 0..1.
  final double progress;

  /// Intensita' istantanea del soffio o del dito, 0..1.
  final double level;
  final bool reduceMotion;
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
    );
    if (!widget.reduceMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(RitualObject old) {
    super.didUpdateWidget(old);
    if (widget.reduceMotion && _controller.isAnimating) {
      _controller.stop();
    } else if (!widget.reduceMotion && !_controller.isAnimating) {
      _controller.repeat();
    }
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
            t: widget.reduceMotion ? 0.0 : _controller.value,
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

  // --- Medora: sfera di cristallo su piedistallo ---
  void _crystalSphere(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, size.height * 0.40);
    final r = w * 0.34;

    // Il piedistallo, disegnato prima cosi' la sfera vi si appoggia sopra.
    _pedestal(canvas, size, sphere: c, r: r);

    // Alone esterno che reagisce.
    canvas.drawCircle(
        c,
        r * (1.28 + 0.16 * level),
        Paint()
          ..color = palette.glow
              .withValues(alpha: 0.14 + 0.30 * level + 0.10 * progress)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 26 + 14 * level));

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // Corpo del vetro: gradiente radiale, luce in alto a sinistra.
    final light = c + Offset(-r * 0.35, -r * 0.38);
    canvas.drawRect(
      Rect.fromCircle(center: c, radius: r),
      Paint()
        ..shader = RadialGradient(
          center: Alignment((light.dx - c.dx) / r, (light.dy - c.dy) / r),
          radius: 1.1,
          colors: [
            Color.lerp(palette.surfaceElevated, Colors.white,
                0.28 + 0.24 * progress)!,
            palette.surface,
            palette.deepest,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // Fumo interno che vortica in spirale e si dirada col soffio.
    final fogAlpha = (0.85 - 0.8 * progress).clamp(0.0, 0.85);
    final swirl = t * 2 * math.pi * (1 + 0.8 * level);
    for (var i = 0; i < 7; i++) {
      final a = swirl + i * (2 * math.pi / 7);
      // Raggio che si allontana dal centro col progresso (il fumo si spande e
      // sfuma verso il bordo mentre si dissolve).
      final rad = r * (0.12 + 0.32 * (i / 7)) * (1 + 0.6 * progress);
      final fp = c +
          Offset(math.cos(a) * rad, math.sin(a * 0.9) * rad * 0.9);
      canvas.drawCircle(
          fp,
          r * (0.40 - 0.16 * (i / 7)) * (1 + 0.2 * math.sin(a)),
          Paint()
            ..color = Color.lerp(Colors.white, palette.goldSoft, 0.35)!
                .withValues(alpha: fogAlpha * (0.42 - 0.04 * i).clamp(0.0, 0.42))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    }

    // Riflesso speculare in alto a sinistra.
    canvas.drawCircle(
        light,
        r * 0.18,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Sottile riflesso di finestra.
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: light + Offset(r * 0.05, r * 0.05),
                width: r * 0.10,
                height: r * 0.22),
            const Radius.circular(4)),
        Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.restore();

    // Bordo del vetro e luce riflessa in basso a destra.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = palette.gold.withValues(alpha: 0.65));
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.98),
        0.4,
        1.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..color = palette.goldSoft.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  // Piedistallo dorato che regge la sfera: culla ad artigli, stelo e base.
  void _pedestal(Canvas canvas, Size size, {required Offset sphere, required double r}) {
    final cx = sphere.dx;
    final cradleY = sphere.dy + r * 0.72; // sotto la sfera
    final baseY = size.height * 0.95;

    final gold = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.goldSoft,
          palette.gold,
          Color.lerp(palette.gold, Colors.black, 0.45)!,
        ],
      ).createShader(Rect.fromLTRB(cx - r, cradleY, cx + r, baseY));

    // Ombra a terra.
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, baseY + 4), width: r * 2.0, height: r * 0.34),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Base larga (due ellissi per dare spessore).
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, baseY), width: r * 1.5, height: r * 0.40),
        gold);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, baseY - r * 0.14), width: r * 1.3, height: r * 0.30),
        Paint()..color = Color.lerp(palette.gold, Colors.black, 0.2)!);

    // Stelo (calice) tra base e culla.
    final stem = Path()
      ..moveTo(cx - r * 0.30, cradleY + r * 0.02)
      ..cubicTo(cx - r * 0.16, cradleY + r * 0.45, cx - r * 0.34,
          baseY - r * 0.30, cx - r * 0.55, baseY - r * 0.06)
      ..lineTo(cx + r * 0.55, baseY - r * 0.06)
      ..cubicTo(cx + r * 0.34, baseY - r * 0.30, cx + r * 0.16,
          cradleY + r * 0.45, cx + r * 0.30, cradleY + r * 0.02)
      ..close();
    canvas.drawPath(stem, gold);

    // Nodo ornamentale al centro dello stelo.
    canvas.drawCircle(Offset(cx, (cradleY + baseY) / 2 + r * 0.05), r * 0.14,
        Paint()..color = palette.goldSoft);
    canvas.drawCircle(Offset(cx, (cradleY + baseY) / 2 + r * 0.05), r * 0.14,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Color.lerp(palette.gold, Colors.black, 0.3)!);

    // Culla ad artigli che avvolge la base della sfera.
    for (var i = -1; i <= 1; i++) {
      final startX = cx + i * r * 0.5;
      final claw = Path()
        ..moveTo(startX, cradleY - r * 0.20)
        ..quadraticBezierTo(
            startX + i * r * 0.10, cradleY + r * 0.12, cx + i * r * 0.20,
            cradleY + r * 0.18);
      canvas.drawPath(
          claw,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round
            ..color = palette.gold);
    }
    // Anello della culla.
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(cx, cradleY), width: r * 1.2, height: r * 0.5),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft);
  }

  // --- Caligo: candela accesa, fiamma grande ---
  void _candle(Canvas canvas, Size size) {
    final w = size.width;
    final cx = size.width / 2;
    final bodyTop = size.height * 0.52;
    final bodyBottom = size.height * 0.94;
    final bodyW = w * 0.24;

    // Pozza di luce alla base.
    canvas.drawCircle(
        Offset(cx, bodyBottom),
        bodyW * 2.0,
        Paint()
          ..color = const Color(0xFFE0733A).withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));

    // Corpo della candela.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - bodyW / 2, bodyTop, cx + bodyW / 2, bodyBottom),
      const Radius.circular(7),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            palette.deepest,
            Color.lerp(palette.surfaceElevated, Colors.white, 0.55)!,
            palette.deepest,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(bodyRect.outerRect),
    );
    // Cera fusa sul bordo superiore.
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, bodyTop), width: bodyW, height: bodyW * 0.28),
        Paint()..color = Color.lerp(palette.surfaceElevated, Colors.white, 0.4)!);
    canvas.drawRRect(
        bodyRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.gold.withValues(alpha: 0.4));

    // Stoppino.
    final wickTop = bodyTop - w * 0.045;
    canvas.drawLine(Offset(cx, bodyTop - w * 0.01), Offset(cx, wickTop),
        Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF201510));

    // Fiamma viva, grande, che il soffio piega e il progresso spegne.
    final alive = (1 - progress).clamp(0.0, 1.0);
    if (alive > 0.02) {
      final flicker = 1 + 0.14 * math.sin(t * 2 * math.pi * 5);
      final lean = level * w * 0.16 * math.sin(t * 40);
      final flameH = w * 0.40 * alive * flicker;
      final flameW = w * 0.17 * alive;
      final baseP = Offset(cx, wickTop);
      final tipP = Offset(cx + lean, wickTop - flameH);

      // Bagliore ampio.
      canvas.drawCircle(
          Offset(cx, wickTop - flameH * 0.4),
          flameH * (1.0 + 0.5 * level),
          Paint()
            ..color = const Color(0xFFFFB055).withValues(alpha: 0.34 * alive)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 + 12 * level));

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
      for (var k = 1; k <= 8; k++) {
        final yy = wickTop - k * w * 0.055;
        final xx = cx + math.sin(t * 2 * math.pi + k * 0.7) * w * 0.045;
        smoke.lineTo(xx, yy);
      }
      canvas.drawPath(
          smoke,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  // --- Aura: soffione grande e dettagliato ---
  void _dandelion(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.46, size.height * 0.40);
    final headR = w * 0.34;
    const total = 60;
    final remaining = (total * (1 - progress)).round();

    // Stelo curvo con una fogliolina.
    final stem = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + w * 0.10, size.height * 0.72, c.dx + w * 0.02,
          size.height * 0.96);
    canvas.drawPath(
        stem,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(palette.gold, const Color(0xFF5F9E6E), 0.5)!
              .withValues(alpha: 0.7));
    final leaf = Path()
      ..moveTo(c.dx + w * 0.07, size.height * 0.74)
      ..quadraticBezierTo(c.dx + w * 0.22, size.height * 0.70, c.dx + w * 0.16,
          size.height * 0.82)
      ..quadraticBezierTo(c.dx + w * 0.10, size.height * 0.80, c.dx + w * 0.07,
          size.height * 0.74);
    canvas.drawPath(leaf,
        Paint()..color = const Color(0xFF5F9E6E).withValues(alpha: 0.5));

    final rng = math.Random(11);
    for (var i = 0; i < total; i++) {
      final ang = (i / total) * 2 * math.pi + rng.nextDouble() * 0.12;
      final len = headR * (0.82 + rng.nextDouble() * 0.18);
      final sway = math.sin(t * 2 * math.pi + i) * 0.05 * (0.4 + level);
      final a = ang + sway;
      if (i < remaining) {
        // Filamento ancora attaccato, con pappo in punta.
        final end = c + Offset(math.cos(a), math.sin(a)) * len;
        canvas.drawLine(
            c,
            end,
            Paint()
              ..strokeWidth = 0.8
              ..color = palette.goldSoft.withValues(alpha: 0.55));
        _tuft(canvas, end, a, palette.goldSoft.withValues(alpha: 0.85));
      } else {
        // Seme staccato che vola via nel vento.
        final fly = (progress - (total - i) / total).clamp(0.0, 1.0);
        final drift = c +
            Offset(math.cos(a), math.sin(a)) * len +
            Offset(math.cos(a) * fly * w * 0.5 + fly * w * 0.2,
                -fly * size.height * 0.4);
        _tuft(canvas, drift, a,
            palette.goldSoft.withValues(alpha: (0.85 * (1 - fly)).clamp(0.0, 0.85)));
      }
    }

    // Ricettacolo centrale luminoso.
    canvas.drawCircle(
        c,
        8,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(c, 4, Paint()..color = palette.gold);
  }

  void _tuft(Canvas canvas, Offset p, double a, Color color) {
    final paint = Paint()
      ..strokeWidth = 0.7
      ..color = color;
    for (var k = -2; k <= 2; k++) {
      final aa = a + k * 0.22;
      canvas.drawLine(p, p + Offset(math.cos(aa), math.sin(aa)) * 7, paint);
    }
    canvas.drawCircle(p, 0.9, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RitualPainter old) => true;
}
