import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/risveglio_journey.dart';
import 'package:esoteric_circle/features/onboarding/trionfi_screen.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ordine del racconto: prima i compagni, poi il ritratto d'insieme.
///
/// Messi dopo la carta natale, i due trionfi rivelavano una cosa gia' vista:
/// la carta contiene la tessera del lupo e quella dei tre angeli, quindi chi
/// arrivava al trionfo li aveva gia' incontrati come voci di un elenco. Un
/// trionfo che svela il noto non e' un trionfo.
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

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('I due trionfi arrivano PRIMA della carta natale',
      (tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final c = CityCatalog.search('Roma').first;
    final details = BirthDetails(
      date: DateTime(1985, 3, 3),
      time: const TimeOfDay(hour: 7, minute: 20),
      place: astro.BirthPlace(
        label: c.name,
        latitude: c.latitude,
        longitude: c.longitude,
        timezone: c.timeZoneId,
      ),
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => IdentityController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        home: MaestroScope(child: RisveglioJourney(details: details)),
      ),
    ));
    await passo(tester);

    // Il cielo di nascita apre la coda: si prosegue.
    await tester.tap(find.byKey(const Key('sky_cta')));
    await passo(tester);

    // Subito dopo il cielo deve venire l'ANIMALE, non la carta.
    expect(find.byType(TrionfoAnimale), findsOneWidget,
        reason: 'dopo il cielo non c\'e\' il trionfo dell\'Animale');
    expect(find.byType(NatalChartReveal), findsNothing,
        reason: 'la carta natale arriva prima dei trionfi, quindi il trionfo '
            'rivelerebbe una cosa gia\' vista');

    // Poi gli Angeli, sempre prima della carta.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byKey(const Key('trionfo_animale_avanti')));
    await passo(tester);
    expect(find.byType(TrionfoAngeli), findsOneWidget);
    expect(find.byType(NatalChartReveal), findsNothing);

    // E solo alla fine la carta, che li raccoglie tutti.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byKey(const Key('trionfo_angeli_avanti')));
    await passo(tester);
    expect(find.byType(NatalChartReveal), findsOneWidget,
        reason: 'dopo i due trionfi deve arrivare il ritratto d\'insieme');
  });
}
