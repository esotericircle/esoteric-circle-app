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
    this.conIlPerche = true,
  });

  final DailyElement rito;

  /// Il colore del testo, dichiarato da chi monta: le schermate dei riti
  /// dipingono il proprio fondale e il tema non lo sa.
  final Color inchiostro;

  /// Il colore delle tre etichette, gia' portato dove si legge.
  final Color accento;

  /// **SE MOSTRARE ANCHE IL PERCHE'. Ordine AS voce 06.**
  ///
  /// La regola trasversale dettata da Mauro dice che chi apre l'app cerca una
  /// risposta e vuole sapere cosa fare: "Cosa fai" e "Cosa ti resta" sono la
  /// risposta, "Perche'" e' la ragione che ci sta dietro. Nel DONO del giorno
  /// la ragione esce dalla scheda e va nel pannello della base, che e' il posto
  /// dove il progetto tiene gia' cio' che spiega, ed e' apribile da chi lo
  /// vuole: non sparisce, si sposta dove si cerca.
  ///
  /// Altrove resta acceso, perche' in una scheda di rito che si apre da sola il
  /// perche' e' parte di cio' che si sta leggendo.
  final bool conIlPerche;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('tre_righe_${rito.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **IL TITOLO CHE DICE DI COSA SI STA PARLANDO.** Ordine CO voce 15,
        // 3 settembre 2026.
        //
        // Le tre righe cominciavano con "Cosa fai", cioe' con un'istruzione
        // senza soggetto: chi leggeva sapeva cosa toccare e non a che cosa
        // appartenesse il gesto. Il fondatore ha chiesto il titolo, e le
        // parole gliele da' l'ORA del rito, non il suo nome, cosi' sotto il
        // Sigillo del Sogno non si legge "stamattina".
        //
        // **In oro e non nell'inchiostro del corpo**, come le tre etichette
        // qui sotto: e' della loro famiglia, e' cio' che le presenta tutte e
        // tre insieme.
        Text(
          rito.titoloDelRito,
          key: Key('titolo_rito_${rito.name}'),
          style: TypographyTokens.didascalia(weight: 600)
              .copyWith(color: accento, letterSpacing: 1.2),
        ),
        const SizedBox(height: SpacingTokens.xs),
        _Riga(
          etichetta: 'Cosa fai',
          testo: rito.cosaFai,
          chiave: Key('cosa_fai_${rito.name}'),
          inchiostro: inchiostro,
          accento: accento,
        ),
        if (conIlPerche) ...[
          const SizedBox(height: SpacingTokens.xs),
          _Riga(
            etichetta: 'Perché',
            testo: rito.perche,
            chiave: Key('perche_${rito.name}'),
            inchiostro: inchiostro,
            accento: accento,
          ),
        ],
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
          // **LE TRE RIGHE SI LEGGONO A DICIOTTO, non a sedici.**
          // Ordine CO voce 13, 3 settembre 2026, chiesta dal fondatore
          // per la terza volta.
          //
          // Erano `didascalia`, sedici punti, che e' il PAVIMENTO di
          // questa app e non la sua misura di lettura. Ci erano arrivate
          // dall'ordine CG voce 14, che aveva alzato quattordici testi
          // sotto il pavimento fino al pavimento: giusto allora, e da
          // quel giorno il pavimento e' stato scambiato per il traguardo.
          //
          // Queste tre non sono etichette: sono il paragrafo che dice
          // cosa fai, perche', e cosa ti resta, cioe' la parte dei Doni
          // che si legge davvero, riga dopo riga. Il ruolo per cio' che
          // si legge esiste nella scala da sempre e si chiama `lettura`.
          TextSpan(
            text: '$etichetta. ',
            style:
                TypographyTokens.lettura(weight: 600).copyWith(color: accento),
          ),
          TextSpan(
            text: testo,
            style: TypographyTokens.lettura().copyWith(
              color: inchiostro,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
