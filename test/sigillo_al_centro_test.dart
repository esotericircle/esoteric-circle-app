import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/circle_seal.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/sigillo_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il Sigillo sta al CENTRO, si tiene premuto, e finisce con un trionfo.
///
/// Per tre build la schermata non e' cambiata: il Sigillo restava in alto con
/// mezzo schermo vuoto sotto, perche' viveva dentro l'impalcatura comune dei
/// passi, che tiene il visivo in una scatola alta 190 in cima. Il criterio qui
/// e' quello scritto nell'ordine, in numeri.
void main() {
  const seal = CircleSeal(
    name: 'Mauro',
    sign: Zodiac.pisces,
    lifePath: 4,
    element: SealElement.acqua,
  );

  Future<Rect> montaSigillo(WidgetTester tester,
      {Size schermo = const Size(390, 844),
      bool reduceMotion = false,
      VoidCallback? onComplete}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = schermo;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: SigilloStep(
          seal: seal,
          palette: MaestroPalette.neutral,
          reduceMotion: reduceMotion,
          onComplete: onComplete ?? () {},
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    return tester.getRect(find.byKey(const Key('risveglio_sigillo')));
  }

  for (final schermo in const [
    Size(390, 844),
    Size(360, 640),
    Size(430, 932),
  ]) {
    testWidgets(
        'Il Sigillo cade sul centro entro il cinque per cento, a '
        '${schermo.width.toInt()}x${schermo.height.toInt()}', (tester) async {
      final sigillo = await montaSigillo(tester, schermo: schermo);
      final area = tester.getRect(find.byType(SigilloStep));

      final scartoX = (sigillo.center.dx - area.center.dx).abs();
      final scartoY = (sigillo.center.dy - area.center.dy).abs();
      expect(scartoX, lessThanOrEqualTo(area.width * 0.05),
          reason: 'fuori centro in orizzontale di $scartoX px');
      expect(scartoY, lessThanOrEqualTo(area.height * 0.05),
          reason: 'fuori centro in verticale di $scartoY px');
    });
  }

  testWidgets('Nessuna fascia vuota supera il venti per cento dell\'altezza',
      (tester) async {
    await montaSigillo(tester);
    final area = tester.getRect(find.byType(SigilloStep));

    // Le bande occupate da qualcosa, in verticale: si prendono tutti i testi
    // piu' il Sigillo, si ordinano, e si guarda il buco piu' largo.
    final bande = <(double, double)>[
      (
        tester.getRect(find.byKey(const Key('risveglio_sigillo'))).top,
        tester.getRect(find.byKey(const Key('risveglio_sigillo'))).bottom
      ),
    ];
    for (final e in find.byType(Text).evaluate()) {
      final r = tester.getRect(find.byWidget(e.widget));
      if (r.height > 0) bande.add((r.top, r.bottom));
    }
    bande.sort((a, b) => a.$1.compareTo(b.$1));

    var vuotoMax = bande.first.$1 - area.top;
    var fine = bande.first.$2;
    for (final b in bande.skip(1)) {
      final buco = b.$1 - fine;
      if (buco > vuotoMax) vuotoMax = buco;
      if (b.$2 > fine) fine = b.$2;
    }
    final codaFinale = area.bottom - fine;
    if (codaFinale > vuotoMax) vuotoMax = codaFinale;

    expect(vuotoMax, lessThanOrEqualTo(area.height * 0.20),
        reason: 'una fascia vuota alta $vuotoMax px su ${area.height}');
  });

  testWidgets('Il testo e\' quello chiesto, parola per parola', (tester) async {
    await montaSigillo(tester);
    expect(find.text('Posa il dito sul numero al centro'), findsOneWidget);
  });

  testWidgets('Tenendo premuto si sigilla, e prima no', (tester) async {
    var compiuto = false;
    await montaSigillo(tester, onComplete: () => compiuto = true);

    final gesto = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('risveglio_sigillo'))));
    // Meta' attesa: non basta, altrimenti il gesto non sarebbe voluto.
    await tester.pump(SigilloStep.attesa ~/ 2);
    expect(compiuto, isFalse, reason: 'sigillato a meta pressione');

    // Il dito resta giu' oltre l'attesa: l'anello si riempie e parte il
    // trionfo. Il passaggio pero' non avviene subito, altrimenti il trionfo
    // non lo vedrebbe nessuno.
    await tester.pump(SigilloStep.attesa);
    expect(compiuto, isFalse,
        reason: 'passato oltre senza mostrare il trionfo');

    // Il trionfo scorre in piu' fotogrammi, come a schermo.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 160));
    }
    expect(compiuto, isTrue, reason: 'il trionfo non ha mai concluso');
    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('Il trionfo dura abbastanza da essere visto', (tester) async {
    expect(SigilloStep.trionfo.inMilliseconds, greaterThanOrEqualTo(1000),
        reason: 'un trionfo piu\' corto di un secondo e\' un lampo');
  });

  testWidgets('Con Riduci Movimento si sigilla lo stesso', (tester) async {
    var compiuto = false;
    await montaSigillo(tester,
        reduceMotion: true, onComplete: () => compiuto = true);

    final gesto = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('risveglio_sigillo'))));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(SigilloStep.attesa + const Duration(milliseconds: 50));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 160));
    }
    await gesto.up();
    expect(compiuto, isTrue,
        reason: 'con Riduci Movimento il rito non si chiude piu\'');
    await tester.pumpAndSettle();
  });
}
