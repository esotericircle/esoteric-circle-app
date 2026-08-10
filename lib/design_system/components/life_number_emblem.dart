import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/typography_tokens.dart';

/// Emblema vivo del numero della vita: un sigillo geometrico che ruota piano,
/// con tanti vertici quanti il numero suggerisce e la cifra incisa al centro. I
/// numeri maestri (11, 22, 33) hanno un secondo anello controrotante. Emblema
/// originale, distinto da ogni altro segno dell'app.
class LifeNumberEmblem extends StatefulWidget {
  const LifeNumberEmblem({
    super.key,
    required this.number,
    required this.palette,
    this.size = 60,
    this.animate = true,
  });

  final int number;
  final MaestroPalette palette;
  final double size;
  final bool animate;

  @override
  State<LifeNumberEmblem> createState() => _LifeNumberEmblemState();
}

class _LifeNumberEmblemState extends State<LifeNumberEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 26));
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  int get _single =>
      widget.number <= 9 ? widget.number : (widget.number ~/ 10 + widget.number % 10);

  @override
  Widget build(BuildContext context) {
    final vertices = _single < 3 ? _single + 3 : _single;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _SigilPainter(
            t: _c.value,
            vertices: vertices,
            master: widget.number > 9,
            gold: widget.palette.gold,
            goldSoft: widget.palette.goldSoft,
          ),
          child: Center(
            child: Text(
              '${widget.number}',
              // Come nell'avatar: la misura segue l'emblema ma non scende
              // sotto il pavimento dell'app.
              style: TypographyTokens.display(
                      size: math.max(
                          widget.size * 0.32, TypographyTokens.pavimento))
                  .copyWith(color: widget.palette.goldSoft),
            ),
          ),
        ),
      ),
    );
  }
}

class _SigilPainter extends CustomPainter {
  _SigilPainter({
    required this.t,
    required this.vertices,
    required this.master,
    required this.gold,
    required this.goldSoft,
  });

  final double t;
  final int vertices;
  final bool master;
  final Color gold;
  final Color goldSoft;

  Offset _vertex(Offset c, double r, int i, int n, double rot) {
    final a = rot + i * (2 * math.pi / n) - math.pi / 2;
    return c + Offset(math.cos(a), math.sin(a)) * r;
  }

  void _polygon(Canvas canvas, Offset c, double r, int n, double rot,
      Paint stroke, {int step = 1}) {
    if (n < 2) {
      canvas.drawCircle(c, r, stroke);
      return;
    }
    final path = Path();
    var idx = 0;
    for (var k = 0; k <= n; k++) {
      final p = _vertex(c, r, idx % n, n, rot);
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      idx += step;
    }
    canvas.drawPath(path, stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.42;
    final rot = t * 2 * math.pi;

    // Alone tenue.
    canvas.drawCircle(
        c,
        r * 1.05,
        Paint()
          ..color = goldSoft.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Cerchio esterno.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = gold.withValues(alpha: 0.45));

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..color = goldSoft.withValues(alpha: 0.85);

    // Stella se abbastanza vertici, altrimenti poligono.
    final step = vertices >= 5 ? 2 : 1;
    _polygon(canvas, c, r * 0.82, vertices, rot, stroke, step: step);

    // Punte luminose ai vertici.
    for (var i = 0; i < vertices; i++) {
      final p = _vertex(c, r * 0.82, i, vertices, rot);
      canvas.drawCircle(p, 1.6, Paint()..color = goldSoft);
    }

    // Numero maestro: secondo anello controrotante.
    if (master) {
      _polygon(canvas, c, r * 0.5, vertices, -rot * 1.4,
          stroke..color = gold.withValues(alpha: 0.5),
          step: vertices >= 5 ? 2 : 1);
    }
  }

  @override
  bool shouldRepaint(_SigilPainter old) => old.t != t;
}
