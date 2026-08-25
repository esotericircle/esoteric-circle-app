/// I DUE CONFINI DEL GIORNO, e ciascuno vive in un punto solo.
///
/// Nell'app ne convivono due, e non e' un disordine: sono due cose diverse.
///
/// - **Il confine d'USO cade a MEZZANOTTE locale.** E' quello dei tetti: le
///   domande del giorno, gli approfondimenti, e da oggi l'Eco. Risponde alla
///   domanda "che giorno e' per il contatore", e la risposta che si aspetta
///   una persona e' quella del calendario.
/// - **Il confine RITUALE cade a MEZZOGIORNO locale**, e vive nella runa del
///   tramonto: li' la giornata rituale e' un'altra cosa, e ha una sua ragione
///   scritta accanto.
///
/// **Perche' questo file esiste.** Il confine d'uso stava scritto dentro un
/// metodo privato di `QuestionAllowance`, e il 3 agosto 2026 l'Eco ha avuto
/// bisogno dello stesso confine. Copiarlo avrebbe voluto dire due definizioni
/// dello stesso giorno che devono restare d'accordo, cioe' la famiglia delle
/// due porte: prima o poi una delle due cambia e l'app ribalta i contatori in
/// un momento e l'Eco in un altro. Qui c'e' una definizione sola.
class ConfineDelGiorno {
  const ConfineDelGiorno._();

  /// La chiave del giorno d'uso per [istante], che ribalta a mezzanotte locale.
  ///
  /// E' una stringa e non una data perche' serve solo a dire "e' lo stesso
  /// giorno oppure no": confrontare due stringhe non ha fusi, ore legali ne'
  /// millisecondi di scarto da interpretare.
  static String chiaveDi(DateTime istante) =>
      '${istante.year}-${istante.month}-${istante.day}';

  /// Vero se [chiave] e' il giorno d'uso in cui cade [istante].
  static bool eOggi(String chiave, DateTime istante) =>
      chiave == chiaveDi(istante);

  /// IL GIORNO DELL'ANNO DI [istante], contato sul CALENDARIO.
  ///
  /// Zero il primo gennaio, 216 il 5 agosto di un anno non bisestile: la
  /// stessa base che l'app usa da sempre per pescare dai corpora, cosi' i
  /// responsi gia' scritti restano quelli.
  ///
  /// **PERCHE' NON SI SOTTRAGGONO DUE DATE, e il numero che lo dimostra.**
  /// In sei punti l'app scriveva `data.difference(DateTime(data.year)).inDays`,
  /// che misura una DURATA e non conta giorni di calendario. Fra il primo
  /// gennaio e il cinque agosto, in Italia, c'e' il passaggio all'ora legale:
  /// la durata e' di 215 giorni e 23 ore, non di 216 giorni tondi, e
  /// `inDays` tronca. Misurato con `TZ=Europe/Rome`: alle 00:00 del 5 agosto
  /// 2026 quella formula da' **215**, e dalle 01:00 in poi **216**.
  ///
  /// Vuol dire che per i sette mesi dell'ora legale l'indice del giorno
  /// cambiava alle UNA DI NOTTE invece che a mezzanotte, e nella prima ora del
  /// giorno l'app pescava ancora dal giorno prima: l'oroscopo di ieri, il
  /// Maestro dell'alba di ieri. In UTC il difetto non si vede, perche' li'
  /// l'ora legale non esiste: e' per questo che nessuna prova lo prendeva.
  ///
  /// Qui il conto si fa in UTC, dove ogni giorno dura ventiquattro ore, dopo
  /// aver preso anno, mese e giorno CIVILI di [istante]: l'ora non entra piu'
  /// nel risultato, e il numero e' lo stesso a ogni ora dello stesso giorno.
  static int giornoDellAnno(DateTime istante) =>
      DateTime.utc(istante.year, istante.month, istante.day)
          .difference(DateTime.utc(istante.year))
          .inDays;
}
