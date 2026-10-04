// ignore_for_file: avoid_print
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LA TENDINA SI APRE DALLA BARRA, NELL'APP INTERA. Ordine EY voce 08.**
///
/// Nata dal collaudo sul Realme con la build 2296: il tocco su "Online" non
/// apriva niente. La barra vive nel `builder` di `MaterialApp`, sopra il
/// Navigator, e la tendina partiva da quel contesto, dove nessun Navigator
/// si trova: il dialogo moriva in silenzio. Le prove e le anteprime montavano
/// la tendina da sola e non l'app intera, quindi non potevano vederlo. Questa
/// monta l'app vera e tocca la barra vera.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  testWidgets('il tocco su Online apre la tendina del Cerchio', (tester) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'onboarding.done': true, 'santuario.greeted': true});
    await tester.pumpWidget(EsotericCircleApp(
        conIntro: false,
        services: AppServices.offline(null, PortaFintaDelCerchioSociale())));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const Key('barra_online_tocco')), findsOneWidget);
    await tester.tap(find.byKey(const Key('barra_online_tocco')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    print('EY.08 LA TENDINA DALLA BARRA: '
        '${find.byKey(const Key('la_tendina_del_cerchio')).evaluate().length}');
    expect(find.byKey(const Key('la_tendina_del_cerchio')), findsOneWidget,
        reason: 'il tocco su Online non apre la tendina nell\'app intera');
  });
}
