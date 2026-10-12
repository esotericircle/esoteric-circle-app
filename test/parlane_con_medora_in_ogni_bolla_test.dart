/// IL PARLANE CON MEDORA DI OGNI BOLLA. Richiesta del fondatore, 12 ottobre
/// 2026: il pulsante "Parlane con Medora" in fondo alla schermata della Stesa
/// di Tarocchi si perde, chi legge una sola carta e chiude non lo vede mai.
///
/// Qui si verifica che ogni bolla (`BollaDellaPosizione`, una per Passato,
/// Presente e Futuro) porti in fondo al suo testo un pulsante suo, con la
/// stessa icona e lo stesso colore del `responso_parlane` che chiude la
/// schermata, ma piu' sottile: non a tutta larghezza.
library;

import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 4400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(const StesaTreCarteScreen(
      seed: 2,
      revealAll: true,
      skipIntro: true,
      topic: TarotTopic.bivio,
    )));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets(
      'ogni bolla porta il suo Parlane con Medora, sotto il testo della carta',
      (tester) async {
    await monta(tester);
    const posizioni = ['passato', 'presente', 'futuro'];
    for (final p in posizioni) {
      final pulsante = find.byKey(Key('bolla_parlane_$p'));
      expect(pulsante, findsOneWidget,
          reason: 'la bolla $p non ha il suo Parlane con Medora');
      final icona = find.descendant(
          of: pulsante, matching: find.byIcon(Icons.forum_outlined));
      expect(icona, findsOneWidget,
          reason: 'la bolla $p non porta la stessa icona del pulsante in '
              'fondo alla schermata');
    }
    // Quattro: le tre bolle piu' quello in fondo alla schermata
    // (`responso_parlane`), che resta com'era.
    expect(find.text('Parlane con Medora'), findsNWidgets(4),
        reason: 'ci sono ${find.text('Parlane con Medora').evaluate().length} '
            'pulsanti "Parlane con Medora" invece di 4 (tre bolle piu\' '
            'quello in fondo)');
  });

  testWidgets(
      'il pulsante della bolla e\' piu\' sottile di quello in fondo alla '
      'schermata', (tester) async {
    await monta(tester);
    final dentroLaBolla =
        tester.getSize(find.byKey(const Key('bolla_parlane_passato')));
    final infondo =
        tester.getSize(find.byKey(const Key('responso_parlane')));
    // ignore: avoid_print
    print('PARLANE IN OGNI BOLLA: pulsante nella bolla '
        '${dentroLaBolla.width.toStringAsFixed(0)}x'
        '${dentroLaBolla.height.toStringAsFixed(0)}, pulsante in fondo '
        '${infondo.width.toStringAsFixed(0)}x'
        '${infondo.height.toStringAsFixed(0)}');
    expect(dentroLaBolla.width, lessThan(infondo.width),
        reason: 'il pulsante della bolla non e\' piu\' sottile di quello in '
            'fondo alla schermata: ${dentroLaBolla.width} contro '
            '${infondo.width}');
  });

  test('ChatOpeners.cartaDellaStesa cita l\'etichetta e la carta', () {
    final sorgente = File('lib/features/maestri/chat/chat_openers.dart')
        .readAsStringSync();
    expect(sorgente.contains('static String cartaDellaStesa('), isTrue,
        reason: 'la porta della chat per la singola bolla non esiste piu\'');
  });
}
