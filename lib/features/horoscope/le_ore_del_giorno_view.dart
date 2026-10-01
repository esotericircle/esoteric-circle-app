import 'package:flutter/material.dart';

import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/le_ore_del_giorno.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **LE ORE DEL GIORNO SULLA SCHEDA DEL GIORNO**, il fondatore il 1 ottobre
/// 2026: *"vorrei infografica a colori anche per oroscopo giornaliero come
/// per settimanale, mensile e annuale [...] Magari inserendo le 24h e
/// indicando le ore migliori"*.
///
/// La forma delle barre della Settimana: una barra per ora, alta quanto il
/// livello e del colore del suo gradino; sotto, l'ora d'inizio ogni tanto; e
/// in parole le ore migliori. Le ore sono quelle della tradizione
/// ([LeOreDelGiorno]): ventiquattro ore planetarie nell'Occidentale e nella
/// Vedica, dodici ore doppie nella Cinese.
class LeOreDelGiornoView extends StatelessWidget {
  const LeOreDelGiornoView({
    super.key,
    required this.ore,
    required this.dominio,
    required this.palette,
    required this.didascalia,
  });

  final List<OraDelGiorno> ore;
  final HoroscopeDomain dominio;
  final MaestroPalette palette;

  /// Che ore sono, in una riga ("Le ore planetarie, dall'alba di oggi
  /// all'alba di domani").
  final String didascalia;

  /// L'altezza della barra del livello 5.
  static const double altezzaPiena = 48;

  static String hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// La riga in parole delle ore migliori.
  static String rigaDelleMigliori(List<OraDelGiorno> ore, HoroscopeDomain d) {
    final fasce = LeOreDelGiorno.migliori(ore, d);
    final dette = [
      for (final (da, a) in fasce) 'dalle ${hm(da)} alle ${hm(a)}',
    ];
    final elenco = dette.length == 1
        ? dette.first
        : '${dette.take(dette.length - 1).join(', ')} e ${dette.last}';
    return dette.length == 1
        ? 'L\'ora migliore: $elenco.'
        : 'Le ore migliori: $elenco.';
  }

  @override
  Widget build(BuildContext context) {
    final etichetta = TypographyTokens.etichetta();
    // Sotto le barre l'ora d'inizio, una ogni tre nelle ventiquattro e una
    // ogni due nelle dodici: tutte non ci stanno.
    final ogni = ore.length > 12 ? 3 : 2;
    return Column(
      key: Key('oroscopo_ore_${dominio.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Le ore del giorno: ${[
            for (final o in ore)
              'dalle ${hm(o.da)} ${o.livelli[dominio.index]} su 5'
          ].join(', ')}',
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, o) in ore.indexed)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            key: Key('oroscopo_ora_barra_${dominio.name}_$i'),
                            height: altezzaPiena *
                                o.livelli[dominio.index].clamp(1, 5) /
                                5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: ColorTokens.delLivello(
                                  o.livelli[dominio.index]),
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: etichetta.fontSize! * 1.3,
                            child: i % ogni == 0
                                ? OverflowBox(
                                    maxWidth: 40,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('${o.da.hour}',
                                          maxLines: 1,
                                          style: etichetta.copyWith(
                                              color:
                                                  ColorTokens.textSecondary)),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(rigaDelleMigliori(ore, dominio),
            key: Key('oroscopo_ore_migliori_${dominio.name}'),
            style: TypographyTokens.corpo()
                .copyWith(color: palette.goldSoft, height: 1.4)),
        Text(didascalia,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.35)),
      ],
    );
  }
}
