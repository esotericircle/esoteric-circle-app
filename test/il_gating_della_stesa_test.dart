import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL GATING DELLA STESA. Ordine BN voce 09.
///
/// **La premessa dell'ordine era falsa su un punto, e la prova misura il
/// vero.** L'ordine chiedeva "uno al giorno per il Viandante, senza limite
/// dagli altri piani", citando dal Briefing Progetto la frase "una carta di
/// tarocchi al giorno". Quella frase e' la riga `Tarocchi carta singola`. La
/// stesa a tre carte sta sull'ALTRA riga, `Stese complete tarocchi`, perche'
/// il briefing dice "carta singola quotidiana e stese complete, dalla tre
/// carte alla Croce Celtica": la tre carte e' la piu' piccola delle stese
/// complete. Quella riga promette Eos pieno, Eos scontati, cinque al giorno,
/// illimitate. Le due misure dell'ordine che dipendevano dal numero sbagliato
/// (la prima gratis per il Viandante, nessun conto dall'Iniziato) sono qui
/// nella forma che il listino regge davvero, e la sostituzione e' dichiarata.
///
/// Quello che NON cambia e' la macchina: budget proprio, consumo una volta
/// sola a stesa compiuta, conto dichiarato prima, due strade a riserva finita,
/// riscatto che conosce il budget nuovo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  // --- IL DATO: il budget, il conto, il consumo, il riscatto ---

  test('la stesa legge la riga delle stese complete, non la carta singola',
      () {
    // I due numeri che l'ordine confondeva, messi uno accanto all'altro.
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final singola = [
      for (final t in ordine)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaCartaSingola, t)
    ];
    final complete = [
      for (final t in ordine)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, t)
    ];
    expect(singola, [1, 3, null, null],
        reason: 'la riga della carta singola non promette piu\' quello che '
            'il briefing dice del gesto gratis del giorno');
    // **UNA STESA AL GIORNO AL VIANDANTE, ordine BU voce 04**, e la decisione
    // e' del fondatore: "il viandante ha una stesa al giorno". Supera la
    // lettura del listino fatta dall'ordine BN voce 09, che aveva concluso
    // zero. Solo la prima cella cambia: il tre per l'Iniziato non e' scritto
    // da nessuna parte, e quando il numero non c'e' si tiene quello di oggi.
    expect(complete, [1, 4, 7, 20],
        reason: 'la riga delle stese complete non promette piu\' quello che '
            'il fondatore ha deciso: una, quattro, sette e venti, e niente '
            'di illimitato');
    expect(complete, isNot(singola),
        reason: 'se le due righe promettessero la stessa cosa, questa voce '
            'non avrebbe nessun motivo di esistere');

    final borsa = QuestionAllowance();
    for (var i = 0; i < 4; i++) {
      expect(borsa.limiteStese(ordine[i]), complete[i],
          reason: 'il borsellino non legge il limite dal listino');
    }
  });

  test('il consumo e\' uno per stesa, e il conto cala solo quando cala',
      () async {
    final borsa = QuestionAllowance();
    // L'Adepto ha sette stese, ordine BV voce 03, al giorno: e' l'unico piano dove il conto si
    // vede scendere senza passare dagli Eos.
    expect(borsa.steseRimaste(Tier.tier2), 7);
    borsa.registraStesa(Tier.tier2);
    expect(borsa.steseRimaste(Tier.tier2), 6);
    for (var i = 0; i < 6; i++) {
      borsa.registraStesa(Tier.tier2);
    }
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(borsa.puoiStendere(Tier.tier2), isFalse);
  });

  test('l\'Illuminato ha venti stese, e niente e\' piu\' illimitato', () {
    // **L'ILLIMITATO E' SPARITO, ordine BV voce 03**, ed e' un principio del
    // fondatore prima che un numero: non fare nulla di illimitato. Prima
    // l'Illuminato non aveva ne' conto ne' cancello; adesso ha venti stese al
    // giorno e le vede scendere come tutti.
    final borsa = QuestionAllowance();
    expect(borsa.limiteStese(Tier.tier3), 20);
    expect(borsa.steseRimaste(Tier.tier3), 20);
    borsa.registraStesa(Tier.tier3);
    expect(borsa.steseRimaste(Tier.tier3), 19);
    expect(borsa.puoiStendere(Tier.tier3), isTrue);
  });

  test('le stese e le gettate sono due budget che non si toccano', () async {
    // Le due strade nello stesso giorno, sullo stesso Viandante: la stesa la
    // compra con gli Eos, la gettata ce l'ha gratis. Consumarne una non deve
    // togliere l'altra.
    final porta = _PortaDelDenaro(saldoIniziale: 400);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();

    // **LA STESA DEL GIORNO PRIMA, POI GLI EOS.** Ordine BU voce 04: il
    // Viandante ne ha una compresa, e il cancello si apre dopo quella.
    expect(borsa.puoiStendere(Tier.free), isTrue,
        reason: 'il Viandante ha una stesa al giorno, e questa e\' la sua');
    borsa.registraStesa(Tier.free);
    expect(borsa.puoiStendere(Tier.free), isFalse,
        reason: 'finita la stesa del giorno il Viandante le compra');
    expect(await borsa.riscatta('stese'), 150);
    expect(borsa.puoiStendere(Tier.free), isTrue);

    // La gettata di rune del giorno: e' l'altro budget.
    borsa.registraGettata(Tier.free);
    expect(borsa.puoiGettare(Tier.free), isFalse);
    expect(borsa.puoiStendere(Tier.free), isTrue,
        reason: 'la gettata ha mangiato la stesa riscattata: sono finite '
            'sullo stesso contatore');

    // E nell'altro verso: consumare la stesa non ridà né toglie gettate.
    borsa.registraStesa(Tier.free);
    expect(borsa.puoiStendere(Tier.free), isFalse,
        reason: 'il credito comprato non si e\' consumato: sarebbe infinito');
    expect(borsa.puoiGettare(Tier.free), isFalse);
  });

  test('il riscatto della stesa paga il prezzo del server', () async {
    final porta = _PortaDelDenaro(saldoIniziale: 400);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    expect(borsa.prezzoDelRiscatto('stese'), 150,
        reason: 'il prezzo della stesa non arriva piu\' dal listino del '
            'server: una cifra scritta nel client non e\' un prezzo');
    expect(await borsa.riscatta('stese'), 150);
    expect(borsa.saldoEos, 250);
  });

  // --- LA SCENA: il conto detto prima, e le due strade ---

  Widget attorno(Widget scena,
          {required Tier piano, required QuestionAllowance borsa}) =>
      MultiProvider(
        // **LA CHIAVE SUL GUSCIO, e non solo sulla scena.** Rimontando lo
        // stesso albero con un piano diverso, Flutter aggiorna gli elementi
        // gia' vivi invece di crearne di nuovi: il `create` del provider non
        // viene chiamato una seconda volta e il piano resta quello di prima.
        // Trovato eseguendo: la prova leggeva il conto dell'Adepto mentre
        // chiedeva quello dell'Illuminato.
        key: ValueKey(piano),
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
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester,
      {required Tier piano, required QuestionAllowance borsa}) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(
      StesaTreCarteScreen(
        key: UniqueKey(),
        seed: 2,
        skipIntro: true,
        topic: TarotTopic.bivio,
      ),
      piano: piano,
      borsa: borsa,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget, reason: 'la carta $indice non e\' nell\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  String contoAVideo(WidgetTester tester) {
    final conto = find.byKey(const Key('stesa_conto_stese'));
    if (conto.evaluate().isEmpty) return '';
    return tester.widget<Text>(conto).data ?? '';
  }

  testWidgets('il conto e\' quello del listino, e cambia col piano',
      (tester) async {
    await monta(tester, piano: Tier.tier2, borsa: QuestionAllowance());
    expect(contoAVideo(tester), 'Ti restano 7 stese di 7, oggi',
        reason: 'il numero non e\' quello che la matrice promette '
            'all\'Adepto');

    // Stessa schermata, stesso codice, piano diverso: il testo cambia da solo.
    await monta(tester, piano: Tier.tier3, borsa: QuestionAllowance());
    expect(contoAVideo(tester), 'Ti restano 20 stese di 20, oggi',
        reason: 'l\'Illuminato non legge piu\' il suo conto: dall\'ordine BV '
            'voce 03 niente e\' illimitato, quindi anche lui ha un numero');

    await monta(tester, piano: Tier.free, borsa: QuestionAllowance());
    expect(contoAVideo(tester), 'Ti resta 1 stesa di 1, oggi',
        reason: 'il Viandante non legge piu\' la sua stesa del giorno: '
            'ordine BU voce 04');
  });

  testWidgets('il conto si dichiara PRIMA, e sparisce a stesa cominciata',
      (tester) async {
    await monta(tester, piano: Tier.tier2, borsa: QuestionAllowance());
    expect(contoAVideo(tester), isNotEmpty);
    await pesca(tester, 38);
    expect(find.byKey(const Key('stesa_conto_stese')), findsNothing,
        reason: 'a stesa cominciata il conto e\' rumore');
  });

  testWidgets('una stesa compiuta consuma una volta sola, e una abbandonata '
      'non consuma niente', (tester) async {
    final borsa = QuestionAllowance();
    await monta(tester, piano: Tier.tier2, borsa: borsa);
    expect(borsa.steseRimaste(Tier.tier2), 7);

    // Una carta sola: la stesa e' cominciata e non e' compiuta.
    await pesca(tester, 38);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'una stesa cominciata ha gia\' consumato: chi cambia idea '
            'alla prima carta paga per niente');

    // La seconda e la terza: adesso la stesa e' compiuta.
    await pesca(tester, 39);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'la seconda carta ha consumato: il conto e\' per carta e '
            'non per stesa');
    await pesca(tester, 40);
    await tester.pump(const Duration(seconds: 5));
    expect(borsa.steseRimaste(Tier.tier2), 6,
        reason: 'la stesa e\' compiuta e non ha consumato niente: il '
            'listino promette un tetto che nessuno impone');
  });

  testWidgets('a riserva finita il tocco non e\' muto, e nomina le stese',
      (tester) async {
    final borsa = QuestionAllowance();
    await monta(tester, piano: Tier.tier2, borsa: borsa);
    for (var i = 0; i < 7; i++) {
      borsa.registraStesa(Tier.tier2);
    }
    await tester.pump();

    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il ventaglio e\' muto a riserva finita: e\' un vicolo cieco');
    // La carta posata si misura dal BLOCCO delle carte uscite, che esiste
    // solo da una carta in poi: la chiave dello slot c'e' anche quando lo
    // slot e' vuoto, e chiederla direbbe il falso.
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'la carta e\' stata posata lo stesso: il cancello non tiene');

    final testo = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('upgrade_invite')),
            matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    expect(testo.contains('stes'), isTrue,
        reason: 'l\'invito non nomina le stese');
    expect(testo.contains('gettat'), isFalse,
        reason: 'l\'invito nomina le gettate: manderebbe la persona a '
            'cercare il residuo dalla parte sbagliata dell\'app');
  });
  testWidgets('il Viandante ha la sua stesa del giorno, e poi la strada degli '
      'Eos', (tester) async {
    // **PRIMA LA STESA DEL GIORNO, POI IL CANCELLO.** Ordine BU voce 04,
    // decisione del fondatore: "il viandante ha una stesa al giorno". Prima di
    // questo ordine il cancello si apriva al primo tocco, perche' il Viandante
    // aveva zero stese comprese.
    final borsa = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 400));
    await borsa.sincronizza();
    await monta(tester, piano: Tier.free, borsa: borsa);

    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'la PRIMA stesa del giorno chiede gli Eos al Viandante: e\' '
            'quella compresa nel piano');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'la prima stesa del giorno non e\' partita');

    // Consumata quella, il cancello si apre e nomina il prezzo.
    final dopo = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 400));
    await dopo.sincronizza();
    dopo.registraStesa(Tier.free);
    await monta(tester, piano: Tier.free, borsa: dopo);
    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'finita la stesa del giorno il Viandante non trova nessuna '
            'strada: e\' il vicolo cieco che il gating a due strade vieta');
    final riscatta = find.textContaining('Riscatta una stesa completa');
    expect(riscatta, findsOneWidget,
        reason: 'la strada degli Eos non c\'e\', o non dice il prezzo');
    expect(find.textContaining('150 Eos'), findsOneWidget,
        reason: 'il prezzo mostrato non e\' quello del server');

    await tester.tap(riscatta);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'a riscatto avvenuto la stesa non e\' ripartita da sola: '
            'chiede un secondo tocco');
  });

  // --- LE GUARDIE STRUTTURALI ---

  test('la schermata della stesa chiede il permesso, consuma e riscatta', () {
    final s = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    expect(s.contains('puoiStendere('), isTrue,
        reason: 'la stesa non guarda piu\' la riserva prima di cominciare');
    expect(s.contains('registraStesa('), isTrue,
        reason: 'la stesa non consuma piu\' niente');
    expect(s.contains("budget: 'stese'"), isTrue,
        reason: 'la stesa non offre piu\' il riscatto del budget giusto');
    expect(s.contains("budget: 'gettate'"), isFalse,
        reason: 'la stesa riscatta le GETTATE: e\' il budget delle rune');
    // Il numero non si scrive a mano: arriva dal borsellino, che lo legge
    // dalla matrice.
    expect(s.contains('limiteStese('), isTrue);
    expect(s.contains('steseRimaste('), isTrue);
  });

  test('il guscio dell\'app porta il denaro sopra la rotta dei tarocchi', () {
    // La scena tollera l'assenza dei due servizi, perche' anteprime e prove
    // la montano da sola. Questa guardia e' cio' che impedisce a quella
    // tolleranza di diventare un modo per perdere il gating nell'app vera.
    final app = File('lib/app.dart').readAsStringSync();
    expect(app.contains('EntitlementService()'), isTrue,
        reason: 'l\'app non offre piu\' il piano: il gating della stesa '
            'sparirebbe in silenzio');
    expect(app.contains('QuestionAllowance('), isTrue,
        reason: 'l\'app non offre piu\' il borsellino: il gating della stesa '
            'sparirebbe in silenzio');
  });

  test('il server conosce il budget delle stese e il suo prezzo', () {
    final budget = File('functions/src/budget.ts').readAsStringSync();
    expect(budget.contains('stese: [1, 4, 7, 20]'), isTrue,
        reason: 'il server non impone piu\' i limiti del listino');
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    expect(RegExp(r'stese: 150').hasMatch(borsellino), isTrue,
        reason: 'il server non conosce piu\' il prezzo della stesa: senza '
            'prezzo il riscatto non si puo\' nemmeno offrire');
  });

  test('BV.03: il censimento di cio\' che resta illimitato', () {
    // **IL FONDATORE HA CHIESTO IL CONTO, non la cura**: "voglio sapere cosa
    // e' rimasto illimitato". Le stese hanno smesso di esserlo con questa
    // voce; qui si contano le altre righe, si stampano col nome e col piano,
    // e il numero resta scritto. **Non si tocca nessuna di quelle righe**:
    // quanto valgono e' una decisione sua, e questa prova e' il posto dove
    // accorgersi se una nuova nasce senza che nessuno lo dica.
    const piani = ['Viandante', 'Iniziato', 'Adepto', 'Illuminato'];
    final server = File('functions/src/budget.ts').readAsStringSync();
    final righe = RegExp(r'^\s{2}(\w+):\s*\[([^\]]+)\],', multiLine: true)
        .allMatches(server);
    final senzaTetto = <String>[];
    var quanteRighe = 0;
    for (final m in righe) {
      quanteRighe++;
      final nome = m.group(1)!;
      final celle = m.group(2)!.split(',').map((c) => c.trim()).toList();
      for (var i = 0; i < celle.length && i < piani.length; i++) {
        if (celle[i] == 'null') senzaTetto.add('$nome per ${piani[i]}');
      }
    }
    // ignore: avoid_print
    print('ORDINE BV VOCE 3: sul server ci sono $quanteRighe budget, e senza '
        'tetto ne restano ${senzaTetto.length}: $senzaTetto');
    expect(quanteRighe, greaterThanOrEqualTo(6),
        reason: 'il censimento non sta leggendo la mappa dei limiti del '
            'server: ha trovato solo $quanteRighe righe');
    expect(senzaTetto.where((v) => v.startsWith('stese')), isEmpty,
        reason: 'le stese sono tornate illimitate su qualche piano, ed e\' '
            'cio\' che questa voce ha chiuso');
    // Il numero segue il dato, la pretesa no: se domani una riga cambia, il
    // conto va rifatto A VOCE, non allargato in silenzio.
    expect(senzaTetto, const [
      'domande per Illuminato',
      'approfondimenti per Illuminato',
      'confronti per Illuminato',
      'gettate per Iniziato',
      'gettate per Adepto',
      'gettate per Illuminato',
      'sinastrie per Illuminato',
    ],
        reason: 'il censimento degli illimitati e\' cambiato: adesso e\' '
            '$senzaTetto. Va detto al fondatore, non aggiornato di nascosto');

    // E la stessa domanda al listino, che e' cio' che la persona LEGGE.
    final matrice = File('lib/core/entitlement/plan_catalog.dart')
        .readAsStringSync();
    final promesse = RegExp(r"FeatureRow\('([^']+)',\s*\[([^\]]+)\]")
        .allMatches(matrice)
        .where((m) => m.group(2)!.toLowerCase().contains('illimitat'))
        .map((m) => m.group(1)!)
        .toList();
    // ignore: avoid_print
    print('ORDINE BV VOCE 3: nel listino promettono ancora illimitato '
        '${promesse.length} righe: $promesse');
    expect(promesse.where((r) => r.toLowerCase().contains('stese')), isEmpty,
        reason: 'il listino promette ancora stese illimitate: server e '
            'listino direbbero due cose diverse');
  });
}

/// Una porta che risponde come il server vero: listino, saldo, movimenti.
class _PortaDelDenaro extends PortaDelCerchio {
  _PortaDelDenaro({required this.saldoIniziale});

  final int saldoIniziale;
  int _saldo = 0;
  final List<Map<String, Object?>> movimenti = [];

  static const _listino = {
    'domande': 80,
    'approfondimenti': 60,
    'confronti': 150,
    'gettate': 60,
    'stese': 150,
  };

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    _saldo = saldoIniziale;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-25',
      'spesi': const {'domande': 0},
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
