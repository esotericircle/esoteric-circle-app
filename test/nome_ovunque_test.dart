import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/identity/nome_proprio.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il nome non compare MAI come lo ha battuto la tastiera.
///
/// La voce risultava chiusa con sette test, e sul telefono la home diceva
/// ancora "mauro, la Luna arde al culmine". La ragione: il nome entra da DUE
/// porte, `IdentityController.setName` e `UserProfile` dentro
/// `ProfileController.setProfile`. Avevo normalizzato la prima, e la home
/// legge la seconda. Sette test verdi su una porta sola.
///
/// Per questo il test qui sotto accende l'app vera e guarda cosa c'e' scritto
/// a schermo, invece di chiamare una funzione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  group('La regola sta nel dato, non in chi lo scrive', () {
    test('Il profilo normalizza il nome appena lo riceve', () {
      expect(UserProfile(displayName: 'mauro').displayName, 'Mauro');
      expect(UserProfile(displayName: 'MAURO').displayName, 'Mauro');
      expect(UserProfile(displayName: '  anna  ').displayName, 'Anna');
      expect(UserProfile(displayName: 'maria grazia').displayName,
          'Maria Grazia');
      expect(UserProfile(displayName: "d'angelo").displayName, "D'Angelo");
      expect(UserProfile(displayName: 'McDonald').displayName, 'McDonald');
      expect(UserProfile(displayName: '   ').displayName, isNull);
    });

    test('Anche l\'altra porta passa dalla stessa funzione', () {
      final c = IdentityController();
      c.setName('mauro');
      expect(c.name, 'Mauro');
      expect(c.name, normalizzaNomeProprio('mauro'));
    });
  });

  testWidgets('Nella home il nome non e\' mai come lo si e\' digitato',
      (tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Il profilo e' stato scritto in un avvio precedente, col nome battuto
    // in minuscolo: e' lo scenario di Mauro.
    await tester.runAsync(() async {
      await OnboardingController().complete();
      ProfileController().setProfile(UserProfile(displayName: 'mauro'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Si guarda OGNI stringa a schermo: nessuna puo' contenere il nome
    // minuscolo attaccato a una virgola, che e' proprio la forma della riga
    // sotto la Luna.
    final sbagliate = <String>[];
    for (final e in find.byType(Text).evaluate()) {
      final t = (e.widget as Text).data;
      if (t == null) continue;
      if (t.contains('mauro')) sbagliate.add(t);
    }
    expect(sbagliate, isEmpty,
        reason: 'il nome compare minuscolo a schermo:\n'
            '${sbagliate.join('\n')}');
  });
}
