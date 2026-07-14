import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il primo avvio mostra l'onboarding "Il Risveglio", poi il Santuario come
/// home; le aperture successive vanno dirette al Santuario.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
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

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('Primo avvio: mostra Il Risveglio, poi entra nel Santuario',
      (tester) async {
    silenceSensors();
    // Nessun flag salvato: e' la primissima apertura.
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await settle(tester);

    // L'onboarding e' in cima, sopra la home.
    expect(find.byKey(const Key('onboarding_risveglio')), findsOneWidget);
    expect(find.text('Il Risveglio'), findsOneWidget);

    // Un tocco entra nel Santuario, che resta la home.
    await tester.tap(find.byKey(const Key('onboarding_enter')));
    await settle(tester);

    expect(find.byKey(const Key('onboarding_risveglio')), findsNothing);
    expect(find.byType(SantuarioScreen), findsOneWidget);
  });

  testWidgets('Aperture successive vanno dirette al Santuario', (tester) async {
    silenceSensors();
    // Il flag c'e' gia': l'onboarding non si ripete.
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await settle(tester);

    expect(find.byKey(const Key('onboarding_risveglio')), findsNothing);
    expect(find.byType(SantuarioScreen), findsOneWidget);
  });
}
