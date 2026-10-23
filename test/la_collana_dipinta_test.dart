import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/features/respiro_della_luna/la_collana_dipinta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA COLLANA DIPINTA.** Ordine FX aggiunta FXA.01, 16 ottobre 2026.
///
/// Il fondatore: *"Non avevo chiesto di evitare grafica procedurale?"*. La
/// collana e' la pittura dello scrigno con i ritagli dipinti delle perle
/// accese, nelle posizioni misurate del file accanto alle pitture.
void main() {
  final json = jsonDecode(File(
          'assets/img/respiro_della_luna/collana/le_perle_della_collana_v2.json')
      .readAsStringSync()) as Map<String, dynamic>;

  test('le posizioni del codice sono quelle del file accanto alle pitture', () {
    final giorni = (json['giorni'] as List).cast<Map<String, dynamic>>();
    expect(LePerleDellaCollana.giorni.length, giorni.length);
    expect(giorni.length, 30);
    for (var i = 0; i < giorni.length; i++) {
      expect(giorni[i]['giorno'], i + 1,
          reason: 'i giorni del file vanno da 1 a 30 nell\'ordine');
      expect(LePerleDellaCollana.giorni[i].x, (giorni[i]['x'] as num).toDouble());
      expect(LePerleDellaCollana.giorni[i].y, (giorni[i]['y'] as num).toDouble());
      expect(LePerleDellaCollana.giorni[i].raggioMaschera,
          (json['raggio_maschera'] as num).toDouble());
    }
    final compimento =
        (json['perle_del_compimento'] as List).cast<Map<String, dynamic>>();
    expect(LePerleDellaCollana.compimento.length, compimento.length);
    for (var i = 0; i < compimento.length; i++) {
      expect(LePerleDellaCollana.compimento[i].x,
          (compimento[i]['x'] as num).toDouble());
      expect(LePerleDellaCollana.compimento[i].y,
          (compimento[i]['y'] as num).toDouble());
    }
    final med = json['medaglia'] as Map<String, dynamic>;
    expect(LePerleDellaCollana.medaglia.x, (med['x'] as num).toDouble());
    expect(LePerleDellaCollana.medaglia.y, (med['y'] as num).toDouble());
    expect(LePerleDellaCollana.medaglia.raggioMaschera,
        (med['raggio_maschera'] as num).toDouble());
    final misura = (json['misura_immagine'] as List).cast<num>();
    expect(LePerleDellaCollana.larghezza, misura[0].toDouble());
    expect(LePerleDellaCollana.altezza, misura[1].toDouble());
  });

  test('le due pitture e i 33 ritagli dipinti esistono', () {
    final asset = [
      LePerleDellaCollana.pitturaSpenta,
      LePerleDellaCollana.pitturaAccesa,
      for (var g = 1; g <= 30; g++) LePerleDellaCollana.ritaglioDelGiorno(g),
      LePerleDellaCollana.ritaglioDelCompimento(1),
      LePerleDellaCollana.ritaglioDelCompimento(2),
      LePerleDellaCollana.ritaglioDellaMedaglia,
    ];
    final mancanti = asset.where((a) => !File(a).existsSync()).toList();
    expect(mancanti, isEmpty, reason: 'asset mancanti: $mancanti');
    expect(asset.length, 35);
  });

  group('le perle si accendono come dice il file', () {
    double opacita(WidgetTester t, String chiave) =>
        t.widget<AnimatedOpacity>(find.byKey(Key(chiave))).opacity;

    Future<void> monta(WidgetTester t, LaCollanaDipinta c) => t.pumpWidget(
        MaterialApp(home: Center(child: SizedBox(width: 360, child: c))));

    testWidgets('cinque giorni accesi, il resto spento, niente compimento',
        (t) async {
      await monta(
          t, const LaCollanaDipinta(accesi: {1, 2, 3, 4, 5}, completa: false));
      for (var g = 1; g <= 30; g++) {
        expect(opacita(t, 'collana_perla_$g'), g <= 5 ? 1 : 0,
            reason: 'giorno $g');
      }
      expect(opacita(t, 'collana_compimento_1'), 0);
      expect(opacita(t, 'collana_compimento_2'), 0);
      expect(opacita(t, 'collana_medaglia'), 0);
    });

    testWidgets('in un ciclo di 29 giorni la perla 30 si accende col '
        'compimento, insieme alle due perle e alla medaglia', (t) async {
      final tutti = {for (var g = 1; g <= 29; g++) g};
      await monta(t,
          LaCollanaDipinta(accesi: tutti, completa: false, numeroDiPerle: 29));
      expect(opacita(t, 'collana_perla_30'), 0);
      expect(opacita(t, 'collana_medaglia'), 0);
      await monta(t,
          LaCollanaDipinta(accesi: tutti, completa: true, numeroDiPerle: 29));
      await t.pumpAndSettle();
      expect(opacita(t, 'collana_perla_30'), 1);
      expect(opacita(t, 'collana_compimento_1'), 1);
      expect(opacita(t, 'collana_compimento_2'), 1);
      expect(opacita(t, 'collana_medaglia'), 1);
    });

    testWidgets('ogni ritaglio sta sul suo centro misurato', (t) async {
      await monta(t, const LaCollanaDipinta(accesi: {1}, completa: false));
      final pittura = t.getRect(find.byType(LaCollanaDipinta));
      final scala = pittura.width / LePerleDellaCollana.larghezza;
      for (final g in [1, 15, 16, 30]) {
        final r = t.getRect(find.byKey(Key('collana_perla_$g')));
        final p = LePerleDellaCollana.giorni[g - 1];
        expect((r.center.dx - (pittura.left + p.x * scala)).abs(),
            lessThan(0.5));
        expect((r.center.dy - (pittura.top + p.y * scala)).abs(),
            lessThan(0.5));
      }
    });
  });
}
