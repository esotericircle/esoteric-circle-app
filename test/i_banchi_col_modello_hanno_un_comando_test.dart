import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// I BANCHI COL MODELLO NON SONO CODICE MORTO. Ordine FD voce 03.
///
/// **Il difetto.** L'ordine FC voce 11.2 aveva portato i cinque casi che
/// chiamano Gemini davvero in `tool/banchi_col_modello/`, fuori dal cancello,
/// e li aveva lasciati senza un comando, senza un'ora per girare e senza un
/// posto per il risultato: un banco che nessuno lancia e' codice morto.
///
/// **Cosa si prova.**
/// a) il comando unico (`i_cinque_banchi.py`) nomina i cinque casi, ognuno
///    esiste nel suo file, il README dice il comando, cosa misura ognuno e
///    il costo in euro, e la consegna non parte senza un giro passato;
/// b) il risultato del giro dell'ordine FD esiste, coi cinque esiti.
void main() {
  const cartella = 'tool/banchi_col_modello';
  final comando = File('$cartella/i_cinque_banchi.py');

  List<(String, String)> casi() {
    final s = comando.readAsStringSync();
    final blocco = s.substring(s.indexOf('BANCHI = ['), s.indexOf('\n]\n'));
    return [
      for (final m in RegExp(r"\('(\w+_test\.dart)',\s*'([^']+)'")
          .allMatches(blocco))
        (m.group(1)!, m.group(2)!),
    ];
  }

  test('a) il comando unico nomina i cinque casi, e ognuno esiste', () {
    final c = casi();
    cardinaleMinimo(c.length, 5, cosa: 'banchi nel comando unico');
    expect(c, hasLength(5));
    for (final (file, nome) in c) {
      final sorgente = File('$cartella/$file');
      expect(sorgente.existsSync(), isTrue, reason: '$file non esiste');
      expect(sorgente.readAsStringSync(), contains("'$nome'"),
          reason: 'in $file non c\'e\' il caso "$nome"');
    }
  });

  test('a) il README dice il comando, i cinque casi e il costo in euro', () {
    final readme = File('$cartella/README.md');
    expect(readme.existsSync(), isTrue);
    final t = readme.readAsStringSync();
    expect(t, contains('python tool/banchi_col_modello/i_cinque_banchi.py'));
    for (final (file, nome) in casi()) {
      expect(t, contains(file), reason: 'il README non nomina $file');
      expect(t, contains(nome), reason: 'il README non nomina "$nome"');
    }
    expect(RegExp(r'\d+,\d\d euro').hasMatch(t), isTrue,
        reason: 'il README non dichiara il costo di un giro in euro');
  });

  test('a) la consegna non parte senza un giro dei banchi passato', () {
    final c = File('tool/consegna.py').readAsStringSync();
    expect(c, contains('passati, perche = i_banchi_sono_passati()'));
    expect(c, contains("raise SystemExit('BANCHI COL MODELLO: '"));
  });

  test('b) il risultato del giro dell\'ordine FD esiste coi cinque esiti', () {
    final giri = Directory('docs/collaudo/banchi_col_modello')
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r'\d{4}-\d\d-\d\d\.txt$').hasMatch(f.path))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    cardinaleMinimo(giri.length, 1, cosa: 'giri dei banchi registrati');
    final dellOrdine = giri.where((f) {
      final data = RegExp(r'(\d{4}-\d\d-\d\d)\.txt$').firstMatch(f.path)!;
      return data.group(1)!.compareTo('2026-10-05') >= 0;
    }).toList();
    expect(dellOrdine, isNotEmpty,
        reason: 'nessun giro dei banchi dal 5 ottobre 2026');
    final t = dellOrdine.last.readAsStringSync();
    final esiti = RegExp(r'^RISULTATO \d: (\S+) \| (\S+) \| (.+)$',
            multiLine: true)
        .allMatches(t)
        .toList();
    expect(esiti, hasLength(5));
    expect(esiti.map((m) => m.group(1)).toSet(), {'PASSATO'});
    expect({for (final m in esiti) (m.group(2)!, m.group(3)!)},
        casi().toSet());
    expect(RegExp(r'^commit: [0-9a-f]{40}$', multiLine: true).hasMatch(t),
        isTrue);
    expect(RegExp(r'^COSTO DEL GIRO: \d+\.\d\d euro$', multiLine: true)
        .hasMatch(t), isTrue);
  });
}
