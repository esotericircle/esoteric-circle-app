import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/zodiac.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';

/// La ruota natale 2.5D che si costruisce con un'animazione: prima l'anello
/// dei dodici segni, poi i pianeti che si posizionano.
///
/// I segni e i pianeti sono etichettati con brevi sigle italiane, cosi' restano
/// leggibili con i font del bundle (i glifi astronomici arriveranno con un font
/// simbolico dedicato).
class NatalWheel extends StatefulWidget {
  const NatalWheel({super.key, required this.chart, this.size = 300});

  final NatalChart chart;
  final double size;

  @override
  State<NatalWheel> createState() => _NatalWheelState();
}

class _NatalWheelState extends State<NatalWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _NatalWheelPainter(
            progress: _controller.value,
            chart: widget.chart,
            palette: palette,
          ),
        ),
      ),
    );
  }
}

class _NatalWheelPainter extends CustomPainter {
  _NatalWheelPainter({
    required this.progress,
    required this.chart,
    required this.palette,
  });

  final double progress;
  final NatalChart chart;
  final MaestroPalette palette;

  static const _signShort = [
    'Ari', 'Tor', 'Gem', 'Can', 'Leo', 'Ver',
    'Bil', 'Sco', 'Sag', 'Cap', 'Acq', 'Pes',
  ];

  double _angle(double lon) => (lon - 90) * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final ringT = Curves.easeOut.transform((progress / 0.55).clamp(0.0, 1.0));
    final planetsBase = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);

    _paintRing(canvas, center, r, ringT);
    _paintAscendant(canvas, center, r, ringT);
    _paintPlanets(canvas, center, r, planetsBase);
    _paintCenter(canvas, center, ringT);
  }

  void _paintRing(Canvas canvas, Offset center, double r, double t) {
    if (t <= 0) return;
    final rInner = r * 0.74;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = palette.gold.withValues(alpha: 0.7 * t);
    canvas.drawCircle(center, r, ring);
    canvas.drawCircle(center, rInner, ring..color = palette.gold.withValues(alpha: 0.35 * t));

    // Divisori dei dodici settori e sigle dei segni.
    for (var i = 0; i < 12; i++) {
      final a = _angle(i * 30.0);
      final p1 = center + Offset(math.cos(a), math.sin(a)) * rInner;
      final p2 = center + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: 0.3 * t),
      );

      final mid = _angle(i * 30.0 + 15);
      final labelPos = center + Offset(math.cos(mid), math.sin(mid)) * (r * 0.87);
      final isSun = Zodiac.values[i] == chart.sunSign;
      _text(
        canvas,
        _signShort[i],
        labelPos,
        color: (isSun ? palette.goldSoft : palette.gold)
            .withValues(alpha: (isSun ? 0.95 : 0.7) * t),
        size: 10.5,
        weight: isSun ? 700 : 500,
      );
    }
  }

  void _paintAscendant(Canvas canvas, Offset center, double r, double t) {
    final asc = chart.ascendant;
    if (asc == null || t <= 0) return;
    final startLon = Zodiac.values.indexOf(asc) * 30.0;
    final a = _angle(startLon);
    final tip = center + Offset(math.cos(a), math.sin(a)) * (r * 0.74);
    final base1 = center + Offset(math.cos(a + 0.05), math.sin(a + 0.05)) * (r * 0.86);
    final base2 = center + Offset(math.cos(a - 0.05), math.sin(a - 0.05)) * (r * 0.86);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base1.dx, base1.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = palette.goldSoft.withValues(alpha: 0.9 * t),
    );
    final labelPos = center + Offset(math.cos(a), math.sin(a)) * (r * 0.62);
    _text(canvas, 'ASC', labelPos,
        color: palette.goldSoft.withValues(alpha: 0.9 * t), size: 9, weight: 700);
  }

  void _paintPlanets(Canvas canvas, Offset center, double r, double base) {
    if (base <= 0) return;
    final planets = chart.planets;
    for (var i = 0; i < planets.length; i++) {
      // Rivelazione scaglionata pianeta per pianeta.
      final t = ((base * planets.length) - i).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final p = planets[i];
      final a = _angle(p.longitude);
      final pos = center + Offset(math.cos(a), math.sin(a)) * (r * 0.52);

      canvas.drawCircle(
        pos,
        7 * t,
        Paint()
          ..color = palette.glow.withValues(alpha: 0.25 * t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        pos,
        3.2 * t,
        Paint()..color = palette.goldSoft.withValues(alpha: t),
      );
      final abbr = p.name.length >= 2 ? p.name.substring(0, 2) : p.name;
      _text(
        canvas,
        abbr,
        pos + const Offset(0, -13),
        color: palette.textPrimary.withValues(alpha: t),
        size: 9.5,
        weight: 600,
      );
    }
  }

  void _paintCenter(Canvas canvas, Offset center, double t) {
    if (t <= 0) return;
    canvas.drawCircle(
      center,
      3.5,
      Paint()..color = palette.gold.withValues(alpha: 0.8 * t),
    );
  }

  void _text(Canvas canvas, String s, Offset pos,
      {required Color color, required double size, double weight = 500}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
          fontFamily: 'EBGaramond',
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_NatalWheelPainter old) =>
      old.progress != progress ||
      old.chart != chart ||
      old.palette != palette;
}
