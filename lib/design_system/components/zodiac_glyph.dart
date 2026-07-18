import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';

/// L'arte dei dodici simboli zodiacali brandizzati.
///
/// Quando l'asset di Mauro c'e' si mostra quello (stem `zod_<segno>`, piena in
/// `assets/img/zodiac/`, miniatura in `assets/img_thumb/zodiac/`); finche' non
/// c'e', si dipinge un glifo dorato a vettori. Mai il carattere di sistema, cosi'
/// non compare piu' il quadratino vuoto.
class ZodiacArt {
  const ZodiacArt._();

  static String stem(Zodiac z) => 'zod_${z.italianName.toLowerCase()}';

  static String fullPath(Zodiac z) => 'assets/img/zodiac/${stem(z)}.webp';

  static String thumbPath(Zodiac z) => 'assets/img_thumb/zodiac/${stem(z)}.webp';
}

/// L'emblema di un segno: l'immagine brandizzata se presente, altrimenti il
/// glifo dorato dipinto a vettori. Mai il glifo di sistema.
class ZodiacEmblem extends StatelessWidget {
  const ZodiacEmblem({
    super.key,
    required this.sign,
    required this.size,
    required this.color,
    this.thumb = false,
    this.assetPath,
  });

  final Zodiac sign;
  final double size;
  final Color color;

  /// Usa la miniatura invece della piena.
  final bool thumb;

