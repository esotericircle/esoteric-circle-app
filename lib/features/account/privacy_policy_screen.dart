import 'package:flutter/material.dart';

import '../../core/legal/privacy_policy.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA PAGINA DELLA PRIVACY POLICY. Ordine BH voce 07.
///
/// Monta il testo che vive in `core/legal/privacy_policy.dart`: qui solo la
/// forma, mai il contenuto. La pagina si legge, non si firma: i consensi
/// veri si danno dove servono (notifiche, sensori), come la policy stessa
/// racconta.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => const MaestroScope(child: PrivacyPolicyScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Privacy policy'),
      ),
      extendBodyBehindAppBar: false,
      body: CosmosBackground(
        child: ListView(
          key: const Key('privacy_policy_lista'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
              SpacingTokens.sm, SpacingTokens.md, SpacingTokens.xl),
          children: [
            Text('Ultimo aggiornamento: $dataDellaPolicy',
                key: const Key('privacy_policy_data'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.sm),
            Text(titolareDellaPolicy,
                style: TypographyTokens.corpo().copyWith(
                    color: ColorTokens.textPrimary, height: 1.5)),
            for (final sezione in sezioniDellaPolicy) ...[
              const SizedBox(height: SpacingTokens.lg),
              Text(sezione.titolo,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xs),
              Text(sezione.corpo,
                  style: TypographyTokens.corpo().copyWith(
                      color: ColorTokens.textSecondary, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
