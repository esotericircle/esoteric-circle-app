import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/horoscope/horoscope.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'indicatore di livello di una scheda: cinque icone che si riempiono da
/// sinistra a destra, dorate se piene e smorzate se vuote, col numero a fianco
/// ("3 su 5").
///
/// Il linguaggio e' lo stesso su tutte e quattro le schede, cambia solo il tipo
/// di icona: soli per la Generale, cuori per l'Amore, barre crescenti per la
/// Carriera, quadrifogli per la Fortuna. Il valore deterministico resta quello
/// gia' calcolato, qui cambia solo la resa.
class DomainLevel extends StatelessWidget {
  const DomainLevel({
    super.key,
    required this.domain,
    required this.value,
    required this.palette,
    required this.pulse,
    this.iconSize = 17,
    this.gap = 4,
    this.animateFill = true,
    this.showNumber = true,
    this.numberSize = 11,
  });

  final HoroscopeDomain domain;

  /// Il livello deterministico, da 1 a 5.
  final int value;
  final MaestroPalette palette;

  /// Pulsazione lenta condivisa (0..1), per il respiro delle icone piene.
  final Animation<double> pulse;

  final double iconSize;
  final double gap;

  /// Se falso le icone partono gia' piene (per la card statica).
  final bool animateFill;
  final bool showNumber;
  final double numberSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: animateFill ? 0.0 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, fill, _) => AnimatedBuilder(
        animation: pulse,
        builder: (context, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < Horoscope.indicatorMax; i++) ...[
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CustomPaint(
                    painter: _LevelIconPainter(
                      domain: domain,
                      filled: i < value,
                      // Le barre crescono da sinistra a destra.
                      growth: (i + 1) / Horoscope.indicatorMax,
                      // Comparsa progressiva, da sinistra.
                      appear: ((fill * Horoscope.indicatorMax) - i)
                          .clamp(0.0, 1.0),
                      pulse: pulse.value,
                      palette: palette,
                    ),
                  ),
                ),
                if (i < Horoscope.indicatorMax - 1) SizedBox(width: gap),
              ],
              if (showNumber) ...[
                SizedBox(width: gap + 3),
                Text('$value su ${Horoscope.indicatorMax}',
                    style: TypographyTokens.label(size: numberSize).copyWith(
                        color: ColorTokens.textSecondary, letterSpacing: 0.4)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Disegna una singola icona di livello, piena o smorzata, secondo il dominio.
class _LevelIconPainter extends CustomPainter {
  _LevelIconPainter({
    required this.domain,
    required this.filled,
    required this.growth,
    required this.appear,
    required this.pulse,
    required this.palette,
  });

  final HoroscopeDomain domain;
  final bool filled;

  /// Quanto e' alta questa icona nella progressione (per le barre).
  final double growth;

  /// Comparsa progressiva da sinistra (0..1).
  final double appear;
  final double pulse;
  final MaestroPalette palette;

  Color get _color {
    if (!filled) return palette.gold.withValues(alpha: 0.20);
    final breath = 0.92 + 0.08 * math.sin(pulse * 2 * math.pi);
    return palette.goldSoft
        .withValues(alpha: (0.55 + 0.45 * appear) * breath);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _color;
    final scale = filled ? (0.82 + 0.18 * appear) : 1.0;
    switch (domain) {
      case HoroscopeDomain.generale:
        _sun(canvas, size, paint, scale);
      case HoroscopeDomain.amore:
        _heart(canvas, size, paint, scale);
      case HoroscopeDomain.carriera:
        _bar(canvas, size, paint);
      case HoroscopeDomain.fortuna:
        _clover(canvas, size, paint, scale);
    }
  }

  // Generale: un piccolo sole coi raggi.
  void _sun(Canvas canvas, Size size, Paint paint, double scale) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.24 * scale;
    canvas.drawCircle(c, r, paint);
    final rayPaint = Paint()
      ..color = paint.color
      ..strokeWidth = size.shortestSide * 0.075
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r * 1.5), c + dir * (r * 2.25), rayPaint);
    }
  }

  // Amore: un cuore pieno.
  void _heart(Canvas canvas, Size size, Paint paint, double scale) {
    final c = Offset(size.width / 2, size.height * 0.54);
    final s = size.shortestSide * 0.30 * scale;
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.92)
      ..cubicTo(c.dx - s * 1.55, c.dy - s * 0.25, c.dx - s * 0.58,
          c.dy - s * 1.20, c.dx, c.dy - s * 0.38)
      ..cubicTo(c.dx + s * 0.58, c.dy - s * 1.20, c.dx + s * 1.55,
          c.dy - s * 0.25, c.dx, c.dy + s * 0.92)
      ..close();
    canvas.drawPath(path, paint);
  }

  // Carriera: una barra, piu' alta man mano che si va a destra.
  void _bar(Canvas canvas, Size size, Paint paint) {
    final w = size.width * 0.58;
    final maxH = size.height * 0.86;
    final h = maxH * (0.32 + 0.68 * growth) * (filled ? appear : 1.0);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH((size.width - w) / 2, size.height * 0.93 - h, w, h),
      Radius.circular(w * 0.3),
    );
    canvas.drawRRect(rect, paint);
  }

  // Fortuna: un quadrifoglio, quattro foglie a cuore piu' lo stelo.
  void _clover(Canvas canvas, Size size, Paint paint, double scale) {
    final c = Offset(size.width / 2, size.height * 0.44);
    final r = size.shortestSide * 0.21 * scale;
    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      final leaf = Path()
        ..moveTo(0, 0)
        ..cubicTo(r * 0.2, -r * 0.62, r * 1.3, -r * 0.62, r * 1.1, 0)
        ..cubicTo(r * 1.3, r * 0.62, r * 0.2, r * 0.62, 0, 0)
        ..close();
      canvas.drawPath(leaf, paint);
      canvas.restore();
    }
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + r * 0.5)
        ..quadraticBezierTo(
            c.dx + r * 0.3, c.dy + r * 1.3, c.dx, size.height * 0.96),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.07
        ..strokeCap = StrokeCap.round
        ..color = paint.color,
    );
  }

  @override
  bool shouldRepaint(_LevelIconPainter old) =>
      old.domain != domain ||
      old.filled != filled ||
      old.growth != growth ||
      old.appear != appear ||
      old.pulse != pulse ||
      old.palette != palette;
}
