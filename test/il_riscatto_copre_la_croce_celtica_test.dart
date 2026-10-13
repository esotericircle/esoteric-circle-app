import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RISCATTO COMPRA LE CARTE CHE MANCANO A QUESTA STESA.
///
/// **Il difetto.** Nella Croce Celtica, dieci carte, a carte del giorno
/// esaurite "Leggi le carte" apriva il foglio con "Riscatta una stesa
/// completa · 150 Eos". Il riscatto ridà sempre tre carte
/// (`QuestionAllowance.kCarteDelRiscatto`, come `UNITA_DEL_RISCATTO` del
/// server), ma il cancello ne pretende dieci: a riscatto pagato la schermata
/// richiamava la lettura, il cancello sbarrava di nuovo e riapriva lo stesso
/// foglio. Ogni giro scalava 150 Eos e aggiungeva tre carte, e chi pagava
/// non leggeva niente. PROVENIENZA: ordine EX voce 02, che ha cambiato
/// l'unita' del contatore da stese a carte lasciando il riscatto a tre carte,
/// e ordine FQ, che ha aperto la stesa da dieci all'Adepto.
///
/// **La cura** compra in una volta sola, sotto un solo consenso, tanti
/// riscatti quanti ne servono alle carte che mancano a questa stesa, e dice il
/// prezzo vero prima del tocco. Il prezzo unitario e il server non cambiano.
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

  /// Le carte della stesa dal ventaglio, poi "Leggi le carte". La finestra
  /// dell'arco costruisce solo gli indici attorno al centro (dal 32 al 46 a
  /// ventaglio fermo): le dieci carte si prendono dal 34 al 43.
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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('upgrade_invite')).evaluate().isNotEmpty) {
        break;
      }
    }
  }

  /// Tocca il riscatto nel foglio e conferma la spesa. Torna le chiavi dei
  /// messaggi comparsi nel frattempo: una snackbar resta quattro secondi, e
  /// guardarla solo alla fine dell'attesa vorrebbe dire non vederla mai.
  Future<Set<String>> riscattaEConferma(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('invito_riscatto')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    final visti = <String>{};
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      for (final chiave in const [
        'riscatto_fatto',
        'riscatto_interrotto',
        'riscatto_non_basta',
        'riscatto_non_riuscito',
      ]) {
        if (find.byKey(Key(chiave)).evaluate().isNotEmpty) visti.add(chiave);
      }
    }
    return visti;
  }

  // --- IL DATO: quanti riscatti, e il loro prezzo ---

  test(
      'all\'Adepto a carte esaurite la Croce Celtica chiede quattro riscatti, '
      'e quattro la aprono', () async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isFalse);

    // Il difetto, per esteso: UN riscatto ridà tre carte e la stesa da dieci
    // resta chiusa. E' il giro che la schermata faceva senza fine.
    final una = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 1000));
    await una.sincronizza();
    una.registraStesa(Tier.tier2, carte: 10);
    await una.riscatta('stese', consenso: ConsensoDellaSpesa.perLeProve(150));
    expect(una.puoiStendere(Tier.tier2, carte: 10), isFalse,
        reason: 'un riscatto solo basta alla stesa da dieci: allora il '
            'riscatto non ridà piu\' tre carte, e questa prova va riletta');

    final volte = borsa.riscattiPerLaStesa(Tier.tier2, carte: 10);
    final unitario = borsa.prezzoDelRiscatto('stese')!;
    expect(volte, 4,
        reason: 'dieci carte mancanti a tre per riscatto non fanno quattro');
    expect(unitario * volte, 600);
    final esito = await borsa.riscattaPiuVolte('stese',
        volte: volte, consenso: ConsensoDellaSpesa.perLeProve(600));
    expect(esito.fatti, 4);
    expect(esito.pagato, 600);
    expect(porta.movimenti, hasLength(4));
    expect(borsa.saldoEos, 400);
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isTrue,
        reason: 'pagati i riscatti, la Croce Celtica resta chiusa');
  });

  test('le stese da una, tre, quattro e dieci carte, con zero carte rimaste',
      () async {
    final borsa = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 0));
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);
    final unitario = borsa.prezzoDelRiscatto('stese')!;
    final attesi = {1: 1, 3: 1, 4: 2, 10: 4};
    attesi.forEach((carte, volte) {
      expect(borsa.riscattiPerLaStesa(Tier.tier2, carte: carte), volte,
          reason: 'la stesa da $carte carte non chiede $volte riscatti');
    });
    // ignore: avoid_print
    print('IL RISCATTO DELLA STESA, zero carte rimaste: ${[
      for (final c in attesi.keys)
        '$c carte ${borsa.riscattiPerLaStesa(Tier.tier2, carte: c) * unitario} Eos'
    ].join(', ')}');
    // Con le carte che bastano non si riscatta niente.
    final piena = QuestionAllowance();
    expect(piena.riscattiPerLaStesa(Tier.tier2, carte: 10), 0);
    // Restano otto carte: alla stesa da dieci ne mancano due, un riscatto.
    piena.registraStesa(Tier.tier2, carte: 2);
    expect(piena.riscattiPerLaStesa(Tier.tier2, carte: 10), 1);
  });

  test('un consenso che non copre tutti i riscatti non ne fa nessuno',
      () async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    final esito = await borsa.riscattaPiuVolte('stese',
        volte: 4, consenso: ConsensoDellaSpesa.perLeProve(150));
    expect(esito.fatti, 0);
    expect(porta.movimenti, isEmpty,
        reason: 'col consenso a 150 Eos se ne sono spesi di piu\'');
    // E col saldo che non basta per tutti, nemmeno: mai mezza stesa pagata.
    final corta = _PortaDelDenaro(saldoIniziale: 500);
    final povera = QuestionAllowance(porta: corta);
    await povera.sincronizza();
    final niente = await povera.riscattaPiuVolte('stese',
        volte: 4, consenso: ConsensoDellaSpesa.perLeProve(600));
    expect(niente.fatti, 0);
    expect(corta.movimenti, isEmpty);
  });

  // --- LA SCENA: il foglio, la conferma, e niente giro ---

  testWidgets(
      'Croce Celtica a carte esaurite: il foglio dice le dieci carte e il '
      'prezzo di quattro riscatti, un consenso solo, e la lettura si apre',
      (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);
    expect(borsa.steseRimaste(Tier.tier2), 0);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);

    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'a carte esaurite il foglio delle due strade non si apre');
    // Dieci carte mancanti, tre per riscatto: quattro riscatti da 150.
    expect(find.text('Riscatta le 10 carte · 600 Eos'), findsOneWidget,
        reason: 'il pulsante del foglio non dice il vero: promette una '
            'stesa completa al prezzo di un riscatto che ridà tre carte');

    await tester.tap(find.byKey(const Key('invito_riscatto')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
        find.text('Questa richiesta costa 600 Eos. Nel tuo borsellino ce '
            'ne sono 1000.'),
        findsOneWidget,
        reason: 'la conferma non dice il prezzo delle dieci carte');
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(porta.movimenti, hasLength(4),
        reason: 'i riscatti chiesti al server non sono quattro');
    expect(borsa.saldoEos, 400, reason: 'la spesa non e\' di 600 Eos');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: a riscatto pagato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a riscatto pagato la lettura non e\' partita');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');
  });

  testWidgets(
      'se un riscatto a meta\' fallisce, si ferma, lo dice e non riapre il '
      'foglio', (tester) async {
    // Il server risponde ai primi due riscatti e poi tace.
    final porta = _PortaDelDenaro(saldoIniziale: 1000, rispondeA: 2);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    final visti = await riscattaEConferma(tester);

    expect(porta.movimenti, hasLength(3),
        reason: 'dopo il riscatto fallito se ne sono chiesti altri');
    expect(borsa.saldoEos, 700,
        reason: 'pagati due riscatti, il saldo non e\' sceso di 300');
    expect(borsa.steseRimaste(Tier.tier2), 6);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: col riscatto a meta\' si riapre lo stesso foglio');
    expect(visti, contains('riscatto_non_basta'),
        reason: 'a riscatto incompleto nessuno dice che le carte non '
            'bastano ancora');
    expect(visti, isNot(contains('riscatto_fatto')),
        reason: 'un riscatto fermo a meta\' si racconta come compiuto');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'la lettura e\' partita senza le carte');
  });

  testWidgets(
      'la stesa a tre carte resta com\'era: un riscatto, una stesa '
      'completa, 150 Eos', (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);

    await monta(tester,
        tipo: TarotSpreadType.treCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 3);
    expect(find.text('Riscatta una stesa completa · 150 Eos'), findsOneWidget,
        reason: 'la stesa a tre carte ha cambiato il suo riscatto');
    await riscattaEConferma(tester);
    expect(porta.movimenti, hasLength(1));
    expect(borsa.saldoEos, 850);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget);
  });
}

/// Una porta che risponde come il server vero: listino, saldo, movimenti.
/// Con [rispondeA] tace dopo quel numero di movimenti, come un server che
/// cade a meta'.
class _PortaDelDenaro extends PortaDelCerchio {
  _PortaDelDenaro({required this.saldoIniziale, this.rispondeA});

  final int saldoIniziale;
  final int? rispondeA;
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
      'giorno': '2026-10-13',
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
    if (rispondeA != null && movimenti.length > rispondeA!) return null;
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
