import 'dart:convert';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La schermata dell'Animale Guida di Caligo.
void main() {
  // Con disableAnimations, il viaggio col tamburo basta un tocco (ripiego) e le
  // animazioni non girano: il test resta stabile.
  Widget host({
    Zodiac userSign = Zodiac.cancer,
    GuideAnimalMode modo = GuideAnimalMode.viaggio,
  }) =>
      MultiProvider(
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
          home: GuideAnimalScreen(userSign: userSign, modo: modo),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  void seedArchetipo() {
    final esito = ArchetypeEsito(
      quando: DateTime(2026, 7, 22, 10),
      percentuali: ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
      dominante: Archetype.realista,
    );
    SharedPreferences.setMockInitialValues({
      'archetipo.storico': [jsonEncode(esito.toJson())],
    });
  }

  // Compie il viaggio: un tocco al tamburo basta con disableAnimations.
  Future<void> viaggia(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('animal_drum')));
    await passo(tester);
  }

  testWidgets('Senza Test Archetipo, il popup invita ma lascia proseguire',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    // Il popup evocativo c'e', coi due pulsanti.
    expect(find.byKey(const Key('animal_test_popup')), findsOneWidget);
    expect(find.byKey(const Key('animal_popup_test')), findsOneWidget);
    expect(find.byKey(const Key('animal_popup_reveal')), findsOneWidget);
    expect(find.text('Il tuo animale ti sta cercando'), findsOneWidget);

    // Rivela dal cielo: il popup si chiude e resta il viaggio col tamburo.
    await tester.tap(find.byKey(const Key('animal_popup_reveal')));
    await passo(tester);
    expect(find.byKey(const Key('animal_test_popup')), findsNothing);
    expect(find.byKey(const Key('animal_journey')), findsOneWidget);

    // Il viaggio porta al messaggio del momento, non alla lettura di identita'.
    await viaggia(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // Cancro da' il Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // Il messaggio del momento coi suoi comandi ripetibili.
    expect(find.byKey(const Key('animal_daily_message')), findsOneWidget);
    expect(find.byKey(const Key('animal_ask_again')), findsOneWidget);
    expect(find.byKey(const Key('animal_identity_link')), findsOneWidget);
    expect(find.byKey(const Key('animal_share')), findsOneWidget);
    expect(find.byKey(const Key('animal_consulta')), findsOneWidget);
    // Le bolle di identita' NON stanno nel viaggio: sono nella lettura fissa.
    expect(find.byKey(const Key('animal_natura')), findsNothing);
  });

  testWidgets('Il viaggio col tamburo porta al messaggio del momento',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    // Niente popup con un archetipo salvato: si parte dal viaggio.
    expect(find.byKey(const Key('animal_test_popup')), findsNothing);
    expect(find.byKey(const Key('animal_journey')), findsOneWidget);
    expect(find.byKey(const Key('animal_drum')), findsOneWidget);

    await viaggia(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // L'animale non cambia col Test: Cancro resta Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
  });

  testWidgets('Chiedi ancora cambia il segno del momento', (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await viaggia(tester);

    final primo =
        tester.widget<Text>(find.byKey(const Key('animal_message_text'))).data;
    await tester.tap(find.byKey(const Key('animal_ask_again')));
    await passo(tester);
    final secondo =
        tester.widget<Text>(find.byKey(const Key('animal_message_text'))).data;
    expect(secondo, isNot(primo));
  });

  testWidgets('Chi e\' il tuo animale apre la lettura fissa di identita\'',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await viaggia(tester);
    await tester.tap(find.byKey(const Key('animal_identity_link')));
    await passo(tester);
    // Si apre l'identita', con le bolle di lettura.
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
  });

  testWidgets('Il ripiego del viaggio, il tasto salta, porta comunque su',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    expect(find.byKey(const Key('animal_journey')), findsOneWidget);
    await tester.tap(find.byKey(const Key('animal_journey_skip')));
    await passo(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
  });

  testWidgets('In modo identita\' si apre la lettura fissa, senza tamburo',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(modo: GuideAnimalMode.identita));
    await passo(tester);
    // Nessun viaggio ne messaggio del momento: subito la lettura fissa.
    expect(find.byKey(const Key('animal_journey')), findsNothing);
    expect(find.byKey(const Key('animal_result')), findsNothing);
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
    // Col Test salvato, l'intreccio con l'archetipo compare.
    expect(find.byKey(const Key('animal_archetipo')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // L'identita' non porta i comandi del momento.
    expect(find.byKey(const Key('animal_daily_message')), findsNothing);
    expect(find.byKey(const Key('animal_ask_again')), findsNothing);
  });
}
