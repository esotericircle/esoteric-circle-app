import 'meeus/l_alba_e_il_tramonto.dart';

/// LE ORE VERE DEL SOLE, calcolate offline senza rete. Dall'ordine FD voce
/// 02 vengono dalla porta del cielo, attraverso [LAlbaEIlTramonto] (Meeus,
/// Sole apparente e tempo siderale): l'algoritmo NOAA che stava qui, scritto
/// due volte con un Sole e un'obliquita' propri, e' stato tolto.
///
/// **Il file portava il nome del solo tramonto, e dichiarava il falso.**
/// Ordine P voce 29: qui dentro c'e' anche il SORGERE, che il Rito dell'Alba
/// usa per l'ora della sua fascia, e un file che dice di conoscere solo il
/// tramonto manda a cercare altrove una cosa che ha in casa, oppure la fa
/// riscrivere. La classe conserva il nome storico perche' entra nei
/// salvataggi e nelle firme di mezza app: a mentire era il file.
///
/// La longitudine e' est positivo, la latitudine in gradi,
/// e il risultato e' l'ora locale a muro dato lo scarto di fuso. Nei casi polari,
/// dove il Sole non tramonta o non sorge, ritorna null e il chiamante ripiega
/// sull'ora media, senza eccezioni.
class SunsetTime {
  const SunsetTime._();

  /// Latitudine di ripiego quando la posizione non e' attiva.
  static const double latDiRipiego = 45.0;

  /// Il tramonto per il giorno di calendario [giorno], di cui si usa solo la
  /// data, alla posizione data, reso nell'ora locale con lo scarto [offset].
  /// Null nei casi polari.
  static DateTime? perData(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) =>
      _estremiSolari(giorno, lat: lat, lon: lon, offset: offset)?.tramonto;

  static DateTime oraMedia(DateTime giorno) =>
      DateTime(giorno.year, giorno.month, giorno.day, 18, 0);

  /// La longitudine stimata dal solo fuso, quando la posizione non e' attiva:
  /// quindici gradi per ogni ora di scarto.
  static double longitudineDaFuso(Duration offset) =>
      offset.inMinutes / 60.0 * 15.0;

  // ===========================================================================
  // IL SORGERE DEL SOLE, aggiunto il 5 agosto 2026
  // ===========================================================================

  /// L'ora vera del SORGERE del sole, stesso algoritmo NOAA del tramonto.
  ///
  /// **Perche' e' arrivato adesso.** Il Rito dell'Alba deve dichiarare alla
  /// persona una fascia oraria vera, calcolata per il suo luogo. Qui c'era solo
  /// il tramonto, e il sorgere non esisteva in nessun punto del progetto:
  /// l'ora dell'alba era l'unico dato del cielo che l'app non sapeva dire.
  ///
  /// **Sorgere e tramonto sono lo stesso calcolo con un segno diverso.** Sono
  /// simmetrici rispetto al mezzogiorno solare: il tramonto e' il transito piu'
  /// l'angolo orario, il sorgere e' il transito meno lo stesso angolo. Per
  /// questo vivono qui e non in un file nuovo: una porta sola sull'astronomia
  /// solare, come per tutto il resto.
  ///
  /// Nei casi polari, dove il Sole non sorge o non tramonta, torna null e il
  /// chiamante ripiega su [oraMediaAlba], senza eccezioni: stessa regola gia'
  /// in uso per il tramonto.
  static DateTime? albaPerData(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) =>
      _estremiSolari(giorno, lat: lat, lon: lon, offset: offset)?.alba;

  /// L'ora media del sorgere, per i casi polari o quando manca la posizione:
  /// le sei locali. E' la simmetrica delle diciotto gia' usate per il tramonto,
  /// e come quella e' sempre valida, mai un'eccezione.
  static DateTime oraMediaAlba(DateTime giorno) =>
      DateTime(giorno.year, giorno.month, giorno.day, 6, 0);

  /// I DUE estremi del giorno solare, dallo stesso transito e dallo stesso
  /// angolo orario.
  ///
  /// **Questa e' una seconda scrittura del nucleo NOAA, e va detto.** L'ordine
  /// che ha aggiunto il sorgere autorizzava solo aggiunte in coda, senza
  /// toccare una riga di [perData]: percio' il calcolo del transito e
  /// dell'angolo orario, che [perData] fa gia' al suo interno, e' ripetuto qui.
  /// Due copie della stessa formula sono la famiglia di difetti piu' cara di
  /// questo progetto, quindi la duplicazione e' **inchiodata da una prova**:
  /// `il_sorgere_del_sole_test.dart` pretende che il tramonto calcolato qui
  /// coincida al secondo con quello di [perData]. Se una delle due derivasse,
  /// la prova cade.
  ///
  /// Quando sara' permesso modificare il file, [perData] deve delegare a questo
  /// metodo e la duplicazione sparisce. E' l'unica cosa che manca, ed e' una
  /// riga.
  /// **I DUE ESTREMI DEL GIORNO DALLA PORTA DEL CIELO**, ordine FD voce 02.
  /// Qui stava l'algoritmo NOAA, scritto due volte, con un Sole proprio e
  /// un'obliquita' fissa: una seconda via per la posizione del Sole. Adesso
  /// l'alba e il tramonto vengono da [LAlbaEIlTramonto], che itera col Sole
  /// apparente e il tempo siderale della porta, e qui si portano all'ora
  /// locale a muro, come prima.
  static ({DateTime alba, DateTime tramonto})? _estremiSolari(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) {
    final e =
        LAlbaEIlTramonto.delGiorno(giorno, lat: lat, lon: lon, offset: offset);
    if (e == null) return null; // notte polare o giorno polare
    return (
      alba: _oraLocale(e.alba, offset),
      tramonto: _oraLocale(e.tramonto, offset),
    );
  }

  static DateTime _oraLocale(DateTime utc, Duration offset) {
    final s = utc.add(offset);
    return DateTime(s.year, s.month, s.day, s.hour, s.minute, s.second);
  }
}
