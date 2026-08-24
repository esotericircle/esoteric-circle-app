import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA FASCIA IN FONDO ALLA HOME C'E' E SI RAGGIUNGE.
///
/// **Cosa ho trovato, misurato prima di correggere.** La premessa diceva che la
/// fascia non compare piu'. Montando l'app: viene COSTRUITA (una occorrenza
/// nell'albero) ed e' raggiungibile scorrendo, sia con la barra dentro sia con
/// la barra fuori. Non era ne' tagliata dal contenitore ne' mai costruita.
///
/// Quel che invece era vero, e che il telefono mostrava, e' che lo spazio
/// riservato in fondo COMMUTAVA col movimento della barra: quando la barra
/// rientrava, l'ultimo pezzo della fascia finiva sotto di lei, e chi guardava
/// vedeva una fascia che spariva. Col padding costante della voce 1 quel caso
/// non esiste piu', e questa prova lo tiene chiuso.
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

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  Finder ilCorpo() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  /// Scorre fino in fondo, come farebbe un dito.
  Future<void> finoInFondo(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.drag(ilCorpo().first, const Offset(0, -400));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('la fascia viene costruita', (tester) async {
    await monta(tester);
    expect(find.byKey(const Key('tue_arti_titolo'), skipOffstage: false),
        findsOneWidget,
        reason: 'La fascia in fondo alla home non viene proprio costruita.');
  });

  testWidgets('si raggiunge scorrendo, e si legge intera sopra la barra',
      (tester) async {
    await monta(tester);

    // DALLA VOCE 4 DEL 2161 LA FASCIA NON E' PIU' L'ULTIMA SEZIONE: sotto
    // vive la striscia delle altre arti, quindi a fondo corsa il titolo
    // della fascia esce dal bordo alto, e non e' un difetto. L'intento
    // della guardia resta quello del 2156: scorrendo come un dito, la
    // fascia DEVE arrivare a leggersi intera sopra la barra. Si scorre a
    // passi e ci si ferma quando la si legge, come farebbe una persona.
    final fascia = find.byKey(const Key('tue_arti_titolo'));
    final schermo =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    var letta = false;
    for (var i = 0; i < 12 && !letta; i++) {
      await tester.drag(ilCorpo().first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 120));
      if (fascia.evaluate().isEmpty) continue;
      final r = tester.getRect(fascia);
      letta = r.top >= 0.0 &&
          r.bottom <= schermo - BarraDelCerchio.altezza;
    }
    expect(letta, isTrue,
        reason: 'Scorrendo la home a passi la fascia non arriva mai a '
            'leggersi intera sopra la barra: e\' il caso del 2156 in cui, '
            'guardando, la fascia sembra sparita.');
  });

  testWidgets('resta raggiungibile anche con la barra fuori', (tester) async {
    await monta(tester);
    // Si porta la barra a fondo corsa col dito, poi si scorre fino in fondo.
    final gesto = await tester.startGesture(tester.getCenter(ilCorpo().first));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa));
    await tester.pump();
    await gesto.up();
    await tester.pump();
    await finoInFondo(tester);

    expect(find.byKey(const Key('tue_arti_titolo')), findsOneWidget,
        reason: 'Con la barra fuori la fascia non si raggiunge piu\'.');
  });
}
