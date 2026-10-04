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
      for (var d = 0; d < 365; d += 13)
        DateTime(2026, 1, 1).add(Duration(days: d)),
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

  // LAPIDE, ordine EZ voce 02: qui stava "il numero cambia col giorno", che
  // pretendeva soltanto greaterThan(1) su una coppia sola, Leone e Pesci, e
  // passava con quattro valori in trenta giorni. Le due guardie che seguono
  // la sostituiscono e guardano tutte le coppie.

  /// Quattro finestre di trenta giorni consecutivi, in stagioni diverse: un
  /// mese fortunato non fa passare la guardia.
  final finestre = [
    DateTime(2026, 10, 4),
    DateTime(2027, 1, 10),
    DateTime(2027, 4, 20),
    DateTime(2027, 7, 30),
  ];

  /// Le 78 coppie, ciascuna coi suoi trenta numeri consecutivi.
  Map<String, List<int>> trentaGiorni(DateTime partenza) => {
        for (var i = 0; i < 12; i++)
          for (var j = i; j < 12; j++)
            '${Zodiac.values[i].id}/${Zodiac.values[j].id}': [
              for (var d = 0; d < 30; d++)
                IlConfrontoDelCielo.fra(Zodiac.values[i], Zodiac.values[j],
                        partenza.add(Duration(days: d)))
                    .affinita,
            ],
      };

  test(
      'GUARDIA EZ.02, LA VARIETA\': almeno quindici valori in trenta giorni '
      'per ogni coppia, e venti di mediana', () {
    // Le soglie sono dell'Architetto (ordine EZ voce 02): un numero che non
    // cambia almeno un giorno su due non da' nessuna ragione per tornare il
    // giorno dopo, ed era esattamente il difetto dell'ordine EY.
    for (final partenza in finestre) {
      final coppie = trentaGiorni(partenza);
      expect(coppie.length, 78);
      final distinti = {
        for (final e in coppie.entries) e.key: e.value.toSet().length,
      };
      final ordinati = distinti.values.toList()..sort();
      final mediana = ordinati[ordinati.length ~/ 2];
      final peggiore =
          distinti.entries.reduce((x, y) => x.value <= y.value ? x : y);
      final sotto = [
        for (final e in distinti.entries)
          if (e.value < 15) '${e.key} ${e.value}',
      ];
      print(
          'EZ.02 LA VARIETA\' dal ${partenza.toIso8601String().substring(0, 10)}: '
          'valori distinti per coppia da ${ordinati.first} a ${ordinati.last}, '
          'mediana $mediana, la coppia peggiore ${peggiore.key} '
          '(${peggiore.value}); Leone e Pesci ${distinti['leo/pisces']}');
      expect(sotto, isEmpty,
          reason: 'queste coppie leggono meno di quindici numeri in trenta '
              'giorni: $sotto');
      expect(mediana, greaterThanOrEqualTo(20));
    }
  });

  test(
      'GUARDIA EZ.02, LA CONTINUITA\': fra due giorni di fila la stessa '
      'coppia non salta piu\' di dodici punti', () {
    // Senza questo tetto il numero sembra tirato a caso: uno che salta da 87
    // a 42 distrugge la credibilita' piu' di uno che sta fermo.
    for (final partenza in finestre) {
      var saltoMax = 0;
      var dove = '';
      for (final e in trentaGiorni(partenza).entries) {
        for (var d = 1; d < e.value.length; d++) {
          final salto = (e.value[d] - e.value[d - 1]).abs();
          if (salto > saltoMax) {
            saltoMax = salto;
            dove = '${e.key} al giorno $d';
          }
        }
      }
      print(
          'EZ.02 LA CONTINUITA\' dal ${partenza.toIso8601String().substring(0, 10)}: '
          'salto massimo $saltoMax ($dove)');
      expect(saltoMax, lessThanOrEqualTo(12),
          reason: 'la coppia $dove salta di $saltoMax punti in un giorno');
    }
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
