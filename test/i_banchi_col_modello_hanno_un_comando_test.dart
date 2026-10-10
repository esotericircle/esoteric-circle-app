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
/// a) il comando unico (`i_banchi_col_modello.py`) nomina gli undici casi,
///    ognuno esiste nel suo file, il README dice il comando, cosa misura
///    ognuno e il costo in euro, e la consegna non parte senza un giro
///    passato;
/// b) il risultato dell'ultimo giro esiste, con un esito per caso.
///
/// **LAPIDE DELLA REGOLA VECCHIA. Ordine FE voce 18, 6 ottobre 2026.** Fino
/// all'ordine FE i casi erano cinque, il comando si chiamava
/// `i_cinque_banchi.py` e questa prova pretendeva cinque esiti. L'ordine FE
/// ha aggiunto i sei percorsi del consulto (`il_filo_del_consulto_col_modello_
/// test.dart`): adesso sono undici, e il numero dei risultati ha due cifre,
/// che la vecchia lettura `RISULTATO \d` non vedeva.
void main() {
  const cartella = 'tool/banchi_col_modello';
  final comando = File('$cartella/i_banchi_col_modello.py');

  /// Quanti casi ci sono dall'ordine FE.
  const quanti = 11;

  List<(String, String)> casi() {
    final s = comando.readAsStringSync();
    final blocco = s.substring(s.indexOf('BANCHI = ['), s.indexOf('\n]\n'));
    return [
      for (final m
          in RegExp(r"\('(\w+_test\.dart)',\s*'([^']+)'").allMatches(blocco))
        (m.group(1)!, m.group(2)!),
    ];
  }

  test('a) il comando unico nomina gli undici casi, e ognuno esiste', () {
    final c = casi();
    cardinaleMinimo(c.length, quanti, cosa: 'banchi nel comando unico');
    expect(c, hasLength(quanti));
    for (final (file, nome) in c) {
      final sorgente = File('$cartella/$file');
      expect(sorgente.existsSync(), isTrue, reason: '$file non esiste');
      expect(sorgente.readAsStringSync(), contains("'$nome'"),
          reason: 'in $file non c\'e\' il caso "$nome"');
    }
  });

  test('a) il README dice il comando, gli undici casi e il costo in euro', () {
    final readme = File('$cartella/README.md');
    expect(readme.existsSync(), isTrue);
    final t = readme.readAsStringSync();
    expect(
        t, contains('python tool/banchi_col_modello/i_banchi_col_modello.py'));
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

  test('b) il risultato dell\'ultimo giro esiste con un esito per caso', () {
    final giri = Directory('docs/collaudo/banchi_col_modello')
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r'\d{4}-\d\d-\d\d\.txt$').hasMatch(f.path))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    cardinaleMinimo(giri.length, 1, cosa: 'giri dei banchi registrati');
    final dellOrdine = giri.where((f) {
      final data = RegExp(r'(\d{4}-\d\d-\d\d)\.txt$').firstMatch(f.path)!;
      return data.group(1)!.compareTo('2026-10-06') >= 0;
    }).toList();
    expect(dellOrdine, isNotEmpty,
        reason: 'nessun giro dei banchi dal 6 ottobre 2026, cioe\' con gli '
            'undici casi dell\'ordine FE');
    final t = dellOrdine.last.readAsStringSync();
    final esiti =
        RegExp(r'^RISULTATO \d+: (\S+) \| (\S+) \| (.+)$', multiLine: true)
            .allMatches(t)
            .toList();
    expect(esiti, hasLength(quanti));
    expect(esiti.map((m) => m.group(1)).toSet(), {'PASSATO'});
    expect({for (final m in esiti) (m.group(2)!, m.group(3)!)}, casi().toSet());
    expect(
        RegExp(r'^commit: [0-9a-f]{40}$', multiLine: true).hasMatch(t), isTrue);
    expect(
        RegExp(r'^COSTO DEL GIRO: \d+\.\d\d euro$', multiLine: true)
            .hasMatch(t),
        isTrue);
  });
}
