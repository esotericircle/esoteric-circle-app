import 'package:flutter/material.dart';

import '../../core/rituals/daily_elements.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// COSA FAI, PERCHE', COSA TI RESTA. Ordine P voce 17.
///
/// **La terza e' quella che mancava ovunque, ed e' la sola che produce
/// ritorno.** I riti dicevano il nome e mostravano un gesto: chi apriva sapeva
/// cosa toccare e non cosa ne avrebbe portato via. La legge che governa la
/// sezione lo dice in una riga: un dono che si esaurisce quando lo apri non
/// produce ritorni, un dono che apre qualcosa che si chiude piu' tardi si'.
///
/// **Vive nel design system e non dentro le cinque schermate.** I cinque riti
/// sono di tre famiglie diverse, `RitualGiftCard` per Alba e Soffio,
/// `RitualView` per l'Oracolo, due schermate proprie per Tramonto e Sogno:
/// scritte cinque volte, le tre righe diventerebbero cinque forme diverse
/// della stessa cosa. E' la stessa scelta gia' fatta per la riga che dichiara
/// chi parla.
///
/// I testi non stanno qui: stanno su [DailyElement], che e' il punto in cui un
/// rito dichiara se stesso.
class LeTreRigheDelRito extends StatelessWidget {
  const LeTreRigheDelRito({
    super.key,
    required this.rito,
    required this.inchiostro,
    required this.accento,
  });

  final DailyElement rito;

  /// Il colore del testo, dichiarato da chi monta: le schermate dei riti
  /// dipingono il proprio fondale e il tema non lo sa.
  final Color inchiostro;

  /// Il colore delle tre etichette, gia' portato dove si legge.
  final Color accento;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('tre_righe_${rito.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Riga(
          etichetta: 'Cosa fai',
          testo: rito.cosaFai,
          chiave: Key('cosa_fai_${rito.name}'),
          inchiostro: inchiostro,
          accento: accento,
        ),
        const SizedBox(height: SpacingTokens.xs),
        _Riga(
          etichetta: 'Perché',
          testo: rito.perche,
          chiave: Key('perche_${rito.name}'),
          inchiostro: inchiostro,
          accento: accento,
        ),
        const SizedBox(height: SpacingTokens.xs),
        _Riga(
          etichetta: 'Cosa ti resta',
          testo: rito.cosaTiResta,
          chiave: Key('cosa_ti_resta_${rito.name}'),
          inchiostro: inchiostro,
          accento: accento,
        ),
      ],
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga({
    required this.etichetta,
    required this.testo,
    required this.chiave,
    required this.inchiostro,
    required this.accento,
  });

  final String etichetta;
  final String testo;
  final Key chiave;
  final Color inchiostro;
  final Color accento;

  @override
  Widget build(BuildContext context) {
    return RichText(
      key: chiave,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$etichetta. ',
            style: TypographyTokens.didascalia(weight: 600)
                .copyWith(color: accento),
          ),
          TextSpan(
            text: testo,
            style: TypographyTokens.didascalia().copyWith(
              color: inchiostro,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
