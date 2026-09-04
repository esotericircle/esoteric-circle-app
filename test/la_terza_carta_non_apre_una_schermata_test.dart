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

/// **LA TERZA CARTA NON APRE UNA SCHERMATA NUOVA.** Ordine CQ voce 6.09,
/// 4 settembre 2026.
///
/// **Parole del fondatore**: *"appena inserisco la terza carta, si apre una
/// nuova schermata con le 3 carte e il bottone 'LEGGI IL RESPONSO'. ELIMINA
/// QUESTA SCHERMATA in piu'! il pulsante deve gia' essere presente nella
/// schermata principale della funzionalita'."*
///
/// **Non si apriva nessuna schermata, ed e' la parte che rende questa voce
/// istruttiva.** Alla terza carta `_complete` diventa vero, e sparivano in
/// blocco il pannello della configurazione, gli slot, il blocco delle carte,
/// il ventaglio e il prompt, mentre il ritratto di Medora saliva da
/// centosettanta punti a trecento. Di tutta la pagina restavano un ritratto
/// grande e un pulsante. **A chi guarda, quello e' un'altra schermata**, e
/// discutere se lo sia davvero non serve a niente: il fondatore descrive cosa
/// vede, e cio' che vede era giusto.
///
/// **Perche' la guardia della voce CQ 1.03 non lo aveva visto.** Quella
/// misura che il pulsante ci sia da subito, spento, e si accenda alla terza
/// carta: e' vero, ed e' restato vero mentre tutto il resto spariva. **Una
/// guardia che sorveglia un widget non vede cosa succede agli altri.**
///
/// **La grandezza nuova**: cosa sopravvive alla terza carta.
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


  testWidgets('alla terza carta la pagina non si svuota', (tester) async {
    await monta(tester);
    // Gli indici sono quelli che la guardia della voce 1.03 usa gia: le
    // carte in cima all arco sono le sole raggiungibili dal tocco, e
    // sceglierne altre fa morire il tocco senza dire perche.
    await pesca(tester, 38);
    await pesca(tester, 39);
    await pesca(tester, 40);

    final scelte = find.byKey(const Key('stesa_blocco_carte_scelte'));
    final pulsante = find.byKey(const Key('stesa_inizia'));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.09: carte a casa ${carteACasa(tester)}, il blocco '
        'delle carte scelte c e ${scelte.evaluate().isNotEmpty}, il pulsante '
        'c e ${pulsante.evaluate().isNotEmpty}');
    expect(carteACasa(tester), 3,
        reason: 'la prova non e arrivata alla terza carta, quindi non sta '
            'misurando cosa succede alla terza carta');
    expect(scelte, findsOneWidget,
        reason: 'dopo la terza carta le carte scelte non si vedono piu: la '
            'pagina si e svuotata, e a chi guarda quella e una schermata '
            'nuova con dentro solo un ritratto e un pulsante');
    expect(pulsante, findsOneWidget,
        reason: 'il pulsante non e nella schermata principale');
    await calma(tester);
  });

  testWidgets('e il pulsante dice Leggi le Carte', (tester) async {
    await monta(tester);
    // **LE PAROLE SONO QUELLE DEL FONDATORE**, e la differenza non e'
    // cosmetica: "Leggi il responso" nomina il risultato, "Leggi le Carte"
    // nomina il gesto sulle carte che hai scelto tu.
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.09: il pulsante dice Leggi le Carte '
        '${find.text('Leggi le Carte').evaluate().isNotEmpty}');
    expect(find.text('Leggi le Carte'), findsOneWidget,
        reason: 'il pulsante non dice piu Leggi le Carte');
    expect(find.text('Leggi il responso'), findsNothing,
        reason: 'la vecchia etichetta e tornata');
    await calma(tester);
  });
}
