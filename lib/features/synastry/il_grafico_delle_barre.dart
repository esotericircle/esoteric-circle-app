import 'package:flutter/material.dart';

import '../../core/synastry_evolutiva/le_barre_della_sinastria.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL GRAFICO DELLE BARRE DELLA SINASTRIA EVOLUTIVA.** Ordine GD voce
/// GD.19, 23 ottobre 2026: un tipo solo per tutte le bolle della funzione
/// (il fondatore: *"usa la stessa, così l'utente non deve imparare a
/// leggerne una diversa per ogni bolla nella stessa funzionalità"*).
///
/// Ogni riga e' una [BarraDellaSinastria] del calcolo
/// ([LeBarreDellaSinastria]): il nome a sinistra, la barra al centro piena
/// quanto il valore, la percentuale a destra, scritta dal valore stesso.
/// Le barre sono grafica funzionale e si disegnano (R8 lascia al codice cio'
/// che e' funzionale): nessun numero si scrive a mano qui.
class IlGraficoDelleBarre extends StatelessWidget {
  const IlGraficoDelleBarre({
    super.key,
    required this.barre,
    required this.palette,
    this.titolo,
  });

  final List<BarraDellaSinastria> barre;
  final MaestroPalette palette;

  /// Che cosa misurano le barre, in una riga sopra; nullo, nessuna riga.
  final String? titolo;

  /// La percentuale scritta accanto alla barra, dal valore.
  static String percentuale(double valore) =>
      '${(valore.clamp(0.0, 1.0) * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final etichetta = TypographyTokens.etichetta()
        .copyWith(color: ColorTokens.textPrimary, letterSpacing: 0.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titolo != null) ...[
          Text(titolo!,
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.xs),
        ],
        for (var i = 0; i < barre.length; i++)
          Padding(
            padding: EdgeInsets.only(
                bottom: i == barre.length - 1 ? 0 : SpacingTokens.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(barre[i].etichetta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: etichetta),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  flex: 6,
                  child: _LaBarra(
                    key: Key('barra_della_sinastria_$i'),
                    valore: barre[i].valore,
                    palette: palette,
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
                SizedBox(
                  width: 48,
                  child: Text(percentuale(barre[i].valore),
                      textAlign: TextAlign.end,
                      style: etichetta.copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Una barra: il binario velato e, sopra, la parte piena quanto il valore.
class _LaBarra extends StatelessWidget {
  const _LaBarra({super.key, required this.valore, required this.palette});

  final double valore;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final forma = BorderRadius.circular(SpacingTokens.xs);
    return Container(
      height: SpacingTokens.sm,
      decoration: BoxDecoration(
        borderRadius: forma,
        color: palette.primary.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: valore.clamp(0.0, 1.0),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: forma,
            gradient: LinearGradient(
              colors: [palette.gold, palette.goldSoft],
            ),
          ),
        ),
      ),
    );
  }
}
