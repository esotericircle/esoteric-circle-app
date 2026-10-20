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
///
/// **ORDINE GA VOCE 01, 20 ottobre 2026: il limite torna a contare le
/// stese.** Il fondatore: "bisogna tornare a conteggio per stesa e non per
/// numero di carte". Una stesa vale una stesa qualunque sia il numero delle
/// sue carte, e ogni riscatto ridà UNA stesa
/// (`QuestionAllowance.kSteseDelRiscatto`, come `UNITA_DEL_RISCATTO` e
/// `unita` del server). Il difetto qui sopra non puo' piu' nascere, perche'
/// un riscatto basta sempre alla stesa che si apre: le prove dei riscatti in
/// fila sono riscritte per misurare proprio questo. Il prezzo resta quello
/// di oggi ("Il giro in piu' a Eos dopo l'ultima stesa del giorno resta
/// com'e' oggi"): a stese finite la Croce Celtica si riscatta col riscatto
/// `steseDieci` da 400 Eos, le stese da una, tre e quattro carte col
/// riscatto da 150. Con un server che `steseDieci` non lo manda, anche la
/// Croce Celtica passa dal riscatto da 150.
///
/// **ORDINE GA VOCE 02, 20 ottobre 2026, sera.** Il fondatore: *"Limitiamo
/// la stesa tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo
/// 1 al giorno."* Il riscatto da 400 resta, e vale solo quando le stese del
/// giorno sono finite e la Croce Celtica del giorno e' ancora libera: tutte
/// le prove qui sotto la trovano libera. Fatta quella del giorno la Croce
/// Celtica non si riscatta a nessun prezzo, e lo prova
/// `test/la_croce_celtica_una_al_giorno_test.dart`. L'Adepto ha adesso
/// quattro stese al giorno, e queste prove le contano dal borsellino.
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

  /// Le stese del giorno dell'Adepto tutte fatte: due dall'ordine GA voce
  /// 01, quattro dalla voce GA.02, nessuna a dieci carte. Si conta dal
  /// limite del borsellino e non da un numero scritto qui.
  void finisciLeStese(QuestionAllowance borsa) {
    final quante = borsa.limiteStese(Tier.tier2)!;
    for (var i = 0; i < quante; i++) {
      borsa.registraStesa(Tier.tier2);
    }
    expect(borsa.steseRimaste(Tier.tier2), 0);
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

  /// Dieci secondi di scena dopo la conferma, raccogliendo le chiavi dei
  /// messaggi comparsi: una snackbar resta quattro secondi, e guardarla solo
  /// alla fine dell'attesa vorrebbe dire non vederla mai.
  Future<Set<String>> raccogliIMessaggi(WidgetTester tester) async {
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

  /// Tocca il riscatto nel foglio e conferma la spesa. Torna le chiavi dei
  /// messaggi comparsi nel frattempo.
  Future<Set<String>> riscattaEConferma(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('invito_riscatto')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    return raccogliIMessaggi(tester);
  }

  // --- IL DATO: quanti riscatti, e il loro prezzo ---

  test(
      'IL RISCATTO DELLA STESA A DIECI CARTE: a stese finite la Croce '
      'Celtica si apre con UN riscatto da 400 Eos che ridà una stesa',
      () async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);
    expect(borsa.puoiStendere(Tier.tier2), isFalse);
    expect(borsa.prezzoDelRiscatto('steseDieci'), 400,
        reason: 'il prezzo del riscatto della stesa a dieci non arriva dal '
            'listino');
    final pagato = await borsa.riscatta('steseDieci',
        consenso: ConsensoDellaSpesa.perLeProve(400));
    expect(pagato, 400);
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_steseDieci');
    expect(borsa.saldoEos, 600);
    // Ordine GA voce 01: ridà UNA stesa (dal 14 ottobre ridava dieci carte).
    expect(borsa.steseRimaste(Tier.tier2), 1,
        reason: 'il riscatto della stesa a dieci non ridà una stesa sola');
    expect(borsa.puoiStendere(Tier.tier2), isTrue,
        reason: 'pagati 400 Eos, la Croce Celtica resta chiusa');
    // La Croce Celtica letta consuma la stesa comprata, e il cancello si
    // richiude: il riscatto non ha regalato credito oltre la stesa pagata.
    borsa.registraStesa(Tier.tier2);
    expect(borsa.puoiStendere(Tier.tier2), isFalse,
        reason: 'dopo la stesa comprata ne resta un\'altra: il riscatto ha '
            'ridato piu\' di una stesa');
  });

  test(
      'il server dice 400 Eos e una stesa per il riscatto della stesa a '
      'dieci carte', () {
    // La decisione del fondatore sta nel server, che e' il solo a decidere
    // il prezzo: questa prova legge il listino vero, non quello finto qui
    // sotto, e il numero delle stese deve essere lo stesso dalle due parti.
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    final intero = RegExp(r'steseDieci:\s*\{\s*budget:\s*"stese",\s*'
            r'prezzo:\s*(\d+),\s*unita:\s*(\d+)')
        .firstMatch(borsellino);
    expect(intero, isNotNull,
        reason: 'il server non conosce il riscatto della stesa a dieci');
    expect(int.parse(intero!.group(1)!), 400,
        reason: 'la stesa da dieci non costa i 400 Eos decisi dal fondatore');
    // Ordine GA voce 01: una stesa, come ogni riscatto (erano dieci carte).
    expect(int.parse(intero.group(2)!), QuestionAllowance.kSteseDelRiscatto,
        reason: 'il riscatto della stesa a dieci ridà dalle due parti un '
            'numero diverso di stese');
    expect(int.parse(intero.group(2)!), 1,
        reason: 'il riscatto della stesa a dieci non ridà una stesa');
    final cerchio = File('functions/src/cerchio.ts').readAsStringSync();
    expect(cerchio.contains('listinoDelRiscatto: LISTINO_DEL_RISCATTO'), isTrue,
        reason: 'il listino che il server manda non porta il riscatto intero');
  });

  test(
      'COL SERVER DI PRIMA: all\'Adepto a stese finite la Croce Celtica '
      'chiede UN riscatto da 150, e quello la apre', () async {
    // LAPIDE, 14 ottobre 2026: era la strada di tutti, e' rimasta quella di
    // un server che il riscatto intero non lo manda nel listino.
    //
    // Ordine GA voce 01: dall'ordine EX qui servivano quattro riscatti da
    // tre carte, 600 Eos. Adesso un riscatto ridà una stesa, e basta: il
    // giro senza fine del difetto (un riscatto pagato, la stesa ancora
    // chiusa) e' misurato qui come impossibile.
    final porta = _PortaDelDenaro(saldoIniziale: 1000, serverDiPrima: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);
    expect(borsa.puoiStendere(Tier.tier2), isFalse);

    expect(borsa.riscattiPerLaStesa(Tier.tier2), 1,
        reason: 'a stese finite la Croce Celtica non chiede un riscatto solo');
    expect(borsa.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse,
        reason: 'un server che il riscatto da 400 non lo manda se lo vede '
            'promettere');
    final pagato = await borsa.riscatta('stese',
        consenso: ConsensoDellaSpesa.perLeProve(150));
    expect(pagato, 150);
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_stese');
    expect(borsa.saldoEos, 850);
    expect(borsa.puoiStendere(Tier.tier2), isTrue,
        reason: 'pagato il riscatto la Croce Celtica resta chiusa: e\' il '
            'giro senza fine del difetto');
    expect(borsa.riscattiPerLaStesa(Tier.tier2), 0);
  });

  test('le stese da una, tre, quattro e dieci carte, a stese finite', () async {
    final borsa = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 0));
    await borsa.sincronizza();
    finisciLeStese(borsa);
    final unitario = borsa.prezzoDelRiscatto('stese')!;
    final intero =
        borsa.prezzoDelRiscatto(QuestionAllowance.kRiscattoDellaStesaIntera)!;
    // Ordine GA voce 01: un riscatto solo per qualunque stesa, perche' ogni
    // riscatto ridà una stesa (dall'ordine EX erano 1, 1, 2 e 4 riscatti da
    // tre carte).
    expect(borsa.riscattiPerLaStesa(Tier.tier2), 1,
        reason: 'a stese finite non serve un riscatto solo');
    // LAPIDE, 14 ottobre 2026: la stesa da dieci a stese finite si paga col
    // riscatto della stesa a dieci. Le stese da una, tre e quattro restano
    // col riscatto da 150.
    final intere = {1: false, 3: false, 4: false, 10: true};
    intere.forEach((carte, intera) {
      expect(borsa.laStesaSiRiscattaIntera(Tier.tier2, carte: carte), intera,
          reason: 'la stesa da $carte carte sbaglia il riscatto da 400');
    });
    // ignore: avoid_print
    print('IL RISCATTO DELLA STESA, stese finite: ${[
      for (final c in intere.keys)
        '$c carte ${intere[c]! ? intero : unitario} Eos'
    ].join(', ')}');
    expect(unitario, 150);
    expect(intero, 400);
    // Con le stese che bastano non si riscatta niente.
    final piena = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 0));
    await piena.sincronizza();
    expect(piena.riscattiPerLaStesa(Tier.tier2), 0);
    expect(piena.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse);
    // Resta una stesa: la Croce Celtica la usa, e non si paga niente. Con le
    // carte dell'ordine EX qui mancavano otto carte e si pagava. Ordine GA
    // voce 02: le stese dell'Adepto sono quattro, e si fanno tutte tranne
    // l'ultima, contandole dal borsellino.
    while (piena.steseRimaste(Tier.tier2)! > 1) {
      piena.registraStesa(Tier.tier2);
    }
    expect(piena.steseRimaste(Tier.tier2), 1);
    expect(piena.riscattiPerLaStesa(Tier.tier2), 0,
        reason: 'con una stesa rimasta la Croce Celtica chiede un riscatto');
    expect(piena.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse,
        reason: 'con una stesa rimasta si fanno pagare 400 Eos');
    // Col server di prima il riscatto della stesa a dieci non c'e', e non si
    // offre.
    final vecchia = QuestionAllowance(
        porta: _PortaDelDenaro(saldoIniziale: 0, serverDiPrima: true));
    await vecchia.sincronizza();
    finisciLeStese(vecchia);
    expect(vecchia.laStesaSiRiscattaIntera(Tier.tier2, carte: 10), isFalse);
  });

  test('un consenso che non copre tutti i riscatti non ne fa nessuno',
      () async {
    // Ordine GA voce 01: nessuna stesa chiede piu' di un riscatto, ma la
    // macchina dei riscatti in fila resta nel borsellino, e la sua regola
    // pure: mai spendere oltre il consenso, mai mezzo acquisto.
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
      'Croce Celtica a stese finite: il foglio dice la Croce Celtica a 400 '
      'Eos, un consenso solo, un riscatto, e la lettura si apre',
      (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);

    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'a stese finite il foglio delle due strade non si apre');
    expect(find.text('Riscatta la Croce Celtica · 400 Eos'), findsOneWidget,
        reason: 'il pulsante del foglio non dice il riscatto della stesa a '
            'dieci al prezzo del server');
    // Ordine GA voce 01: col riscatto da 400 nel listino la Croce Celtica non
    // si offre al riscatto da 150 (dall'ordine EX qui si escludevano i
    // quattro riscatti da 150, "Riscatta le 10 carte · 600 Eos").
    expect(find.text('Riscatta una stesa · 150 Eos'), findsNothing,
        reason: 'col riscatto da 400 nel listino la Croce Celtica si offre '
            'al prezzo delle stese piccole');

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
    final visti = await raccogliIMessaggi(tester);

    expect(porta.movimenti, hasLength(1),
        reason: 'i riscatti chiesti al server non sono uno solo');
    expect(porta.movimenti.single['motivo'], 'riscatto_steseDieci');
    expect(borsa.saldoEos, 600, reason: 'la spesa non e\' di 400 Eos');
    expect(visti, contains('riscatto_fatto'),
        reason: 'il riscatto riuscito non si dice');
    expect(visti, isNot(contains('riscatto_non_basta')),
        reason: 'un riscatto pagato non basta alla stesa che si apre: e\' il '
            'giro del difetto');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: a riscatto pagato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');
    // Ordine GA voce 01: la lettura ha consumato la stesa comprata, e ne
    // resta zero. Con le dieci carte del 14 ottobre ne sarebbero rimaste
    // nove.
    expect(borsa.steseRimaste(Tier.tier2), 0,
        reason: 'la Croce Celtica letta non ha consumato la stesa comprata, '
            'o il riscatto ha ridato piu\' di una stesa');
  });

  testWidgets(
      'se il server rifiuta il riscatto della stesa a dieci, lo si dice, '
      'nessun Eos esce e il foglio non si riapre', (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000, rispondeA: 0);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    final visti = await riscattaEConferma(tester);

    expect(porta.movimenti, hasLength(1),
        reason: 'dopo il rifiuto il telefono ha chiesto altri riscatti');
    expect(borsa.saldoEos, 1000);
    expect(borsa.puoiStendere(Tier.tier2), isFalse);
    expect(visti, contains('riscatto_non_riuscito'),
        reason: 'il rifiuto del server non si dice');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: col riscatto rifiutato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing);
  });

  testWidgets(
      'COL SERVER DI PRIMA: il foglio dice una stesa a 150 Eos, un consenso '
      'solo, un riscatto, e la lettura si apre', (tester) async {
    // LAPIDE, 14 ottobre 2026: era la scena di tutti, a 600 Eos; resta per
    // il server che non manda ancora il riscatto della stesa intera.
    //
    // Ordine GA voce 01: un riscatto ridà una stesa, e la Croce Celtica col
    // server di prima costa un riscatto da 150 (dall'ordine EX erano quattro
    // riscatti da tre carte, "Riscatta le 10 carte · 600 Eos").
    final porta = _PortaDelDenaro(saldoIniziale: 1000, serverDiPrima: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);

    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'a stese finite il foglio delle due strade non si apre');
    expect(find.text('Riscatta una stesa · 150 Eos'), findsOneWidget,
        reason: 'il pulsante del foglio non dice il vero: una stesa al prezzo '
            'di un riscatto');
    expect(find.text('Riscatta la Croce Celtica · 400 Eos'), findsNothing,
        reason: 'un server che il riscatto da 400 non lo manda se lo vede '
            'promettere');

    await tester.tap(find.byKey(const Key('invito_riscatto')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
        find.text('Questa richiesta costa 150 Eos. Nel tuo borsellino ce '
            'ne sono 1000.'),
        findsOneWidget,
        reason: 'la conferma non dice il prezzo di un riscatto');
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    final visti = await raccogliIMessaggi(tester);

    expect(porta.movimenti, hasLength(1),
        reason: 'i riscatti chiesti al server non sono uno solo');
    expect(porta.movimenti.single['motivo'], 'riscatto_stese');
    expect(borsa.saldoEos, 850, reason: 'la spesa non e\' di 150 Eos');
    expect(visti, isNot(contains('riscatto_non_basta')),
        reason: 'un riscatto pagato non basta alla Croce Celtica: e\' il '
            'giro del difetto');
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: a riscatto pagato si riapre lo stesso foglio');
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a riscatto pagato la lettura non e\' partita');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');
    expect(borsa.steseRimaste(Tier.tier2), 0,
        reason: 'la lettura non ha consumato la stesa comprata');
  });

  testWidgets(
      'COL SERVER DI PRIMA: se il riscatto fallisce, lo dice, nessun Eos '
      'esce e il foglio non si riapre', (tester) async {
    // Ordine GA voce 01: qui il server rispondeva ai primi due riscatti dei
    // quattro e poi taceva, e la prova pretendeva che i riscatti in fila si
    // fermassero a meta'. Con le stese il riscatto e' uno solo: la pretesa
    // diventa che il riscatto da 150 rifiutato non spenda, lo dica e non si
    // racconti come compiuto.
    final porta =
        _PortaDelDenaro(saldoIniziale: 1000, rispondeA: 0, serverDiPrima: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.dieciCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 10);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    final visti = await riscattaEConferma(tester);

    expect(porta.movimenti, hasLength(1),
        reason: 'dopo il riscatto fallito se ne sono chiesti altri');
    expect(porta.movimenti.single['motivo'], 'riscatto_stese');
    expect(borsa.saldoEos, 1000,
        reason: 'col riscatto rifiutato il saldo e\' sceso');
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'IL GIRO: col riscatto rifiutato si riapre lo stesso foglio');
    expect(visti, contains('riscatto_non_riuscito'),
        reason: 'il rifiuto del server non si dice');
    expect(visti, isNot(contains('riscatto_fatto')),
        reason: 'un riscatto rifiutato si racconta come compiuto');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'la lettura e\' partita senza la stesa');
  });

  testWidgets(
      'la stesa a tre carte resta com\'era: un riscatto, una stesa, 150 Eos',
      (tester) async {
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.treCarte, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 3);
    // Ordine GA voce 01: "una stesa", non piu' "una stesa completa" (tre
    // carte dall'ordine EX).
    expect(find.text('Riscatta una stesa · 150 Eos'), findsOneWidget,
        reason: 'la stesa a tre carte ha cambiato il suo riscatto');
    await riscattaEConferma(tester);
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_stese');
    expect(borsa.saldoEos, 850);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget);
  });

  testWidgets(
      'ORDINE GA VOCE 01: la croce a quattro carte a stese finite si '
      'riscatta con UN riscatto da 150, non col prezzo della stesa a dieci',
      (tester) async {
    // Dall'ordine EX la croce a quattro carte, a carte finite, chiedeva due
    // riscatti da tre carte, 300 Eos. Adesso e' una stesa come le altre: un
    // riscatto da 150, e il riscatto da 400 resta della Croce Celtica.
    final porta = _PortaDelDenaro(saldoIniziale: 1000);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    finisciLeStese(borsa);

    await monta(tester,
        tipo: TarotSpreadType.croceQuattro, piano: Tier.tier2, borsa: borsa);
    await stendiEApri(tester, 4);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'a stese finite il foglio delle due strade non si apre');
    expect(find.text('Riscatta una stesa · 150 Eos'), findsOneWidget,
        reason: 'la croce a quattro carte non si riscatta con un riscatto '
            'da 150');
    expect(find.textContaining('400 Eos'), findsNothing,
        reason: 'la croce a quattro carte si offre al prezzo della stesa a '
            'dieci');
    await riscattaEConferma(tester);
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_stese');
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
