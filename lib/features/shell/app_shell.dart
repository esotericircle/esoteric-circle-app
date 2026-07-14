import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/tap_wave.dart';
import '../../services/app_services.dart';
import '../maestri/domain_screen.dart';
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
  const AppShell({super.key, this.clock});

  /// Orologio iniettabile per i test, inoltrato al Santuario cosi' che striscia
  /// del giorno ed eroe centrale si possano fissare a una fascia oraria.
  final DateTime Function()? clock;

  // L'icona Maestro nella barra e' una porta diretta al dominio: seleziona il
  // Maestro (cosi' al ritorno resta il centro) e spinge la route del dominio.
  void _openDomain(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    Navigator.of(context).push(
      DomainScreen.route(
        maestro: maestro,
        services: context.read<AppServices>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    final Widget screen = switch (nav.view) {
      ShellView.santuario => SantuarioScreen(clock: clock),
      ShellView.passport => const CosmicPassport(),
    };

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      // Il Santuario e il Passport non mostrano le figure zodiacali: niente
      // asterismi, niente riquadro a portale nell'angolo. Il segno solare in
      // oro resta al cielo di nascita, non qui. Restano stelle, nebulose e
      // atmosfera. Nel Santuario le stelle tengono una zona franca attorno al
      // titolo in alto, cosi' nessuna cade su una lettera.
      body: CosmosBackground(
        showZodiac: false,
        starKeepOut: nav.view == ShellView.santuario
            ? SantuarioScreen.titleKeepOut
            : null,
        child: TapWaveLayer(
          // Il saluto vocale per nome non vive piu' qui: appartiene alla fine
          // dell'onboarding, "Il Risveglio". Nel Santuario resta solo la riga
          // personale sotto la Luna.
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
        onSantuario: nav.goToSantuario,
        onMaestro: (m) => _openDomain(context, m),
        onPassport: nav.goToPassport,
      ),
    );
  }
}
