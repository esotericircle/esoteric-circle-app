import 'dart:math';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/bindrune.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata dell'Estrazione Rune di Caligo.
void main() {
  // Sensori assenti in headless: senza il mock la parallasse e lo scuotimento
  // sollevano una MissingPluginException.
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
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
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

  Future<void> getta(WidgetTester tester) async {
    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await passo(tester);
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('La soglia mostra selettore, testo dinamico, domanda e lancio',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('rune_selector')), findsOneWidget);
    expect(find.byKey(const Key('rune_dynamic_text')), findsOneWidget);
    expect(find.byKey(const Key('rune_question_field')), findsOneWidget);
    // **LE PILLOLE SONO DIVENTATE UNA TENDINA, ordine S voce 21.** La domanda si
    // pone prima di gettare e sta SOPRA il pulsante: cinque pillole aperte sotto il
    // getto erano l'elenco vecchio, e in cima non ci sarebbero mai stati sedici
    // suggerimenti in chiaro.
    expect(find.byKey(const Key('rune_tendina_domande')), findsOneWidget);
    expect(find.byKey(const Key('rune_cast_button')), findsOneWidget);
    // **IL POZZO NON STA PIU' SULLA SOGLIA, ordine S voce 22.** Erano 140 punti
    // che non dipingevano niente fra la domanda e il pulsante, misurati sulla
    // resa. Il pozzo compare col getto, dove ha le pietre: la sua prova vive in
    // `il_pozzo_in_attesa_non_e_un_vuoto_test`.
    expect(find.byKey(const Key('rune_well')), findsNothing);
    // La gettata iniziale e' la Runa di Odino: il testo dinamico ne parla.
    expect(find.textContaining('Odino'), findsWidgets);
  });

  testWidgets('Il selettore cambia gettata e testo dinamico', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // All'inizio, Odino cita l'Havamal; non ancora Tacito.
    expect(find.textContaining('Havamal'), findsOneWidget);
    expect(find.textContaining('Tacito'), findsNothing);

    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    // Ora le tre Norne citano Tacito e la Voluspa.
    expect(find.textContaining('Tacito'), findsOneWidget);
    expect(find.textContaining('Havamal'), findsNothing);
  });

  testWidgets('Un suggerimento riempie la domanda', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // La domanda si scegli dalla tendina, che e' il modo nuovo: si apre e si
    // prende la voce.
    await tester.tap(find.byKey(const Key('rune_tendina_domande')));
    await passo(tester);
    await tester.tap(find.text('Nel lavoro, quale passo fare?').last);
    await passo(tester);
    final campo = tester.widget<TextField>(
        find.byKey(const Key('rune_question_field')));
    expect(campo.controller!.text, 'Nel lavoro, quale passo fare?');
  });

  testWidgets('Getta le rune porta al responso col presagio', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // Le tre Norne: tre rune posate.
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    await getta(tester);

    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_0')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_1')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_2')), findsOneWidget);
    expect(find.byKey(const Key('rune_card_3')), findsNothing);
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
    // Il presagio passa dalla porta unica dei paragrafi, quindi non e' piu'
    // un Text solo: si verifica che il blocco ci sia e porti del testo.
    final presagio = find.descendant(
        of: find.byKey(const Key('rune_presage_text')),
        matching: find.byType(Text));
    expect(presagio, findsWidgets);
    expect(tester.widget<Text>(presagio.first).data!.trim(), isNotEmpty);
    expect(find.byKey(const Key('rune_share')), findsOneWidget);
    expect(find.byKey(const Key('rune_consulta')), findsOneWidget);
  });

  testWidgets('La Croce delle Cinque posa cinque rune', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('rune_segment_croce')));
    await passo(tester);
    await getta(tester);

    for (var i = 0; i < 5; i++) {
      expect(find.byKey(Key('rune_card_$i')), findsOneWidget, reason: 'card $i');
    }
  });

  testWidgets('La domanda scritta compare sopra la lettura', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.enterText(
        find.byKey(const Key('rune_question_field')), 'Dove sto andando?');
    await passo(tester);
    await getta(tester);
    expect(find.byKey(const Key('rune_question_shown')), findsOneWidget);
    expect(find.text('Dove sto andando?'), findsOneWidget);
  });

  testWidgets('Getta ancora resta nel responso con una nuova gettata',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await getta(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('rune_recast')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_recast')));
    await passo(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
  });

  testWidgets('Nessuna etichetta del selettore e\' troncata', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // Ogni nome di gettata si legge per intero, compreso "La Croce delle
    // Cinque" e "Il getto sul telo", niente tre puntini.
    for (final g in gettate) {
      expect(find.text(g.nome), findsWidgets, reason: g.nome);
    }
    // Nessuna etichetta nel selettore usa l'ellissi da troncamento.
    final testi = find.descendant(
        of: find.byKey(const Key('rune_selector')),
        matching: find.byType(Text));
    for (final e in testi.evaluate()) {
      final t = e.widget as Text;
      expect(t.overflow == TextOverflow.ellipsis, isFalse,
          reason: 'etichetta troncata: ${t.data}');
    }
  });

  testWidgets('Il getto sul telo e\' selezionabile, si legge e da\' il sigillo',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('rune_segment_telo')));
    await passo(tester);
    // Il testo dinamico della sorte libera cita Tacito e il telo.
    expect(find.textContaining('Tacito'), findsOneWidget);
    expect(find.textContaining('telo'), findsWidgets);

    await getta(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    // Si legge almeno una runa, in luce.
    expect(find.byKey(const Key('rune_card_0')), findsOneWidget);
    // DALL'ORDINE H sul telo il verso esce a sorte come nelle altre gettate:
    // la scheda dice "diritta", "in merkstave" o la nota della simmetrica,
    // mai piu' "in luce", che direbbe il falso su una runa rovesciata.
    expect(find.text('in luce'), findsNothing);
    expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'diritta' ||
                w.data == 'in merkstave' ||
                w.data == SunsetRuneCorpus.noteSimmetrica)),
        findsWidgets);
    // Il sigillo del giorno con la bindrune.
    expect(find.byKey(const Key('rune_sigillo')), findsOneWidget);
    expect(find.byKey(const Key('bindrune')), findsOneWidget);
  });

  testWidgets('La bindrune viene dalle rune uscite, in modo deterministico',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    await getta(tester);

    // La stessa sorgente del caso della schermata, il seme 3, da' le stesse rune.
    final atteso = RuneCast.getta(gettataNorne, random: Random(3))
        .rune
        .map((r) => r.rune.name)
        .toList();
    final sigillo =
        tester.widget<BindruneSigillo>(find.byType(BindruneSigillo));
    expect(sigillo.runeNames, atteso);
  });
}
