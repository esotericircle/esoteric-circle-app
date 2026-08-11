import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_test_screen.dart';
import 'package:esoteric_circle/features/angels/angels_screen.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as luogo;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'dart:convert' show jsonEncode;
import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_screen.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:esoteric_circle/features/onboarding/custodia_del_cielo_step.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:esoteric_circle/features/onboarding/planisfero.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/onboarding/trionfi_screen.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
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
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
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
                    child: const PannelloDiMessaAPunto(
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

  // ORDINE 2163, VOCE 2: il pannello dei suggerimenti nel colore di casa.
  // In casa Medora, blu notte: nella prima esce col colore sbagliato, nella
  // dopo veste il blu della schermata.
  testWidgets('2163, il pannello nel colore di casa', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      // La data c'e': la famiglia delle personali compare, ed e' la coppia
      // che serve anche alla voce 3, il pannello unito.
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: _VoceConUnTesto('Il cielo osserva con te questa domanda.'),
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
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).first, 'Ciao');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text('Suggerimenti').first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await scattaApp(tester, radice, 'pannello_colore');
  });

  // ORDINE 2163, VOCE 6: la barra nel Consiglio. Nella prima una voce di
  // Maestro e' accesa e il fondo e' colorato; nella dopo nessuna voce e
  // fondo neutro, perche' il Consiglio non e' di nessuno.
  testWidgets('2163, la barra nel consiglio', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(
          conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(AskMaestriScreen.perLaSintesi(
      starter: Maestro.caligo,
      tema: 'una scelta da fare',
      lenti: [
        MaestroLens.strati(
            maestro: Maestro.medora,
            glance: 'le stelle',
            reading: 'il cielo tiene aperta la domanda',
            invite: 'guarda stasera'),
        MaestroLens.strati(
            maestro: Maestro.aura,
            glance: 'il respiro',
            reading: 'il corpo conosce il suo passo',
            invite: 'ascolta il ritmo'),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 1200));

    await scattaApp(tester, radice, 'barra_consiglio');
  });

  // ORDINE 2163, VOCE 4: il primo schermo della chat. Nella prima la
  // colonna lunga dei suggerimenti; nella dopo il benvenuto, l'invito alle
  // stelline e l'assaggio di tre in riga.
  testWidgets('2163, il primo schermo della chat', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: _VoceConUnTesto('Il cielo osserva con te questa domanda.'),
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
    // Il mezzo busto si precarica, sempre: in headless nessuno lo decodifica.
    await tester.runAsync(() async {
      final el = tester.element(find.byType(MaterialApp));
      await precacheImage(AssetImage(Maestro.medora.avatarAsset), el);
    });
    await tester.pump(const Duration(milliseconds: 300));

    await scattaApp(tester, radice, 'primo_schermo');
  });

  // ORDINE 2163, VOCE 1: il campo di scrittura opaco. Una risposta lunga
  // scorre dietro al campo: nella prima si legge attraverso, nella dopo
  // sparisce sotto.
  testWidgets('2163, il campo opaco', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: _VoceConUnTesto(List.filled(
              12,
              'Il cielo tiene aperta la tua domanda e la osserva con te, '
              'riga dopo riga, senza fretta.')
          .join(' ')),
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
        MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).first, 'Chi sei tu?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    // La risposta lunga si porta dietro al campo, come negli screenshot.
    await tester.drag(find.byType(ListView).first, const Offset(0, 140),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));

    await scattaApp(tester, radice, 'campo_opaco');
  });

  // ORDINE 2163, VOCE 11: il Soffio dentro l'app. Nella prima il respiro
  // parte DA SOLO: la scena dell'invito non ha nessun pulsante, e la seconda
  // scatta mostra "Inspira" gia' in corso senza che nessuno abbia toccato.
  // Nella dopo c'e' il pulsante "Tocca per cominciare" e la seconda scatta
  // mostra il conto alla rovescia sul 2. Lo stesso file gira sui due alberi,
  // quindi il ramo si sceglie guardando se il pulsante esiste.
  testWidgets('2163, il soffio parte quando decidi tu', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child:
          EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(BreathDestinyScreen.route(now: DateTime(2026, 8, 7, 10, 30)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // I livelli del prato e del soffione si decodificano solo dentro
    // runAsync: senza questo giro la prima scatta esce su fondo nero.
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(BreathDestinyScreen));
      for (final asset in const [
        'assets/ritual_backgrounds/breath_meadow.png',
        'assets/ritual_backgrounds/breath_dandelion.png',
      ]) {
        await precacheImage(AssetImage(asset), ctx);
      }
    });
    await tester.pump(const Duration(milliseconds: 600));

    // Il gesto col ripiego tattile: il respiro compare a dono rivelato.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await scattaApp(tester, radice, 'soffio_invito');

    final tocca = find.byKey(const Key('respiro_tocca'));
    if (tocca.evaluate().isNotEmpty) {
      await tester.tap(tocca);
      await tester.pump();
      // Un secondo dopo il tocco il conto dice 2; ancora un decimo perche'
      // il numero appena nato si veda pieno.
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 120));
    } else {
      // Albero vecchio: si aspetta e il respiro parte da solo, che e'
      // esattamente il difetto da mostrare. La guida nasce a fine
      // dispersione, circa un secondo e mezzo dopo il gesto, e il suo timer
      // dura altri due: la prima stesura aspettava 1,7 secondi e fotografava
      // ancora l'apertura, misurato sulla scatta stessa.
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await scattaApp(tester, radice, 'soffio_conto');
  });

  // ORDINE 2163, VOCE 12: i due trionfi dell'onboarding. Nella prima sotto
  // l'animale e sotto i tre angeli resta il vuoto; nella dopo c'e' il
  // riquadro della scelta con le caratteristiche e la ragione. I trionfi si
  // montano come li monta il viaggio del risveglio, con dati fissi.
  // ORDINE 2164. Le scene delle otto voci di pulizia, tutte a 1080 pixel di
  // larghezza sulla misura del fondatore.
  //
  // - chat_pulita: il primo schermo (voci 3 e 4: via l'assaggio e il
  //   pulsante) piu' la riga del campo senza fascia (voce 2) e le stelline
  //   al centro (voce 5).
  // - barra_trasparente: la barra in fondo alla home (voce 1).
  // - scena_senza_riquadro: la scena di attesa sopra una conversazione
  //   (voce 6).
  // - pannello_due_titoli: il pannello dei suggerimenti (voce 7).
  // - soffio_pulsante: il pulsante del respiro con la scheda sotto (voce 8).
  // ORDINE DEL CIELO DIPINTO UNA VOLTA: LA PARITA' VISIVA.
  //
  // Cinque scene rappresentative, le stesse prima e dopo, per guardare se
  // l'occhio si accorge di qualcosa. Il criterio e' dichiarato nell'ordine:
  // se qualcosa cambia visibilmente e' un difetto da correggere, non un
  // compromesso da accettare.
  //
  // **Le scene si catturano a MOTO FERMO**, con Riduci Movimento acceso: non
  // per nascondere qualcosa, ma perche' un cielo che scintilla fotografato in
  // due istanti diversi darebbe due immagini diverse anche senza toccare una
  // riga, e il confronto non direbbe piu' niente. Cio' che questa coppia deve
  // mostrare e' la GEOMETRIA e il COLORE del cielo: stesse stelle, stesse
  // nebulose, stessi pianeti, stesse costellazioni, stessa parallasse.
  testWidgets('cielo, le cinque scene', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: _VoceConUnTesto('Il cielo osserva con te questa domanda.'),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: EsotericCircleApp(conIntro: false, services: servizi),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await scattaApp(tester, radice, 'cielo_home');

    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(DomainScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await scattaApp(tester, radice, 'cielo_dominio');

    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await scattaApp(tester, radice, 'cielo_chat');

    nav.pop();
    await tester.pump();
    nav.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // IL RITO: il cosmo con la palette imposta dall'elemento del giorno.
    nav.push(MaterialPageRoute<void>(
      // Il rito monta il cosmo con la palette imposta, come fanno i riti
      // quotidiani: fuori dal guscio serve lo scope, che dentro l'app c'e'
      // sempre e in una rotta nuda no.
      builder: (_) => const MaestroScope(
        maestro: Maestro.aura,
        child: CosmosBackground(
          seed: 41,
          showZodiac: true,
          child: SizedBox.expand(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await scattaApp(tester, radice, 'cielo_rito');
  });

  testWidgets('cielo, l\'onboarding', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: EsotericCircleApp(
            conIntro: false, services: AppServices.offline()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await scattaApp(tester, radice, 'cielo_onboarding');
  });

  testWidgets('2164, la chat pulita e la barra trasparente', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = AppServices(
      ai: _VoceConUnTesto('Il cielo osserva con te questa domanda, e la '
          'risposta si posa dove tu la stai gia\' cercando.'),
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

    // LA BARRA nella home, dove la sfumatura si posa sul contenuto.
    final scroll = find.byType(SingleChildScrollView);
    if (scroll.evaluate().isNotEmpty) {
      for (var i = 0; i < 8; i++) {
        await tester.drag(scroll.first, const Offset(0, -300),
            warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
    await tester.pump(const Duration(milliseconds: 400));
    await scattaApp(tester, radice, 'barra_trasparente');

    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await scattaApp(tester, radice, 'chat_pulita');

    // IL PANNELLO: si apre dall'unica porta rimasta, le stelline.
    final stelline = find.byKey(const Key('chat_stelline'));
    await tester.tap(
        stelline.evaluate().isNotEmpty
            ? stelline
            : find.text('Suggerimenti').first,
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await scattaApp(tester, radice, 'pannello_due_titoli');
  });

  testWidgets('2164, la scena di attesa senza riquadro', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // La voce tace: la scena di attesa resta a video, che e' cio' che si
    // deve guardare.
    final servizi = AppServices(
      ai: _VoceCheTace(),
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
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(
        find.byType(TextField).first, 'Cosa dicono le stelle sul mio amore?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await scattaApp(tester, radice, 'scena_senza_riquadro');
    // La scena del consulto fa ruotare le sue frasi con un timer: si lascia
    // scadere, altrimenti resta pendente e la cattura cade dopo aver gia'
    // scattato bene.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('2164, il pulsante del Soffio', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // LE BARRE DI SISTEMA: senza di loro il difetto non esiste, ed e'
        // il motivo per cui su schermo nudo non si vedeva.
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 797),
            padding: EdgeInsets.only(top: 40, bottom: 24),
          ),
          child: BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(BreathDestinyScreen));
      for (final asset in const [
        'assets/ritual_backgrounds/breath_meadow.png',
        'assets/ritual_backgrounds/breath_dandelion.png',
      ]) {
        await precacheImage(AssetImage(asset), ctx);
      }
    });
    await tester.pump(const Duration(milliseconds: 600));
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await scattaApp(tester, radice, 'soffio_pulsante');
  });

  testWidgets('2163, i riquadri dei trionfi', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final paletteCaligo =
        MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final radice = GlobalKey();

    Future<void> monta(Widget trionfo) async {
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF05060A),
            body: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: trionfo,
            ),
          ),
        ),
      ));
      await tester.pump();
      // L'arte del totem e delle carte si decodifica dentro runAsync.
      await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 400)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
    }

    await monta(TrionfoAnimale(
      animale: GuideAnimalDerivation.forSign(Zodiac.taurus),
      palette: paletteCaligo,
      reduceMotion: true,
      onContinue: () {},
    ));
    await scattaApp(tester, radice, 'trionfo_animale');

    await monta(TrionfoAngeli(
      triade: AngelTriad(
        guardian: AngelCatalog.byNumber(3),
        heart: AngelCatalog.byNumber(31),
        intellect: GuardianAngels.intellectFor(10, 30),
        sunLongitude: 134.6,
        dayOfYear: 219,
        minuteOfDay: 10 * 60 + 30,
      ),
      palette: paletteCaligo,
      reduceMotion: true,
      onContinue: () {},
    ));
    await scattaApp(tester, radice, 'trionfo_angeli');
  });

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

  // ORDINE 2169, VOCE 9: il luogo scelto sul planisfero. La "prima" e' la
  // stella con l'alone e i quattro raggi, la "dopo" sono le tre onde
  // concentriche che si allargano dal punto.
  // ORDINE 2171, VOCE 6: la scena a taglio compiuto. Il gesto adesso taglia
  // davvero il mazzo, e questa cattura mostra il ventaglio risteso dopo il
  // taglio.
  // ORDINE 2171, VOCE 5: l'Oroscopo come consulto. Due scatti, all'apertura
  // e dopo il tocco, perche' la differenza sta proprio fra i due momenti.
  testWidgets('2171, l Oroscopo all apertura e dopo il tocco',
      (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: radice,
          child: MaestroScope(
            child: OroscopoScreen(
              userSign: Zodiac.leo,
              now: DateTime(2026, 7, 10),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await scattaApp(tester, radice, 'oroscopo_apertura');

    final interroga = find.byKey(const Key('oroscopo_interroga'));
    if (interroga.evaluate().isNotEmpty) {
      await tester.tap(interroga);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
    }
    await scattaApp(tester, radice, 'oroscopo_consulto');
  });


  testWidgets('2171, la stesa a taglio compiuto', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: radice,
          child: const MaestroScope(
            child: StesaTreCarteScreen(seed: 4),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.byKey(const Key('stesa_taglia')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    await scattaApp(tester, radice, 'stesa_taglio');
  });


  testWidgets('2169, il punto del luogo sul planisfero', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    // Il rapporto e' quello del corredo, tre, come tutte le altre catture:
    // la misura fisica e' percio' tre volte lo spazio logico che serve.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(2160, 1140);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF05040A),
          body: RepaintBoundary(
            key: radice,
            child: const SizedBox(
              width: 720,
              height: 380,
              // Torino, come nel Risveglio di chi sceglie la propria citta'.
              child: Planisfero(
                palette: MaestroPalette.neutral,
                luogo: (lat: 45.07, lon: 7.69),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await scattaApp(tester, radice, 'planisfero_luogo');
  });

  // ORDINE A: LA TIPOGRAFIA DELL'OROSCOPO.
  //
  // **Perche' sta qui e non nel corredo.** Il corredo rigenera tutto a ogni
  // giro, quindi la "prima" verrebbe riscritta col codice di oggi e sparirebbe
  // al primo aggiornamento: e' la stessa ragione per cui questo file esiste. Le
  // due fasi si producono con lo STESSO blocco, la stessa misura e gli stessi
  // tempi, cambiando solo l'albero sotto, cioe' lanciandolo una volta su un
  // albero di lavoro fermo al commit precedente.
  //
  // I FONT SI CARICANO A MANO, e non e' un dettaglio: senza, il testo esce col
  // ripiego, cioe' blocchi neri in cattura, e un'anteprima della TIPOGRAFIA
  // scritta col carattere sbagliato non prova assolutamente niente.
  testWidgets('A, la tipografia dell\'Oroscopo', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    for (final (famiglia, percorso) in const [
      ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
      ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
    ]) {
      final loader = FontLoader(famiglia);
      final bytes = File(percorso).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    // La misura del telefono di Mauro: 360 per 797 punti logici, che a rapporto
    // tre fanno i 1080 per 2391 pixel del corredo.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(OroscopoScreen.route(
        userSign: Zodiac.aries, now: DateTime(2026, 7, 10))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() async {
      final element = tester.element(find.byType(OroscopoScreen));
      await precacheImage(
          AssetImage(ZodiacArt.emblemPath(Zodiac.aries)), element);
    });
    // LA CASCATA D'INGRESSO DEVE AVER FINITO. Con due soli quarti di secondo le
    // voci sotto i periodi erano ancora trasparenti: meta' immagine vuota, e il
    // confronto avrebbe attribuito alla tipografia un vuoto che era soltanto
    // un'animazione colta a meta'.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await scattaApp(tester, radice, 'oroscopo_tipografia');

    // E la stessa scena a consulto aperto, dove vive il responso: e' li' che si
    // vede se il testo e' un muro oppure respira.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));
    // Si scorre fino al responso: senza, l'immagine si ferma sull'emblema e
    // mostra due righe di testo su millecinquecento pixel di ariete. La quota
    // e' dichiarata invece che cercata, cosi' le due fasi guardano lo stesso
    // punto della pagina anche se il testo sotto e' composto in modo diverso.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1500));
    await tester.pump();
    // Le schede sotto la piega nascono quando ci si arriva, quindi il loro
    // responso comincia a comporsi adesso: senza questa attesa il primo scatto
    // le coglieva a meta' frase.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));
    await scattaApp(tester, radice, 'oroscopo_tipografia_consulto');
  });

  // ORDINE B, voce 2: IL PERCORSO PRIORITARIO NEI RUOLI.
  //
  // Quattro scene, le stesse quattro che l'ordine nomina: il Risveglio, il
  // Santuario, la Stesa e la chat. Stessa misura, stessi tempi e stesso blocco
  // per tutte e due le fasi, cosi' il confronto misura la tipografia e non
  // l'apparato.
  for (final scena in const ['risveglio', 'santuario', 'stesa', 'chat']) {
    testWidgets('B, il percorso prioritario, $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        final bytes = File(percorso).readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      }
      // Il Risveglio si apre solo a chi non l'ha ancora fatto: per le altre tre
      // scene si parte da chi torna, altrimenti l'app mostra l'onboarding.
      SharedPreferences.setMockInitialValues(scena == 'risveglio'
          ? const {}
          : const {'onboarding.done': true, 'santuario.greeted': true});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child:
            EsotericCircleApp(conIntro: false, services: AppServices.offline()),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));

      if (scena == 'stesa') {
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        unawaited(nav.push(StesaTreCarteScreen.route(seed: 7)));
      } else if (scena == 'chat') {
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        unawaited(nav.push(MaestroChatScreen.route(
            maestro: Maestro.medora, services: AppServices.offline())));
      }
      // GLI AVATAR SI PRECARICANO, sempre: senza, le tre carte del Santuario
      // escono VUOTE in cattura, perche' in headless un'immagine non si
      // decodifica se nessuno la mette in cache prima. E' successo davvero,
      // e un'anteprima con tre riquadri vuoti non fa giudicare niente.
      await tester.runAsync(() async {
        final element = tester.element(find.byType(MaterialApp));
        for (final m in Maestro.values) {
          await precacheImage(AssetImage(m.avatarAsset), element);
        }
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await scattaApp(tester, radice, 'percorso_$scena');
    });
  }

  // ORDINE C, voce 2: LE QUATTRO SCHERMATE PIU' PESANTI.
  //
  // Stessa misura, stessi tempi e stesso blocco per le due fasi, come per le
  // altre coppie: si lancia questo file su un albero fermo al commit precedente
  // con STATO=prima, e sull'albero corrente con STATO=dopo.
  for (final scena in const ['angeli', 'archetipo', 'volto', 'rune']) {
    testWidgets('C, le quattro schermate, $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        final bytes = File(percorso).readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      }
      SharedPreferences.setMockInitialValues(
          const {'onboarding.done': true, 'santuario.greeted': true});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child:
            EsotericCircleApp(conIntro: false, services: AppServices.offline()),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));

      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      switch (scena) {
        case 'angeli':
          unawaited(nav.push(AngelsScreen.route(
              identity: BirthIdentity(
                  birthMoment: DateTime(1990, 6, 15, 14, 30)))));
        case 'archetipo':
          unawaited(nav.push(ArchetypeTestScreen.route()));
        case 'volto':
          unawaited(nav.push(FaceConstellationScreen.route()));
        case 'rune':
          unawaited(nav.push(RuneDrawScreen.route(
              userSign: Zodiac.aries,
              userBirth: DateTime(1990, 6, 15),
              random: math.Random(7))));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await scattaApp(tester, radice, 'schermata_$scena');
    });
  }

  // ORDINE H: LE OTTO SCENE, prima e dopo. Stesso blocco, stessa misura,
  // stessi tempi sui due alberi.
  for (final scena in const [
    'rune_telo',
    'rune_scheda',
    'rune_presagio',
    'rune_sigillo',
    'chat_tastiera',
    'tramonto_h',
    'stesa_mischia',
    'stesa_taglio',
  ]) {
    testWidgets('H, la scena $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        final bytes = File(percorso).readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      }
      SharedPreferences.setMockInitialValues(
          const {'onboarding.done': true, 'santuario.greeted': true});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child:
            EsotericCircleApp(conIntro: false, services: AppServices.offline()),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);

      Future<void> attesa([int ms = 2400]) async {
        await tester.pump();
        await tester.pump(Duration(milliseconds: ms));
        await tester.pump(const Duration(milliseconds: 600));
      }

      switch (scena) {
        case 'rune_telo' || 'rune_scheda' || 'rune_presagio' || 'rune_sigillo':
          unawaited(nav.push(RuneDrawScreen.route(
              userSign: Zodiac.aries,
              userBirth: DateTime(1990, 6, 15),
              random: math.Random(7))));
          await attesa();
          // La gettata sul telo, che e' la scena dell'ordine.
          await tester.ensureVisible(find.text('Il getto sul telo'));
          await tester.pump();
          await tester.tap(find.text('Il getto sul telo'),
              warnIfMissed: false);
          await attesa(800);
          await tester.runAsync(() async {
            final el = tester.element(find.byType(MaterialApp));
            for (final r in kElderFuthark) {
              if (r.thumbPath != null) {
                await precacheImage(AssetImage(r.thumbPath!), el);
              }
              // ANCHE LA PIETRA PIENA: la card della scheda usa fullPath,
              // non thumbPath, e in una corsa a scena singola nessun'altra
              // prova l'ha gia' decodificata: senza questa riga la
              // miniatura della scheda esce vuota, visto sull'anteprima.
              if (r.fullPath != null) {
                await precacheImage(AssetImage(r.fullPath!), el);
              }
            }
          });
          await tester.ensureVisible(
              find.byKey(const Key('rune_cast_button')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('rune_cast_button')),
              warnIfMissed: false);
          await attesa(3200);
          if (scena == 'rune_scheda') {
            await tester.drag(
                find.byKey(const Key('rune_result')), const Offset(0, -700));
            await attesa(600);
          } else if (scena == 'rune_presagio') {
            await tester.scrollUntilVisible(
                find.byKey(const Key('rune_presage')), 400,
                scrollable: find.byType(Scrollable).first);
            await attesa(600);
          } else if (scena == 'rune_sigillo') {
            await tester.scrollUntilVisible(
                find.byKey(const Key('rune_sigillo')), 400,
                scrollable: find.byType(Scrollable).first);
            await attesa(600);
          }
        case 'chat_tastiera':
          unawaited(nav.push(MaestroChatScreen.route(
              maestro: Maestro.medora, services: AppServices.offline())));
          await attesa();
          // LA TASTIERA APERTA: si simula l'inset di sistema, che e' cio'
          // che la tastiera fa allo schermo, e si mette il fuoco nel campo.
          tester.view.viewInsets = const FakeViewPadding(bottom: 280 * 3);
          await tester.showKeyboard(find.byType(TextField).first);
          await tester.enterText(
              find.byType(TextField).first, 'Che mi dice il cielo stasera?');
          await attesa(800);
        case 'tramonto_h':
          unawaited(nav.push(SunsetRuneScreen.route(
              now: DateTime(2026, 8, 10, 21, 30),
              dataNascita: DateTime(1988, 7, 5))));
          await attesa();
          await tester.runAsync(() async {
            final el = tester.element(find.byType(MaterialApp));
            for (final r in kElderFuthark) {
              final vergine = pathVergineDi(r.stem);
              if (vergine != null) {
                await precacheImage(AssetImage(vergine), el);
              }
            }
          });
          await attesa(600);
        case 'stesa_mischia' || 'stesa_taglio':
          unawaited(nav.push(StesaTreCarteScreen.route(seed: 7)));
          // A passi brevi: la regia porta la scena a riposo in una catena di
          // callback, e un pump solo da tre secondi la lascia a meta'.
          for (var i = 0; i < 10; i++) {
            await tester.pump(const Duration(milliseconds: 400));
          }
          // Il dorso del mazzo si precarica: in headless un'immagine non
          // decodificata non si dipinge, e le carte del gesto sarebbero
          // contorni invisibili sul cosmo.
          await tester.runAsync(() async {
            final el = tester.element(find.byType(MaterialApp));
            await precacheImage(AssetImage(TarotDeck.dorsoThumb), el);
            await precacheImage(AssetImage(TarotDeck.dorsoFull), el);
          });
          await attesa(400);
          final gesto = scena == 'stesa_mischia' ? 'Mischia' : 'Taglia';
          await tester.ensureVisible(find.text(gesto));
          await tester.pump();
          await tester.tap(find.text(gesto));
          await tester.pump();
          // A META' DELL'ATTO CENTRALE: la mescola vive fra 0,30 e 0,70 di
          // 1600 ms, il taglio in divisione fra 0,28 e 0,52 di 1400 ms. A
          // passi brevi e non con un salto solo, cosi' il ticker macina frame
          // veri come sul telefono.
          final passi = scena == 'stesa_mischia' ? 8 : 5;
          for (var i = 0; i < passi; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
      }
      await scattaApp(tester, radice, scena);
      // La stesa resta a meta' animazione: si lascia finire, altrimenti il
      // tester segnala il timer vivo.
      await tester.pump(const Duration(seconds: 3));
    });
  }

  // ORDINE I: LE SETTE SCENE, prima e dopo. I tre domini col busto, la chat
  // di un Maestro, la scheda Carriera in Breve e in Profonda, le rune col
  // pulsante esaurito.
  final cartaOrdineI = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '\u2609',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '\u263d',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '\u2640',
          longitude: 150.2,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '\u2642',
          longitude: 61.9,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn',
          name: 'Saturno',
          glyph: '\u2644',
          longitude: 300.5,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  for (final scena in const [
    'dominio_medora',
    'dominio_caligo',
    'dominio_aura',
    'chat_maestro_i',
    'oroscopo_breve_i',
    'oroscopo_profonda_i',
    'rune_esaurite',
  ]) {
    testWidgets('I, la scena $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        final bytes = File(percorso).readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      }
      SharedPreferences.setMockInitialValues(
          const {'onboarding.done': true, 'santuario.greeted': true});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();

      Future<void> attesa([int ms = 2400]) async {
        await tester.pump();
        await tester.pump(Duration(milliseconds: ms));
        await tester.pump(const Duration(milliseconds: 600));
      }

      Future<void> precaricaAvatar() async {
        await tester.runAsync(() async {
          final el = tester.element(find.byType(MaterialApp));
          for (final m in Maestro.values) {
            await precacheImage(AssetImage(m.avatarAsset), el);
          }
        });
      }

      switch (scena) {
        case 'dominio_medora' || 'dominio_caligo' || 'dominio_aura':
          await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: EsotericCircleApp(
                conIntro: false, services: AppServices.offline()),
          ));
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          final nav =
              tester.state<NavigatorState>(find.byType(Navigator).first);
          final maestro = switch (scena) {
            'dominio_medora' => Maestro.medora,
            'dominio_caligo' => Maestro.caligo,
            _ => Maestro.aura,
          };
          unawaited(nav.push(DomainScreen.route(
              maestro: maestro, services: AppServices.offline())));
          await attesa();
          await precaricaAvatar();
          await attesa(800);
        case 'chat_maestro_i':
          await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: EsotericCircleApp(
                conIntro: false, services: AppServices.offline()),
          ));
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          final nav =
              tester.state<NavigatorState>(find.byType(Navigator).first);
          unawaited(nav.push(MaestroChatScreen.route(
              maestro: Maestro.caligo, services: AppServices.offline())));
          await attesa();
          await precaricaAvatar();
          await attesa(800);
        case 'oroscopo_breve_i' || 'oroscopo_profonda_i':
          final nascita = BirthIdentityController();
          nascita.setBirth(
            BirthDetails(
              date: DateTime(1990, 8, 10),
              time: const TimeOfDay(hour: 12, minute: 0),
              place: const luogo.BirthPlace(
                  label: 'Roma',
                  latitude: 41.9,
                  longitude: 12.5,
                  timezone: 'Europe/Rome'),
            ),
            cartaOrdineI,
          );
          await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => MaestroController()),
                ChangeNotifierProvider(
                    create: (_) => EntitlementService(initial: Tier.tier1)),
                ChangeNotifierProvider(
                    create: (_) => QualityTierController()),
                ChangeNotifierProvider(create: (_) => ParallaxController()),
                ChangeNotifierProvider(create: (_) => ZodiacController()),
                ChangeNotifierProvider(create: (_) => ProfileController()),
                ChangeNotifierProvider<BirthIdentityController>.value(
                    value: nascita),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark(),
                builder: (ctx, child) => MaestroScope(child: child!),
                home: OroscopoScreen(
                    userSign: Zodiac.leo,
                    now: DateTime.utc(2026, 8, 5, 12)),
              ),
            ),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await tester.tap(find.byKey(const Key('oroscopo_interroga')));
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          for (var i = 0; i < 8; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }
          await tester.scrollUntilVisible(
              find.byKey(const Key('oroscopo_depth_carriera')), 400,
              scrollable: find.byType(Scrollable).first);
          await tester.pump();
          if (scena == 'oroscopo_profonda_i') {
            await tester
                .tap(find.byKey(const Key('oroscopo_depth_carriera')));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            await tester.tap(find.text('Profonda').last);
            await tester.pump();
            for (var i = 0; i < 14; i++) {
              await tester.pump(const Duration(milliseconds: 500));
            }
          }
          // La scheda Carriera in vista, col suo inizio in alto. LO
          // SCORRIMENTO RIMONTA LA CARD e la scrittura riparte da capo:
          // la si lascia finire, altrimenti la scena esce a meta' riga.
          await tester.dragUntilVisible(
              find.byKey(const Key('oroscopo_card_carriera')),
              find.byType(Scrollable).first,
              const Offset(0, -80));
          await tester.pump(const Duration(milliseconds: 300));
          for (var i = 0; i < 8; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }
        case 'rune_esaurite':
          await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (_) => MaestroController(
                        initial: const ThemeKey.of(Maestro.caligo))),
                ChangeNotifierProvider(
                    create: (_) => QualityTierController()),
                ChangeNotifierProvider(create: (_) => ParallaxController()),
                ChangeNotifierProvider(create: (_) => ZodiacController()),
                ChangeNotifierProvider(create: (_) => EntitlementService()),
                ChangeNotifierProvider(create: (_) => QuestionAllowance()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark(),
                builder: (ctx, child) => MaestroScope(child: child!),
                home: RuneDrawScreen(
                    userSign: Zodiac.aries, random: math.Random(9)),
              ),
            ),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
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
          // Tre getti: il primo dal pulsante, gli altri da Getta ancora.
          await tester
              .ensureVisible(find.byKey(const Key('rune_cast_button')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('rune_cast_button')));
          await attesa(800);
          for (var i = 0; i < 2; i++) {
            await tester
                .ensureVisible(find.byKey(const Key('rune_recast')));
            await tester.pump();
            await tester.tap(find.byKey(const Key('rune_recast')));
            await attesa(800);
          }
          await tester.ensureVisible(find.byKey(const Key('rune_recast')));
          await tester.pump(const Duration(milliseconds: 400));
      }
      await scattaApp(tester, radice, scena);
      await tester.pump(const Duration(seconds: 3));
    });
  }

  // ORDINE L: LE NOVE SCENE, prima e dopo. L'Oroscopo dopo lo scorrimento e
  // la bolla del premium; la testa delle rune col conto (pieno, a due, a
  // zero); la stella che chiama nel Sogno; l'Animale in tre momenti.
  final cartaOrdineL = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '\u2609',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '\u263d',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '\u2640',
          longitude: 150.2,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '\u2642',
          longitude: 61.9,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn',
          name: 'Saturno',
          glyph: '\u2644',
          longitude: 300.5,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  for (final scena in const [
    'oroscopo_ritorno_l',
    'oroscopo_bolla_premium_l',
    'rune_testa_l',
    'rune_conto_due_l',
    'rune_conto_zero_l',
    'sogno_stella_l',
    'animale_punti_l',
    'animale_sagoma_l',
    'animale_rivelato_l',
  ]) {
    testWidgets('L, la scena $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        final bytes = File(percorso).readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      }
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final radice = GlobalKey();

      Future<void> attesa([int ms = 1200]) async {
        await tester.pump();
        await tester.pump(Duration(milliseconds: ms));
        await tester.pump(const Duration(milliseconds: 400));
      }

      Future<void> montaOroscopo({required Tier piano}) async {
        SharedPreferences.setMockInitialValues(const {});
        final nascita = BirthIdentityController();
        nascita.setBirth(
          BirthDetails(
            date: DateTime(1990, 8, 10),
            time: const TimeOfDay(hour: 12, minute: 0),
            place: const luogo.BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          cartaOrdineL,
        );
        await tester.pumpWidget(RepaintBoundary(
          key: radice,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(
                  create: (_) => EntitlementService(initial: piano)),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => ZodiacController()),
              ChangeNotifierProvider(create: (_) => ProfileController()),
              ChangeNotifierProvider<BirthIdentityController>.value(
                  value: nascita),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              // LO SCOPE DICHIARA MEDORA, come fa la rotta vera con
              // SogliaArte: senza, la bolla dell'invito esce nel viola
              // neutro invece che nel blu di Medora. Visto sull'anteprima.
              builder: (ctx, child) =>
                  MaestroScope(maestro: Maestro.medora, child: child!),
              home: OroscopoScreen(
                  userSign: Zodiac.leo, now: DateTime.utc(2026, 8, 5, 12)),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byKey(const Key('oroscopo_interroga')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      Future<void> montaRune() async {
        SharedPreferences.setMockInitialValues(const {});
        await tester.pumpWidget(RepaintBoundary(
          key: radice,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => MaestroController(
                      initial: const ThemeKey.of(Maestro.caligo))),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => ZodiacController()),
              ChangeNotifierProvider(create: (_) => EntitlementService()),
              ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              builder: (ctx, child) => MaestroScope(child: child!),
              home: RuneDrawScreen(
                  userSign: Zodiac.aries, random: math.Random(9)),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
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
      }

      Future<void> gettaUna() async {
        await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('rune_cast_button')));
        await attesa(800);
      }

      Future<void> gettaAncora() async {
        await tester.ensureVisible(find.byKey(const Key('rune_recast')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('rune_recast')));
        await attesa(800);
      }

      Future<void> montaAnimale() async {
        final esito = ArchetypeEsito(
          quando: DateTime(2026, 7, 22, 10),
          percentuali:
              ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
          dominante: Archetype.realista,
        );
        SharedPreferences.setMockInitialValues({
          'archetipo.storico': [jsonEncode(esito.toJson())],
        });
        await tester.pumpWidget(RepaintBoundary(
          key: radice,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => MaestroController(
                      initial: const ThemeKey.of(Maestro.caligo))),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => ZodiacController()),
              ChangeNotifierProvider(create: (_) => EntitlementService()),
              ChangeNotifierProvider(create: (_) => QuestionAllowance()),
              ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              builder: (ctx, child) => MaestroScope(child: child!),
              home: const GuideAnimalScreen(userSign: Zodiac.cancer),
            ),
          ),
        ));
        await attesa(800);
        await tester.runAsync(() async {
          final el = tester.element(find.byType(MaterialApp));
          final animal = GuideAnimalDerivation.forSign(Zodiac.cancer);
          await precacheImage(AssetImage(animal.fullPath), el);
        });
        await attesa(400);
      }

      /// Unisce le stelle dell'animale se la scena nuova c'e'; altrimenti
      /// batte il tamburo dell'albero vecchio: il blocco gira su tutti e due.
      Future<void> avanzaIlViaggio(int passi) async {
        final stelle = find.byKey(const Key('animal_star_0'));
        if (stelle.evaluate().isNotEmpty) {
          for (var i = 0; i < passi; i++) {
            final k = find.byKey(Key('animal_star_$i'));
            if (k.evaluate().isEmpty) break;
            await tester.tap(k, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 120));
          }
        } else {
          for (var i = 0; i < passi; i++) {
            final tamburo = find.byKey(const Key('animal_drum'));
            if (tamburo.evaluate().isEmpty) break;
            await tester.tap(tamburo, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 120));
          }
        }
      }

      switch (scena) {
        case 'oroscopo_ritorno_l':
          await montaOroscopo(piano: Tier.tier1);
          // GIU' e poi SU: nel prima le schede rinascono vergini e si
          // riscrivono, nel dopo restano intere e ferme.
          final lista = find.byType(Scrollable).first;
          for (var i = 0; i < 5; i++) {
            await tester.drag(lista, const Offset(0, -700));
            await tester.pump(const Duration(milliseconds: 120));
          }
          for (var i = 0; i < 5; i++) {
            await tester.drag(lista, const Offset(0, 700));
            await tester.pump(const Duration(milliseconds: 120));
          }
          // La Generale in quadro col suo TESTO: e' li' che nel prima la
          // scrittura riparte monca e nel dopo resta intera e ferma.
          await tester.drag(lista, const Offset(0, -560));
          await tester.pump(const Duration(milliseconds: 350));
        case 'oroscopo_bolla_premium_l':
          await montaOroscopo(piano: Tier.free);
          await tester.scrollUntilVisible(
              find.byKey(const Key('oroscopo_depth_generale')), 300,
              scrollable: find.byType(Scrollable).first);
          await tester.pump();
          await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.text('Profonda').last);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        case 'rune_testa_l':
          await montaRune();
        case 'rune_conto_due_l':
          await montaRune();
          await gettaUna();
          await tester.ensureVisible(find.byKey(const Key('rune_recast')));
          await tester.pump(const Duration(milliseconds: 300));
        case 'rune_conto_zero_l':
          await montaRune();
          await gettaUna();
          await gettaAncora();
          await gettaAncora();
          await tester.ensureVisible(find.byKey(const Key('rune_recast')));
          await tester.pump(const Duration(milliseconds: 300));
        case 'sogno_stella_l':
          SharedPreferences.setMockInitialValues(const {});
          await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => MaestroController()),
                ChangeNotifierProvider(
                    create: (_) => QualityTierController()),
                ChangeNotifierProvider(create: (_) => ParallaxController()),
                ChangeNotifierProvider(create: (_) => ZodiacController()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark(),
                builder: (ctx, child) => MaestroScope(child: child!),
                home: DreamRiteScreen(now: DateTime(2026, 8, 10, 22, 30)),
              ),
            ),
          ));
          await attesa(800);
          await tester.tap(find.byKey(const Key('dream_fog_skip')));
          await attesa(800);
          // La prima stella si unisce: adesso la SECONDA chiama il tocco.
          await tester.tap(find.byKey(const Key('dream_star_0')),
              warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump(const Duration(milliseconds: 400));
        case 'animale_punti_l':
          await montaAnimale();
        case 'animale_sagoma_l':
          await montaAnimale();
          await avanzaIlViaggio(12);
          // Subito dopo l'ultima stella: la sagoma unita, prima del volo.
          await tester.pump(const Duration(milliseconds: 250));
        case 'animale_rivelato_l':
          await montaAnimale();
          await tester.ensureVisible(
              find.byKey(const Key('animal_journey_skip')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('animal_journey_skip')));
          await attesa(1200);
          await attesa(1600);
      }
      await scattaApp(tester, radice, scena);
      await tester.pump(const Duration(seconds: 4));
    });
  }

  // ORDINE M: LA HOME IN TRE QUADRI, prima e dopo. In cima la frase
  // personale, che nella prima sta sopra il pulsante del Dominio e passa
  // sopra il Maestro e nella dopo torna sotto la Luna; le Arti, dove la
  // descrizione dell'Oroscopo nella prima si taglia su "sul tuo segno di";
  // il fondo, dove nella prima la coda dello scorrimento non riservava la
  // barra. Le scene sono a moto fermo per confrontare la geometria: per il
  // MOVIMENTO l'anteprima non basta e fa fede la misura dichiarata nel
  // rapporto, campioni di pixel cambiati con l'interruttore di release.
  testWidgets('M, la home in cima, le arti e il fondo', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: EsotericCircleApp(
            conIntro: false, services: AppServices.offline()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    // I BUSTI DEI MAESTRI si decodificano solo col tempo vero: senza questo
    // giro la prima scatta esce coi dorsi vuoti, misurato sulla scatta
    // stessa.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 400));
    await scattaApp(tester, radice, 'home_cima_m');

    // LE ARTI: si scende finche' la card dell'Oroscopo non e' in quadro.
    final scroll = find.byType(SingleChildScrollView).first;
    for (var i = 0;
        i < 12 && find.textContaining('Oroscopo').evaluate().isEmpty;
        i++) {
      await tester.drag(scroll, const Offset(0, -400), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.drag(scroll, const Offset(0, -200), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    await scattaApp(tester, radice, 'arti_oroscopo_m');

    // IL FONDO, scorso davvero come nella scena della striscia.
    for (var i = 0; i < 20; i++) {
      await tester.drag(scroll, const Offset(0, -500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await scattaApp(tester, radice, 'home_fondo_m');
  });

  // ORDINE N: le due scene dell'identita'.
  //
  // - `custodia_risveglio_n`: l'ULTIMO passo del Risveglio, dove si chiede di
  //   non perdere il proprio cielo. Nella prima non esiste: il Risveglio
  //   finiva alla rivelazione del Maestro e nessuno chiedeva niente, quindi
  //   la scena si monta lo stesso e mostra cosa c'era al posto suo.
  // - `invito_a_custodire_n`: l'invito che torna a chi ha rimandato, col
  //   numero VERO dei momenti custoditi. Nella prima non esisteva.
  //
  // Le due scene si montano fuori dal Risveglio intero: montarlo tutto
  // vorrebbe dire attraversare il calcolo della carta, che senza rete non
  // arriva, e l'anteprima mostrerebbe un'attesa invece della scena.
  testWidgets('N, la custodia del cielo e l invito', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final (famiglia, percorso) in const [
      ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
      ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
    ]) {
      final loader = FontLoader(famiglia);
      loader.addFont(
          Future.value(ByteData.view(File(percorso).readAsBytesSync().buffer)));
      await loader.load();
    }

    final radice = GlobalKey();
    final account = AccountDelCerchio(porta: _IdentitaPerAnteprima());
    await account.avvia();

    Future<void> monta(Widget scena) async {
      await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
            ChangeNotifierProvider<AccountDelCerchio>.value(value: account),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            builder: (ctx, child) => MaestroScope(child: child!),
            home: scena,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
    }

    // LA PRIMA non ha ne' la scena ne' l'invito: al loro posto c'era la
    // rivelazione del Maestro, che chiudeva il Risveglio senza chiedere
    // niente. Si fotografa quella, cosi' il confronto mostra cosa e' stato
    // aggiunto e non un rettangolo vuoto.
    if (_stato == 'prima') {
      await monta(MaestroRevealScreen(
        maestro: Maestro.medora,
        onRevealed: (_) {},
      ));
      await tester.pump(const Duration(seconds: 3));
      await scattaApp(tester, radice, 'custodia_risveglio_n');
      await scattaApp(tester, radice, 'invito_a_custodire_n');
      return;
    }

    await monta(CustodiaDelCieloStep(
      maestro: Maestro.medora,
      suFine: () {},
    ));
    await scattaApp(tester, radice, 'custodia_risveglio_n');

    // L'INVITO col numero vero: sette momenti, come li conterebbe la memoria
    // di chi ha gia' parlato coi Maestri.
    await monta(
      Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: const Color(0xFF05060A),
          body: Center(
            child: TextButton(
              onPressed: () => mostraInvitoACustodire(ctx, momenti: 7),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('apri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await scattaApp(tester, radice, 'invito_a_custodire_n');
  });

  // ORDINE O: le scene dei Sigilli del Cammino.
  //
  // Nella PRIMA non esiste niente di tutto questo: i sentieri, la
  // celebrazione e il saldo nascono adesso, quindi la prima fotografa il
  // Passaporto com'era, che e' il posto da cui i sentieri si aprono.
  for (final scena in const [
    'sentiero_costellazione_o',
    'sentiero_albero_o',
    'sentiero_loto_o',
    'sentiero_a_meta_o',
    'celebrazione_grande_o',
    'sovrimpressione_mini_o',
    'card_riaperta_o',
  ]) {
    testWidgets('O, la scena $scena', (tester) async {
      if (_stato.isEmpty) return;
      silence();
      SharedPreferences.setMockInitialValues(const {});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final (famiglia, percorso) in const [
        ('Cinzel', 'assets/fonts/Cinzel-variable.ttf'),
        ('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'),
      ]) {
        final loader = FontLoader(famiglia);
        loader.addFont(Future.value(
            ByteData.view(File(percorso).readAsBytesSync().buffer)));
        await loader.load();
      }

      final radice = GlobalKey();
      final diario = DiarioDelCammino();
      await diario.carica();
      // UN CAMMINO GIA' COMINCIATO per la scena a meta': dodici Sigilli
      // accesi sulla Costellazione, cosi' la discesa si ferma davvero a
      // meta' strada invece che in cima.
      if (scena == 'sentiero_a_meta_o' ||
          scena == 'card_riaperta_o' ||
          scena == 'celebrazione_grande_o') {
        for (final t in Sentieri.miniDi(Sentiero.costellazione).take(12)) {
          await diario.accendi(t.id);
        }
        for (final t in Sentieri.miniDi(Sentiero.albero).take(4)) {
          await diario.accendi(t.id);
        }
      }
      final borsa = QuestionAllowance();

      Future<void> monta(Widget scena) async {
        await tester.pumpWidget(RepaintBoundary(
          key: radice,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => ZodiacController()),
              ChangeNotifierProvider(create: (_) => EntitlementService()),
              ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
              ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              builder: (ctx, child) => MaestroScope(child: child!),
              home: scena,
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
      }

      switch (scena) {
        case 'sentiero_costellazione_o':
          await monta(const SentieroScreen(
              sentiero: Sentiero.costellazione, senzaVolo: true));
        case 'sentiero_albero_o':
          await monta(
              const SentieroScreen(sentiero: Sentiero.albero, senzaVolo: true));
        case 'sentiero_loto_o':
          await monta(
              const SentieroScreen(sentiero: Sentiero.loto, senzaVolo: true));
        case 'sentiero_a_meta_o':
          await monta(const SentieroScreen(
              sentiero: Sentiero.costellazione, senzaVolo: true));
          await tester.pump(const Duration(milliseconds: 600));
        case 'celebrazione_grande_o':
          await monta(CelebrazioneAScermoPieno(
            traguardo: Sentieri.grandiDi(Sentiero.costellazione).first,
            sentiero: Sentiero.costellazione,
            serie: 'settimo giorno di seguito',
          ));
          await tester.pump(const Duration(milliseconds: 1400));
        case 'sovrimpressione_mini_o':
          await monta(Builder(
            builder: (ctx) => Scaffold(
              backgroundColor: const Color(0xFF05060A),
              body: Center(
                child: ElevatedButton(
                  onPressed: () => mostraLaSovrimpressione(
                    ctx,
                    traguardo: Sentieri.miniDi(Sentiero.albero)[4],
                    sentiero: Sentiero.albero,
                    serie: 'terzo giorno di seguito',
                  ),
                  child: const Text('quello che stavo facendo'),
                ),
              ),
            ),
          ));
          await tester.tap(find.text('quello che stavo facendo'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 700));
        case 'card_riaperta_o':
          await monta(Builder(
            builder: (ctx) => Scaffold(
              backgroundColor: const Color(0xFF05060A),
              body: Center(
                child: ElevatedButton(
                  onPressed: () => mostraLaCardDelTraguardo(
                    ctx,
                    traguardo: Sentieri.miniDi(Sentiero.costellazione)[5],
                    sentiero: Sentiero.costellazione,
                  ),
                  child: const Text('riapri'),
                ),
              ),
            ),
          ));
          await tester.tap(find.text('riapri'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 700));
      }
      await scattaApp(tester, radice, scena);
      await tester.pump(const Duration(seconds: 2));
    });
  }
}

/// L'identita' per l'anteprima: un account anonimo che non tocca nessuna rete.
class _IdentitaPerAnteprima implements PortaDellIdentita {
  @override
  String? get uid => 'anteprima';

  @override
  bool get anonimo => true;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  Future<String?> assicuraUnAccount() async => 'anteprima';

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async =>
      EsitoDellaCustodia.nonRiuscita;
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
