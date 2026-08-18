import 'package:flutter/material.dart';

import '../../features/account/account_screen.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import 'user_avatar.dart';

/// LA PORTA DELL'ACCOUNT, una sola per tutta l'app. Ordine AI voce 02.
///
/// **Il difetto**: il menu' utente si vedeva solo nella home, dentro un widget
/// privato di quella schermata. Una porta che esiste in un posto solo non e'
/// una porta, e' un segreto: chi sta nel dominio di un Maestro non ha nessuna
/// via verso "Il tuo account".
///
/// **Un componente, un punto per testata, una destinazione.** Il tondo e' il
/// volto vero della persona (`UserAvatar`, coi suoi quattro ripieghi: foto,
/// emblema del segno, iniziali, sigillo neutro), il tocco apre sempre
/// `AccountScreen`. MAI una copia per schermata: e' la famiglia di difetti
/// piu' numerosa del progetto.
class PortaDellAccount extends StatelessWidget {
  const PortaDellAccount({super.key, this.misura = 40, this.suTocco});

  final double misura;

  /// Il tocco, quando la porta vive SOPRA il Navigator (la capsula
  /// dell'ordine AL voce 08): da lassu' `Navigator.of` non trova niente e la
  /// via gliela consegna chi la monta. Nullo dentro le schermate, dove vale
  /// la destinazione di sempre.
  final VoidCallback? suTocco;

  @override
  Widget build(BuildContext context) {
    // La stessa porta della pillola: senza scope non si dipinge e non si
    // casca, e l'enumerazione della prova garantisce che nelle testate vere
    // lo scope ci sia.
    final palette = MaestroScope.forse(context) ?? MaestroPalette.medora;
    return Semantics(
      button: true,
      label: 'Il tuo account',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          key: const Key('porta_dell_account'),
          customBorder: const CircleBorder(),
          onTap: suTocco ?? () => Navigator.of(context).push(AccountScreen.route()),
          child: Container(
            width: misura,
            height: misura,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipOval(
              // Il volto vero, coi ripieghi del componente: se i controller
              // del profilo non ci sono, `forUser` non si puo' costruire e si
              // mostra il sigillo neutro.
              child: _volto(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _volto(BuildContext context) {
    try {
      return UserAvatar.forUser(context, size: misura);
    } catch (errore) {
      // Una prova che monta la testata senza i controller del profilo non
      // deve cadere per un tondo: si mostra il sigillo neutro del Cerchio.
      return UserAvatar(size: misura);
    }
  }
}
