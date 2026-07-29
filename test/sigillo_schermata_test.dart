import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata del Sigillo, dal campo alla rivelazione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> apri(WidgetTester tester, {double altezza = 844}) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(390, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: SigilloIntenzioneScreen()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Legge l'avanzamento del tracciamento dal painter a schermo.
  RuotaSigilloPainter painter(WidgetTester tester) {
    final cp = tester.widget<CustomPaint>(find.byKey(const Key('sigillo_ruota')));
    return cp.painter! as RuotaSigilloPainter;
  }

  testWidgets('La soglia dichiara le fonti prima di chiedere qualcosa',
      (tester) async {
    await apri(tester);
    expect(find.byKey(const Key('sigillo_soglia')), findsOneWidget);
    expect(find.byKey(const Key('sigillo_fonti')), findsOneWidget);
    expect(find.textContaining('Austin Osman Spare'), findsOneWidget);
    expect(find.textContaining('Golden Dawn'), findsOneWidget);
  });

  testWidgets('Senza abbastanza lettere non si traccia', (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('sigillo_campo')), 'aaa');
    await tester.pump();
    final bottone = tester.widget<FilledButton>(
        find.byKey(const Key('sigillo_traccia')));
    expect(bottone.onPressed, isNull,
        reason: 'con una lettera sola il sigillo si potrebbe tracciare');
    expect(find.textContaining('almeno due lettere'), findsOneWidget);
  });

  testWidgets('Il cammino si traccia un poco per volta, non tutto insieme',
      (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('sigillo_campo')), 'Chiedo chiarezza');
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();

    // Subito dopo l'avvio il cammino non e' ancora finito: se lo fosse, non
    // ci sarebbe nessun tracciamento da guardare.
    await tester.pump(const Duration(milliseconds: 200));
    final aMeta = painter(tester).avanzamento;
    expect(aMeta, greaterThan(0));
    expect(aMeta, lessThan(1),
        reason: 'il cammino e\' comparso tutto insieme');
    expect(painter(tester).mostraRuota, isTrue,
        reason: 'la ruota deve vedersi mentre si traccia, altrimenti non si '
            'capisce da dove nasce il segno');

    // A fine animazione si rivela.
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));
    expect(painter(tester).avanzamento, 1.0);
    expect(find.byKey(const Key('sigillo_via')), findsOneWidget);
    expect(find.byKey(const Key('sigillo_perche')), findsOneWidget);
  });

  testWidgets('La via riconosciuta viene dichiarata col suo perche\'',
      (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('sigillo_campo')), 'Metto radici qui');
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(ViaMagica.verde.nome), findsOneWidget);
    expect(find.textContaining('radici'), findsWidgets);
  });

  testWidgets('Una richiesta sulla volonta\' altrui viene riformulata a video',
      (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('sigillo_campo')),
        'Fai che lui si innamori di me');
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();
    await tester.pump(SigilloIntenzioneScreen.tracciamento);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('sigillo_riformulata')), findsOneWidget,
        reason: 'la riformulazione non viene spiegata a chi ha scritto');
    // Il testo mostrato e' quello riformulato, non l'originale.
    expect(find.textContaining('si innamori'), findsNothing);
  });

  testWidgets('Con Riduci Movimento si arriva subito al sigillo finito',
      (tester) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const MaestroScope(child: SigilloIntenzioneScreen()),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_inizia')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('sigillo_campo')), 'Chiedo pace');
    await tester.pump();
    await tester.tap(find.byKey(const Key('sigillo_traccia')));
    await tester.pump();

    expect(painter(tester).avanzamento, 1.0);
    expect(find.byKey(const Key('sigillo_via')), findsOneWidget);
  });

  group('Regola 21: il sigillo non e\' una bindrune', () {
    test('Il cammino non ha un asse verticale condiviso', () {
      // La bindrune ha un'asta centrale verticale su cui tutto converge: i
      // suoi punti stanno quasi tutti sulla stessa x. Il sigillo invece gira
      // su una ruota, quindi le x sono sparse.
      final c = IntentionSigil.cammino('Chiedo chiarezza sulla mia strada');
      expect(c.length, greaterThan(3));
      final xs = c.map((p) => p.dx).toList();
      final minX = xs.reduce((a, b) => a < b ? a : b);
      final maxX = xs.reduce((a, b) => a > b ? a : b);
      expect(maxX - minX, greaterThan(0.3),
          reason: 'i punti stanno quasi sulla stessa verticale, come una '
              'bindrune: apertura ${(maxX - minX).toStringAsFixed(2)}');
    });

    test('I punti stanno su un cerchio, non su un segmento', () {
      final c = IntentionSigil.cammino('Apro il mio cuore al coraggio');
      for (final p in c) {
        final d = (p - const Offset(0.5, 0.5)).distance;
        expect(d, closeTo(0.38, 0.001),
            reason: 'un punto del cammino non sta sulla ruota');
      }
    });
  });
}
