// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/la_stesa_conservata.dart';
import 'package:esoteric_circle/core/tarot/le_uscite_delle_carte.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **"LE CARTE HANNO GIA' PARLATO" SOLO NEL CASO RARO**, ordine GD voce
/// GD.04, 23 ottobre 2026. Il fondatore: *"Questa scritta deve uscire solo
/// nella caso raro in cui pongo la stessa identica domanda ed escono le
/// stesse identiche carte nello stesso giorno"*.
///
/// Quattro casi, con lo stesso seme (lo stesso mazzo) e la stessa domanda:
/// la domanda nuova, la stessa domanda con carte diverse, la stessa domanda
/// con le stesse carte, il giorno dopo. La riga c'e' soltanto nel terzo, e
/// mai prima che le carte siano scelte.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
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
  });

  Future<void> passa(WidgetTester tester, int volte) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> monta(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(
          child: StesaTreCarteScreen(
            seed: 11,
            ricordaAncheColSeme: true,
            skipIntro: true,
            topic: TarotTopic.momentoCheVivo,
            chiamata: (i, r, c) async =>
                throw StateError('GD.04: nessuna chiamata al modello'),
          ),
        ),
      ),
    ));
    await passa(tester, 30);
  }

  Future<void> scegli(WidgetTester tester, List<int> indici) async {
    for (final i in indici) {
      final r = tester.getRect(find.byKey(Key('stesa_fan_$i')));
      await tester.tapAt(Offset(r.left + 6, r.center.dy));
      await tester.pump();
      await passa(tester, 25);
    }
  }

  bool riga() =>
      find.byKey(const Key('stesa_conservata')).evaluate().isNotEmpty;

  testWidgets('la riga solo con la stessa domanda e le stesse carte, oggi',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(402, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final esiti = <String, bool>{};

    // 1. La domanda nuova: nessuna stesa oggi.
    await monta(tester);
    final primaDiScegliere1 = riga();
    await scegli(tester, const [36, 37, 38]);
    esiti['domanda nuova, prima di scegliere'] = primaDiScegliere1;
    esiti['domanda nuova, carte scelte'] = riga();
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0;
        i < 40 && tester.widget<FilledButton>(pulsante).onPressed == null;
        i++) {
      await passa(tester, 1);
    }
    print('GD.04: pulsante acceso '
        '${tester.widget<FilledButton>(pulsante).onPressed != null}, carte '
        '${tester.state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen)).stesaCorrente.cards.length}');
    await tester.ensureVisible(pulsante);
    await tester.pump();
    await tester.tap(pulsante, warnIfMissed: false);
    await passa(tester, 60);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await passa(tester, 5);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LaStesaConservata.chiave), isNotNull,
        reason: 'la prima stesa non si e\' conservata');

    // 2. La stessa domanda, carte diverse.
    await monta(tester);
    esiti['stessa domanda, prima di scegliere'] = riga();
    await scegli(tester, const [40, 41, 42]);
    esiti['stessa domanda, carte diverse'] = riga();

    // 3. La stessa domanda, le stesse carte (stesso mazzo, stessi dorsi).
    await monta(tester);
    await scegli(tester, const [36, 37, 38]);
    esiti['stessa domanda, stesse carte'] = riga();
    // La stesa identica si rilegge senza contarla di nuovo (voce FI.18).
    final contoPrima = prefs.getString(LeUsciteDelleCarte.chiave);
    await tester.ensureVisible(pulsante);
    await tester.pump();
    await tester.tap(pulsante, warnIfMissed: false);
    await passa(tester, 60);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await passa(tester, 5);
    expect(prefs.getString(LeUsciteDelleCarte.chiave), contoPrima,
        reason: 'la stessa stesa riletta si e\' contata di nuovo');

    // 4. Il giorno dopo: la stesa conservata e' di ieri.
    final dati = jsonDecode(prefs.getString(LaStesaConservata.chiave)!) as Map;
    dati['giorno'] = '2000-01-01';
    await prefs.setString(LaStesaConservata.chiave, jsonEncode(dati));
    await monta(tester);
    await scegli(tester, const [36, 37, 38]);
    esiti['il giorno dopo, stesse carte'] = riga();

    print('GD.04: $esiti');
    expect(esiti, {
      'domanda nuova, prima di scegliere': false,
      'domanda nuova, carte scelte': false,
      'stessa domanda, prima di scegliere': false,
      'stessa domanda, carte diverse': false,
      'stessa domanda, stesse carte': true,
      'il giorno dopo, stesse carte': false,
    });
    await tester.pumpWidget(const SizedBox());
    await passa(tester, 5);
  });
}
