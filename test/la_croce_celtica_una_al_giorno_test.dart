import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/components/riga_del_residuo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CROCE CELTICA E' UNA AL GIORNO. Ordine GA voce 02.
///
/// **Le parole del fondatore, la sera del 20 ottobre 2026:** *"Limitiamo la
/// stesa tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo 1
/// al giorno."*
///
/// Cosa si pretende, e da dove:
/// - all'Adepto e all'Illuminato, dopo la prima Croce Celtica del giorno la
///   seconda NON si apre, nemmeno con gli Eos: il riscatto non e' offerto, e
///   il server non ha un prezzo per lei (`PREZZI_DEL_RISCATTO` in
///   `functions/src/borsellino.ts`) mentre il suo budget, `steseDaDieci` in
///   `functions/src/budget.ts`, vale uno;
/// - con stese rimaste un'altra stesa (tre carte) si apre ancora: la Croce
///   Celtica fatta non chiude il giorno;
/// - il Viandante e l'Iniziato non la aprono mai;
/// - il server e l'app dicono lo stesso numero: la cella della matrice
///   `Stesa da 10 carte` e il vettore del server.
///
/// Il nome del budget non e' `steseDieci`: quel nome e' il riscatto da 400
/// Eos della Croce Celtica (decisione del fondatore del 14 ottobre 2026), e
/// il server legge ogni motivo `riscatto_<budget>` come il riscatto di quel
/// budget.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const piani = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  // --- I NUMERI: matrice, server, listino ---

  test(
      'il server e l\'app dicono lo stesso numero, uno all\'Adepto e '
      'all\'Illuminato', () {
    final sorgente = File('functions/src/budget.ts').readAsStringSync();
    final blocco = RegExp(r'const LIMITI[^{]*\{(.*?)\n\};', dotAll: true)
        .firstMatch(sorgente);
    expect(blocco, isNotNull,
        reason: 'la tabella dei limiti del server non si trova piu\'');
    final riga =
        RegExp(r'steseDaDieci: \[([^\]]*)\]').firstMatch(blocco!.group(1)!);
    expect(riga, isNotNull,
        reason: 'il server non ha il budget della stesa a dieci carte');
    final server = [
      for (final c in riga!.group(1)!.split(',')) int.parse(c.trim())
    ];
    final matrice = [
      for (final t in piani)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStesaDaDieci, t)
    ];
    // ignore: avoid_print
    print('GA.02 MISURA: stesa a dieci al giorno, server $server, matrice '
        '$matrice');
    expect(server, matrice,
        reason: 'il server e la matrice dicono due numeri diversi per la '
            'stesa a dieci carte');
    expect(matrice, [0, 0, 1, 1],
        reason: 'la stesa a dieci non e\' una al giorno all\'Adepto e '
            'all\'Illuminato, e nessuna al Viandante e all\'Iniziato');
    expect([for (final t in piani) PlanCatalog.haLaStesaDaDieci(t)],
        [false, false, true, true]);
    expect(
        [for (final t in piani) TarotSpreadType.dieciCarte.apribileDa(t)]
            .sublist(0, 2),
        [false, false],
        reason: 'il Viandante o l\'Iniziato aprono la Croce Celtica');
  });

  test('la stesa a dieci carte non ha un prezzo di riscatto sul server', () {
    final budget = File('functions/src/budget.ts').readAsStringSync();
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    // Il listino dei prezzi del riscatto: nessuna voce per la dieci.
    final listino = RegExp(
            r'PREZZI_DEL_RISCATTO: Record<BudgetRiscattabile, number> = \{'
            r'(.*?)\n\};',
            dotAll: true)
        .firstMatch(borsellino);
    expect(listino, isNotNull,
        reason: 'il listino del riscatto non e\' piu\' dei soli budget '
            'riscattabili: un prezzo per la dieci si potrebbe scrivere');
    expect(
        RegExp(r'^\s*steseDaDieci\s*:', multiLine: true)
            .hasMatch(listino!.group(1)!),
        isFalse,
        reason: 'la stesa a dieci ha un prezzo di riscatto: si ricompra');
    // Il budget e' dichiarato senza riscatto, e i riscattabili lo escludono.
    expect(
        budget.contains(
            'BUDGET_SENZA_RISCATTO: readonly Budget[] = ["steseDaDieci"]'),
        isTrue,
        reason: 'il server non dichiara la dieci fra i budget senza riscatto');
    expect(
        budget.contains('BudgetRiscattabile = Exclude<Budget, "steseDaDieci">'),
        isTrue);
    // Il riscatto da 400 resta del budget delle stese, non della dieci.
    expect(RegExp(r'steseDieci:\s*\{\s*budget:\s*"stese"').hasMatch(borsellino),
        isTrue,
        reason: 'il riscatto da 400 non riapre piu\' il budget delle stese');
  });

  // --- IL BORSELLINO: il conto e il riscatto ---

  for (final piano in const [Tier.tier2, Tier.tier3]) {
    test(
        '${piano.name}: dopo la prima Croce Celtica la seconda non si apre, e '
        'una stesa a tre carte si', () async {
      final porta = _PortaDelGiorno(saldoIniziale: 5000);
      final borsa = QuestionAllowance(porta: porta);
      await borsa.sincronizza();
      expect(borsa.steseDaDieciRimaste(piano), 1);
      expect(borsa.laCroceCelticaDiOggiEFatta(piano), isFalse);
      // La prima Croce Celtica del giorno.
      borsa.registraStesa(piano, daDieci: true);
      expect(borsa.steseDaDieciRimaste(piano), 0);
      expect(borsa.laCroceCelticaDiOggiEFatta(piano), isTrue,
          reason: 'dopo la prima Croce Celtica la seconda resta aperta');
      // Con stese rimaste, un'altra stesa si apre ancora.
      expect(borsa.puoiStendere(piano), isTrue,
          reason: 'la Croce Celtica fatta ha chiuso tutte le stese');
      // Finite anche le stese, la Croce Celtica non si riscatta: nessun
      // riscatto da 400 offerto.
      while (borsa.puoiStendere(piano)) {
        borsa.registraStesa(piano);
      }
      expect(borsa.laStesaSiRiscattaIntera(piano, carte: 10), isFalse,
          reason: 'fatta la Croce Celtica del giorno si offre il riscatto da '
              '400, che la riaprirebbe');
      // Anche comprando una stesa col riscatto di sempre la Croce Celtica
      // resta chiusa: il credito comprato e' delle stese, non della dieci.
      expect(
          await borsa.riscatta('stese',
              consenso: ConsensoDellaSpesa.perLeProve(150)),
          150);
      expect(borsa.puoiStendere(piano), isTrue);
      expect(borsa.laCroceCelticaDiOggiEFatta(piano), isTrue,
          reason: 'il riscatto di una stesa ha riaperto la Croce Celtica');
      expect(borsa.prezzoDelRiscatto(QuestionAllowance.kSteseDaDieci), isNull,
          reason: 'il listino del server porta un prezzo per la dieci');
    });
  }

  test(
      'il riscatto da 400 resta, ma solo con la Croce Celtica del giorno '
      'ancora libera', () async {
    final borsa = QuestionAllowance(porta: _PortaDelGiorno(saldoIniziale: 0));
    await borsa.sincronizza();
    while (borsa.puoiStendere(Tier.tier2)) {
      borsa.registraStesa(Tier.tier2);
    }
    expect(borsa.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isTrue,
        reason: 'a stese finite e Croce Celtica libera il riscatto da 400 '
            'non c\'e\' piu\'');
    expect(borsa.laStesaSiRiscattaIntera(Tier.tier2, carte: 3), isFalse);
  });

  test('il Viandante e l\'Iniziato non la aprono mai, e non e\' "fatta"',
      () async {
    final borsa = QuestionAllowance(porta: _PortaDelGiorno(saldoIniziale: 0));
    await borsa.sincronizza();
    for (final piano in const [Tier.free, Tier.tier1]) {
      expect(borsa.limiteStesaDaDieci(piano), 0);
      expect(borsa.steseDaDieciRimaste(piano), 0);
      // A chi non ce l'ha nel piano si dice da quale piano si apre, non che
      // e' gia' stata fatta oggi.
      expect(borsa.laCroceCelticaDiOggiEFatta(piano), isFalse);
      expect(borsa.laStesaSiRiscattaIntera(piano, carte: 10), isFalse);
    }
  });

  test('il conto del server vince, e la dieci si manda solo a chi la conosce',
      () async {
    // Un server che la conosce e l'ha gia' contata oggi.
    final nuovo =
        _PortaDelGiorno(saldoIniziale: 0, conosceLaDieci: true, dieciSpese: 1);
    final borsa = QuestionAllowance(porta: nuovo);
    await borsa.sincronizza();
    expect(borsa.laCroceCelticaDiOggiEFatta(Tier.tier2), isTrue,
        reason: 'il telefono non legge la Croce Celtica gia\' contata dal '
            'server');
    // Un server nuovo, a giornata intatta: la Croce Celtica gli si manda.
    final intatto = _PortaDelGiorno(saldoIniziale: 0, conosceLaDieci: true);
    final conta = QuestionAllowance(porta: intatto);
    await conta.sincronizza();
    conta.registraStesa(Tier.tier2, daDieci: true);
    await Future<void>.delayed(Duration.zero);
    expect(intatto.consumi, containsAllInOrder(['stese', 'steseDaDieci']),
        reason: 'la Croce Celtica non arriva al server che la conosce');
    // Un server di prima, che non la conosce: le si manda solo la stesa, o
    // la coda dei gesti si fermerebbe su un budget sconosciuto.
    final vecchio = _PortaDelGiorno(saldoIniziale: 0);
    final locale = QuestionAllowance(porta: vecchio);
    await locale.sincronizza();
    locale.registraStesa(Tier.tier2, daDieci: true);
    await Future<void>.delayed(Duration.zero);
    expect(vecchio.consumi, isNot(contains('steseDaDieci')),
        reason: 'la dieci parte verso un server che non la conosce');
    expect(locale.laCroceCelticaDiOggiEFatta(Tier.tier2), isTrue,
        reason: 'senza il server nuovo il telefono non tiene il conto');
  });

  // --- LA SCENA: l'invito, il residuo, il selettore ---

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

  Future<void> monta(WidgetTester tester,
      {required TarotSpreadType tipo,
      required Tier piano,
      required QuestionAllowance borsa}) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: piano)),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: 2,
              skipIntro: true,
              topic: TarotTopic.bivio,
              tipo: tipo,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  /// Le carte della stesa dal ventaglio, poi "Leggi le carte" (come
  /// `il_riscatto_copre_la_croce_celtica_test.dart`).
  Future<void> stendiEApri(WidgetTester tester, int quante) async {
    for (var k = 0; k < quante; k++) {
      final carta = find.byKey(Key('stesa_fan_${34 + k}'));
      expect(carta, findsOneWidget,
          reason: 'la carta ${34 + k} non e\' nell\'arco');
      final r = tester.getRect(carta);
      await tester.tapAt(Offset(r.left + 6, r.center.dy));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
    }
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.tap(pulsante, warnIfMissed: false);
    await tester.pump();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      if (find.byKey(const Key('upgrade_invite')).evaluate().isNotEmpty ||
          find.byKey(const Key('stesa_blocco_carte')).evaluate().isNotEmpty) {
        break;
      }
    }
  }

  /// Lascia finire la scena del responso: Medora che pensa tiene dei timer,
  /// e una prova che finisce prima li lascia pendenti.
  Future<void> lasciaFinire(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  String testoDellInvito(WidgetTester tester) => tester
      .widgetList<Text>(find.descendant(
          of: find.byKey(const Key('upgrade_invite')),
          matching: find.byType(Text)))
      .map((t) => t.data ?? '')
      .join(' ');

  testWidgets(
      'Adepto, Croce Celtica gia\' fatta: il foglio dice che torna domani, '
      'nessun riscatto, e manda a un\'altra stesa', (tester) async {
    final porta = _PortaDelGiorno(saldoIniziale: 5000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, daDieci: true);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    // Prima della prima carta il residuo della dieci lo dice gia'.
    final riga =
        find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.steseDaDieci));
    expect(riga, findsOneWidget,
        reason: 'prima del gesto non si dice se la Croce Celtica del giorno '
            'e\' libera');
    expect(
        find.descendant(
            of: riga,
            matching:
                find.text('Non ti resta nessuna stesa a dieci carte, oggi')),
        findsOneWidget);

    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'la seconda Croce Celtica del giorno si apre');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'la seconda Croce Celtica del giorno ha aperto il responso');
    expect(find.byKey(const Key('invito_riscatto')), findsNothing,
        reason: 'la Croce Celtica fatta si offre al riscatto con gli Eos');
    final testo = testoDellInvito(tester);
    // ignore: avoid_print
    print('GA.02 L\'INVITO: $testo');
    expect(testo, contains('La Croce Celtica di oggi è stata fatta'));
    expect(testo, contains('una al giorno'));
    expect(testo, contains('torna domani'));
    expect(testo, contains('un’altra stesa'));
    // Le stese che restano, col numero del borsellino: tre su quattro.
    expect(testo, contains('Ti restano 3 stese su 4, oggi.'),
        reason: 'l\'invito non dice quante stese restano per un\'altra stesa');
    expect(testo, isNot(contains('Eos')),
        reason: 'con stese rimaste l\'invito parla di Eos');
    expect(porta.movimenti, isEmpty, reason: 'si e\' speso qualcosa');
    expect(borsa.steseRimaste(Tier.tier2), 3,
        reason: 'la Croce Celtica rifiutata ha consumato una stesa');
  });

  testWidgets(
      'Illuminato, Croce Celtica fatta e stese finite: nessun riscatto per '
      'lei, e la strada degli Eos e\' quella di un\'altra stesa',
      (tester) async {
    final porta = _PortaDelGiorno(saldoIniziale: 5000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier3, daDieci: true);
    while (borsa.puoiStendere(Tier.tier3)) {
      borsa.registraStesa(Tier.tier3);
    }

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier3, borsa: borsa);
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    expect(find.byKey(const Key('invito_riscatto')), findsNothing,
        reason: 'fatta la Croce Celtica del giorno si offre un riscatto');
    expect(find.textContaining('400 Eos'), findsNothing,
        reason: 'si offre il riscatto da 400 della Croce Celtica');
    final testo = testoDellInvito(tester);
    expect(testo, contains('torna domani'));
    expect(testo, contains('un’altra stesa si riscatta con gli Eos'));
    expect(porta.movimenti, isEmpty);
  });

  testWidgets(
      'con la Croce Celtica fatta e stese rimaste, una stesa a tre carte si '
      'apre', (tester) async {
    final borsa = QuestionAllowance(porta: _PortaDelGiorno(saldoIniziale: 0));
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, daDieci: true);
    await monta(tester,
        tipo: TarotSpreadType.treCarte, piano: Tier.tier2, borsa: borsa);
    // Sulla stesa a tre carte la riga della dieci non c'e': non la si sta
    // scegliendo.
    expect(find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.steseDaDieci)),
        findsNothing);
    await stendiEApri(tester, 3);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'la Croce Celtica fatta ha chiuso anche le altre stese');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'la stesa a tre carte non si e\' aperta');
    expect(borsa.steseRimaste(Tier.tier2), 2);
    expect(borsa.steseDaDieciRimaste(Tier.tier2), 0);
    await lasciaFinire(tester);
  });

  testWidgets(
      'la Croce Celtica libera si apre una volta e consuma anche la dieci',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaDelGiorno(saldoIniziale: 0));
    await borsa.sincronizza();
    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    expect(
        find.descendant(
            of: find
                .byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.steseDaDieci)),
            matching: find.text('Oggi hai 1 stesa a dieci carte')),
        findsOneWidget,
        reason: 'prima del gesto non si dice che la Croce Celtica e\' libera');
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget);
    expect(borsa.steseRimaste(Tier.tier2), 3);
    expect(borsa.laCroceCelticaDiOggiEFatta(Tier.tier2), isTrue,
        reason: 'la Croce Celtica letta non ha consumato quella del giorno');
    await lasciaFinire(tester);
  });

  testWidgets('il selettore dice "Fatta oggi" accanto alla Croce Celtica',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaDelGiorno(saldoIniziale: 0));
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, daDieci: true);
    await monta(tester,
        tipo: TarotSpreadType.treCarte, piano: Tier.tier2, borsa: borsa);
    await tester.tap(find.byKey(const Key('stesa_setup_riga')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('stesa_tipo')));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(TarotSetupPanel.fattaOggi), findsOneWidget,
        reason: 'il selettore non dice che la Croce Celtica e\' fatta oggi');
    // Il tocco sulla Croce Celtica chiusa dice che torna domani, e non che
    // e' dell'Adepto.
    // La tendina si apre fuori dalla finestra della prova (la sua voce sta a
    // x negativa): si chiude toccando la barriera, e la scelta si fa con la
    // stessa callback che il tocco sulla voce chiamerebbe, `onSelected`
    // della tendina vera, che passa da `bloccata` e da `onLocked`.
    await tester.tapAt(const Offset(350, 10));
    await tester.pump(const Duration(milliseconds: 500));
    tester
        .widget<PopupMenuButton<TarotSpreadType>>(
            find.byKey(const Key('stesa_tipo')))
        .onSelected!(TarotSpreadType.dieciCarte);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.byKey(const Key('upgrade_invite')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il tocco sulla Croce Celtica fatta oggi non spiega niente');
    final testo = testoDellInvito(tester);
    expect(testo, contains('torna domani'));
    expect(testo, isNot(contains('è dell’Adepto')));
  });
}

