// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/l_ora_d_oro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ORA D'ORO E' QUELLA DEL CIELO, E NEI GIORNI SENZA NON SI INVENTA.**
/// Ordine ES voce 32, 29 settembre 2026.
///
/// Dieci casi calcolati fuori dall'app col JPL DE440s (skyfield), con la
/// stessa regola (trigono, sestile, congiunzione; Giove, Venere, Sole; il
/// primo del giorno di Roma): `docs/collaudo/ES/ore_d_oro.csv`. L'undicesimo
/// giorno ha due candidati, una congiunzione al Sole alle 5 e un trigono a
/// Giove alle 17: vince il trigono, e la prova vede l'ordine di preferenza. L'app deve
/// trovare lo stesso aspetto allo stesso punto, e l'istante entro due minuti;
/// nei giorni in cui il JPL non ne trova, l'app non deve mostrarne.
void main() {
  test('dieci giorni contro il JPL', () {
    final righe = File('docs/collaudo/ES/ore_d_oro.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .toList();
    cardinaleMinimo(righe.length, 10, cosa: 'giorni di controllo');
    final diversi = <String>[];
    final scarti = <double>[];
    var inventate = 0;
    for (final r in righe) {
      final c = r.split(',');
      final giorno = DateTime.parse(c[0]);
      PlanetPosition punto(String id, double l) => PlanetPosition(
          id: id,
          name: id,
          glyph: '',
          longitude: l,
          sign: Zodiac.values[(l ~/ 30) % 12]);
      final carta = NatalChart(
        sunSign: Zodiac.values[(double.parse(c[1]) ~/ 30) % 12],
        planets: [
          punto('sun', double.parse(c[1])),
          punto('venus', double.parse(c[2])),
          punto('jupiter', double.parse(c[3])),
        ],
        ascendantLongitude: 0,
        midheavenLongitude: 270,
        houses: const [],
        hasTime: true,
      );
      // Mezzanotte di Roma nel 2026: ora legale (UTC+2) fino al 25 ottobre,
      // poi UTC+1.
      final legale =
          giorno.month < 10 || (giorno.month == 10 && giorno.day < 25);
      final inizio = DateTime.utc(giorno.year, giorno.month, giorno.day)
          .subtract(Duration(hours: legale ? 2 : 1));
      final ora = LOraDOro.di(carta, inizio);
      if (c[4] == 'nessuno') {
        if (ora != null) {
          inventate++;
          diversi.add('${c[0]}: il JPL non ne trova, l\'app si');
        }
        continue;
      }
      if (ora == null) {
        diversi.add('${c[0]}: il JPL trova ${c[4]} a ${c[5]}, l\'app no');
        continue;
      }
      final atteso = DateTime.parse(c[6]);
      final scarto = ora.istante.difference(atteso).inSeconds.abs() / 60.0;
      scarti.add(scarto);
      if (ora.aspetto.name != c[4] || ora.punto != c[5] || scarto > 2) {
        diversi.add('${c[0]}: app ${ora.aspetto.name} ${ora.punto} '
            '${ora.istante}, JPL ${c[4]} ${c[5]} $atteso');
      }
    }
    final medio =
        scarti.isEmpty ? 0 : scarti.reduce((a, b) => a + b) / scarti.length;
    print('ORDINE ES VOCE 32: giorni ${righe.length}, ore d\'oro confrontate '
        '${scarti.length}, scarto medio ${medio.toStringAsFixed(2)} minuti, '
        'inventate $inventate, diverse ${diversi.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });
}
