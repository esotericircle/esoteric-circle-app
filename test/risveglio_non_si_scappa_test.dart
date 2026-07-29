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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il Risveglio e' la porta gemella dell'onboarding, e va chiusa insieme.
///
/// L'onboarding finisce con un pushReplacement verso il Risveglio, che e' a
/// sua volta una rotta spinta sopra lo shell. Il Maestro pero' si assegna alla
/// rivelazione, cioe' all'ultima fase: uscire prima col gesto di sistema vuol
/// dire entrare nel Cerchio senza Maestro, per di piu' senza che l'onboarding
/// torni a proporsi, dato che il lanciatore lo considera gia' gestito.
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

  testWidgets('Dal Risveglio il gesto di sistema non riporta alla home',
      (tester) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 2392);
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
        // La home finta sta SOTTO, come lo shell nell'app vera: se il gesto fa
        // il pop, e' lei a comparire.
        home: Builder(
          builder: (ctx) {

            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).push(
                    RisveglioJourney.route(
                      details: BirthDetails(date: DateTime(1990, 5, 12)),
                    ),
                  ),
                  child: const Text('LA HOME SOTTO'),
                ),
              ),
            );
          },
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('LA HOME SOTTO'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(RisveglioJourney), findsOneWidget);

    // Il gesto Indietro di sistema, ripetuto: chi vuole uscire insiste.
    for (var i = 0; i < 5; i++) {
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
        (_) {},
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.text('LA HOME SOTTO'), findsNothing,
        reason: 'il gesto ha riportato alla home prima della rivelazione: si '
            'entra nel Cerchio senza Maestro assegnato');
    expect(find.byType(RisveglioJourney), findsOneWidget);
    // Qui c'era anche un controllo su needsOnboarding. Misurava lo stato
    // iniziale del controller, che nasce falso finche' non ha letto le
    // preferenze, quindi sarebbe stato verde a prescindere dal difetto: tolto
    // invece che adattato.
  });
}
