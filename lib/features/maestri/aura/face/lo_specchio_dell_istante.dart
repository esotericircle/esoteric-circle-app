import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import '../../../../core/face/espressione_dell_istante.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **LO SPECCHIO DELL'ISTANTE, la lettura dell'espressione a video.**
/// Ordine CR voce 07, 6 settembre 2026.
///
/// **PERCHE' E' UN RIQUADRO SEPARATO E NON UNA RIGA DEL RESPONSO.** L'ordine
/// impone che i tratti e l'espressione non si mescolino mai in una frase sola:
/// i tratti dicono come sei, l'espressione dice come sei ADESSO, e sono due
/// letture con due durate diverse. Un riquadro con un titolo suo e' il modo
/// piu' semplice perche' chi legge non le confonda.
///
/// **QUANDO NON C'E' NIENTE DA DIRE, NON DICE NIENTE.** Con i coefficienti
/// vuoti, o con un volto a riposo, questo riquadro sparisce del tutto invece di
/// inventare un'osservazione: e' la stessa disciplina del cancello della
/// scansione, dove il nulla e' una risposta onesta.
class LoSpecchioDellIstante extends StatelessWidget {
  const LoSpecchioDellIstante({
    super.key,
    required this.coefficienti,
    required this.palette,
  });

  /// I 52 coefficienti che il motore ha letto nell'istante dello scatto.
  final Map<FaceBlendshape, double> coefficienti;

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final segni = EspressioneDellIstante.leggi(coefficienti);
    if (segni.isEmpty) return const SizedBox.shrink();

    return Container(
      key: const Key('face_espressione'),
      margin: const EdgeInsets.only(top: SpacingTokens.lg),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.surfaceElevated.withValues(alpha: 0.85),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('In questo momento',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xs),
          // **LA DURATA SI DICHIARA.** Senza questa riga la persona porta
          // via l'osservazione come se fosse un tratto suo, che e' proprio
          // la confusione che l'ordine vieta.
          Text(
            'Questa lettura vale adesso e cambia con te: non parla di come '
            'sei, parla di cosa sta facendo il tuo viso.',
            style: TypographyTokens.corpo().copyWith(
                color: palette.textPrimary.withValues(alpha: 0.75),
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (final s in segni)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.osservazione,
                      style: TypographyTokens.corpo().copyWith(
                          color: palette.goldSoft,
                          fontWeight: FontWeight.w700)),
                  Text(s.specchio,
                      style: TypographyTokens.corpo()
                          .copyWith(color: palette.textPrimary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
