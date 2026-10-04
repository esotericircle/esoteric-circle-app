// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_glifo_del_legame.dart';
import 'package:esoteric_circle/features/rituals/rune_strokes.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL GLIFO DEL LEGAME, ordine EY voce 14.** Lo stesso da tutti e due i
/// lati, sempre lo stesso per la stessa coppia, e mai confondibile con una
/// runa: nessun bastone verticale da cima a fondo, nessuna runa intera.
void main() {
  const alfabeto = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  // Sigilli veri, da un generatore col seme fisso: la prova rifa' sempre gli
  // stessi.
  final caso = Random(2026);
  final sigilli = [
    for (var i = 0; i < 4000; i++)
      [for (var k = 0; k < 4; k++) alfabeto[caso.nextInt(32)]].join(),
  ];
  String sigillo(int i) => sigilli[i % sigilli.length];

  test('GUARDIA EY.14: lo stesso glifo dai due lati, su cinquecento coppie',
      () {
    var diversi = 0;
    final forme = <String>{};
    for (var i = 0; i < 500; i++) {
      final a = sigillo(i);
      final b = sigillo(i + 977);
      final sa = Zodiac.values[i % 12];
      final sb = Zodiac.values[(i * 5) % 12];
      final da = IlGlifoDelLegame.di(a, sa, b, sb);
      final daB = IlGlifoDelLegame.di(b, sb, a, sa);
      if (da.tratti.toString() != daB.tratti.toString()) diversi++;
      expect(da.tratti, hasLength(IlGlifoDelLegame.quantiTratti));
      expect(IlGlifoDelLegame.di(a, sa, b, sb).tratti.toString(),
          da.tratti.toString());
      forme.add(da.tratti.toString());
    }
    print('EY.14 GLIFO: 500 coppie, diversi fra i due lati $diversi, forme '
        'distinte ${forme.length}');
    expect(diversi, 0);
    expect(forme.length, greaterThan(400));
  });

  test('nessun glifo ha il bastone di una runa ne\' e\' una runa intera', () {
    bool verticale((Offset, Offset) t) =>
        (t.$1.dx - t.$2.dx).abs() < 0.01 && (t.$1.dy - t.$2.dy).abs() > 0.8;
    var colBastone = 0;
    var comeUnaRuna = 0;
    // Le rune, ridotte a insiemi di segmenti normalizzati.
    String forma(List<(Offset, Offset)> s) {
      final pezzi = [
        for (final (a, b) in s)
          [a, b]
              .map((p) => '${p.dx.toStringAsFixed(2)},${p.dy.toStringAsFixed(2)}')
              .toList()
            ..sort(),
      ].map((p) => p.join('-')).toList()
        ..sort();
      return pezzi.join('|');
    }

    final rune = {
      for (final r in kRuneStrokes.values)
        forma([
          for (final linea in r)
            for (var i = 1; i < linea.length; i++) (linea[i - 1], linea[i]),
        ]),
    };
    for (var i = 0; i < 2000; i++) {
      final g = IlGlifoDelLegame.di(sigillo(i), Zodiac.values[i % 12],
          sigillo(i + 31), Zodiac.values[(i + 3) % 12]);
      if (g.tratti.any(verticale)) colBastone++;
      if (rune.contains(forma(g.tratti))) comeUnaRuna++;
    }
    print('EY.14 GLIFO E RUNE: 2000 glifi, col bastone $colBastone, uguali a '
        'una runa $comeUnaRuna');
    expect(colBastone, 0);
    expect(comeUnaRuna, 0);
  });

  test('il glifo si dichiara un segno del Cerchio', () {
    expect(IlGlifoDelLegame.rigaDelMetodo,
        contains('segno del Cerchio e non un sigillo tradizionale'));
  });
}
