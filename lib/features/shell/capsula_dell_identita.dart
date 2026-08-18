import 'package:flutter/material.dart';

import '../../design_system/components/borsellino.dart';
import '../../design_system/components/porta_dell_account.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import 'barra_del_cerchio.dart';

/// LA CAPSULA DELL'IDENTITA', UNA SOLA IN TUTTA L'APP. Ordine AL voce 08,
/// forma decisa da Mauro.
///
/// In alto a destra, persistente e uguale in tutte le schermate: SOPRA il
/// volto della persona (la porta dell'account, coi suoi quattro ripieghi) e
/// SOTTO il saldo Eos con la moneta d'oro di Mauro come icona. Vive SOPRA il
/// Navigator come la barra, ed e' per questo che le testate hanno perso la
/// loro copia di pillola e porta: la regola delle due porte vale anche qui,
/// il volto e il saldo vivono in un posto solo.
///
/// Il tocco sul volto apre AccountScreen, il tocco sul saldo apre il
/// borsellino come sempre: le vie passano dalla navigazione della barra,
/// perche' da quassu' `Navigator.of` non trova niente.
///
/// **Dove NON si vede, dichiarato**: sulle soglie del Risveglio la persona
/// non ha ancora un volto ne' un saldo, e una capsula sopra il rito
/// d'ingresso sarebbe una promessa vuota. Tutte le altre schermate la
/// portano, comprese quelle senza barra: e' questa la differenza fra le due
/// leggi.
const Set<String> soglieSenzaCapsula = {
  'OnboardingScreen',
  'MaestroRevealScreen',
  'ArtIntroScreen',
};

/// Vero se su questa schermata la capsula si vede.
bool capsulaSiVede(String? schermata) =>
    !soglieSenzaCapsula.contains(schermata);

class CapsulaDellIdentita extends StatefulWidget {
  const CapsulaDellIdentita({
    super.key,
    required this.observatore,
    required this.child,
  });

  final OsservatoreDellaPila observatore;
  final Widget child;

  /// LA LARGHEZZA CHE SI PRENDE, in punti logici, con l'aria attorno.
  ///
  /// La leggono i doni del giorno e l'angolo delle barre per riservarle lo
  /// spazio: le icone scorrono alla sua sinistra e sfumano sparendo sotto di
  /// lei. E' una misura che descrive una resa e la prova la confronta con
  /// la larghezza vera della capsula, 75,3 punti con la pillola verticale e
  /// la cifra a cinque posti riservati.
  static const double larghezza = 80;

  @override
  State<CapsulaDellIdentita> createState() => _CapsulaDellIdentitaState();
}

class _CapsulaDellIdentitaState extends State<CapsulaDellIdentita> {
  String? _schermata;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    _pilaCambiata();
  }

  @override
  void dispose() {
    widget.observatore.cambi.removeListener(_pilaCambiata);
    super.dispose();
  }

  void _pilaCambiata() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(
            () => _schermata = widget.observatore.schermataInCima());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Stack(
      children: [
        widget.child,
        if (capsulaSiVede(_schermata))
          Positioned(
            top: mq.padding.top + SpacingTokens.xs,
            right: SpacingTokens.xs,
            child: Container(
              key: const Key('capsula_dell_identita'),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusPill),
                // Lo stesso velo della pillola: un colore, mai una
                // sfocatura per fotogramma.
                color: palette.deepest.withValues(alpha: 0.45),
                border: Border.all(
                    color: palette.goldSoft.withValues(alpha: 0.25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PortaDellAccount(
                    misura: 32,
                    suTocco: NavigazioneDellaBarra.allAccount,
                  ),
                  const SizedBox(height: 4),
                  // La pillola VERA, non una copia: porta con se' la veste
                  // mista, il conto che sale e il bersaglio del volo degli
                  // Eos, che ora atterra qui da ogni schermata. In forma
                  // VERTICALE, moneta sopra e cifra sotto, cosi' la capsula
                  // resta stretta e i titoli delle barre non perdono punti.
                  SegnoDelBorsellino(
                    compatta: true,
                    verticale: true,
                    monetaDOro: true,
                    contestoDelFoglio:
                        NavigazioneDellaBarra.contestoDelNavigatore,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
