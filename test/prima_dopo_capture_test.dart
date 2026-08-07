import 'package:esoteric_circle/app.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/rituals/retro_della_runa.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/diagnostics_dialog.dart';
import 'package:esoteric_circle/services/firebase/attestazione.dart';
import 'package:esoteric_circle/core/maestro/ancoraggio.dart';
import 'package:esoteric_circle/core/maestro/frase_del_limite.dart';
import 'package:esoteric_circle/core/maestro/lente_del_cielo.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/intro/sequenza_intro.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE IMMAGINI PRIMA E DOPO, che l'Architetto apre dal remoto prima che il
/// fondatore installi.
///
/// Si generano con `--dart-define=STATO=prima` oppure `dopo`, e finiscono in
/// `docs/preview/prima_dopo/`. La "prima" si ottiene riportando il codice allo
/// stato di partenza e rieseguendo: NON si recupera da un file vecchio, che
/// potrebbe essere di un'altra misura e mostrerebbe una differenza che non e'
/// quella corretta.
const _stato = String.fromEnvironment('STATO');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// PRECARICA GLI ASSET PRIMA DELLA CATTURA, SEMPRE.
  ///
  /// In headless un'immagine non si decodifica se nessuno la mette in cache
  /// prima: senza questo, l'anteprima mostra un buco e non prova niente. E'
  /// gia' costato un'anteprima del consulto, che infatti non aveva corpo.
  Future<void> precarica(WidgetTester tester) async {
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      for (final segno in Zodiac.values) {
        await precacheImage(AssetImage(ZodiacArt.emblemPath(segno)), ctx);
      }
    });
    await tester.pump();
  }

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  for (final nascita in const [false, true]) {
  testWidgets('Cielo ${nascita ? "nascita" : "adesso"}', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    // La misura reale del telefono del fondatore: 360 punti logici.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: SkyOverviewScreen(
            birth: nascita,
            // L'ISTANTE DELLA SEGNALAZIONE, non l'adesso della macchina: due
            // catture fatte in momenti diversi non si possono confrontare, e
            // questa coppia serve proprio a confrontare.
            now: nascita
                ? DateTime(1975, 7, 6, 9, 30)
                : DateTime(2026, 8, 1, 18, 4),
            ctaLabel: nascita ? 'Leggi la tua carta' : null,
            onCta: nascita ? () {} : null,
            luogoIniziale:
                const SkyPlace(latitude: 45.46, longitude: 9.19),
            location: const DisabledSkyLocation(),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));

    // Si tocca Ariete, che e' la costellazione della segnalazione.
    // Si tocca la LUNA, che e' il corpo che finiva sotto la barra del titolo.
    final corpo = find.byKey(const Key('sky_body_moon'));
    if (corpo.evaluate().isNotEmpty) {
      await tester.tap(corpo, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final quale = nascita ? 'nascita' : 'adesso';
      File('${dir.path}/cielo_${quale}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });
  }

  testWidgets('Dati di nascita', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: const DatiDiNascitaScreen(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/dati_nascita_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  testWidgets('Miniature del Passport', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: const Scaffold(
            backgroundColor: Color(0xFF0B1020),
            body: CosmicPassport(),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Si scorre fino alle tessere dell'Animale e degli Angeli, che sono quelle
    // con le miniature segnalate.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/miniature_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  /// I DUE FOTOGRAMMI DELL'INTRO, non piu' tre.
  ///
  /// **Cosa mostrava prima, e cosa mostrava davvero.** Le catture erano tre,
  /// "frase", "logo" e "destinazione", e quelle del logo e della destinazione
  /// erano uscite BYTE PER BYTE IDENTICHE: la sequenza in prova headless
  /// passava oltre il logo prima dello scatto, quindi l'anteprima del logo
  /// mostrava la destinazione e dichiarava di mostrare il logo. Cieca dal 3
  /// agosto 2026, e nessuno se ne era accorto perche' un'immagine che esiste
  /// sembra una prova anche quando non lo e'.
  ///
  /// **Cosa si puo' fotografare adesso.** L'intro e' un video, e un video in
  /// prova headless non si disegna: non c'e' niente che lo decodifichi, e
  /// nessuna finta puo' inventarne i fotogrammi. Quello che si puo' catturare
  /// e' cio' che il CODICE mette attorno al video, cioe' il nero su cui si
  /// apre e l'invito a saltare, e la destinazione che resta quando l'intro se
  /// ne e' andata. Il video si guarda sul telefono, ed e' l'unico posto dove
  /// guardarlo abbia senso.
  testWidgets('I due fotogrammi dell intro', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: radice,
        child: const SequenzaIntro(
          child: Scaffold(
            backgroundColor: Color(0xFF0B1020),
            body: Center(
              child: Text('IL CERCHIO',
                  style: TextStyle(color: Color(0xFFD9B65C), fontSize: 24)),
            ),
          ),
        ),
      ),
    ));

    Future<void> scatta(String nome) async {
      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/intro_$nome.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    }

    // 1. L'APERTURA: il nero su cui il video si apre, con l'invito a saltare.
    //    Si scatta SUBITO, prima di far scorrere il tempo: il lettore vero non
    //    parte in prova, e al primo istante utile l'intro va gia' verso la
    //    destinazione. Questo e' il fotogramma che una persona vede mentre il
    //    video si prepara, ed e' l'unico che il codice disegni da solo.
    await scatta('apertura');

    // 2. La destinazione, dopo che l'intro se ne e' andata. Due dissolvenze:
    //    una perche' scorra, una perche' si smonti.
    await tester.pump();
    await tester.pump(SequenzaIntro.dissolvenza);
    await tester.pump(SequenzaIntro.dissolvenza);
    await scatta('destinazione');

    // E I DUE SCATTI DEVONO ESSERE DIVERSI. E' la riga che mancava prima, ed e'
    // il motivo per cui logo e destinazione sono rimasti identici per giorni
    // senza che niente lo dicesse.
    final apertura =
        File('docs/preview/prima_dopo/intro_apertura.png').readAsBytesSync();
    final destinazione = File('docs/preview/prima_dopo/intro_destinazione.png')
        .readAsBytesSync();
    expect(apertura.length == destinazione.length, isFalse,
        reason: 'i due fotogrammi dell intro sono venuti identici: uno dei due '
            'e stato scattato nel momento sbagliato, e l anteprima dichiara un '
            'momento che non ha mai visto');
  });

  // LA CHAT QUANDO LA VOCE TACE.
  //
  // La coppia che conta per l'ordine sarebbe "la chat che tace contro la chat
  // che risponde", ma la chat che risponde NON e' fotografabile qui: in prova
  // headless non c'e' rete, e sul progetto vero l'API di Firebase AI e' spenta.
  // Fotografare una risposta finta proverebbe soltanto che so scrivere una
  // stringa. La coppia vera e verificabile e' un'altra, ed e' quella che
  // cambia per la persona: il ripiego MUTO contro il ripiego DICHIARATO.
  testWidgets('Chat, il ripiego', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceCheTace(),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'cattura prima e dopo',
    );

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepaintBoundary(
          key: radice,
          child: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
              initialUserMessage: 'Che cosa mi dice il mio cammino?',
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/chat_ripiego_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  // LA CHAT CHE SI LEGGE: quattro difetti di vista in una schermata sola.
  // Il cosmo che passa dentro la bolla, la conversazione appesa in alto, il
  // colore della palette neutra al posto di quello del Maestro, il Riprova
  // lontano dalla bolla. Si fotografa una conversazione RIUSCITA di due turni,
  // che e' esattamente il caso in cui la schermata leggeva come vuota.
  // LA RISPOSTA INTERA CONTRO IL MONCONE, che e' la coppia dell'ORDINE D.
  //
  // A differenza delle altre coppie, questa NON si ottiene riportando indietro
  // il codice: il difetto non stava in una riga di layout, stava in cio' che il
  // modello riusciva a scrivere prima di finire lo spazio. Il "prima" e' la
  // frase che il fondatore ha letto sul telefono, il "dopo" e' una risposta
  // vera misurata oggi. La differenza che si vede e' quella vera.
  testWidgets('Chat, la risposta intera', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Il moncone letto sul telefono del fondatore il 2 agosto 2026, contro la
    // risposta di novantuno parole misurata dopo la correzione.
    const moncone = 'Un velo argenteo si';
    const intera = 'Un velo sottile di Luna nuova sembra avvolgerti, Sofia.\n\n'
        'La tua Luna in Cancro, segno di profondità e protezione, si lega alla '
        'tua natura di Leone, portandoti a sentire ogni emozione con grande '
        'intensità. Il timore di sbagliare è una risonanza del tuo numero della '
        'vita, il Cercatore, che ti spinge alla perfezione e alla comprensione '
        'profonda. Questo transito lunare ti invita a osservare le tue paure, '
        'non a reprimerle, riconoscendole come parte del tuo cammino.\n\n'
        'Il ciclo lunare si chiuderà completamente fra sette giorni, portando '
        'con sé una nuova prospettiva.';

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceConUnTesto(_stato == 'prima' ? moncone : intera),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'cattura prima e dopo',
    );

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepaintBoundary(
          key: radice,
          child: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
              initialUserMessage: 'ho paura di sbagliare',
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/chat_risposta_intera_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  testWidgets('Chat, la conversazione', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceCheRisponde(),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'cattura prima e dopo',
    );

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepaintBoundary(
          key: radice,
          child: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
              initialUserMessage: 'Che cosa mi dice il mio cammino?',
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/chat_leggibile_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  // L'ATTESA CHE CONSULTA IL CIELO, nei suoi tre stati visibili. La scena si
  // fotografa da sola, senza montare la chat: e' un widget del design system,
  // e questo e' esattamente il motivo per cui ci vive.
  const statiDelConsulto = <String, ({NatalContext natal, bool fermo})>{
    'consulto_ascendente': (natal: _cartaPiena, fermo: false),
    'consulto_luna': (natal: _soloFaseLunare, fermo: false),
    // LA STESSA LUNA IN UNA SECONDA FASE, perche' una fase sola non prova che
    // il disco segua il dato: proverebbe solo che quel disegno esiste.
    'consulto_luna_gibbosa': (natal: _gibbosaCalante, fermo: false),
    'consulto_senza_carta': (natal: NatalContext.none, fermo: false),
    'consulto_riduci_movimento': (natal: _cartaPiena, fermo: true),
  };

  for (final stato in statiDelConsulto.entries) {
    testWidgets('Consulto, ${stato.key}', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      Widget albero({required bool mostra}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            maestro: Maestro.medora,
            child: Builder(
              builder: (ctx) => MediaQuery(
                data: MediaQuery.of(ctx)
                    .copyWith(disableAnimations: stato.value.fermo),
                child: RepaintBoundary(
                  key: radice,
                  child: Scaffold(
                    backgroundColor: const Color(0xFF080B1A),
                    body: Center(
                      // La stessa dissolvenza della chat, con la stessa regola:
                      // a moto fermo dura zero, cioe' la scena c'e' invece di
                      // comparire.
                      child: AnimatedSwitcher(
                        duration: stato.value.fermo
                            ? Duration.zero
                            : TempiDellAttesa.dissolvenza,
                        transitionBuilder: (figlio, anim) =>
                            FadeTransition(opacity: anim, child: figlio),
                        child: mostra
                            ? ConsultoDelCieloView(
                                key: const ValueKey('scena che compare'),
                                natal: stato.value.natal,
                                maestro: Maestro.medora,
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('nessuna scena')),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // LA SCENA DEVE COMPARIRE DAVVERO, altrimenti non c'e' nessuna meta'
      // della comparsa da fotografare. `AnimatedSwitcher` non anima il primo
      // figlio che riceve: anima quando il figlio CAMBIA. Montando la scena
      // gia' presente, le due catture tornavano identiche al byte anche dopo
      // aver spostato l'istante, ed e' successo davvero.
      await tester.pumpWidget(albero(mostra: false));
      await tester.pump();
      await tester.pumpWidget(albero(mostra: true));
      await precarica(tester);
      // A META' DELLA COMPARSA, allo stesso istante nominale per tutte e due.
      //
      // **Il dato che ha fatto cambiare questo istante.** Le anteprime
      // `consulto_riduci_movimento_dopo` e `consulto_ascendente_dopo` pesavano
      // lo stesso numero di byte, 105.481: erano lo stesso file. A riposo le
      // due scene sono identiche PER COSTRUZIONE, quindi un'immagine ferma non
      // puo' provare un'assenza di movimento. La differenza esiste solo
      // DURANTE la comparsa: a meta' della dissolvenza, con il moto acceso
      // l'emblema sta emergendo, con Riduci Movimento e' gia' posato.
      await tester.pump(TempiDellAttesa.dissolvenza ~/ 2);

      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/${stato.key}_$_stato.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    });
  }

  // L'AVVISO DI CONFIGURAZIONE NELLA CHAT DI AURA: diceva "La voce di Medora
  // si attiva" anche qui, e questa e' l'immagine che lo prova.
  testWidgets('Chat, avviso di configurazione, aura', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: memoria,
      memoryPersistent: false,
    );

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepaintBoundary(
          key: radice,
          child: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.aura,
              services: servizi,
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/chat_avviso_aura_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  // LA CARD DELLA SINTESI: la bilancia prima, i tre volti dopo.
  //
  // Il segno in cima alla Sintesi comparativa era `Icons.balance`. Il
  // fondatore ci ha letto il SEGNO della Bilancia, e aveva ragione: il
  // significato di un simbolo non lo decide il contesto nella testa di chi
  // disegna. La "prima" si ottiene rimettendo l'icona nel codice e
  // rieseguendo, come dice il commento in cima a questo file: NON si recupera
  // l'immagine vecchia, che era impaginata a rapporto 1 e mostrerebbe due
  // differenze invece di una.
  testWidgets('Sintesi comparativa, il segno in cima', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: AppServices.offline()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: radice,
          child: const MaestroScope(
            child: AskMaestriScreen(starter: Maestro.medora),
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.enterText(
        find.byKey(const Key('ask_field')), 'Devo cambiare lavoro?');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pumpAndSettle();
    // La Sintesi compare solo quando gli sguardi sono piu' di uno.
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // I mezzi busti dei Maestri: senza decodifica il segno nuovo sarebbe un
    // buco, e l'immagine non proverebbe niente.
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), ctx);
      }
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ask_synthesis')), findsOneWidget);

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/sintesi_segno_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  // LE TRE LENTI SULLO STESSO DATO, una immagine per Maestro.
  for (final maestro in Maestro.values) {
    testWidgets('Lente, ${maestro.id}', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            maestro: maestro,
            child: Builder(
              builder: (ctx) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
                child: RepaintBoundary(
                  key: radice,
                  child: Scaffold(
                    backgroundColor: const Color(0xFF080B1A),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ChatBubble(
                          message: ChatMessage(
                            role: ChatRole.maestro,
                            text: LenteDelCielo.battuta(
                                maestro, _ancoraggioDellaLente),
                          ),
                          maestro: maestro,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/lente_${maestro.id}_$_stato.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    });
  }

  // IL PANNELLO DI MESSA A PUNTO che dichiara l'attestazione.
  testWidgets('Pannello, attestazione', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(
          maestro: Maestro.medora,
          child: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: Scaffold(
                backgroundColor: const Color(0xFF080B1A),
                body: Center(
                  child: RepaintBoundary(
                    key: radice,
                    child: PannelloDiMessaAPunto(
                      aiReady: true,
                      memoryPersistent: false,
                      attestazione:
                          EsitoAttestazione.nonInstallataPerScelta,
                      nota: 'Memoria persistente non disponibile.',
                      guasti: null,
                      appCheckDebugToken: null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/pannello_attestazione_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  // IL MESSAGGIO DEL LIMITE, uno per Maestro. Il "prima" esiste ed e' negli
  // screenshot del fondatore del 2 agosto: la STESSA identica frase su Caligo
  // e su Aura, col numero sbagliato. Qui si vede che sono tre e che il numero
  // arriva dal dato.
  for (final maestro in Maestro.values) {
    testWidgets('Limite, ${maestro.id}', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            maestro: maestro,
            child: Builder(
              builder: (ctx) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
                child: RepaintBoundary(
                  key: radice,
                  child: Scaffold(
                    backgroundColor: const Color(0xFF080B1A),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ChatBubble(
                          message: ChatMessage(
                            role: ChatRole.maestro,
                            // Il numero viene dal DATO, come nell'app.
                            text: FraseDelLimite.per(
                              maestro,
                              limite: QuestionAllowance().dailyLimit(Tier.free),
                            ),
                            tipo: TipoDiMessaggio.limiteRaggiunto,
                          ),
                          maestro: maestro,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await precarica(tester);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/limite_${maestro.id}_$_stato.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    });
  }

  // "VAI PIU' A FONDO" sotto la risposta, e IL RIPIEGO CHE LEGGE DAVVERO.
  // Due stati della stessa schermata, distinti solo da come risponde la voce.
  for (final caso in const ['approfondisci', 'ripiego_lettura']) {
    testWidgets('Chat, $caso', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final memoria = InMemoryMaestroMemoryRepository();
      await memoria
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final servizi = AppServices(
        ai: caso == 'approfondisci' ? _VoceCheRisponde() : _VoceCheTace(),
        memory: memoria,
        memoryPersistent: false,
      );

      // Una carta natale vera, cosi' il ripiego ha qualcosa da leggere.
      final identita = BirthIdentityController();

      final radice = GlobalKey();
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<AppServices>.value(value: servizi),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider<BirthIdentityController>.value(
              value: identita),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: RepaintBoundary(
            key: radice,
            child: Navigator(
              onGenerateRoute: (_) => MaestroChatScreen.route(
                maestro: Maestro.medora,
                services: servizi,
                initialUserMessage: 'Che cosa mi dice il mio cammino?',
              ),
            ),
          ),
        ),
      ));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }

      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/preview/prima_dopo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/chat_${caso}_$_stato.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        img.dispose();
      });
    });
  }

  // LE COPPIE DELL'ORDINE 2161, voci 1..4. Tutte montano l'APP INTERA
  // dall'avvio, non una schermata a mano: le regressioni di quest'ordine
  // vivevano proprio nella differenza fra il widget isolato, dove le prove
  // erano verdi, e l'app vera, dove Mauro non vedeva niente.

  /// Uno scatto dell'app intera, con la radice avvolta nel RepaintBoundary.
  Future<void> scattaApp(
      WidgetTester tester, GlobalKey radice, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  }

  // VOCE 1: la scena di attesa sopra una conversazione PIENA, alla misura
  // del telefono del fondatore. La conversazione si riempie con tre scambi
  // interi, che e' la condizione vera della regressione: e' col passare
  // della storia che la scena spariva.
  testWidgets('2161, la scena di attesa in chat piena', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: const _VoceLenta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(maestro: Maestro.aura, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Due scambi interi riempiono la conversazione. NON tre: il cammino
    // prevede tre domande al giorno, e al quarto invio risponderebbe il
    // limite, che e' istantaneo e non ha attesa da fotografare.
    for (final battuta in const [
      'Chi sei tu?',
      'Continua il discorso, ti ascolto.',
    ]) {
      await tester.enterText(find.byType(TextField).first, battuta);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
    // Terzo invio, l'ultimo del giorno: lo scatto cade nel mezzo dell'attesa.
    await tester.enterText(
        find.byType(TextField).first, 'E adesso dove guardo?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    await scattaApp(tester, radice, 'attesa_chat');

    // Si esaurisce l'attesa residua, per chiudere senza lavori in volo.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  });

  // VOCE 2: la barra della chat, con cio' che le passa sotto. L'eccezione
  // e' revocata: anche qui il vetro deve avere contenuto da mostrare.
  testWidgets('2161, la barra nella chat', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices.offline();
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await scattaApp(tester, radice, 'barra_chat');
  });

  // VOCE 3: le due famiglie di domande sulla prima schermata. La data di
  // nascita c'e', quindi le personali sul Sole compaiono e dicono il vero.
  // La voce e' accesa: cosi' i chip si vedono vivi e senza l'avviso di
  // configurazione davanti. Si scorre fino alle famiglie, come farebbe la
  // persona: e' il contenuto della voce, non il mezzo busto.
  testWidgets('2161, le due famiglie di domande', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: const _VoceLenta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Fino in fondo al primo schermo: le famiglie stanno sotto il mezzo
    // busto, e il fondo dichiarato dal primo schermo le porta sopra il
    // compositore, non dietro.
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(MaestroChatScreen), const Offset(0, -400),
          warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 300));

    await scattaApp(tester, radice, 'famiglie_domande');
  });

  // VOCE 6: la gettata fissa (dove l'acqua rossa non c'e' piu': le pietre
  // cadono sul cosmo) e il getto sul telo (dove il panno di Tacito resta,
  // ma coi bordi morbidi e irregolari).
  for (final caso in const ['fissa', 'telo']) {
    testWidgets('2161, la gettata $caso', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(
                  initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: RepaintBoundary(
            key: radice,
            child: RuneDrawScreen(
                userSign: Zodiac.aries, random: math.Random(7)),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      // LE PIETRE SI PRECARICANO, SEMPRE: in headless un'immagine non si
      // decodifica da sola, e senza queste righe la gettata mostrava ombre
      // e cerchi senza pietre, cioe' il falso. Tutte e ventiquattro, nelle
      // due misure: quale esca lo decide la sorte col suo seme.
      await tester.runAsync(() async {
        final el = tester.element(find.byType(MaterialApp));
        for (final r in kElderFuthark) {
          if (r.thumbPath != null) {
            await precacheImage(AssetImage(r.thumbPath!), el);
          }
          if (r.fullPath != null) {
            await precacheImage(AssetImage(r.fullPath!), el);
          }
        }
      });
      await tester.pump();

      if (caso == 'telo') {
        await tester.ensureVisible(find.text('Il getto sul telo'));
        await tester.pump(const Duration(milliseconds: 120));
        await tester.tap(find.text('Il getto sul telo'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const Key('rune_cast_button')));
      await tester.pump();
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.ensureVisible(find.byKey(const Key('rune_well')));
      await tester.pump(const Duration(milliseconds: 300));

      await scattaApp(tester, radice, 'gettata_$caso');
    });
  }

  // VOCI 9 E 11: il Tramonto. L'incisione a meta' sulla pietra vergine
  // vera (voce 9) e la lettura con l'invito "Gira la pietra" subito sotto
  // la pietra (voce 11).
  for (final caso in const ['incisione', 'invito']) {
    testWidgets('2161, il tramonto $caso', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepaintBoundary(
          key: radice,
          child: SunsetRuneScreen(
              now: DateTime(2026, 8, 6, 21, 30),
              dataNascita: DateTime(1988, 7, 5)),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // La pietra vergine si precarica, sempre: headless non decodifica.
      await tester.runAsync(() async {
        final el = tester.element(find.byType(MaterialApp));
        for (final r in kElderFuthark) {
          final vergine = pathVergineDi(r.stem);
          if (vergine != null) {
            await precacheImage(AssetImage(vergine), el);
          }
          if (r.fullPath != null) {
            await precacheImage(AssetImage(r.fullPath!), el);
          }
        }
      });
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
      if (caso == 'incisione') {
        // A meta' del segno: col movimento ridotto l'incisione va da se'
        // in 1,2 secondi, tre passi da 200 ms sono circa meta'.
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));
      } else {
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      await scattaApp(tester, radice, 'tramonto_$caso');

      // Si esaurisce il rito, per chiudere senza lavori in volo.
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    });
  }

  // VOCE 4: il fondo della home, scorso davvero, dove la striscia delle
  // altre arti adesso c'e' e prima non c'era.
  testWidgets('2161, la striscia in fondo alla home', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final scroll = find.byType(SingleChildScrollView).first;
    for (var i = 0; i < 20; i++) {
      await tester.drag(scroll, const Offset(0, -500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 400));

    await scattaApp(tester, radice, 'striscia_home');
  });
}

/// Una carta natale piena, per le anteprime del consulto.
/// LE TRE RISPOSTE CON LA LENTE: lo stesso dato detto da tre voci.
///
/// Non passano dall'AI: il testo e' quello che la lente produce in modo
/// deterministico, cosi' l'immagine mostra la REGOLA e non l'umore di una
/// generazione. Lo dichiaro perche' un'anteprima che sembra una risposta vera
/// senza esserlo e' peggio di nessuna anteprima.
const _ancoraggioDellaLente =
    Ancoraggio(nome: 'segno lunare', valore: 'Cancro');

/// Solo la fase lunare, per fotografare il disco della Luna col terminatore.
const _soloFaseLunare = NatalContext(
    moonIllumination:
        MoonIllumination(fraction: 0.25, waxing: true, elongationDeg: 60));

/// La stessa persona con una Luna diversa: gibbosa calante, elongazione 240
/// gradi, cioe' tre quarti di disco accesi dall'altro lato. Serve a far vedere
/// che il disco SEGUE il numero invece di essere sempre lo stesso disegno.
const _gibbosaCalante = NatalContext(
    moonIllumination:
        MoonIllumination(fraction: 0.75, waxing: false, elongationDeg: 240));

const _cartaPiena = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Pesci',
  ascendant: 'Vergine',
);

/// Una voce che risponde davvero, per fotografare una conversazione riuscita.
/// Una voce che consegna un testo dato, per fotografarlo.
///
/// **IL LIMITE, DICHIARATO.** In prova non esiste un `FirebaseAI`, quindi
/// l'anteprima non puo' far parlare Gemini: il testo lo mette questa classe.
/// Per questo NON e' inventato. Il "dopo" e' copiato parola per parola da una
/// risposta VERA misurata il 2 agosto 2026 con
/// `flutter test tool/risposte_intere.dart`, novantuno parole,
/// `finishReason: STOP`. Il "prima" e' copiato dallo schermo del fondatore.
/// L'immagine mostra come l'app IMPAGINA quel testo, non che il modello lo
/// scriva: quello lo dice la misura, che sta nel rapporto.
class _VoceConUnTesto implements MaestroAiProvider {
  _VoceConUnTesto(this.testo);

  final String testo;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      testo;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

class _VoceCheRisponde implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
      'Non è fermo chi si raccoglie: è fermo chi si nasconde. '
      'Questa settimana scegli una cosa sola e portala fino in fondo.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Una voce accesa che fallisce a ogni chiamata: e' lo stato reale del
/// progetto finche' firebasevertexai.googleapis.com resta spenta.
class _VoceCheTace implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      throw Exception('firebasevertexai.googleapis.com non abilitata');

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw Exception('firebasevertexai.googleapis.com non abilitata');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw Exception('firebasevertexai.googleapis.com non abilitata');

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      throw Exception('firebasevertexai.googleapis.com non abilitata');
}

/// Una voce pronta che risponde con calma: quanto basta perche' l'attesa
/// esista e la scena della voce 1 abbia qualcosa da accompagnare.
class _VoceLenta implements MaestroAiProvider {
  const _VoceLenta();

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'Il cielo osserva con te questa domanda e la tiene aperta. '
        'Guarda quel che torna due volte nello stesso giorno. '
        'Consiglio: annota stasera quel che il mattino ti ha detto.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
