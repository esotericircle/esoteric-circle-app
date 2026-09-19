import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
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

/// **IL SUONO DELLA CARTA ESCE DALLA STESA VERA.** Ordine CQ voce 6.08,
/// 4 settembre 2026.
///
/// **Parole del fondatore, ed e' la terza volta che lo segnala**: *"Nei
/// tarocchi il suono effetto della carta NON C'E'!"*
///
/// **Perche' la guardia che c'era non lo vedeva.** `la_carta_girata_suona`
/// chiama `sensi.momento(contesto, flip)` **direttamente**, con un contesto
/// costruito apposta, e pretende che la porta del Cerchio riceva il suono
/// della carta. E' vero, e resta vero: dimostra che `SensiDellaStesa`
/// consegna il momento alla porta. **Non dimostra che toccare una carta nella
/// stesa faccia partire quel momento**, che e' cio' che la persona fa.
///
/// E' la stessa famiglia di cecita' che l'ordine CN aveva gia' incontrato qui:
/// allora la risposta giusta veniva consegnata a un lettore vuoto, adesso la
/// consegna e' giusta e nessuno la misurava dal lato del gesto. **Ogni volta
/// il pezzo sorvegliato era sano e quello accanto no.**
///
/// **La grandezza nuova**: si monta la stesa, si tocca una carta del ventaglio
/// come la tocca una persona, e si guarda la spia della porta unica.
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

  final sentiti = <SuonoDelCerchio>[];

  Future<QuestionAllowance> monta(WidgetTester tester,
      {Tier piano = Tier.tier2}) async {
    silenzia();
    // **LA SPIA STA SULLA PORTA UNICA DEL CERCHIO**, cioe' sul punto da cui
    // ogni suono dell'app esce davvero: una spia piu' vicina al gesto
    // direbbe che il gesto e' partito, che e' esattamente cio' che la
    // guardia cieca gia' diceva.
    sentiti.clear();
    PaletteSensoriale.spia = sentiti.add;
    addTearDown(() => PaletteSensoriale.spia = null);
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
        // **LE IMPOSTAZIONI SERVONO O IL SUONO NON ESCE E BASTA.** Il
        // permesso del suono ripiega su falso quando il controller non
        // c'e', quindi senza questa riga la prova misurerebbe un albero
        // muto per costruzione.
        ChangeNotifierProvider(create: (_) => SettingsController()),
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



  testWidgets('toccare una carta del ventaglio fa uscire il suono della carta',
      (tester) async {
    await monta(tester);
    await pesca(tester, 38);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.08: carte posate ${carteACasa(tester)}, suoni '
        'usciti dalla porta del Cerchio $sentiti');
    cardinaleMinimo(carteACasa(tester), 1,
        cosa: 'carte posate dal tocco della prova',
        perche: 'Se il tocco non posasse niente, la prova direbbe che il '
            'suono non esce mentre il gesto non e mai avvenuto, e curerei '
            'la cosa sbagliata.');
    expect(sentiti, contains(SuonoDelCerchio.carta),
        reason: 'toccando una carta del ventaglio nessun suono di carta esce '
            'dalla porta unica del Cerchio: il gesto della persona non arriva '
            'al suono, e nessuna guardia se ne accorgeva perche tutte '
            'chiamavano il momento invece di toccare una carta');
    await calma(tester);
  });

  testWidgets('e ne esce uno per carta, non uno solo per tutta la stesa',
      (tester) async {
    await monta(tester);
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    final quanti = sentiti.where((s) => s == SuonoDelCerchio.carta).length;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.08: carte posate ${carteACasa(tester)}, suoni di '
        'carta usciti $quanti');
    cardinaleMinimo(carteACasa(tester), 3,
        cosa: 'carte posate dai tre tocchi della prova',
        perche: 'Con meno di tre carte il conto dei suoni non dice niente.');
    expect(quanti, 3,
        reason: 'su tre carte scelte sono usciti $quanti suoni di carta: ogni '
            'carta che si posa si deve sentire, e un suono solo per tutta la '
            'stesa sarebbe il difetto con un altro nome');
    await calma(tester);
  });

  testWidgets('e nessun altro suono le parte addosso nello stesso istante',
      (tester) async {
    // **E' QUI CHE IL SUONO MORIVA, e la misura lo dice col numero.** Il
    // lettore degli effetti e' UNO SOLO e ogni suono ferma quello prima.
    // `_pesca` chiamava il flip e nella riga dopo la fioritura, che chiama il
    // reveal: due suoni sullo stesso lettore nello stesso fotogramma, e la
    // carta durava zero millesimi su settecento trenta.
    //
    // **Le guardie di prima non potevano vederlo**: dalla porta del Cerchio
    // uscivano tutti e due i suoni, come dovevano, e nessuna guardava cosa
    // succede al primo quando arriva il secondo.
    await monta(tester);
    await pesca(tester, 38);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.08: sul gesto di posare una carta escono $sentiti');
    cardinaleMinimo(carteACasa(tester), 1,
        cosa: 'carte posate dal tocco della prova',
        perche: 'Senza il gesto la lista dei suoni sarebbe vuota, e vuota '
            'passerebbe questa pretesa senza aver misurato niente.');
    expect(sentiti, [SuonoDelCerchio.carta],
        reason: 'posando una carta esce piu di un suono, $sentiti: il lettore '
            'e uno solo e il secondo ferma il primo, quindi la carta si sente '
            'per zero millesimi');
    await calma(tester);
  });
}
