import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UNA PORTA APERTA NON SI RIAPRE. Ordine AU voce 10.
///
/// **Il fatto, misurato dal fondatore**: aprendo dieci volte il menu' utente in
/// alto a sinistra servono dieci tocchi su indietro per tornare al principio.
///
/// **La causa**: ogni apertura IMPILAVA una rotta nuova invece di tornare a
/// quella gia' aperta. La regola per non farlo esisteva gia', `apriUnaVoltaSola`
/// dell'ordine AL, ma il menu' utente e il Calendario non ci passavano: si
/// aprivano con un `push` diretto, perche' nessuno aveva dato loro una
/// destinazione da confrontare.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  int profondita() => NavigazioneDellaBarra.osservatore?.pila.length ?? -1;

  testWidgets('aperto e chiuso dieci volte, la pila torna dov era',
      (tester) async {
    await monta(tester);
    final partenza = profondita();
    expect(partenza, greaterThan(0),
        reason: 'la pila non si legge: l osservatore non e montato, e una '
            'prova che non conta niente e verde per cecita');

    // **DIECI APERTURE DI SEGUITO, SENZA CHIUDERE**, che e' esattamente il
    // gesto del fondatore: si tocca il volto in alto a sinistra piu' volte.
    for (var i = 0; i < 10; i++) {
      NavigazioneDellaBarra.allAccount();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    final dopoDieci = profondita();
    // ignore: avoid_print
    print('ORDINE AU VOCE 10: la pila era $partenza, dopo dieci aperture del '
        'menu utente e $dopoDieci');
    expect(dopoDieci, partenza + 1,
        reason: 'dieci aperture hanno impilato ${dopoDieci - partenza} rotte '
            'invece di una: servirebbero ${dopoDieci - partenza} tocchi su '
            'indietro per tornare al principio');

    // Un tocco solo su indietro, e si e' tornati dov eravamo.
    final navigatore = tester.state<NavigatorState>(find.byType(Navigator));
    navigatore.maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(profondita(), partenza,
        reason: 'un tocco su indietro non basta a tornare al principio');
  });

  testWidgets('lo stesso vale per il Calendario', (tester) async {
    await monta(tester);
    final partenza = profondita();
    for (var i = 0; i < 10; i++) {
      NavigazioneDellaBarra.alCalendario();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    // ignore: avoid_print
    print('ORDINE AU VOCE 10: dieci aperture del Calendario portano la pila '
        'da $partenza a ${profondita()}');
    expect(profondita(), partenza + 1,
        reason: 'il Calendario si impila su se stesso');
  });

  test('il censimento: nessuna porta della barra impila con un push diretto',
      () {
    // **LA REGOLA SI SORVEGLIA ALLA SORGENTE**, se no domani nasce la sesta
    // porta e nessuno si ricorda di farla passare di qui.
    final barra =
        File('lib/features/shell/barra_del_cerchio.dart').readAsStringSync();
    final diretti = RegExp(r'_navigatore\(\)\.push\(').allMatches(barra).length;
    // ignore: avoid_print
    print('ORDINE AU VOCE 10: nella barra restano $diretti spinte dirette '
        'nella pila');
    expect(diretti, 1,
        reason: 'nella barra ci sono $diretti spinte dirette: l unica ammessa '
            'e quella DENTRO apriUnaVoltaSola, che spinge solo dopo aver '
            'guardato se la porta era gia aperta');
  });
}
