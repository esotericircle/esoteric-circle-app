import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

class SkyNode {
  const SkyNode(this.label, this.filled);
  final String label;
  final bool filled;
}

/// Il filo del cielo che si compone mentre l'utente inserisce i dati: una fila
/// di stelle collegate da un filo dorato. Ogni dato inserito accende la stella
/// e allunga il filo, con uno scintillio continuo.
class SkyThread extends StatefulWidget {
  const SkyThread({super.key, required this.nodes});

  final List<SkyNode> nodes;

  @override
  State<SkyThread> createState() => _SkyThreadState();
}

class _SkyThreadState extends State<SkyThread>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final n = widget.nodes.length;
    final filled = widget.nodes.where((x) => x.filled).length;
    // Frazione di filo composto (fino all'ultima stella accesa).
    final target = n <= 1 ? 0.0 : (filled - 1).clamp(0, n - 1) / (n - 1);

    return SizedBox(
      height: 66,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target.toDouble()),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, fill, _) => AnimatedBuilder(
          animation: _shimmer,
          builder: (context, __) => CustomPaint(
            size: Size.infinite,
            painter: _ThreadPainter(
              nodes: widget.nodes,
              fill: fill,
              shimmer: _shimmer.value,
              gold: palette.gold,
              goldSoft: palette.goldSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadPainter extends CustomPainter {
  _ThreadPainter({
    required this.nodes,
    required this.fill,
    required this.shimmer,
    required this.gold,
    required this.goldSoft,
  });

  final List<SkyNode> nodes;
  final double fill;
  final double shimmer;
  final Color gold;
  final Color goldSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final n = nodes.length;
    if (n == 0) return;
    const marginX = 26.0;
    const baseY = 26.0;
    const arc = 12.0;
    final span = size.width - marginX * 2;
    // I nodi stanno su un arco morbido: da uniti formano una piccola
    // costellazione, non una riga.
    Offset nodeAt(int i) {
      final f = n == 1 ? 0.0 : i / (n - 1);
      final y = baseY - math.sin(f * math.pi) * arc;
      return Offset(marginX + span * f, y);
    }

    // Filo di fondo lungo l'arco.
    final bgPath = Path()..moveTo(nodeAt(0).dx, nodeAt(0).dy);
    for (var i = 1; i < n; i++) {
      bgPath.lineTo(nodeAt(i).dx, nodeAt(i).dy);
    }
    canvas.drawPath(
        bgPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = gold.withValues(alpha: 0.18));

    // Filo composto fino alla frazione raggiunta.
    final litSegments = (fill * (n - 1));
    final litPath = Path()..moveTo(nodeAt(0).dx, nodeAt(0).dy);
    for (var i = 1; i < n; i++) {
      final seg = (litSegments - (i - 1)).clamp(0.0, 1.0);
      if (seg <= 0) break;
      final a = nodeAt(i - 1);
      final b = nodeAt(i);
      litPath.lineTo(a.dx + (b.dx - a.dx) * seg, a.dy + (b.dy - a.dy) * seg);
    }
    canvas.drawPath(
        litPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = goldSoft.withValues(alpha: 0.85));

    // Costellazione personale: da tutte accese, un satellite chiude la figura.
    final allFilled = nodes.every((x) => x.filled);
    if (allFilled && n >= 2) {
      final sat = Offset((nodeAt(0).dx + nodeAt(n - 1).dx) / 2, baseY + 12);
      canvas.drawLine(nodeAt(0), sat,
          Paint()..strokeWidth = 1..color = goldSoft.withValues(alpha: 0.4));
      canvas.drawLine(nodeAt(n - 1), sat,
          Paint()..strokeWidth = 1..color = goldSoft.withValues(alpha: 0.4));
      final twk = 0.5 + 0.5 * math.sin(2 * math.pi * shimmer);
      _star(canvas, sat, 3.5, goldSoft.withValues(alpha: 0.6 + 0.4 * twk));
    }

    for (var i = 0; i < n; i++) {
      final node = nodes[i];
      final p = nodeAt(i);
      final shimmerPulse =
          0.5 + 0.5 * math.sin(2 * math.pi * (shimmer + i / n));
      if (node.filled) {
        canvas.drawCircle(
            p,
            8 + shimmerPulse * 3,
            Paint()
              ..color = goldSoft.withValues(alpha: 0.25 * shimmerPulse)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        _star(canvas, p, 5.5, goldSoft.withValues(alpha: 0.95));
      } else {
        canvas.drawCircle(p, 3,
            Paint()..color = gold.withValues(alpha: 0.35));
      }
      _label(canvas, node.label, Offset(p.dx, baseY + 22),
          color: node.filled
              ? goldSoft.withValues(alpha: 0.9)
              : ColorTokens.textMuted);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var k = 0; k < 8; k++) {
      final ang = k * math.pi / 4;
      final rad = k.isEven ? r : r * 0.42;
      final p = c + Offset(math.cos(ang) * rad, math.sin(ang) * rad);
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _label(Canvas canvas, String s, Offset center, {required Color color}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s.toUpperCase(),
          style: TypographyTokens.body(size: 9)
              .copyWith(color: color, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(_ThreadPainter old) => true;
}
