// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/l_annuale.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/amici/l_oroscopo_dell_amico_screen.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA PROFONDITA' STA SU OGNI SCHEDA, E L'AMICO STA IN ALTO.** Ordine ES,
/// 30 settembre 2026, le richieste del fondatore mentre guardava le anteprime
/// e le catture prima della consegna:
///
/// - *"Ogni scheda deve avere sempre il pulsante profondità e la scelta
///   "approfondita" è esclusiva dei premium."* Il pulsante stava solo sulle
///   schede del Giorno: mancava sull'Anno (ordine ES voce 04, che lo aveva
///   tolto di proposito), sulla Settimana e sul Mese (ES.02 ed ES.03) e
///   sull'oroscopo di un amico (ES.12).
/// - *"Nel selettore profondità cambiamo "Approfondita" in Lunga"*.
/// - *"Il pulsante "Oroscopo per un Amico" deve stare in alto e non per
///   ultimo."* Stava in fondo alla pagina (ES.12).
/// - E un difetto visto sul Realme con la build di prova 2289: "Condividi la
///   settimana · +15 Eo", l'etichetta tagliata quando porta il premio (ES.05).
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

  Future<void> monta(
    WidgetTester tester, {
    Tier tier = Tier.tier3,
    double scala = 1.0,
    QuestionAllowance? borsa,
    Size finestra = const Size(360, 2400),
  }) async {
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
    tester.view.physicalSize = finestra;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    final piano = EntitlementService()..setTier(tier);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider.value(value: piano),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
        ChangeNotifierProvider(create: (_) => AmiciOffline()),
        if (borsa != null) ChangeNotifierProvider.value(value: borsa),
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

  Future<void> scegliIlPeriodo(WidgetTester tester, String nome) async {
    await tester.tap(find.byKey(Key('oroscopo_period_$nome')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> scegli(
      WidgetTester tester, Finder selettore, AnswerDepth quale) async {
    await tester.ensureVisible(selettore);
    await tester.pump();
    await tester.tap(selettore);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(quale.label), findsWidgets,
        reason: 'il menu della profondita\' non si e\' aperto');
    await tester.tap(find.text(quale.label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Tutti i testi dentro [dove], in fila.
  String testiDi(WidgetTester tester, Finder dove) => tester
      .widgetList<Text>(find.descendant(of: dove, matching: find.byType(Text)))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .join(' | ');

  test('le voci a video sono Breve e Lunga', () {
    expect(AnswerDepth.shown.map((d) => d.label).toList(), ['Breve', 'Lunga']);
    expect(AnswerDepth.breve.premium, isFalse);
    expect(AnswerDepth.profonda.premium, isTrue,
        reason: 'la Lunga e\' dei piani a pagamento');
  });

  test('l\'Anno: la Lunga dice di piu\' della Breve su ogni scheda', () {
    const segni = [
      'Ariete', 'Toro', 'Gemelli', 'Cancro', 'Leone', 'Vergine', //
      'Bilancia', 'Scorpione', 'Sagittario', 'Capricorno', 'Acquario', 'Pesci',
    ];
    final uguali = <String>[];
    final senzaIlFatto = <String>[];
    var schede = 0;
    final tutte = {for (final d in HoroscopeDomain.values) d: true};
    for (var mese = 1; mese <= 12; mese++) {
      final istante = LaRivoluzioneSolare.ritornoInCorso(
          DateTime.utc(1990, mese, 15, 7), DateTime(2026, 9, 30));
      final tema = LaRivoluzioneSolare.tema(istante, 41.9, 12.5);
      final brevi = LAnnuale.schede(tema, approfondite: const {});
      final lunghe = LAnnuale.schede(tema, approfondite: tutte);
      final intere = LAnnuale.schede(tema);
      for (var i = 0; i < brevi.length; i++) {
        schede++;
        final chi = 'nascita del mese $mese, ${brevi[i].domain.name}';
        if (brevi[i].text == lunghe[i].text ||
            !lunghe[i].text.startsWith(brevi[i].text) ||
            lunghe[i].text.length <= brevi[i].text.length) {
          uguali.add(chi);
        }
        expect(intere[i].text, lunghe[i].text,
            reason: '$chi: senza scelta si legge la lettura intera, come '
                'nel PDF');
        expect(brevi[i].title, lunghe[i].title);
        expect(brevi[i].indicator, lunghe[i].indicator);
      }
      // Il fatto calcolato che la Lunga aggiunge all'Amore e alla Fortuna:
      // il segno e la casa del pianeta al ritorno del Sole. Sta nella riga
      // "Da dove viene", dopo la lettura: il simbolo non apre mai (Linee
      // Guida, sezione 2), e nella lettura non c'e'.
      for (final (dominio, nome, corpo) in const [
        (HoroscopeDomain.amore, 'Venere', CorpoCeleste.venere),
        (HoroscopeDomain.fortuna, 'Giove', CorpoCeleste.giove),
      ]) {
        final segno =
            segni[TemaDellaRivoluzione.segno(tema.longitudini[corpo]!)];
        final attesa = '$nome era in $segno, nella casa ${tema.casaDi(corpo)} '
            'del tuo anno';
        final lunga = lunghe.firstWhere((s) => s.domain == dominio);
        final breve = brevi.firstWhere((s) => s.domain == dominio);
        if (!lunga.rigaDelLivello!.contains(attesa) ||
            breve.rigaDelLivello!.contains(attesa) ||
            lunga.text.contains(attesa)) {
          senzaIlFatto.add('mese $mese, ${dominio.name}: manca "$attesa"');
        }
      }
    }
    cardinaleMinimo(schede, 48, cosa: 'schede dell\'anno');
    print('LA PROFONDITA\' SULL\'ANNO: schede in cui la Lunga non dice di '
        'piu\' della Breve ${uguali.length} su $schede; Amore e Fortuna '
        'senza il segno e la casa del pianeta ${senzaIlFatto.length} su 24');
    expect(uguali, isEmpty, reason: uguali.join('\n'));
    expect(senzaIlFatto, isEmpty, reason: senzaIlFatto.join('\n'));
  });

  testWidgets(
      'l\'Anno a video: il pulsante su ognuna delle quattro schede, e '
      'la scelta cambia il testo', (tester) async {
    await monta(tester);
    await scegliIlPeriodo(tester, 'anno');
    var conIlPulsante = 0;
    // Le schede si cercano scorrendo: con la riga "Da dove viene" sotto ogni
    // lettura la quarta sta oltre la finestra, e la lista pigra non la
    // costruisce finche' non ci si arriva.
    final lista = find.descendant(
        of: find.byKey(const Key('oroscopo_list')),
        matching: find.byType(Scrollable));
    for (final d in HoroscopeDomain.values) {
      final pulsante = find.byKey(Key('oroscopo_depth_${d.name}'));
      await tester.scrollUntilVisible(pulsante, 300, scrollable: lista.first);
      if (pulsante.evaluate().isNotEmpty) conIlPulsante++;
    }
    await tester.scrollUntilVisible(
        find.byKey(const Key('oroscopo_depth_amore')), -300,
        scrollable: lista.first);
    final amore = find.byKey(const Key('oroscopo_card_amore'));
    expect(amore, findsOneWidget);
    final prima = testiDi(tester, amore);
    expect(prima, isNot(contains('Al tuo compleanno Venere')));
    await scegli(tester, find.byKey(const Key('oroscopo_depth_amore')),
        AnswerDepth.profonda);
    final dopo = testiDi(tester, amore);
    print('LA PROFONDITA\' SULL\'ANNO A VIDEO: schede col pulsante '
        '$conIlPulsante su ${HoroscopeDomain.values.length}; scelta la '
        'Lunga il testo dell\'Amore passa da ${prima.length} a '
        '${dopo.length} caratteri');
    expect(conIlPulsante, HoroscopeDomain.values.length);
    expect(dopo, contains('Al tuo compleanno Venere'));
    // Le altre schede restano alla loro profondita'.
    expect(testiDi(tester, find.byKey(const Key('oroscopo_card_fortuna'))),
        isNot(contains('Al tuo compleanno Giove')));
  });

  testWidgets(
      'il Viandante che ha aperto l\'Anno con gli Eos: il pulsante '
      'c\'e\', la Lunga invita al piano', (tester) async {
    final anno = LaRivoluzioneSolare.ritornoInCorso(
            DateTime.utc(1990, 6, 15, 6, 10), DateTime(2026, 9, 30))
        .year;
    SharedPreferences.setMockInitialValues({
      'oroscopo_annuale_aperti': ['$anno'],
    });
    await monta(tester, tier: Tier.free);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await scegliIlPeriodo(tester, 'anno');
    final generale = find.byKey(const Key('oroscopo_card_generale'));
    expect(generale, findsOneWidget,
        reason: 'l\'anno comprato con gli Eos non si e\' aperto: la prova '
            'non misura la profondita\'');
    final prima = testiDi(tester, generale);
    await scegli(tester, find.byKey(const Key('oroscopo_depth_generale')),
        AnswerDepth.profonda);
    expect(testiDi(tester, generale), prima,
        reason: 'il Viandante ha letto la Lunga senza il piano');
    expect(find.textContaining('Cerchio Premium'), findsWidgets,
        reason: 'la voce col lucchetto non porta all\'invito');
  });

  testWidgets(
      'la Settimana e il Mese: il pulsante su ogni scheda, la Breve '
      'senza le righe dei giorni, la Lunga con', (tester) async {
    final esiti = <String>[];
    for (final (nome, righeAttese) in const [('settimana', 7), ('mese', 3)]) {
      await monta(tester);
      await scegliIlPeriodo(tester, nome);
      var conIlPulsante = 0;
      for (final d in HoroscopeDomain.values) {
        if (find
            .byKey(Key('oroscopo_periodo_depth_${d.name}'))
            .evaluate()
            .isNotEmpty) {
          conIlPulsante++;
        }
      }
      Finder righe(String dominio) => find.byWidgetPredicate((w) {
            final k = w.key;
            return k is ValueKey<String> &&
                k.value.startsWith('oroscopo_periodo_riga_${dominio}_');
          });
      final primaAmore = righe('amore').evaluate().length;
      // Nella Breve restano il giorno migliore e il momento chiave.
      final breve =
          testiDi(tester, find.byKey(const Key('oroscopo_periodo_amore')));
      expect(breve, contains('Il giorno migliore'));
      expect(breve, contains('Da dove viene'));
      await scegli(
          tester,
          find.byKey(const Key('oroscopo_periodo_depth_amore')),
          AnswerDepth.profonda);
      final dopoAmore = righe('amore').evaluate().length;
      final dopoFortuna = righe('fortuna').evaluate().length;
      esiti.add('$nome: schede col pulsante $conIlPulsante su 4; righe '
          'dell\'Amore nella Breve $primaAmore, nella Lunga $dopoAmore; '
          'righe della Fortuna, rimasta Breve, $dopoFortuna');
      expect(conIlPulsante, 4, reason: nome);
      expect(primaAmore, 0, reason: nome);
      expect(dopoAmore, righeAttese, reason: nome);
      expect(dopoFortuna, 0, reason: nome);
      await tester.pumpWidget(const SizedBox());
    }
    print('LA PROFONDITA\' SULLA SETTIMANA E SUL MESE: ${esiti.join('; ')}');
  });

  testWidgets(
      'l\'oroscopo di un amico: il pulsante su ogni scheda, e la Lunga '
      'dice di piu\' nelle tre tradizioni', (tester) async {
    tester.view.physicalSize = const Size(360, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
      ],
      child: MaterialApp(
          theme: AppTheme.dark(),
          home: MaestroScope(
              maestro: Maestro.medora,
              child: LOroscopoDellAmicoScreen(
                  amico: Amico(
                      id: 'l',
                      nome: 'Lucia',
                      nascita: DateTime(1990, 1, 12),
                      ora: '08:10'),
                  adesso: DateTime(2026, 9, 30, 12)))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    var misurate = 0;
    final ferme = <String>[];
    var senzaPulsante = 0;
    for (final t in const ['occidentale', 'cinese', 'vedica']) {
      await tester.tap(find.byKey(Key('amico_tradizione_$t')));
      await tester.pump(const Duration(milliseconds: 300));
      for (final d in HoroscopeDomain.values) {
        final scheda = find.byKey(Key('amico_scheda_${d.name}'));
        final pulsante = find.byKey(Key('amico_depth_${d.name}'));
        expect(scheda, findsOneWidget, reason: '$t ${d.name}');
        if (pulsante.evaluate().isEmpty) {
          senzaPulsante++;
          continue;
        }
        final prima = testiDi(tester, scheda);
        await scegli(tester, pulsante, AnswerDepth.profonda);
        final dopo = testiDi(tester, scheda);
        misurate++;
        if (dopo.length <= prima.length) ferme.add('$t ${d.name}');
        // Si torna alla Breve, per la scheda dopo.
        await scegli(tester, pulsante, AnswerDepth.breve);
        expect(testiDi(tester, scheda), prima, reason: '$t ${d.name}');
      }
    }
    cardinaleMinimo(misurate, 12, cosa: 'schede dell\'amico misurate');
    print('LA PROFONDITA\' SULL\'OROSCOPO DI UN AMICO: schede senza il '
        'pulsante $senzaPulsante su 12; schede in cui la Lunga non dice di '
        'piu\' ${ferme.length} su $misurate'
        '${ferme.isEmpty ? '' : ': ${ferme.join(', ')}'}');
    expect(senzaPulsante, 0);
    expect(ferme, isEmpty);
  });

  testWidgets(
      '"L\'oroscopo per un amico" sta nella barra in alto, in ogni '
      'periodo, e apre gli amici', (tester) async {
    final guasti = <String>[];
    var misurati = 0;
    for (final scala in [1.0, 1.3]) {
      await monta(tester, scala: scala, finestra: const Size(360, 800));
      for (final p in HoroscopePeriod.values) {
        await scegliIlPeriodo(tester, p.name);
        final pulsante = find.byKey(const Key('oroscopo_per_un_amico'));
        misurati++;
        final chi = 'scala $scala, ${p.label}';
        if (pulsante.evaluate().length != 1) {
          guasti.add('$chi: pulsanti ${pulsante.evaluate().length}');
          continue;
        }
        final r = tester.getRect(pulsante);
        final barra = tester.getRect(find.byType(AppBar));
        if (r.top < barra.top - 0.5 || r.bottom > barra.bottom + 0.5) {
          guasti.add('$chi: fuori dalla barra (${r.top.round()}-'
              '${r.bottom.round()} contro ${barra.top.round()}-'
              '${barra.bottom.round()})');
        }
        if (r.left < 0 || r.right > 360) guasti.add('$chi: esce di lato');
        // Non copre la freccia ne' i due pulsanti a destra.
        final indietro = tester.getRect(find.byTooltip('Indietro'));
        final fonti = tester.getRect(find.byTooltip('Fonti e metodo'));
        if (r.left < indietro.right - 8 || r.right > fonti.left + 8) {
          guasti.add('$chi: sopra un altro pulsante della barra');
        }
        // Il nome su una riga, e non piu' piccolo di dodici punti a video.
        final nome = find.descendant(
            of: pulsante, matching: find.text('L\'oroscopo per un amico'));
        if (nome.evaluate().isEmpty) {
          guasti.add('$chi: senza il suo nome');
          continue;
        }
        final paragrafo = tester.renderObject<RenderParagraph>(nome);
        final aVideo = tester.getRect(nome).height /
            paragrafo.size.height *
            paragrafo.text.style!.fontSize! *
            scala;
        if (paragrafo.size.height >
            paragrafo.text.style!.fontSize! * scala * 2) {
          guasti.add('$chi: il nome a capo');
        }
        if (aVideo < 12 - 0.05) {
          guasti.add('$chi: nome a ${aVideo.toStringAsFixed(1)} punti');
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
    cardinaleMinimo(misurati, 8, cosa: 'barre misurate');
    print('"L\'OROSCOPO PER UN AMICO" IN ALTO: guasti ${guasti.length} su '
        '$misurati${guasti.isEmpty ? '' : ': ${guasti.join('; ')}'}');
    expect(guasti, isEmpty);

    // E il tocco apre la schermata degli amici.
    await monta(tester, finestra: const Size(360, 800));
    await tester.tap(find.byKey(const Key('oroscopo_per_un_amico')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AmiciScreen), findsOneWidget);
  });

  testWidgets(
      'i pulsanti che condividono un periodo dicono l\'etichetta intera, '
      'anche col premio', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final borsa = QuestionAllowance(porta: _PortaDelPremio());
    await tester.runAsync(borsa.sincronizza);
    final tagliate = <String>[];
    var misurate = 0;
    for (final scala in [1.0, 1.3]) {
      for (final p in [
        HoroscopePeriod.settimana,
        HoroscopePeriod.mese,
        HoroscopePeriod.anno
      ]) {
        // Alta abbastanza perche' la lista costruisca il fondo della pagina.
        await monta(tester,
            scala: scala, borsa: borsa, finestra: const Size(360, 5200));
        await scegliIlPeriodo(tester, p.name);
        final pulsante = find.byKey(Key('oroscopo_condividi_${p.name}'));
        final etichetta =
            find.byKey(Key('oroscopo_condividi_etichetta_${p.name}'));
        expect(pulsante, findsOneWidget, reason: p.label);
        expect(etichetta, findsOneWidget, reason: p.label);
        final testo = tester.widget<Text>(etichetta).data!;
        expect(testo, endsWith('· +15 Eos'),
            reason: 'senza il premio la prova non misura l\'etichetta lunga');
        misurate++;
        final dentro = tester.getRect(pulsante);
        final r = tester.getRect(etichetta);
        final paragrafo = tester.renderObject<RenderParagraph>(etichetta);
        final pittore = TextPainter(
          text: TextSpan(text: testo, style: paragrafo.text.style),
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.linear(scala),
          maxLines: 1,
        )..layout();
        final chi = 'scala $scala, ${p.label}';
        if (paragrafo.size.width < pittore.width - 0.5) {
          tagliate.add('$chi: l\'etichetta ha ${paragrafo.size.width.round()} '
              'punti e ne chiede ${pittore.width.round()}');
        } else if (r.left < dentro.left || r.right > dentro.right) {
          tagliate.add('$chi: esce dal pulsante');
        }
        pittore.dispose();
        await tester.pumpWidget(const SizedBox());
      }
    }
    cardinaleMinimo(misurate, 6, cosa: 'etichette misurate');
    print('ORDINE ES VOCE 05, L\'ETICHETTA COL PREMIO: tagliate o fuori dal '
        'pulsante ${tagliate.length} su $misurate'
        '${tagliate.isEmpty ? '' : ': ${tagliate.join('; ')}'}');
    expect(tagliate, isEmpty);
  });
}

/// Il server che paga quindici Eos per una condivisione.
class _PortaDelPremio extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-09-30',
        'spesi': const {'domande': 0},
        'saldoEos': 300,
        'listinoDellaCondivisione': const {
          'invito_con_download': 60,
          'social_pubblico': 30,
          'condivisione_privata': 15,
          'condivisione_arte': 15,
        },
      });

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      315;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}
