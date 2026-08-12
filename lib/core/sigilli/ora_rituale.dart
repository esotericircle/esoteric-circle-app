import '../astro/solar_time.dart';

/// L'ORA RITUALE DI ADESSO, misurata sul cielo vero del luogo.
/// Ordine P voce 35.
///
/// **Perche' non si scrive a mano.** I traguardi della famiglia `cielo` si
/// chiudono solo dentro una finestra astronomica vera: `GestoNellOraGiusta`
/// chiede 'alba', 'tramonto' o 'notte'. Passare la stringa fissa dal punto di
/// chiamata, come faceva il Rito dell'Alba con `oraRituale: 'alba'`, vuol dire
/// che aprendo quel rito a mezzogiorno il traguardo del cielo si accende lo
/// stesso: il traguardo migliore che questa app possa avere, quello che non
/// si affretta, diventerebbe il piu' facile di tutti.
///
/// Qui l'ora si MISURA: si chiedono l'alba e il tramonto veri del giorno e si
/// guarda dove cade adesso. Il ripiego, quando non si conosce il luogo, e' lo
/// stesso gia' precedentato nell'app, `longitudineDaFuso` piu' `latDiRipiego`:
/// un ripiego dichiarato e' meglio di una finestra sempre aperta.
class OraRituale {
  const OraRituale._();

  /// Quanto dura la finestra attorno all'alba e al tramonto.
  ///
  /// Un'ora e mezza per parte: e' la durata della luce che cambia davvero, ed
  /// e' abbastanza larga perche' chi si sveglia col rito la trovi aperta senza
  /// dover guardare l'orologio.
  static const Duration finestra = Duration(minutes: 90);

  /// 'alba', 'tramonto', 'notte' oppure nullo se adesso non e' nessuna delle
  /// tre. Nullo e' una risposta: vuol dire che il gesto conta come gesto e non
  /// come gesto nell'ora giusta.
  static String? diAdesso({
    DateTime? adesso,
    double? latitudine,
    double? longitudine,
  }) {
    final ora = adesso ?? DateTime.now();
    final offset = ora.timeZoneOffset;
    final lat = latitudine ?? SunsetTime.latDiRipiego;
    final lon = longitudine ?? SunsetTime.longitudineDaFuso(offset);

    final alba = SunsetTime.albaPerData(ora,
        lat: lat, lon: lon, offset: offset);
    final tramonto = SunsetTime.perData(ora,
        lat: lat, lon: lon, offset: offset);

    if (alba != null && _vicino(ora, alba)) return 'alba';
    if (tramonto != null && _vicino(ora, tramonto)) return 'tramonto';
    // LA NOTTE E' IL RESTO DEL BUIO: dopo il tramonto o prima dell'alba,
    // fuori dalle due finestre.
    if (alba != null && tramonto != null) {
      if (ora.isAfter(tramonto) || ora.isBefore(alba)) return 'notte';
      return null;
    }
    // Senza effemeridi si ripiega sull'ora dell'orologio, e si dichiara: e'
    // meglio di una finestra sempre aperta.
    if (ora.hour >= 22 || ora.hour < 5) return 'notte';
    return null;
  }

  static bool _vicino(DateTime ora, DateTime bersaglio) =>
      ora.difference(bersaglio).abs() <= finestra;
}
