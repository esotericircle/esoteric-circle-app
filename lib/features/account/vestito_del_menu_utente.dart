/// IL VESTITO DEL MENU' UTENTE. Ordine EA voce 17.
///
/// **Il fatto, dal fondatore**: *"il colore tema principale del menu' utente e'
/// il viola per le bolle e lo sfondo deve essere cosmico"*. La cattura della
/// 2272 mostrava *Il tuo account* su un nero uniforme, con bolle blu notte:
/// il colore del Cerchio a meta' trasparenza sopra il nero.
///
/// **Un vestito solo per tutte le schermate del menu'**, invece di otto
/// sfondi scritti a mano: la tavolozza neutra del Cerchio, che e' la viola, e
/// il cosmo dietro. Chi ha gia' il suo cosmo dentro il corpo chiede soltanto
/// la tavolozza (`soloIlColore`), per non disegnare due cieli uno sopra
/// l'altro.
library;

import 'package:flutter/material.dart';

import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';

class VestitoDelMenuUtente extends StatelessWidget {
  const VestitoDelMenuUtente({
    super.key,
    required this.child,
    this.seme = 7,
    this.soloIlColore = false,
  });

  final Widget child;

  /// Il seme del cielo: schermate diverse, stelle diverse.
  final int seme;

  /// Vero per le schermate che il cosmo lo disegnano gia' da se'.
  final bool soloIlColore;

  /// **IL VIOLA DELLE BOLLE.** La superficie alta della tavolozza neutra,
  /// piena: a meta' trasparenza sul nero diventava blu notte.
  static Color get bolla => MaestroPalette.neutral.surfaceElevated;

  /// Il viola del cerchietto dell'icona, un tono sotto la bolla.
  static Color get cerchietto => MaestroPalette.neutral.surface;

  @override
  Widget build(BuildContext context) {
    return MaestroScope(
      neutro: true,
      child: soloIlColore
          ? child
          : CosmosBackground(
              key: const Key('menu_utente_cosmo'),
              seed: seme,
              showZodiac: false,
              child: child,
            ),
    );
  }
}
