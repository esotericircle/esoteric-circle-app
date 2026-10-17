import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/viaggio/l_animale_di_potere.dart';
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
/// zero: i dodici animali del catalogo sono un dato dell'app, non di nessuna
/// persona, quindi il bosco del Cerchio si puo' mostrare per intero senza
/// chiedere niente a nessuno, senza mandare niente da nessuna parte e senza
/// che l'identita' di una persona sfiori questa schermata.
///
/// **DALL'ORDINE FZ VOCE 01 E 02 NON C'E' PIU' UN SEGNO PER ABITANTE.** Qui
/// gli abitanti erano i dodici segni, ognuno col suo animale derivato dalla
/// tabella di curatela (abolita dall'ordine FZ): si elencano invece i dodici
/// animali del catalogo direttamente, che sono lo stesso insieme di dodici,
/// solo senza piu' il segno scritto sopra, perche' nessun segno elegge piu'
/// nessuno di loro.
///
/// **Cosa NON c'e', ed e' una scelta**: nessun conteggio di quante persone
/// portano un animale, che avrebbe richiesto di contare le persone; nessun
/// nome, nessun volto. Il giorno che il fondatore volesse i numeri del bosco,
/// quella sarebbe una porta diversa con una privacy diversa, e si dichiara
/// allora.
class BoscoDelCerchio extends StatelessWidget {
  const BoscoDelCerchio({super.key, this.mio});

  /// L'animale di chi guarda, per riconoscerlo fra gli altri. Nullo se non
  /// e' ancora stato riconosciuto.
  final String? mio;

  static Route<void> route({String? mio}) =>
      PassaggioDelCerchio.rotta<void>((_) => BoscoDelCerchio(mio: mio));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    // **IL BOSCO NON ADDITA IL TUO PRIMA CHE TU L'ABBIA INCONTRATO.**
    // Ordine DG voce 02, 12 settembre 2026.
    //
    // Chi arriva qui dalla lettura dell'animale porta il nome con se', e la
    // lettura si apre solo a riconoscimento fatto. Chi ci arrivasse per
    // un'altra strada, senza [mio], legge la cache di sessione del Diario
    // (ordine FZ voce 01): nessuna derivazione dal segno, mai piu'.
    final mioAnimale = mio ?? AnimaleDiPotere.dalCioCheSiSaGia()?.name;
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
                'per ciascuno. Questo è il bosco: guardando gli altri '
                'riconosci anche il tuo.',
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (final animale in AnimalCatalog.animals)
            _AbitanteDelBosco(
              animale: animale,
              eIlMio: mioAnimale != null && animale.name == mioAnimale,
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
    required this.animale,
    required this.eIlMio,
    required this.palette,
  });

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
              color:
                  eIlMio ? palette.gold : palette.gold.withValues(alpha: 0.3),
              width: eIlMio ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **NESSUN SEGNO PIU' QUI**, ordine FZ voce 01 e 02: qui c'era
            // il glifo dello zodiaco che elencava l'abitante per segno. Un
            // dato dell'animale, non del cielo: la stessa icona di riserva
            // che il Passaporto e la tessera dei compagni usano quando il
            // totem non c'e' ancora.
            Icon(Icons.pets, size: 22, color: palette.goldSoft),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eIlMio ? '${animale.name}, il tuo' : animale.name,
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
