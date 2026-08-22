import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/transizione_di_stelle.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LO STACCO ARRIVA AL FRAME 21, E NON PRIMA. Ordine AT voci 05 e 07.
///
/// **Cosa si misura, montando la scena vera.** Che nei primi venti fotogrammi
/// lo schermo non porti ne' il nome del traguardo ne' la parola di premio, e
/// che dopo gli 800 millesimi ci siano tutti e due. E' la regia che il
/// fondatore ha chiesto: il lampo della stella copre lo stacco, quindi lo
/// stacco dev'essere secco e cadere li'.
///
/// **Il tempo si fa scorrere col `pump`**, che nelle prove e' tempo finto e
/// preciso: la misura su dispositivo reale, M3, resta dell'Architetto.
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
          data: MediaQuery.of(ctx)
              .copyWith(disableAnimations: riduciMovimento),
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
    testWidgets('su ${sentiero.name} lo schermo e solo stelle fino allo stacco',
        (tester) async {
      await montaLaFesta(tester, sentiero);
      // **IL NOME COME LA CARD LO RENDE.** Ordine AU voce 07: il corpus
      // scrive i traguardi grandi in maiuscolo integrale per marcarli, ma a
      // video il maiuscolo vale solo per la parola di premio, quindi la card
      // mostra "La costellazione nascente". Cercare il nome del dato invece di
      // quello reso trovava zero widget.
      final nome = nomeInTondo(Sentieri.grandiDi(sentiero).first.nome);

      // **NON SI CONTANO I WIDGET, SI GUARDA SE SONO DIPINTI.** La prima
      // stesura di questa prova usava `find.text`, e trovava il nome anche a
      // 400 millesimi: la scheda infatti E' nell'albero, tenuta li' da
      // `maintainSize` perche' quando compare non salti niente. Un widget
      // nell'albero non e' un widget a schermo, ed e' una trappola in cui
      // questo repo era gia' caduto col Passaporto coperto dalla festa. Qui si
      // legge lo stato vero della scena: `Visibility.visible`.
      Visibility schedaAdesso() => tester.widget<Visibility>(find.ancestor(
            of: find.text(nome),
            matching: find.byType(Visibility),
          ).first);

      await tester.pump(const Duration(milliseconds: 400));
      final visibilePrima = schedaAdesso().visible;
      // ignore: avoid_print
      print('ORDINE AT VOCE 05: ${sentiero.name} a 400 ms, scheda dipinta '
          '$visibilePrima');
      expect(visibilePrima, isFalse,
          reason: 'a 400 millesimi la scheda si dipinge gia: i primi venti '
              'fotogrammi devono essere solo stelle');

      // **DOPO LO STACCO**: la scheda c'e', e con lei la parola di premio, che
      // le sta dentro e quindi compare nello stesso fotogramma.
      await tester.pump(const Duration(milliseconds: 500));
      final visibileDopo = schedaAdesso().visible;
      // ignore: avoid_print
      print('ORDINE AT VOCE 05: ${sentiero.name} a 900 ms, scheda dipinta '
          '$visibileDopo');
      expect(visibileDopo, isTrue,
          reason: 'passati gli 800 millesimi il traguardo non e comparso');
      expect(find.text('CONGRATULAZIONI'), findsOneWidget,
          reason: 'la parola di premio non c e nella scheda');

      // Si lascia finire la transizione, se no l albero muore con un ticker
      // ancora vivo.
      await tester.pump(const Duration(milliseconds: 1200));
    });
  }

  testWidgets('con Riduci Movimento il traguardo si vede subito',
      (tester) async {
    // Si toglie il movimento, non il contenuto: senza transizione la scheda
    // non puo restare invisibile ad aspettare un frame che non arrivera mai.
    await montaLaFesta(tester, Sentiero.costellazione, riduciMovimento: true);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('CONGRATULAZIONI'), findsOneWidget,
        reason: 'con Riduci Movimento la scheda resta nascosta: si e tolto il '
            'contenuto insieme al movimento');
  });

  testWidgets('finita la transizione non resta nessuna immagine viva',
      (tester) async {
    // **OGNI ui.Image CREATA RICEVE dispose()**, ordine AT voce 04: il
    // contatore lo rende verificabile invece che dichiarato.
    TransizioneDiStelle.immaginiVive = 0;
    await montaLaFesta(tester, Sentiero.costellazione);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 1300));
    // Si smonta la scena, che e cio che succede quando la festa si chiude.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // ignore: avoid_print
    print('ORDINE AT VOCE 04: immagini vive dopo lo smontaggio '
        '${TransizioneDiStelle.immaginiVive}');
    expect(TransizioneDiStelle.immaginiVive, lessThanOrEqualTo(0),
        reason: 'restano immagini vive dopo lo smontaggio: il lettore perde '
            'memoria a ogni festa');
  });
}
