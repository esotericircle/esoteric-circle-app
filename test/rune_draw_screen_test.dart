import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata dell'Estrazione Rune di Caligo.
void main() {
  // Sensori assenti in headless: senza il mock la parallasse e lo scuotimento
  // sollevano una MissingPluginException.
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
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> getta(WidgetTester tester) async {
    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('La soglia mostra selettore, testo dinamico, domanda e lancio',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('rune_selector')), findsOneWidget);
    expect(find.byKey(const Key('rune_dynamic_text')), findsOneWidget);
    expect(find.byKey(const Key('rune_question_field')), findsOneWidget);
    expect(find.byKey(const Key('rune_suggestions')), findsOneWidget);
    expect(find.byKey(const Key('rune_cast_button')), findsOneWidget);
    expect(find.byKey(const Key('rune_well')), findsOneWidget);
    // La gettata iniziale e' la Runa di Odino: il testo dinamico ne parla.
    expect(find.textContaining('Odino'), findsWidgets);
  });

  testWidgets('Il selettore cambia gettata e testo dinamico', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // All'inizio, Odino cita l'Havamal; non ancora Tacito.
    expect(find.textContaining('Havamal'), findsOneWidget);
    expect(find.textContaining('Tacito'), findsNothing);

    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    // Ora le tre Norne citano Tacito e la Voluspa.
    expect(find.textContaining('Tacito'), findsOneWidget);
    expect(find.textContaining('Havamal'), findsNothing);
  });

  testWidgets('Un suggerimento riempie la domanda', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.text('Nel lavoro, quale passo fare?'));
    await passo(tester);
    final campo = tester.widget<TextField>(
        find.byKey(const Key('rune_question_field')));
    expect(campo.controller!.text, 'Nel lavoro, quale passo fare?');
  });

  testWidgets('Getta le rune porta al responso col presagio', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // Le tre Norne: tre rune posate.
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    await getta(tester);

    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_0')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_1')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_2')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_3')), findsNothing);
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
    final presagio = tester
        .widget<Text>(find.byKey(const Key('rune_presage_text')))
        .data!;
    expect(presagio.trim(), isNotEmpty);
    expect(find.byKey(const Key('rune_share')), findsOneWidget);
    expect(find.byKey(const Key('rune_consulta')), findsOneWidget);
  });

  testWidgets('La Croce delle Cinque posa cinque rune', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('rune_segment_croce')));
    await passo(tester);
    await getta(tester);

    for (var i = 0; i < 5; i++) {
      expect(find.byKey(Key('rune_card_$i')), findsOneWidget, reason: 'card $i');
    }
  });

  testWidgets('La domanda scritta compare sopra la lettura', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.enterText(
        find.byKey(const Key('rune_question_field')), 'Dove sto andando?');
    await passo(tester);
    await getta(tester);
    expect(find.byKey(const Key('rune_question_shown')), findsOneWidget);
    expect(find.text('Dove sto andando?'), findsOneWidget);
  });

  testWidgets('Getta ancora resta nel responso con una nuova gettata',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await getta(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('rune_recast')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_recast')));
    await passo(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
  });
}
