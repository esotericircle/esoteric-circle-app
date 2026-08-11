import 'dart:convert';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/rituals/animal_constellations.dart';
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
    DateTime? userBirth,
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
          // LO STORICO CONDIVISO, fornito da chi monta la schermata.
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: GuideAnimalScreen(
              userSign: userSign, userBirth: userBirth, modo: modo),
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
    // DALL'ORDINE L il viaggio e' la costellazione: si uniscono le stelle
    // dell'animale nell'ordine dichiarato dalla sua figura.
    final figura = costellazioneDi('Lupo').figura;
    for (var i = 0; i < figura.punti.length; i++) {
      await tester.tap(find.byKey(Key('animal_star_$i')));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await passo(tester);
    await passo(tester);
  }

  testWidgets('Senza Test Archetipo, il popup invita ma lascia proseguire',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 2400);
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

    // Il viaggio porta al Messaggio del Giorno, non alla lettura di identita'.
    await viaggia(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // Cancro da' il Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // Il Messaggio del Giorno, il blocco di trasparenza e i comandi.
    expect(find.byKey(const Key('animal_daily_message')), findsOneWidget);
    expect(find.byKey(const Key('animal_transparency')), findsOneWidget);
    expect(find.byKey(const Key('animal_identity_link')), findsOneWidget);
    expect(find.byKey(const Key('animal_share')), findsOneWidget);
    expect(find.byKey(const Key('animal_consulta')), findsOneWidget);
    // Non c'e' piu' il Chiedi ancora: un solo messaggio al giorno.
    expect(find.byKey(const Key('animal_ask_again')), findsNothing);
    // Le bolle di identita' NON stanno nel viaggio: sono nella lettura fissa.
    expect(find.byKey(const Key('animal_natura')), findsNothing);
  });

  testWidgets('Il viaggio a costellazione porta al Messaggio del Giorno',
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
    expect(find.byKey(const Key('animal_star_0')), findsOneWidget);

    await viaggia(tester);
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    // L'animale non cambia col Test: Cancro resta Lupo.
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
  });

  testWidgets('La trasparenza dichiara il transito e i dati natali',
      (tester) async {
    seedArchetipo();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Con la data di nascita, i dati natali mostrano anche la Luna natale.
    await tester.pumpWidget(host(userBirth: DateTime(1988, 7, 5, 9, 30)));
    await passo(tester);
    await viaggia(tester);

    final transito =
        tester.widget<Text>(find.byKey(const Key('animal_transit'))).data!;
    final natali =
        tester.widget<Text>(find.byKey(const Key('animal_natal_data'))).data!;
    expect(transito, contains('Luna'));
    expect(transito, contains('Sole'));
    expect(natali, contains('Sole in Cancro'));
    expect(natali, contains('Luna in'));
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
    // Nessun viaggio ne Messaggio del Giorno: subito la lettura fissa.
    expect(find.byKey(const Key('animal_journey')), findsNothing);
    expect(find.byKey(const Key('animal_result')), findsNothing);
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
    // Col Test salvato, l'intreccio con l'archetipo compare.
    expect(find.byKey(const Key('animal_archetipo')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('animal_name'))).data,
        'LUPO');
    // L'identita' non porta il Messaggio del Giorno ne la sua trasparenza.
    expect(find.byKey(const Key('animal_daily_message')), findsNothing);
    expect(find.byKey(const Key('animal_transparency')), findsNothing);
  });
}
