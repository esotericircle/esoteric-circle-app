import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/zodiac.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';

/// Ruota natale 2.5D ricca e ornata, che si costruisce con un'animazione.
///
/// Comprende la fascia zodiacale con i glifi dei segni, le tacche dei gradi,
/// le cuspidi delle case, i pianeti con i loro glifi (e il segno di
/// retrogradazione), le linee degli aspetti colorate per natura, gli angoli
/// Ascendente e Medio Cielo. La costruzione anima l'ingresso pianeta per
/// pianeta con un bagliore, con profondita' e luce.
class NatalWheel extends StatefulWidget {
  const NatalWheel({super.key, required this.chart, this.size = 320});

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
      duration: const Duration(milliseconds: 3600),
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
          painter: _WheelPainter(
            progress: Curves.easeOut.transform(_controller.value),
            chart: widget.chart,
            palette: palette,
          ),
        ),
      ),
    );
  }
}

const _elementColor = {
  ZodiacElement.fire: Color(0xFFE0733A),
  ZodiacElement.earth: Color(0xFF5F9E6E),
  ZodiacElement.air: Color(0xFF6FA8E0),
  ZodiacElement.water: Color(0xFF49B7B0),
};

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.progress,
    required this.chart,
    required this.palette,
  });

  final double progress;
  final NatalChart chart;
  final MaestroPalette palette;

  double get _ascLon => chart.orientationLongitude;

  // Ascendente a sinistra, zodiaco antiorario (convenzione dei temi natali).
  Offset _u(double lon) {
    final a = (180.0 + (lon - _ascLon)) * math.pi / 180;
    return Offset(math.cos(a), -math.sin(a));
  }

  double _t(double from, double span) =>
      ((progress - from) / span).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final rBandOut = r;
    final rBandIn = r * 0.80;
    final rHouse = r * 0.5;
    final rPlanet = r * 0.66;
    final rAspect = r * 0.46;

    final tBand = _t(0.0, 0.32);
    final tHouse = _t(0.22, 0.28);
    final tPlanetBase = _t(0.4, 0.5);
    final tAspect = _t(0.78, 0.22);

    _paintZodiacBand(canvas, center, rBandOut, rBandIn, tBand);
    _paintDegreeTicks(canvas, center, rBandIn, tBand);
    if (chart.hasTime) {
      _paintHouses(canvas, center, rBandIn, rHouse, tHouse);
      _paintAngles(canvas, center, rBandIn, tHouse);
    }
    _paintAspects(canvas, center, rAspect, tAspect);
    _paintPlanets(canvas, center, rPlanet, rAspect, tPlanetBase);

    // Mozzo centrale luminoso.
    if (tBand > 0) {
      canvas.drawCircle(
          center,
          rAspect * 0.14,
          Paint()
            ..color = palette.glow.withValues(alpha: 0.25 * tBand)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(center, 2.6,
          Paint()..color = palette.goldSoft.withValues(alpha: 0.9 * tBand));
    }
  }

  void _paintZodiacBand(
      Canvas canvas, Offset c, double rOut, double rIn, double t) {
    if (t <= 0) return;
    final gold = palette.gold.withValues(alpha: 0.75 * t);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = gold;
    canvas.drawCircle(c, rOut, ring);
    canvas.drawCircle(c, rIn, ring..color = palette.gold.withValues(alpha: 0.5 * t));

    final rGlyph = (rOut + rIn) / 2;
    for (var i = 0; i < 12; i++) {
      final z = Zodiac.values[i];
      final startLon = i * 30.0;

      // Settore tinto con l'elemento (molto tenue).
      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (rOut - rIn)
        ..color = _elementColor[z.element]!.withValues(alpha: 0.14 * t);
      final rect = Rect.fromCircle(center: c, radius: rGlyph);
      final a0 = _bandAngle(startLon);
      canvas.drawArc(rect, a0, -30 * math.pi / 180, false, sweepPaint);

      // Divisore del settore.
      final dv = _u(startLon);
      canvas.drawLine(c + dv * rIn, c + dv * rOut,
          Paint()..strokeWidth = 0.8..color = palette.gold.withValues(alpha: 0.35 * t));

      // Glifo del segno.
      final mid = _u(startLon + 15);
      _glyph(canvas, z.symbol, c + mid * rGlyph,
          color: palette.goldSoft.withValues(alpha: 0.92 * t),
          size: rOut * 0.11, family: 'NotoSansSymbols');
    }
  }

  // Angolo di partenza dell'arco (in radianti, sistema canvas) per un settore.
  double _bandAngle(double lon) {
    final u = _u(lon);
    return math.atan2(u.dy, u.dx);
  }

  void _paintDegreeTicks(Canvas canvas, Offset c, double rIn, double t) {
    if (t <= 0) return;
    for (var deg = 0; deg < 360; deg += 1) {
      final u = _u(deg.toDouble());
      final bool major = deg % 10 == 0;
      final bool medium = deg % 5 == 0;
      final len = major ? 8.0 : (medium ? 5.0 : 2.5);
      final alpha = (major ? 0.5 : (medium ? 0.35 : 0.2)) * t;
      canvas.drawLine(
        c + u * rIn,
        c + u * (rIn - len),
        Paint()
          ..strokeWidth = major ? 1.0 : 0.6
          ..color = palette.gold.withValues(alpha: alpha),
      );
    }
  }

  void _paintHouses(
      Canvas canvas, Offset c, double rIn, double rHub, double t) {
    if (t <= 0 || chart.houses.isEmpty) return;
    for (final h in chart.houses) {
      final u = _u(h.longitude);
      final isAngular = h.number == 1 || h.number == 10;
      canvas.drawLine(
        c + u * rHub,
        c + u * (rIn - 10),
        Paint()
          ..strokeWidth = isAngular ? 1.2 : 0.6
          ..color = palette.gold
              .withValues(alpha: (isAngular ? 0.45 : 0.22) * t),
      );
      // Numero della casa a meta' settore.
      final next = chart.houses.firstWhere(
        (x) => x.number == (h.number % 12) + 1,
        orElse: () => h,
      );
      final midLon = _midLon(h.longitude, next.longitude);
      final pos = _u(midLon) * (rHub + 14);
      _text(canvas, '${h.number}', c + pos,
          color: palette.textSecondary.withValues(alpha: 0.5 * t), size: 8);
    }
  }

  void _paintAngles(Canvas canvas, Offset c, double rIn, double t) {
    if (t <= 0) return;
    void marker(double? lon, String label) {
      if (lon == null) return;
      final u = _u(lon);
      final tip = c + u * rIn;
      final b1 = c + _u(lon + 1.4) * (rIn + 14);
      final b2 = c + _u(lon - 1.4) * (rIn + 14);
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(b1.dx, b1.dy)
        ..lineTo(b2.dx, b2.dy)
        ..close();
      canvas.drawPath(
          path, Paint()..color = palette.goldSoft.withValues(alpha: 0.9 * t));
      _text(canvas, label, c + u * (rIn + 22),
          color: palette.goldSoft.withValues(alpha: 0.95 * t),
          size: 9,
          weight: 700);
    }

    marker(chart.ascendantLongitude, 'ASC');
    marker(chart.midheavenLongitude, 'MC');
  }

  void _paintAspects(Canvas canvas, Offset c, double rAsp, double t) {
    if (t <= 0 || chart.aspects.isEmpty) return;
    for (final a in chart.aspects) {
      final p1 = c + _u(a.aLongitude) * rAsp;
      final p2 = c + _u(a.bLongitude) * rAsp;
      final color = switch (a.type.harmony) {
        AspectHarmony.soft => const Color(0xFF6FA8E0),
        AspectHarmony.hard => const Color(0xFFE0733A),
        AspectHarmony.neutral => palette.goldSoft,
      };
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..strokeWidth = a.type.harmony == AspectHarmony.neutral ? 1.0 : 0.8
          ..color = color.withValues(alpha: 0.32 * t),
      );
    }
    // Cerchio guida degli aspetti.
    canvas.drawCircle(
        c,
        rAsp,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = palette.gold.withValues(alpha: 0.2 * t));
  }

  void _paintPlanets(
      Canvas canvas, Offset c, double rPlanet, double rAsp, double base) {
    if (base <= 0) return;
    final planets = [...chart.planets]..sort((a, b) => a.longitude.compareTo(b.longitude));

    double? prevLon;
    var alt = false;
    for (var i = 0; i < planets.length; i++) {
      final p = planets[i];
      final tp = ((base * planets.length) - i).clamp(0.0, 1.0);
      if (tp <= 0) continue;

      // Anti sovrapposizione: se vicino al precedente, sposta il raggio.
      if (prevLon != null && _sep(prevLon, p.longitude) < 8) {
        alt = !alt;
      } else {
        alt = false;
      }
      prevLon = p.longitude;
      final rr = rPlanet + (alt ? 16 : 0);

      final u = _u(p.longitude);
      final pos = c + u * rr;

      // Raggio che collega il pianeta al cerchio degli aspetti.
      canvas.drawLine(c + u * rAsp, pos,
          Paint()..strokeWidth = 0.6..color = palette.gold.withValues(alpha: 0.25 * tp));

      // Bagliore di ingresso, piu' intenso all'apparizione.
      final flash = 1 - tp;
      canvas.drawCircle(
          pos,
          8 + flash * 16,
          Paint()
            ..color = palette.glow.withValues(alpha: (0.2 + 0.4 * flash) * tp)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

      // Glifo del pianeta.
      _glyph(canvas, p.glyph, pos,
          color: palette.goldSoft.withValues(alpha: tp),
          size: rPlanet * 0.14,
          family: 'NotoSansSymbols');

      // Segno di retrogradazione.
      if (p.retrograde) {
        _text(canvas, 'R', pos + Offset(rPlanet * 0.11, -rPlanet * 0.11),
            color: const Color(0xFFE0733A).withValues(alpha: tp),
            size: 8,
            weight: 700);
      }
    }
  }

  double _sep(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }

  double _midLon(double a, double b) {
    var diff = (b - a) % 360;
    if (diff < 0) diff += 360;
    return (a + diff / 2) % 360;
  }

  void _glyph(Canvas canvas, String s, Offset pos,
      {required Color color, required double size, String? family}) {
    _text(canvas, s, pos, color: color, size: size, family: family);
  }

  void _text(Canvas canvas, String s, Offset pos,
      {required Color color,
      required double size,
      double weight = 500,
      String? family}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight:
              FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
          fontFamily: family ?? 'EBGaramond',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.progress != progress ||
      old.chart != chart ||
      old.palette != palette;
}
