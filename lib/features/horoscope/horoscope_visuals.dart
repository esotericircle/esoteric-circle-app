import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/horoscope/horoscope.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'indicatore a livello di una scheda: la forma a tema del dominio piu' il
/// numero esplicito, per esempio "4 su 5".
///
/// La scala e' la stessa su tutte e quattro le schede (da 1 a 5), la forma no:
/// anello per la Generale, cuori per l'Amore, barre crescenti per la Carriera,
/// quadrifoglio per la Fortuna. Cosi' il livello si legge subito e il visivo non
/// ripete mai la stessa grafica (regola 21 delle Linee Guida UX).
class DomainLevel extends StatelessWidget {
  const DomainLevel({
    super.key,
    required this.domain,
    required this.value,
    required this.palette,
    required this.pulse,
    this.size = 46,
    this.animateFill = true,
    this.showNumber = true,
    this.numberSize = 12,
  });

  final HoroscopeDomain domain;

  /// Il livello deterministico, da 1 a 5.
  final int value;
  final MaestroPalette palette;

  /// Pulsazione lenta condivisa (0..1), per il respiro delle forme.
  final Animation<double> pulse;
  final double size;

  /// Se falso la forma parte gia' piena (per la card statica).
  final bool animateFill;
  final bool showNumber;
  final double numberSize;

  @override
  Widget build(BuildContext context) {
    final shape = SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(value),
        tween: Tween(begin: animateFill ? 0.0 : 1.0, end: 1.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, fill, _) => AnimatedBuilder(
          animation: pulse,
          builder: (context, __) => CustomPaint(
            painter: _painterFor(domain, value, fill, pulse.value, palette),
          ),
        ),
      ),
    );
    if (!showNumber) return shape;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        shape,
        const SizedBox(width: 6),
        Text('$value su ${Horoscope.indicatorMax}',
            style: TypographyTokens.label(size: numberSize).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 0.4)),
      ],
    );
  }
}

CustomPainter _painterFor(HoroscopeDomain domain, int value, double fill,
    double pulse, MaestroPalette palette) {
  switch (domain) {
    case HoroscopeDomain.generale:
      return _RingPainter(
          value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.amore:
      return _HeartsPainter(
          value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.carriera:
      return _BarsPainter(
          value: value, fill: fill, pulse: pulse, palette: palette);
    case HoroscopeDomain.fortuna:
      return _CloverPainter(
          value: value, fill: fill, pulse: pulse, palette: palette);
  }
}

abstract class _LevelPainter extends CustomPainter {
  _LevelPainter(
      {required this.value,
      required this.fill,
      required this.pulse,
      required this.palette});

  final int value;
  final double fill;
  final double pulse;
  final MaestroPalette palette;

  /// Il livello come frazione, un quinto per grado.
  double get ratio =>
      (value / Horoscope.indicatorMax).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(_LevelPainter old) =>
      old.value != value ||
      old.fill != fill ||
      old.pulse != pulse ||
      old.palette != palette;
}

/// Generale, energia: un anello che si riempie di un quinto per grado.
class _RingPainter extends _LevelPainter {
  _RingPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.36;
    final w = size.shortestSide * 0.13;
    final breathe = 0.85 + 0.15 * math.sin(pulse * 2 * math.pi);

    canvas.drawCircle(
      c,
      r * 1.32,
      Paint()
        ..color = palette.goldSoft.withValues(alpha: 0.14 * breathe)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // Traccia con le cinque tacche, cosi' i quinti si leggono.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = palette.gold.withValues(alpha: 0.20),
    );
    // Arco pieno fino al livello.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * ratio * fill,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [palette.gold, palette.goldSoft, palette.gold],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Tacche di separazione dei quinti.
    for (var i = 0; i < Horoscope.indicatorMax; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / Horoscope.indicatorMax;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (r - w / 2),
        c + dir * (r + w / 2),
        Paint()
          ..strokeWidth = 1.2
          ..color = palette.deepest.withValues(alpha: 0.85),
      );
    }
  }
}

/// Amore, affinita': cinque cuori, accesi fino al livello.
class _HeartsPainter extends _LevelPainter {
  _HeartsPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    const total = Horoscope.indicatorMax;
    final slot = size.width / total;
    final hs = math.min(slot * 0.42, size.height * 0.30);
    final beat = 0.94 + 0.06 * math.sin(pulse * 2 * math.pi);

