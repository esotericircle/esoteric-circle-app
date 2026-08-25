import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/zodiac.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';

/// Ascendente a sinistra, zodiaco antiorario (convenzione dei temi natali).
Offset _wheelDir(double lon, double ascLon) {
  final a = (180.0 + (lon - ascLon)) * math.pi / 180;
  return Offset(math.cos(a), -math.sin(a));
}

const _planetRingFraction = 0.66;

/// Ruota natale 2.5D ricca e ornata, che si costruisce con un'animazione.
///
/// Comprende la fascia zodiacale con i glifi, le tacche dei gradi, le cuspidi
/// delle case, i pianeti coi glifi (e il segno di retrogradazione), gli angoli
/// Ascendente e Medio Cielo, e le linee degli aspetti come strato attivabile.
/// Un pianeta puo' essere evidenziato e pulsa; toccando un pianeta si richiama
/// [onPlanetTap].
class NatalWheel extends StatefulWidget {
  const NatalWheel({
    super.key,
    required this.chart,
    this.size = 320,
    this.showAspects = false,
    this.highlightPlanetId,
    this.onPlanetTap,
    this.avanzamento,
  });

  final NatalChart chart;
  final double size;
  final bool showAspects;
  final String? highlightPlanetId;
  final ValueChanged<String>? onPlanetTap;

  /// **QUANTO DELLA RUOTA E' GIA' DISEGNATA, da fuori.** Ordine BO voce 06.
  ///
  /// Nullo vuol dire "fai da te", cioe' il comportamento di sempre: la ruota
  /// si costruisce da sola in 3.600 millesimi. Quando invece la ruota fa parte
  /// di una coreografia piu' grande, come la sovrapposizione delle due carte
  /// nella Sinastria, il tempo lo detta la scena: **si passa il progresso e
  /// non si scrive una seconda ruota**, che era il rischio vero di quella
  /// voce.
  final double? avanzamento;

  @override
  State<NatalWheel> createState() => _NatalWheelState();
}

