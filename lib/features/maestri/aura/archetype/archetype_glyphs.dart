import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/archetypes/archetype.dart';

/// Un glifo essenziale per ogni archetipo, disegnato a vettori.
///
/// Sono tratti nostri, semplici e riconoscibili, non caratteri di sistema:
/// cosi' non c'e' rischio di tofu e il segno resta uguale su ogni piattaforma.
/// Sono segnaposto onesti finche' non arrivera' un set dedicato, come per i
/// glifi delle tradizioni astrologiche. Ogni glifo dice qualcosa dell'archetipo:
/// il sole nascente dell'Innocente, la bussola dell'Esploratore, il libro del
/// Saggio, la spada dell'Eroe, la catena spezzata del Ribelle, la stella a
/// otto punte del Mago, il cerchio di persone del Realista, il cuore
/// dell'Amante, la maschera del Giullare, lo scudo del Custode, la corona del
/// Sovrano, il compasso del Creatore.
class ArchetypeGlyphs {
  const ArchetypeGlyphs._();

  static void disegna(Archetype a, Canvas canvas, Offset c, double r,
      Paint stroke, Paint fill) {
    switch (a) {
      case Archetype.innocente:
        // Sole nascente sull'orizzonte.
        canvas.drawArc(Rect.fromCircle(center: Offset(c.dx, c.dy + r * 0.3), radius: r * 0.6),
            math.pi, math.pi, false, stroke);
        canvas.drawLine(Offset(c.dx - r, c.dy + r * 0.3),
            Offset(c.dx + r, c.dy + r * 0.3), stroke);
        for (var i = 0; i < 3; i++) {
          final ang = -math.pi / 2 + (i - 1) * 0.7;
          final d = Offset(math.cos(ang), math.sin(ang));
          final base = Offset(c.dx, c.dy + r * 0.3);
          canvas.drawLine(base + d * r * 0.7, base + d * r * 0.95, stroke);
        }
      case Archetype.esploratore:
        // Rosa dei venti.
        canvas.drawCircle(c, r * 0.85, stroke);
        for (var i = 0; i < 4; i++) {
          final ang = i * math.pi / 2 - math.pi / 2;
          final d = Offset(math.cos(ang), math.sin(ang));
          canvas.drawLine(c, c + d * r * 0.85, stroke);
        }
      case Archetype.saggio:
        // Libro aperto.
        final p = Path()
          ..moveTo(c.dx, c.dy - r * 0.5)
          ..quadraticBezierTo(c.dx - r * 0.9, c.dy - r * 0.7, c.dx - r * 0.9, c.dy + r * 0.5)
          ..lineTo(c.dx, c.dy + r * 0.6)
          ..lineTo(c.dx, c.dy - r * 0.5)
          ..quadraticBezierTo(c.dx + r * 0.9, c.dy - r * 0.7, c.dx + r * 0.9, c.dy + r * 0.5)
          ..lineTo(c.dx, c.dy + r * 0.6);
        canvas.drawPath(p, stroke);
      case Archetype.eroe:
        // Spada verticale.
        canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r * 0.6), stroke);
        canvas.drawLine(Offset(c.dx - r * 0.55, c.dy + r * 0.3),
            Offset(c.dx + r * 0.55, c.dy + r * 0.3), stroke);
        canvas.drawLine(Offset(c.dx, c.dy + r * 0.6), Offset(c.dx, c.dy + r), stroke);
      case Archetype.ribelle:
        // Catena spezzata: due anelli aperti.
        canvas.drawArc(Rect.fromCircle(center: Offset(c.dx - r * 0.4, c.dy), radius: r * 0.5),
            -math.pi * 0.3, math.pi * 1.4, false, stroke);
        canvas.drawArc(Rect.fromCircle(center: Offset(c.dx + r * 0.4, c.dy), radius: r * 0.5),
            math.pi * 0.7, math.pi * 1.4, false, stroke);
      case Archetype.mago:
        // Stella a otto punte.
        _stella(canvas, c, r, 8, 0.42, stroke);
      case Archetype.realista:
        // Tre figure vicine, il cerchio di pari.
        for (final dx in [-0.55, 0.0, 0.55]) {
          canvas.drawCircle(Offset(c.dx + dx * r, c.dy - r * 0.35), r * 0.28, stroke);
          canvas.drawArc(
              Rect.fromCircle(center: Offset(c.dx + dx * r, c.dy + r * 0.35), radius: r * 0.4),
              math.pi, math.pi, false, stroke);
        }
      case Archetype.amante:
        // Cuore.
        final p = Path()
          ..moveTo(c.dx, c.dy + r * 0.7)
          ..cubicTo(c.dx - r * 1.2, c.dy - r * 0.2, c.dx - r * 0.4, c.dy - r,
              c.dx, c.dy - r * 0.35)
          ..cubicTo(c.dx + r * 0.4, c.dy - r, c.dx + r * 1.2, c.dy - r * 0.2,
              c.dx, c.dy + r * 0.7);
        canvas.drawPath(p, fill);
      case Archetype.giullare:
        // Cappello a tre punte con campanelli.
        for (var i = 0; i < 3; i++) {
          final ang = -math.pi / 2 + (i - 1) * 0.8;
          final d = Offset(math.cos(ang), math.sin(ang));
          canvas.drawLine(Offset(c.dx, c.dy + r * 0.4), c + d * r, stroke);
          canvas.drawCircle(c + d * r, r * 0.16, fill);
        }
      case Archetype.custode:
        // Scudo.
        final p = Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r * 0.8, c.dy - r * 0.5)
          ..lineTo(c.dx + r * 0.8, c.dy + r * 0.3)
          ..quadraticBezierTo(c.dx, c.dy + r * 1.1, c.dx - r * 0.8, c.dy + r * 0.3)
          ..lineTo(c.dx - r * 0.8, c.dy - r * 0.5)
          ..close();
        canvas.drawPath(p, stroke);
      case Archetype.sovrano:
        // Corona.
        final p = Path()
          ..moveTo(c.dx - r * 0.9, c.dy + r * 0.5)
          ..lineTo(c.dx - r * 0.9, c.dy - r * 0.3)
          ..lineTo(c.dx - r * 0.45, c.dy + r * 0.1)
          ..lineTo(c.dx, c.dy - r * 0.6)
          ..lineTo(c.dx + r * 0.45, c.dy + r * 0.1)
          ..lineTo(c.dx + r * 0.9, c.dy - r * 0.3)
          ..lineTo(c.dx + r * 0.9, c.dy + r * 0.5)
          ..close();
        canvas.drawPath(p, stroke);
      case Archetype.creatore:
        // Compasso.
        canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx - r * 0.6, c.dy + r), stroke);
        canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx + r * 0.6, c.dy + r), stroke);
        canvas.drawCircle(Offset(c.dx, c.dy - r), r * 0.16, fill);
    }
  }

  static void _stella(Canvas canvas, Offset c, double r, int punte,
      double interno, Paint stroke) {
    final path = Path();
    for (var i = 0; i < punte * 2; i++) {
      final ang = -math.pi / 2 + i * math.pi / punte;
      final rr = i.isEven ? r : r * interno;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * rr;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, stroke);
  }
}
