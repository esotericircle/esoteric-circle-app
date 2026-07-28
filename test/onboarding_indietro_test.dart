import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Si deve poter tornare indietro a correggere.
///
/// Il Risveglio andava in una direzione sola: chi sbagliava la data, l'ora o
/// il luogo non aveva modo di rimediare, ne' con una freccia ne' col gesto di
/// sistema. Un dato di nascita sbagliato resta sbagliato per sempre in tutte
/// le letture che ne discendono, quindi non e' un fastidio, e' un difetto
/// grave.
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
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> apri(WidgetTester tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => IdentityController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: OnboardingScreen()),
      ),
    ));
    await passo(tester);
  }

  /// Avanza di un passo toccando l'azione principale, qualunque sia.
  Future<void> avanti(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')).last);
    await passo(tester);
  }

  testWidgets('Dal secondo passo in poi la freccia indietro c\'e\'',
      (tester) async {
    await apri(tester);
    // Al primo passo non serve: non c'e' un dietro dove tornare.
    expect(find.byKey(const Key('onboarding_indietro')), findsNothing);

    await avanti(tester);
    expect(find.byKey(const Key('onboarding_indietro')), findsOneWidget,
        reason: 'dal secondo passo si deve poter tornare');
  });

  testWidgets('La freccia riporta al passo precedente', (tester) async {
    await apri(tester);
    await avanti(tester);
    await avanti(tester);

    // I puntini dicono a che punto si e': si legge da li' senza dipendere dai
    // testi delle singole schermate.
    final prima = tester.widget<StepDots>(find.byType(StepDots)).current;
    await tester.tap(find.byKey(const Key('onboarding_indietro')));
    await passo(tester);
    final dopo = tester.widget<StepDots>(find.byType(StepDots)).current;

    expect(dopo, prima - 1, reason: 'la freccia non e\' tornata indietro');
  });

  testWidgets('Il gesto di sistema torna indietro invece di uscire',
      (tester) async {
    await apri(tester);
    await avanti(tester);
    await avanti(tester);
    final prima = tester.widget<StepDots>(find.byType(StepDots)).current;

    // Il gesto Indietro di Android, quello vero che arriva dalla piattaforma.
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(
          const MethodCall('popRoute')),
      (_) {},
    );
    await passo(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget,
        reason: 'il gesto ha buttato fuori dal rito invece di tornare');
    final dopo = tester.widget<StepDots>(find.byType(StepDots)).current;
    expect(dopo, prima - 1, reason: 'il gesto non ha riportato al passo prima');
  });
}
