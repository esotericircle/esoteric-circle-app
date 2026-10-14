import 'dart:io';

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
///
/// **LAPIDE, 14 ottobre 2026: la Croce Celtica non costa piu' 600 Eos.** Con
/// la cura qui sopra le dieci carte costavano quattro riscatti da 150. Il
/// fondatore, alla domanda "Prezzo della stesa da 10: oggi 600 Eos (4
/// riscatti da 150). Se la vuoi a 150 fissi serve cambiare il server.", ha
/// risposto alla lettera "2 400 EOS": la stesa da dieci si riscatta con UN
/// riscatto da 400 Eos che ridà le dieci carte. E' un riscatto nuovo del
/// server, `steseDieci` in `RISCATTI_DELLA_STESA_INTERA` di
/// `functions/src/borsellino.ts`, col suo prezzo nel listino che il server
/// manda: il telefono lo legge e non lo scrive. Le prove dei quattro
/// riscatti restano, ma dicono adesso cosa succede con un server che il
/// riscatto nuovo non lo conosce ancora: il telefono ripiega sulla strada
/// di prima, al prezzo che quel server dichiara, e non promette i 400.
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
      'IL RISCATTO DELLA STESA INTERA: la Croce Celtica a carte esaurite si '
      'apre con UN riscatto da 400 Eos che ridà dieci carte', () async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isFalse);
    expect(borsa.prezzoDelRiscatto('steseDieci'), 400,
        reason: 'il prezzo del riscatto intero non arriva dal listino');
    final pagato = await borsa.riscatta('steseDieci',
        consenso: ConsensoDellaSpesa.perLeProve(400));
    expect(pagato, 400);
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_steseDieci');
    expect(borsa.saldoEos, 600);
    expect(borsa.steseRimaste(Tier.tier2), 10,
        reason: 'il riscatto intero non ridà le dieci carte');
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isTrue,
        reason: 'pagati 400 Eos, la Croce Celtica resta chiusa');
  });

  test(
      'il server dice 400 Eos e dieci carte per il riscatto della stesa intera',
      () {
    // La decisione del fondatore sta nel server, che e' il solo a decidere
    // il prezzo: questa prova legge il listino vero, non quello finto qui
    // sotto, e il numero delle carte deve essere lo stesso dalle due parti.
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    final intero = RegExp(r'steseDieci:\s*\{\s*budget:\s*"stese",\s*'
            r'prezzo:\s*(\d+),\s*unita:\s*(\d+)')
        .firstMatch(borsellino);
    expect(intero, isNotNull,
        reason: 'il server non conosce il riscatto della stesa intera');
    expect(int.parse(intero!.group(1)!), 400,
        reason: 'la stesa da dieci non costa i 400 Eos decisi dal fondatore');
    expect(int.parse(intero.group(2)!), 10,
        reason: 'il riscatto intero non ridà dieci carte');
    final cerchio = File('functions/src/cerchio.ts').readAsStringSync();
    expect(cerchio.contains('listinoDelRiscatto: LISTINO_DEL_RISCATTO'), isTrue,
        reason: 'il listino che il server manda non porta il riscatto intero');
  });

  test(
      'COL SERVER DI PRIMA: all\'Adepto a carte esaurite la Croce Celtica '
      'chiede quattro riscatti, e quattro la aprono', () async {
    // LAPIDE, 14 ottobre 2026: era la strada di tutti, e' rimasta quella di
    // un server che il riscatto intero non lo manda nel listino.
    final porta = _PortaDelDenaro(saldoIniziale: 1000, serverDiPrima: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isFalse);

    // Il difetto, per esteso: UN riscatto ridà tre carte e la stesa da dieci
    // resta chiusa. E' il giro che la schermata faceva senza fine.
    final una = QuestionAllowance(
        porta: _PortaDelDenaro(saldoIniziale: 1000, serverDiPrima: true));
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
    // LAPIDE, 14 ottobre 2026: la stesa da dieci a carte esaurite non si
    // paga piu' coi quattro riscatti da tre, ma col riscatto intero. Le
    // stese da una, tre e quattro restano coi riscatti da tre.
    final intere = {1: false, 3: false, 4: false, 10: true};
    intere.forEach((carte, intera) {
      expect(borsa.laStesaSiRiscattaIntera(Tier.tier2, carte: carte), intera,
          reason: 'la stesa da $carte carte sbaglia il riscatto intero');
    });
    final intero =
        borsa.prezzoDelRiscatto(QuestionAllowance.kRiscattoDellaStesaIntera)!;
    // ignore: avoid_print
    print('IL RISCATTO DELLA STESA, zero carte rimaste: ${[
      for (final c in attesi.keys)
        '$c carte ${intere[c]! ? intero : borsa.riscattiPerLaStesa(Tier.tier2, carte: c) * unitario} Eos'
    ].join(', ')}');
    // Con le carte che bastano non si riscatta niente.
    final piena = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 0));
    await piena.sincronizza();
    expect(piena.riscattiPerLaStesa(Tier.tier2, carte: 10), 0);
    expect(piena.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse);
    // Restano otto carte: alla stesa da dieci ne mancano due, un riscatto
    // da 150, che costa meno dei 400 del riscatto intero.
    piena.registraStesa(Tier.tier2, carte: 2);
    expect(piena.riscattiPerLaStesa(Tier.tier2, carte: 10), 1);
    expect(piena.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse,
        reason: 'per due carte mancanti si fanno pagare 400 Eos invece di 150');
    // Restano tre carte: ne mancano sette, tre riscatti da 150 sono 450, e
    // il riscatto intero a 400 costa meno.
    piena.registraStesa(Tier.tier2, carte: 5);
    expect(piena.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isTrue);
    // Col server di prima il riscatto intero non c'e', e non si offre.
    final vecchia = QuestionAllowance(
        porta: _PortaDelDenaro(saldoIniziale: 0, serverDiPrima: true));
    await vecchia.sincronizza();
    vecchia.registraStesa(Tier.tier2, carte: 10);
    expect(vecchia.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse);
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
      'Croce Celtica a carte esaurite: il foglio dice la Croce Celtica a 400 '
      'Eos, un consenso solo, un riscatto, e la lettura si apre',
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
    expect(find.text('Riscatta la Croce Celtica · 400 Eos'), findsOneWidget,
        reason: 'il pulsante del foglio non dice il riscatto della stesa '
            'intera al prezzo del server');
    expect(find.text('Riscatta le 10 carte · 600 Eos'), findsNothing,
        reason: 'col riscatto intero nel listino si offrono ancora i quattro '
            'riscatti da 150');

    await tester.tap(find.byKey(const Key('invito_riscatto')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
        find.text('Questa richiesta costa 400 Eos. Nel tuo borsellino ce '
            'ne sono 1000.'),
        findsOneWidget,
        reason: 'la conferma non dice il prezzo della Croce Celtica');
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(porta.movimenti, hasLength(1),
        reason: 'i riscatti chiesti al server non sono uno solo');
    expect(porta.movimenti.single['motivo'], 'riscatto_steseDieci');
    expect(borsa.saldoEos, 600, reason: 'la spesa non e\' di 400 Eos');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: a riscatto pagato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');
  });

  testWidgets(
      'se il server rifiuta il riscatto della stesa intera, lo si dice, '
      'nessun Eos esce e il foglio non si riapre', (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000, rispondeA: 0);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    borsa.registraStesa(Tier.tier2, carte: 10);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    final visti = await riscattaEConferma(tester);

    expect(porta.movimenti, hasLength(1),
        reason: 'dopo il rifiuto il telefono ha chiesto altri riscatti');
    expect(borsa.saldoEos, 1000);
    expect(borsa.puoiStendere(Tier.tier2, carte: 10), isFalse);
    expect(visti, contains('riscatto_non_riuscito'),
        reason: 'il rifiuto del server non si dice');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: col riscatto rifiutato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing);
  });

  testWidgets(
      'COL SERVER DI PRIMA: il foglio dice le dieci carte e il prezzo di '
      'quattro riscatti, un consenso solo, e la lettura si apre',
      (tester) async {
    // LAPIDE, 14 ottobre 2026: era la scena di tutti, a 600 Eos; resta per
    // il server che non manda ancora il riscatto della stesa intera.
    final porta = _PortaDelDenaro(saldoIniziale: 1000, serverDiPrima: true);
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
      'COL SERVER DI PRIMA: se un riscatto a meta\' fallisce, si ferma, lo '
      'dice e non riapre il foglio', (tester) async {
    // Il server risponde ai primi due riscatti e poi tace. LAPIDE, 14
    // ottobre 2026: i riscatti in fila restano solo col server di prima.
    final porta =
        _PortaDelDenaro(saldoIniziale: 1000, rispondeA: 2, serverDiPrima: true);
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
/// Con [serverDiPrima] il listino e' quello di prima del 14 ottobre 2026,
/// senza il riscatto della stesa intera.
class _PortaDelDenaro extends PortaDelCerchio {
  _PortaDelDenaro(
      {required this.saldoIniziale,
      this.rispondeA,
      this.serverDiPrima = false});

  final int saldoIniziale;
  final int? rispondeA;
  final bool serverDiPrima;
  int _saldo = 0;
  final List<Map<String, Object?>> movimenti = [];

  static const _listinoDiPrima = {
    'domande': 80,
    'approfondimenti': 60,
    'confronti': 150,
    'gettate': 60,
    'stese': 150,
  };

  Map<String, int> get _listino => serverDiPrima
      ? _listinoDiPrima
      : const {..._listinoDiPrima, 'steseDieci': 400};

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
