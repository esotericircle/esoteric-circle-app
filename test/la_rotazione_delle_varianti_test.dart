// LA ROTAZIONE DELLE VARIANTI. Ordine FI voci 18 e 42, 11 ottobre 2026.
//
// La stessa carta nella stessa posizione mostra tre testi diversi alla prima,
// alla seconda e alla terza uscita, e alla quarta ricomincia dalla prima. La
// variante la sceglie quante volte la carta e' gia' uscita a questa persona
// in quella posizione, non il caso. Finche' il corpus vero porta una sola
// variante, la prova usa una fonte di tre varianti scritte qui; la catena
// (conta, conserva, lettura) e' quella dell'app. L'ultima prova monta l'app
// dall'avvio vero e pretende che la schermata conti le uscite una volta sola.

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/tarot/la_stesa_conservata.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/le_uscite_delle_carte.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final torre = TarotDeck.cards.firstWhere((c) => c.name == 'La Torre');
  DrawnCard nel(SpreadPosition p, {bool capovolta = false}) =>
      DrawnCard(card: torre, position: p, reversed: capovolta);
  const varianti = ['Prima variante.', 'Seconda variante.', 'Terza variante.'];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LeCarteNellaPosizione.fonteDiProva = {
      'presente|La Torre|dritta': varianti,
      'presente|La Torre|capovolta': [for (final v in varianti) 'Giu. $v'],
    };
  });
  tearDown(() => LeCarteNellaPosizione.fonteDiProva = null);

  // **LAPIDE: i testi attesi erano il solo scheletro.** Dall'ordine FM i
  // registri sono consegnati, e la lettura di casa monta lo scheletro e poi il
  // registro del gruppo dell'argomento (voce FI.20): il testo atteso e' la
  // variante col registro dietro, che non ruota.
  String conRegistro(DrawnCard d, String scheletro) {
    final r =
        LeCarteNellaPosizione.registroDi(d, TarotTopic.momentoCheVivo.group);
    return r == null ? scheletro : '$scheletro $r';
  }

  Future<String> esce(DrawnCard d) async {
    final uscite = await LeUsciteDelleCarte.conta([d]);
    return PosizioneLetta.of(
            d, TarotTopic.momentoCheVivo, TarotSpread.draw(seed: 1),
            uscita: uscite.single)
        .testo;
  }

  test('FI.42: tre uscite, tre testi; alla quarta si ricomincia', () async {
    final testi = [
      for (var i = 0; i < 4; i++) await esce(nel(SpreadPosition.presente)),
    ];
    final d = nel(SpreadPosition.presente);
    expect(testi, [
      for (final i in [0, 1, 2, 0]) conRegistro(d, varianti[i]),
    ]);
  });

  test('FI.18: il verso conta per conto suo', () async {
    await esce(nel(SpreadPosition.presente));
    await esce(nel(SpreadPosition.presente));
    final giu = nel(SpreadPosition.presente, capovolta: true);
    expect(await esce(giu), conRegistro(giu, 'Giu. ${varianti[0]}'),
        reason: 'la prima uscita capovolta comincia dalla prima variante');
    expect(await esce(nel(SpreadPosition.presente)),
        conRegistro(nel(SpreadPosition.presente), varianti[2]));
  });

  // **LA PRIMA ONDATA VERA, ordine FJ voce 5.** Il lato ha le tre varianti
  // dell'Architetto: la catena dell'app (conta, lettura di casa) sui testi
  // veri, senza la fonte di prova. Il lato sta solo nella croce di Dora, che
  // resta chiusa: a video non si vede ancora, qui si vede la catena.
  test('FJ.5: il lato ruota sulle sue tre varianti vere', () async {
    LeCarteNellaPosizione.fonteDiProva = null;
    for (final capovolta in const [false, true]) {
      final d = nel(SpreadPosition.lato, capovolta: capovolta);
      final vere = LeCarteNellaPosizione.variantiDi(d);
      expect(vere, hasLength(3), reason: 'il lato porta tre varianti');
      final testi = [for (var i = 0; i < 4; i++) await esce(d)];
      // ignore: avoid_print
      print('ROTAZIONE DEL LATO, La Torre '
          '${capovolta ? 'capovolta' : 'dritta'}:\n'
          '${[
        for (var i = 0; i < 4; i++) '  uscita ${i + 1}: ${testi[i]}'
      ].join('\n')}');
      expect(testi, [
        for (final i in [0, 1, 2, 0]) conRegistro(d, vere[i])
      ]);
      expect(testi.take(3).toSet(), hasLength(3));
    }
  });

  test('FI.18: la stesa conservata ritrova le sue uscite', () async {
    final carte = [nel(SpreadPosition.presente)];
    await LeUsciteDelleCarte.conta(carte);
    final uscite = await LeUsciteDelleCarte.conta(carte);
    await LaStesaConservata.conserva('firma', carte, uscite: uscite);
    expect(await LaStesaConservata.usciteDi('firma'), [1]);
  });

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

  testWidgets('FI.18: la schermata conta le uscite una volta sola',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(402, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passa(tester, 8, const Duration(milliseconds: 120));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(StesaTreCarteScreen.route());
    await passa(tester, 30);
    for (final indice in const [38, 39, 40]) {
      final r = tester.getRect(find.byKey(Key('stesa_fan_$indice')));
      await tester.tapAt(Offset(r.left + 6, r.center.dy));
      await tester.pump();
      await passa(tester, 20);
    }
    Future<void> apriIlResponso() async {
      final pulsante = find.byKey(const Key('stesa_inizia'));
      for (var i = 0; i < 60; i++) {
        if (pulsante.evaluate().isNotEmpty &&
            tester.widget<FilledButton>(pulsante).onPressed != null) {
          await tester.tap(pulsante, warnIfMissed: false);
          await passa(tester, 60);
          return;
        }
        await tester.pump(const Duration(milliseconds: 200));
      }
      fail('il pulsante che apre il responso non si e\' mai acceso');
    }

    await apriIlResponso();
    StesaTreCarteScreenState stato() =>
        tester.state(find.byType(StesaTreCarteScreen));
    expect(stato().usciteCorrenti, [0, 0, 0],
        reason: 'la prima uscita di ogni carta sceglie la prima variante');
    final prefs = await SharedPreferences.getInstance();
    String? conto() => prefs.getString(LeUsciteDelleCarte.chiave);
    expect(conto(), isNotNull, reason: 'la schermata non ha contato');
    final dopoLaPrima = conto();
    expect(RegExp(r':1[,}]').allMatches(dopoLaPrima!).length, 3,
        reason: 'tre carte, ognuna contata una volta: $dopoLaPrima');

    // Si esce e si rientra: la stesa conservata non si conta di nuovo e
    // ritrova le stesse uscite.
    nav.pop();
    await passa(tester, 20);
    nav.push(StesaTreCarteScreen.route());
    await passa(tester, 30);
    await apriIlResponso();
    expect(conto(), dopoLaPrima,
        reason: 'rileggere la stesa conservata l\'ha contata di nuovo');
    expect(stato().usciteCorrenti, [0, 0, 0]);
    expect(tester.takeException(), isNull);
  });
}
