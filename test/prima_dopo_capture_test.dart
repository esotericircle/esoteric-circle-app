import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
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
                      child: ConsultoDelCieloView(natal: stato.value.natal),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
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
}

/// Una carta natale piena, per le anteprime del consulto.
const _cartaPiena = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Pesci',
  ascendant: 'Vergine',
);

/// Una voce che risponde davvero, per fotografare una conversazione riuscita.
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
