// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA FRASE DEL DISTACCO PER OGNI VIP AL PRIMO POSTO.** Ordine ER voce 16.
///
/// Prima, sul commit 3a2c12d3, la riga diceva "gli sta addosso" per tutti e
/// cinquanta; qui si scrive la riga di adesso accanto a quella di prima.
/// Si lancia con `flutter test tool/frasi_del_gemello.dart`.
void main() {
  test('le frasi del distacco', () {
    final righe = <String>[
      'ER.16, LA FRASE DEL DISTACCO PER OGNI VIP AL PRIMO POSTO, 27 settembre '
          '2026',
      '',
      'Il secondo e\' il VIP che viene dopo nel catalogo; il distacco e\' di '
          'un punto. PRIMA: la riga del commit 3a2c12d3, "gli sta addosso" '
          'per tutti. DOPO: la riga di adesso.',
      '',
    ];
    var sbagliatePrima = 0;
    var sbagliateDopo = 0;
    const vips = VipCatalog.vips;
    for (var i = 0; i < vips.length; i++) {
      final primo = vips[i];
      final secondo = vips[(i + 1) % vips.length];
      final g = GemelloAstrale(
        vip: primo,
        punteggio: 72,
        secondo: secondo,
        punteggioDelSecondo: 71,
        terzo: secondo,
        punteggioDelTerzo: 60,
      );
      final dopo = g.annuncio;
      final prima = dopo.replaceFirst(' le sta addosso', ' gli sta addosso');
      final giusto = primo.femminile ? ' le sta addosso' : ' gli sta addosso';
      if (!prima.contains(giusto)) sbagliatePrima++;
      if (!dopo.contains(giusto)) sbagliateDopo++;
      righe
        ..add('${primo.name} (${primo.femminile ? 'donna' : 'uomo'})')
        ..add('  PRIMA: $prima')
        ..add('  DOPO:  $dopo');
    }
    righe
      ..add('')
      ..add('Frasi del distacco col pronome sbagliato: prima $sbagliatePrima '
          'su ${vips.length}, dopo $sbagliateDopo su ${vips.length}.');
    Directory('docs/collaudo/ER').createSync(recursive: true);
    File('docs/collaudo/ER/gemello_frasi.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print(righe.last);
  });
}
