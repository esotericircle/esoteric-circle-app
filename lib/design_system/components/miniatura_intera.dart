import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/spacing_tokens.dart';

/// LA MINIATURA CHE NON TAGLIA MAI L'IMMAGINE.
///
/// **La segnalazione, ripetuta.** Nel Passport il lupo era tagliato dal cerchio
/// che lo conteneva, con zampe e coda fuori dalla cornice, e l'angelo era
/// ritagliato dentro un riquadro che non rispettava la proporzione della carta,
/// quindi la figura veniva mozzata sui lati.
///
/// **La regola, e sta QUI e non nelle schermate.** Un'immagine non si adatta mai
/// al riempimento del suo riquadro: il riquadro si adatta all'immagine, oppure
/// l'immagine ci sta dentro intera. Correggere il Passport avrebbe lasciato la
/// stessa immagine tagliata negli altri quattro punti che la mostrano, ed e' la
/// famiglia di difetto che questo progetto ha gia' incontrato dodici volte.
///
/// `BoxFit.contain` e non `cover`: cover riempie ritagliando cio' che avanza, e
/// in un quadrato un totem verticale perde la testa. Un animale guida decapitato
/// non e' un animale guida, e una carta d'angelo senza cornice non e' una carta.
class MiniaturaIntera extends StatelessWidget {
  const MiniaturaIntera({
    super.key,
    required this.path,
    required this.ripiego,
    required this.palette,
    required this.larghezza,
    this.proporzione = proporzioneQuadrata,
    this.raggio,
  });

  /// La miniatura di una CARTA: rettangolare verticale, due terzi.
  ///
  /// Le illustrazioni degli Angeli e dei Tarocchi sono carte: ritagliarle in un
  /// quadrato le mutila per costruzione, qualunque sia il `fit`.
  const MiniaturaIntera.carta({
    super.key,
    required this.path,
    required this.ripiego,
    required this.palette,
    required this.larghezza,
    this.raggio,
  }) : proporzione = proporzioneCarta;

  /// Larghezza diviso altezza. Uno e' il quadrato.
  static const double proporzioneQuadrata = 1;

  /// La proporzione di una carta, larghezza su altezza.
  static const double proporzioneCarta = 2 / 3;

  final String path;
  final IconData ripiego;
  final MaestroPalette palette;
  final double larghezza;
  final double proporzione;
  final double? raggio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: larghezza,
      height: larghezza / proporzione,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(raggio ?? SpacingTokens.radiusSm),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(ripiego,
              color: palette.goldSoft, size: larghezza * 0.34),
        ),
      ),
    );
  }
}
