// LA STESA SI CONSERVA. Ordine FI voci 26, 27 e 41, 10 ottobre 2026.
//
// Il seme della stesa nasceva dal caso a ogni apertura: chi usciva e
// rientrava con la stessa domanda vedeva carte diverse e poteva rilanciare
// finche' non usciva il responso che gli piaceva. La guardia monta l'APP
// DALL'AVVIO VERO, apre la stesa dalla rotta di produzione (senza seme), fa
// una stesa compiuta, esce, rientra con la stessa domanda e pretende le
// stesse carte, con la riga di Medora che lo dice. Il difetto e' di
// collegamento: montata da sola, la schermata passerebbe per la ragione
// sbagliata.

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

  testWidgets('chi rientra con la stessa domanda ritrova le sue carte',
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
    final dopo = carte(tester);
    // ignore: avoid_print
    print('STESA CONSERVATA: prima [$prima], dopo il rientro [$dopo]');
    expect(dopo, prima,
        reason: 'rientrando con la stessa domanda le carte '
            'sono cambiate');
    expect(find.byKey(const Key('stesa_conservata')), findsOneWidget,
        reason: 'la schermata non dice che le carte sono quelle di prima');
    expect(tester.takeException(), isNull);
  });
}
