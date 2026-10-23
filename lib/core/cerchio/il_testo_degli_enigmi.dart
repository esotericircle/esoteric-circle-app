/// IL TESTO DEGLI ENIGMI, porta unica. Ordine FF aggiunta 1, voci A2 e A3,
/// 8 ottobre 2026.
///
/// Ogni testo che esce dai due corpora degli Enigmi (il Ritratto e le
/// Prove) passa da qui prima di arrivare a video, e qui la marca del genere
/// `[maschile|femminile|neutro]` si risolve con la forma giusta:
/// - **a chi ha compilato il Ritratto o sta facendo la Prova** si parla con
///   la forma che ha dichiarato ([perChiCompila]);
/// - **un tratto uscito come indizio su un'altra persona** porta SEMPRE il
///   neutro ([comeIndizio]): chi gioca non conosce il genere della persona
///   da indovinare, e indovinarlo e' vietato (ordine DL, "il genere scelto vale ovunque").
/// Non c'e' un terzo caso.
///
/// **La porta si rompe, rossa, su una marca malformata o non risolta**:
/// meglio un errore nelle prove che una quadra con le barre a video.
library;

import '../chat/le_forme_del_genere.dart';
import '../chat/user_profile.dart';

/// Un testo dei corpora che a video arriverebbe con una marca.
class MarcaNonRisolta implements Exception {
  MarcaNonRisolta(this.testo);
  final String testo;

  @override
  String toString() => 'marca del genere non risolta: "$testo"';
}

abstract final class IlTestoDegliEnigmi {
  /// Il testo per la persona che lo ha compilato o che sta facendo la
  /// Prova, nella sua forma (neutro se non l'ha ancora dichiarata).
  static String perChiCompila(String testoMarcato, CourtesyForm forma) =>
      _risolvi(testoMarcato, forma);

  /// Il tratto uscito come indizio su un'altra persona: sempre il neutro.
  static String comeIndizio(String testoMarcato) =>
      _risolvi(testoMarcato, CourtesyForm.neutral);

  static String _risolvi(String testo, CourtesyForm forma) {
    final fuori = LaMarcaDelGenere.risolvi(testo, forma: forma);
    // `risolvi` restituisce il testo intatto se una marca e' malformata:
    // qui quel testo non passa.
    if (marcaDelGenere.hasMatch(fuori) ||
        fuori.contains('[') ||
        fuori.contains('|')) {
      throw MarcaNonRisolta(testo);
    }
    return fuori;
  }
}
