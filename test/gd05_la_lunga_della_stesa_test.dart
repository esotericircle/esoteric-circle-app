// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_lettura_finta_della_stesa.dart';

/// **LA LUNGA DELLA STESA DA' I DUE PARAGRAFI, col modello e senza.** Ordine
/// GD voce GD.05, 23 ottobre 2026. Il fondatore: *"la profondità lunga nella
/// prima risposta NON FUNZIONA: non compaiono i 2 paragrafi aggiuntivi di cui
/// il 2ndo in riquadro con il titolo che avevi scelto"*.
///
/// La schermata vera, dalla scelta delle carte al responso, quattro volte:
/// Breve e Lunga, col modello (finto, a misura: regola SPESE) e col modello
/// che non torna, che e' il caso che sul telefono toglieva la Lunga. Si
/// contano i paragrafi del responso principale e si cerca il riquadro col
/// suo titolo.
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

  const pezzi = ['risposta', 'cosa_fare', 'approfondimento', 'rito'];

  Future<Map<String, Object>> responso(WidgetTester tester,
      {required AnswerDepth profondita, required bool colModello}) async {
    SharedPreferences.setMockInitialValues({});
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
            skipIntro: true,
            topic: TarotTopic.momentoCheVivo,
            profondita: profondita,
            chiamata: (i, r, c) async {
              if (!colModello) throw StateError('GD.05: la rete non c\'e\'');
              final stesa = tester
                  .state<StesaTreCarteScreenState>(
                      find.byType(StesaTreCarteScreen))
                  .stesaCorrente;
              return jsonEncode(
                  letturaFinta(stesa, lunga: profondita == AnswerDepth.profonda)
                      .toJson());
            },
          ),
        ),
      ),
    ));
    await passa(tester, 30);
    for (final i in const [36, 37, 38]) {
      final r = tester.getRect(find.byKey(Key('stesa_fan_$i')));
      await tester.tapAt(Offset(r.left + 6, r.center.dy));
      await tester.pump();
      await passa(tester, 25);
    }
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0;
        i < 40 && tester.widget<FilledButton>(pulsante).onPressed == null;
        i++) {
      await passa(tester, 1);
    }
    await tester.ensureVisible(pulsante);
    await tester.pump();
    await tester.tap(pulsante, warnIfMissed: false);
    for (var i = 0;
        i < 300 &&
            find
                .byKey(const Key('stesa_principale_risposta'))
                .evaluate()
                .isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await passa(tester, 20);
    final presenti = [
      for (final p in pezzi)
        if (find.byKey(Key('stesa_principale_$p')).evaluate().isNotEmpty) p,
    ];
    final titolo = find.descendant(
        of: find.byType(RiquadroArancione),
        matching: find.byKey(const Key('stesa_principale_titolo_rito')));
    final esito = <String, Object>{
      'paragrafi': presenti.length,
      'pezzi': presenti.join(','),
      'riquadro col titolo':
          titolo.evaluate().isEmpty ? '' : tester.widget<Text>(titolo).data!,
    };
    await tester.pumpWidget(const SizedBox());
    await passa(tester, 5);
    return esito;
  }

  testWidgets('la Lunga aggiunge due paragrafi, il secondo nel riquadro',
      (tester) async {
    tester.view.physicalSize = const Size(402, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final esiti = <String, Map<String, Object>>{};
    for (final colModello in const [true, false]) {
      for (final p in const [AnswerDepth.breve, AnswerDepth.profonda]) {
        esiti['${p.label} ${colModello ? 'col modello' : 'senza modello'}'] =
            await responso(tester, profondita: p, colModello: colModello);
      }
    }
    print('GD.05: $esiti');
    const titolo = 'La contemplazione propiziatoria';
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.tarocchi), titolo);
    for (final e in esiti.entries) {
      final lunga = e.key.startsWith('Lunga');
      expect(e.value['paragrafi'], lunga ? 4 : 2,
          reason: '${e.key}: ${e.value['pezzi']}');
      expect(e.value['riquadro col titolo'], lunga ? titolo : '',
          reason: '${e.key}: il riquadro col titolo');
    }
  });
}
