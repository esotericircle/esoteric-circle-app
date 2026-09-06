import 'package:flutter/material.dart';

/// **IL FASCIO CHE MISURA.** Ordine CR voce 09, 6 settembre 2026.
///
/// **Parole del fondatore**: *"mentre un fascio di luce fa la scansione"*.
///
/// **NON E' UN'ANIMAZIONE DECORATIVA, e la differenza si vede.** Un fascio che
/// scorre sempre uguale direbbe una bugia: direbbe che la macchina sta
/// misurando anche quando non sta misurando niente. Qui la lama di luce scende
/// **con la tenuta della posa**: si muove mentre l'angolo e' dentro soglia, e
/// si ferma nell'istante in cui la persona lo perde. Chi guarda impara in due
/// secondi che il movimento della luce e' il progresso vero.
///
/// **RIDUCI MOVIMENTO, dichiarato**: l'ordine chiede che tutto regga anche col
/// movimento ridotto, e che in quel caso *il fascio non scorre, i punti
/// compaiono*. Qui il fascio riceve la sua quota gia' calcolata: chi lo monta
/// decide se farla salire nel tempo o portarla di colpo, e la scena col
/// movimento ridotto non anima la quota. Il disegno resta lo stesso.
class FascioDiScansione extends CustomPainter {
  const FascioDiScansione({
    required this.quota,
    required this.colore,
    required this.acceso,
  });

  /// Dove sta la lama, da zero in alto a uno in basso. E' il progresso della
  /// posa corrente, non un tempo che scorre per conto suo.
  final double quota;

  /// L'oro del Maestro.
  final Color colore;

  /// Falso finche' la testa non e' agganciata: prima di quel momento non c'e'
  /// niente da misurare, e una luce che scorre sul nulla e' l'ornamento che
  /// questa classe rifiuta di essere.
  final bool acceso;

  @override
  void paint(Canvas canvas, Size size) {
    if (!acceso || size.isEmpty) return;
    final y = size.height * quota.clamp(0.0, 1.0);

    // **L'ALONE PRIMA, LA LAMA DOPO.** Una riga netta su un volto sembra un
    // difetto dello schermo; con l'alone sotto diventa luce.
    final altezzaAlone = size.height * 0.06;
    canvas.drawRect(
      Rect.fromLTWH(0, y - altezzaAlone, size.width, altezzaAlone * 2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colore.withValues(alpha: 0),
            colore.withValues(alpha: 0.28),
            colore.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromLTWH(0, y - altezzaAlone, size.width, altezzaAlone * 2),
        ),
    );

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = colore.withValues(alpha: 0.85)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(FascioDiScansione vecchio) =>
      vecchio.quota != quota ||
      vecchio.acceso != acceso ||
      vecchio.colore != colore;
}
