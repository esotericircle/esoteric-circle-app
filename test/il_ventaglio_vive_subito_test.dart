import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL VENTAGLIO VIVE SUBITO, E IL PULSANTE APRE IL RESPONSO.**
/// Ordine CQ voce 1.03, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"la stesa deve rimanere viva sin
/// dall'inizio, l'utente sceglie le 3 carte e poi il pulsante diventa
/// premibile. Il pulsante consuma la stesa, la scelta no."*
///
/// **La provenienza e' l'ordine CO voce 07**, 3 settembre 2026, cioe' lo
/// stesso giorno. CO.07 nasceva da un difetto vero: la schermata si apriva su
/// un ventaglio di carte coperte e niente diceva che si cominciava toccandone
/// una. La cura pero' aveva messo il pulsante PRIMA delle carte, cioe' faceva
/// premere per ottenere il permesso di scegliere. Il fondatore lo vuole al
/// contrario: **si sceglie subito, e si preme per leggere.**
///
/// **Perche' questa guardia e' di comportamento e non di sorgente.** La
/// guardia di CO.07 leggeva il file e cercava delle righe. Non poteva vedere
/// il difetto che la prima stesura di questa voce ha davvero prodotto: il
/// pulsante era finito DENTRO il blocco `!_complete`, quindi spariva
/// esattamente all'istante in cui doveva accendersi. **Una guardia che legge
/// il sorgente vede cosa e' scritto, non cosa si vede a video**, e qui la
/// differenza era tutta li'.
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

  Future<QuestionAllowance> monta(WidgetTester tester,
      {Tier piano = Tier.tier2}) async {
    silenzia();
    // **LA FINESTRA E' QUELLA DI UN TELEFONO, ALTA.** Con la finestra di
    // prova, 800 per 600, il pulsante finisce fuori campo e il tocco muore
    // senza dire perche'.
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final borsa = QuestionAllowance();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => EntitlementService(initial: piano)),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              key: UniqueKey(),
              seed: 2,
              skipIntro: true,
              topic: TarotTopic.bivio,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return borsa;
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget, reason: 'la carta $indice non e nell arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  /// Quante carte sono posate, lette dalla riga che le conta a video. E' la
  /// stessa cosa che legge la persona: 'Scegli ancora 2' vuol dire una
  /// posata. Sparita la riga, sono tutte e tre.
  int carteACasa(WidgetTester tester) {
    final riga = find.byKey(const Key('stesa_prompt'));
    if (riga.evaluate().isEmpty) return 3;
    final testo = tester.widget<Text>(riga).data ?? '';
    if (testo.contains('ancora 2')) return 1;
    if (testo.contains('ancora 1')) return 2;
    return 0;
  }

  /// **SI ASPETTA CHE LA SCENA SI FERMI PRIMA DI SMONTARLA.** Medora, mentre
  /// pensa, arma dei tempi brevi in catena: smontare l'albero con uno di
  /// quelli ancora in volo fa cadere la prova sull'invariante dei timer, e la
  /// caduta non dice niente di cio' che la prova voleva misurare.
  Future<void> calma(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Il pulsante, e se e' premibile. Nullo se non e' a video.
  bool? pulsantePremibile(WidgetTester tester) {
    final trovato = find.byKey(const Key('stesa_inizia'));
    if (trovato.evaluate().isEmpty) return null;
    return tester.widget<FilledButton>(trovato).onPressed != null;
  }

  testWidgets('senza premere niente, il ventaglio posa la carta',
      (tester) async {
    await monta(tester);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'a schermata appena aperta ci sono gia carte posate');
    await pesca(tester, 38);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'il ventaglio non risponde a chi non ha premuto un pulsante: '
            'e il difetto che l ordine CO voce 07 aveva introdotto e che '
            'questa voce chiude');
  });

  testWidgets('il pulsante c e da subito, spento, e si accende alla terza',
      (tester) async {
    await monta(tester);
    // **C'E' DA SUBITO**: chi arriva vede cosa dovra' premere, e vede anche
    // che adesso non si puo'. E' cio' che CO.07 cercava di ottenere mettendo
    // il pulsante prima, e si ottiene meglio cosi'.
    expect(pulsantePremibile(tester), isFalse,
        reason: 'a zero carte il pulsante non c e, oppure e gia premibile');
    final letti = <int, bool?>{};
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
      letti[carteACasa(tester)] = pulsantePremibile(tester);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.03: carte posate e pulsante premibile $letti');
    cardinaleMinimo(letti.length, 3,
        cosa: 'stati distinti di carte posate osservati',
        perche: 'Se le carte non si posassero, la prova leggerebbe sempre lo '
            'stesso stato e sarebbe verde senza aver visto niente.');
    expect(letti[1], isFalse, reason: 'con una carta il pulsante e premibile');
    expect(letti[2], isFalse, reason: 'con due carte il pulsante e premibile');
    expect(letti[3], isTrue,
        reason: 'con tre carte posate il pulsante non e premibile, oppure non '
            'e piu a video: e il difetto della prima stesura di questa voce, '
            'che lo aveva lasciato dentro il blocco delle carte da pescare');
  });

  testWidgets('scegliere non consuma, premere si', (tester) async {
    final borsa = await monta(tester);
    final partenza = borsa.steseRimaste(Tier.tier2);
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    await tester.pump(const Duration(seconds: 5));
    final dopoLeCarte = borsa.steseRimaste(Tier.tier2);
    await tester.tap(find.byKey(const Key('stesa_inizia')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 8));
    final dopoIlPulsante = borsa.steseRimaste(Tier.tier2);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.03: stese rimaste, alla partenza $partenza, con '
        'tre carte posate $dopoLeCarte, premuto il pulsante $dopoIlPulsante');
    expect(dopoLeCarte, partenza,
        reason: 'tre carte posate hanno gia consumato la stesa: chi ci '
            'ripensa prima di leggere paga per niente');
    expect(dopoIlPulsante, partenza! - 1,
        reason: 'il pulsante non consuma la stesa, oppure ne consuma piu di '
            'una: il conto e per lettura');
    await calma(tester);
  });

  testWidgets('premuto il pulsante, il responso arriva', (tester) async {
    await monta(tester);
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('stesa_synthesis')), findsNothing,
        reason: 'il responso e gia a video con le sole tre carte posate: '
            'allora il pulsante non serve a niente');
    await tester.tap(find.byKey(const Key('stesa_inizia')));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(seconds: 2));
      if (find.byKey(const Key('stesa_synthesis')).evaluate().isNotEmpty) break;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.03: premuto il pulsante, la sintesi a video '
        '${find.byKey(const Key('stesa_synthesis')).evaluate().length}');
    expect(find.byKey(const Key('stesa_synthesis')), findsOneWidget,
        reason: 'premuto il pulsante il responso non arriva: la lettura non '
            'si apre da nessuna parte, e la stesa e stata pagata per niente');
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a responso aperto il pulsante resta acceso: ha gia fatto il '
            'suo lavoro ed e una cosa in piu da capire');
    await calma(tester);
  });
}
