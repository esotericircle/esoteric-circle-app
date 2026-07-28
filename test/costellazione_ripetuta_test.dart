import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// La costellazione riconoscibile che tornava ovunque.
///
/// Mauro l'ha vista a occhio nudo, uguale in alto a destra, su piu' schermate
/// dell'onboarding e non solo. Il criterio "zero costellazioni ripetute" era
/// stato dichiarato chiuso coi diciotto semi distinti, ed era una diagnosi
/// sbagliata: il seme muove le stelle sparse, le nebulose e le comete, mentre
/// le DODICI COSTELLAZIONI ZODIACALI hanno l'ancora scritta nel codice e non
/// leggono il seme. Ogni schermata col fondale le disegnava tutte e dodici
/// nelle stesse identiche posizioni.
void main() {
  test('L\'asterismo zodiacale non e\' un elemento fisso di ogni schermata',
      () {
    // La griglia era una costante: dodici ancore uguali su ogni fondale.
    // Adesso la posizione dipende dal seme, quindi due schermate diverse non
    // possono avere lo stesso Ariete nello stesso angolo.
    final a = ZodiacLayout.perSeed(1);
    final b = ZodiacLayout.perSeed(2);
    for (var i = 0; i < kZodiacConstellations.length; i++) {
      final sign = kZodiacConstellations[i].sign;
      expect(a[i].anchor, isNot(equals(b[i].anchor)),
          reason: '$sign sta nello stesso punto con due semi diversi');
    }
  });

  test('Lo stesso seme rida\' sempre la stessa volta', () {
    // Deterministico: la scena di una schermata non balla tra un ingresso e
    // l'altro.
    final a = ZodiacLayout.perSeed(7);
    final b = ZodiacLayout.perSeed(7);
    for (var i = 0; i < a.length; i++) {
      expect(a[i].anchor, b[i].anchor);
      expect(a[i].scale, b[i].scale);
    }
  });

  test('Il fondale non disegna l\'asterismo se non glielo si chiede', () {
    // La difesa vera: il valore per difetto. Chi monta un fondale senza dire
    // niente NON ottiene le dodici costellazioni, quindi il caso "compare
    // ovunque" non puo' tornare per distrazione.
    const c = CosmosBackground(child: SizedBox.shrink());
    expect(c.showZodiac, isFalse,
        reason: 'il fondale disegna l\'asterismo per difetto');
  });

  test('Una sola schermata accende l\'asterismo', () {
    final acceso = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      if (src.contains('showZodiac: true')) {
        acceso.add(f.path.replaceAll('\\', '/'));
      }
    }
    expect(acceso.length, lessThanOrEqualTo(1),
        reason: 'l\'asterismo e\' acceso in piu\' schermate:\n'
            '${acceso.join('\n')}');
  });

  test('Le dodici restano dodici e distinte', () {
    // Sanita' della sorgente: la ricollocazione non deve perderne nessuna ne'
    // sovrapporne due nello stesso punto.
    final l = ZodiacLayout.perSeed(3);
    expect(l.length, 12);
    expect(l.map((c) => c.sign).toSet().length, 12);
    expect(Zodiac.values.length, 12);
    for (var i = 0; i < l.length; i++) {
      for (var j = i + 1; j < l.length; j++) {
        final d = (l[i].anchor - l[j].anchor).distance;
        expect(d, greaterThan(0.12),
            reason: '${l[i].sign} e ${l[j].sign} si accavallano');
      }
    }
  });
}
