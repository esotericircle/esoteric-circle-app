// IL MAZZO RESTA NEL RIQUADRO. Segnalato dal fondatore l'11 ottobre 2026:
// "quando faccio taglia o mischia il mazzo esce dal riquadro dell'animazione
// mentre dovrebbe stare al centro".
//
// Il ventaglio vive in una fascia ritagliata alta quanto una carta piu' 34
// punti. Il mazzo si componeva a -8, cioe' gia' sopra il bordo alto, e nella
// divisione del taglio la meta' di sopra saliva di altri 26 punti: il
// ritaglio la mangiava. Qui si monta il ventaglio, si fa scorrere il taglio e
// il mescolamento nei loro atti a mazzo raccolto, e si misura il rettangolo
// vero di ogni carta contro il riquadro: deve starci dentro, e il mazzo deve
// stare al centro della fascia.

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/stesa_choreography.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> monta(WidgetTester tester,
      {double taglio = 0, double mescolamento = 0}) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 328,
            child: StesaFan(
              palette: MaestroPalette.medora,
              taken: const {},
              onPick: (_) {},
              scene: StesaScene.riposo,
              ingresso: 1,
              respiro: 0,
              taglio: taglio,
              mescolamento: mescolamento,
              taglioIndice: 39,
              reduceMotion: true,
            ),
          ),
        ),
      ),
    ));
  }

  /// I rettangoli delle carte del ventaglio fuori dal riquadro ritagliato, e
  /// lo scarto verticale del centro del mazzo dal centro del riquadro.
  ({List<String> fuori, double scartoDalCentro, int carte}) misura(
      WidgetTester tester) {
    final riquadro = tester.getRect(find
        .descendant(
            of: find.byKey(const Key('stesa_fan')),
            matching: find.byType(ClipRect))
        .first);
    final fuori = <String>[];
    var carte = 0;
    var cima = double.infinity, fondo = -double.infinity;
    for (final e in find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('stesa_fan_') &&
            (w.key! as ValueKey<String>).value != 'stesa_fan_posizione')
        .evaluate()) {
      final r = tester.getRect(find.byWidget(e.widget));
      carte++;
      cima = r.top < cima ? r.top : cima;
      fondo = r.bottom > fondo ? r.bottom : fondo;
      if (r.top < riquadro.top - 0.5 || r.bottom > riquadro.bottom + 0.5) {
        fuori.add('${(e.widget.key! as ValueKey<String>).value}: $r fuori da '
            '$riquadro');
      }
    }
    return (
      fuori: fuori,
      scartoDalCentro: ((cima + fondo) / 2 - riquadro.center.dy).abs(),
      carte: carte,
    );
  }

  testWidgets('nel taglio il mazzo resta nel riquadro, al centro',
      (tester) async {
    var guardati = 0;
    for (var t = TaglioPose.fineRaccolta + 0.01;
        t < TaglioPose.fineRicomposizione;
        t += 0.03) {
      await monta(tester, taglio: t);
      await tester.pump();
      final m = misura(tester);
      expect(m.carte, greaterThan(0));
      expect(m.fuori, isEmpty, reason: 'al taglio $t: ${m.fuori.join(" | ")}');
      guardati++;
    }
    // A mazzo appena raccolto, prima della divisione, il mazzo sta al centro
    // della fascia.
    await monta(tester, taglio: TaglioPose.fineRaccolta - 0.001);
    await tester.pump();
    expect(misura(tester).scartoDalCentro, lessThan(2.0));
    expect(guardati, greaterThanOrEqualTo(5));
  });

  testWidgets('nel mescolamento il mazzo resta nel riquadro, al centro',
      (tester) async {
    var guardati = 0;
    for (var t = MischiaPose.fineRaccolta + 0.01;
        t < MischiaPose.fineMescola;
        t += 0.03) {
      await monta(tester, mescolamento: t);
      await tester.pump();
      final m = misura(tester);
      expect(m.fuori, isEmpty,
          reason: 'al mescolamento $t: ${m.fuori.join(" | ")}');
      guardati++;
    }
    await monta(tester, mescolamento: MischiaPose.fineRaccolta + 0.001);
    await tester.pump();
    expect(misura(tester).scartoDalCentro, lessThan(8.0));
    expect(guardati, greaterThanOrEqualTo(5));
  });
}
