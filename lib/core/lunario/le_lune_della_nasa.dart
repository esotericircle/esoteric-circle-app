/// **LE LUNE VERE**, ordine FV voce FV.03, 15 ottobre 2026: ogni giorno del
/// mese mostra la fotografia della Luna di quel giorno, una delle trenta di
/// una lunazione dello Scientific Visualization Studio, scelta per
/// elongazione. La fonte e' dichiarata in `lib/core/legal/fonti_dei_dati.dart`;
/// nei testi di Medora la fonte non si nomina mai (linee guida della fonte).
///
/// **PRIMA STESURA**: la tabella delle trenta immagini e la regola
/// dell'emisfero le scrive la voce FV.03 col suo lavoro; finche' la tabella
/// e' vuota [immaginePer] restituisce null e la schermata mostra il solo
/// castone.
abstract final class LeLuneDellaNasa {
  /// Le immagini con la loro elongazione, in gradi da 0 a 360.
  static const List<({String percorso, double elongazione})> immagini = [];

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
  /// gradi (emisfero sud). La regola e la sua fonte le dichiara la voce
  /// FV.03.
  static bool ruotaPer(double latitudine) => latitudine < 0;

  /// Il castone d'argento in cui sta ogni Luna (P2 dell'ordine FV).
  static const String castone =
      'assets/img/calendario_lunare/castone_luna_v1.webp';
}
