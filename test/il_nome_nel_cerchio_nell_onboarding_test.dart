// ignore_for_file: avoid_print
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL NOME NEL CERCHIO NELL'ONBOARDING, ordine EY voce 01 punto 1.** Nel
/// passo che chiede il nome, sotto il primo campo, il secondo: la domanda
/// sopra, la riga piu' piccola sotto, il campo gia' compilato col nome
/// iniziatico, che non contiene il nome proprio. Un nome del Cerchio non
/// passa, e la riga lo dice.
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

  Future<void> assesta(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('il secondo campo arriva compilato, e un nome del Cerchio non '
      'passa', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await assesta(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('onboarding_continue')));
      await assesta(tester);
    }
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Stella');
    await assesta(tester);
    expect(find.text('Con quale nome vuoi essere trovato nel Cerchio?'),
        findsOneWidget);
    final campo = tester.widget<TextField>(
        find.byKey(const Key('risveglio_nome_nel_cerchio')));
    final proposto = campo.controller!.text;
    print('EY.01 ONBOARDING: Stella riceve il nome "$proposto"');
    expect(proposto, isNotEmpty);
    expect(proposto.toLowerCase(), isNot(contains('stella')));
    expect(
        find.text('Questo è il nome che il Cerchio ti ha dato: tienilo, '
            'oppure scrivine uno tuo. Potrai cambiarlo dal tuo profilo.'),
        findsOneWidget);

    // Un nome del Cerchio: la riga lo dice, e il rito non prosegue.
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_nel_cerchio')), 'M3dora');
    await assesta(tester);
    expect(find.text('Questo nome è del Cerchio: scegline un altro.'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding_continue')),
        warnIfMissed: false);
    await assesta(tester);
    expect(find.byKey(const Key('risveglio_nome_nel_cerchio')), findsOneWidget,
        reason: 'col nome di Medora il rito e\' andato avanti');

    // Un nome suo: passa, e resta proposto finche' il server lo riceve.
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_nel_cerchio')), 'Lunaria');
    await assesta(tester);
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await assesta(tester);
    expect(find.byKey(const Key('risveglio_nome_nel_cerchio')), findsNothing);
  });

  test('il nome proposto resta sul telefono finche\' il server lo riceve',
      () async {
    SharedPreferences.setMockInitialValues({});
    await IlCerchioSociale.proponiIlNome('  Lunaria ');
    final p = await SharedPreferences.getInstance();
    expect(p.getString(IlCerchioSociale.chiaveDelNomeProposto), 'Lunaria');
  });
}
