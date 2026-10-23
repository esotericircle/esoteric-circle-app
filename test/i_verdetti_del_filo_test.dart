// Ordine FF voce 08, 7 ottobre 2026: il giudice del filo separa le
// contraddizioni dichiarate da quelle a tradimento, e la soglia conta solo
// le seconde. La prova gira senza il modello: guarda la regola che il
// giudice riceve e il conto che il banco ne fa.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/banchi_col_modello/i_verdetti_del_filo.dart';

ConteggioDelFilo _conta(List<String?> verdetti) {
  final c = ConteggioDelFilo();
  verdetti.forEach(c.conta);
  return c;
}

void main() {
  test('a) la regola nomina i quattro verdetti e li definisce', () {
    for (final v in [contraddice, cambiaDichiarando, ignora, portaAvanti]) {
      expect(regolaDelGiudice, contains('$v:'),
          reason: 'la regola non definisce $v');
    }
    // Il giudice non sa che cosa si misura: nessuna soglia nella regola.
    expect(regolaDelGiudice.toLowerCase(), isNot(contains('soglia')));
  });

  test('b) le dichiarate non sono un difetto, quelle a tradimento si', () {
    final c = _conta([
      contraddice,
      cambiaDichiarando,
      cambiaDichiarando,
      cambiaDichiarando,
      ...List.filled(6, portaAvanti),
    ]);
    expect(c.giudicate, 10);
    expect(c.aTradimento, 1);
    expect(c.dichiarate, 3);
    expect(c.quotaSenzaDifetto, closeTo(0.9, 1e-9));
    expect(c.passa, isTrue);
  });

  test('c) tre contraddizioni a tradimento non passano, anche con la quota',
      () {
    // Quindici risposte: la quota di otto su dieci e' raggiunta, cosi'
    // cade solo la soglia delle due a tradimento.
    final c = _conta([
      contraddice,
      contraddice,
      contraddice,
      ...List.filled(12, portaAvanti),
    ]);
    expect(c.aTradimento, 3);
    expect(c.quotaSenzaDifetto, closeTo(0.8, 1e-9));
    expect(c.passa, isFalse);
  });

  test('c) due a tradimento passano solo con otto su dieci senza difetto', () {
    expect(
        _conta([contraddice, contraddice, ...List.filled(8, portaAvanti)])
            .passa,
        isTrue);
    expect(
        _conta([
          contraddice,
          contraddice,
          ignora,
          ...List.filled(7, portaAvanti),
        ]).passa,
        isFalse);
  });

  test('d) un verdetto mancante non e\' mai senza difetto', () {
    final c = _conta([null, 'NESSUN VERDETTO', ...List.filled(8, portaAvanti)]);
    expect(c.senzaVerdetto, 2);
    expect(c.quotaSenzaDifetto, closeTo(0.8, 1e-9));
  });

  test('e) la riga del resoconto porta i due numeri separati', () {
    final r = _conta([contraddice, cambiaDichiarando]).riga('A');
    expect(r, contains('contraddice a tradimento 1'));
    expect(r, contains('cambia dichiarando 1'));
  });

  test('f) il banco del filo usa questa regola e questo conto', () {
    final banco = File(
            'tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart')
        .readAsStringSync();
    expect(banco, contains('const _regola = giudice.regolaDelGiudice;'));
    expect(banco, contains('conteggio.conta('));
    expect(banco, contains('conteggio.aTradimento, lessThanOrEqualTo(2)'));
    expect(banco, contains('conteggio.quotaSenzaDifetto'));
  });
}
