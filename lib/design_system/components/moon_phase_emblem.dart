import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/celestial.dart';
import 'luna_reale.dart';

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
    // La forma viene da `LunaReale`, la sola del progetto. Qui c'era una
    // seconda geometria, con mezzo disco e un contorno netto: e' quella che
    // disegnava una meta' esatta sotto la parola "crescente".
    LunaReale.dipingi(
      canvas,
      c,
      size.width * 0.34 * breathe,
      illuminazione: phase.fraction,
      crescente: phase.waxing,
    );
  }

  @override
  bool shouldRepaint(_MoonEmblemPainter old) => old.t != t;
}
