import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata del Rito del Sogno: nebbia, cielo, stelle unite, saluto.
void main() {
  final quando = DateTime(2026, 7, 13, 22, 40);

  void silenceSensors(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: DreamRiteScreen(now: quando),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Dirada la nebbia col ripiego tattile, poi unisce tutte le stelle in ordine.
  Future<void> compiIlRito(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);
    final segno = NightSky.moonSign(quando);
    final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
    for (var i = 0; i < figura.points.length; i++) {
      await tester.tap(find.byKey(Key('dream_star_$i')));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 1000));
    await passo(tester);
  }

  testWidgets('Si apre nella nebbia, col fiato e il ripiego tattile',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.text('Rito del Sogno'), findsOneWidget);
    expect(find.byKey(const Key('dream_fog')), findsOneWidget);
    expect(find.byKey(const Key('dream_invito')), findsOneWidget);
    expect(find.byKey(const Key('dream_breath_bar')), findsOneWidget);
    expect(find.byKey(const Key('dream_fog_skip')), findsOneWidget);
    // Nella nebbia il cielo non e' ancora toccabile.
    expect(find.byKey(const Key('dream_star_0')), findsNothing);
    // Nessun vecchio nome nell'interfaccia.
    expect(find.textContaining('Rito della Buonanotte'), findsNothing);
  });

  testWidgets('Diradata la nebbia emergono le stelle da unire', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);
    expect(find.byKey(const Key('dream_star_0')), findsOneWidget);
    expect(find.text('Alza il telefono verso il cielo.'), findsOneWidget);
    // La costellazione e' quella del segno della Luna di quel momento.
    final segno = NightSky.moonSign(quando);
    expect(find.textContaining(segno.italianName), findsWidgets);
  });

  testWidgets('Le stelle si uniscono in sequenza, fuori ordine non contano',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);

    final segno = NightSky.moonSign(quando);
    final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
    // Toccare l'ultima per prima non unisce nulla.
    await tester.tap(find.byKey(Key('dream_star_${figura.points.length - 1}')));
    await passo(tester);
    expect(find.textContaining('Stelle unite 0 su'), findsOneWidget);
    // In ordine, invece, si accende.
    await tester.tap(find.byKey(const Key('dream_star_0')));
    await passo(tester);
    expect(find.textContaining('Stelle unite 1 su'), findsOneWidget);
  });

  testWidgets('Unita la costellazione scende il saluto della notte',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compiIlRito(tester);

    expect(find.byKey(const Key('dream_message')), findsOneWidget);
    expect(find.byKey(const Key('dream_word')), findsOneWidget);
    expect(find.byKey(const Key('dream_provenienza')), findsOneWidget);
    expect(find.byKey(const Key('dream_share')), findsOneWidget);
    // Il saluto e' quello deterministico dal cielo reale.
    final atteso = DreamRiteCorpus.saluto(quando);
    expect(tester.widget<Text>(find.byKey(const Key('dream_message'))).data,
        atteso);
    // Chiude con la buonanotte, il rito non si chiama piu' cosi'.
    expect(atteso.trim().endsWith('Buonanotte.'), isTrue);
    expect(find.textContaining('Rito della Buonanotte'), findsNothing);
  });

  testWidgets('Il tooltip dichiara il cielo reale e il confine onesto',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('dream_sources')));
    await passo(tester);
    expect(find.byKey(const Key('dream_sources_sheet')), findsOneWidget);
    expect(find.textContaining('cielo notturno reale di questo momento'),
        findsOneWidget);
    expect(find.textContaining('non è allineata'), findsOneWidget);
  });
}
