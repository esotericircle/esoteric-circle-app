// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/la_luna_intera.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA LUNA DEI SEGNI E' QUELLA DEL JPL AL CENTESIMO DI GRADO.** Ordine ES
/// voci 07 e 11, 29 settembre 2026.
///
/// Il segno vedico e la dimora araba vengono dalla Luna di nascita. La Luna
/// di `Effemeridi`, troncata a undici termini, sbaglia fino a 0,27 gradi
/// (misura sul JPL DE440s, 20.000 istanti fra il 1900 e il 2100): il segno
/// vedico sarebbe sbagliato per circa una nascita su trecento, la dimora
/// araba, larga dodici gradi e cinquantuno primi, piu' spesso. `LaLunaIntera`
/// e' il capitolo 47 di Meeus intero, con la nutazione del capitolo 22 e il
/// Delta T di Espenak e Meeus: sui 20.000 istanti scarta al massimo 0,0095
/// gradi a parita' di Delta T.
void main() {
  test('l\'esempio 47.a di Meeus: 12 aprile 1992, 0h TD, 133,167265 gradi', () {
    final l = LaLunaIntera.longitudineTd(2448724.5);
    print('ORDINE ES: esempio 47.a, longitudine apparente '
        '${l.toStringAsFixed(6)}');
    expect(l, closeTo(133.167265, 0.00001));
  });

  test('quaranta istanti fra il 1900 e il 2100 contro il JPL DE440s', () {
    final righe = File('docs/collaudo/ES/riferimenti_luna.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .toList();
    cardinaleMinimo(righe.length, 40,
        cosa: 'istanti di riferimento della Luna');
    var peggiore = 0.0;
    final lontani = <String>[];
    for (final r in righe) {
      final c = r.split(',');
      final quando = DateTime.parse(c[0]);
      final jpl = double.parse(c[1]);
      final app = LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(quando));
      var d = (app - jpl).abs() % 360;
      if (d > 180) d = 360 - d;
      if (d > peggiore) peggiore = d;
      // Oltre il 2050 il Delta T futuro di Espenak e Meeus si allontana da
      // quello del JPL: la tolleranza e' quella misurata, 0,025 gradi.
      if (d > 0.025) lontani.add('$quando: app $app, JPL $jpl');
    }
    print('ORDINE ES: Luna intera contro JPL su ${righe.length} istanti, '
        'scarto massimo ${peggiore.toStringAsFixed(4)} gradi');
    expect(lontani, isEmpty, reason: lontani.join('\n'));
  });
}
