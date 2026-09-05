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
  /// A moto fermo NON ESISTE. Prima veniva creato comunque e si ometteva solo
  /// il `repeat`: un controllore che nessuno fa girare e' un ticker registrato
  /// nell'albero, ed e' una promessa mantenuta a meta'. Chi chiede di ridurre
  /// il movimento non chiede un'animazione ferma, chiede che non ce ne sia.
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _c =
          AnimationController(vsync: this, duration: const Duration(seconds: 6))
            ..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vivo = _c;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: vivo == null
          ? CustomPaint(painter: _MoonEmblemPainter(widget.phase, 0))
          : AnimatedBuilder(
              animation: vivo,
              builder: (context, _) => CustomPaint(
                painter: _MoonEmblemPainter(widget.phase, vivo.value),
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
