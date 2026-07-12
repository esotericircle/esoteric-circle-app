import 'package:flutter/material.dart';

import '../../core/astro/moon_phase.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'widgets/moon_widget.dart';

/// Segnaposto della schermata "Il cielo sopra di te".
///
/// Si apre toccando la zona del cielo e della Luna in cima al Santuario. Per
/// ora e' una destinazione segnaposto, in attesa della schermata vera del cielo
/// del momento (transiti, pianeti, fase) quando la costruiremo. Vale la regola
/// del mai un vicolo cieco: c'e' la freccia Indietro che torna al Santuario.
class SkyOverviewScreen extends StatelessWidget {
  const SkyOverviewScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(child: SkyOverviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final moon = MoonPhase.forDate(DateTime.now());

    return Scaffold(
      key: const Key('sky_overview_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Il cielo sopra di te',
            style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoonWidget(phase: moon, size: 92),
                  Text(
                    moon.italianName,
                    style: TypographyTokens.label(size: 12)
                        .copyWith(color: palette.goldSoft, letterSpacing: 1.4),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'Il cielo del momento',
                    style: TypographyTokens.display(size: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Transiti, pianeti e fase della Luna in una sola veduta. '
                    'Ancora dietro il velo, presto si dirada.',
                    style: TypographyTokens.body(size: 15)
                        .copyWith(color: palette.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SpacingTokens.radiusPill),
                      border: Border.all(
                          color: palette.gold.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Dietro il velo',
                      style: TypographyTokens.label(size: 11)
                          .copyWith(color: palette.gold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
