import 'package:flutter/material.dart';

/// Geometria a tratti delle rune dell'Elder Futhark, in coordinate normalizzate
/// (0..1), cosi' il glifo si disegna via codice senza dipendere da un font che
/// contenga il blocco runico Unicode. Ogni runa e' una lista di spezzate.
///
/// Sono forme fedeli nello spirito ai segni tradizionali, tracciate a mano: la
/// runa e' reale e riconoscibile, il tratto e' essenziale in attesa dell'arte
/// incisa di brand sul bucket.
const Map<String, List<List<Offset>>> kRuneStrokes = {
  'Fehu': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0.2), Offset(0.75, 0.06)],
    [Offset(0.3, 0.46), Offset(0.75, 0.32)],
  ],
  'Uruz': [
    [Offset(0.28, 1), Offset(0.28, 0), Offset(0.72, 0.22), Offset(0.72, 1)],
  ],
  'Thurisaz': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0.3), Offset(0.62, 0.5), Offset(0.3, 0.7)],
  ],
  'Ansuz': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0.12), Offset(0.72, 0.3)],
    [Offset(0.3, 0.4), Offset(0.72, 0.58)],
  ],
  'Raidho': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0), Offset(0.66, 0.12), Offset(0.3, 0.46)],
    [Offset(0.3, 0.46), Offset(0.68, 1)],
  ],
  'Kenaz': [
    [Offset(0.66, 0.12), Offset(0.28, 0.5), Offset(0.66, 0.88)],
  ],
  'Gebo': [
    [Offset(0.15, 0.08), Offset(0.85, 0.92)],
    [Offset(0.85, 0.08), Offset(0.15, 0.92)],
  ],
  'Wunjo': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0.04), Offset(0.7, 0.24), Offset(0.3, 0.44)],
  ],
  'Hagalaz': [
    [Offset(0.28, 0), Offset(0.28, 1)],
    [Offset(0.72, 0), Offset(0.72, 1)],
    [Offset(0.28, 0.42), Offset(0.72, 0.58)],
  ],
  'Nauthiz': [
    [Offset(0.42, 0), Offset(0.42, 1)],
    [Offset(0.18, 0.66), Offset(0.66, 0.34)],
  ],
  'Isa': [
    [Offset(0.5, 0), Offset(0.5, 1)],
  ],
  'Jera': [
    [Offset(0.46, 0.06), Offset(0.72, 0.26), Offset(0.46, 0.46)],
    [Offset(0.54, 0.54), Offset(0.28, 0.74), Offset(0.54, 0.94)],
  ],
  'Eihwaz': [
    [Offset(0.42, 0.05), Offset(0.42, 0.95)],
    [Offset(0.42, 0.12), Offset(0.66, 0.02)],
    [Offset(0.42, 0.88), Offset(0.18, 0.98)],
  ],
  'Perthro': [
    [
      Offset(0.64, 0.08),
      Offset(0.34, 0.28),
      Offset(0.34, 0.72),
      Offset(0.64, 0.92)
    ],
  ],
  'Algiz': [
    [Offset(0.5, 0.28), Offset(0.5, 1)],
    [Offset(0.5, 0.28), Offset(0.22, 0.02)],
    [Offset(0.5, 0.28), Offset(0.78, 0.02)],
  ],
  'Sowilo': [
    [
      Offset(0.68, 0.08),
      Offset(0.36, 0.34),
      Offset(0.64, 0.58),
      Offset(0.32, 0.92)
    ],
  ],
  'Tiwaz': [
    [Offset(0.5, 0.28), Offset(0.5, 1)],
    [Offset(0.5, 0.28), Offset(0.26, 0.52)],
    [Offset(0.5, 0.28), Offset(0.74, 0.52)],
  ],
  'Berkano': [
    [Offset(0.3, 0), Offset(0.3, 1)],
    [Offset(0.3, 0.05), Offset(0.64, 0.22), Offset(0.3, 0.42)],
    [Offset(0.3, 0.5), Offset(0.64, 0.68), Offset(0.3, 0.9)],
  ],
  'Ehwaz': [
    [Offset(0.28, 0), Offset(0.28, 1)],
    [Offset(0.72, 0), Offset(0.72, 1)],
    [Offset(0.28, 0.14), Offset(0.5, 0.4)],
    [Offset(0.72, 0.14), Offset(0.5, 0.4)],
  ],
  'Mannaz': [
    [Offset(0.24, 0), Offset(0.24, 1)],
    [Offset(0.76, 0), Offset(0.76, 1)],
    [Offset(0.24, 0.04), Offset(0.76, 0.5)],
    [Offset(0.76, 0.04), Offset(0.24, 0.5)],
  ],
  'Laguz': [
    [Offset(0.4, 0), Offset(0.4, 1)],
    [Offset(0.4, 0), Offset(0.72, 0.2)],
  ],
  'Ingwaz': [
    [
      Offset(0.5, 0.16),
      Offset(0.74, 0.5),
      Offset(0.5, 0.84),
      Offset(0.26, 0.5),
      Offset(0.5, 0.16)
    ],
  ],
  'Dagaz': [
    [Offset(0.24, 0.05), Offset(0.24, 0.95)],
    [Offset(0.76, 0.05), Offset(0.76, 0.95)],
    [Offset(0.24, 0.05), Offset(0.76, 0.95)],
    [Offset(0.76, 0.05), Offset(0.24, 0.95)],
  ],
  'Othala': [
    [
      Offset(0.5, 0.08),
      Offset(0.72, 0.4),
      Offset(0.5, 0.66),
      Offset(0.28, 0.4),
      Offset(0.5, 0.08)
    ],
    [Offset(0.5, 0.66), Offset(0.3, 0.98)],
    [Offset(0.5, 0.66), Offset(0.7, 0.98)],
  ],
};

/// Disegna il glifo runico a tratti, incastonato in un quadrato, con un alone.
class RunePainter extends CustomPainter {
  RunePainter({
    required this.runeName,
    required this.color,
    required this.glow,
    this.intensity = 1.0,
  });

  final String runeName;
  final Color color;
  final Color glow;

  /// Da 0 (spento) a 1 (rivelato): quanto e' acceso il glifo.
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final strokes = kRuneStrokes[runeName];
    if (strokes == null) return;
    final side = size.shortestSide * 0.62;
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2;
    Offset map(Offset p) => Offset(left + p.dx * side, top + p.dy * side);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = glow.withValues(alpha: 0.5 * intensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.05);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color =
          color.withValues(alpha: (0.5 + 0.5 * intensity).clamp(0.0, 1.0));

    for (final polyline in strokes) {
      final path = Path()
        ..moveTo(map(polyline.first).dx, map(polyline.first).dy);
      for (var i = 1; i < polyline.length; i++) {
        final p = map(polyline[i]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(RunePainter old) =>
      old.runeName != runeName ||
      old.color != color ||
      old.intensity != intensity;
}
