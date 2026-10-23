import 'daily_elements.dart';
import 'scelta_degli_avvisi.dart';

/// **QUANDO UN DONO SI APRE, E FINO A QUANDO.** Ordine DD voce 05,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: i cinque Doni si aprono a qualunque ora. Il
/// Rito dell'Alba si puo' fare a mezzanotte, il Sigillo del Sogno alle sette
/// del mattino, e cosi' l'appuntamento con la giornata non esiste: se tutto e'
/// disponibile sempre, niente ha un'ora sua.
///
/// **LA LEGGE, ed e' una sola frase**: un Dono si apre **all'ora della sua
/// notifica** e resta aperto **fino al rinnovo**, cioe' fino alla stessa ora
/// del giorno dopo.
///
/// **E L'ORA E' QUELLA CHE LA PERSONA HA SCELTO.** Chi ha spostato l'avviso
/// dell'Alba alle nove non deve trovare il Dono aperto dalle sette: sarebbe una
/// seconda verita' sullo stesso appuntamento. Chi non ha scelto niente, e chi
/// ha spento l'avviso, prende **l'ora di casa** che il Dono porta scritta:
/// Alba 7:00, Soffio 10:30, Arcano 13:00, Tramonto 18:30, Notte 22:30.
/// [SceltaDegliAvvisi.minutiDi] gia' risponde a questa domanda per tutti e due
/// i casi, e questa classe non ne apre una seconda.
///
/// **IL FUSO E' QUELLO DELLA PERSONA, senza fare niente.** Le ore qui dentro
/// sono ore locali confrontate con un [DateTime] locale: `DateTime.now()` sul
/// telefono e' gia' l'ora di chi guarda. Non si converte niente, e proprio per
/// questo non si puo' sbagliare la conversione.
abstract final class FinestraDelDono {
  /// **VERO SE IL DONO E' APERTO ADESSO.**
  ///
  /// Aperto vuol dire: l'ora di [adesso] ha raggiunto l'ora di apertura di
  /// oggi. Prima di quell'ora il Dono di oggi non c'e' ancora; da quell'ora in
  /// poi resta aperto per tutto il resto del giorno, e il rinnovo arriva alla
  /// stessa ora di domani.
  static bool aperto(
    DailyElement dono, {
    required SceltaDegliAvvisi avvisi,
    required DateTime adesso,
  }) {
    final minuti = avvisi.minutiDi(dono);
    return _minutiDi(adesso) >= minuti;
  }

  /// **QUANDO SI APRE LA PROSSIMA VOLTA**, in ora locale.
  ///
  /// Se non e' ancora l'ora, e' oggi a quell'ora. Se e' gia' aperto, e' il
  /// rinnovo di domani: la stessa risposta serve alle due domande, e tenerle
  /// separate vorrebbe dire due conti che possono divergere.
  static DateTime prossimaApertura(
    DailyElement dono, {
    required SceltaDegliAvvisi avvisi,
    required DateTime adesso,
  }) {
    final minuti = avvisi.minutiDi(dono);
    final oggi = DateTime(adesso.year, adesso.month, adesso.day)
        .add(Duration(minutes: minuti));
    if (_minutiDi(adesso) < minuti) return oggi;
    return oggi.add(const Duration(days: 1));
  }

  /// **COSA DICE LA CARD CHIUSA**, e dice l'ora, non "non ancora".
  ///
  /// L'ordine lo chiede per nome: *la card chiusa deve dire quando si apre*.
  /// Una porta chiusa senza orario e' una porta che sembra rotta; con l'orario
  /// e' un appuntamento.
  static String quandoSiApre(
    DailyElement dono, {
    required SceltaDegliAvvisi avvisi,
    required DateTime adesso,
  }) {
    final q = prossimaApertura(dono, avvisi: avvisi, adesso: adesso);
    final ora = q.hour.toString().padLeft(2, '0');
    final minuto = q.minute.toString().padLeft(2, '0');
    final domani = q.day != adesso.day;
    return domani
        ? 'Si apre domani alle $ora:$minuto'
        : 'Si apre alle $ora:$minuto';
  }

  /// **IL GIORNO DEL DONO, che non comincia a mezzanotte.**
  ///
  /// Serve a chi deve sapere se il Dono di questa finestra e' gia' stato
  /// vissuto: la finestra va dall'ora di apertura alla stessa ora del giorno
  /// dopo, quindi le ore prima dell'apertura appartengono ancora alla finestra
  /// di ieri.
  static DateTime giornoDellaFinestra(
    DailyElement dono, {
    required SceltaDegliAvvisi avvisi,
    required DateTime adesso,
  }) {
    final minuti = avvisi.minutiDi(dono);
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    return _minutiDi(adesso) >= minuti
        ? oggi
        : oggi.subtract(const Duration(days: 1));
  }

  static int _minutiDi(DateTime t) => t.hour * 60 + t.minute;
}
