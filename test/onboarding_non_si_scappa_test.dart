import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dall'onboarding non si scappa, e nessuna via porta alla home a meta'.
///
/// Il gesto di sistema, cioe' lo scorrimento dal bordo sinistro, saltava
/// l'intera procedura e apriva la home del Cerchio: le scelte non erano state
/// salvate, quindi si entrava nell'app senza carta natale. La causa e' che
/// l'onboarding e' una rotta spinta SOPRA lo shell, quindi uscirne significa
/// rivelare la home che sta gia' sotto.
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
  }

  Future<void> apri(WidgetTester tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passo(tester);
    await passo(tester);
  }

  /// Il gesto Indietro di sistema, quello vero che arriva dalla piattaforma.
  Future<void> gestoDiSistema(WidgetTester tester) async {
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await passo(tester);
  }

  Future<void> avanti(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')).last);
    await passo(tester);
  }

  testWidgets('Al terzo passo il gesto riporta al secondo, coi dati intatti',
      (tester) async {
    await apri(tester);
    await avanti(tester); // -> data
    await avanti(tester); // -> ora
    final prima = tester.widget<StepDots>(find.byType(StepDots)).current;

    await gestoDiSistema(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget,
        reason: 'il gesto ha buttato fuori dal rito');
    final dopo = tester.widget<StepDots>(find.byType(StepDots)).current;
    expect(dopo, prima - 1, reason: 'il gesto non ha riportato al passo prima');
  });

  testWidgets('Dal primo passo il gesto NON apre la home', (tester) async {
    await apri(tester);
    // Il primo passo e' quello dell'accoglienza: da li' un dietro non esiste,
    // ma uscire vorrebbe dire entrare nell'app senza carta natale.
    await gestoDiSistema(tester);

    expect(find.byType(AppShell), findsNothing,
        reason: 'dal primo passo il gesto ha aperto la home con l\'onboarding '
            'incompiuto: la persona entra senza carta natale');
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('Nemmeno insistendo col gesto si arriva alla home',
      (tester) async {
    await apri(tester);
    await avanti(tester);
    await avanti(tester);
    // Sette volte: chi vuole uscire insiste.
    for (var i = 0; i < 7; i++) {
      await gestoDiSistema(tester);
    }
    expect(find.byType(AppShell), findsNothing,
        reason: 'insistendo col gesto si e\' arrivati alla home');
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
