import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Nessuna frase falsa a schermo.
///
/// Finche' l'Ascendente era un segnaposto, dichiararlo era onesto. Da quando
/// il motore a effemeridi e' vivo quelle frasi sono BUGIE, e una bugia
/// rassicurante e' peggio di un silenzio: chi legge "per ora e' un
/// segnaposto" smette di fidarsi del numero che ha davanti, che invece e'
/// vero.
///
/// Il test guarda le stringhe del sorgente, non i commenti: i commenti che
/// raccontano perche' una parola e' stata tolta devono poter restare.
void main() {
  /// Tutte le stringhe letterali di lib/, con il file in cui stanno.
  final stringhe = <(String, String)>[];
  for (final f in Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    final percorso = f.path.replaceAll('\\', '/');
    for (final riga in f.readAsLinesSync()) {
      final pulita = riga.trimLeft();
      // Via i commenti: una riga che comincia con // non arriva a nessuno.
      if (pulita.startsWith('//')) continue;
      for (final m
          in RegExp(r"'((?:[^'\\]|\\.)*)'").allMatches(riga)) {
        stringhe.add((m.group(1)!, percorso));
      }
    }
  }

  test('Le stringhe del sorgente si leggono davvero', () {
    // Se la lettura fallisse, i test qui sotto passerebbero a vuoto.
    expect(stringhe.length, greaterThan(2000),
        reason: 'lette solo ${stringhe.length} stringhe');
  });

  test('Nessuna frase dichiara l\'Ascendente un segnaposto', () {
    final bugie = <String>[];
    for (final (s, file) in stringhe) {
      final t = s.toLowerCase();
      if (!t.contains('ascendente')) continue;
      if (t.contains('segnaposto') ||
          t.contains('provvisor') ||
          t.contains('non è ancora') ||
          t.contains('non e\' ancora')) {
        bugie.add('$file: "$s"');
      }
    }
    expect(bugie, isEmpty, reason: 'frasi false:\n${bugie.join('\n')}');
  });

  test('Nessun distintivo "Provvisorio" a schermo', () {
    final badge = <String>[];
    for (final (s, file) in stringhe) {
      // Il distintivo era la stringa secca, non una frase che la contiene.
      if (s.trim() == 'Provvisorio' || s.trim() == 'PROVVISORIO') {
        badge.add('$file: "$s"');
      }
    }
    expect(badge, isEmpty, reason: 'distintivi rimasti:\n${badge.join('\n')}');
  });

  test('Nessuna frase finisce col doppio punto', () {
    final doppi = <String>[];
    for (final (s, file) in stringhe) {
      final t = s.trimRight();
      // I puntini di sospensione sono tre e sono voluti; due punti in fila
      // alla fine di una frase sono sempre un errore di composizione, e
      // nascono quando due pezzi concatenati portano ciascuno il suo punto.
      if (t.length > 8 && t.endsWith('..') && !t.endsWith('...')) {
        doppi.add('$file: "$s"');
      }
    }
    expect(doppi, isEmpty, reason: 'doppi punti:\n${doppi.join('\n')}');
  });
}
