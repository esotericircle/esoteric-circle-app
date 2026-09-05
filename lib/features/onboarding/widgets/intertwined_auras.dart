import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tre aure intrecciate che respirano e si sfiorano, emblema del colpo d'occhio
/// della carta (Sole, Luna, Ascendente). Ogni aura ruota attorno al centro con
/// il proprio ritmo e si fonde con le altre.
class IntertwinedAuras extends StatefulWidget {
  const IntertwinedAuras({
    super.key,
    required this.colors,
    this.size = 180,
  });

  /// Colori delle aure (Sole, Luna e, se presente, Ascendente).
  final List<Color> colors;
  final double size;

  @override
  State<IntertwinedAuras> createState() => _IntertwinedAurasState();
}

class _IntertwinedAurasState extends State<IntertwinedAuras>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
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
          painter: _AuraPainter(colors: widget.colors, t: _c.value),
        ),
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({required this.colors, required this.t});

  final List<Color> colors;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final orbit = size.width * 0.22;
    final rBlob = size.width * 0.27;
    final n = colors.length;
    for (var i = 0; i < n; i++) {
      final ph = t * 2 * math.pi + i * (2 * math.pi / n);
      final breathe = 1 + 0.12 * math.sin(ph * 1.3);
      final pos = c + Offset(math.cos(ph) * orbit, math.sin(ph) * orbit * 0.85);
      canvas.drawCircle(
        pos,
        rBlob * breathe,
        Paint()
          ..color = colors[i].withValues(alpha: 0.42)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26)
          ..blendMode = BlendMode.plus,
      );
    }
    // Nucleo dorato dove le aure si intrecciano.
    canvas.drawCircle(
        c,
        size.width * 0.06,
        Paint()
          ..color = const Color(0xFFF0D77B).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  @override
  bool shouldRepaint(_AuraPainter old) => true;
}
