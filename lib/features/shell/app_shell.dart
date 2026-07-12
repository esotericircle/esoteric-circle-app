import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/tap_wave.dart';
import '../passport/cosmic_passport_screen.dart';
import '../santuario/santuario_screen.dart';
import 'navigation_controller.dart';
import 'santuario_bottom_bar.dart';

/// Contenitore principale dell'app: cosmo immersivo, schermata dello shell e
/// bottom bar. Lo shell mostra il Santuario oppure il Cosmic Passport; il
/// dominio di un Maestro e la chat vivono come route spinte sopra, con la loro
/// freccia Indietro e senza bottom bar.
///
/// Lo scorrimento della schermata attiva alimenta la parallasse dello sfondo;
/// ogni tocco propaga un'onda luminosa del colore del Maestro.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final maestro = context.watch<MaestroController>();

    final Widget screen = switch (nav.view) {
      ShellView.santuario => const SantuarioScreen(),
      ShellView.passport => const CosmicPassport(),
    };

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
            child: screen,
          ),
        ),
      ),
      bottomNavigationBar: SantuarioBottomBar(
        view: nav.view,
        activeMaestro: maestro.activeMaestro,
        onSantuario: nav.goToSantuario,
        onMaestro: nav.selectCentral,
        onPassport: nav.goToPassport,
      ),
    );
  }
}
