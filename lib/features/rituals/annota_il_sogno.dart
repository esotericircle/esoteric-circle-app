import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac_controller.dart';
import '../../core/rituals/diario_dei_sogni.dart';
import '../../core/rituals/guide_animal_derivation.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../sigilli/regia_del_cammino.dart';

/// ANNOTA IL SOGNO, E RILEGGILO. Ordine BX voce 10.
///
/// **Perche' esiste.** Tre voci del sentiero dell'Albero parlano di sogni
/// ANNOTATI, e nell'app non si poteva annotare niente: il rito della notte
/// mandava alla regia il gesto e basta. Queste due porte sono la funzione che
/// mancava, non un abbellimento.
///
/// **Il testo resta sul telefono**: il quaderno vive in `DiarioDeiSogni`, che
/// non parla col server. Alla regia arrivano i SIMBOLI scelti, mai le parole.
Future<void> annotaIlSogno(BuildContext context) async {
  final palette = MaestroScope.of(context);
  final diario = context.read<DiarioDeiSogni>();
  final scelti = <String>{};
  final parole = TextEditingController();
  final salvato = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
    ),
    builder: (foglio) => Padding(
      padding: EdgeInsets.only(
          left: SpacingTokens.lg,
          right: SpacingTokens.lg,
          top: SpacingTokens.lg,
          bottom: MediaQuery.viewInsetsOf(foglio).bottom + SpacingTokens.lg),
      child: StatefulBuilder(
        builder: (foglio, ridisegna) => Column(
          key: const Key('annota_il_sogno'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Annota il tuo sogno',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
            ParagrafiDiLettura(
              testo: 'Scegli i simboli che hai visto e scrivi ciò che '
                  'ricordi. Resta sul tuo telefono.',
              stile: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                for (final simbolo in DiarioDeiSogni.simboliOfferti)
                  _ChipDelSimbolo(
                    simbolo: simbolo,
                    scelto: scelti.contains(simbolo),
                    palette: palette,
                    onTocco: () => ridisegna(() {
                      if (!scelti.remove(simbolo)) scelti.add(simbolo);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              key: const Key('annota_parole'),
              controller: parole,
              maxLines: 4,
              minLines: 2,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cosa hai sognato',
                hintStyle: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
                filled: true,
                fillColor: palette.deepest.withValues(alpha: 0.45),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusMd),
                  borderSide: BorderSide(
                      color: palette.gold.withValues(alpha: 0.35)),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('annota_salva'),
                onPressed: scelti.isEmpty && parole.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(foglio).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.gold,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(48)),
                child: Text('Custodisci il sogno',
                    style: TypographyTokens.etichetta()),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (salvato != true) {
    parole.dispose();
    return;
  }
  await diario.annota(simboli: scelti.toList(), parole: parole.text);
  parole.dispose();
  if (!context.mounted) return;
  // **ALLA REGIA VANNO I SIMBOLI, MAI LE PAROLE.** Il cammino deve poter dire
  // "lo stesso simbolo torna in due sogni" e "il tuo Animale compare in un
  // sogno": per tutte e due bastano i simboli.
  // **E SE FRA I SIMBOLI C'E' IL PROPRIO ANIMALE GUIDA**, il cammino lo deve
  // sapere: e' una delle tre voci del corpus, e l'animale di una persona lo
  // decide il suo segno, non una scelta.
  final segno = context.read<ZodiacController>().sunSign;
  final mio = segno == null
      ? null
      : GuideAnimalDerivation.forSign(segno).name.toLowerCase();
  final ceIlMio = mio != null &&
      scelti.any((s) => s.toLowerCase() == mio);
  await RegiaDelCammino.dopoUnGesto(
    context,
    'sogno_annotato',
    dettagli: {
      'simbolo': scelti.toList(),
      if (ceIlMio) 'animale_guida': const ['si'],
    },
  );
}

/// LA RILETTURA: si torna su un sogno annotato, e conta **quanti giorni**
/// erano passati.
Future<void> rileggiUnSogno(BuildContext context, SognoAnnotato sogno) async {
  final palette = MaestroScope.of(context);
  final diario = context.read<DiarioDeiSogni>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: palette.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
    ),
    builder: (foglio) => Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        key: const Key('rileggi_il_sogno'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Il sogno del ${sogno.quando.day}/${sogno.quando.month}',
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          if (sogno.simboli.isNotEmpty)
            Text(sogno.simboli.join(', '),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.sm),
          if (sogno.parole.isNotEmpty)
            ParagrafiDiLettura(
              testo: sogno.parole,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
        ],
      ),
    ),
  );
  final giorni = await diario.rileggi(sogno);
  if (!context.mounted) return;
  // **A DISTANZA DI GIORNI, e il numero lo porta il gesto**: rileggere il
  // sogno di stanotte non e' tornarci sopra.
  // **A DISTANZA DI GIORNI VUOL DIRE ALMENO UNO.** Rileggere stanotte il
  // sogno di stanotte non e' tornarci sopra, e il dettaglio parte solo quando
  // la distanza c'e' davvero: e' la memoria con la data che lo permette.
  await RegiaDelCammino.dopoUnGesto(
    context,
    'sogno_riletto',
    dettagli: {
      'giorni': ['$giorni'],
      if (giorni >= 1) 'a_distanza': const ['si'],
    },
  );
}

class _ChipDelSimbolo extends StatelessWidget {
  const _ChipDelSimbolo({
    required this.simbolo,
    required this.scelto,
    required this.palette,
    required this.onTocco,
  });

  final String simbolo;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('simbolo_$simbolo'),
      onTap: onTocco,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: SpacingTokens.xxs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: scelto
              ? palette.gold.withValues(alpha: 0.22)
              : palette.deepest.withValues(alpha: 0.45),
          border: Border.all(
              color: scelto
                  ? palette.gold
                  : palette.gold.withValues(alpha: 0.3)),
        ),
        child: Text(simbolo,
            style: TypographyTokens.didascalia().copyWith(
                color:
                    scelto ? palette.goldSoft : ColorTokens.textPrimary)),
      ),
    );
  }
}
