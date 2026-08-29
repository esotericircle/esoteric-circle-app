import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/corsa_dello_zodiaco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CORSA DELLO ZODIACO. Ordine CC voce 03.
///
/// **Cio' che si muove si prova sul MOVIMENTO**, cioe' confrontando due
/// istanti, non sulla presenza a schermo. Una scena ferma che contiene un
/// emblema supererebbe qualunque prova che chieda "c'e' l'emblema?": la
/// domanda giusta e' "quanti fotogrammi cambiano, e quanti segni diversi si
/// sono visti".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester,
      {required Duration durata, bool riduciMovimento = false}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(disableAnimations: riduciMovimento),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(children: [
          const ColoredBox(color: Colors.black, child: SizedBox.expand()),
          CorsaDelloZodiaco(
            segno: Zodiac.leo,
            palette: MaestroPalette.medora,
            durata: durata,
            frase: 'Medora sta leggendo il cielo di oggi',
            riduciMovimento: riduciMovimento,
          ),
        ]),
      ),
    ));
    await tester.pump();
  }

  /// Quale segno e' a schermo adesso, letto dalla chiave dell'emblema.
  String? segnoAdesso(WidgetTester tester) {
    for (final e in find.byType(Container).evaluate()) {
      final k = e.widget.key;
      if (k is ValueKey<String> && k.value.startsWith('corsa_segno_')) {
        return k.value.substring('corsa_segno_'.length);
      }
    }
    return null;
  }

  testWidgets('i dodici segni si succedono, e non e\' un lampeggio',
      (tester) async {
    await monta(tester, durata: const Duration(milliseconds: 4700));
    final visti = <String>{};
    var cambi = 0;
    String? prima = segnoAdesso(tester);
    visti.add(prima ?? '');
    // Si guarda la scena a piccoli passi, come farebbe un occhio.
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      final ora = segnoAdesso(tester);
      if (ora != null) {
        visti.add(ora);
        if (ora != prima) cambi++;
        prima = ora;
      }
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: segni diversi visti ${visti.length}, cambi di '
        'segno $cambi');
    expect(visti.length, greaterThanOrEqualTo(12),
        reason: 'la corsa ha mostrato solo ${visti.length} segni diversi: '
            'l\'ordine chiede TUTTI i simboli dello zodiaco');
    expect(cambi, greaterThanOrEqualTo(12),
        reason: 'i cambi di segno sono stati $cambi: non e\' una corsa');
    await tester.pumpAndSettle();
  });

  testWidgets('la corsa si ferma sul segno di chi guarda', (tester) async {
    await monta(tester, durata: const Duration(milliseconds: 4700));
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    final finale = segnoAdesso(tester);
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: la corsa si e\' fermata su $finale');
    expect(finale, Zodiac.leo.name,
        reason: 'la corsa si e\' fermata su un segno che non e\' quello di chi '
            'guarda');
    expect(find.text(Zodiac.leo.italianName), findsOneWidget,
        reason: 'fermandosi, la scena non nomina il segno');
    await tester.pumpAndSettle();
  });

  testWidgets('la frase di attesa si legge finche\' la corsa gira',
      (tester) async {
    await monta(tester, durata: const Duration(milliseconds: 4700));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Medora sta leggendo il cielo di oggi'), findsOneWidget,
        reason: 'durante la corsa non si legge nessuna frase di attesa');
    await tester.pumpAndSettle();
  });

  testWidgets('il segno si ingrandisce, e la scena si dissolve',
      (tester) async {
    await monta(tester, durata: const Duration(milliseconds: 4700));
    // **SI MISURA APPENA LA CORSA SI FERMA, non a un istante scelto a caso.**
    // Con novanta passi da quaranta millesimi la crescita era gia\' finita, e
    // la prova confrontava due volte lo stesso numero dicendo che non
    // cresceva: misurava il momento sbagliato, non il difetto.
    // Il segno di chi guarda passa anche DURANTE la corsa, quindi non e' lui
    // a dire che la corsa e' finita: lo dice la riga sotto, che smette di
    // essere la frase di attesa e diventa il nome del segno.
    var passi = 0;
    while (find.text(Zodiac.leo.italianName).evaluate().isEmpty &&
        passi < 200) {
      await tester.pump(const Duration(milliseconds: 40));
      passi++;
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: la corsa si e\' fermata dopo $passi passi da 40 '
        'millesimi');
    final appenaFermo = tester
        .widget<Transform>(find.ancestor(
            of: find.byKey(Key('corsa_segno_${Zodiac.leo.name}')),
            matching: find.byType(Transform)))
        .transform
        .getMaxScaleOnAxis();
    await tester.pump(const Duration(milliseconds: 400));
    final dopo = tester
        .widget<Transform>(find.ancestor(
            of: find.byKey(Key('corsa_segno_${Zodiac.leo.name}')),
            matching: find.byType(Transform)))
        .transform
        .getMaxScaleOnAxis();
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: il segno cresce da '
        '${appenaFermo.toStringAsFixed(2)} a ${dopo.toStringAsFixed(2)}');
    expect(dopo, greaterThan(appenaFermo),
        reason: 'il segno non si ingrandisce: e\' il quinto tempo che il '
            'fondatore ha chiesto');

    // E la scena se ne va: l'opacita' cala fino a zero.
    await tester.pump(const Duration(milliseconds: 2000));
    final velo = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    final residua = velo.isEmpty ? 0.0 : velo.first.opacity;
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: opacita\' della scena a fine dissolvenza '
        '${residua.toStringAsFixed(2)}');
    expect(residua, lessThan(0.05),
        reason: 'la scena non si dissolve: il responso comparirebbe di botto');
    await tester.pumpAndSettle();
  });

  testWidgets('con Riduci Movimento la scena c\'e\', ferma e intera',
      (tester) async {
    await monta(tester,
        durata: const Duration(milliseconds: 4700), riduciMovimento: true);
    expect(segnoAdesso(tester), Zodiac.leo.name,
        reason: 'senza movimento la scena mostra un segno che non e\' il tuo');
    expect(find.text(Zodiac.leo.italianName), findsOneWidget);
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: con Riduci Movimento il segno e\' gia\' quello '
        'di chi guarda, fermo');
  });

  test('le frasi di attesa sono dichiarate provvisorie', () {
    expect(FrasiDellaCorsa.provvisorie, isNotEmpty);
    for (final f in FrasiDellaCorsa.provvisorie) {
      expect(f.startsWith('Medora sta'), isTrue,
          reason: 'la frase "$f" non e\' nella forma che il fondatore ha '
              'chiesto, "Medora sta..."');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 03: frasi di attesa provvisorie '
        '${FrasiDellaCorsa.provvisorie.length}');
  });
}
