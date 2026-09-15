import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// La schermata del Sigillo del Sogno: nebbia, cielo, stelle unite, saluto.
void main() {
  final quando = DateTime(2026, 7, 13, 22, 40);

  void silenceSensors(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: DreamRiteScreen(now: quando),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Dirada la nebbia col ripiego tattile, poi unisce tutte le stelle in ordine.
  Future<void> compiIlRito(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);
    final segno = NightSky.moonSign(quando);
    final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
    for (var i = 0; i < figura.points.length; i++) {
      await tester.tap(find.byKey(Key('dream_star_$i')));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 1000));
    await passo(tester);
  }

  testWidgets('Si apre nella nebbia, col fiato e il ripiego tattile',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.text('Sigillo del Sogno'), findsOneWidget);
    expect(find.byKey(const Key('dream_fog')), findsOneWidget);
    expect(find.byKey(const Key('dream_invito')), findsOneWidget);
    expect(find.byKey(const Key('dream_breath_bar')), findsOneWidget);
    expect(find.byKey(const Key('dream_fog_skip')), findsOneWidget);
    // Nella nebbia il cielo non e' ancora toccabile.
    expect(find.byKey(const Key('dream_star_0')), findsNothing);
    // Nessun vecchio nome nell'interfaccia.
    expect(find.textContaining('Rito della Buonanotte'), findsNothing);
  });

  testWidgets('Diradata la nebbia emergono le stelle da unire', (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);
    expect(find.byKey(const Key('dream_star_0')), findsOneWidget);
    expect(find.text('Alza il telefono verso il cielo.'), findsOneWidget);
    // La costellazione e' quella del segno della Luna di quel momento.
    final segno = NightSky.moonSign(quando);
    expect(find.textContaining(segno.italianName), findsWidgets);
  });

  testWidgets('Le stelle si uniscono in sequenza, fuori ordine non contano',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await passo(tester);

    final segno = NightSky.moonSign(quando);
    final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
    // Toccare l'ultima per prima non unisce nulla.
    await tester.tap(find.byKey(Key('dream_star_${figura.points.length - 1}')));
    await passo(tester);
    expect(find.textContaining('Stelle unite 0 su'), findsOneWidget);
    // In ordine, invece, si accende.
    await tester.tap(find.byKey(const Key('dream_star_0')));
    await passo(tester);
    expect(find.textContaining('Stelle unite 1 su'), findsOneWidget);
  });

  testWidgets('Unita la costellazione scende il saluto della notte',
      (tester) async {
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await compiIlRito(tester);

    expect(find.byKey(const Key('dream_message')), findsOneWidget);
    expect(find.byKey(const Key('dream_word')), findsOneWidget);
    expect(find.byKey(const Key('dream_provenienza')), findsOneWidget);
    // **LA CHIAVE E' CAMBIATA, ordine CG voci 06 e 08.** Il Condividi
    // adesso viene da AzioniDelResponso, che e' la porta sola per tutte e
    // tredici le arti col responso, e accanto ci sono il Custodisci e il
    // Parlane, che prima qui non esistevano. La chiave vecchia era di
    // questa schermata e basta.
    expect(find.byKey(const Key('responso_condividi')), findsOneWidget);
    expect(find.byKey(const Key('responso_custodisci')), findsOneWidget);
    expect(find.byKey(const Key('responso_parlane')), findsOneWidget);
    // Il saluto e' quello deterministico dal cielo reale.
    final atteso = DreamRiteCorpus.saluto(quando);
    // **IL SALUTO PASSA DALLA PORTA UNICA, ordine BV voce 06**: non e' piu'
    // un `Text` ma il blocco narrato comune, e il testo si legge da li'.
    expect(
        tester
            .widget<ParagrafiDiLettura>(find.byKey(const Key('dream_message')))
            .testo,
        atteso);
    // Chiude con la buonanotte, il rito non si chiama piu' cosi'.
    expect(atteso.trim().endsWith('Buonanotte.'), isTrue);
    expect(find.textContaining('Rito della Buonanotte'), findsNothing);
  });

  testWidgets('Il tooltip dice su cosa il rito si fonda, e non cosa manca',
      (tester) async {
    // **QUESTA PROVA TENEVA IN VITA LA CONFESSIONE.** Ordine CW voce 04, 7
    // settembre 2026. Pretendeva la riga *"non è allineata alla posizione
    // esatta sopra di te: servirebbero GPS, bussola ed effemeridi in tempo
    // reale"*, cioe' esattamente la forma che l'ordine CS ha aperto per il
    // tooltip degli Angeli.
    //
    // **Misurato sensore per sensore, nessuno dei tre serve al calcolo:** il
    // segno e la fase della Luna vengono dalla sola data e sono grandezze
    // geocentriche, uguali in ogni punto della Terra; la bussola servirebbe
    // solo a orientare la scena; e le effemeridi **ci sono**, girano sul
    // dispositivo senza rete, ed erano proprio quelle che producevano il
    // responso. La riga diceva quindi anche una cosa falsa.
    //
    // Adesso la prova pretende il contrario: che il tooltip dica su cosa il
    // rito si fonda, e che non nomini piu' cio' che non ha.
    silenceSensors(tester);
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    await tester.tap(find.byKey(const Key('dream_sources')));
    await passo(tester);
    expect(find.byKey(const Key('dream_sources_sheet')), findsOneWidget);
    expect(find.textContaining('cielo notturno reale di questo momento'),
        findsOneWidget);
    expect(find.textContaining('non ha bisogno di sapere dove sei'),
        findsOneWidget,
        reason: 'il tooltip non dice piu\' che il rito si fonda sulla sola '
            'data, cioe\' ha smesso di confessare senza spiegare');

    // **E NON CONFESSA PIU'.** Nessuno dei tre sensori si nomina.
    for (final parola in const ['GPS', 'bussola', 'servirebbero']) {
      expect(find.textContaining(parola), findsNothing,
          reason: 'il tooltip nomina ancora "$parola": un tooltip non e\' il '
              'posto dove l\'app confessa quello che non ha fatto, e questo '
              'sensore al calcolo del Sigillo del Sogno non serve');
    }

    // **REGOLA D: QUI SI PRETENDEVA LA PROVENIENZA DEL TONO, e adesso si
    // pretende il contrario.** Ordine DD voce 04, 10 settembre 2026, per
    // decisione del fondatore: **il tono theta ha lasciato il Sigillo** ed e'
    // tornato nella Meditazione di Aura, dove sta con le altre otto frequenze
    // sotto il sintomo Insonnia.
    //
    // La pretesa della voce CW.03 era giusta finche' il suono usciva da
    // questa schermata: un foglio che spiega il testo e tace sul suono lascia
    // credere che il suono venga da un'altra parte. **Adesso il suono non
    // c'e', e spiegarne la provenienza sarebbe parlare di un'altra stanza.**
    //
    // La spiegazione non e' andata perduta: vive nella Meditazione, accanto
    // alla pratica che quel tono lo suona, e la guardia dell'ordine CN
    // pretende che il preset resti li'.
    expect(find.byKey(const Key('dream_provenienza_del_tono')), findsNothing,
        reason: 'il foglio delle fonti del Sigillo spiega ancora da dove '
            'nasce un tono che questa schermata non emette piu');
    expect(find.byKey(const Key('dream_sound')), findsNothing,
        reason: 'il pulsante del tono theta e ancora nel Sigillo');
  });

  testWidgets(
      'ORDINE DD VOCE 04: la Parola dell Alba TORNA a video nel Sigillo',
      (tester) async {
    // **Il fatto del fondatore**: la Parola dell Alba non torna nel Sigillo
    // del Sogno.
    //
    // **E il meccanismo c e da sempre.** Ordine P voce 18:
    // `FiloDelGiorno.segnaLaParola` la scrive dall Alba,
    // `parolaDiStamattina` la rilegge dal Sigillo, e la formula la mostra.
    // La guardia dell ordine CY prova che **il dato sopravvive** fra i due
    // riti, anche a chi si alza alle due di notte.
    //
    // **Quello che nessuno provava e che la frase ARRIVI A VIDEO.** Il dato
    // che sopravvive e la frase che si legge sono due fatti diversi, e fra
    // loro c e tutta la schermata: una fase che non arriva, un ramo che non
    // si monta, un rito che non si compie. Questa prova fa il giro intero:
    // segna la parola come farebbe l Alba, compie il rito della sera, e
    // guarda se la riga c e.
    silenceSensors(tester);
    grande(tester);
    SharedPreferences.setMockInitialValues({});
    await FiloDelGiorno.segnaLaParola('Soglia', quando);

    await tester.pumpWidget(host());
    await passo(tester);
    await compiIlRito(tester);
    // La lettura dal disco e asincrona: si lascia arrivare.
    await passo(tester);
    await tester.pump(const Duration(milliseconds: 400));

    final riga = find.byKey(const Key('dream_parola_del_mattino'));
    // ignore: avoid_print
    print('ORDINE DD VOCE 04: la riga della parola del mattino '
        '${riga.evaluate().isEmpty ? "NON c e" : "c e"} a video');
    expect(riga, findsOneWidget,
        reason: 'la Parola dell Alba non torna a video nel Sigillo: il dato '
            'sopravvive, la frase non arriva, e per chi guarda la promessa '
            'dell Alba non e stata mantenuta');
    expect(find.textContaining('Soglia'), findsWidgets,
        reason: 'la riga c e ma non porta la parola di stamattina');
  });
}
