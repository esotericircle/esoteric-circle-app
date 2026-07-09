import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/tap_wave.dart';
import '../home/home_screen.dart';
import '../maestri/maestro_screen.dart';
import 'navigation_controller.dart';
import 'santuario_bottom_bar.dart';

/// Contenitore principale dell'app: cosmo immersivo, schermata attiva e bottom
/// bar dei Maestri. Le schermate restano vive in un IndexedStack, cosi' il
/// ritorno al Santuario e' immediato (cold start percepito nullo).
///
/// Lo scorrimento della schermata attiva alimenta la parallasse dello sfondo;
/// ogni tocco propaga un'onda luminosa del colore del Maestro.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: CosmosBackground(
        child: TapWaveLayer(
          child: NotificationListener<ScrollNotification>(
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
        ),
      ),
      bottomNavigationBar: SantuarioBottomBar(
        current: nav.current,
        onSelected: nav.goTo,
      ),
    );
  }
}
