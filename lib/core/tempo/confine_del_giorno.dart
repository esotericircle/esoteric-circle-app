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
}
