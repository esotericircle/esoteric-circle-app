// ignore_for_file: avoid_print
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/riquadro_del_numero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL NUMERO STA AL CENTRO DEL SUO RIQUADRO.** Ordine ES voce 14, 28
/// settembre 2026.
///
/// **Il fatto del fondatore, sul telefono**: *"nel riquadro del numero
/// fortunato, il numero deve essere centrato nel riquadro"*. Il riquadro sta
/// accanto a quello del colore, piu' alto, e dall'ordine DD voce 09 si stira
/// fino alla sua altezza: qui lo si monta allo stesso modo, in una riga che
/// pareggia le altezze accanto a un riquadro alto 84 punti, come sul
/// telefono.
///
/// **Si misura la distanza fra il centro della cifra e il centro del
/// riquadro**, in orizzontale e in verticale, con una cifra e con due, alla
/// scala del testo normale e a quella ingrandita (1,3). Vista rossa col
/// riquadro di prima, la colonna allineata all'inizio.
void main() {
  Future<({double orizzontale, double verticale})> scarto(
      WidgetTester tester, int numero, double scala) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(390, 844), textScaler: TextScaler.linear(scala)),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RiquadroDelNumero(
                        numero: numero, palette: MaestroPalette.medora),
                    const SizedBox(width: 8),
                    // Il vicino alto: il riquadro del colore del giorno, che
                    // col suo testo su due righe arriva a 84 punti.
                    const Expanded(child: SizedBox(height: 84)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    final riquadro =
        tester.getRect(find.byKey(const Key('riquadro_del_numero')));
    final cifra =
        tester.getRect(find.byKey(const Key('riquadro_del_numero_cifra')));
    final o = (cifra.center.dx - riquadro.center.dx).abs();
    final v = (cifra.center.dy - riquadro.center.dy).abs();
    print('ORDINE ES VOCE 14: numero $numero alla scala $scala, riquadro '
        '${riquadro.width.toStringAsFixed(1)}x'
        '${riquadro.height.toStringAsFixed(1)}, scarto del centro '
        '${o.toStringAsFixed(1)} in orizzontale e ${v.toStringAsFixed(1)} in '
        'verticale');
    // **GRANDE**, ordine EU voce 10: la cifra e' piu' alta dell'etichetta
    // del riquadro ("NUMERO"), e se ne vede la differenza.
    final etichetta = tester.getRect(find.text('NUMERO').first);
    print('ORDINE EU VOCE 10: cifra alta ${cifra.height.toStringAsFixed(1)}, '
        'etichetta ${etichetta.height.toStringAsFixed(1)}');
    expect(cifra.height, greaterThan(etichetta.height * 1.8),
        reason: 'il numero non e\' grande: alto ${cifra.height} contro '
            '${etichetta.height} dell\'etichetta');
    return (orizzontale: o, verticale: v);
  }

  for (final numero in const [7, 42]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets('il numero $numero alla scala $scala sta al centro',
          (tester) async {
        final s = await scarto(tester, numero, scala);
        expect(s.orizzontale, lessThanOrEqualTo(1.0),
            reason: 'il numero $numero alla scala $scala e\' fuori centro in '
                'orizzontale di ${s.orizzontale.toStringAsFixed(1)} punti');
        expect(s.verticale, lessThanOrEqualTo(1.0),
            reason: 'il numero $numero alla scala $scala e\' fuori centro in '
                'verticale di ${s.verticale.toStringAsFixed(1)} punti');
      });
    }
  }
}
