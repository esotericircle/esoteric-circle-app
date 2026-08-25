import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// IL FILO FRA LE TRE CARTE. Ordine BN voce 08.
///
/// Quando esce la terza carta, e PRIMA che Medora cominci a pensare, un filo
/// di luce parte dalla carta chiave e collega le tre carte per un istante.
/// Dice a colpo d'occhio che le tre carte sono **una lettura sola** e non tre
/// responsi affiancati.
///
/// **Parte sempre dalla chiave**, che e' la carta su cui la lettura poggia:
/// il filo non e' una decorazione che unisce da sinistra a destra, e' il modo
/// visivo di dire da dove il senso viene.
///
/// Con Riduci Movimento il filo compare **fermo e intero**, e non si salta:
/// chi ha tolto le animazioni non ha chiesto di rinunciare a sapere che le
/// tre carte si parlano.
class FiloFraLeCarte extends StatelessWidget {
  const FiloFraLeCarte({
    super.key,
    required this.centri,
    required this.dallaChiave,
    required this.avanzamento,
    required this.palette,
  });

  /// Quanto dura il filo, in millesimi: dentro la finestra fra 600 e 900 che
  /// l'ordine chiede, e finisce PRIMA che l'attesa cominci.
  static const Duration durata = Duration(milliseconds: 720);

  /// I centri delle tre carte, nell'ordine delle posizioni.
  final List<Offset> centri;

  /// Quale delle tre e' la chiave: e' da li' che il filo parte.
  final int dallaChiave;

  /// Da zero a uno.
  final double avanzamento;

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        key: const Key('stesa_filo'),
        painter: _PittoreDelFilo(
          centri: centri,
          dallaChiave: dallaChiave,
          avanzamento: avanzamento,
          colore: palette.gold,
        ),
      ),
    );
  }
}

class _PittoreDelFilo extends CustomPainter {
  _PittoreDelFilo({
    required this.centri,
    required this.dallaChiave,
    required this.avanzamento,
    required this.colore,
  });

  final List<Offset> centri;
  final int dallaChiave;
  final double avanzamento;
  final Color colore;

  @override
  void paint(Canvas canvas, Size size) {
    if (centri.length < 2 || avanzamento <= 0) return;
    // L'ordine in cui il filo tocca le carte: dalla chiave, poi le altre nel
    // loro ordine naturale.
    final ordine = <int>[
      dallaChiave,
      for (var i = 0; i < centri.length; i++)
        if (i != dallaChiave) i,
    ];
    // Il filo entra e poi si spegne: sale fino a meta' e cala.
    final vigore = avanzamento < 0.5
        ? avanzamento * 2
        : (1 - (avanzamento - 0.5) * 2).clamp(0.0, 1.0);

    final penna = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = colore.withValues(alpha: 0.85 * vigore);

    // **UN SOLO TRACCIATO, e non tre disegni.** Il costo per fotogramma e' la
    // ragione: una polilinea sola con un velo sopra sta largamente sotto il
    // budget, mentre tre `drawLine` con altrettanti Paint no.
    final tracciato = Path()..moveTo(centri[ordine[0]].dx, centri[ordine[0]].dy);
    for (var i = 1; i < ordine.length; i++) {
      tracciato.lineTo(centri[ordine[i]].dx, centri[ordine[i]].dy);
    }
    canvas.drawPath(tracciato, penna);

    // Il capo del filo, sulla chiave: dice da dove parte.
    canvas.drawCircle(
      centri[dallaChiave],
      3.5 * vigore,
      Paint()..color = colore.withValues(alpha: 0.9 * vigore),
    );
  }

  @override
  bool shouldRepaint(_PittoreDelFilo vecchio) =>
      vecchio.avanzamento != avanzamento ||
      vecchio.dallaChiave != dallaChiave ||
      vecchio.centri != centri;
}
