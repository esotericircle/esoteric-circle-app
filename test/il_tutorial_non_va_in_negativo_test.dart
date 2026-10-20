import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL TUTORIAL NON VA IN NEGATIVO.** Ordine GA voce 11, 20 ottobre 2026,
/// difetto 12 della ricognizione.
///
/// Il fatto, letto in Crashlytics sulla build 2314: sei eventi "BoxConstraints
/// has non-normalized height constraints, 0.0<=h<=-32.0" lanciati da
/// `_Carta.build` di `primo_approdo.dart`. **-32 e' esattamente meno due
/// volte l'orlo** (`_orlo`, 16 punti): la carta del fumetto e' alta al
/// massimo `fondo - cima`, cioe' l'altezza della finestra meno le barre e i
/// due orli, e quando la finestra non ha ancora la sua altezza (aprendo
/// l'app, lo stesso istante che rompeva la home) quel massimo nasce
/// negativo. In debug e' l'errore rosso; in release vincoli rovesciati che
/// nessuno sa disegnare.
///
/// Padre (Regola C): ordine FD, commit `6944b91f` del 5 ottobre 2026 (il
/// fumetto fra la barra di stato e la barra dei tasti, A35), che ha scritto
/// `maxHeight: alMassimo` senza un pavimento.
///
/// La prova monta il tutorial in una finestra di 0, 20 e 40 punti, e anche
/// larga zero, poi la porta alla sua misura vera, al passo con la freccia
/// e a quello senza: nessun vincolo negativo o rovesciato.
void main() {
  bool grave(String e) =>
      e.contains('NOT NORMALIZED') ||
      e.contains('negative') ||
      e.contains('non-normalized') ||
      e.contains('_elements.contains') ||
      e.contains('minWidth');

  Future<List<String>> monta(WidgetTester tester, Size iniziale,
      {required bool colPassoConLaFreccia}) async {
    SharedPreferences.setMockInitialValues(
        {MemoriaDelPrimoApprodo.chiaveArmata: true});
    MemoriaDelPrimoApprodo.dimenticaLApertura();
    addTearDown(MemoriaDelPrimoApprodo.dimenticaLApertura);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final errori = <String>[];
    final diPrima = FlutterError.onError;
    FlutterError.onError = (dettagli) => errori.add(dettagli.toString());
    try {
      const vera = Size(360, 800);
      tester.view.physicalSize = colPassoConLaFreccia ? vera : iniziale;
      await tester.pumpWidget(const MaterialApp(
        home: PrimoApprodo(
          child: Scaffold(
            body: Center(
              child: AncoraDelPrimoApprodo(
                nome: BersagliDelPrimoApprodo.trio,
                child: SizedBox(width: 200, height: 270),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      if (colPassoConLaFreccia) {
        // Il secondo fumetto e' il primo con la freccia: poi la finestra
        // perde la sua altezza e la ritrova.
        await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        tester.view.physicalSize = iniziale;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
      // La finestra prende la sua altezza vera: il tutorial si ricostruisce.
      tester.view.physicalSize = vera;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    } finally {
      FlutterError.onError = diPrima;
    }
    return errori;
  }

  for (final iniziale in const [
    Size(360, 0),
    Size(360, 20),
    Size(360, 40),
    Size(0, 0),
  ]) {
    for (final freccia in const [false, true]) {
      final nome = '${iniziale.width.round()}x${iniziale.height.round()}';
      testWidgets(
          'in una finestra di $nome punti, ${freccia ? 'al passo con la '
              'freccia' : 'al benvenuto'}, il tutorial non costruisce vincoli '
          'negativi', (tester) async {
        final errori =
            await monta(tester, iniziale, colPassoConLaFreccia: freccia);
        final gravi = errori.where(grave).toList();
        // Gli errori che non sono vincoli negativi si stampano lo stesso,
        // con la seconda e la terza riga, perche' chi legge sappia che cosa
        // sono: a 40 punti, al passo con la freccia, la colonna del fumetto
        // trabocca di 8 punti per un fotogramma, e non e' un vincolo rotto.
        final quali = [
          for (final e in errori) e.split('\n').skip(1).take(2).join(' '),
        ].join(' | ');
        // ignore: avoid_print
        print('ORDINE GA VOCE 11: tutorial a $nome, '
            '${freccia ? 'freccia' : 'benvenuto'}: ${gravi.length} vincoli '
            'negativi su ${errori.length} errori ($quali)');
        expect(gravi, isEmpty,
            reason: 'il tutorial ha costruito un vincolo negativo: '
                '${gravi.map((e) => e.split('\n').take(4).join(' ')).join(' | ')}');
      });
    }
  }
}
