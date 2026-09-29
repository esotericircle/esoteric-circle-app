import 'effemeridi.dart';
import 'le_effemeridi_del_jpl.dart';

/// **IL CIELO DEL JPL SUL TELEFONO.** Ordine ES voce 04, 29 settembre 2026.
///
/// Legge i polinomi di [LeEffemeridiDelJpl], adattati sul JPL DE421: la
/// longitudine eclittica apparente di Sole (1900-2050), Venere, Giove e
/// Saturno (2019-2050), al secondo d'arco. Fuori dall'intervallo torna null,
/// e chi chiama ripiega sulle formule di Meeus dichiarandolo.
abstract final class IlCieloDelJpl {
  /// La longitudine di [corpo] al giorno giuliano UT [jd], o null.
  static double? longitudine(CorpoCeleste corpo, double jd) {
    final (coeff, inizio, fine, lunghezza, grado) = switch (corpo) {
      CorpoCeleste.sole => (
          LeEffemeridiDelJpl.sole,
          LeEffemeridiDelJpl.soleInizio,
          LeEffemeridiDelJpl.soleFine,
          LeEffemeridiDelJpl.soleLunghezza,
          LeEffemeridiDelJpl.soleGrado,
        ),
      CorpoCeleste.venere => (
          LeEffemeridiDelJpl.venere,
          LeEffemeridiDelJpl.venereInizio,
          LeEffemeridiDelJpl.venereFine,
          LeEffemeridiDelJpl.venereLunghezza,
          LeEffemeridiDelJpl.venereGrado,
        ),
      CorpoCeleste.giove => (
          LeEffemeridiDelJpl.giove,
          LeEffemeridiDelJpl.gioveInizio,
          LeEffemeridiDelJpl.gioveFine,
          LeEffemeridiDelJpl.gioveLunghezza,
          LeEffemeridiDelJpl.gioveGrado,
        ),
      CorpoCeleste.saturno => (
          LeEffemeridiDelJpl.saturno,
          LeEffemeridiDelJpl.saturnoInizio,
          LeEffemeridiDelJpl.saturnoFine,
          LeEffemeridiDelJpl.saturnoLunghezza,
          LeEffemeridiDelJpl.saturnoGrado,
        ),
      _ => (const <int>[], 0.0, 0.0, 1, 0),
    };
    if (coeff.isEmpty || jd < inizio || jd >= fine) return null;
    final n = grado + 1;
    final s = ((jd - inizio) / lunghezza).floor();
    final a = inizio + s * lunghezza;
    final x = 2 * (jd - a) / lunghezza - 1;
    // Clenshaw.
    var b1 = 0.0;
    var b2 = 0.0;
    for (var k = n - 1; k >= 1; k--) {
      final b0 = 2 * x * b1 - b2 + coeff[s * n + k] / 1e7;
      b2 = b1;
      b1 = b0;
    }
    final v = x * b1 - b2 + coeff[s * n] / 1e7;
    final l = v % 360.0;
    return l < 0 ? l + 360.0 : l;
  }
}
