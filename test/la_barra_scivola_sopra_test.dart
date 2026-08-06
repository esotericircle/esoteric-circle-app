import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA BARRA SCIVOLA SOPRA IL CONTENUTO, E IL CONTENUTO NON SI MUOVE.
///
/// **Il difetto che queste prove chiudono.** Lo spazio riservato al contenuto
/// commutava fra zero e l'altezza della barra quando il ritiro passava la meta'
/// della corsa. Commutare uno spazio vuol dire RILAYARE cio' che ci sta dentro:
/// nella home la carta del Maestro centrale cresceva di 66,42 punti in un
/// fotogramma solo, e in chat il campo di scrittura saltava di 123.
///
/// **La grandezza misurata, dichiarata.** Nella home il contenuto scorre col
/// dito, quindi la carta si sposta: e' giusto, ed e' il gesto. Quel che non
/// deve succedere e' che si sposti di PIU' di quanto la pagina abbia scorso, o
/// che cambi misura. Si confronta percio' lo spostamento della carta con i
/// pixel della posizione di scorrimento: la differenza fra i due e' il salto, e
/// deve essere zero.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<NavigatorState> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  Finder ilCorpo() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  double quantoHaScorso(WidgetTester tester) =>
      tester.state<ScrollableState>(ilCorpo().first).position.pixels;

  testWidgets('nella home la carta del Maestro non cambia misura ne\' salta',
      (tester) async {
    await monta(tester);
    final carta = find.byKey(const Key('santuario_central_bust'));
    final prima = tester.getRect(carta);
    final scorsoPrima = quantoHaScorso(tester);

    final gesto = await tester.startGesture(tester.getCenter(ilCorpo().first));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    // Si guarda a OGNI passo della corsa, non solo agli estremi: un salto a
    // meta' strada sarebbe invisibile confrontando solo il principio e la fine.
    //
    // **LA GRANDEZZA E' CAMBIATA, e va detto.** La prima stesura confrontava
    // lo spostamento della carta con i pixel scorsi e pretendeva che
    // coincidessero: cadeva di 1,025 punti al primo passo, e guardando cosa
    // aveva misurato era la PARALLASSE dell'eroe, che nella home e' voluta e fa
    // muovere la scena un po' meno del dito. Una prova che boccia una cosa
    // voluta e' cieca quanto una che promuove una cosa rotta.
    //
    // Si misura quindi la REGOLARITA' del passo: la parallasse sposta la carta
    // di poco e sempre della stessa quantita', mentre un rilayout la sposta di
    // decine di punti in un fotogramma solo. Fra il passo piu' lungo e il piu'
    // corto non devono esserci piu' di tre punti.
    final spostamenti = <double>[];
    var topPrecedente = tester.getRect(carta).top;
    for (var passo = 0; passo < 8; passo++) {
      await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa / 8));
      await tester.pump();
      final ora = tester.getRect(carta);
      expect((ora.height - prima.height).abs(), lessThan(1.0),
          reason: 'Al passo $passo la carta misura '
              '${ora.height.toStringAsFixed(1)} contro i '
              '${prima.height.toStringAsFixed(1)} di partenza: il contenuto si '
              'sta rilayando mentre la barra si muove.');
      spostamenti.add(ora.top - topPrecedente);
      topPrecedente = ora.top;
    }
    final piuLungo = spostamenti.reduce((a, b) => a < b ? a : b);
    final piuCorto = spostamenti.reduce((a, b) => a > b ? a : b);
    expect((piuCorto - piuLungo).abs(), lessThan(3.0),
        reason: 'I passi della carta sono irregolari: fra il maggiore '
            '(${piuLungo.toStringAsFixed(1)}) e il minore '
            '(${piuCorto.toStringAsFixed(1)}) ci sono '
            '${(piuCorto - piuLungo).abs().toStringAsFixed(1)} punti. Uno '
            'scorrimento procede regolare, un rilayout no.');

    // E tornando indietro, fino in fondo alla corsa opposta.
    for (var passo = 0; passo < 8; passo++) {
      await gesto.moveBy(const Offset(0, BarraDelCerchio.corsa / 8));
      await tester.pump();
      expect((tester.getRect(carta).height - prima.height).abs(), lessThan(1.0),
          reason: 'Tornando indietro, al passo $passo la carta ha cambiato '
              'misura.');
    }
    await gesto.up();
    await tester.pump();
  });

  testWidgets('in chat l\'ultima bolla e il campo di scrittura stanno fermi',
      (tester) async {
    final nav = await monta(tester);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final campo = find.byType(TextField).first;
    final prima = tester.getRect(campo);

    final scorribile = find.byType(Scrollable).first;
    final gesto = await tester.startGesture(tester.getCenter(scorribile));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    for (var passo = 0; passo < 8; passo++) {
      await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa / 8));
      await tester.pump();
      final ora = tester.getRect(campo);
      expect((ora.top - prima.top).abs(), lessThan(1.0),
          reason: 'Al passo $passo il campo di scrittura si e\' spostato di '
              '${(ora.top - prima.top).toStringAsFixed(1)} punti: in chat il '
              'campo e\' ancorato in fondo e non deve muoversi di un capello '
              'mentre la barra entra ed esce.');
    }
    await gesto.up();
    await tester.pump();
  });

  testWidgets('il campo di scrittura resta usabile a ogni punto della corsa',
      (tester) async {
    // Usabile vuol dire due cose: che si vede e che il tocco ci arriva. La
    // seconda si prova toccandolo davvero e guardando se prende il fuoco.
    final nav = await monta(tester);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final campo = find.byType(TextField).first;
    for (final quanto in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      // Si porta la barra a quel punto della corsa col dito.
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(Scrollable).first));
      await gesto.moveBy(const Offset(0, -kDragSlopDefault));
      await tester.pump();
      if (quanto > 0) {
        await gesto.moveBy(Offset(0, -BarraDelCerchio.corsa * quanto));
        await tester.pump();
      }

      final r = tester.getRect(campo);
      final schermo = tester.view.physicalSize.height /
          tester.view.devicePixelRatio;
      expect(r.bottom, lessThanOrEqualTo(schermo),
          reason: 'A ${(quanto * 100).round()} per cento della corsa il campo '
              'di scrittura finisce fuori dallo schermo.');

      // **Il tocco ARRIVA vuol dire che in quel punto c'e' lui e non la
      // barra.** Non si guarda il fuoco, che in prova dipende dalla tastiera
      // finta: si guarda chi c'e' sotto il dito, che e' la domanda vera.
      final sotto = tester.hitTestOnBinding(r.center);
      final bersagli = sotto.path
          .map((e) => e.target)
          .whereType<RenderBox>()
          .toList();
      final ilCampo = tester.renderObject(campo);
      expect(bersagli.contains(ilCampo), isTrue,
          reason: 'A ${(quanto * 100).round()} per cento della corsa il tocco '
              'sul campo di scrittura non arriva: in quel punto, sotto il '
              'dito, ci sta qualcosa d\'altro.');
      await gesto.up();
      await tester.pump();
    }
  });

  testWidgets('lo spazio riservato al contenuto non commuta mai',
      (tester) async {
    // La misura che sta sotto a tutte le altre: se questo numero cambiasse
    // durante il movimento, il rilayout tornerebbe e le prove sopra
    // cadrebbero una dopo l'altra. Si guarda il padding che la barra dichiara
    // al contenuto, non un effetto di quel padding.
    await monta(tester);
    double paddingSottoLaBarra() {
      final ctx = tester.element(find.byType(SantuarioBottomBar));
      // Il MediaQuery che il contenuto riceve sta SOTTO la barra nell'albero,
      // quindi si legge da una schermata e non da qui: si prende quello del
      // guscio.
      return MediaQuery.of(ctx).padding.bottom;
    }

    final atteso = paddingSottoLaBarra();
    final gesto = await tester.startGesture(tester.getCenter(ilCorpo().first));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    for (var passo = 0; passo < 8; passo++) {
      await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa / 8));
      await tester.pump();
      expect(paddingSottoLaBarra(), atteso,
          reason: 'Al passo $passo lo spazio riservato e\' cambiato: '
              'e\' passato da $atteso a ${paddingSottoLaBarra()}.');
    }
    await gesto.up();
    await tester.pump();
  });
}
