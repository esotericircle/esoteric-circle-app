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
///
/// **E RIEMPIE IL RIQUADRO**, il fondatore il 1 ottobre 2026: *"Il colore
/// del giorno e il numero del giorno più grandi in modo da riempire il
/// riquadro e centrati verticalmente e orizzontalmente."* La cifra cresce
/// fino allo spazio che c'e' fra l'etichetta e il suo contrappeso.
class RiquadroDelNumero extends StatelessWidget {
  const RiquadroDelNumero({
    super.key,
    required this.numero,
    required this.palette,
    this.etichetta = 'Numero',
    this.cifre,
  });

  /// **PIU' NUMERI IN UN RIQUADRO**, ordine ES voce 08: la tradizione cinese
  /// da' all'elemento del giorno due numeri, quelli dello He Tu ("3 e 8").
  /// Null vale il solo [numero].
  final String? cifre;

  final int numero;
  final MaestroPalette palette;
  final String etichetta;

  @override
  Widget build(BuildContext context) {
    return _RiquadroDellaFortuna(
      chiave: const Key('riquadro_del_numero'),
      etichetta: etichetta,
      palette: palette,
      // **GRANDE E AL CENTRO**, ordine EU voce 10, e dal 1 ottobre 2026 sera
      // alta quanto il riquadro: la cifra cresce fino a riempire lo spazio
      // che resta, e si rimpicciolisce intera se il riquadro e' stretto (i
      // due numeri della lettura cinese) invece di andare a capo.
      contenuto: FittedBox(
        fit: BoxFit.contain,
        // **LA RIGA STRETTA SULLA CIFRA**, visto sul Realme il 1 ottobre
        // 2026: con la riga intera (ascendenti e discendenti) la cifra
        // occupava un terzo dell'altezza del riquadro. Le cifre non hanno
        // discendenti: la riga si stringe a tre quarti del carattere, e il
        // FittedBox la porta a riempire lo spazio.
        //
        // **E IL DISEGNO AL CENTRO, non la riga**: nel carattere delle cifre
        // il disegno sta piu' in alto della sua riga, di circa il 3,5 per
        // cento del carattere (misurato sui pixel della cifra a video). Un
        // margine sopra di due volte tanto lo riporta al centro del riquadro.
        child: Padding(
          key: const Key('riquadro_del_numero_cifra'),
          padding: EdgeInsets.only(
              top: (TypographyTokens.numeroDelGiorno().fontSize ?? 40) * 0.07),
          child: Text(cifre ?? '$numero',
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TypographyTokens.numeroDelGiorno().copyWith(
                  color: palette.goldSoft,
                  height: 0.75,
                  leadingDistribution: TextLeadingDistribution.even)),
        ),
      ),
    );
  }
}

/// **IL RIQUADRO DEL COLORE DEL GIORNO**, gemello di quello del numero: il
/// fondatore, 1 ottobre 2026, *"Il colore del giorno e il numero del giorno
/// più grandi in modo da riempire il riquadro e centrati verticalmente e
/// orizzontalmente"*. Prima il colore era un pallino di sedici punti e il
/// suo nome in didascalia, allineati a sinistra sotto un'etichetta su due
/// righe. Adesso il cerchio del colore e il suo nome crescono insieme fino
/// allo spazio del riquadro, e stanno al centro.
class RiquadroDelColore extends StatelessWidget {
  const RiquadroDelColore({
    super.key,
    required this.nome,
    required this.colore,
    required this.palette,
  });

  /// Il nome del colore, come lo dice la scheda ("oro").
  final String nome;
  final Color colore;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return _RiquadroDellaFortuna(
      chiave: const Key('riquadro_del_colore'),
      etichetta: 'Colore',
      palette: palette,
      contenuto: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          key: const Key('riquadro_del_colore_contenuto'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('riquadro_del_colore_cerchio'),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colore,
                border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 4),
            Text(nome,
                key: const Key('riquadro_del_colore_nome'),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.1)),
          ],
        ),
      ),
    );
  }
}

/// **I DUE RIQUADRI DELLA FORTUNA DEL GIORNO**, il numero e il colore, larghi
/// uguale e alti uguale, alti almeno [altezzaMinima] (cresce col carattere):
/// cosi' il loro contenuto ha lo spazio per essere grande.
class LaFortunaDelGiorno extends StatelessWidget {
  const LaFortunaDelGiorno({
    super.key,
    required this.numero,
    required this.palette,
    this.cifre,
    this.etichettaDelNumero = 'Numero',
    this.nomeDelColore,
    this.colore,
  });

  final int numero;
  final String? cifre;
  final String etichettaDelNumero;
  final String? nomeDelColore;
  final Color? colore;
  final MaestroPalette palette;

  /// L'altezza dei due riquadri al carattere normale, in punti.
  static const double altezzaMinima = 112;

  @override
  Widget build(BuildContext context) {
    final scala = MediaQuery.textScalerOf(context).scale(14) / 14;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: altezzaMinima * scala),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RiquadroDelNumero(
                  numero: numero,
                  palette: palette,
                  etichetta: etichettaDelNumero,
                  cifre: cifre),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: RiquadroDelColore(
                  nome: nomeDelColore ?? '',
                  colore: colore ?? palette.goldSoft,
                  palette: palette),
            ),
          ],
        ),
      ),
    );
  }
}

/// La forma comune dei due riquadri: l'etichetta in cima, il contenuto nello
/// spazio che resta, e in fondo il contrappeso invisibile alto quanto
/// l'etichetta, perche' il contenuto stia al centro.
class _RiquadroDellaFortuna extends StatelessWidget {
  const _RiquadroDellaFortuna({
    required this.chiave,
    required this.etichetta,
    required this.palette,
    required this.contenuto,
  });

  final Key chiave;
  final String etichetta;
  final MaestroPalette palette;
  final Widget contenuto;

  @override
  Widget build(BuildContext context) {
    final stileEtichetta = TypographyTokens.etichetta()
        .copyWith(color: ColorTokens.textSecondary, letterSpacing: 0.8);
    final testoEtichetta = etichetta.toUpperCase();
    return Container(
      key: chiave,
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(testoEtichetta, maxLines: 1, style: stileEtichetta),
          // Lo spazio intero al contenuto: il FittedBox lo riempie, al
          // centro, senza deformarlo. Per questo il riquadro va messo dove ha
          // una larghezza (in un Expanded, come nella scheda e nella card).
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox.expand(child: contenuto),
            ),
          ),
          ExcludeSemantics(
            child: Opacity(
              opacity: 0,
              child: Text(testoEtichetta, maxLines: 1, style: stileEtichetta),
            ),
          ),
        ],
      ),
    );
  }
}
