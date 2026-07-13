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

  /// La riduzione passo per passo dalla data di nascita al Numero della vita,
  /// da mostrare a chi vuole capire da dove nasce la cifra.
  static LifePathBreakdown breakdown(DateTime date) =>
      LifePathBreakdown.of(date);

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

  /// Riduce un numero mostrando ogni passaggio, per la spiegazione a schermo.
  /// Restituisce ad esempio "1 + 9 + 9 + 0 = 19 → 1 + 9 = 10 → 1 + 0 = 1". Se il
  /// numero e' gia' una cifra sola (o un maestro), restituisce il numero stesso.
  static String explainReduction(int n) {
    var v = n.abs();
    final segments = <String>[];
    while (v > 9 && v != 11 && v != 22 && v != 33) {
      final digits = v.toString().split('').map(int.parse).toList();
      final sum = digits.reduce((a, b) => a + b);
      segments.add('${digits.join(' + ')} = $sum');
      v = sum;
    }
    if (segments.isEmpty) return '$v';
    return segments.join(' → ');
  }
}

/// La riduzione numerologica passo per passo, dalla data di nascita al Numero
/// della vita. Serve al pannello "Cosa significa" del Sigillo: chi vuole capire
/// legge da dove nasce ogni cifra.
class LifePathBreakdown {
  const LifePathBreakdown({
    required this.date,
    required this.dayRoot,
    required this.monthRoot,
    required this.yearRoot,
    required this.sum,
    required this.number,
  });

  final DateTime date;
  final int dayRoot;
  final int monthRoot;
  final int yearRoot;
  final int sum;

  /// La cifra finale, coincide con `LifePath.forDate(date).number`.
  final int number;

  factory LifePathBreakdown.of(DateTime date) {
    final dayRoot = LifePath._reduce(date.day);
    final monthRoot = LifePath._reduce(date.month);
    final yearRoot = LifePath._reduce(date.year);
    final sum = dayRoot + monthRoot + yearRoot;
    return LifePathBreakdown(
      date: date,
      dayRoot: dayRoot,
      monthRoot: monthRoot,
      yearRoot: yearRoot,
      sum: sum,
      number: LifePath._reduce(sum),
    );
  }

  /// Le righe leggibili della riduzione, in ordine.
  List<String> get steps {
    final lines = <String>[
      'Giorno ${date.day}: ${LifePath.explainReduction(date.day)}',
      'Mese ${date.month}: ${LifePath.explainReduction(date.month)}',
      'Anno ${date.year}: ${LifePath.explainReduction(date.year)}',
    ];
    final sumLine = StringBuffer('Somma: $dayRoot + $monthRoot + $yearRoot = $sum');
    if (sum != number) sumLine.write(' → $number');
    lines.add(sumLine.toString());
    return lines;
  }
}