class _NatalWheelState extends State<NatalWheel>
    with TickerProviderStateMixin {
  late final AnimationController _build;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _build = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _build.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails d) {
    final cb = widget.onPlanetTap;
    if (cb == null) return;
    final r = widget.size / 2 - 4;
    final center = Offset(widget.size / 2, widget.size / 2);
    final v = d.localPosition - center;
    final rPlanet = r * _planetRingFraction;
    // Solo nella fascia dei pianeti.
    if ((v.distance - rPlanet).abs() > r * 0.28) return;
    final tapAngle = math.atan2(v.dy, v.dx);
    final ascLon = widget.chart.orientationLongitude;
    String? best;
    var bestDiff = 0.22; // ~12 gradi
    for (final p in widget.chart.planets) {
      final dir = _wheelDir(p.longitude, ascLon);
      final ang = math.atan2(dir.dy, dir.dx);
      var diff = (ang - tapAngle).abs();
      if (diff > math.pi) diff = 2 * math.pi - diff;
      if (diff < bestDiff) {
        bestDiff = diff;
        best = p.id;
      }
    }
    if (best != null) cb(best);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTapUp: _onTapUp,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_build, _pulse]),
          builder: (context, _) => CustomPaint(
            painter: _WheelPainter(
              progress: widget.avanzamento != null
                  ? widget.avanzamento!.clamp(0.0, 1.0)
                  : Curves.easeOut.transform(_build.value),
              pulse: _pulse.value,
              chart: widget.chart,
              palette: palette,
              showAspects: widget.showAspects,
              highlightId: widget.highlightPlanetId,
            ),
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
    required this.pulse,
    required this.chart,
    required this.palette,
    required this.showAspects,
    required this.highlightId,
  });

  final double progress;
  final double pulse;
  final NatalChart chart;
  final MaestroPalette palette;
  final bool showAspects;
  final String? highlightId;

  double get _ascLon => chart.orientationLongitude;
  Offset _u(double lon) => _wheelDir(lon, _ascLon);
  double _t(double from, double span) =>
      ((progress - from) / span).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final rBandOut = r;
    final rBandIn = r * 0.80;
    final rHouse = r * 0.5;
    final rPlanet = r * _planetRingFraction;
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
    if (showAspects) _paintAspects(canvas, center, rAspect, tAspect);
    _paintPlanets(canvas, center, rPlanet, rAspect, tPlanetBase);

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
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = palette.gold.withValues(alpha: 0.75 * t);
    canvas.drawCircle(c, rOut, ring);
    canvas.drawCircle(
        c, rIn, ring..color = palette.gold.withValues(alpha: 0.5 * t));

    final rGlyph = (rOut + rIn) / 2;
    for (var i = 0; i < 12; i++) {
      final z = Zodiac.values[i];
      final startLon = i * 30.0;
      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (rOut - rIn)
        ..color = _elementColor[z.element]!.withValues(alpha: 0.14 * t);
      final rect = Rect.fromCircle(center: c, radius: rGlyph);
      final u = _u(startLon);
      canvas.drawArc(
          rect, math.atan2(u.dy, u.dx), -30 * math.pi / 180, false, sweepPaint);

      final dv = _u(startLon);
      canvas.drawLine(c + dv * rIn, c + dv * rOut,
          Paint()..strokeWidth = 0.8..color = palette.gold.withValues(alpha: 0.35 * t));

      final mid = _u(startLon + 15);
      _glyph(canvas, z.symbol, c + mid * rGlyph,
          color: palette.goldSoft.withValues(alpha: 0.92 * t),
          size: rOut * 0.11);
    }
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
      final angular = h.number == 1 || h.number == 10;
      canvas.drawLine(
        c + u * rHub,
        c + u * (rIn - 10),
        Paint()
          ..strokeWidth = angular ? 1.2 : 0.6
          ..color =
              palette.gold.withValues(alpha: (angular ? 0.45 : 0.22) * t),
      );
      final next = chart.houses.firstWhere(
        (x) => x.number == (h.number % 12) + 1,
        orElse: () => h,
      );
      final midLon = _midLon(h.longitude, next.longitude);
      _text(canvas, '${h.number}', c + _u(midLon) * (rHub + 14),
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
        // Spessore e opacita' quasi raddoppiati. Prima erano 0,8 px a 32 di
        // opacita': sul simulatore, che disegna a densita' 1, si vedevano; su
        // un telefono vero il tratto cade sotto il pixel fisico ed e' un
        // fantasma. Le linee d'aspetto sono il contenuto della ruota, non una
        // decorazione, quindi devono reggere lo schermo vero.
        Paint()
          ..strokeWidth = a.type.harmony == AspectHarmony.neutral ? 2.0 : 1.7
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.58 * t),
      );
    }
    canvas.drawCircle(
        c,
        rAsp,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = palette.gold.withValues(alpha: 0.34 * t));
  }

  void _paintPlanets(
      Canvas canvas, Offset c, double rPlanet, double rAsp, double base) {
    if (base <= 0) return;
    final planets = [...chart.planets]
      ..sort((a, b) => a.longitude.compareTo(b.longitude));

    double? prevLon;
    var alt = false;
    for (var i = 0; i < planets.length; i++) {
      final p = planets[i];
      final tp = ((base * planets.length) - i).clamp(0.0, 1.0);
      if (tp <= 0) continue;
      if (prevLon != null && _sep(prevLon, p.longitude) < 8) {
        alt = !alt;
      } else {
        alt = false;
      }
      prevLon = p.longitude;
      final rr = rPlanet + (alt ? 16 : 0);
      final u = _u(p.longitude);
      final pos = c + u * rr;

      canvas.drawLine(c + u * rAsp, pos,
          Paint()..strokeWidth = 0.6..color = palette.gold.withValues(alpha: 0.25 * tp));

      final flash = 1 - tp;
      final isHi = p.id == highlightId;
      final pulseGlow = isHi ? (0.4 + 0.4 * math.sin(pulse * 2 * math.pi)) : 0.0;
      canvas.drawCircle(
          pos,
          8 + flash * 16 + pulseGlow * 12,
          Paint()
            ..color = palette.glow
                .withValues(alpha: (0.2 + 0.4 * flash + pulseGlow * 0.5) * tp)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      if (isHi) {
        canvas.drawCircle(
            pos,
            12 + pulseGlow * 4,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4
              ..color = palette.goldSoft.withValues(alpha: 0.9));
      }

      _planetGlyph(canvas, p, pos,
          color: palette.goldSoft.withValues(alpha: tp), size: rPlanet * 0.14);

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
          {required Color color, required double size}) =>
      _text(canvas, s, pos, color: color, size: size, family: 'NotoSansSymbols');

  // Il glifo del Sole non e' nel font simboli: si disegna (cerchio con punto).
  void _planetGlyph(Canvas canvas, PlanetPosition p, Offset pos,
      {required Color color, required double size}) {
    if (p.id == 'sun') {
      final r = size * 0.5;
      canvas.drawCircle(pos, r,
          Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = color);
      canvas.drawCircle(pos, size * 0.1, Paint()..color = color);
    } else {
      _glyph(canvas, p.glyph, pos, color: color, size: size);
    }
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
      old.pulse != pulse ||
      old.chart != chart ||
      old.palette != palette ||
      old.showAspects != showAspects ||
      old.highlightId != highlightId;
}
