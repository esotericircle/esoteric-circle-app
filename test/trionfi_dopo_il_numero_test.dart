import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/risveglio_journey.dart';
import 'package:esoteric_circle/features/onboarding/trionfi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I trionfi vengono subito dopo il numero della vita, e si puo' tornare
/// indietro.
///
/// Il numero della vita chiude l'onboarding, nel passo del Sigillo. Il Risveglio
/// partiva invece dal cielo di nascita, e i due trionfi, l'Animale Guida e la
/// triade di Angeli, arrivavano dopo: fra il numero e i suoi trionfi si
/// infilava un'altra schermata.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

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

  Future<void> apriRisveglio(WidgetTester tester,
      {double altezza = 2392}) async {
    silence();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RisveglioJourney(
            details: BirthDetails(date: DateTime(1990, 5, 12))),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Il Risveglio comincia dal trionfo degli Angeli',
      (tester) async {
    // **RISCRITTA DALL'ORDINE DG VOCE 04.** Apriva l'Animale; adesso apre
    // chi resta, cioe' gli Angeli, perche' la scheda dell'animale e' passata
    // in fondo per decisione del fondatore.
    await apriRisveglio(tester);

    expect(find.byType(TrionfoAngeli), findsOneWidget,
        reason: 'fra il numero della vita e i suoi trionfi si e\' infilata '
            'un\'altra schermata');
    expect(find.byType(TrionfoAnimale), findsNothing,
        reason: 'l Animale apre ancora il Risveglio, e la voce DG.04 lo vuole '
            'per ultimo');
  });

  testWidgets(
      'Il primo trionfo non ha una freccia che non porta da nessuna '
      'parte', (tester) async {
    await apriRisveglio(tester);
    // **ADESSO IL PRIMO SONO GLI ANGELI**: un indietro non esiste, quindi non
    // si mostra una freccia che non fa nulla. Ordine DG voce 04.
    expect(find.byKey(const Key('trionfo_angeli_indietro')), findsNothing,
        reason: 'il primo trionfo mostra una freccia che non porta indietro');
  });

  /// **L'ANIMALE ARRIVA SUBITO DOPO GLI ANGELI**, e non piu' in fondo.
  ///
  /// **Questa prova diceva il contrario**, e diceva il vero sull'ordine che
  /// avevo scelto io. Il fondatore ha rifatto l'onboarding l'11 settembre 2026
  /// e ha corretto: *"la schermata c'e' con l'animale oscurato, ma andrebbe
  /// messa dopo la rivelazione degli angeli. adesso e' dopo la rivelazione del
  /// maestro"*.
  testWidgets('L Animale arriva subito dopo gli Angeli', (tester) async {
    await apriRisveglio(tester);
    await tester.tap(find.byKey(const Key('trionfo_angeli_avanti')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TrionfoAngeli), findsNothing);
    expect(find.byType(TrionfoAnimale), findsOneWidget,
        reason: 'l Animale non arriva subito dopo gli Angeli: e la correzione '
            'che il fondatore ha chiesto per nome');
  });
}
