import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/identity/profile_controller.dart';
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

    // Il Passport riceve l'identita' vera, quella che il Risveglio ha scritto
    // nel profilo. Senza questo passaggio la schermata ripiegava sul dato
    // d'esempio anche quando la persona aveva gia' dato la sua nascita, e
    // mostrava numero della vita, fase lunare e animale guida di un'altra data.
    // La fonte e' la stessa che usa il dominio del Maestro per il segno solare.
    final Widget screen = switch (nav.view) {
      ShellView.santuario => SantuarioScreen(clock: clock),
      ShellView.passport =>
        CosmicPassport(identity: context.watch<ProfileController>().identity),
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
        seed: 1,
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
      // **LA BARRA NON STA PIU' QUI**, e non e' un alleggerimento: dentro il
      // guscio si vedeva solo nel Santuario e nel Passport, perche' `ShellView`
      // ha due valori, mentre i domini, le chat e il Consiglio sono rotte
      // spinte SOPRA il guscio, col proprio Scaffold. Vive adesso in
      // `BarraDelCerchio`, sopra il Navigator, che e' il solo punto da cui si
      // vedono anche quelle. Lasciarla anche qui vorrebbe dire due barre in
      // home, che e' il difetto che questo spostamento chiude.
    );
  }
}
