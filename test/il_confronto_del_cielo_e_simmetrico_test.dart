// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_confronto_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CONFRONTO DEL CIELO E' SIMMETRICO, ordine EY voce 13 e legge L4.**
///
/// "Se da un lato esce 87 e dall'altro 84, la voce non e' chiusa." La
/// guardia enumera tutte le 78 coppie di segni (dodici con se stessi e
/// sessantasei fra due diversi) in piu' giorni dell'anno e pretende che il
/// numero sia identico nei due versi, barra per barra. La coppia la calcola
/// il telefono, non il server: lo si verifica anche, cercando il calcolo fra
/// i sorgenti del server.
void main() {
  test('GUARDIA EY.13: le 78 coppie danno lo stesso numero nei due versi', () {
    final giorni = [
      for (var d = 0; d < 365; d += 13) DateTime(2026, 1, 1).add(Duration(days: d)),
    ];
    var coppie = 0;
    var confronti = 0;
    final diversi = <String>[];
    for (var i = 0; i < 12; i++) {
      for (var j = i; j < 12; j++) {
        coppie++;
        final a = Zodiac.values[i];
        final b = Zodiac.values[j];
        for (final g in giorni) {
          confronti++;
          final ab = IlConfrontoDelCielo.fra(a, b, g);
          final ba = IlConfrontoDelCielo.fra(b, a, g);
          if (ab.affinita != ba.affinita ||
              ab.barre.toString() != ba.barre.toString()) {
            diversi.add('${a.id}/${b.id} ${g.toIso8601String()}: '
                '${ab.affinita} contro ${ba.affinita}');
          }
          expect(ab.affinita, inInclusiveRange(0, 100));
        }
      }
    }
    print('EY.13 SIMMETRIA: $coppie coppie, ${giorni.length} giorni, '
        '$confronti confronti, diversi ${diversi.length}');
    expect(coppie, 78);
    expect(diversi, isEmpty);
  });

  test('il numero cambia col giorno: il cielo di oggi conta davvero', () {
    final valori = {
      for (var d = 0; d < 30; d++)
        IlConfrontoDelCielo.fra(Zodiac.leo, Zodiac.pisces,
                DateTime(2026, 10, 1).add(Duration(days: d)))
            .affinita,
    };
    print('EY.13 VALORI DI LEONE E PESCI IN TRENTA GIORNI: $valori');
    expect(valori.length, greaterThan(1));
  });

  test('il confronto usa le barre della Sinastria VIP e non le riscrive', () {
    final sorgente =
        File('lib/core/cerchio/il_confronto_del_cielo.dart').readAsStringSync();
    expect(sorgente.contains('AltreAffinita.terraComune('), isTrue);
    expect(sorgente.contains('AltreAffinita.ritmo('), isTrue);
    // Il server non calcola la coppia: se un giorno lo facesse, la
    // simmetria andrebbe pretesa anche li'.
    final server = Directory('functions/src')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts'))
        .map((f) => f.readAsStringSync())
        .join();
    expect(server.contains('terraComune'), isFalse);
  });

  test('il confronto dichiara che e\' sul segno e porta Fonti e metodo', () {
    expect(IlConfrontoDelCielo.sulSegno,
        'Il confronto è sul segno e non sulla carta intera.');
    expect(IlConfrontoDelCielo.fontiEMetodo,
        contains('chiave di lettura del Maestro e non una dottrina'));
  });
}
