import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../design_system/components/zodiac_wheel.dart' show drawZodiacGlyph;

/// Le accensioni del Risveglio, disegnate dal codice: ogni passo del rituale ha
/// la sua, un piccolo evento di luce che accompagna cio' che si raccoglie. Tutte
/// prendono un progresso [t] da 0 a 1, cosi' la schermata puo' accenderle piano
/// o, sotto Riduci Movimento, mostrarle gia' compiute a t = 1 senza moto.

/// Il Sole scende e si posa nel segno ricavato dalla data. Astronomia vera dietro
/// (il segno viene da `NightSky.sunSign`), qui solo la messa in scena.
class SunInSignPainter extends CustomPainter {
  SunInSignPainter({
    required this.sign,
    required this.t,
    required this.color,
  });

  final Zodiac sign;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w * 0.5, h * 0.6);
    final glyphS = math.min(w, h) * 0.14;

    // Arco dello zodiaco su cui il Sole si posa.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.004)
      ..color = color.withValues(alpha: 0.28);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.32),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      arcPaint,
    );

    // Il Sole cala dall'alto verso il segno.
    final sunY = _lerp(h * 0.12, center.dy - glyphS * 1.7, t);
    final sunCenter = Offset(center.dx, sunY);
    final sunR = glyphS * (0.62 + 0.12 * t);
    // Alone caldo.
    canvas.drawCircle(
      sunCenter,
      sunR * 2.4,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFF3D0).withValues(alpha: 0.5 * t),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: sunCenter, radius: sunR * 2.4)),
    );
    // Raggi che si accendono a fine discesa.
    final rayA = (t - 0.4).clamp(0.0, 1.0) / 0.6;
    if (rayA > 0) {
      final rp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, w * 0.004)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFE9AE).withValues(alpha: 0.7 * rayA);
      for (var i = 0; i < 12; i++) {
        final a = 2 * math.pi * i / 12;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          sunCenter + dir * sunR * 1.3,
          sunCenter + dir * sunR * (1.7 + 0.4 * rayA),
          rp,
        );
      }
    }
    // Disco del Sole.
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()
        ..shader = const RadialGradient(colors: [
          Color(0xFFFFF7E0),
          Color(0xFFF3C766),
        ]).createShader(Rect.fromCircle(center: sunCenter, radius: sunR)),
    );

    // Il glifo del segno, che si accende man mano che il Sole scende.
    final lit = 0.35 + 0.6 * t;
    final glyphPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, glyphS * 0.14)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: lit);
    drawZodiacGlyph(canvas, sign, center, glyphS, glyphPaint);
  }

  @override
  bool shouldRepaint(SunInSignPainter old) =>
      old.t != t || old.sign != sign || old.color != color;
}

/// L'orizzonte con l'Ascendente che sorge a est. E' un segnaposto dichiarato: il
/// punto esatto richiede il calcolo a effemeridi con ora e luogo, quindi qui la
/// scena e' evocativa, non una posizione vera. Con [known] falso la scena resta
/// calma, a indicare che senza l'ora si salta con grazia.
class HorizonRisePainter extends CustomPainter {
  HorizonRisePainter({
    required this.t,
    required this.color,
    this.known = true,
  });

  final double t;
  final Color color;
  final bool known;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final horizonY = h * 0.62;

    // Cielo sopra l'orizzonte, appena piu' chiaro.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizonY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, horizonY)),
    );

    // La linea dell'orizzonte.
    canvas.drawLine(
      Offset(w * 0.08, horizonY),
      Offset(w * 0.92, horizonY),
      Paint()
        ..strokeWidth = math.max(1.0, w * 0.004)
        ..color = color.withValues(alpha: 0.5),
    );

    if (!known) {
      // Senza ora: un punto tenue resta sotto l'orizzonte, la scena non forza
      // nulla. La grazia del salto e' anche visiva.
      canvas.drawCircle(
        Offset(w * 0.72, horizonY + h * 0.06),
        w * 0.02,
        Paint()..color = color.withValues(alpha: 0.25),
      );
      return;
    }

    // Il punto dell'Ascendente sorge a est (destra), dal basso verso l'alto.
    final riseY = _lerp(horizonY + h * 0.10, horizonY - h * 0.16, t);
    final riseX = w * 0.72;
    final point = Offset(riseX, riseY);
    // Scia dal punto verso l'orizzonte.
    canvas.drawLine(
      Offset(riseX, horizonY),
      point,
      Paint()
        ..strokeWidth = math.max(1.0, w * 0.003)
        ..color = color.withValues(alpha: 0.35 * t),
    );
    // Alone del punto nascente.
    canvas.drawCircle(
      point,
      w * 0.06,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: 0.55 * t),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: point, radius: w * 0.06)),
    );
    canvas.drawCircle(
        point, w * 0.016, Paint()..color = const Color(0xFFFFF3D0));
  }

  @override
  bool shouldRepaint(HorizonRisePainter old) =>
      old.t != t || old.color != color || old.known != known;
}

/// Il cielo si ancora alla Terra: un orizzonte, e sopra la ruota delle dodici
/// case che si dispone attorno al centro. Con [anchored] falso la ruota e'
/// appena accennata, in attesa che il luogo la fissi.
class HousesAnchorPainter extends CustomPainter {
  HousesAnchorPainter({
    required this.t,
    required this.color,
    this.anchored = false,
  });

  final double t;
  final Color color;
  final bool anchored;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final r = math.min(w, h) * 0.40;
    final a = anchored ? t : t * 0.4;

    Paint stroke(double width, double alpha) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha * a);

    // Anelli portanti della ruota.
    canvas.drawCircle(center, r, stroke(math.max(1.0, r * 0.012), 0.55));
    canvas.drawCircle(center, r * 0.66, stroke(math.max(1.0, r * 0.008), 0.4));
    canvas.drawCircle(center, r * 0.2, stroke(math.max(1.0, r * 0.008), 0.35));

    // Dodici raggi: i confini delle case che si dispongono.
    final spokes = (12 * t).clamp(0, 12).floor();
    for (var i = 0; i < (anchored ? spokes : 12); i++) {
      final ang =
          2 * math.pi * i / 12 - math.pi; // parte dall'orizzonte a ovest
      final dir = Offset(math.cos(ang), math.sin(ang));
      canvas.drawLine(center + dir * r * 0.2, center + dir * r,
          stroke(math.max(1.0, r * 0.006), i % 3 == 0 ? 0.55 : 0.3));
    }

    // La linea dell'orizzonte che taglia la ruota: l'ancora alla Terra.
    final horizon = Paint()
      ..strokeWidth = math.max(1.0, r * 0.012)
      ..color = color.withValues(alpha: 0.6 * a);
    canvas.drawLine(
      Offset(center.dx - r * 1.05, center.dy),
      Offset(center.dx + r * 1.05, center.dy),
      horizon,
    );
    // Il punto a est (Ascendente) dove l'orizzonte incontra la ruota.
    if (anchored) {
      final east = Offset(center.dx + r, center.dy);
      canvas.drawCircle(
        east,
        r * 0.08,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFF3D0).withValues(alpha: 0.8 * a),
            const Color(0x00000000),
          ]).createShader(Rect.fromCircle(center: east, radius: r * 0.08)),
      );
    }
  }

  @override
  bool shouldRepaint(HousesAnchorPainter old) =>
      old.t != t || old.color != color || old.anchored != anchored;
}

/// Piccola utilita' locale: interpolazione lineare senza dipendere da altro.
double _lerp(double a, double b, double t) => a + (b - a) * t;
