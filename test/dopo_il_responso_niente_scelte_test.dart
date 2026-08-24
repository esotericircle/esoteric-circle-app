import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// DOPO IL RESPONSO NON RESTANO SCELTE DA FARE. Ordine S voce 23.
///
/// **La voce dice: "i pulsanti di scelta della stesa restano dopo il getto".** Una
/// scelta che resta dopo il responso e' un invito a rifare invece di un invito a
/// leggere, e chi tocca un pulsante di scelta si aspetta che cambi qualcosa: se la
/// lettura e' gia' uscita, quel tocco o non fa niente o butta il responso.
///
/// **QUESTA PROVA E' NATA PER VERIFICARE UNA PREMESSA, non per chiudere un difetto.**
/// Il difetto era dichiarato ma non misurato: prima di toccare il codice si guarda se
/// c'e'. La misura enumera i comandi di scelta delle due arti che hanno un getto e
/// pretende che nessuno sopravviva al responso.
void main() {
  void silenceSensors(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(
                  initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          // TIER 1: la prova guarda le scelte che restano, non i tetti del
          // giorno; col piano gratuito la seconda gettata aprirebbe l'invito
          // all'upgrade invece di gettare (ordine BF voce 05.a).
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: Tier.tier1)),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('nell\'Estrazione Rune la scelta della gettata resta dopo il '
      'responso, e getta davvero', (tester) async {
    silenceSensors(tester);
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host());
    await passo(tester);

    // I QUATTRO COMANDI DI SCELTA, enumerati: il selettore e le sue quattro
    // pillole. Prima del getto ci sono tutti, ed e' giusto.
    const scelte = [
      'rune_selector',
      'rune_segment_odino',
      'rune_segment_norne',
      'rune_segment_croce',
      'rune_segment_telo',
    ];
    for (final s in scelte) {
      expect(find.byKey(Key(s)), findsOneWidget,
          reason: 'prima del getto la scelta "$s" deve esserci: senza di lei '
              'non si scegli la gettata');
    }

    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);

    // **LA LEGGE SI E' ROVESCIATA, ordine BF voce 05.a.** L'ordine S voce 23
    // aveva verificato che nessun selettore sopravviveva al responso e
    // l'aveva dichiarato giusto; il fondatore ha poi concordato il
    // contrario: le pillole della stesa RESTANO dopo il getto, e toccarne
    // una getta subito con quella stesa, senza tornare indietro. Il timore
    // di allora (un selettore che sembri cambiare una lettura gia' uscita)
    // e' sciolto dal comportamento: il tocco non cambia la lettura, ne apre
    // una nuova.
    for (final s in scelte) {
      expect(find.byKey(Key(s)), findsOneWidget,
          reason: 'dopo il responso la scelta "$s" deve restare: dal responso '
              'si cambia stesa direttamente (ordine BF voce 05.a)');
    }

    // E il tocco su un'altra pillola getta DAVVERO con quella stesa.
    await tester.ensureVisible(find.byKey(const Key('rune_segment_norne')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    expect(find.text('LE TRE NORNE'), findsOneWidget,
        reason: 'il tocco sulla pillola delle Norne non ha gettato con le '
            'Norne: la scelta dal responso e\' muta');

    // "Getta ancora" resta, e rifa' la stessa gettata dichiarandolo nel nome.
    expect(find.byKey(const Key('rune_recast')), findsOneWidget,
        reason: 'per rigettare la stessa stesa serve il comando che lo dice');
  });

  testWidgets('anche la domanda non resta modificabile dopo il responso',
      (tester) async {
    silenceSensors(tester);
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host());
    await passo(tester);

    // **LA STESSA FAMIGLIA, e la voce non la nomina.** La tendina delle domande e
    // il campo libero sono comandi di scelta come i quattro segmenti: se
    // restassero dopo il responso, cambiarli non cambierebbe la lettura appena
    // letta, e sarebbe la stessa promessa non mantenuta.
    expect(find.byKey(const Key('rune_tendina_domande')), findsOneWidget);
    expect(find.byKey(const Key('rune_question_field')), findsOneWidget);

    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);

    expect(find.byKey(const Key('rune_tendina_domande')), findsNothing,
        reason: 'la tendina delle domande resta dopo il responso: sceglierne '
            'un\'altra non cambierebbe la lettura appena uscita');
    expect(find.byKey(const Key('rune_question_field')), findsNothing,
        reason: 'il campo della domanda resta dopo il responso');
    // La domanda posta invece si RILEGGE, e non e' un comando: e' il fatto che
    // spiega la lettura.
    expect(find.byKey(const Key('rune_senza_domanda')), findsNothing);
  });

  testWidgets('nella Stesa di Tarocchi la configurazione non sopravvive alla '
      'lettura', (tester) async {
    // **LA VOCE S.23 DICE "la stesa", quindi si guarda anche la'**, che e' l'altra
    // arte con un getto: la Stesa di Tarocchi. La configurazione (tipo, argomento,
    // chiave, mazzo, profondita') e' una fila di scelte, e con le tre carte gia'
    // sul tavolo cambiarle non cambierebbe la lettura appena letta.
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const StesaTreCarteScreen(
            seed: 2, skipIntro: true, revealAll: true),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const Key('stesa_setup_riga')), findsNothing,
        reason: 'la riga della configurazione resta con le tre carte già '
            'lette: cambiarla non cambierebbe la lettura');
    expect(find.byKey(const Key('stesa_setup')), findsNothing,
        reason: 'il pannello della configurazione resta dopo la lettura');
  });
}
