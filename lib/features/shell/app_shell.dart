import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/tap_wave.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../home/home_screen.dart';
import '../maestri/maestro_screen.dart';
import 'navigation_controller.dart';
import 'santuario_bottom_bar.dart';

/// Contenitore principale dell'app: cosmo immersivo, schermata attiva e bottom
/// bar dei Maestri. Le schermate restano vive in un IndexedStack, cosi' il
/// ritorno al Santuario e' immediato (cold start percepito nullo).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Coachmark mostrato una sola volta per sessione, al primo ingresso.
  static bool _coachmarkShown = false;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showCoach = false;

  @override
  void initState() {
    super.initState();
    if (!AppShell._coachmarkShown) {
      AppShell._coachmarkShown = true;
      _showCoach = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: CosmosBackground(
        child: TapWaveLayer(
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  context
                      .read<ParallaxController>()
                      .updateScroll(notification.metrics.pixels);
                  return false;
                },
                child: IndexedStack(
                  index: nav.index,
                  children: const [
                    HomeScreen(),
                    MaestroScreen(maestro: Maestro.medora),
                    MaestroScreen(maestro: Maestro.aura),
                    MaestroScreen(maestro: Maestro.caligo),
                  ],
                ),
              ),
              if (_showCoach)
                _Coachmark(onDismiss: () => setState(() => _showCoach = false)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SantuarioBottomBar(
        current: nav.current,
        onSelected: nav.goTo,
      ),
    );
  }
}

/// Coachmark gentile: i tre Maestri sono sempre con te, cambiali dalla barra.
class _Coachmark extends StatelessWidget {
  const _Coachmark({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              left: SpacingTokens.lg,
              right: SpacingTokens.lg,
              bottom: SpacingTokens.xxxl + SpacingTokens.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.surfaceElevated, palette.deepest],
                    ),
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusLg),
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'I tre Maestri sono sempre con te. Cambiali quando vuoi dalla barra qui in basso.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.body(size: TypographyTokens.guide)
                        .copyWith(height: 1.45),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Icon(Icons.keyboard_arrow_down,
                    color: palette.goldSoft, size: 28),
                Text('Ho capito',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