  /// Percorso dell'asset, per i test. Se nullo si risolve da [ZodiacArt].
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path =
        assetPath ?? (thumb ? ZodiacArt.thumbPath(sign) : ZodiacArt.fullPath(sign));
    final fallback = CustomPaint(
      size: Size.square(size),
      painter: ZodiacGlyphPainter(sign: sign, color: color),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

/// Il glifo zodiacale dipinto a vettori, semplice ed elegante, in oro. Ripiego
/// quando l'asset non c'e', e base di test per non mostrare mai il tofu.
class ZodiacGlyphPainter extends CustomPainter {
  ZodiacGlyphPainter({required this.sign, required this.color});

  final Zodiac sign;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);
    final s = size.shortestSide;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()..color = color;

    void line(Offset a, Offset b) => canvas.drawLine(a, b, stroke);
    void path(void Function(Path) build) {
      final pt = Path();
      build(pt);
      canvas.drawPath(pt, stroke);
    }

    switch (sign) {
      case Zodiac.aries: // corna dell'ariete
        path((pt) {
          pt.moveTo(p(0.5, 0.78).dx, p(0.5, 0.78).dy);
          pt.lineTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy);
        });
        path((pt) => pt
          ..moveTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy)
          ..cubicTo(p(0.5, 0.22).dx, p(0.5, 0.22).dy, p(0.26, 0.22).dx,
              p(0.26, 0.22).dy, p(0.26, 0.44).dx, p(0.26, 0.44).dy));
        path((pt) => pt
          ..moveTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy)
          ..cubicTo(p(0.5, 0.22).dx, p(0.5, 0.22).dy, p(0.74, 0.22).dx,
              p(0.74, 0.22).dy, p(0.74, 0.44).dx, p(0.74, 0.44).dy));
      case Zodiac.taurus: // cerchio con la falce sopra
        canvas.drawCircle(p(0.5, 0.64), s * 0.2, stroke);
        path((pt) => pt
          ..moveTo(p(0.28, 0.4).dx, p(0.28, 0.4).dy)
          ..cubicTo(p(0.34, 0.18).dx, p(0.34, 0.18).dy, p(0.66, 0.18).dx,
              p(0.66, 0.18).dy, p(0.72, 0.4).dx, p(0.72, 0.4).dy));
      case Zodiac.gemini: // due colonne coi ponti
        line(p(0.38, 0.3), p(0.38, 0.7));
        line(p(0.62, 0.3), p(0.62, 0.7));
        path((pt) => pt
          ..moveTo(p(0.3, 0.3).dx, p(0.3, 0.3).dy)
          ..quadraticBezierTo(
              p(0.5, 0.2).dx, p(0.5, 0.2).dy, p(0.7, 0.3).dx, p(0.7, 0.3).dy));
        path((pt) => pt
          ..moveTo(p(0.3, 0.7).dx, p(0.3, 0.7).dy)
          ..quadraticBezierTo(
              p(0.5, 0.8).dx, p(0.5, 0.8).dy, p(0.7, 0.7).dx, p(0.7, 0.7).dy));
      case Zodiac.cancer: // le due spirali
        path((pt) => pt
          ..moveTo(p(0.26, 0.46).dx, p(0.26, 0.46).dy)
          ..cubicTo(p(0.28, 0.3).dx, p(0.28, 0.3).dy, p(0.56, 0.3).dx,
              p(0.56, 0.3).dy, p(0.6, 0.44).dx, p(0.6, 0.44).dy));
        canvas.drawCircle(p(0.63, 0.45), s * 0.05, fill);
        path((pt) => pt
          ..moveTo(p(0.74, 0.54).dx, p(0.74, 0.54).dy)
          ..cubicTo(p(0.72, 0.7).dx, p(0.72, 0.7).dy, p(0.44, 0.7).dx,
              p(0.44, 0.7).dy, p(0.4, 0.56).dx, p(0.4, 0.56).dy));
        canvas.drawCircle(p(0.37, 0.55), s * 0.05, fill);
      case Zodiac.leo: // testa e coda a ricciolo
        canvas.drawCircle(p(0.36, 0.62), s * 0.13, stroke);
        path((pt) => pt
          ..moveTo(p(0.48, 0.64).dx, p(0.48, 0.64).dy)
          ..cubicTo(p(0.66, 0.7).dx, p(0.66, 0.7).dy, p(0.76, 0.44).dx,
              p(0.76, 0.44).dy, p(0.62, 0.34).dx, p(0.62, 0.34).dy)
          ..cubicTo(p(0.52, 0.27).dx, p(0.52, 0.27).dy, p(0.66, 0.22).dx,
              p(0.66, 0.22).dy, p(0.78, 0.32).dx, p(0.78, 0.32).dy));
      case Zodiac.virgo: // la M con l'occhiello
        path((pt) => pt
          ..moveTo(p(0.24, 0.72).dx, p(0.24, 0.72).dy)
          ..lineTo(p(0.24, 0.36).dx, p(0.24, 0.36).dy)
          ..quadraticBezierTo(p(0.31, 0.3).dx, p(0.31, 0.3).dy, p(0.37, 0.36).dx,
              p(0.37, 0.36).dy)
          ..lineTo(p(0.37, 0.68).dx, p(0.37, 0.68).dy)
          ..moveTo(p(0.37, 0.36).dx, p(0.37, 0.36).dy)
          ..quadraticBezierTo(p(0.44, 0.3).dx, p(0.44, 0.3).dy, p(0.5, 0.36).dx,
              p(0.5, 0.36).dy)
          ..lineTo(p(0.5, 0.72).dx, p(0.5, 0.72).dy));
        path((pt) => pt
          ..moveTo(p(0.5, 0.42).dx, p(0.5, 0.42).dy)
          ..quadraticBezierTo(p(0.66, 0.28).dx, p(0.66, 0.28).dy, p(0.66, 0.52).dx,
              p(0.66, 0.52).dy)
          ..quadraticBezierTo(p(0.66, 0.66).dx, p(0.66, 0.66).dy, p(0.56, 0.62).dx,
              p(0.56, 0.62).dy));
      case Zodiac.libra: // la cupola sulla linea
        line(p(0.24, 0.68), p(0.76, 0.68));
        line(p(0.24, 0.56), p(0.42, 0.56));
        line(p(0.58, 0.56), p(0.76, 0.56));
        canvas.drawArc(
            Rect.fromCircle(center: p(0.5, 0.5), radius: s * 0.17),
            math.pi,
            math.pi,
            false,
            stroke);
        line(p(0.33, 0.5), p(0.42, 0.56));
        line(p(0.67, 0.5), p(0.58, 0.56));
      case Zodiac.scorpio: // la M con la freccia
        path((pt) => pt
          ..moveTo(p(0.22, 0.72).dx, p(0.22, 0.72).dy)
          ..lineTo(p(0.22, 0.36).dx, p(0.22, 0.36).dy)
          ..quadraticBezierTo(p(0.29, 0.3).dx, p(0.29, 0.3).dy, p(0.35, 0.36).dx,
              p(0.35, 0.36).dy)
          ..lineTo(p(0.35, 0.7).dx, p(0.35, 0.7).dy)
          ..moveTo(p(0.35, 0.36).dx, p(0.35, 0.36).dy)
          ..quadraticBezierTo(p(0.42, 0.3).dx, p(0.42, 0.3).dy, p(0.48, 0.36).dx,
              p(0.48, 0.36).dy)
          ..lineTo(p(0.48, 0.72).dx, p(0.48, 0.72).dy)
          ..moveTo(p(0.48, 0.36).dx, p(0.48, 0.36).dy)
          ..quadraticBezierTo(p(0.55, 0.3).dx, p(0.55, 0.3).dy, p(0.61, 0.36).dx,
              p(0.61, 0.36).dy)
          ..lineTo(p(0.61, 0.66).dx, p(0.61, 0.66).dy)
          ..lineTo(p(0.74, 0.78).dx, p(0.74, 0.78).dy));
        line(p(0.74, 0.78), p(0.62, 0.76));
        line(p(0.74, 0.78), p(0.76, 0.64));
      case Zodiac.sagittarius: // la freccia con la traversa
        line(p(0.28, 0.74), p(0.74, 0.28));
        line(p(0.74, 0.28), p(0.52, 0.28));
        line(p(0.74, 0.28), p(0.74, 0.5));
        line(p(0.42, 0.46), p(0.56, 0.6));
      case Zodiac.capricorn: // testa e coda ad anello
        path((pt) => pt
          ..moveTo(p(0.24, 0.34).dx, p(0.24, 0.34).dy)
          ..lineTo(p(0.32, 0.7).dx, p(0.32, 0.7).dy)
          ..moveTo(p(0.24, 0.34).dx, p(0.24, 0.34).dy)
          ..quadraticBezierTo(p(0.42, 0.28).dx, p(0.42, 0.28).dy, p(0.5, 0.4).dx,
              p(0.5, 0.4).dy)
          ..cubicTo(p(0.58, 0.52).dx, p(0.58, 0.52).dy, p(0.5, 0.64).dx,
              p(0.5, 0.64).dy, p(0.46, 0.56).dx, p(0.46, 0.56).dy));
        canvas.drawCircle(p(0.62, 0.62), s * 0.1, stroke);
      case Zodiac.aquarius: // due onde
        for (final dy in const [0.42, 0.58]) {
          path((pt) => pt
            ..moveTo(p(0.22, dy).dx, p(0.22, dy).dy)
            ..lineTo(p(0.34, dy - 0.06).dx, p(0.34, dy - 0.06).dy)
            ..lineTo(p(0.46, dy).dx, p(0.46, dy).dy)
            ..lineTo(p(0.58, dy - 0.06).dx, p(0.58, dy - 0.06).dy)
            ..lineTo(p(0.7, dy).dx, p(0.7, dy).dy)
            ..lineTo(p(0.78, dy - 0.04).dx, p(0.78, dy - 0.04).dy));
        }
      case Zodiac.pisces: // due archi e la barra
        canvas.drawArc(Rect.fromCircle(center: p(0.34, 0.5), radius: s * 0.22),
            -math.pi / 2, math.pi, false, stroke);
        canvas.drawArc(Rect.fromCircle(center: p(0.66, 0.5), radius: s * 0.22),
            math.pi / 2, math.pi, false, stroke);
        line(p(0.34, 0.5), p(0.66, 0.5));
    }
  }

  @override
  bool shouldRepaint(ZodiacGlyphPainter old) =>
      old.sign != sign || old.color != color;
}
