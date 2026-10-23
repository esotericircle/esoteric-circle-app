import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA TENDINA NON CHIAMA LA BARRA. Ordine BE voce 02.
///
/// **Fatto del fondatore, screenshot agli atti**: "quando apro il selettore
/// di giorno, mese o anno compare sopra la barra sottile con menu' utente,
/// eventi e borsellino, che non si devono vedere". Nello screenshot la barra
/// con granchio ed Eos sta sopra l'onboarding, e l'elenco dei giorni le
/// scorre sopra.
///
/// **La causa era una rotta senza nome**: la tendina del selettore e' una
/// `PopupRoute`, la pila la metteva in cima, il suo nome non era conosciuto
/// e per il nulla la barra si vedeva. Adesso le rotte a comparsa non contano
/// come schermate: la cima e' la prima rotta che sia una pagina.
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

  testWidgets(
      'BE.02: aprendo la tendina del giorno nell\'onboarding la barra resta '
      'invisibile', (tester) async {
    silenzia();
    // Onboarding NON fatto: e' il rito d'ingresso, dove la barra non esiste.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    // La barra sottile non c'e' prima della tendina: la premessa del rito.
    expect(find.byKey(const Key('barra_dell_identita')), findsNothing,
        reason: 'la barra sottile sta gia\' sopra il rito d\'ingresso, prima '
            'ancora della tendina');

    // Un Continua dal benvenuto porta al passo della data, come nelle
    // catture del Risveglio.
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    final giorno = find.byKey(const Key('risveglio_giorno'));
    expect(giorno, findsOneWidget,
        reason: 'il selettore del giorno non si trova: la prova non sta '
            'guardando il passo della data');
    await tester.tap(giorno, warnIfMissed: false);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // **LA MISURA DELLA VOCE**: con la tendina aperta, la barra resta
    // invisibile. Prima di questa cura compariva, perche' la tendina era la
    // cima della pila e il suo nome non era conosciuto.
    expect(find.byKey(const Key('barra_dell_identita')), findsNothing,
        reason: 'con la tendina aperta la barra sottile e\' comparsa sopra '
            'l\'onboarding: la rotta a comparsa e\' tornata a contare come '
            'schermata (ordine BE voce 02)');
    // ignore: avoid_print
    print('ORDINE BE VOCE 02: tendina aperta, barra invisibile');
  });
}
