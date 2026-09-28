import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL RIQUADRO DEL NUMERO FORTUNATO, COL NUMERO AL CENTRO.** Ordine ES voce
/// 14, 28 settembre 2026.
///
/// **Il fatto del fondatore, sul telefono**: nel riquadro del numero
/// fortunato il numero non e' centrato. **Il padre**: l'ordine DD voce 09
/// (commit `b6188d20`) ha pareggiato l'altezza delle due bolle della Fortuna
/// stirando la piu' bassa fino alla piu' alta, ma dentro la bolla del numero
/// la colonna restava allineata all'inizio e alta quanto il suo contenuto:
/// l'etichetta e la cifra restavano attaccate in alto a sinistra, e sotto
/// si apriva un vuoto di ventitre punti.
///
/// **Adesso** l'etichetta sta in cima, la cifra nello spazio che resta, e
/// in fondo c'e' una copia invisibile dell'etichetta, alta uguale: sopra e
/// sotto la cifra c'e' lo stesso spazio, quindi la cifra sta al centro del
/// riquadro, in verticale e in orizzontale, con una cifra o con due, alla
/// scala del testo normale e a quella ingrandita dalle impostazioni del
/// telefono. Lo stesso riquadro serve alla Cinese e alla Vedica.
class RiquadroDelNumero extends StatelessWidget {
  const RiquadroDelNumero({
    super.key,
    required this.numero,
    required this.palette,
    this.etichetta = 'Numero',
  });

  final int numero;
  final MaestroPalette palette;
  final String etichetta;

  @override
  Widget build(BuildContext context) {
    final stileEtichetta = TypographyTokens.etichetta()
        .copyWith(color: ColorTokens.textSecondary, letterSpacing: 0.8);
    final testoEtichetta = etichetta.toUpperCase();
    return Container(
      key: const Key('riquadro_del_numero'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        // Tutto centrato sull'asse di traverso: nella riga il riquadro non ha
        // un limite di larghezza, e stirare i figli lo romperebbe.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(testoEtichetta, style: stileEtichetta),
          Expanded(
            child: Center(
              child: Text('$numero',
                  key: const Key('riquadro_del_numero_cifra'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
            ),
          ),
          // Il contrappeso: alto quanto l'etichetta, invisibile, cosi' la
          // cifra ha sopra e sotto lo stesso spazio.
          ExcludeSemantics(
            child: Opacity(
              opacity: 0,
              child: Text(testoEtichetta, style: stileEtichetta),
            ),
          ),
        ],
      ),
    );
  }
}
