import 'package:flutter/material.dart';

import '../../core/onboarding/scheda_della_scelta.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// IL RIQUADRO DELLA SCELTA, uno solo per i due trionfi.
///
/// ORDINE 2163, VOCE 12. Sotto l'animale guida e sotto i tre angeli restava
/// mezzo schermo vuoto: qui vive il riquadro che dice le caratteristiche e la
/// ragione della scelta. La FORMA e' una sola, usata due volte: due copie
/// sarebbero due verita' che col tempo divergono. Il CONTENUTO nasce nel
/// generatore, in core/onboarding/scheda_della_scelta.dart: questa e' solo la
/// veste.
class RiquadroDellaScelta extends StatelessWidget {
  const RiquadroDellaScelta({
    super.key,
    required this.scheda,
    required this.palette,
  });

  final SchedaDellaScelta scheda;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // Senza caratteristiche il riquadro NON esiste: un riquadro vuoto o un
    // segnaposto direbbero che qualcosa sta per arrivare, e non e' vero.
    if (scheda.caratteristiche.isEmpty) return const SizedBox.shrink();

    return Container(
      key: const Key('riquadro_scelta'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        // Opaco, composto una volta per tutte: sotto passa il cosmo animato
        // e un velo trasparente lo lascerebbe leggere attraverso.
        color: Color.alphaBlend(
            palette.surfaceElevated.withValues(alpha: 0.5), palette.deepest),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < scheda.caratteristiche.length; i++) ...[
            if (i > 0) const SizedBox(height: SpacingTokens.sm),
            if (scheda.caratteristiche[i].titolo != null) ...[
              Text(scheda.caratteristiche[i].titolo!.toUpperCase(),
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.4)),
              const SizedBox(height: 2),
            ],
            Text(scheda.caratteristiche[i].testo,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          ],
          if (scheda.ragione != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: palette.goldSoft),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(scheda.ragione!,
                      key: const Key('riquadro_ragione'),
                      style: TypographyTokens.corpo()
                          .copyWith(color: palette.goldSoft, height: 1.35)),
                ),
              ],
            ),
          ],
          const SizedBox(height: SpacingTokens.xs),
          // Al minimo del token, non sotto: la gerarchia con la ragione la
          // fa il colore smorzato, non una misura che il clamp rialzerebbe.
          Text(scheda.chiave,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textMuted, height: 1.3)),
        ],
      ),
    );
  }
}
