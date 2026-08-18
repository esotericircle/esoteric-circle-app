import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA HOME NON RALLENTA AL RITORNO. Ordine AM voce 01.
///
/// **L'ipotesi dell'ordine e' CADUTA, e si dichiara.** Doveva esserci
/// qualcosa che si somma a ogni ciclo "apri e torna": i conteggi dicono di
/// no. Misurati su tre giri di oroscopo, stesa e rune, dal montaggio a
/// freddo: cosmi montati 1, ticker attivi 5, ricostruzioni del cosmo per
/// dieci inclinazioni 10, tutti IDENTICI a ogni giro. Nessuna iscrizione
/// doppia, nessun controller ri-armato, nessun ticker rimasto vivo.
///
/// **La causa vera, misurata dove il difetto vive.** Il costo non era una
/// somma, era un MOLTIPLICATORE: il cosmo tiene in cache quattro teli
/// rasterizzati a schermo pieno, e la chiave di quella cache porta i colori
/// della palette. Durante il cambio di Maestro `MaestroScope` sfuma la
/// palette a ogni fotogramma, quindi ogni fotogramma era una chiave nuova e
/// i quattro teli si rifacevano da capo: 36 rasterizzazioni su 40
/// fotogrammi per UN cambio, contro UNA da freddo. In home il Maestro
/// cambia a ogni giro del carosello e a ogni ritorno da un'arte del Maestro:
/// e' la lentezza che Mauro ha visto sulla 2180.
///
/// La cura: chi rasterizza poggia sulla palette di DESTINAZIONE, ferma per
/// tutta la sfumatura; chi dipinge al volo, cioe' il fondo, l'alone e il
/// velo, continua a usare la palette animata, e la transizione si vede
/// esattamente come prima.
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

  Future<void> apri(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('il cambio di Maestro non rifa\' il cielo a ogni fotogramma',
      (tester) async {
    await apri(tester);
    final maestri =
        tester.element(find.byType(Navigator).first).read<MaestroController>();

    CosmosBackground.quanteRigenerazioni = 0;
    maestri.selectMaestro(Maestro.caligo);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final durante = CosmosBackground.quanteRigenerazioni;
    // ignore: avoid_print
    print('ORDINE AM VOCE 01: rasterizzazioni del cielo per un cambio di '
        'Maestro: $durante su 40 fotogrammi');
    expect(durante, lessThanOrEqualTo(2),
        reason: 'i quattro teli a schermo pieno si rifanno $durante volte per '
            'un solo cambio di Maestro: e\' la lentezza della 2180, e vuol '
            'dire che chi rasterizza sta seguendo i colori intermedi della '
            'sfumatura invece della destinazione');
  });

  testWidgets('tre giri di oroscopo, stesa e rune lasciano i conti come li '
      'hanno trovati', (tester) async {
    await apri(tester);
    final contesto = tester.element(find.byType(Navigator).first);
    final parallasse = contesto.read<ParallaxController>();

    Future<({int cosmi, int ticker, int ricostruzioni})> conti() async {
      CosmosBackground.quanteRicostruzioni = 0;
      for (var i = 0; i < 10; i++) {
        parallasse.inclinaPerLaProva((i % 5) / 5, (i % 3) / 3);
        await tester.pump(const Duration(milliseconds: 16));
      }
      return (
        cosmi: find.byType(CosmosBackground).evaluate().length,
        ticker: SchedulerBinding.instance.transientCallbackCount,
        ricostruzioni: CosmosBackground.quanteRicostruzioni,
      );
    }

    final freddo = await conti();
    // ignore: avoid_print
    print('ORDINE AM VOCE 01: da freddo cosmi ${freddo.cosmi}, ticker '
        '${freddo.ticker}, ricostruzioni per dieci inclinazioni '
        '${freddo.ricostruzioni}');
    expect(freddo.ricostruzioni, greaterThan(0),
        reason: 'la prova non sta misurando niente: il cosmo non si '
            'ricostruisce nemmeno inclinando');

    for (var giro = 1; giro <= 3; giro++) {
      for (final rotta in <Route<void> Function()>[
        () => OroscopoScreen.route(userSign: Zodiac.leo),
        () => StesaTreCarteScreen.route(seed: 7),
        () => RuneDrawScreen.route(userSign: Zodiac.leo),
      ]) {
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        nav.push(rotta());
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
        nav.pop();
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
      }
      final dopo = await conti();
      // ignore: avoid_print
      print('ORDINE AM VOCE 01: dopo il giro $giro cosmi ${dopo.cosmi}, '
          'ticker ${dopo.ticker}, ricostruzioni ${dopo.ricostruzioni}');
      expect(dopo.cosmi, freddo.cosmi,
          reason: 'dopo $giro giri restano ${dopo.cosmi} cosmi montati '
              'invece di ${freddo.cosmi}: le schermate chiuse non se ne sono '
              'andate');
      expect(dopo.ticker, freddo.ticker,
          reason: 'dopo $giro giri ci sono ${dopo.ticker} ticker attivi '
              'invece di ${freddo.ticker}: un\'animazione e\' rimasta viva '
              'dietro le quinte');
      expect(dopo.ricostruzioni, freddo.ricostruzioni,
          reason: 'lo stesso movimento del dispositivo produce '
              '${dopo.ricostruzioni} ricostruzioni del cosmo invece di '
              '${freddo.ricostruzioni}: qualcuno si e\' iscritto due volte');
    }
  });
}
