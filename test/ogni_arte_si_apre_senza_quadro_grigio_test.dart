import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **NESSUNA ARTE SI APRE SUL QUADRO GRIGIO.** Ordine FY voce FY.01, 16
/// ottobre 2026. Il fondatore, sulla build 2312: "il calendario lunare
/// mostra una schermata grigia a tutto schermo" (cattura
/// `docs/collaudo/FY/catture_fondatore/fy_fondatore_09.jpg`). Il quadro
/// grigio a tutto schermo e' l'`ErrorWidget` di una build di rilascio: una
/// schermata che lancia un'eccezione mentre si costruisce.
///
/// **Le prove di prima non lo vedevano** perche' montavano le schermate su
/// uno schermo senza margini: in alto niente barra di stato, in basso niente
/// barra di sistema. Qui si apre l'app vera, coi margini di un telefono vero
/// (75 punti in alto, 48 in basso), a due misure e col testo a 1,0 e a 1,3,
/// e si entra in ogni arte che ha una rotta: la prova cade se un'eccezione
/// arriva fino al quadro d'errore, o se a schermo c'e' un `ErrorWidget`.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
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

  final arti = [
    for (final a in ArtCatalog.all)
      if (artRouteFor(a.id, userBirth: DateTime(1990, 5, 12, 14, 30)) != null)
        a.id,
  ];

  test('il cardinale: le arti con una rotta', () {
    cardinaleMinimo(arti.length, 14,
        cosa: 'arti con una rotta da aprire',
        perche: 'Se il catalogo non desse piu\' rotte, la prova sarebbe '
            'verde senza aver aperto niente.');
  });

  for (final misura in const [Size(360, 800), Size(430, 932)]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets(
          'ogni arte si apre senza quadro grigio, '
          '${misura.width.toInt()} punti, testo a $scala', (tester) async {
        silenzia();
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = misura;
        // IL MARGINE ALTO DEL TELEFONO VERO: sul Realme 767f596c la barra
        // di stato piu' la barra dell'identita' (che aggiunge la sua altezza
        // al margine) fanno 74,67 punti, letto dall'eccezione vera della
        // build 2312 (134,67 = 74,67 + 56 della barra del titolo + 4).
        tester.view.padding = const FakeViewPadding(top: 75, bottom: 48);
        tester.platformDispatcher.textScaleFactorTestValue = scala;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        SharedPreferences.setMockInitialValues({});
        await tester.runAsync(() async {
          await OnboardingController().complete();
        });
        await tester.pumpWidget(EsotericCircleApp(
            conIntro: false, services: AppServices.offline()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

        final cadute = <String>[];
        for (final id in arti) {
          final rotta =
              artRouteFor(id, userBirth: DateTime(1990, 5, 12, 14, 30))!;
          unawaitedPush(nav, rotta);
          for (var i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 250));
            final e = tester.takeException();
            if (e != null) {
              cadute.add('$id: ${e.toString().split('\n').first}');
              break;
            }
          }
          if (find.byType(ErrorWidget).evaluate().isNotEmpty) {
            cadute.add('$id: a schermo c\'e\' il quadro d\'errore');
          }
          nav.popUntil((r) => r.isFirst);
          await tester.pump(const Duration(milliseconds: 400));
          tester.takeException();
        }
        expect(cadute, isEmpty,
            reason: 'QUESTE ARTI SI APRONO SUL QUADRO GRIGIO: $cadute');
      });
    }
  }
}

/// Apre la rotta senza aspettarne la chiusura.
void unawaitedPush(NavigatorState nav, Route<void> rotta) {
  nav.push(rotta);
}
