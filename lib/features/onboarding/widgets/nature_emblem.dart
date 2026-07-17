import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/astro/natal_poetics.dart';
import '../../../core/astro/zodiac.dart';

/// Emblema vivo diverso per la natura di ciascun pianeta: una fiammella per il
/// fuoco, una fronda per la terra, una brezza per l'aria, una goccia per
/// l'acqua. La dignita' e' resa come orbe piu' o meno luminoso, la
/// retrogradazione come una spirale inversa sovrapposta.
///
/// Nessun emblema e' uguale a un altro: e' il principio del segno grafico a
/// tema, mai lo stesso due volte.
class NatureEmblem extends StatefulWidget {
  const NatureEmblem({
    super.key,
    required this.element,
    required this.dignity,
    required this.retrograde,
    this.size = 40,
  });

  final ZodiacElement element;
  final Dignity dignity;
  final bool retrograde;
  final double size;

  @override
  State<NatureEmblem> createState() => _NatureEmblemState();
}

class _NatureEmblemState extends State<NatureEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))
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
          painter: _EmblemPainter(
            element: widget.element,
            dignity: widget.dignity,
            retrograde: widget.retrograde,
            t: _c.value,
          ),
        ),
      ),
    );
  }
}

const _elementColor = {
  ZodiacElement.fire: Color(0xFFE0733A),
  ZodiacElement.earth: Color(0xFF5F9E6E),
  ZodiacElement.air: Color(0xFF8FB8EC),
  ZodiacElement.water: Color(0xFF49B7B0),
};

class _EmblemPainter extends CustomPainter {
  _EmblemPainter({
    required this.element,
    required this.dignity,
    required this.retrograde,
    required this.t,
  });

  final ZodiacElement element;
  final Dignity dignity;
  final bool retrograde;
  final double t;

  double get _dignityGlow => switch (dignity) {
        Dignity.strong => 0.55,
        Dignity.neutral => 0.28,
        Dignity.weak => 0.12,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.42;
    final color = _elementColor[element]!;

    // Orbe di dignita' dietro l'emblema.
    canvas.drawCircle(
        c,
        r * (1.1 + 0.08 * math.sin(t * 2 * math.pi)),
        Paint()
          ..color = color.withValues(alpha: _dignityGlow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.35 + _dignityGlow * 0.5));

    switch (element) {
      case ZodiacElement.fire:
        _flame(canvas, c, r, color);
      case ZodiacElement.earth:
        _frond(canvas, c, r, color);
      case ZodiacElement.air:
        _breeze(canvas, c, r, color);
      case ZodiacElement.water:
        _drop(canvas, c, r, color);
    }

    if (retrograde) _retroSpiral(canvas, c, r);
  }

  void _flame(Canvas canvas, Offset c, double r, Color color) {
    final flick = 1 + 0.12 * math.sin(t * 2 * math.pi * 4);
    final base = c + Offset(0, r * 0.6);
    final tip = c + Offset(math.sin(t * 8) * r * 0.08, -r * 0.7 * flick);
    Path flame(double w, Offset t2) => Path()
      ..moveTo(base.dx - w, base.dy)
      ..quadraticBezierTo(base.dx - w, (base.dy + t2.dy) / 2, t2.dx, t2.dy)
      ..quadraticBezierTo(base.dx + w, (base.dy + t2.dy) / 2, base.dx + w, base.dy)
      ..close();
    canvas.drawPath(flame(r * 0.34, tip), Paint()..color = color);
    canvas.drawPath(flame(r * 0.18, Offset(tip.dx, tip.dy + r * 0.28)),
        Paint()..color = const Color(0xFFFFD86B));
  }

  void _frond(Canvas canvas, Offset c, double r, Color color) {
    final sway = math.sin(t * 2 * math.pi) * 0.12;
    final stem = Path()
      ..moveTo(c.dx, c.dy + r * 0.7)
      ..quadraticBezierTo(c.dx + r * sway, c.dy, c.dx + r * sway, c.dy - r * 0.7);
    canvas.drawPath(
        stem,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color);
    for (var i = -2; i <= 2; i++) {
      final y = c.dy - r * 0.5 + i * r * 0.24;
      final side = i.isEven ? 1 : -1;
      canvas.drawLine(
          Offset(c.dx + r * sway, y),
          Offset(c.dx + r * sway + side * r * 0.4, y - r * 0.14),
          Paint()
            ..strokeWidth = 1.1
            ..color = color.withValues(alpha: 0.9));
    }
  }

  void _breeze(Canvas canvas, Offset c, double r, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (var k = 0; k < 3; k++) {
      final yy = c.dy - r * 0.4 + k * r * 0.4;
      final ph = t * 2 * math.pi + k;
      final path = Path()..moveTo(c.dx - r * 0.7, yy);
      for (var x = -0.7; x <= 0.7; x += 0.1) {
        path.lineTo(c.dx + r * x, yy + math.sin(ph + x * 6) * r * 0.12);
      }
      canvas.drawPath(path, paint..color = color.withValues(alpha: 0.5 + 0.4 * (1 - k / 3)));
    }
  }

  void _drop(Canvas canvas, Offset c, double r, Color color) {
    final drop = Path()
      ..moveTo(c.dx, c.dy - r * 0.6)
      ..quadraticBezierTo(c.dx + r * 0.5, c.dy + r * 0.1, c.dx, c.dy + r * 0.55)
      ..quadraticBezierTo(c.dx - r * 0.5, c.dy + r * 0.1, c.dx, c.dy - r * 0.6)
      ..close();
    canvas.drawPath(drop, Paint()..color = color);
    // Increspatura che pulsa.
    final ripple = (t % 1.0);
    canvas.drawCircle(
        c + Offset(0, r * 0.2),
        r * (0.2 + ripple * 0.6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: (1 - ripple) * 0.5));
  }

  void _retroSpiral(Canvas canvas, Offset c, double r) {
    // Spirale inversa (senso antiorario) in alto a destra.
    final center = c + Offset(r * 0.7, -r * 0.7);
    final path = Path();
    for (var a = 0.0; a < math.pi * 3; a += 0.2) {
      final rad = 0.6 + a * 0.7;
      final p = center + Offset(math.cos(-a) * rad, math.sin(-a) * rad);
      if (a == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFE0733A).withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_EmblemPainter old) => true;
}