/// Una porta che risponde come il server: il giorno, il listino del riscatto
/// (col riscatto da 400 della Croce Celtica, mai un prezzo per la dieci), il
/// saldo e i consumi. Con [conosceLaDieci] lo stato porta `resta` con il
/// budget `steseDaDieci`, come il server nuovo; senza, e' il server di prima.
class _PortaDelGiorno extends PortaDelCerchio {
  _PortaDelGiorno(
      {required this.saldoIniziale,
      this.conosceLaDieci = false,
      this.dieciSpese = 0});

  final int saldoIniziale;
  final bool conosceLaDieci;
  final int dieciSpese;
  int _saldo = 0;
  final List<Map<String, Object?>> movimenti = [];
  final List<String> consumi = [];

  static const _listino = {
    'domande': 80,
    'approfondimenti': 60,
    'confronti': 150,
    'gettate': 60,
    'stese': 150,
    'steseDieci': 400,
  };

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    _saldo = saldoIniziale;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-10-20',
      'spesi': {
        'domande': 0,
        if (conosceLaDieci) 'steseDaDieci': dieciSpese,
      },
      if (conosceLaDieci)
        'resta': {'domande': 3, 'stese': 4, 'steseDaDieci': 1 - dieciSpese},
      'saldoEos': saldoIniziale,
      'listinoDelRiscatto': _listino,
    });
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    movimenti.add({'causale': causale, 'motivo': motivo, 'id': idMovimento});
    _saldo -= _listino[motivo.replaceFirst('riscatto_', '')] ?? 0;
    return _saldo;
  }

  @override
  Future<EsitoDelConsumo?> consuma(
      {required String budget, required String idMovimento}) async {
    consumi.add(budget);
    return const EsitoDelConsumo(concesso: true);
  }

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
