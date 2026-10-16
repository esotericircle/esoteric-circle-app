import 'package:flutter/material.dart';

/// **L'OVALE CHE DICE DOVE METTERE IL VISO.** Ordine DS voce 06, 17 settembre
/// 2026.
///
/// Il fondatore: *"durante la scansione niente aiuta a mettere il viso nel
/// punto giusto"*. L'ovale sta al centro dell'inquadratura e ha la proporzione
/// di un volto che la riempie alla distanza giusta: chi ci entra con la faccia
/// e' abbastanza vicino, e abbastanza centrato, perche' il rilevatore lo
/// prenda.
///
/// **E' UNA GUIDA, NON UN RILEVAMENTO**, la stessa legge della sagoma
/// dell'ordine CR voce 01. Senza volto l'ovale resta tenue, e si accende solo
/// quando il motore ha davvero misurato un volto in questo fotogramma: un ovale
/// acceso davanti a un muro direbbe che la macchina sta trovando qualcosa.
class OvaleDellInquadratura extends CustomPainter {
  const OvaleDellInquadratura({
    required this.colore,
    required this.agganciato,
  });

  final Color colore;

  /// Vero solo quando il motore ha misurato un volto nel fotogramma.
  final bool agganciato;

  /// Quanta larghezza dell'inquadratura prende l'ovale.
  static const double quotaDellaLarghezza = 0.64;

  /// Quanta altezza dell'inquadratura prende l'ovale.
  static const double quotaDellAltezza = 0.74;

  /// Il rettangolo dell'ovale, centrato: una funzione sola per chi disegna e
  /// per chi prova.
  static Rect rettangoloIn(Size size) => Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * quotaDellaLarghezza,
        height: size.height * quotaDellAltezza,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final ovale = rettangoloIn(size);
    // Fuori dall'ovale la scena si abbassa, cosi' l'occhio va dentro.
    final velo = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(ovale);
    canvas.drawPath(
      velo,
      Paint()..color = Colors.black.withValues(alpha: agganciato ? 0.30 : 0.42),
    );
    // L'alone e il filo.
    canvas.drawOval(
      ovale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = colore.withValues(alpha: agganciato ? 0.35 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawOval(
      ovale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = agganciato ? 3 : 2
        ..color = colore.withValues(alpha: agganciato ? 0.95 : 0.55),
    );
  }

  @override
  bool shouldRepaint(OvaleDellInquadratura oldDelegate) =>
      oldDelegate.colore != colore || oldDelegate.agganciato != agganciato;
}
