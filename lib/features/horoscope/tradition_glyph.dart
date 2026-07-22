import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/horoscope/astro_tradition.dart';

/// Il glifo di una tradizione astrologica, disegnato a vettori.
///
/// Livello visivo prima del testo: ogni tradizione si riconosce dal suo segno
/// prima ancora di leggerne il nome. Sono tratti nostri, disegnati, non
/// caratteri di sistema: cosi' non c'e' rischio di tofu e il segno resta uguale
/// su ogni piattaforma. Sono segnaposto onesti finche' non arrivera' l'arte
/// dipinta, come per i ritratti dei Maestri.
///
/// Ruota dei dodici per l'Occidentale, ruota a otto raggi per la Vedica, il
/// cerchio diviso dalla curva per la Cinese, la piramide a gradoni per la Maya,
/// il nodo a tre lobi per la Celtica, l'ankh per l'Egizia, la falce con la
/// stella per l'Araba.
class TraditionGlyph extends StatelessWidget {
  const TraditionGlyph({
    super.key,
    required this.tradition,
    required this.color,
    this.size = 22,
  });

  final AstroTradition tradition;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key('tradition_glyph_${tradition.name}'),
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TraditionGlyphPainter(tradition: tradition, color: color),
      ),
    );
  }
}

class _TraditionGlyphPainter extends CustomPainter {
  const _TraditionGlyphPainter({required this.tradition, required this.color});

  final AstroTradition tradition;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final r = s * 0.42;
    final tratto = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * 0.075)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pieno = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (tradition) {
      case AstroTradition.occidentale:
        // Ruota dei dodici settori: il cerchio e le tacche delle case.
        canvas.drawCircle(c, r, tratto);
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(c + d * (r * 0.72), c + d * r, tratto);
        }
        canvas.drawCircle(c, s * 0.06, pieno);
      case AstroTradition.vedica:
        // Ruota a otto raggi, il segno della legge che gira.
        canvas.drawCircle(c, r, tratto);
        canvas.drawCircle(c, r * 0.34, tratto);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(c + d * (r * 0.34), c + d * r, tratto);
        }
      case AstroTradition.cinese:
        // Il cerchio diviso dalla curva, coi due semi.
        canvas.drawCircle(c, r, tratto);
        final curva = Path()
          ..moveTo(c.dx, c.dy - r)
          ..arcToPoint(c, radius: Radius.circular(r / 2), clockwise: true)
          ..arcToPoint(Offset(c.dx, c.dy + r),
              radius: Radius.circular(r / 2), clockwise: false);
        canvas.drawPath(curva, tratto);
        canvas.drawCircle(Offset(c.dx, c.dy - r / 2), s * 0.045, pieno);
      case AstroTradition.maya:
        // Piramide a gradoni, tre livelli che salgono.
        final w = r * 2;
        final passo = w / 3;
        for (var i = 0; i < 3; i++) {
          final larghezza = w - i * passo;
          final top = c.dy + r - (i + 1) * (r * 2 / 3);
          canvas.drawRect(
            Rect.fromLTWH(c.dx - larghezza / 2, top, larghezza, r * 2 / 3 * 0.8),
            tratto,
          );
        }
      case AstroTradition.celtica:
        // Nodo a tre lobi, il filo che non ha ne' capo ne' coda.
        for (var i = 0; i < 3; i++) {
          final a = -math.pi / 2 + i * 2 * math.pi / 3;
          final centro = c + Offset(math.cos(a), math.sin(a)) * (r * 0.42);
          canvas.drawCircle(centro, r * 0.55, tratto);
        }
      case AstroTradition.egizia:
        // Ankh: l'occhiello sopra, la croce sotto.
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(c.dx, c.dy - r * 0.52),
              width: r * 0.9,
              height: r * 0.95),
          tratto,
        );
        canvas.drawLine(
            Offset(c.dx, c.dy - r * 0.05), Offset(c.dx, c.dy + r), tratto);
        canvas.drawLine(Offset(c.dx - r * 0.6, c.dy + r * 0.18),
            Offset(c.dx + r * 0.6, c.dy + r * 0.18), tratto);
      case AstroTradition.araba:
        // Falce di Luna con la stella.
        final falce = Path()
          ..addArc(Rect.fromCircle(center: c, radius: r),
              math.pi * 0.42, math.pi * 1.16);
        canvas.drawPath(falce, tratto);
        _stella(canvas, c + Offset(r * 0.52, -r * 0.34), s * 0.15, pieno);
    }
  }

  // Una piccola stella a cinque punte, piena.
  void _stella(Canvas canvas, Offset centro, double raggio, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? raggio : raggio * 0.45;
      final p = centro + Offset(math.cos(a), math.sin(a)) * rr;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TraditionGlyphPainter old) =>
      old.tradition != tradition || old.color != color;
}