    for (var i = 0; i < total; i++) {
      final lit = i < value;
      final appear = ((fill * total) - i).clamp(0.0, 1.0);
      final cx = slot * (i + 0.5);
      final cy = size.height / 2;
      final s = hs * (lit ? beat : 1.0) * (0.75 + 0.25 * appear);
      final paint = Paint()
        ..color = lit
            ? palette.goldSoft.withValues(alpha: 0.55 + 0.45 * appear)
            : palette.gold.withValues(alpha: 0.20);
      _heart(canvas, Offset(cx, cy), s, paint, filled: lit);
    }
  }

  void _heart(Canvas canvas, Offset c, double s, Paint paint,
      {required bool filled}) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.85)
      ..cubicTo(c.dx - s * 1.5, c.dy - s * 0.25, c.dx - s * 0.55,
          c.dy - s * 1.15, c.dx, c.dy - s * 0.35)
      ..cubicTo(c.dx + s * 0.55, c.dy - s * 1.15, c.dx + s * 1.5,
          c.dy - s * 0.25, c.dx, c.dy + s * 0.85)
      ..close();
    if (filled) {
      canvas.drawPath(path, paint);
    } else {
      canvas.drawPath(
          path,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.22);
    }
  }
}

/// Carriera, spinta: il grafico a barre crescenti, accese fino al livello.
class _BarsPainter extends _LevelPainter {
  _BarsPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    const total = Horoscope.indicatorMax;
    final slot = size.width / total;
    final barW = slot * 0.56;
    final baseY = size.height * 0.86;
    final maxH = size.height * 0.66;

    for (var i = 0; i < total; i++) {
      final lit = i < value;
      final appear = ((fill * total) - i).clamp(0.0, 1.0);
      // Barre crescenti: la prima bassa, l'ultima alta.
      final h = maxH * (0.28 + 0.72 * (i / (total - 1))) * appear;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(slot * i + (slot - barW) / 2, baseY - h, barW, h),
        Radius.circular(barW * 0.28),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = lit
              ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [palette.gold, palette.goldSoft],
                ).createShader(rect.outerRect)
              : null
          ..color = lit
              ? palette.gold
              : palette.gold.withValues(alpha: 0.18),
      );
    }
    // Linea di base.
    canvas.drawLine(
      Offset(size.width * 0.04, baseY + 1.5),
      Offset(size.width * 0.96, baseY + 1.5),
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = palette.gold.withValues(alpha: 0.35),
    );
  }
}

/// Fortuna, sorte: il quadrifoglio, quattro foglie nette a cuore piu' lo stelo.
/// L'intensita' e il numero di foglie accese seguono il livello.
class _CloverPainter extends _LevelPainter {
  _CloverPainter(
      {required super.value,
      required super.fill,
      required super.pulse,
      required super.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.42);
    final leaf = size.shortestSide * 0.30 * (0.6 + 0.4 * fill);
    final sway = math.sin(pulse * 2 * math.pi) * 0.05;
    final alpha = (0.45 + 0.55 * ratio).clamp(0.0, 1.0);

    // Quattro foglie nette a cuore, ai quattro angoli.
    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4 + sway;
      _leaf(canvas, c, a, leaf,
          Paint()..color = palette.goldSoft.withValues(alpha: alpha));
    }
    // Cuore del fiore.
    canvas.drawCircle(c, leaf * 0.22,
        Paint()..color = palette.gold.withValues(alpha: alpha));
    // Stelo.
    final stem = Path()
      ..moveTo(c.dx, c.dy + leaf * 0.35)
      ..quadraticBezierTo(c.dx + leaf * 0.18, c.dy + leaf * 0.95, c.dx,
          size.height * 0.94);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.055
        ..strokeCap = StrokeCap.round
        ..color = palette.gold.withValues(alpha: alpha * 0.85),
    );
  }

  // Una foglia a cuore, con la punta verso il centro.
  void _leaf(Canvas canvas, Offset c, double angle, double r, Paint paint) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(r * 0.15, -r * 0.55, r * 1.15, -r * 0.55, r * 1.0, 0)
      ..cubicTo(r * 1.15, r * 0.55, r * 0.15, r * 0.55, 0, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
