import 'package:flutter/material.dart';

import '../../design_system/components/titolo_del_responso.dart';
import '../../design_system/typography/il_titolo_col_trattino.dart';

/// **IL TITOLO DELLA SCHEDA DEL GIORNO, A CAPO FRA LE PAROLE O COL TRATTINO.**
/// Ordine ER, dal Realme alla build 2285.
///
/// La scheda della Fortuna dei Gemelli del 28 settembre si leggeva "AMICI
/// PORT / AFORTUNA": i titoli del giorno della voce ER.14 sono piu' lunghi, e
/// la colonna accanto alla tendina della profondita' a 360 punti e' larga
/// 123,8. Rimpicciolire non basta: "riconoscimento" non entra nemmeno al
/// pavimento di dodici punti. Si usa la regola della home, decisa dal
/// fondatore con la voce ER.09: prima a capo fra le parole, e se una parola
/// non ci sta, a capo col trattino a una sillaba (`IlTitoloColTrattino`),
/// alla misura del ruolo.
class TitoloDellaSchedaDelGiorno extends StatelessWidget {
  const TitoloDellaSchedaDelGiorno({
    super.key,
    required this.testo,
    required this.stile,
  });

  final String testo;
  final TextStyle stile;

  /// Il margine fra la colonna misurata e quella dipinta: una parola che entra
  /// per un decimo di punto si spezza lo stesso sul telefono (vedi
  /// `TitoloCheNonSiRompe.margineDellaScatola`).
  static const double margine = 4;

  /// **IL TITOLO VA SOPRA IL SELETTORE?** Ordine EU, visto sul Realme il 1
  /// ottobre 2026: accanto al selettore della profondita' "RICOMINCIARE
  /// DALLE STANZE" diventava "RICOMIN- / CIARE DAL- / LE STANZE". Vero quando
  /// nella colonna accanto al selettore (largo [accanto], con lo spazio di
  /// [distanza] in mezzo) il titolo andrebbe a capo col trattino: allora la
  /// scheda lo mette sopra, largo quanto lei ([larghezza]). **E quando
  /// accanto andrebbe su tre righe**, visto sul Realme la stessa sera: "IL /
  /// CANTIERE / SOSPESO", con l'articolo da solo sulla prima riga.
  static bool vaSopra(
    String testo, {
    required TextStyle stile,
    required double larghezza,
    required double accanto,
    required double distanza,
    TextScaler scala = TextScaler.noScaling,
  }) =>
      siLeggeMale(IlTitoloColTrattino.righe(testo,
          stile: stile,
          larghezza: larghezza - distanza - accanto - margine,
          scala: scala,
          maxRighe: 3));

  /// Le righe di un titolo si leggono male se una va a capo col trattino o
  /// se sono piu' di due.
  static bool siLeggeMale(List<String> righe) =>
      righe.length > 2 || righe.any((r) => r.endsWith('-'));

  /// **DISEGNATO DAL TITOLO COMUNE**, ordine FK aggiunta voce A1: la regola
  /// del capo fra le parole e' passata in `TitoloDelResponso`, e questa
  /// scheda e' una delle porte di `IlTitoloDelResponso.porte`.
  @override
  Widget build(BuildContext context) => TitoloDelResponso(
        testo: testo,
        stile: stile,
        aCapoFraLeParole: true,
        margine: margine,
      );
}
