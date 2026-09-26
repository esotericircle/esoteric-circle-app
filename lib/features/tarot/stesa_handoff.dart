import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// IL VELO NERO con cui la stesa passa dall'apertura alla scena viva.
///
/// **Era BIANCO, ed e' il rilievo del fondatore del 29 agosto 2026**, verbatim:
/// "quando entro nella funzionalita' dei tarocchi c'e' un flash bianco che
/// introduce la schermata, voglio che questo flash sia nero e che ci sia sempre
/// ad ogni cambio schermata".
///
/// **Da dove veniva il bianco**, perche' non era un capriccio: l'intro
/// cinematografica che produce Mauro finisce in bianco pieno, e questo velo
/// partiva dallo stesso bianco per coprire il taglio fra il video e l'app. Ma
/// l'intro si vede una volta sola, all'avvio, mentre questo velo si vede a OGNI
/// ingresso nella stesa: nove volte su dieci copriva un taglio che non c'era, e
/// lampeggiava bianco in mezzo a un'app notturna.
///
/// **Adesso e' il nero del Passaggio del Cerchio**, cioe' lo stesso colore con
/// cui ogni schermata dell'app entra e esce. Un colore solo, un posto solo.
///
/// Quando la schermata si apre senza apertura, come nei test e nell'anteprima,
/// il velo si salta del tutto.
class HandoffVeil extends StatelessWidget {
  const HandoffVeil({super.key, required this.opacity});

  /// Da 1, bianco pieno, a 0, velo sparito.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: PassaggioDelCerchio.nero
              .withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}

/// La scia di stelle che una carta lascia mentre vola nel suo slot.
class StardustTrail extends StatelessWidget {
  const StardustTrail({
    super.key,
    required this.progress,
    required this.palette,
    required this.seed,
  });

  /// Il punto del volo, da 0 a 1.
  final double progress;

  final MaestroPalette palette;

  /// Da qui nasce la disposizione delle scintille: stessa carta, stessa scia.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TrailPainter(
          progress: progress,
          palette: palette,
          seed: seed,
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.progress,
    required this.palette,
    required this.seed,
  });

  final double progress;
  final MaestroPalette palette;
  final int seed;

  /// Quante scintille compongono la scia.
  static const int scintille = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rnd = math.Random(seed);
    for (var i = 0; i < scintille; i++) {
      // Ogni scintilla resta indietro di un poco rispetto alla carta.
      final ritardo = i / scintille * 0.5;
      final t = progress - ritardo;
      if (t <= 0) continue;
      final vita = (1 - t / (1 - ritardo)).clamp(0.0, 1.0);
      final dx = (rnd.nextDouble() - 0.5) * size.width * 0.7;
      final dy = size.height * (1 - t) + (rnd.nextDouble() - 0.5) * 12;
      final r = (0.8 + rnd.nextDouble() * 1.6) * vita;
      canvas.drawCircle(
        Offset(size.width / 2 + dx, dy),
        r,
        Paint()..color = palette.goldSoft.withValues(alpha: 0.65 * vita),
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.progress != progress || old.seed != seed;
}
