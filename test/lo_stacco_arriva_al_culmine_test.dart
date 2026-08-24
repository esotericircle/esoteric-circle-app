import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/spirale_di_stelle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LO STACCO ARRIVA AL CULMINE, E NON PRIMA. Ordine AV voce 01, misura M5.
///
/// **Riscritta sulla nuova animazione.** Questa prova sorvegliava i filmati
/// dell'ordine AT e il loro frame 21; i filmati sono usciti di scena per
/// decisione del fondatore, e al loro posto c'e' la spirale disegnata dal
/// codice. **Cio' che sorveglia non e' cambiato**: nei primi 800 millesimi lo
/// schermo e' solo stelle, e a 800 compaiono di colpo il traguardo e la parola
/// di premio.
///
/// **Il tempo si fa scorrere col `pump`**, che nelle prove e' tempo finto e
/// preciso: la misura su dispositivo reale resta dell'Architetto.
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

  Future<void> montaLaFesta(WidgetTester tester, Sentiero sentiero,
      {bool riduciMovimento = false}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: riduciMovimento),
          child: MaestroScope(maestro: sentiero.maestro, child: child!),
        ),
        home: CelebrazioneAScermoPieno(
          traguardi: [Sentieri.grandiDi(sentiero).first],
          sentieri: [sentiero],
        ),
      ),
    ));
    await tester.pump();
  }

  for (final sentiero in Sentiero.values) {
    testWidgets('su ${sentiero.name} lo schermo e solo stelle fino al culmine',
        (tester) async {
      await montaLaFesta(tester, sentiero);
      final nome = nomeInTondo(Sentieri.grandiDi(sentiero).first.nome);

      // **NON SI CONTANO I WIDGET, SI GUARDA SE SONO DIPINTI.** La scheda E'
      // nell'albero anche prima dello stacco, tenuta li' da `maintainSize`
      // perche' quando compare non salti niente: un widget nell'albero non e'
      // un widget a schermo. Qui si legge lo stato vero, `Visibility.visible`.
      Visibility schedaAdesso() => tester.widget<Visibility>(find
          .ancestor(of: find.text(nome), matching: find.byType(Visibility))
          .first);

      await tester.pump(const Duration(milliseconds: 400));
      final prima = schedaAdesso().visible;
      // ignore: avoid_print
      print('ORDINE AV VOCE 01, M5: ${sentiero.name} a 400 ms, scheda dipinta '
          '$prima');
      expect(prima, isFalse,
          reason: 'a 400 millesimi la scheda si dipinge gia: fino al culmine '
              'lo schermo deve essere solo stelle');

      // **E LA SPIRALE C E DAVVERO**, se no "solo stelle" sarebbe uno schermo
      // vuoto e la prova sarebbe verde per assenza.
      expect(find.byKey(const Key('spirale_di_stelle')), findsOneWidget,
          reason: 'la spirale non e a schermo: lo schermo non e solo stelle, e '
              'nudo');

      await tester.pump(const Duration(milliseconds: 500));
      final dopo = schedaAdesso().visible;
      // ignore: avoid_print
      print('ORDINE AV VOCE 01, M5: ${sentiero.name} a 900 ms, scheda dipinta '
          '$dopo');
      expect(dopo, isTrue,
          reason: 'passato il culmine il traguardo non e comparso');
      expect(find.text('CONGRATULAZIONI'), findsOneWidget,
          reason: 'la parola di premio non c e nella scheda');

      // Si lascia finire, se no l albero muore con un ticker ancora vivo.
      await tester.pump(const Duration(milliseconds: 1200));
    });
  }

  testWidgets('lo stacco cade a 800 millesimi piu o meno 40', (tester) async {
    // **M5 AL MILLESIMO.** Si avanza di venti in venti e si guarda l'istante
    // esatto in cui la scheda si accende.
    await montaLaFesta(tester, Sentiero.costellazione);
    final nome = nomeInTondo(Sentieri.grandiDi(Sentiero.costellazione).first.nome);
    int? quando;
    for (var t = 0; t <= 1200; t += 20) {
      final visibile = tester
          .widget<Visibility>(find
              .ancestor(of: find.text(nome), matching: find.byType(Visibility))
              .first)
          .visible;
      if (visibile) {
        quando = t;
        break;
      }
      await tester.pump(const Duration(milliseconds: 20));
    }
    // ignore: avoid_print
    print('ORDINE AV VOCE 01, M5: la scheda si accende a $quando millesimi, '
        'il culmine sta a ${SpiraleDiStelle.istanteDelCulmine.inMilliseconds}');
    expect(quando, isNotNull,
        reason: 'la scheda non si e mai accesa in 1200 millesimi');
    expect(
        (quando! - SpiraleDiStelle.istanteDelCulmine.inMilliseconds).abs(),
        lessThanOrEqualTo(40),
        reason: 'lo stacco cade a $quando millesimi invece che a 800 piu o '
            'meno 40');
    await tester.pump(const Duration(milliseconds: 1400));
  });

  testWidgets('con Riduci Movimento la spirale non c e e il traguardo si vede '
      'subito', (tester) async {
    await montaLaFesta(tester, Sentiero.costellazione, riduciMovimento: true);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('CONGRATULAZIONI'), findsOneWidget,
        reason: 'con Riduci Movimento la scheda resta nascosta: si e tolto il '
            'contenuto insieme al movimento');
  });

  testWidgets('nella scena montata la spirale dipinge davvero le stelle',
      (tester) async {
    // **L'ANTEPRIMA MOSTRAVA UNA SCENA SENZA STELLE**, e una prova che conta
    // widget non l'avrebbe mai detto: il `CustomPaint` c'era. Qui si guarda il
    // contatore del pittore, che si aggiorna solo quando `paint` gira davvero.
    PittoreDellaSpirale.viveAllUltimoFotogramma = 0;
    await montaLaFesta(tester, Sentiero.costellazione);
    await tester.pump(const Duration(milliseconds: 900));
    // ignore: avoid_print
    print('ORDINE AV VOCE 01: nella scena montata, a 900 millesimi le stelle '
        'dipinte sono ${PittoreDellaSpirale.viveAllUltimoFotogramma}');
    expect(PittoreDellaSpirale.viveAllUltimoFotogramma, greaterThan(300),
        reason: 'la spirale non dipinge nella scena vera: a schermo non ci '
            'sono stelle');
    await tester.pump(const Duration(milliseconds: 1400));
  });
}
