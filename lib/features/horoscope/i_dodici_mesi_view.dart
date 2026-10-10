import 'package:flutter/material.dart';

import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/i_dodici_mesi.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'il_periodo_view.dart';

/// **I DODICI MESI SULLA SCHEDA DELL'ANNO**, il fondatore il 1 ottobre 2026:
/// *"Hai messo infografica anche per oroscopo annuale? Magari per i 12 mesi
/// indicando i migliori o quello che ritieni migliore."*
///
/// La stessa forma delle barre della Settimana, che il fondatore ha scelto
/// ("Altezza e colore"): una barra per mese dell'anno della persona, alta
/// quanto la parte dei suoi giorni favorevoli e del colore del suo gradino,
/// la percentuale sopra il mese migliore, l'iniziale del mese sotto. Sotto le
/// barre la scala dei colori e, in parole, il mese migliore coi suoi giorni
/// favorevoli e i due che lo seguono.
class IDodiciMesiView extends StatelessWidget {
  const IDodiciMesiView({
    super.key,
    required this.mesi,
    required this.dominio,
    required this.palette,
  });

  final List<MeseDellAnno> mesi;
  final HoroscopeDomain dominio;
  final MaestroPalette palette;

  /// L'altezza della barra di un mese coi giorni tutti favorevoli.
  static const double altezzaPiena = 64;

  static const List<String> nomiDeiMesi = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];

  /// L'altezza della barra di una quota di giorni favorevoli: mai meno di
  /// quattro punti, perche' un mese quieto resta una barra e non sparisce.
  static double altezzaDi(double quota) =>
      (altezzaPiena * quota).clamp(4.0, altezzaPiena);

  /// La riga in parole: il mese migliore e i due che lo seguono.
  static String rigaDeiMigliori(List<MeseDellAnno> mesi, HoroscopeDomain d) {
    final tre = IDodiciMesi.migliori(mesi, d);
    final primo = tre.first;
    final altri = [for (final m in tre.skip(1)) nomiDeiMesi[m.da.month - 1]];
    final poi = altri.isEmpty
        ? ''
        : altri.length == 1
            ? ' Poi ${altri.first}.'
            : ' Poi ${altri.first} e ${altri.last}.';
    final quanti = primo.favorevoli == null
        ? '.'
        : ': ${primo.favorevoli![d.index]} giorni favorevoli su '
            '${primo.giorni}.';
    return 'Il mese migliore è ${nomiDeiMesi[primo.da.month - 1]}$quanti$poi';
  }

  @override
  Widget build(BuildContext context) {
    final migliore = IDodiciMesi.migliori(mesi, dominio, quanti: 1).first;
    final etichetta = TypographyTokens.etichetta();
    return Column(
      key: Key('oroscopo_anno_mesi_${dominio.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'I dodici mesi: ${[
            for (final m in mesi)
              m.favorevoli == null
                  ? '${nomiDeiMesi[m.da.month - 1]} ${m.livelli![dominio.index]} '
                      'su 5'
                  : '${nomiDeiMesi[m.da.month - 1]} '
                      '${m.favorevoli![dominio.index]} giorni favorevoli su '
                      '${m.giorni}'
          ].join(', ')}',
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final m in mesi)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // La percentuale esce dalla colonna stretta della
                          // sua barra (dodici barre in 300 punti): stretta
                          // nella colonna si leggeva a malapena (visto sul
                          // Realme il 1 ottobre 2026).
                          if (m == migliore)
                            SizedBox(
                              height: etichetta.fontSize! *
                                  MediaQuery.textScalerOf(context).scale(1) *
                                  1.3,
                              child: OverflowBox(
                                maxWidth: 64,
                                child: Text(
                                    '${(m.quota(dominio) * 100).round()}%',
                                    key: Key(
                                        'oroscopo_anno_percentuale_${dominio.name}'),
                                    maxLines: 1,
                                    style: etichetta.copyWith(
                                        color: ColorTokens.delLivello(
                                            m.gradino(dominio)),
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            key: Key('oroscopo_anno_barra_${dominio.name}_'
                                '${m.da.month}'),
                            height: altezzaDi(m.quota(dominio)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: ColorTokens.delLivello(m.gradino(dominio)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                nomiDeiMesi[m.da.month - 1][0].toUpperCase(),
                                maxLines: 1,
                                style: etichetta.copyWith(
                                    color: m == migliore
                                        ? palette.goldSoft
                                        : ColorTokens.textSecondary)),
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
        const LaScalaDelLivello(),
        const SizedBox(height: SpacingTokens.xs),
        Text(rigaDeiMigliori(mesi, dominio),
            key: Key('oroscopo_anno_migliori_${dominio.name}'),
            // In bianco, non in oro: nella scheda la prosa in oro e' una sola,
            // l'apertura (oroscopo_tipografia, "Un solo blocco in oro").
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
      ],
    );
  }
}
