// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RIVOLUZIONE SOLARE E' QUELLA DEL JPL. Ordine ES voce 04, 29
/// settembre 2026.**
///
/// Il fondatore approva l'annuale dell'Architetto: "Rivoluzione Solare dal
/// compleanno". Dieci nascite di `docs/collaudo/ES/rivoluzione_solare_jpl.csv`,
/// calcolate fuori dall'app con skyfield e il JPL DE421: l'istante del
/// ritorno del Sole nel 2026, l'Ascendente e il Medio Cielo del luogo, i
/// corpi della lettura. Si pretende il segno giusto di ognuno e la casa
/// giusta, e lo scarto si stampa.
void main() {
  double scarto(double a, double b) => ((a - b + 540) % 360 - 180).abs();

  test('dieci ritorni del 2026 contro il JPL', () {
    final righe = File('docs/collaudo/ES/rivoluzione_solare_jpl.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(righe.length, 10, cosa: 'ritorni');
    var istanteMax = 0.0;
    var angoliMax = 0.0;
    var corpiMax = 0.0;
    final diversi = <String>[];
    for (final c in righe) {
      final nascita = DateTime.parse('${c[0].replaceFirst(' ', 'T')}:00Z');
      final lat = double.parse(c[1]);
      final lon = double.parse(c[2]);
      final sole = LaRivoluzioneSolare.soleNatale(nascita);
      final r =
          LaRivoluzioneSolare.ritorno(sole, 2026, nascita.month, nascita.day);
      final jpl = DateTime.parse(c[4]);
      final s = r.difference(jpl).inMilliseconds.abs() / 1000;
      if (s > istanteMax) istanteMax = s;
      final t = LaRivoluzioneSolare.tema(r, lat, lon);
      final asc = double.parse(c[5]);
      final mc = double.parse(c[6]);
      for (final (mio, suo) in [(t.ascendente, asc), (t.medioCielo, mc)]) {
        final d = scarto(mio, suo);
        if (d > angoliMax) angoliMax = d;
      }
      if (t.segnoDellAscendente != (asc ~/ 30) % 12) {
        diversi.add('${c[0]}: Ascendente');
      }
      if (t.segnoDelMedioCielo != (mc ~/ 30) % 12) {
        diversi.add('${c[0]}: Medio Cielo');
      }
      final corpi = {
        CorpoCeleste.luna: double.parse(c[7]),
        CorpoCeleste.venere: double.parse(c[8]),
        CorpoCeleste.giove: double.parse(c[9]),
        CorpoCeleste.saturno: double.parse(c[10]),
      };
      for (final e in corpi.entries) {
        final d = scarto(t.longitudini[e.key]!, e.value);
        if (d > corpiMax) corpiMax = d;
        final casaJpl = (((e.value - asc) % 360 + 360) % 360 ~/ 30) % 12 + 1;
        if (t.casaDi(e.key) != casaJpl) {
          diversi.add('${c[0]}: ${e.key.nome} in casa ${t.casaDi(e.key)}, '
              'JPL $casaJpl');
        }
      }
    }
    print('ORDINE ES VOCE 04: ritorni del 2026 con un segno o una casa '
        'diversi dal JPL ${diversi.length} su ${righe.length}; scarto '
        'massimo dell\'istante ${istanteMax.toStringAsFixed(0)} s, di '
        'Ascendente e Medio Cielo ${angoliMax.toStringAsFixed(3)} gradi, dei '
        'corpi ${corpiMax.toStringAsFixed(3)} gradi');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
    expect(istanteMax, lessThan(20));
    expect(angoliMax, lessThan(0.1));
  });

  test('l\'anno che corre: prima del compleanno vale quello di prima', () {
    final nascita = DateTime.utc(1990, 3, 15, 7, 30);
    final prima =
        LaRivoluzioneSolare.ritornoInCorso(nascita, DateTime.utc(2026, 3, 1));
    final dopo =
        LaRivoluzioneSolare.ritornoInCorso(nascita, DateTime.utc(2026, 3, 20));
    expect(prima.year, 2025);
    expect(dopo.year, 2026);
    expect(
        LaRivoluzioneSolare.prossimoRitorno(nascita, DateTime.utc(2026, 3, 1))
            .year,
        2026);
  });
}
