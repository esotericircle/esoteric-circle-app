import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SPAZIO ESAGERATO IN HOME E' SPARITO. Ordine AJ voce 03.
///
/// **Il difetto di Mauro, dal telefono**: fra la scheda dei tre Maestri e la
/// sezione delle arti c'era un vuoto reso di 184 punti, misurato sulla
/// schermata montata a 360 (lezione AC.02: si misura la resa, non il
/// codice). La causa, verificata prima di correggere: l'ingresso e' ancorato
/// a 14 punti dal fondo dell'eroe, e DOPO l'eroe viveva un'aria alta quanto
/// la barra (decisione del 2164, superata dalla voce di Mauro del 17
/// agosto): era quell'aria la fascia morta.
///
/// **La soglia viene dal misurato**: dopo la cura il vuoto reso e' di 92,3
/// punti, la somma dichiarata dei pezzi onesti (14 di aria dell'eroe, 32 di
/// respiro di sezione, 16 di distacco dello scaffale piu' la riga del suo
/// titolo). La soglia a 100 lascia il gioco del layout e cade molto prima
/// che la fascia morta possa tornare, che era il doppio.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('il vuoto fra i Maestri e le arti e\' un respiro di sezione',
      (tester) async {
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
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));

    final ingresso = find.byKey(const Key('santuario_enter_domain'));
    final titolo = find.text('Le arti preferite');
    expect(ingresso, findsWidgets);
    expect(titolo, findsWidgets,
        reason: 'la sezione delle arti non e\' montata: niente da misurare');
    final vuoto = tester.getRect(titolo.first).top -
        tester.getRect(ingresso.first).bottom;
    // **LA MISURA SI DICHIARA.**
    // ignore: avoid_print
    print('ORDINE AJ VOCE 03: vuoto reso fra ingresso e arti '
        '${vuoto.toStringAsFixed(1)} punti');
    expect(vuoto, lessThanOrEqualTo(100.0),
        reason: 'il vuoto fra la scheda dei Maestri e le arti e\' tornato a '
            '${vuoto.toStringAsFixed(1)} punti: la fascia morta era 184 e '
            'deve restare un respiro di sezione');
    expect(vuoto, greaterThan(0),
        reason: 'le due sezioni si toccano o si sovrappongono: non e\' il '
            'respiro chiesto, e\' un altro difetto');
  });
}
