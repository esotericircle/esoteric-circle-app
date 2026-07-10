import 'package:flutter/material.dart';

import '../../core/feature_flags/feature_catalog.dart';
import '../../design_system/components/feature_grid.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/widgets/maestro_presence.dart';
import '../profile/profile_screen.dart';
import 'widgets/demo_controls.dart';
import 'widgets/maestro_selector.dart';

/// Home Il Santuario: punto di ritorno naturale dell'app.
///
/// In C1 mostra l'ossatura navigabile: intestazione, scelta del Maestro
/// (che cambia il tema) e una vetrina di funzioni di esempio nei tre stati
/// (attiva, Coming soon, premium bloccata).
///
/// Riferimento: Master Tecnico sezione 13, Home Il Santuario.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.md,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESOTERIC CIRCLE',
                              style: TypographyTokens.body(size: 12)
                                  .copyWith(
                                color: palette.goldSoft,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.xxs),
                            Text(
                              'Il Santuario',
                              style: TypographyTokens.display(size: 34),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Il tuo profilo',
                        icon: Icon(Icons.person_outline_rounded,
                            color: palette.goldSoft),
                        onPressed: () => openProfile(context),
                      ),
                      IconButton(
                        tooltip: 'Controlli dimostrativi',
                        icon: Icon(Icons.tune_rounded,
                            color: palette.goldSoft),
                        onPressed: () => showDemoControls(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'Scegli un Maestro e senti l\'intero cerchio cambiare colore.',
                    style: TypographyTokens.body(size: 15),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  const SantuarioPresence(height: 150),
                  const SizedBox(height: SpacingTokens.md),
                  const MaestroSelector(),
                  const SizedBox(height: SpacingTokens.xl),
                  const SectionTitle(
                    title: 'Le funzioni del cerchio',
                    subtitle:
                        'Tre stati: attiva, in arrivo, premium. Toccale per vederli.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: FeatureGrid(features: FeatureCatalog.all),
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
