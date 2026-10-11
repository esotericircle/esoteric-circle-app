import 'package:flutter/material.dart';

import '../typography/il_titolo_col_trattino.dart';

/// **IL TITOLO DI UN RESPONSO, in un punto solo.** Ordine FK, aggiunta voce
/// A1. La regola e le parole del fondatore stanno in
/// `lib/core/responsi/il_titolo_del_responso.dart`: *"ogni risposta deve
/// avere una gerarchia a partire dal titolo"*.
///
/// Ogni arte che produce un responso disegna qui il suo titolo, che e' gia'
/// la risposta a colpo d'occhio. Lo stile resta dell'arte (la scala ha tre
/// ruoli da titolo: ogni arte ha il suo da prima di quest'ordine): quello
/// che si tiene in un punto solo e' il fatto che il responso PARTA da qui
/// e che una guardia possa contarlo.
///
/// [chiaveDelTesto] sta sul `Text` dipinto, cosi' le prove che misurano il
/// titolo di un'arte continuano a trovarlo dove lo trovavano.
class TitoloDelResponso extends StatelessWidget {
  const TitoloDelResponso({
    super.key,
    required this.testo,
    required this.stile,
    this.allineamento = TextAlign.start,
    this.chiaveDelTesto,
    this.aCapoFraLeParole = false,
    this.margine = 0,
    this.maxRighe = 3,
  });

  final String testo;
  final TextStyle stile;
  final TextAlign allineamento;
  final Key? chiaveDelTesto;

  /// **A CAPO FRA LE PAROLE, col trattino a una sillaba se una parola non
  /// ci sta** (la regola della home, ordine ER voce 09): per i titoli che
  /// stanno in una colonna stretta, come quelli delle schede del giorno.
  final bool aCapoFraLeParole;

  /// Il margine fra la colonna misurata e quella dipinta, per
  /// [aCapoFraLeParole].
  final double margine;
  final int maxRighe;

  @override
  Widget build(BuildContext context) {
    if (!aCapoFraLeParole) {
      return Text(testo,
          key: chiaveDelTesto, style: stile, textAlign: allineamento);
    }
    return LayoutBuilder(builder: (context, vincoli) {
      final righe = IlTitoloColTrattino.righe(
        testo,
        stile: stile,
        larghezza: vincoli.maxWidth - margine,
        scala: MediaQuery.textScalerOf(context),
        maxRighe: maxRighe,
      );
      return Text(
        righe.join('\n'),
        key: chiaveDelTesto,
        softWrap: false,
        overflow: TextOverflow.visible,
        textAlign: allineamento,
        style: stile,
        semanticsLabel: testo,
      );
    });
  }
}
