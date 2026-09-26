import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../schede/la_luce_delle_schede.dart';
import '../schede/la_riga_delle_schede.dart';
import '../schede/la_scheda_dell_arte.dart';

/// **LA CATEGORIA INTERA, IN GRIGLIA.** Ordine EP voce 07, 26 settembre 2026.
///
/// Il fondatore, sui consigli presi dagli streaming: *"Vedi tutto"*,
/// *"Accanto al titolo della riga, apre la categoria intera in griglia."*
///
/// Tutte le arti della riga, nell'ordine del fondatore, nel formato
/// verticale, alla larghezza delle schede della home: 162 punti per la scala
/// del testo. **E' la larghezza che tiene i titoli interi**: la parola piu'
/// lunga della home, "Interpretazione", misura 161,3 punti col Cinzel vero.
/// Le colonne sono quante ci stanno con 12 punti fra una scheda e l'altra, e
/// la griglia si centra nello schermo.
class LaCategoriaIntera extends StatelessWidget {
  const LaCategoriaIntera({
    super.key,
    required this.chiave,
    required this.titolo,
    required this.arti,
  });

  final String chiave;
  final String titolo;
  final List<ArtEntry> arti;

  /// Lo spazio fra le schede e il margine minimo ai lati.
  static const double spazio = 12;

  /// Quante colonne stanno in [larghezzaVista], con schede larghe [scheda].
  static int colonne(double larghezzaVista, double scheda) {
    final n =
        ((larghezzaVista - 2 * spazio + spazio) / (scheda + spazio)).floor();
    return n < 1 ? 1 : n;
  }

  static Route<void> route({
    required BuildContext context,
    required String chiave,
    required String titolo,
    required List<ArtEntry> arti,
  }) {
    final maestro =
        context.read<MaestroController?>()?.activeMaestro ?? Maestro.medora;
    return PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          maestro: maestro,
          child: LaCategoriaIntera(chiave: chiave, titolo: titolo, arti: arti),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    final scala = MediaQuery.textScalerOf(context).scale(1);
    final larghezza = LaSchedaDellArte.larghezzaPer(
        FormatoDellaScheda.verticale,
        scalaDelTesto: scala,
        inCasa: true);
    return Scaffold(
      key: Key('categoria_intera_$chiave'),
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text(
          titolo,
          key: const Key('categoria_intera_titolo'),
          style: TypographyTokens.titoloDiSchermata()
              .copyWith(color: LaRigaDelleSchede.coloreDelTitolo),
        ),
      ),
      body: LaLuceDelleSchede(
        child: LayoutBuilder(builder: (context, spazioVista) {
          final n = colonne(spazioVista.maxWidth, larghezza);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                spazio, SpacingTokens.xs, spazio, SpacingTokens.xl),
            child: Center(
              child: SizedBox(
                width: n * larghezza + (n - 1) * spazio,
                child: Wrap(
                  spacing: spazio,
                  runSpacing: SpacingTokens.md,
                  children: [
                    for (final art in arti)
                      LaSchedaDellArte(
                        key: Key('categoria_intera_${chiave}_${art.id}'),
                        art: art,
                        maestro: maestroDiArte(context, art.id),
                        formato: FormatoDellaScheda.verticale,
                        larghezza: larghezza,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
