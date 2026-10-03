// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/features/amici/l_oroscopo_dell_amico_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **L'OROSCOPO COME SI VEDE NELLE ANTEPRIME.** Ordine ES, 30 settembre 2026.
///
/// Il fondatore valida guardando le anteprime, ed e' da un'anteprima che ha
/// visto "Settimana" andare a capo nel selettore. Riguardate una per una prima
/// della consegna, le anteprime dell'Oroscopo mostravano altri quattro
/// difetti che nessuna prova cercava, ognuno col suo padre:
/// - il sottotitolo che lascia "giorno" o "settimana" da soli sulla seconda
///   riga (ordine 2171 voce 5, che lo ha allungato col nome del periodo);
/// - la frase del segno attaccata al sottotitolo, e "In arrivo" che tocca la
///   riga delle tradizioni (ES.07, che ha messo il segno in cima);
/// - le tre tradizioni dell'amico su due righe, "Vedica" da sola (ES.12);
/// - "Condividi" e "Manda a Lucia" in viola scuro sul pulsante viola
///   (PROVENIENZA IGNOTA: il tema non ha mai dichiarato il colore di cio' che
///   sta sul primario).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  final nascita = BirthDetails(
    date: DateTime(1990, 6, 15),
    time: const TimeOfDay(hour: 8, minute: 10),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );

  Future<void> monta(WidgetTester tester, {double scala = 1.0}) async {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(name),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    final piano = EntitlementService()..setTier(Tier.tier3);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider.value(value: piano),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
              disableAnimations: true, textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.gemini, now: DateTime(2026, 9, 30, 12, 5)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final r = tester.getRect(chip);
    if (r.right > 360) {
      await tester.drag(riga, Offset(360 - r.right - 8, 0));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // La rivelazione del segno, la prima volta: si chiude.
    final continua = find.byKey(const Key('rivelazione_continua'));
    if (continua.evaluate().isNotEmpty) {
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(continua);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }
  }

  // **LAPIDE, 1 ottobre 2026, ordine EU voce 04.** La prova pretendeva che
  // "Oroscopo Personalizzato della settimana", che a 360 punti andava a capo,
  // non lasciasse il nome del periodo da solo sulla seconda riga. Il
  // fondatore ha tolto "Personalizzato" per guadagnare una riga: adesso si
  // pretende che la testata stia su UNA riga, a 360 punti e al carattere
  // massimo, e che "Personalizzato" non ci sia.
  testWidgets(
      'la testata dice "Oroscopo del" periodo su una riga sola, senza '
      '"Personalizzato"', (tester) async {
    final soli = <String>[];
    var misurati = 0;
    var suDueRighe = 0;
    for (final scala in [1.0, 1.3]) {
      await monta(tester, scala: scala);
      for (final p in HoroscopePeriod.values) {
        // Senza portarlo in vista: nella finestra alta il selettore si vede
        // gia', e scorrendo il sottotitolo che gli sta sopra uscirebbe.
        final scheda = find.byKey(Key('oroscopo_period_${p.name}'));
        await tester.tap(scheda);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final titolo = find.byKey(const Key('oroscopo_heading'));
        expect(titolo, findsOneWidget);
        final testo = tester.widget<Text>(titolo).data!;
        // Quello che si legge e' il sottotitolo del periodo, parola per
        // parola: lo spazio che non si spezza non cambia le parole.
        expect(testo.replaceAll('\u00A0', ' '), p.sottotitolo);
        final paragrafo = tester.renderObject<RenderParagraph>(titolo);
        const prima = 'Oroscopo ';
        final preposizione = paragrafo
            .getOffsetForCaret(
                const TextPosition(offset: prima.length), Rect.zero)
            .dy;
        final nome = paragrafo
            .getOffsetForCaret(
                TextPosition(offset: testo.length - 1), Rect.zero)
            .dy;
        final inizio = paragrafo
            .getOffsetForCaret(const TextPosition(offset: 0), Rect.zero)
            .dy;
        misurati++;
        if (nome != inizio) {
          suDueRighe++;
          soli.add('scala $scala, ${p.label} su due righe: "$testo"');
        }
        if (testo.contains('Personalizzato')) {
          soli.add('scala $scala, ${p.label} dice ancora "Personalizzato"');
        }
        if (preposizione != nome) {
          soli.add('scala $scala, ${p.label}: "$testo"');
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
    cardinaleMinimo(misurati, 8, cosa: 'sottotitoli misurati');
    print('ORDINE EU, LA TESTATA A 360 PUNTI: testate su due righe '
        '$suDueRighe su $misurati, fuori regola ${soli.length}'
        '${soli.isEmpty ? '' : ': ${soli.join('; ')}'}');
    expect(soli, isEmpty);
  });

  testWidgets(
      'sotto la testa di una tradizione c\'e\' uno stacco, prima del '
      'sottotitolo o della riga delle tradizioni', (tester) async {
    await monta(tester);
    final attaccate = <String>[];
    var misurate = 0;
    final altre = AstroTradition.values
        .where((t) => t != AstroTradition.occidentale)
        .toList();
    cardinaleMinimo(altre.length, 6, cosa: 'tradizioni oltre l\'occidentale');
    for (final t in altre) {
      await toccaLaTradizione(tester, t);
      final testa = find.byKey(Key('oroscopo_testa_${t.name}'));
      expect(testa, findsOneWidget, reason: 'manca la testa di ${t.name}');
      final sotto = t.unlocked
          ? find.byKey(const Key('oroscopo_heading'))
          : find.byKey(const Key('oroscopo_tradition_tabs'));
      expect(sotto, findsOneWidget);
      final stacco = tester.getRect(sotto).top - tester.getRect(testa).bottom;
      misurate++;
      if (stacco < SpacingTokens.md - 0.5) {
        attaccate.add('${t.name}: ${stacco.toStringAsFixed(1)} punti');
      }
    }
    print('ORDINE ES VOCE 07, LO STACCO SOTTO LA TESTA: tradizioni con meno '
        'di ${SpacingTokens.md.round()} punti fra la testa e cio\' che segue '
        '${attaccate.length} su $misurate'
        '${attaccate.isEmpty ? '' : ': ${attaccate.join('; ')}'}');
    expect(attaccate, isEmpty);
  });

  testWidgets(
      'ES.12: le tre tradizioni dell\'amico stanno su una riga, a 360 '
      'punti', (tester) async {
    final guasti = <String>[];
    var misurate = 0;
    for (final scala in [1.0, 1.3]) {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: Tier.tier3)),
        ],
        child: MaterialApp(
            theme: AppTheme.dark(),
            builder: (ctx, child) => MediaQuery(
                  data: MediaQuery.of(ctx)
                      .copyWith(textScaler: TextScaler.linear(scala)),
                  child: child!,
                ),
            home: MaestroScope(
                maestro: Maestro.medora,
                child: LOroscopoDellAmicoScreen(
                    amico: Amico(
                        id: 'l', nome: 'Lucia', nascita: DateTime(1990, 1, 12)),
                    adesso: DateTime(2026, 9, 30, 12)))),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      final centri = <double>{};
      for (final t in const ['occidentale', 'cinese', 'vedica']) {
        final voce = find.byKey(Key('amico_tradizione_$t'));
        expect(voce, findsOneWidget);
        final r = tester.getRect(voce);
        misurate++;
        centri.add(r.center.dy.roundToDouble());
        if (r.left < -0.5 || r.right > 360.5) {
          guasti.add('scala $scala, $t: esce dallo schermo '
              '(${r.left.round()}, ${r.right.round()})');
        }
        // Il nome su una riga sola.
        final nome = find.descendant(of: voce, matching: find.byType(RichText));
        final paragrafo = tester.renderObject<RenderParagraph>(nome.first);
        final righe = paragrafo
            .getBoxesForSelection(TextSelection(
                baseOffset: 0,
                extentOffset: paragrafo.text.toPlainText().length))
            .map((b) => b.top.round())
            .toSet();
        if (righe.length != 1) guasti.add('scala $scala, $t: nome a capo');
      }
      if (centri.length != 1) {
        guasti.add('scala $scala: le tre voci su ${centri.length} righe');
      }
      // La scelta si tocca ancora, e cambia la lettura.
      await tester.tap(find.byKey(const Key('amico_tradizione_cinese')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('oroscopo_frase_cinese')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
    cardinaleMinimo(misurate, 6, cosa: 'voci delle tradizioni dell\'amico');
    print('ORDINE ES VOCE 12, LE TRADIZIONI DELL\'AMICO A 360 PUNTI: guasti '
        '${guasti.length} su $misurate voci'
        '${guasti.isEmpty ? '' : ': ${guasti.join('; ')}'}');
    expect(guasti, isEmpty);
  });

  testWidgets('la scritta di un pulsante pieno si legge sul suo fondo',
      (tester) async {
    double contrasto(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final chiaro = la > lb ? la : lb;
      final scuro = la > lb ? lb : la;
      return (chiaro + 0.05) / (scuro + 0.05);
    }

    // Prima: il colore che lo schema calcola dal seme per cio' che sta sul
    // suo primario, messo sul primario del Cerchio.
    final primario = MaestroPalette.neutral.primary;
    final diFabbrica =
        ColorScheme.fromSeed(seedColor: primario, brightness: Brightness.dark);
    final prima = contrasto(diFabbrica.onPrimary, primario);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: FilledButton.icon(
            key: const Key('pieno'),
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Condividi'),
          ),
        ),
      ),
    ));
    await tester.pump();
    final scritta = tester
        .renderObject<RenderParagraph>(find.text('Condividi'))
        .text
        .style!
        .color!;
    final fondo = tester
        .widget<Material>(find
            .descendant(
                of: find.byKey(const Key('pieno')),
                matching: find.byType(Material))
            .first)
        .color!;
    final dopo = contrasto(scritta, fondo);
    final icona =
        IconTheme.of(tester.element(find.byIcon(Icons.ios_share_rounded)))
            .color!;
    print('ORDINE ES, LA SCRITTA DEI PULSANTI PIENI: contrasto sul fondo, '
        'prima ${prima.toStringAsFixed(2)}, dopo ${dopo.toStringAsFixed(2)} '
        '(icona ${contrasto(icona, fondo).toStringAsFixed(2)})');
    expect(fondo, primario, reason: 'il pulsante non ha il fondo del tema');
    // Sette, la misura che il censimento dei grigi chiede a una etichetta.
    expect(dopo, greaterThanOrEqualTo(7.0));
    expect(contrasto(icona, fondo), greaterThanOrEqualTo(7.0));
  });
}
