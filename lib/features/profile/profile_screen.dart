import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac_controller.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/identity_controller.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/immersive_scaffold.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/widgets/identity_widgets.dart';

/// Anticipo del Cosmic Passport: il profilo che raccoglie i fatti identitari
/// fissi (segno solare, fase lunare di nascita, numero della vita) dal modello
/// riusabile. Domani questa schermata diventera' il passaporto vero e proprio.
void openProfile(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => const MaestroScope(child: ProfileScreen()),
  ));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final identity = context.watch<IdentityController>();
    final birth = context.watch<BirthIdentityController>();
    final sun = context.watch<ZodiacController>().sunSign;
    final facts = birth.facts;

    return ImmersiveScaffold(
      safeBottom: true,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                  SpacingTokens.sm, SpacingTokens.sm, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IL TUO PROFILO',
                            style: TypographyTokens.label(size: 13).copyWith(
                                color: palette.goldSoft, letterSpacing: 3)),
                        const SizedBox(height: SpacingTokens.xxs),
                        Text(identity.hasName ? identity.name : 'Cerchio',
                            style: TypographyTokens.display(size: 30)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chiudi',
                    icon: Icon(Icons.close_rounded, color: palette.goldSoft),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                    SpacingTokens.lg, SpacingTokens.xl),
                children: [
                  Text('Anticipo del tuo Cosmic Passport.',
                      style: TypographyTokens.body(size: TypographyTokens.guide)
                          .copyWith(color: ColorTokens.textSecondary)),
                  const SizedBox(height: SpacingTokens.md),
                  if (sun != null) ...[
                    _SunCard(signName: sun.italianName, symbol: sun.symbol),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                  if (facts != null) ...[
                    IdentityFactsSection(facts: facts),
                    const SizedBox(height: SpacingTokens.sm),
                    if (birth.details != null)
                      BirthSkyPortal(
                        details: birth.details!,
                        moonPhase: facts.moonPhase,
                      ),
                  ] else
                    DepthCard(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Text(
                        'Completa il tuo cielo di nascita per svelare la Luna e il numero della vita.',
                        style: TypographyTokens.body(size: TypographyTokens.guide)
                            .copyWith(color: ColorTokens.textSecondary, height: 1.4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunCard extends StatelessWidget {
  const _SunCard({required this.signName, required this.symbol});
  final String signName;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Center(
              child: Text(symbol,
                  style: TextStyle(
                      fontFamily: 'NotoSansSymbols',
                      fontSize: 34,
                      color: palette.goldSoft)),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IL TUO SEGNO SOLARE',
                    style: TypographyTokens.label(size: 12.5)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(signName, style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text('la tua essenza e la volonta\'',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
