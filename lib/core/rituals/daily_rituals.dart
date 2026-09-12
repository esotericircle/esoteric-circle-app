import '../tempo/confine_del_giorno.dart';
import '../maestro/maestro.dart';

/// La rotazione dei Maestri dei riti del giorno.
///
/// **QUI C'ERANO ANCHE QUATTRO POOL STATICI, e sono usciti.** Ordine CS,
/// voce M1 della scansione, 6 settembre 2026. `dawnMessage`,
/// `nightMessage`, `destinyFragment` e `dayOracle` sceglievano una frase
/// da un elenco col giorno dell'anno, e **nessun file di `lib` li chiamava
/// piu'**: i Doni hanno motori propri, `RitoAlba`, `RispostaDelSoffio`,
/// `ArcanoDelGiorno` e `SunsetRune.estrai`.
///
/// Li usavano soltanto tre file di prova, che quindi misuravano da mesi
/// **testo che nessun utente vede**, mentre il testo vero non lo misurava
/// nessuno. Le tre prove sono state riportate sulle sorgenti vive, e la
/// prima cosa che hanno trovato e' stato un difetto vero nel gesto
/// dell'Alba.
///
/// **Resta la rotazione del Maestro di turno**, che e' viva e dichiarata:
/// e' una rotazione, non una personalizzazione promessa.
///
/// Tutto nasce dalla data, senza rete: lo stesso giorno dà sempre lo stesso
/// responso, e a mezzanotte cambia. Le voci restano quelle dei Maestri.
class DailyRituals {
  const DailyRituals._();

  /// **ORDINE BL, ed e' il punto che pesa di piu'.** Da questo numero
  /// esce il Maestro del Rito dell'Alba, cioe' il primo gesto della
  /// giornata e il piu' ripetuto dell'app. Con la sottrazione fra istanti
  /// locali il numero cambiava alle una di notte: per i sette mesi
  /// dell'ora legale, chi apriva l'app fra mezzanotte e l'una riceveva il
  /// dono di ieri, con la voce del Maestro di ieri.
  static int _dayOfYear(DateTime date) => ConfineDelGiorno.giornoDellAnno(date);

  /// Il Maestro del Rito dell'Alba di oggi, a rotazione di giorno in giorno.
  static Maestro dawnMaestro(DateTime date) =>
      Maestro.fixedOrder[_dayOfYear(date) % Maestro.fixedOrder.length];

  /// Il Maestro del Rito della Buonanotte di oggi. Ruota come il Rito dell'Alba,
  /// quindi lo stesso giorno condivide lo stesso Maestro di turno.
  static Maestro nightMaestro(DateTime date) => dawnMaestro(date);

}
