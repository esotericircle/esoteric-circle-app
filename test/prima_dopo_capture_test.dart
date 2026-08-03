import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
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

  testWidgets('I tre fotogrammi della sequenza intro', (tester) async {
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

    // 1. La frase a meta' scrittura.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(
        SequenzaIntro.cadenzaPer(SequenzaIntro.voceDiRipiego) * 12);
    await scatta('frase');

    // 2. Il logo. In prova headless il video non si riproduce, quindi la
    //    sequenza passa oltre da sola e si arriva qui.
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.duranteIlNero);
    await tester.pump(SequenzaIntro.dissolvenza);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(SequenzaIntro.dissolvenza);
    await scatta('logo');

    // 3. La destinazione, dopo che la sequenza e' finita.
    await tester.pump(SequenzaIntro.duranteIlLogo);
    await tester.pump(SequenzaIntro.dissolvenza);
    await tester.pump(SequenzaIntro.dissolvenza);
    await scatta('destinazione');
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
                data: MediaQuery.of(ctx)
                    .copyWith(disableAnimations: stato.value.fermo),
                child: RepaintBoundary(
                  key: radice,
                  child: Scaffold(
                    backgroundColor: const Color(0xFF080B1A),
                    body: Center(
                      child: ConsultoDelCieloView(
                        natal: stato.value.natal,
                        maestro: Maestro.medora,
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
      await tester.pump(const Duration(milliseconds: 200));

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
    bool approfondisci = false,
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
    bool approfondisci = false,
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
    bool approfondisci = false,
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
