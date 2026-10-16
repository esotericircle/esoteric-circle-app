// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'dart:io';

import 'package:esoteric_circle/core/astro/meeus/la_luna_intera.dart';
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
    var oltre = 0;
    for (final r in righe) {
      final c = r.split(',');
      final quando = DateTime.parse(c[0]);
      final jpl = double.parse(c[1]);
      final jd = IlCieloDiMeeus.giornoGiuliano(quando);
      // **ORDINE FD VOCE 02**: la porta del cielo e' verificata fino al 31
      // dicembre 2099, e oltre non risponde. Gli istanti di questo file oltre
      // quel giorno pretendono il rifiuto, non un numero.
      if (!IlCieloDiMeeus.verificato(jd)) {
        oltre++;
        expect(() => IlCieloDiMeeus.longitudine(CorpoCeleste.luna, jd),
            throwsA(isA<FuoriDalCieloVerificato>()));
        continue;
      }
      final app = IlCieloDiMeeus.longitudine(CorpoCeleste.luna, jd);
      var d = (app - jpl).abs() % 360;
      if (d > 180) d = 360 - d;
      if (d > peggiore) peggiore = d;
      // Oltre il 2050 il Delta T futuro di Espenak e Meeus si allontana da
      // quello del JPL: la tolleranza e' quella misurata, 0,025 gradi.
      if (d > 0.025) lontani.add('$quando: app $app, JPL $jpl');
    }
    print('ORDINE ES: Luna intera contro JPL su ${righe.length - oltre} '
        'istanti dentro l\'intervallo verificato, scarto massimo '
        '${peggiore.toStringAsFixed(4)} gradi; $oltre oltre il 2099, rifiutati');
    cardinaleMinimo(righe.length - oltre, 35,
        cosa: 'istanti della Luna dentro l\'intervallo verificato');
    expect(lontani, isEmpty, reason: lontani.join('\n'));
  });

  test('il Sole di nascita contro il JPL DE440s, quaranta istanti', () {
    final righe = File('docs/collaudo/ES/riferimenti_sole.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .toList();
    cardinaleMinimo(righe.length, 40, cosa: 'istanti di riferimento del Sole');
    var peggiore = 0.0;
    for (final r in righe) {
      final c = r.split(',');
      final app = IlCieloDiMeeus.longitudine(CorpoCeleste.sole,
          IlCieloDiMeeus.giornoGiuliano(DateTime.parse(c[0])));
      var d = (app - double.parse(c[1])).abs() % 360;
      if (d > 180) d = 360 - d;
      if (d > peggiore) peggiore = d;
    }
    print('ORDINE ES: Sole di nascita contro JPL su ${righe.length} istanti, '
        'scarto massimo ${peggiore.toStringAsFixed(4)} gradi');
    // Un decano e' largo dieci gradi: un centesimo di grado e' un quarto
    // d'ora di Sole.
    expect(peggiore, lessThan(0.01));
  });
}
