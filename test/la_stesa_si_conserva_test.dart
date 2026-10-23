// LA STESA SI CONSERVA. Ordine FI voci 26, 27 e 41, 10 ottobre 2026.
//
// LAPIDE, ordine GD voce GD.04 del 23 ottobre 2026. Qui la guardia pretendeva
// che chi rientrava con la stessa domanda si ritrovasse le carte di prima gia'
// in tavola, con la riga di Medora. Il fondatore: "mi dice sempre «su questa
// domanda le carte hanno già parlato oggi» ma non è assolutamente vero anche
// perché devo ancora scegliere le carte". Adesso la guardia, sempre dall'APP
// DALL'AVVIO VERO e dalla rotta di produzione, pretende il contrario: al
// rientro le carte si scelgono di nuovo e la riga non c'e', ne' prima di
// scegliere ne' con carte diverse. Il caso raro delle carte identiche lo
// misura `gd04_le_carte_hanno_gia_parlato_test.dart`.

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/tarot/la_stesa_conservata.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  Future<void> passa(WidgetTester tester, int volte,
      [Duration passo = const Duration(milliseconds: 250)]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(passo);
    }
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await passa(tester, 20);
  }

  Future<void> premi(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 60; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        await tester.tap(pulsante, warnIfMissed: false);
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    fail('il pulsante che apre il responso non si e\' mai acceso');
  }

  String carte(WidgetTester tester) => tester
      .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
      .stesaCorrente
      .cards
      .map((c) => '${c.card.name}${c.reversed ? ' (rovescia)' : ''}')
      .join(', ');

  testWidgets('chi rientra con la stessa domanda sceglie di nuovo le carte',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    // Alta abbastanza da tenere in campo il ventaglio e il pulsante.
    tester.view.physicalSize = const Size(402, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passa(tester, 8, const Duration(milliseconds: 120));

    // La prima stesa, dalla rotta di produzione: nessun seme.
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(StesaTreCarteScreen.route());
    await passa(tester, 30);
    expect(find.byKey(const Key('stesa_conservata')), findsNothing);
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    final prima = carte(tester);
    await premi(tester);
    await passa(tester, 60);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LaStesaConservata.chiave), isNotNull,
        reason: 'la stesa compiuta non si e\' conservata');

    // Si esce e si rientra: stessa stesa, stessa domanda (l'argomento di
    // partenza).
    nav.pop();
    await passa(tester, 20);
    nav.push(StesaTreCarteScreen.route());
    await passa(tester, 30);
    final alRientro = tester
        .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
        .carteScelte;
    final rigaAlRientro =
        find.byKey(const Key('stesa_conservata')).evaluate().isNotEmpty;
    for (final indice in const [41, 42, 43]) {
      await pesca(tester, indice);
    }
    final dopo = carte(tester);
    final rigaDopo =
        find.byKey(const Key('stesa_conservata')).evaluate().isNotEmpty;
    // ignore: avoid_print
    print('STESA AL RIENTRO: prima [$prima], al rientro [$alRientro] '
        'riga $rigaAlRientro, scelte di nuovo [$dopo] riga $rigaDopo');
    expect(alRientro, 0,
        reason: 'al rientro le carte sono gia\' in tavola: '
            'l\'utente deve ancora sceglierle');
    expect(rigaAlRientro, isFalse,
        reason: 'la riga compare prima che le carte siano scelte');
    if (dopo != prima) {
      expect(rigaDopo, isFalse,
          reason: 'la riga compare con carte diverse da quelle di prima');
    }
    expect(tester.takeException(), isNull);
  });
}
