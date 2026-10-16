import 'le_lune_della_nasa.g.dart';

/// **LE LUNE VERE**, ordine FV voce FV.03, 15 ottobre 2026: ogni giorno del
/// mese mostra la fotografia della Luna di quel giorno, una delle trenta di
/// una lunazione dello Scientific Visualization Studio, scelta per
/// elongazione. La fonte e' dichiarata in `lib/core/legal/fonti_dei_dati.dart`;
/// nei testi di Medora la fonte non si nomina mai (linee guida della NASA:
/// mai "secondo la NASA" in un prodotto con intelligenza artificiale).
abstract final class LeLuneDellaNasa {
  /// Le trenta immagini con la loro elongazione, in gradi da 0 a 360,
  /// generate da `tool/le_lune_della_nasa.py` in
  /// `le_lune_della_nasa.g.dart`.
  static const List<({String percorso, double elongazione})> immagini =
      leLuneDellaNasaGenerate;

  /// L'immagine con l'elongazione piu' vicina, in senso circolare.
  static String? immaginePer(double elongazione) {
    if (immagini.isEmpty) return null;
    var migliore = immagini.first;
    var scarto = 360.0;
    for (final i in immagini) {
      final d = (i.elongazione - elongazione).abs() % 360;
      final c = d > 180 ? 360 - d : d;
      if (c < scarto) {
        scarto = c;
        migliore = i;
      }
    }
    return migliore.percorso;
  }

  /// Vero se per chi sta a questa latitudine la Luna va ruotata di 180
  /// gradi: nell'emisfero sud chi guarda verso l'equatore guarda dalla
  /// parte opposta a chi lo guarda dal nord, e vede la Luna (e le stelle)
  /// capovolta rispetto all'emisfero nord. Fonte, verificata il 15 ottobre
  /// 2026: Jake Foster, "Does the Moon look upside down in the southern
  /// hemisphere?", BBC Science Focus,
  /// https://www.sciencefocus.com/science/does-the-moon-look-upside-down-in-the-southern-hemisphere;
  /// David J. Eicher, "Why do the constellations and the Moon appear upside
  /// down from the Southern Hemisphere?", Astronomy Magazine,
  /// https://www.astronomy.com/astronomy-for-beginners/why-do-the-constellations-and-the-moon-appear-upside-down-from-the-southern-hemisphere/.
  static bool ruotaPer(double latitudine) => latitudine < 0;

  /// Il castone d'argento in cui sta ogni Luna (P2 dell'ordine FV).
  static const String castone =
      'assets/img/calendario_lunare/castone_luna_v1.webp';
}
