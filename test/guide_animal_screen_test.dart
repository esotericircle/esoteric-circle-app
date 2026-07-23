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
  Widget host({Zodiac userSign = Zodiac.cancer, bool saltaViaggio = false}) =>
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
          home: GuideAnimalScreen(
              userSign: userSign, saltaViaggio: saltaViaggio),
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

    // Il viaggio porta alla rivelazione e alla lettura.
    await viaggia(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // Cancro da' il Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // Senza il Test, la sezione dell'archetipo non compare.
    expect(find.byKey(const Key('animal_archetipo')), findsNothing);
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
    expect(find.byKey(const Key('animal_daily_message')), findsOneWidget);
    expect(find.byKey(const Key('animal_share')), findsOneWidget);
    expect(find.byKey(const Key('animal_consulta')), findsOneWidget);
  });

  testWidgets('Il viaggio col tamburo porta alla rivelazione', (tester) async {
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
    // La sezione che intreccia l'archetipo compare.
    expect(find.byKey(const Key('animal_archetipo')), findsOneWidget);
    // L'animale non cambia col Test: Cancro resta Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
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

  testWidgets('Con saltaViaggio si apre diretta la lettura, senza tamburo',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(saltaViaggio: true));
    await passo(tester);
    // Nessun viaggio: subito la lettura.
    expect(find.byKey(const Key('animal_journey')), findsNothing);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
  });
}
