import 'package:flutter/material.dart';

import '../../../../core/face/face_classifier.dart';
import '../../../../design_system/theme/maestro_palette.dart';

/// La sagoma neutra del volto: contorni canonici e un disegno essenziale.
///
/// Serve al ripiego tattile, dove non c'e' una foto, e come stand-in
/// deterministico per le anteprime, dove la fotocamera dal vivo non si cattura.
/// I contorni sono in un riquadro di mille per mille, cosi' la costellazione ci
/// si costruisce sopra come su un volto vero.
class FaceSilhouette {
  const FaceSilhouette._();

  /// I contorni canonici di un volto neutro, proporzioni gradevoli.
  static FaceContours contorni() {
    const cx = 500.0;
    const y0 = 100.0;
    const h = 800.0;

    List<Offset> lato(double frazione, double semi) {
      final y = y0 + h * frazione;
      return [Offset(cx - semi, y), Offset(cx + semi, y)];
    }

    final volto = <Offset>[
      const Offset(cx, y0),
      ...lato(0.06, 180),
      ...lato(0.22, 250),
      ...lato(0.30, 265),
      ...lato(0.45, 280),
      ...lato(0.55, 275),
      ...lato(0.72, 235),
      ...lato(0.82, 200),
      ...lato(0.86, 180),
      ...lato(0.94, 120),
      ...lato(0.98, 70),
      const Offset(cx, y0 + h),
    ];

    List<Offset> sopraccio(double centro) {
      const base = y0 + h * 0.30;
      return [
        Offset(centro - 60, base),
        Offset(centro, base - 10),
        Offset(centro + 60, base),
      ];
    }

    List<Offset> occhio(double centro) {
      const y = y0 + h * 0.36;
      return [
        Offset(centro - 45, y),
        Offset(centro + 45, y),
        Offset(centro, y - 22),
        Offset(centro, y + 22),
      ];
    }

    return FaceContours(
      volto: volto,
      sopraccioSx: sopraccio(cx - 120),
      sopraccioDx: sopraccio(cx + 120),
      occhioSx: occhio(cx - 100),
      occhioDx: occhio(cx + 100),
      nasoPonte: const [Offset(cx, y0 + h * 0.38)],
      nasoBase: const [
        Offset(cx - 30, y0 + h * 0.55),
        Offset(cx + 30, y0 + h * 0.55),
      ],
      labbroSopra: const [
        Offset(cx - 75, y0 + h * 0.72),
        Offset(cx + 75, y0 + h * 0.72),
      ],
      labbroSotto: const [
        Offset(cx - 75, y0 + h * 0.72 + 55),
        Offset(cx + 75, y0 + h * 0.72 + 55),
      ],
      guanciaSx: const Offset(cx - 280, y0 + h * 0.5),
      guanciaDx: const Offset(cx + 280, y0 + h * 0.5),
    );
  }
}

/// Disegna una sagoma neutra del volto, un ovale con pochi tratti essenziali,
/// perche' la costellazione abbia un volto su cui posarsi anche senza foto.
class FaceSilhouettePainter extends CustomPainter {
  FaceSilhouettePainter({required this.palette});

  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2;
    final ovale = Rect.fromCenter(
        center: Offset(cx, h * 0.5), width: w * 0.62, height: h * 0.82);
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = palette.gold.withValues(alpha: 0.28);
    canvas.drawOval(ovale, filo);

    final tenue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.18);

    // Sopracciglia.
    for (final segno in [-1, 1]) {
      final bx = cx + segno * w * 0.13;
      final by = h * 0.36;
      canvas.drawLine(Offset(bx - w * 0.07, by),
          Offset(bx + w * 0.07, by - h * 0.006), tenue);
    }
    // Occhi.
    for (final segno in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + segno * w * 0.11, h * 0.42),
            width: w * 0.11,
            height: h * 0.045),
        tenue,
      );
    }
    // Naso.
    canvas.drawLine(Offset(cx, h * 0.44), Offset(cx, h * 0.56), tenue);
    // Bocca.
    canvas.drawLine(Offset(cx - w * 0.09, h * 0.66),
        Offset(cx + w * 0.09, h * 0.66), tenue);
  }

  @override
  bool shouldRepaint(FaceSilhouettePainter old) => old.palette != palette;
}
