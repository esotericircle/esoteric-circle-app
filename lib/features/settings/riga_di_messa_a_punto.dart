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
    // I punti che vengono dal dito e non dalla mano, per poterli separare.
    final scorrimento = Offset(
        0, parallasse.puntiDelloScorrimento(ProfonditaDeiPiani.fondo));
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
          // **LA CORSA SI DICE SU TUTTI E DUE GLI ASSI. Ordine AS voce 01.**
          // Prima questa riga mostrava un numero solo, quello dell'asse X, e
          // ha nascosto meta' del fenomeno per un ordine intero: sull'asse Y
          // la corsa era gia' a 79 punti su 80 col telefono fermo in mano,
          // cioe' saturo in permanenza, e dalla riga non si poteva sapere.
          // Una misura che guarda meta' della cosa e' una misura che mente.
          // **LA RIGA DICE LA VERITA', E PRIMA NON LA DICEVA.** Ordine AW
          // voce 01, pezzo 4.
          //
          // Qui c'era scritto "Inclinazione dal riposo" seguito da
          // `parallasse.tiltX`. **Non e' l'inclinazione**: e' la RISPOSTA dopo
          // la zona morta e la curva, che satura a 1,00 molto prima che il
          // telefono sia inclinato tanto. Il fondatore ha letto 1,00 e ha
          // creduto di essere a fondo corsa di mano, **e la diagnosi e' stata
          // sbagliata tre volte per questo**.
          //
          // E i punti del piano di fondo sommavano il sensore e lo
          // SCORRIMENTO senza dirlo: con inclinazione dichiarata 0,00 il piano
          // verticale correva meno tredici punti, e quei punti erano il dito.
          //
          // Adesso ogni numero ha il suo nome e la sua unita'.
          Text(
            'Mano: ${parallasse.deviazioneInGradiX.toStringAsFixed(1)} e '
            '${parallasse.deviazioneInGradiY.toStringAsFixed(1)} gradi dal '
            'riposo, su ${ParallaxController.fondoCorsaInGradi.toStringAsFixed(0)} '
            'a fondo corsa.',
            key: const Key('messa_a_punto_gradi'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          Text(
            'Risposta dopo la curva ${parallasse.rispostaX.toStringAsFixed(2)} '
            'e ${parallasse.rispostaY.toStringAsFixed(2)} su 1,00.',
            key: const Key('messa_a_punto_risposta'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          Text(
            'Piano di fondo: ${(corsa.dx - scorrimento.dx).toStringAsFixed(1)} e '
            '${(corsa.dy - scorrimento.dy).toStringAsFixed(1)} punti dalla '
            'mano, ${scorrimento.dy.toStringAsFixed(1)} dallo scorrimento, su '
            '${corsaAttesaDelFondo.toStringAsFixed(0)} attesi.',
            key: const Key('messa_a_punto_numeri'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          // **IL NUMERO CHE AVREBBE FATTO TROVARE IL DIFETTO DUE GIORNI FA.**
          // Col disegno legato al campione del sensore questa riga avrebbe
          // detto quindici, e nessuno avrebbe dovuto cercare oltre.
          Text(
            'Il cielo si ridipinge a '
            '${parallasse.fotogrammiAlSecondo.toStringAsFixed(0)} fotogrammi '
            'al secondo.',
            key: const Key('messa_a_punto_fotogrammi'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 2),
          // Il riposo imparato: se questi due numeri non somigliano a come si
          // sta tenendo il telefono, il difetto e' nell'apprendimento e non
          // nella corsa.
          Text(
            parallasse.riposoX == null
                ? 'Riposo non ancora imparato: nessuna lettura del sensore.'
                : 'Riposo imparato ${parallasse.riposoX!.toStringAsFixed(2)} e '
                    '${parallasse.riposoY!.toStringAsFixed(2)}: è come stai '
                    'tenendo il telefono adesso.',
            key: const Key('messa_a_punto_riposo'),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
