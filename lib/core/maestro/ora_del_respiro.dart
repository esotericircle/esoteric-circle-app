import 'memoria_del_respiro.dart';

/// **L'ORA IN CUI TORNI, E L'APP LA SEGUE.** Ordine DA voce 04,
/// 10 settembre 2026.
///
/// **Da dove nasce.** Nel manifesto dell'ordine DB, alla voce 12, avevo
/// scritto che *"l'ora in cui torni e' gia' nella memoria, e l'app non la
/// usa: chi medita sempre alle 22:30 e chi medita alle 7 sono due persone
/// diverse, e oggi ricevono la stessa app"*. Il fondatore ha detto di
/// procedere.
///
/// **Cosa fa**: l'avviso del Soffio si sposta da solo sull'ora in cui quella
/// persona respira davvero, invece di restare dove sta per tutti.
///
/// **E COSA NON FA, che conta di piu'.**
///
/// **Non tocca un'ora scelta a mano.** L'ordine BC voce 05 dice che ogni
/// orario si puo' cambiare, e una scelta della persona vale piu' di
/// qualunque cosa l'app abbia dedotto. Questo suggerimento entra **solo**
/// dove l'ora e' ancora quella di partenza.
///
/// **Non sposta niente su due sole sessioni.** La soglia sta in
/// `MemoriaDelRespiro.oraPiuFrequente`, che vuole almeno tre sessioni e
/// pretende che una fascia si stacchi dalle altre: sotto, non c'e'
/// un'abitudine, c'e' rumore.
///
/// **NON SUONA MAI NEL CUORE DELLA NOTTE.** Ed e' un confine di ore, non di
/// distanza: la prima stesura permetteva di spostarsi al massimo di sei ore
/// dall'ora di partenza, **e cosi' non serviva proprio il caso per cui era
/// nata**. L'ora di partenza del Soffio e' meta' mattina, chi respira la sera
/// alle 22 sta a dodici ore da li', e il suggerimento non arrivava mai.
///
/// **La guardia l'ha trovato al primo giro**, con le quattro sessioni alle 22
/// che non spostavano niente. Il vincolo vero non era *quanto si sposta*, era
/// **dove non deve mai finire**.
abstract final class OraDelRespiro {
  /// **LE ORE IN CUI UN AVVISO NON ARRIVA MAI**, comunque vada la memoria.
  ///
  /// Dall'una alle sei. Chi respira alle tre di notte lo fa, e la memoria lo
  /// sa, ma **un avviso a quell'ora non e' un'app che ti segue, e' un'app che
  /// ti sveglia**. Le 22 e le 7 ci stanno dentro, che sono i due casi veri.
  static const int nonPrimaDelle = 6 * 60;
  static const int nonDopoLe = 24 * 60 + 60;

  /// I minuti dalla mezzanotte a cui mettere l'avviso del Soffio, oppure
  /// **nulla quando non c'e' niente da suggerire** e vale l'ora di partenza.
  ///
  /// [minutiDiPartenza] e' l'ora ancorata del Dono. [minutiScelti] e' quella
  /// che la persona ha messo nel menu': quando le due differiscono, la scelta
  /// e' sua e qui non si tocca niente.
  static int? minutiSuggeriti(
    MemoriaDelRespiro memoria, {
    required int minutiDiPartenza,
    required int minutiScelti,
  }) {
    // **La scelta della persona vince sempre.** Non e' una cortesia: e' la
    // legge dell'ordine BC voce 05.
    if (minutiScelti != minutiDiPartenza) return null;
    final ora = memoria.oraPiuFrequente;
    if (ora == null) return null;
    // Si punta all'inizio di quell'ora, non a un minuto preciso: l'app non
    // promette mai un orario al minuto, e il sistema consegna comunque in una
    // finestra attorno all'ora chiesta.
    final proposti = ora * 60;
    if (proposti == minutiDiPartenza) return null;
    // **IL CUORE DELLA NOTTE RESTA FUORI.** L'una di notte si legge come
    // venticinque, cosi' il confine e' un intervallo solo invece che due.
    final sulGiro = proposti < nonPrimaDelle ? proposti + 24 * 60 : proposti;
    if (sulGiro > nonDopoLe) return null;
    return proposti;
  }

  /// **LA RIGA CHE LO DICE ALLA PERSONA**, o nulla se non c'e' niente da dire.
  ///
  /// **Un'app che sposta un avviso in silenzio non e' premurosa, e' opaca.**
  /// Questa riga sta nel menu' delle Notifiche accanto all'ora del Soffio, e
  /// dice il fatto senza vantarsi: l'ora e' quella, e si puo' cambiare.
  static String? laRiga(int? suggeriti) {
    if (suggeriti == null) return null;
    final ora = suggeriti ~/ 60;
    return 'Respiri quasi sempre verso le $ora, e questo avviso ti segue lì. '
        'Se preferisci un\'altra ora, cambiala e resta quella.';
  }
}
