import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// **"FATTO", IN FONDO A UN FOGLIO CHE SI LEGGE.** Il fondatore, il 1 ottobre
/// 2026, sulla nota della tradizione cinese: *"si apre dal basso un pannello
/// bolla informativa, ma poi non posso più chiuderla: inserisci in basso una
/// scritta "fatto" per chiudere oppure utilizzando il gesto del dito
/// dall'alto al basso per chiudere la scheda informativa. Controlla che sia
/// così dappertutto"*.
///
/// Sta fuori dal testo che scorre, quindi si vede sempre, e chiude il foglio
/// che lo contiene. Il gesto del dito vale in ogni foglio dell'app
/// ([ChiusuraColDito], in `velo_del_cerchio.dart`); questo pulsante va nei
/// fogli che si leggono soltanto, quelli che non hanno un altro pulsante.
class FattoDelFoglio extends StatelessWidget {
  const FattoDelFoglio({super.key, this.palette});

  /// La palette del foglio; senza, quella del Maestro che presiede.
  final MaestroPalette? palette;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.xs),
      child: Center(
        child: TextButton(
          key: const Key('foglio_fatto'),
          style: TextButton.styleFrom(
            minimumSize: const Size(160, 48),
            foregroundColor: p.goldSoft,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text('Fatto',
              style: TypographyTokens.etichetta()
                  .copyWith(color: p.goldSoft, letterSpacing: 1.2)),
        ),
      ),
    );
  }
}
