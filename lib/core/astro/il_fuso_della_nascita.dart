import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// **L'ORA DI NASCITA IN TEMPO UNIVERSALE, COL FUSO DI ALLORA.** Ordine ES
/// voci 07 e 11, 29 settembre 2026.
///
/// I segni della Vedica, dell'Egizia e dell'Araba dipendono da dove stavano
/// la Luna o il Sole nell'istante di nascita, e l'istante si ricava dall'ora
/// locale col fuso **di quel giorno**: in Italia l'ora legale c'era negli
/// anni Quaranta, poi dal 1966 con regole cambiate piu' volte. Il luogo di
/// nascita porta uno scarto fisso dall'ora di Greenwich (`utcOffsetMinutes`),
/// che d'estate sbaglia di un'ora: la Luna in un'ora fa mezzo grado, e una
/// dimora lunare araba e' larga dodici gradi e cinquantuno primi.
///
/// **Il database dei fusi e' uno per tutta l'app**, e da quest'ordine e'
/// quello completo (`latest`), che copre anche gli anni che servono alle
/// nascite. Gli avvisi e le push caricavano quello dei soli dieci anni: se
/// l'avessero ricaricato dopo questo, le date vecchie sarebbero tornate
/// sbagliate senza che nessuno se ne accorgesse. Adesso caricano lo stesso.
abstract final class IlFusoDellaNascita {
  static bool _pronto = false;

  /// Il fuso di chi non ha dato il luogo: l'app parla italiano.
  static const String fusoDiRipiego = 'Europe/Rome';

  static void _prepara() {
    if (_pronto) return;
    tzdata.initializeTimeZones();
    _pronto = true;
  }

  /// L'istante in tempo universale dell'ora locale [locale] (si leggono solo
  /// anno, mese, giorno, ora e minuto) nel fuso [fuso]. Un fuso che il
  /// database non conosce vale come [fusoDiRipiego].
  static DateTime inUtc(DateTime locale, String? fuso) {
    _prepara();
    tz.Location luogo;
    try {
      luogo = tz.getLocation(fuso ?? fusoDiRipiego);
    } on tz.LocationNotFoundException {
      luogo = tz.getLocation(fusoDiRipiego);
    }
    return tz.TZDateTime(luogo, locale.year, locale.month, locale.day,
            locale.hour, locale.minute)
        .toUtc();
  }
}
