import 'package:esoteric_circle/core/astro/lingua_degli_eventi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/features/calendario/calendario_degli_eventi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CALENDARIO DEGLI EVENTI. Ordine AN voce 03.
///
/// Si apre dal centro della barra e dice cosa fara' il cielo nei prossimi
/// mesi. Le pretese: solo eventi con una data VERA calcolata, ordine
/// cronologico, i tuoi appuntamenti solo quando l'identita' li rende veri, e
/// senza identita' nessun vicolo cieco ma un invito con un pulsante che
/// porta davvero da qualche parte.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  Future<void> apri(WidgetTester tester,
      {Zodiac? segno, NatalChart? carta}) async {
    silenzia();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final carte = NatalChartController();
    if (carta != null) carte.chart = carta;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController(sunSign: segno)),
        ChangeNotifierProvider<NatalChartController>.value(value: carte),
      ],
      child: MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) =>
              CalendarioDegliEventiScreen.route(adesso: DateTime(2026, 8, 18)),
        ),
      ),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('mostra gli eventi di tutti, in ordine cronologico e con le '
      'date vere', (tester) async {
    await apri(tester);
    expect(find.byKey(const Key('calendario_degli_eventi')), findsOneWidget);

    // Le voci mostrate vengono dal motore: si confrontano con lui, non con
    // una lista scritta a mano nella prova.
    final attesi = ProssimiEventi.da(adesso: DateTime(2026, 8, 18))
        .where((e) =>
            e.fraQuantiGiorni <= CalendarioDegliEventiScreen.orizzonteComune)
        .toList();
    expect(attesi, isNotEmpty,
        reason: 'entro tre mesi il cielo fa sempre qualcosa: se qui e\' vuoto '
            'la prova gira a vuoto');
    // OGNI VOCE PORTA IL SUO NOME IN LINGUA, e si guarda PRIMA di scorrere:
    // dopo, la prima voce e' uscita dalla vista.
    final primo = attesi.first;
    expect(find.text(LinguaDegliEventi.nomeDi(primo.evento)), findsWidgets,
        reason: 'la prima voce non porta il nome in lingua del Cerchio');

    // **LA LISTA E' PIGRA: si scorre.** Le voci sotto la piega non esistono
    // nell'albero finche' non le si raggiunge, e contarle senza scorrere
    // misurerebbe la finestra invece del calendario.
    var visti = 0;
    for (final evento in attesi) {
      final voce = find.byKey(Key('evento_${evento.evento}'));
      for (var giro = 0; giro < 12 && voce.evaluate().isEmpty; giro++) {
        await tester.dragFrom(const Offset(180, 500), const Offset(0, -280));
        await tester.pump(const Duration(milliseconds: 150));
      }
      if (voce.evaluate().isNotEmpty) visti++;
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 03: eventi attesi ${attesi.length}, trovati a '
        'schermo $visti');
    expect(visti, greaterThan(3),
        reason: 'il calendario mostra $visti eventi su ${attesi.length}: le '
            'voci non vengono dal motore');

  });

  testWidgets('senza identita\' non c\'e\' un vicolo cieco, ma un invito che '
      'porta da qualche parte', (tester) async {
    await apri(tester);
    expect(find.byKey(const Key('calendario_invito_al_profilo')),
        findsOneWidget,
        reason: 'senza identita\' il calendario non invita a completarla');
    expect(find.byKey(const Key('calendario_completa_il_profilo')),
        findsOneWidget,
        reason: 'l\'invito non ha un pulsante vero: sarebbe un vicolo cieco '
            'con le parole gentili');

    // E gli eventi di tutti ci sono lo stesso: la Luna piena arriva per
    // chiunque, anche per chi non ha dato la sua nascita.
    expect(find.byKey(Key('evento_${EventiDelCielo.lunaPiena}')),
        findsOneWidget,
        reason: 'senza identita\' sparisce anche la Luna piena, che non '
            'dipende da chi sei');
  });

  testWidgets('senza identita\' nessun appuntamento tuo si calcola',
      (tester) async {
    await apri(tester);
    for (final personale in ProssimiEventi.personali) {
      expect(find.byKey(Key('evento_$personale')), findsNothing,
          reason: 'senza identita\' il calendario mostra $personale: un '
              'appuntamento tuo che nessuno puo\' calcolare');
    }
  });

  testWidgets('col segno, gli appuntamenti tuoi compaiono', (tester) async {
    // Una prova sua: montare due volte l'app dentro lo stesso test lascia
    // in piedi l'albero di prima e i finder pescano dove non devono.
    await apri(tester, segno: Zodiac.leo);
    expect(find.byKey(const Key('calendario_invito_al_profilo')), findsNothing,
        reason: 'con l\'identita\' data l\'invito a completarla resta li\' '
            'a chiedere una cosa gia\' fatta');
    final mia = find.byKey(Key('evento_${EventiDelCielo.lunaNelTuoSegno}'));
    for (var giro = 0; giro < 12 && mia.evaluate().isEmpty; giro++) {
      await tester.dragFrom(const Offset(180, 500), const Offset(0, -280));
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(mia, findsOneWidget,
        reason: 'col segno noto la Luna nel tuo segno deve comparire: ci '
            'passa ogni mese');
  });

  testWidgets('le voci si leggono col significato, senza imperativi',
      (tester) async {
    await apri(tester, segno: Zodiac.leo);
    // Le righe di significato poggiano su tradizioni reali e non ordinano
    // niente a nessuno: nessun verbo all'imperativo nelle righe mostrate.
    const imperativi = [
      'Approfitta',
      'Cogli',
      'Non perdere',
      'Ricorda di',
      'Sfrutta',
      'Preparati',
    ];
    var lette = 0;
    final colpe = <String>[];
    for (final evento in EventiDelCielo.tutti) {
      final riga = LinguaDegliEventi.significatoDi(evento);
      if (riga == null) continue;
      lette++;
      for (final ordine in imperativi) {
        if (riga.contains(ordine)) {
          colpe.add('$evento: "$riga" contiene "$ordine"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 03: righe di significato lette $lette');
    expect(lette, greaterThan(20),
        reason: 'quasi nessun evento ha la sua riga di significato');
    expect(colpe, isEmpty,
        reason: 'il calendario da\' ordini invece di raccontare:\n'
            '${colpe.join("\n")}');
  });

  test('ogni evento del catalogo ha un nome in lingua del Cerchio', () {
    final senzaNome = <String>[];
    for (final evento in EventiDelCielo.tutti) {
      if (LinguaDegliEventi.nomeDi(evento) == evento) senzaNome.add(evento);
    }
    expect(senzaNome, isEmpty,
        reason: 'questi eventi si mostrerebbero col nome tecnico: '
            '${senzaNome.join(", ")}');
  });
}
