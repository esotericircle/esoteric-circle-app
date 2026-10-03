import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I MAESTRI FLUTTUANO, E LO SPAZIO SOTTO SI E' STRETTO. Ordine BE voce 01.
///
/// **Parole del fondatore sulla 2199**: "c'e' troppo spazio sotto i 3 maestri
/// e inoltre prima i 3 maestri fluttuavano e voglio ancora l'effetto
/// fluttuazione". Il movimento orizzontale della parallasse resta com'e'.
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

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = const Size(390, 844) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('BE.01: tutti e tre i Maestri fluttuano, sfasati',
      (tester) async {
    await monta(tester);
    Rect di(String k) => tester.getRect(find.byKey(Key(k)));

    // Il respiro dura sei secondi: fra due istanti a un quarto di ciclo la
    // quota verticale DEVE cambiare, per tutti e tre.
    final prima = {
      for (final k in const [
        'santuario_central_bust',
        'santuario_side_left',
        'santuario_side_right'
      ])
        k: di(k).bottom
    };
    await tester.pump(const Duration(milliseconds: 1500));
    final dopo = {for (final k in prima.keys) k: di(k).bottom};
    for (final k in prima.keys) {
      final salto = (dopo[k]! - prima[k]!).abs();
      // ignore: avoid_print
      print('ORDINE BE VOCE 01: $k si e\' mosso di '
          '${salto.toStringAsFixed(1)} punti in un quarto di respiro');
      expect(salto, greaterThan(1.0),
          reason: '$k non fluttua: il fondatore ha chiesto che l\'effetto '
              'torni, per tutti e tre');
      expect(salto, lessThan(12.0),
          reason: '$k sobbalza di ${salto.toStringAsFixed(1)} punti: una '
              'fluttuazione, non un ascensore');
    }
    // E i tre non salgono in coro: almeno due quote diverse nello stesso
    // istante, se no e' un palco che si muove tutto insieme.
    final quote = dopo.values.map((v) => v.round()).toSet();
    expect(quote.length, greaterThan(1),
        reason: 'i tre Maestri fluttuano in coro: le fasi sfasate sono '
            'sparite');
  });

  testWidgets('BE.01: lo spazio sotto le carte si e\' stretto', (tester) async {
    await monta(tester);
    final centro =
        tester.getRect(find.byKey(const Key('santuario_central_bust')));
    final ingresso =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final aria = ingresso.top - centro.bottom;
    // ignore: avoid_print
    print('ORDINE BE VOCE 01: fra il fondo delle carte e la bolla '
        'd\'ingresso corrono ${aria.toStringAsFixed(1)} punti');
    // La misura arriva fino al PULSANTE della bolla, quindi contiene anche
    // l'invito di due righe che gli sta sopra (circa 32 punti): il cuscino
    // vero sotto le carte e' otto punti piu' l'otto per mille dell'eroe,
    // quindici a questa misura, e la fluttuazione ne aggiunge fino a
    // cinque. Prima della cura il solo cuscino ne valeva ventotto, e il
    // totale superava i sessanta.
    expect(aria, lessThan(53),
        reason: 'sotto i Maestri c\'e\' di nuovo troppa aria: il cuscino '
            'era stato stretto per la voce BE.01');
  });
}
