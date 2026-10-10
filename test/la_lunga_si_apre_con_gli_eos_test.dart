// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA LUNGA SI APRE CON GLI EOS.** Ordine EU voce 15, 1 ottobre 2026.
///
/// La tabella della voce ES.06, approvata dal fondatore (*"Approvo
/// tutto."*): *"Occidentale del giorno, Approfondita: 50 Eos, per la
/// giornata e le quattro schede"*; alla domanda *"Chi può scegliere la
/// profondità Lunga?"*, *"Premium più Eos"*. Il rapporto ES (scelta 17)
/// diceva che nel listino quel prezzo non c'era e che al Viandante la Lunga
/// mostrava solo l'invito al piano.
///
/// Si pretende: le voci dell'Oroscopo che la tabella ES.06 prezza in Eos
/// stanno tutte nel listino (la Lunga del giorno 50, l'anno 300, un amico in
/// piu' 100), e nessuna per la Vedica o la Cinese; al Viandante il lucchetto
/// della Lunga nell'Occidentale del giorno apre le due strade: prima, pieno,
/// l'invito "Abbonati per avere sempre l'oroscopo completo"; sotto, col
/// bordo, i 50 Eos con la porta della spesa, solo per oggi (il fondatore, 1
/// ottobre 2026 sera); con la Lunga di oggi gia' comprata il Viandante la
/// sceglie.
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
  final oggi = DateTime(2026, 10, 1, 12, 5);

  test('le voci dell\'Oroscopo prezzate dalla tabella ES.06 stanno nel listino',
      () {
    const prezzate = {
      'oroscopo_lunga_del_giorno': 50,
      'oroscopo_annuale': 300,
      'amico_in_piu': 100,
    };
    final mancanti = <String>[];
    for (final e in prezzate.entries) {
      final voce = ListinoDegliEos.perArte(e.key);
      if (voce == null || voce.costo != e.value) mancanti.add(e.key);
    }
    print('ORDINE EU VOCE 15: voci dell\'Oroscopo con un prezzo nella tabella '
        'ES.06 ma assenti dal listino ${mancanti.length} su ${prezzate.length}');
    expect(mancanti, isEmpty, reason: mancanti.join(', '));
    // **LAPIDE, richieste del fondatore della sera del 1 ottobre 2026**: il
    // nome diceva "La Lunga dell'Oroscopo occidentale del giorno, per la
    // giornata e le quattro schede", e il fondatore ha detto che "la Lunga"
    // chi legge non lo capisce. Resta da pretendere che dica quanto vale
    // (oggi, le quattro schede) e che non usi la parola che non si capisce.
    final nome = ListinoDegliEos.oroscopoLungaDelGiorno.nome;
    expect(nome, contains('di oggi'));
    expect(nome, contains('quattro le schede'));
    expect(nome.toLowerCase(), isNot(contains('lunga')));
    // La Vedica e la Cinese non si comprano con gli Eos.
    expect(
        ListinoDegliEos.tutte.where((v) =>
            v.id.contains('vedic') ||
            v.id.contains('cinese') ||
            v.nome.contains('vedic') ||
            v.nome.contains('cinese')),
        isEmpty);
    // La profondita' del piano resta dei piani a pagamento.
    expect(PlanCatalog.haProfondita(Tier.free), isFalse);
    expect(PlanCatalog.haProfondita(Tier.tier1), isTrue);
  });

  Future<void> monta(WidgetTester tester) async {
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
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.free)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(userSign: Zodiac.gemini, now: oggi),
      ),
    ));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 600));
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> scegliLaLunga(WidgetTester tester) async {
    final selettore = find.byKey(const Key('oroscopo_depth_generale'));
    await tester.ensureVisible(selettore);
    await tester.pump();
    await tester.tap(selettore);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(AnswerDepth.profonda.label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('al Viandante la Lunga offre i 50 Eos e il piano col suo nome',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester);
    await scegliLaLunga(tester);
    expect(find.byKey(const Key('oroscopo_lunga_due_strade')), findsOneWidget,
        reason: 'il lucchetto della Lunga non apre le due strade');
    final costo = tester
        .widget<Text>(find.byKey(const Key('porta_della_spesa_costo')))
        .data!;
    expect(costo, contains('50 Eos'));
    // **LAPIDE, 1 ottobre 2026 sera.** Qui si pretendeva "La Lunga ogni
    // giorno con l'Iniziato". Il fondatore: *"Non chiamarla "la lunga di oggi
    // con l'iniziato", ma "abbonati per avere sempre l'oroscopo completo".
    // L'utente non sa cos'è l'iniziato e "la lunga" ha poco senso [...]
    // bisogna invitare l'utente ad abbonarsi principalmente oppure a spendere
    // eos solo per l'occasione."* Si misura: l'invito all'abbonamento con le
    // sue parole, pieno e in alto; gli Eos col bordo e sotto; nel foglio
    // nessuna parola che chi legge non conosce ("Lunga", i nomi dei piani).
    final invito = find.byKey(const Key('oroscopo_lunga_col_piano'));
    expect(
        find.descendant(
            of: invito,
            matching:
                find.text('Abbonati per avere sempre l\'oroscopo completo')),
        findsOneWidget,
        reason: 'l\'invito non dice le parole del fondatore');
    expect(tester.widget(invito), isA<FilledButton>(),
        reason: 'l\'invito all\'abbonamento non e\' il pulsante principale');
    final eos = find.byKey(const Key('porta_della_spesa_conferma'));
    expect(tester.widget(eos), isA<OutlinedButton>(),
        reason: 'gli Eos sono il pulsante principale, e non l\'abbonamento');
    expect(tester.getRect(invito).top, lessThan(tester.getRect(eos).top),
        reason: 'gli Eos stanno sopra l\'invito all\'abbonamento');
    final foglio = find.byKey(const Key('oroscopo_lunga_due_strade'));
    final parole = [
      for (final e in find
          .descendant(of: foglio, matching: find.byType(Text))
          .evaluate())
        (e.widget as Text).data ?? '',
    ];
    final ignote = [
      for (final p in parole)
        if (p.contains('Lunga') ||
            Tier.values.any((t) => p.contains(PlanCatalog.forTier(t).name)))
          p,
    ];
    print('ORDINE EU VOCE 15: il foglio della Lunga, ${parole.length} scritte, '
        'con "Lunga" o il nome di un piano ${ignote.length}; invito pieno '
        'sopra gli Eos col bordo; "$costo"');
    expect(ignote, isEmpty,
        reason: 'parole che chi legge non conosce nel foglio: $ignote');
    // **NON SI VENDONO PARAGRAFI**, il fondatore la stessa sera: *"Ma dai,
    // elimina che aggiungiamo 2 paragrafi [...] Io penserei: "ma devo
    // spendere soldi per solo 2 paragrafi di merda?"*. Si misura: nessuna
    // scritta del foglio parla di paragrafi; il foglio fa leggere l'inizio
    // vero della parte che la Breve non mostra; dice che cosa porta
    // l'abbonamento, col suo prezzo.
    final paragrafi = [
      for (final p in parole)
        if (p.toLowerCase().contains('paragraf')) p,
    ];
    final anteprima = find.byKey(const Key('oroscopo_lunga_anteprima'));
    final inizio = anteprima.evaluate().isEmpty
        ? ''
        : tester
            .widget<Text>(
                find.descendant(of: anteprima, matching: find.byType(Text)))
            .data!;
    final cosaPorta = tester
        .widget<Text>(find.byKey(const Key('oroscopo_lunga_cosa_porta')))
        .data!;
    print('ORDINE EU, LA SERA: scritte che parlano di paragrafi '
        '${paragrafi.length}; anteprima di ${inizio.length} caratteri; '
        '"$cosaPorta"');
    expect(paragrafi, isEmpty,
        reason: 'il foglio vende ancora paragrafi: $paragrafi');
    expect(inizio.length, greaterThan(60),
        reason: 'il foglio non fa leggere l\'inizio della lettura completa');
    expect(cosaPorta, contains('a settimana'),
        reason: 'il foglio non dice il prezzo dell\'abbonamento');
    // **LA SCRITTA DEL PIANO STA AL CENTRO DEL SUO PULSANTE**, visto sul
    // Realme il 1 ottobre 2026: andava a capo su due righe allineate a
    // sinistra. Si misura il centro di ogni riga contro quello del pulsante.
    final pulsante =
        tester.getRect(find.byKey(const Key('oroscopo_lunga_col_piano')));
    final scritta = find.descendant(
        of: find.byKey(const Key('oroscopo_lunga_col_piano')),
        matching: find.byType(RichText));
    final r = tester.renderObject<RenderParagraph>(scritta);
    final testo = r.text.toPlainText();
    final origine = r.localToGlobal(Offset.zero);
    final righe = <double, Rect>{};
    // Lettera per lettera, senza gli spazi: lo spazio alla fine della prima
    // riga allarga la riga a destra senza che nessuno lo veda.
    for (var k = 0; k < testo.length; k++) {
      if (testo[k] == ' ') continue;
      for (final b in r.getBoxesForSelection(
          TextSelection(baseOffset: k, extentOffset: k + 1))) {
        final rect = b.toRect().shift(origine);
        final chiave = (rect.top / 4).roundToDouble();
        righe[chiave] = righe[chiave]?.expandToInclude(rect) ?? rect;
      }
    }
    final scarti = [
      for (final rr in righe.values) (rr.center.dx - pulsante.center.dx).abs(),
    ];
    print('ORDINE EU VOCE 15: la scritta del piano su ${righe.length} righe, '
        'scarto massimo dal centro del pulsante '
        '${scarti.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}');
    for (final s in scarti) {
      expect(s, lessThan(2.0),
          reason: 'una riga della scritta del piano non sta al centro del '
              'pulsante: scarto $s');
    }
  });

  testWidgets('con la Lunga di oggi gia\' comprata il Viandante la sceglie',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        const {'oroscopo_lunga_comprata_il': '2026-10-01'});
    await monta(tester);
    await scegliLaLunga(tester);
    expect(find.byKey(const Key('oroscopo_lunga_due_strade')), findsNothing);
    expect(
        find.descendant(
            of: find.byKey(const Key('oroscopo_depth_generale')),
            matching: find.text(AnswerDepth.profonda.label)),
        findsOneWidget,
        reason: 'la Lunga comprata oggi non si sceglie');
  });
}
