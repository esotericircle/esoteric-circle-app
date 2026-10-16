import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// L'oggetto rituale vivo su cui si soffia, diverso per ciascun Maestro: una
/// vera sfera di cristallo su piedistallo cesellato per Medora, una candela di
/// cera per Caligo, un dente di leone per Aura. E' dipinto a piu' strati con
/// gradienti, alte luci, ombre e profondita' 2.5D, per stare all'altezza dei
/// Maestri. Reagisce al soffio o al dito ([level]) mentre il rito procede
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

  // ==================== Medora: sfera di cristallo ====================
  void _crystalSphere(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, size.height * 0.40);
    final r = w * 0.34;

    _pedestal(canvas, size, sphere: c, r: r);

    // Alone esterno reattivo (la sfera irradia).
    canvas.drawCircle(
        c,
        r * (1.30 + 0.16 * level),
        Paint()
          ..color = palette.glow
              .withValues(alpha: 0.16 + 0.30 * level + 0.10 * progress)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 + 14 * level));

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // Vetro di base: gradiente radiale con la luce in alto a sinistra.
    final light = c + Offset(-r * 0.36, -r * 0.40);
    canvas.drawRect(
      Rect.fromCircle(center: c, radius: r),
      Paint()
        ..shader = RadialGradient(
          center: Alignment((light.dx - c.dx) / r, (light.dy - c.dy) / r),
          radius: 1.15,
          colors: [
            Color.lerp(
                palette.surfaceElevated, Colors.white, 0.30 + 0.24 * progress)!,
            palette.surface,
            palette.deepest,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // Ombra interna sul bordo, per dare volume di sfera piena.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
              palette.deepest.withValues(alpha: 0.85),
            ],
            stops: const [0.0, 0.72, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: r)));

    // Fumo volumetrico che vortica a piu' livelli e si dirada col soffio.
    final fog = (0.9 - 0.85 * progress).clamp(0.0, 0.9);
    for (var layer = 0; layer < 3; layer++) {
      final speed = 1.0 + layer * 0.6 + 0.8 * level;
      final swirl = t * 2 * math.pi * speed + layer * 1.7;
      final blobs = 5 + layer;
      for (var i = 0; i < blobs; i++) {
        final a = swirl + i * (2 * math.pi / blobs);
        final rad = r *
            (0.10 + 0.30 * (i / blobs) + 0.08 * layer) *
            (1 + 0.7 * progress);
        final fp = c +
            Offset(math.cos(a) * rad, math.sin(a * 0.9 + layer) * rad * 0.88);
        final blobR = r *
            (0.42 - 0.14 * (i / blobs) - 0.05 * layer) *
            (1 + 0.2 * math.sin(a));
        canvas.drawCircle(
            fp,
            blobR.clamp(2.0, r),
            Paint()
              ..color = Color.lerp(Colors.white, palette.goldSoft, 0.35)!
                  .withValues(
                      alpha: fog * (0.16 - 0.02 * layer).clamp(0.02, 0.16))
              ..maskFilter =
                  MaskFilter.blur(BlurStyle.normal, 16 - layer * 2.0));
      }
    }

    // Caustiche: due archi luminosi rifratti nella meta' bassa.
    for (var i = 0; i < 2; i++) {
      final rr = r * (0.55 + 0.18 * i);
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: rr),
          0.85 + 0.1 * math.sin(t * 2 * math.pi),
          1.1,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = Colors.white.withValues(alpha: 0.14 * (1 - progress))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));
    }

    // Alta luce speculare morbida piu' hotspot nitido.
    canvas.drawCircle(
        light,
        r * 0.22,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.drawCircle(light + Offset(r * 0.02, r * 0.02), r * 0.07,
        Paint()..color = Colors.white.withValues(alpha: 0.95));

    // Riflesso di finestra.
    final winC = light + Offset(r * 0.10, r * 0.16);
    canvas.save();
    canvas.translate(winC.dx, winC.dy);
    canvas.rotate(-0.35);
    final winPaint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: r * 0.16, height: r * 0.30),
            const Radius.circular(4)),
        winPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(r * 0.16, 0), width: r * 0.09, height: r * 0.26),
            const Radius.circular(3)),
        Paint()..color = Colors.white.withValues(alpha: 0.18));
    canvas.restore();

    // Luce riflessa in basso a destra (rim light).
    canvas.drawCircle(
        c + Offset(r * 0.34, r * 0.42),
        r * 0.30,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    canvas.restore();

    // Bordo del vetro: doppio anello, luce in alto a sinistra e ombra opposta.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = palette.gold.withValues(alpha: 0.7));
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.985),
        math.pi * 0.9,
        math.pi * 0.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..color = Colors.white.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.98),
        0.3,
        1.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..color = palette.goldSoft.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  // Piedistallo dorato cesellato con materia metallica.
  void _pedestal(Canvas canvas, Size size,
      {required Offset sphere, required double r}) {
    final cx = sphere.dx;
    final cradleY = sphere.dy + r * 0.72;
    final baseY = size.height * 0.95;

    // Banda metallica riflettente: chiaro, oro, scuro, oro (finta riflessione).
    Shader metal(Rect rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(palette.goldSoft, Colors.white, 0.5)!,
            palette.gold,
            Color.lerp(palette.gold, Colors.black, 0.55)!,
            palette.gold,
          ],
          stops: const [0.0, 0.35, 0.72, 1.0],
        ).createShader(rect);

    // Ombra a terra.
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, baseY + 5), width: r * 2.0, height: r * 0.34),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11));

    // Base larga a piu' gradini.
    final baseRect = Rect.fromCenter(
        center: Offset(cx, baseY), width: r * 1.55, height: r * 0.42);
    canvas.drawOval(baseRect, Paint()..shader = metal(baseRect));
    canvas.drawArc(
        baseRect,
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    final base2 = Rect.fromCenter(
        center: Offset(cx, baseY - r * 0.16),
        width: r * 1.28,
        height: r * 0.30);
    canvas.drawOval(base2, Paint()..shader = metal(base2));

    // Stelo a calice.
    final stemRect = Rect.fromLTRB(cx - r * 0.6, cradleY, cx + r * 0.6, baseY);
    final stem = Path()
      ..moveTo(cx - r * 0.30, cradleY + r * 0.02)
      ..cubicTo(cx - r * 0.16, cradleY + r * 0.45, cx - r * 0.34,
          baseY - r * 0.32, cx - r * 0.55, baseY - r * 0.06)
      ..lineTo(cx + r * 0.55, baseY - r * 0.06)
      ..cubicTo(cx + r * 0.34, baseY - r * 0.32, cx + r * 0.16,
          cradleY + r * 0.45, cx + r * 0.30, cradleY + r * 0.02)
      ..close();
    canvas.drawPath(stem, Paint()..shader = metal(stemRect));
    // Alta luce verticale sullo stelo.
    canvas.drawLine(
        Offset(cx - r * 0.16, cradleY + r * 0.10),
        Offset(cx - r * 0.28, baseY - r * 0.12),
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(palette.goldSoft, Colors.white, 0.5)!
              .withValues(alpha: 0.6));

    // Nodo ornamentale sferico con alta luce.
    final knot = Offset(cx, (cradleY + baseY) / 2 + r * 0.05);
    canvas.drawCircle(
        knot,
        r * 0.15,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            colors: [
              Color.lerp(palette.goldSoft, Colors.white, 0.6)!,
              palette.gold,
              Color.lerp(palette.gold, Colors.black, 0.5)!,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: knot, radius: r * 0.15)));

    // Culla ad artigli che avvolge la base della sfera.
    for (var i = -1; i <= 1; i++) {
      final startX = cx + i * r * 0.5;
      final claw = Path()
        ..moveTo(startX, cradleY - r * 0.22)
        ..quadraticBezierTo(startX + i * r * 0.10, cradleY + r * 0.12,
            cx + i * r * 0.20, cradleY + r * 0.18);
      canvas.drawPath(
          claw,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..color = palette.gold);
      canvas.drawPath(
          claw,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round
            ..color = Color.lerp(palette.goldSoft, Colors.white, 0.5)!
                .withValues(alpha: 0.5));
    }
    final cradleRect = Rect.fromCenter(
        center: Offset(cx, cradleY), width: r * 1.2, height: r * 0.5);
    canvas.drawArc(
        cradleRect,
        0.12 * math.pi,
        0.76 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = palette.gold);
    canvas.drawArc(
        cradleRect,
        0.12 * math.pi,
        0.76 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(palette.goldSoft, Colors.white, 0.5)!
              .withValues(alpha: 0.55));
  }

  // ==================== Caligo: candela ====================
  void _candle(Canvas canvas, Size size) {
    final w = size.width;
    final cx = size.width / 2;
    final bodyTop = size.height * 0.50;
    final bodyBottom = size.height * 0.94;
    final bodyW = w * 0.26;
    const wax = Color(0xFFF3E4C4);
    const waxWarm = Color(0xFFE9B98C);

    final alive = (1 - progress).clamp(0.0, 1.0);
    final wickTop = bodyTop - w * 0.05;
    final flameH =
        w * 0.42 * alive * (1 + 0.14 * math.sin(t * 2 * math.pi * 5));

    // Pozza di luce calda alla base.
    canvas.drawCircle(
        Offset(cx, bodyBottom),
        bodyW * 2.1,
        Paint()
          ..color =
              const Color(0xFFE0733A).withValues(alpha: 0.10 + 0.14 * alive)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26));

    // Corpo della candela: cera translucida (gradiente verticale caldo + volume
    // laterale).
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx - bodyW / 2, bodyTop, cx + bodyW / 2, bodyBottom),
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(waxWarm, Colors.black, 0.35)!,
            wax,
            Color.lerp(waxWarm, Colors.black, 0.45)!,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(bodyRect.outerRect),
    );
    // Bagliore caldo che traslucida dall'alto (dove la fiamma scalda la cera).
    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(
        bodyRect.outerRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFB055).withValues(alpha: 0.5 * alive),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4],
          ).createShader(bodyRect.outerRect));
    canvas.restore();

    // Cera che cola su un lato.
    for (final drip in [
      [cx - bodyW * 0.34, bodyTop + w * 0.02, w * 0.09],
      [cx + bodyW * 0.28, bodyTop + w * 0.06, w * 0.13],
    ]) {
      final dx = drip[0], dy = drip[1], len = drip[2];
      final p = Path()
        ..moveTo(dx - w * 0.02, dy)
        ..quadraticBezierTo(dx - w * 0.03, dy + len * 0.6, dx, dy + len)
        ..quadraticBezierTo(dx + w * 0.03, dy + len * 0.6, dx + w * 0.02, dy)
        ..close();
      canvas.drawPath(p, Paint()..color = wax.withValues(alpha: 0.9));
      canvas.drawCircle(Offset(dx, dy + len), w * 0.022, Paint()..color = wax);
    }

    // Bordo superiore fuso (coppa di cera) con alta luce.
    final topRim = Rect.fromCenter(
        center: Offset(cx, bodyTop), width: bodyW, height: bodyW * 0.30);
    canvas.drawOval(
        topRim, Paint()..color = Color.lerp(wax, Colors.white, 0.25)!);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, bodyTop - bodyW * 0.02),
            width: bodyW * 0.7,
            height: bodyW * 0.16),
        Paint()..color = Color.lerp(waxWarm, Colors.black, 0.3)!);

    // Stoppino con brace alla base.
    canvas.drawLine(
        Offset(cx, bodyTop - w * 0.005),
        Offset(cx, wickTop),
        Paint()
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF2A1A12));

    if (alive > 0.02) {
      final lean = level * w * 0.16 * math.sin(t * 40);
      final baseP = Offset(cx, wickTop);
      final tip = Offset(cx + lean, wickTop - flameH);

      // Alone caldo ampio.
      canvas.drawCircle(
          Offset(cx, wickTop - flameH * 0.45),
          flameH * (1.1 + 0.5 * level),
          Paint()
            ..color = const Color(0xFFFFB055).withValues(alpha: 0.34 * alive)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 12 * level));

      Path flame(double scale, Offset tp, double wScale) => Path()
        ..moveTo(baseP.dx - w * 0.085 * wScale, baseP.dy)
        ..quadraticBezierTo(baseP.dx - w * 0.10 * wScale,
            (baseP.dy + tp.dy) * 0.5, tp.dx, tp.dy)
        ..quadraticBezierTo(baseP.dx + w * 0.10 * wScale,
            (baseP.dy + tp.dy) * 0.5, baseP.dx + w * 0.085 * wScale, baseP.dy)
        ..close();

      // Strato esterno arancio.
      canvas.drawPath(flame(1.0, tip, 1.0),
          Paint()..color = const Color(0xFFE0561F).withValues(alpha: alive));
      // Strato medio ambra.
      canvas.drawPath(flame(0.72, Offset(tip.dx, tip.dy + flameH * 0.22), 0.72),
          Paint()..color = const Color(0xFFFFC24D).withValues(alpha: alive));
      // Nucleo bianco caldo.
      canvas.drawPath(
          flame(0.4, Offset(tip.dx, tip.dy + flameH * 0.42), 0.42),
          Paint()
            ..color = const Color(0xFFFFF6E0).withValues(alpha: 0.95 * alive)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
      // Base bluastra della combustione.
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, wickTop - flameH * 0.06),
              width: w * 0.10,
              height: flameH * 0.22),
          Paint()
            ..color = const Color(0xFF6FA8FF).withValues(alpha: 0.5 * alive)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    } else {
      // Fumo reale che sale, si allarga e sfuma.
      for (var s = 0; s < 2; s++) {
        final path = Path()..moveTo(cx, wickTop);
        for (var k = 1; k <= 10; k++) {
          final yy = wickTop - k * w * 0.05;
          final xx = cx +
              math.sin(t * 2 * math.pi + k * 0.6 + s * 1.5) *
                  w *
                  (0.02 + 0.006 * k);
          path.lineTo(xx, yy);
        }
        canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5 + s * 2
              ..strokeCap = StrokeCap.round
              ..color = Colors.white.withValues(alpha: 0.16 - s * 0.06)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + s * 2));
      }
    }
  }

  // ==================== Aura: dente di leone ====================
  void _dandelion(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.46, size.height * 0.40);
    final headR = w * 0.35;
    const total = 84;
    final remaining = (total * (1 - progress)).round();

    // Luce che filtra da dietro la testa.
    canvas.drawCircle(
        c,
        headR * 1.15,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));
    // Morbido nucleo di lanugine (fa da base soffice sotto i pappi).
    canvas.drawCircle(
        c,
        headR * 0.82,
        Paint()
          ..color = Color.lerp(Colors.white, palette.goldSoft, 0.5)!
              .withValues(alpha: 0.10 * (1 - progress))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));

    // Stelo curvo con fogliolina.
    final stem = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + w * 0.11, size.height * 0.72, c.dx + w * 0.02,
          size.height * 0.965);
    canvas.drawPath(
        stem,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7CB98A),
              Color(0xFF3F7A54),
            ],
          ).createShader(
              Rect.fromLTWH(c.dx, c.dy, w * 0.2, size.height * 0.55)));
    final leaf = Path()
      ..moveTo(c.dx + w * 0.07, size.height * 0.74)
      ..quadraticBezierTo(c.dx + w * 0.24, size.height * 0.70, c.dx + w * 0.17,
          size.height * 0.83)
      ..quadraticBezierTo(c.dx + w * 0.10, size.height * 0.80, c.dx + w * 0.07,
          size.height * 0.74);
    canvas.drawPath(
        leaf,
        Paint()
          ..shader = const LinearGradient(colors: [
            Color(0xFF6BA878),
            Color(0xFF3F7A54),
          ]).createShader(Rect.fromLTWH(
              c.dx + w * 0.07, size.height * 0.70, w * 0.18, w * 0.15)));

    final rng = math.Random(11);
    // Prima passata: gambi sottili di tutti i filamenti ancora attaccati.
    for (var i = 0; i < total; i++) {
      final ang = (i / total) * 2 * math.pi + rng.nextDouble() * 0.10;
      final len = headR * (0.80 + rng.nextDouble() * 0.20);
      final sway = math.sin(t * 2 * math.pi + i) * 0.045 * (0.4 + level);
      final a = ang + sway;
      if (i < remaining) {
        final end = c + Offset(math.cos(a), math.sin(a)) * len;
        canvas.drawLine(
            c,
            end,
            Paint()
              ..strokeWidth = 0.7
              ..color = palette.goldSoft.withValues(alpha: 0.42));
        _pappus(canvas, end, a, palette.goldSoft, 1.0);
      } else {
        // Seme che si stacca, volteggia e sfuma nel vento.
        final fly = (progress - (total - i) / total).clamp(0.0, 1.0);
        final spin = a + fly * 6;
        final drift = c +
            Offset(math.cos(a), math.sin(a)) * len +
            Offset(math.cos(a) * fly * w * 0.5 + fly * w * 0.28,
                -fly * size.height * 0.42 + math.sin(fly * 8) * w * 0.05);
        _seed(canvas, drift, spin, (1 - fly).clamp(0.0, 1.0), palette.goldSoft);
      }
    }

    // Ricettacolo centrale con piccola texture.
    canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(c, 5, Paint()..color = palette.gold);
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * 2 * math.pi;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * 4.5, 0.9,
          Paint()..color = Color.lerp(palette.gold, Colors.black, 0.4)!);
    }
  }

  // Un pappo soffice: piccola raggiera di peli sottili, con un velo morbido.
  void _pappus(Canvas canvas, Offset p, double a, Color color, double alpha) {
    // Velo morbido per la sensazione lanuginosa.
    canvas.drawCircle(
        p,
        6.5,
        Paint()
          ..color = color.withValues(alpha: 0.14 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    final paint = Paint()
      ..strokeWidth = 0.55
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.7 * alpha);
    for (var k = 0; k < 9; k++) {
      final aa = a + (k - 4) * 0.16;
      final l = 6.5 + (k.isEven ? 1.2 : 0);
      canvas.drawLine(p, p + Offset(math.cos(aa), math.sin(aa)) * l, paint);
    }
  }

  // Un seme volante: achenio con il suo pappo, in dissolvenza.
  void _seed(Canvas canvas, Offset p, double a, double alpha, Color color) {
    if (alpha <= 0.02) return;
    // Achenio.
    final seedEnd = p + Offset(math.cos(a), math.sin(a)) * 6;
    canvas.drawLine(
        p,
        seedEnd,
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(color, const Color(0xFF8A6B3A), 0.5)!
              .withValues(alpha: 0.8 * alpha));
    _pappus(canvas, p, a + math.pi, color, alpha);
  }

  @override
  bool shouldRepaint(_RitualPainter old) => true;
}
