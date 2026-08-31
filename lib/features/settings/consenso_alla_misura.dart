import 'package:flutter/material.dart';

import '../../core/misura/misura_del_ritorno.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA DOMANDA SULLA MISURA. Ordine CC voce 09.
///
/// **Il consenso si chiede, e chi dice no usa l'app intera.** E' il vincolo
/// della voce, e non e' negoziabile: questa domanda non blocca niente, non
/// torna se la risposta e' stata data, e non ha una risposta preselezionata.
///
/// **Non e' un banner dei cookie.** Non c'e' una scelta grande e una piccola,
/// non c'e' un colore che spinge, e il no non ha bisogno di essere cercato:
/// due pulsanti uguali, uno accanto all'altro.
///
/// **Dice cosa si conta, non promesse.** Le cinque cose che l'app registra
/// sono nominate una per una: chi decide deve poter sapere su cosa decide.
class DomandaDellaMisura extends StatelessWidget {
  const DomandaDellaMisura({super.key, required this.onRisposta});

  /// Chiamata col si' o col no. Chi la monta scrive la risposta e chiude.
  final ValueChanged<bool> onRisposta;

  /// La mostra come foglio dal basso, e torna la risposta.
  ///
  /// **Non si mostra mai due volte**: chi la chiama guarda prima
  /// [ConsensoDellaMisura.letto].
  static Future<bool?> chiedi(BuildContext context) {
    return foglioDelCerchio<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (foglio) => DomandaDellaMisura(
        onRisposta: (si) => Navigator.of(foglio).pop(si),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Container(
      key: const Key('misura_domanda'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Possiamo contare i gesti, non te?',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            ParagrafiDiLettura(
              testo: 'Per capire cosa funziona il Cerchio conta cinque cose: '
                  'le aperture, i riti cominciati, i riti finiti, i ritorni da '
                  'una notifica e i responsi condivisi. Sono numeri per giorno, '
                  'senza nome e senza niente che tu abbia scritto. Se dici no '
                  'l\'app resta esattamente com\'è, tutta.',
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('misura_no'),
                    onPressed: () => onRisposta(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.55)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text('No, grazie',
                        style: TypographyTokens.etichetta()),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('misura_si'),
                    onPressed: () => onRisposta(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.55)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text('Va bene',
                        style: TypographyTokens.etichetta()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
