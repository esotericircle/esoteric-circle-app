import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/celestial.dart';

/// Renderer condiviso della Luna in una data fase, riusato dal cielo reale della
/// nascita e dagli emblemi identitari (carta e profilo). Disegna alone, disco in
/// ombra, parte illuminata con terminatore ed un bordo tenue.
void paintMoonPhase(
  Canvas canvas,
  Offset c,
  double r, {
  required double fraction,
  required bool waxing,
  bool glow = true,
}) {
  const bright = Color(0xFFF3ECD6);
  const dark = Color(0xFF20242E);

  if (glow) {
    canvas.drawCircle(
        c,
        r * 2.2,
        Paint()
          ..color = bright.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
  }
  canvas.drawCircle(c, r, Paint()..color = dark);

  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
  final litLeft = !waxing;
  final half = litLeft
      ? Rect.fromLTRB(c.dx - r, c.dy - r, c.dx, c.dy + r)
      : Rect.fromLTRB(c.dx, c.dy - r, c.dx + r, c.dy + r);
  canvas.drawRect(half, Paint()..color = bright);
  final rx = (r * (1 - 2 * fraction)).abs();
  if (rx > 0.5) {
    final term = Rect.fromCenter(center: c, width: 2 * rx, height: 2 * r);
    canvas.drawOval(term, Paint()..color = fraction < 0.5 ? dark : bright);
  }
  canvas.restore();

  canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = bright.withValues(alpha: 0.35));
}

/// Emblema vivo della fase lunare, con un alone che respira lievemente.
class MoonPhaseEmblem extends StatefulWidget {
  const MoonPhaseEmblem({
    super.key,
    required this.phase,
    this.size = 56,
    this.animate = true,
  });

  final MoonIllumination phase;
  final double size;
  final bool animate;

  @override
  State<MoonPhaseEmblem> createState() => _MoonPhaseEmblemState();
}

class _MoonPhaseEmblemState extends State<MoonPhaseEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 6));
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _MoonEmblemPainter(widget.phase, _c.value),
        ),
      ),
    );
  }
}

class _MoonEmblemPainter extends CustomPainter {
  _MoonEmblemPainter(this.phase, this.t);
  final MoonIllumination phase;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final breathe = 1 + 0.05 * math.sin(t * 2 * math.pi);
    paintMoonPhase(canvas, c, size.width * 0.34 * breathe,
        fraction: phase.fraction, waxing: phase.waxing);
  }

  @override
  bool shouldRepaint(_MoonEmblemPainter old) => old.t != t;
}
