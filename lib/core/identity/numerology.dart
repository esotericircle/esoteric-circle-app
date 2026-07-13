/// Numero della vita: numerologia deterministica dalla sola data di nascita.
///
/// Metodo pitagorico classico: si riduce ciascun componente della data (giorno,
/// mese, anno) alla sua radice, si sommano le radici e si riduce ancora. In ogni
/// riduzione si conservano i numeri maestri 11, 22 e 33, che non si riducono
/// oltre. Nessuna rete, nessun dato esterno, solo la data.
class LifePath {
  const LifePath({required this.number, required this.title, required this.meaning});

  /// La cifra finale: 1..9 oppure un numero maestro 11, 22, 33.
  final int number;

  /// Titolo breve del numero, nella voce di Medora.
  final String title;

  /// Una riga di significato.
  final String meaning;

  /// Vero se e' un numero maestro (11, 22, 33).
  bool get isMaster => number == 11 || number == 22 || number == 33;

  /// Calcola il Numero della vita dalla data di nascita.
  factory LifePath.forDate(DateTime date) {
    final root = _reduce(_reduce(date.day) + _reduce(date.month) + _reduce(date.year));
    return LifePath(
      number: root,
      title: _titles[root] ?? 'Numero della vita',
      meaning: _meanings[root] ?? 'La cifra che riduce il tuo giorno di nascita.',
    );
  }

  /// Riduce un intero sommando le sue cifre finche' resta una cifra sola,
  /// fermandosi pero' sui numeri maestri 11, 22, 33.
  static int _reduce(int n) {
    var value = n.abs();
    while (value > 9 && value != 11 && value != 22 && value != 33) {
      var sum = 0;
      var v = value;
      while (v > 0) {
        sum += v % 10;
        v ~/= 10;
      }
      value = sum;
    }
    return value;
  }

  static const Map<int, String> _titles = {
    1: 'Il pioniere',
    2: 'Il paciere',
    3: 'Il creativo',
    4: 'Il costruttore',
    5: 'Il viandante',
    6: 'Il custode',
    7: 'Il cercatore',
    8: 'Il realizzatore',
    9: 'Il benefattore',
    11: 'Il visionario',
    22: 'Il maestro costruttore',
    33: 'Il maestro guaritore',
  };

  static const Map<int, String> _meanings = {
    1: 'Guidi e apri strade: la tua forza sta nell\'iniziare.',
    2: 'Tessi legami e armonia: la tua forza sta nell\'unire.',
    3: 'Esprimi e crei: la tua forza sta nella parola e nella gioia.',
    4: 'Fondi e ordini: la tua forza sta nel dare basi solide.',
    5: 'Cerchi libertà e cambiamento: la tua forza sta nel movimento.',
    6: 'Proteggi e ti prendi cura: la tua forza sta nell\'amore responsabile.',
    7: 'Indaghi e contempli: la tua forza sta nella ricerca interiore.',
    8: 'Concretizzi e governi: la tua forza sta nella misura e nel potere giusto.',
    9: 'Doni e comprendi: la tua forza sta nella compassione ampia.',
    11: 'Intuisci oltre il visibile: sei un ponte fra ispirazione e vita.',
    22: 'Trasformi i sogni in opere: costruisci in grande, con radici.',
    33: 'Servi e sollevi gli altri: la cura diventa la tua via maestra.',
  };
}
