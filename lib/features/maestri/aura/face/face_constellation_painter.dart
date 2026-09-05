import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';
import 'face_constellation.dart';

/// Disegna la costellazione del viso: le linee fra le stelle e le stelle che
/// pulsano, nel verde smeraldo e oro di Aura.
///
/// E' lo stesso disegno per il volto dal vivo, per la sagoma neutra e per la
/// card. Sulla card si alza [risalto] per rendere la costellazione molto
/// visibile sopra il volto sbiadito.
class FaceConstellationPainter extends CustomPainter {
  FaceConstellationPainter({
    required this.costellazione,
    required this.palette,
    this.pulsazione = 1.0,
    this.risalto = 1.0,
  });

  final FaceConstellation costellazione;
  final MaestroPalette palette;

  /// Da zero a uno: il respiro delle stelle. Fermo a uno per le catture.
  final double pulsazione;

  /// Da uno in su: quanto la costellazione e' accesa. Sulla card sale.
  final double risalto;

  @override
  void paint(Canvas canvas, Size size) {
    final stelle = costellazione.scalate(size.shortestSide);
    // Le linee: fili sottili che uniscono le stelle.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * risalto
      ..strokeCap = StrokeCap.round
      ..color =
          palette.goldSoft.withValues(alpha: (0.45 * risalto).clamp(0.0, 1.0));
    for (final l in costellazione.linee) {
      if (l[0] < stelle.length && l[1] < stelle.length) {
        canvas.drawLine(stelle[l[0]], stelle[l[1]], filo);
      }
    }

    // Le stelle: un nucleo verde acceso con un alone dorato che respira.
    for (var i = 0; i < stelle.length; i++) {
      final s = stelle[i];
      // Un respiro sfasato stella per stella, deterministico dall'indice.
      final fase = (pulsazione + i * 0.13) % 1.0;
      final battito = 0.75 + 0.25 * math.sin(fase * 2 * math.pi);
      final r = (3.0 + (i % 3)) * battito * risalto;

      canvas.drawCircle(
        s,
        r * 2.4,
        Paint()
          ..color =
              palette.gold.withValues(alpha: (0.22 * risalto).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        s,
        r,
        Paint()..color = palette.glow.withValues(alpha: (0.95).clamp(0.0, 1.0)),
      );
      canvas.drawCircle(
        s,
        r * 0.5,
        Paint()
          ..color =
              Colors.white.withValues(alpha: (0.9 * risalto).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(FaceConstellationPainter old) =>
      old.pulsazione != pulsazione ||
      old.risalto != risalto ||
      old.costellazione != costellazione;
}
