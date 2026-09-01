import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_quiz.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/simbolo_dellattesa.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/loto_dorato.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_test_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ARCHETIPO E' UN DATO SOLO, LETTO DA PIU' PORTE.
///
/// **Il difetto che queste prove tengono chiuso.** Fatto il Test Archetipo, la
/// chat di Aura continuava a mostrare il loto invece dell'emblema. Non era il
/// simbolo a sbagliare, ne' l'emblema a mancare: la schermata del Test si
/// costruiva uno `ArchetypeHistory` SUO e registrava li' dentro, mentre la chat
/// e il Passaporto leggevano quello del fornitore. Due copie dello stesso dato,
/// che si incontravano solo su disco: l'emblema compariva al riavvio dell'app,
/// quindi il difetto sembrava capriccioso ed era esattissimo.
///
/// Copie ce n'erano TRE, non due: anche la schermata dell'Animale Guida se ne
/// costruiva una. E' la famiglia di difetti piu' numerosa di questo progetto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
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

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  // ==========================================================================
  // UNA PORTA SOLA
  // ==========================================================================

  test('In tutto lib un solo posto costruisce uno ArchetypeHistory', () {
    // ENUMERA, non campiona: si guardano TUTTI i file di lib, non quelli che
    // sembrano sospetti. La prima volta che ho contato a occhio ne avevo visti
    // due, e il terzo stava nella schermata dell'Animale Guida.
    //
    // La regola e' sul FATTO, cioe' su quante volte quel costruttore viene
    // chiamato, non sui nomi dei file: rinominare o spostare una schermata non
    // la fa uscire da questa prova.
    final creatori = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      // Il file che DEFINISCE la classe contiene il suo costruttore, e non e'
      // una copia: e' la dichiarazione.
      if (f.path.replaceAll(r'\', '/').endsWith('archetype_history.dart')) {
        continue;
      }
      // SI GUARDA IL CODICE, NON I COMMENTI. La prima stesura di questa prova
      // e' caduta su se stessa: la nota che spiega il difetto NOMINA il
      // costruttore, e una ricerca sul testo intero la contava come una copia.
      // Una prova che non distingue una riga di codice da una riga che ne
      // parla fallisce ogni volta che qualcuno spiega bene.
      final testo = f.readAsLinesSync().where((r) {
        final t = r.trimLeft();
        return !t.startsWith('//') && !t.startsWith('*') && !t.startsWith('/*');
      }).join('\n');
      if (testo.contains('ArchetypeHistory(')) {
        creatori.add(f.path.replaceAll(r'\', '/'));
      }
    }
    expect(creatori.length, 1,
        reason:
            'lo storico dell archetipo viene costruito in ${creatori.length} '
            'posti: $creatori. Ogni copia in piu e un dato che vive due volte, '
            'e due copie dello stesso dato si incontrano solo su disco');
    expect(creatori.single, endsWith('lib/app.dart'),
        reason:
            'l unico costruttore non e il fornitore dell app: ${creatori.single}');
  });

  // ==========================================================================
  // LA CHAT, DAL VIVO
  // ==========================================================================

  testWidgets(
      'Fatto il Test, la chat di Aura passa dal loto all emblema senza '
      'riaprire l app', (tester) async {
    silenceSensors();
    // IL RISVEGLIO GIA' FATTO. Senza questa riga l'app spinge l'onboarding
    // SOPRA lo shell, il Santuario resta sotto e la voce "Consulta" non e'
    // raggiungibile: la prova cadrebbe sul percorso invece che su cio' che
    // vuole misurare. L'archetipo NON si semina: quello deve arrivare dopo,
    // dal vivo, ed e' tutto il punto.
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    // Finestra da telefono, ordine BD voce 02: sul default 800x600 la scena
    // del Santuario degenera e il tocco sul busto muore. Vedi la nota estesa
    // in chat_header_test.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester
        .ensureVisible(find.text('Consulta ${Maestro.aura.displayName}'));
    await tester.pump();
    await tester.tap(find.text('Consulta ${Maestro.aura.displayName}'));
    await step(tester);

    // SENZA TEST, IL LOTO. Se questa riga non passasse, la prova che segue non
    // misurerebbe un cambiamento, misurerebbe uno stato gia' arrivato.
    final storico = ctx.read<ArchetypeHistory>();
    expect(storico.ultimo, isNull);

    // Si fa il Test, cioe' si registra un esito nello storico VERO dell'app,
    // che e' esattamente cio' che fa la schermata del Test.
    await storico.registra(ArchetypeScoring.calcola(List.filled(12, 3)));
    await step(tester);

    // E LO STORICO DELL'APP LO SA SUBITO, senza riavvio.
    //
    // Questa e' la riga che sarebbe caduta prima della correzione, e non per la
    // ragione che sembra: `carica()` parte all'avvio e la lettura del disco
    // arriva dopo qualche istante. Chi in quegli istanti finiva il Test vedeva
    // il proprio esito entrare in memoria e poi sparire, sostituito dalla lista
    // vuota che la lettura riportava da un disco ancora vergine.
    expect(storico.ultimo, isNotNull,
        reason: 'l esito registrato e sparito: la lettura del disco ha '
            'calpestato chi ha scritto mentre leggeva');
    expect(storico.ultimo!.dominante, Archetype.realista);

    // E il loto non c'e' piu' da nessuna parte nell'app viva. La scena di
    // attesa con l'emblema dentro si guarda nell'anteprima
    // `medora-chat`/`aura-chat-emblema`, dove la voce che tace la tiene ferma:
    // qui basta che il fiore dell'attesa non sopravviva al Test.
    expect(find.byType(LotoDorato), findsNothing,
        reason: 'il loto e ancora a schermo col Test gia fatto: il dato '
            'esiste due volte e questa e la copia che non lo sa');
  });

  // ==========================================================================
  // IL PASSAPORTO, DALLO STESSO DATO
  // ==========================================================================

  Widget passaporto(ArchetypeHistory storico) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider<ArchetypeHistory>.value(value: storico),
        ],
        child: const MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              // NUDO, senza avvolgerlo in uno scorrimento: il Passaporto ha
              // gia' il suo, e due scorrimenti annidati non sanno quanto sono
              // alti.
              body: CosmicPassport(),
            ),
          ),
        ),
      );

  testWidgets('Il Passaporto legge lo stesso storico, e cambia insieme a lui',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final storico =
        ArchetypeHistory(clock: () => DateTime(2026, 8, 6, 11), massimo: 40);
    await tester.pumpWidget(passaporto(storico));
    await step(tester);

    // Senza Test, la tessera dice cosa fare e non promette un futuro.
    expect(find.byKey(const Key('passport_archetipo')), findsNothing);

    await storico.registra(ArchetypeScoring.calcola(List.filled(12, 3)));
    await step(tester);

    expect(find.byKey(const Key('passport_archetipo')), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('passport_archetipo_nome')))
            .data,
        Archetype.realista.conArticolo);
    // E LA DATA DELL'ULTIMO TEST, che e' cio' che rende la tessera un
    // documento invece di un'etichetta.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('passport_archetipo_quando')))
            .data,
        'Scoperto il 6/8/2026');

    // RIFATTO IL TEST con un dominante diverso, la tessera lo segue: e' lo
    // stesso oggetto, non una copia che si aggiorna quando le pare.
    await storico.registra(ArchetypeScoring.calcola(List.filled(12, 0)));
    await step(tester);
    final nuovo = ArchetypeScoring.calcola(List.filled(12, 0)).dominante;
    expect(nuovo, isNot(Archetype.realista),
        reason: 'la prova non distingue niente se i due dominanti coincidono');
    expect(
        tester
            .widget<Text>(find.byKey(const Key('passport_archetipo_nome')))
            .data,
        nuovo.conArticolo,
        reason: 'la tessera e rimasta sul dominante di prima');
  });

  // ==========================================================================
  // L'EMBLEMA SI DECODIFICA DAVVERO
  // ==========================================================================

  testWidgets('L emblema si decodifica, non e solo montato', (tester) async {
    // MONTATO NON VUOL DIRE VISIBILE. Un `Image.asset` che punta a un file
    // assente o non decodificabile resta nell'albero, non solleva niente e
    // dipinge ZERO pixel: la scena sembra a posto e ha un buco. E' gia'
    // costato un'anteprima senza corpo, il 2 agosto 2026.
    // LA SUPERFICIE E' QUELLA DELL'IMMAGINE, non lo schermo intero: contare
    // quanti pixel dipinge un emblema di 120 punti dentro una finestra da 800
    // per 600 da' l'uno per cento anche quando l'emblema c'e' tutto, e la
    // soglia direbbe che manca. La misura dev'essere della cosa misurata.
    tester.view.physicalSize = const Size(120, 120);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chiave = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: chiave,
        child: Center(
          child: Image.asset(Archetype.realista.arteThumb,
              width: 120, height: 120, fit: BoxFit.contain),
        ),
      ),
    ));

    // IL PRECARICO PRIMA DELLA CATTURA, e con il suo onError collegato: senza,
    // un fallimento di decodifica finisce in FlutterError.onError e la prova
    // continua come se niente fosse.
    Object? guasto;
    await tester.runAsync(() async {
      await precacheImage(
        AssetImage(Archetype.realista.arteThumb),
        tester.element(find.byType(Image)),
        onError: (e, _) => guasto = e,
      );
    });
    expect(guasto, isNull, reason: 'l emblema non si decodifica: $guasto');
    await tester.pump();

    final immagine = await tester.runAsync(() async =>
        (chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage(pixelRatio: 1.0));
    final dati = await tester.runAsync(
        () => immagine!.toByteData(format: ui.ImageByteFormat.rawRgba));
    final byte = dati!.buffer.asUint8List();

    var dipinti = 0;
    for (var i = 3; i < byte.length; i += 4) {
      if (byte[i] > 0) dipinti++;
    }
    final totale = byte.length ~/ 4;
    // Un decimo dello schermo dipinto e' molto piu' di quanto basti a
    // distinguere un emblema da un buco, e molto meno di quanto l'arte occupi
    // davvero: la soglia serve a dire "c'e' qualcosa", non a misurare l'arte.
    expect(dipinti / totale, greaterThan(0.10),
        reason: 'l emblema ha dipinto $dipinti pixel su $totale: e un buco');
  });

  // ==========================================================================
  // I TRANSITI NON RIELEGGONO LA FIGURA
  // ==========================================================================

  Widget testArchetipo({Set<Pianeta> Function(DateTime)? pianeti}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService()..setTier(Tier.tier2)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(
              create: (_) => ArchetypeHistory(clock: () => DateTime(2026, 8, 6))
                ..carica()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: ArchetypeTestScreen(
                clock: () => DateTime(2026, 8, 6), pianetiDelGiorno: pianeti),
          ),
        ),
      );

  testWidgets(
      'Acceso o spento l interruttore dei transiti, la figura e la '
      'stessa', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // IL CASO CHE RIELEGGE DAVVERO, cercato invece che scelto a occhio.
    //
    // La prima stesura metteva tutti i pianeti e rispondeva sempre per quarta,
    // pensando che la spinta massima fosse anche l'occasione migliore. Restava
    // verde col difetto rimesso: su quel profilo la modulazione non spostava
    // il primo posto, quindi la prova confrontava una figura con se stessa.
    // Enumerando le quattro risposte uniformi e tutti i sottoinsiemi di
    // pianeti, il caso e' questo: rispondendo sempre per PRIMA la base e'
    // l'Innocente, e col solo SOLE attivo il modulato diventa il Sovrano.
    await tester.pumpWidget(testArchetipo(pianeti: (_) => {Pianeta.sole}));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('archetype_start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (var i = 0; i < ArchetypeQuiz.tutte.length; i++) {
      await tester.tap(find.byKey(const Key('archetype_answer_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }

    String nome() =>
        tester.widget<Text>(find.byKey(const Key('archetype_name'))).data!;

    final base = ArchetypeScoring.calcola(List.filled(12, 0));
    final modulato =
        ArchetypeTransits.applica(base, {Pianeta.sole}).modulato.dominante;
    // LA PROVA DICHIARA DI POTER DISTINGUERE: se un giorno la tabella dei
    // transiti cambiasse e questo caso smettesse di rieleggere, qui si
    // fermerebbe invece di diventare verde su niente.
    expect(modulato, isNot(base.dominante),
        reason: 'questo caso non rielegge piu il dominante: la prova che segue '
            'confronterebbe una figura con se stessa');

    final spento = nome();
    expect(spento, base.dominante.conArticolo.toUpperCase());

    // Si accende il cielo.
    await tester.scrollUntilVisible(
        find.byKey(const Key('archetype_transits_switch')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('archetype_transits_switch')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(nome(), spento,
        reason: 'col cielo acceso la figura cambia: l app sta dicendo alla '
            'persona che oggi e un altra persona, e il Passaporto intanto '
            'conserva quella di prima');

    // E il cielo si vede lo stesso, dove gli compete: le percentuali si sono
    // mosse, quindi la riga che dichiara la figura del giorno c'e' oppure il
    // cielo non ha spostato niente. Le due cose insieme sono la prova che i
    // transiti non sono stati semplicemente spenti.
    expect(find.byKey(const Key('archetype_synchronicity')), findsOneWidget,
        reason: 'acceso l interruttore, dei transiti non si vede niente: non '
            'sono stati messi al loro posto, sono stati tolti');
  });

  // ==========================================================================
  // LA PORTA DEL SIMBOLO, E CHI LA APRE
  // ==========================================================================

  test('La porta del simbolo di Aura sceglie sul dato, non sul Maestro', () {
    // Il modello puro, senza schermo: e' qui che si decide fra loto ed
    // emblema, ed e' un posto solo.
    const natal = NatalContext.none;
    final senza = SimboloDellAttesa.per(Maestro.aura, natal: natal);
    expect(senza.loto, isTrue);
    expect(senza.asset, isNull);
    expect(senza.invito, isNotNull,
        reason: 'il fiore chiuso senza una riga sotto sembra un guasto');

    final con = SimboloDellAttesa.per(Maestro.aura,
        natal: natal, archetipo: Archetype.realista);
    expect(con.loto, isFalse,
        reason: 'col Test fatto Aura guarda ancora il fiore che aspetta');
    expect(con.asset, Archetype.realista.arteThumb);
  });

  test('La chat prende l archetipo dallo storico condiviso, non da una copia',
      () {
    // TRASVERSALE, sul punto di montaggio: il difetto vero non stava nella
    // scena ne' nel simbolo, stava nel FILO. Una prova a schermo non lo
    // vedrebbe, perche' a schermo il filo staccato somiglia a "non ho ancora
    // fatto il Test".
    final chat = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    // **GLI SPAZI SI TOLGONO PRIMA DI CERCARE.** Il formattatore spezza
    // `context.watch<ArchetypeHistory>()` su due righe appena la riga si
    // allunga, e questa guardia cercava la forma su una riga sola: e'
    // diventata rossa su codice giusto il 1 settembre 2026. Una guardia che
    // legge il codice come testo deve leggerlo senza la sua impaginazione.
    final chatSenzaSpazi = chat.replaceAll(RegExp(r'\s+'), '');
    expect(chatSenzaSpazi.contains('.watch<ArchetypeHistory>()'), isTrue,
        reason: 'la chat non legge piu lo storico condiviso');
    expect(chat.contains('ArchetypeHistory('), isFalse,
        reason: 'la chat si costruisce uno storico suo');
  });

  test('La lettura del disco non calpesta chi ha scritto mentre leggeva',
      () async {
    // Il cuore del difetto, senza schermo di mezzo. Si fa partire la lettura,
    // si registra PRIMA che arrivi, e si pretende che l'esito sopravviva.
    SharedPreferences.setMockInitialValues({});
    // SUL DISCO C'E' GIA' QUALCOSA DI DIVERSO, e non e' un dettaglio: con un
    // disco vuoto la lettura riportava una lista vuota, e "vuoto sopra vuoto"
    // non si distingue da "non e' successo niente". La prima stesura di questa
    // prova restava verde anche col difetto rimesso, perche' il caso non
    // percorreva il ramo che credeva di misurare.
    final prima = ArchetypeHistory(clock: () => DateTime(2026, 8, 1));
    await prima.registra(ArchetypeScoring.calcola(List.filled(12, 0)));

    // E adesso lo storico nuovo, come all'apertura dell'app: legge il disco
    // mentre qualcuno finisce il Test.
    final storico = ArchetypeHistory(clock: () => DateTime(2026, 8, 6));
    final lettura = storico.carica();
    await storico.registra(ArchetypeScoring.calcola(List.filled(12, 3)));
    await lettura;
    expect(storico.ultimo, isNotNull,
        reason: 'la lettura ha riportato il disco vuoto sopra un esito appena '
            'registrato: il Test fatto nei primi istanti dopo l apertura si '
            'perde, e sembra un capriccio');
    expect(storico.ultimo!.dominante, Archetype.realista);
  });
}
