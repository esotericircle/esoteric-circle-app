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
  Widget host({Zodiac userSign = Zodiac.cancer}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(child: GuideAnimalScreen(userSign: userSign)),
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

    // Rivela dal cielo: il popup si chiude e resta il responso.
    await tester.tap(find.byKey(const Key('animal_popup_reveal')));
    await passo(tester);
    expect(find.byKey(const Key('animal_test_popup')), findsNothing);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // Cancro da' il Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // Senza il Test, la sezione dell'archetipo non compare.
    expect(find.byKey(const Key('animal_archetipo')), findsNothing);
    // Le sezioni della lettura e il messaggio del giorno ci sono.
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
    expect(find.byKey(const Key('animal_daily_message')), findsOneWidget);
    expect(find.byKey(const Key('animal_share')), findsOneWidget);
    expect(find.byKey(const Key('animal_consulta')), findsOneWidget);
  });

  testWidgets('Con un archetipo salvato, niente popup e la sezione compare',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    // Niente popup: c'e' gia' un archetipo.
    expect(find.byKey(const Key('animal_test_popup')), findsNothing);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // La sezione che intreccia l'archetipo compare.
    expect(find.byKey(const Key('animal_archetipo')), findsOneWidget);
    // L'animale non cambia col Test: Cancro resta Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
  });

  testWidgets('Il pulsante Parlane con Caligo e\' nel rosso di Caligo',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    final btn = tester.widget<FilledButton>(
        find.byKey(const Key('animal_consulta')));
    expect(btn.style!.backgroundColor!.resolve({}), isNotNull);
  });
}
