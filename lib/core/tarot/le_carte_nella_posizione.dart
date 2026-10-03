import 'le_carte_nella_posizione_dati.dart';
import 'tarot_spread.dart';

/// **LA CARTA NELLA SUA POSIZIONE.** Ordine EQ voce 04, 27 settembre 2026.
///
/// Prima "Le carte, una alla volta" mostrava per ogni carta il testo fisso del
/// suo verso, uguale nel passato, nel presente e nel futuro e per qualunque
/// domanda: l'Architetto l'ha letto nel codice e il fondatore nelle catture.
/// Qui ogni carta ha un testo per verso e per posizione, 78 per 2 per 3,
/// scritti una volta sola dal significato tradizionale che l'app gia' porta
/// (`docs/corpus/tarocchi_nella_posizione.md`, generato in Dart da
/// `tool/genera_carte_nella_posizione.py`). Servono due volte: al modello,
/// che legge la stesa partendo da li', e alla lettura di casa, quando il
/// modello non risponde.
abstract final class LeCarteNellaPosizione {
  /// La chiave del corpus per la carta [d]: il nome e il verso.
  static String chiaveDi(DrawnCard d) =>
      '${d.card.name}|${d.reversed ? 'capovolta' : 'dritta'}';

  /// Il testo della carta [d] nella sua posizione. **Se il corpus non la
  /// porta**, il significato del suo verso: meglio il testo di prima che
  /// niente, e la guardia del corpus pretende che non succeda mai.
  static String di(DrawnCard d) {
    final testi = carteNellaPosizione[chiaveDi(d)];
    if (testi == null || testi.length != SpreadPosition.values.length) {
      return d.meaning;
    }
    return testi[d.position.index];
  }
}
