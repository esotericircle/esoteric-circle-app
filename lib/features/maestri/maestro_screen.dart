import 'package:flutter/material.dart';

import '../../core/feature_flags/feature_catalog.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/feature_grid.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'widgets/maestro_presence.dart';

/// Sezione di un Maestro.
///
/// In C1 e' una schermata di dominio navigabile: intestazione cerimoniale del
/// Maestro e le sue funzioni nei tre stati. Le esperienze vere (chat, oracoli,
/// avatar animati) arrivano nei checkpoint successivi.
class MaestroScreen extends StatelessWidget {
  const MaestroScreen({super.key, required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final features = FeatureCatalog.forMaestro(maestro);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Presenza del Maestro: avatar reale con respiro e aura.
                  MaestroPresence(maestro: maestro, height: 250),
                  const SizedBox(height: SpacingTokens.md),
                  DepthCard(
                    raised: true,
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Row(
                      children: [
                        Icon(maestro.icon, color: palette.goldSoft, size: 30),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(maestro.displayName,
                                  style: TypographyTokens.display(size: 26)),
                              Text(
                                maestro.domainTitle,
                                style: TypographyTokens.body(size: 13)
                                    .copyWith(color: palette.goldSoft),
                              ),
                              const SizedBox(height: SpacingTokens.xs),
                              Text(
                                maestro.tagline,
                                style: TypographyTokens.body(size: 14)
                                    .copyWith(
                                        color: ColorTokens.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  SectionTitle(
                    title: 'Funzioni di ${maestro.displayName}',
                    subtitle: 'Il dominio del Maestro, nei suoi tre stati.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverToBoxAdapter(
              child: FeatureGrid(features: features),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }
}
