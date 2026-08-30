import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/astro/zodiac.dart';
import '../../../../core/astro/zodiac_controller.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/guide_animal_derivation.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';

/// IL BOSCO DEL CERCHIO. Ordine BX voce 03.
///
/// **La condizione del corpus, verbatim**: "Guardi quali Animali Guida
/// accompagnano gli altri del Cerchio". Nomina QUALI animali, non di chi, e
/// non quanti: **il minimo che quella condizione richiede non contiene il dato
/// di nessuno.**
///
/// L'ordine dice di prendere il minimo e niente di piu', e qui il minimo e'
/// zero: il legame fra un segno e il suo animale e' una tabella di curatela
/// che l'app gia' porta con se', quindi il bosco del Cerchio si puo' mostrare
/// per intero senza chiedere niente a nessuno, senza mandare niente da nessuna
/// parte e senza che l'identita' di una persona sfiori questa schermata.
///
/// **Cosa NON c'e', ed e' una scelta**: nessun conteggio di quante persone
/// portano un animale, che avrebbe richiesto di contare le persone; nessun
/// nome, nessun volto. Il giorno che il fondatore volesse i numeri del bosco,
/// quella sarebbe una porta diversa con una privacy diversa, e si dichiara
/// allora.
class BoscoDelCerchio extends StatelessWidget {
  const BoscoDelCerchio({super.key, this.mio});

  /// L'animale di chi guarda, per riconoscerlo fra gli altri. Nullo se il
  /// segno non si sa ancora.
  final String? mio;

  static Route<void> route({String? mio}) => PassaggioDelCerchio.rotta<void>((_) => BoscoDelCerchio(mio: mio));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    final segno = () {
      try {
        return context.watch<ZodiacController>().sunSign;
      } catch (senzaSegno) {
        return null;
      }
    }();
    final mioAnimale =
        mio ?? (segno == null ? null : GuideAnimalDerivation.forSign(segno).name);
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Il bosco del Cerchio',
            style: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
      ),
      body: ListView(
        key: const Key('bosco_del_cerchio'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xxxl),
        children: [
          ParagrafiDiLettura(
            testo: 'Dodici animali accompagnano chi cammina nel Cerchio, uno '
                'per ogni segno. Questo è il bosco: guardando gli altri '
                'riconosci anche il tuo.',
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (final segnoDelBosco in Zodiac.values)
            _AbitanteDelBosco(
              segno: segnoDelBosco,
              animale: GuideAnimalDerivation.forSign(segnoDelBosco),
              eIlMio: mioAnimale != null &&
                  GuideAnimalDerivation.forSign(segnoDelBosco).name == mioAnimale,
              palette: palette,
            ),
        ],
      ),
    );
  }

  /// Apre il bosco e lo dice al cammino: guardare il bosco E' il gesto.
  static Future<void> apri(BuildContext context, {String? mio}) async {
    await RegiaDelCammino.dopoUnGesto(context, 'bosco');
    if (!context.mounted) return;
    await Navigator.of(context).push(BoscoDelCerchio.route(mio: mio));
  }
}

class _AbitanteDelBosco extends StatelessWidget {
  const _AbitanteDelBosco({
    required this.segno,
    required this.animale,
    required this.eIlMio,
    required this.palette,
  });

  final Zodiac segno;
  final GuideAnimal animale;
  final bool eIlMio;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Container(
        key: Key('bosco_${animale.name}'),
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: palette.surfaceElevated.withValues(alpha: eIlMio ? 0.9 : 0.5),
          border: Border.all(
              color: eIlMio
                  ? palette.gold
                  : palette.gold.withValues(alpha: 0.3),
              width: eIlMio ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **IL SIMBOLO VUOLE IL SUO CARATTERE.** Il font del display non
            // ha i glifi dello zodiaco: a schermo uscivano dodici rettangoli
            // vuoti, e nessuna prova li vede. L'ha visti l'anteprima. Il
            // carattere dei simboli e' quello dichiarato nel pubspec e usato
            // dalla carta natale.
            Text(segno.symbol,
                style: TextStyle(
                    fontFamily: 'NotoSansSymbols',
                    fontSize: 22,
                    color: palette.goldSoft)),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      eIlMio
                          ? '${animale.name}, il tuo'
                          : animale.name,
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(animale.summary,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
