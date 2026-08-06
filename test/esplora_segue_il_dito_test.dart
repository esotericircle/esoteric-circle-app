import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/esplora.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL MOVIMENTO E' CONTINUO, NON A SCATTO.
///
/// La striscia non ha due stati: si ritrae in proporzione a quanto il dito ha
/// scorso e risale in proporzione a quanto risale il dito, alla sua stessa
/// velocita'.
///
/// **La grandezza misurata e' la CORSA, non l'altezza totale.** L'ordine
/// diceva "meta' dell'altezza della striscia": la parte che si muove pero' e'
/// solo il blocco delle vie, perche' la linguetta resta sempre visibile e non
/// si ritrae mai. Misurare sull'altezza intera avrebbe preteso uno spostamento
/// piu' lungo della corsa, cioe' una prova che nessun codice corretto puo'
/// passare. La corsa e' `EsploraStriscia.corsa`, e si dichiara qui.
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

  Future<void> inChat(WidgetTester tester,
      {bool riduciMovimento = false}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      if (riduciMovimento) 'settings.reduceAnimations': true,
    });
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// Il bordo alto del blocco che si muove, in coordinate di schermo: scende
  /// mentre la striscia si ritrae.
  double doveStannoLeVie(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(const Key('esplora_vie'))).dy;

  Finder ilCorpo() => find.byWidgetPredicate((w) =>
      w is Scrollable && w.axisDirection != AxisDirection.right &&
      w.axisDirection != AxisDirection.left);

  testWidgets('meta\' della corsa scorsa, meta\' della corsa scesa',
      (tester) async {
    await inChat(tester);
    // Si parte con le vie fuori: alla prima apertura no, quindi si aprono col
    // tocco sulla linguetta, che e' il gesto vero.
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final gesto = await tester.startGesture(
        tester.getCenter(ilCorpo().first));
    // Il primo tratto serve a superare la soglia del trascinamento, che il
    // riconoscitore si mangia: senza, meta' del movimento misurato non sarebbe
    // mai arrivata alla lista.
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    final partenza = doveStannoLeVie(tester);

    const mezzaCorsa = EsploraStriscia.corsa / 2;
    await gesto.moveBy(const Offset(0, -mezzaCorsa));
    await tester.pump();
    final arrivo = doveStannoLeVie(tester);

    expect(arrivo - partenza, closeTo(mezzaCorsa, 1.0),
        reason: 'Il dito ha scorso ${mezzaCorsa.toStringAsFixed(1)} punti e la '
            'striscia si e\' spostata di ${(arrivo - partenza).toStringAsFixed(1)}. '
            'Deve seguire il dito, non commutare fra due stati.');

    // E risale della stessa quantita' tornando indietro.
    await gesto.moveBy(const Offset(0, mezzaCorsa));
    await tester.pump();
    expect(doveStannoLeVie(tester), closeTo(partenza, 1.0),
        reason: 'Tornando indietro col dito la striscia deve risalire di '
            'altrettanto.');
    await gesto.up();
    await tester.pump();
  });

  testWidgets('il dito non muove la striscia oltre i due estremi',
      (tester) async {
    await inChat(tester);
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final aperta = doveStannoLeVie(tester);

    final gesto =
        await tester.startGesture(tester.getCenter(ilCorpo().first));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    // Molto piu' lungo della corsa: la striscia si ferma a fondo corsa.
    await gesto.moveBy(const Offset(0, -EsploraStriscia.corsa * 4));
    await tester.pump();
    final ritratta = doveStannoLeVie(tester);
    expect(ritratta - aperta, closeTo(EsploraStriscia.corsa, 1.0),
        reason: 'Oltre il fondo corsa la striscia deve fermarsi.');

    await gesto.moveBy(const Offset(0, EsploraStriscia.corsa * 8));
    await tester.pump();
    expect(doveStannoLeVie(tester), closeTo(aperta, 1.0),
        reason: 'Oltre l\'apertura piena la striscia deve fermarsi.');
    await gesto.up();
    await tester.pump();
  });

  testWidgets('la linguetta apre e richiude, e non e\' un vicolo cieco',
      (tester) async {
    // **QUI VIVE `onChiudi`.** Era un parametro che il costruttore pretendeva e
    // che dentro `build` non compariva mai: finche' la striscia aperta
    // SOSTITUIVA la linguetta, aperta la striscia non restava piu' niente da
    // toccare per richiuderla, e il richiamo non aveva dove attaccarsi. Adesso
    // la linguetta resta sempre, quindi lo stesso tocco fa le due cose a
    // seconda di dove sta la striscia.
    await inChat(tester);
    final ritratta = doveStannoLeVie(tester);

    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final aperta = doveStannoLeVie(tester);
    expect(ritratta - aperta, closeTo(EsploraStriscia.corsa, 1.0),
        reason: 'Toccando la linguetta le vie devono salire in vista.');

    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(doveStannoLeVie(tester), closeTo(ritratta, 1.0),
        reason: 'Toccandola di nuovo le vie devono rientrare: senza questo, '
            'aperta la striscia non c\'e\' modo di richiuderla col tocco.');
  });

  testWidgets('con Riduci Movimento il cambio resta secco', (tester) async {
    await inChat(tester, riduciMovimento: true);
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final aperta = doveStannoLeVie(tester);

    final gesto =
        await tester.startGesture(tester.getCenter(ilCorpo().first));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    // Un solo punto di scorrimento: col movimento continuo si sposterebbe di
    // un punto, col cambio secco e' gia' tutta ritratta.
    await gesto.moveBy(const Offset(0, -1));
    await tester.pump();
    expect(doveStannoLeVie(tester) - aperta, closeTo(EsploraStriscia.corsa, 1.0),
        reason: 'Con Riduci Movimento la striscia non segue il dito: cambia '
            'stato di colpo, che e\' esattamente cio\' che quell\'impostazione '
            'chiede.');
    await gesto.up();
    await tester.pump();
  });
}
