import 'package:flutter/material.dart';

import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// **IL PULSANTE PRINCIPALE DELL'ONBOARDING, UNO SOLO.** Ordine DP voce
/// 01.5, 15 settembre 2026.
///
/// Parole del fondatore sulla Carta di Nascita della build 2261: il pulsante
/// in basso *"e' illeggibile e dovrebbe essere giallo come nelle altre
/// schermate"*. Era un `FilledButton` senza stile, cioe' il viola del tema
/// col testo scuro sopra. **Il censimento della stessa passata** ne ha
/// trovati altri quattro fuori dallo standard: il Ritrovamento col viola,
/// l'Invito e il Primo Approdo col carattere dell'etichetta e senza la forma
/// a pillola, la Carta del Cielo e la Risonanza col carattere della lettura.
///
/// **Lo standard e' quello del Trionfo**, *"Chi altro ti accompagna"* e
/// *"La tua Carta di Nascita"*, che il fondatore ha indicato: fondo oro
/// pieno, testo scuro, la pillola, tutta la larghezza, il corpo a peso 600.
/// Da qui in poi nessuna schermata dell'onboarding scrive il suo: una guardia
/// lo pretende.
class PulsanteDelRisveglio extends StatelessWidget {
  const PulsanteDelRisveglio({
    super.key,
    required this.testo,
    required this.onPressed,
    this.chiave,
    this.palette,
  });

  final String testo;

  /// Nullo, il pulsante e' spento e lo dice col suo oro attenuato.
  final VoidCallback? onPressed;

  /// La chiave del `FilledButton`, per le prove che lo cercano e lo toccano.
  final Key? chiave;

  /// La tavolozza, quando chi monta il pulsante ne ha una sua; altrimenti
  /// quella del Maestro in scena.
  final MaestroPalette? palette;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: chiave,
        style: FilledButton.styleFrom(
          backgroundColor: p.gold,
          foregroundColor: p.deepest,
          disabledBackgroundColor: p.gold.withValues(alpha: 0.3),
          disabledForegroundColor: p.deepest,
          padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.md, horizontal: SpacingTokens.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          testo,
          textAlign: TextAlign.center,
          style: TypographyTokens.corpo(weight: 600).copyWith(color: p.deepest),
        ),
      ),
    );
  }
}
