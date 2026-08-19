import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA RIGA DI MESSA A PUNTO DEL MOVIMENTO. Ordine AR voce 01.
///
/// **Perche' esiste.** Per tre ordini di fila il cielo che non si muove e'
/// stato descritto a parole, e a parole non si distingue un sensore spento da
/// una formula sbagliata da un cielo che si ferma. Qui il telefono lo dice da
/// solo: se l'accelerometro vive, di quanto e' inclinato, e quanti punti sta
/// correndo il piano di fondo in questo istante.
///
/// **Si legge in due secondi.** `sensore vivo` falso vuol dire che la causa e'
/// li' e ogni altra ipotesi cade; una corsa vicina agli 80 punti col telefono
/// inclinato vuol dire che il movimento c'e' e il difetto e' altrove.
///
/// Sta nelle Impostazioni, in fondo, e non e' un pannello nascosto: chi non
/// sa cos'e' legge tre numeri e va oltre, chi collauda ha finito di indovinare.
class RigaDiMessaAPunto extends StatelessWidget {
  const RigaDiMessaAPunto({super.key});

  /// La corsa attesa del piano di fondo a inclinazione satura, fatto F3
  /// dell'ordine AR: 500 per 0,16.
  static const double corsaAttesaDelFondo =
      ParallaxController.tiltRangeDefault * ProfonditaDeiPiani.fondo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Si ASCOLTA, perche' questi numeri devono cambiare mentre il telefono si
    // inclina: una riga di messa a punto ferma direbbe la stessa bugia che
    // deve smascherare.
    final parallasse = context.watch<ParallaxController?>();
    if (parallasse == null) {
      return Text(
        'Movimento: nessun controller montato.',
        key: const Key('messa_a_punto_assente'),
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary),
      );
    }
    final corsa = parallasse.layerOffset(ProfonditaDeiPiani.fondo);
    final vivo = parallasse.sensorActive;
    return Padding(
      key: const Key('riga_di_messa_a_punto'),
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                vivo ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                size: 18,
                color: vivo ? palette.goldSoft : ColorTokens.textSecondary,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                vivo ? 'Sensore vivo' : 'Sensore spento',
                key: const Key('messa_a_punto_sensore'),
                style: TypographyTokens.etichetta().copyWith(
                  color: vivo ? palette.goldSoft : ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Inclinazione ${parallasse.tiltX.toStringAsFixed(2)} e '
            '${parallasse.tiltY.toStringAsFixed(2)}. Il piano di fondo corre '
            '${corsa.dx.toStringAsFixed(1)} punti su '
            '${corsaAttesaDelFondo.toStringAsFixed(0)} attesi a fondo corsa.',
            key: const Key('messa_a_punto_numeri'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
