import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/assets/family_image.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/design_system/components/natal_wheel.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/features/account/profile_screen.dart';
import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_share_card.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_share_card.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_silhouette.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_card.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/components/immersive_scaffold.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:esoteric_circle/features/tarot/stesa_reveal.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/features/santuario/widgets/tue_arti_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cattura headless delle schermate, con font reali (corpo e icone), provider
/// AI offline e conversazioni gia' seminate. Nessuna rete, nessun device.
///
/// Dove finiscono i PNG. Di default in `build/preview/`, cartella ignorata dal
/// versionamento: cosi' `flutter test` verifica che ogni schermata renda ancora
/// senza mai sporcare l'albero di lavoro. Le anteprime committate in
/// `docs/preview/` si aggiornano solo su richiesta esplicita, valorizzando
/// AGGIORNA_ANTEPRIME=1, cosa che fanno gli script in `tool/`.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Un solo comando rigenera le anteprime: tool/aggiorna_anteprime.ps1 su
  // Windows, tool/aggiorna_anteprime.sh altrove.
  final aggiornaAnteprime =
      Platform.environment['AGGIORNA_ANTEPRIME'] == '1';
  final previewDir = aggiornaAnteprime ? 'docs/preview' : 'build/preview';

  // Ogni cattura parte da uno store locale noto e ripulito, quello di chi torna:
  // risveglio gia' fatto, cosi' si apre il Santuario e non l'onboarding, e saluto
  // della prima volta gia' visto, cosi' non compare a coprire la scena. Nessuna
  // continuita' di rito e' seminata se non dove serve. Senza questo ripristino
  // prima di ogni test, il mock di SharedPreferences di una cattura si
  // trascinerebbe nelle successive e ne cambierebbe il rendering.
  setUp(() => SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true},
      ));

  Future<void> loadFont(String family, String path) async {
    final loader = FontLoader(family);
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  List<String> materialIconsCandidates() {
    const rel = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
    final env = Platform.environment;
    final out = <String>[
      if (env['MATERIAL_ICONS_FONT'] != null) env['MATERIAL_ICONS_FONT']!,
      if (env['FLUTTER_ROOT'] != null) '${env['FLUTTER_ROOT']}/bin/cache/$rel',
    ];
    // L'eseguibile puo' essere dart (.../cache/dart-sdk/bin/dart) o
    // flutter_tester (.../cache/artifacts/engine/.../flutter_tester): si risale
    // di qualche livello provando entrambe le forme, cosi' si trova la cache in
    // ogni caso.
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      out.add('${dir.path}/$rel');
      out.add('${dir.path}/bin/cache/$rel');
      dir = dir.parent;
    }
    return out;
  }

  Future<void> loadFonts() async {
    await loadFont('Cinzel', 'assets/fonts/Cinzel-variable.ttf');
    await loadFont('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf');
    // Icone Material: si risolve il font dalla cache dell'SDK di Flutter a
    // partire dall'eseguibile Dart, cosi' il test e' autosufficiente. Un
    // eventuale percorso esplicito via ambiente ha la precedenza.
    for (final candidate in materialIconsCandidates()) {
      if (File(candidate).existsSync()) {
        await loadFont('MaterialIcons', candidate);
        break;
      }
    }
  }

  // Silenzia i sensori: in headless non esistono, e senza questo la parallasse
  // solleva una MissingPluginException asincrona che sporca il test.
  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    // IL CANALE AUDIO, muto nelle anteprime.
    //
    // Da quando il lettore reale e' il default, aprire la Meditazione dalla
    // rotta vera tenta di riprodurre, e in prova il plugin non esiste: la
    // cattura cadeva e due anteprime smettevano di rigenerarsi senza che
    // nessuno se ne accorgesse. L'anteprima misura la grafica, non il suono,
    // quindi il canale si spegne qui invece di far cadere la cattura.
    for (final canale in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers/events',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(canale), (call) async => null);
      messenger.setMockStreamHandler(
          EventChannel(canale), MockStreamHandler.inline(onListen: (a, e) {}));
    }
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

  List<(ChatRole, String)> seedFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return const [
          (ChatRole.user, 'Parlami del mio segno'),
          (
            ChatRole.maestro,
            'Il tuo segno racconta una tensione fra il cuore e la volontà. '
                'Oggi le stelle ti invitano a scegliere con calma, senza '
                'fretta. Vuoi che guardi un ambito, l\'amore o il lavoro?'
          ),
          (ChatRole.user, 'L\'amore, ti ascolto'),
          (
            ChatRole.maestro,
            'Venere ti sfiora con dolcezza. Un legame chiede verità, non '
                'perfezione. Prova a dire una cosa sincera a chi ami oggi, poi '
                'osserva come cambia la luce fra voi.'
          ),
        ];
      case Maestro.aura:
        return const [
          (ChatRole.user, 'Aiutami a rilassarmi'),
          (
            ChatRole.maestro,
            'Chiudi gli occhi un istante. Porta il respiro nel ventre, lento e '
                'profondo. Lascia scendere le spalle. Senti già un piccolo '
                'spazio in più?'
          ),
          (ChatRole.user, 'Sì, un poco'),
          (
            ChatRole.maestro,
            'Bene. Resta lì tre respiri. Il chakra del cuore si apre quando '
                'smetti di spingere. Vuoi una frequenza dolce per stasera?'
          ),
        ];
      case Maestro.caligo:
        return const [
          (ChatRole.user, 'Estrai una runa per me'),
          (
            ChatRole.maestro,
            'Esce Uruz, la forza del toro selvatico. Parla di energia grezza '
                'che chiede una direzione. Dove, in questi giorni, senti una '
                'potenza che non hai ancora incanalato?'
          ),
          (ChatRole.user, 'Nel lavoro'),
          (
            ChatRole.maestro,
            'Allora incanala. Un gesto solo, deciso, prima di sera. La forza '
                'onora chi la usa, non chi la trattiene.'
          ),
        ];
    }
  }

  Future<AppServices> buildServices(Maestro maestro,
      {required bool seeded}) async {
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
      UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)),
    );
    if (seeded) {
      for (final (role, text) in seedFor(maestro)) {
        await memory.appendMessage(
            maestro, ChatMessage(role: role, text: text));
      }
    }
    return AppServices(
      ai: _ScriptedMaestro(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
  }

  /// Le due altezze su cui si guarda ogni schermata che puo' stringersi.
  ///
  /// LE TRE MISURE DEL CORREDO, e la prima e' quella su cui si giudica.
  ///
  /// [schermoReale] e' il telefono di Mauro: 1080 per 2392 pixel fisici, che con
  /// un rapporto di pixel di 3 fanno **360 per 797 punti logici**. E' la misura
  /// su cui l'app viene guardata davvero, quindi viene prima.
  ///
  /// **Qui c'era il difetto che ha prodotto nove segnalazioni.** La costante che
  /// diceva di essere "quella di Mauro" valeva `Size(390, 797)`: l'altezza era
  /// giusta e la LARGHEZZA no, trenta punti logici in piu', novanta pixel
  /// fisici. Il commento dichiarava la cosa giusta mentre il codice ne faceva
  /// un'altra. Su trenta punti in meno il testo va a capo prima, i titoli si
  /// spezzano, le etichette si troncano e le bolle crescono in altezza perche'
  /// occupano due righe invece di una: e' l'elenco esatto dei difetti che nelle
  /// anteprime non si vedevano.
  const schermoReale = Size(360, 797);
  const schermoAlto = Size(390, 844);
  const schermoBasso = Size(360, 797);

  Future<GlobalKey> mount(WidgetTester tester, AppServices services,
      {DateTime Function()? clock, Size? schermo}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = schermo ?? schermoReale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: EsotericCircleApp(services: services, clock: clock),
      ),
    );
    await step(tester);
    tester
        .element(find.byType(MaterialApp))
        .read<QualityTierController>()
        .setTier(QualityTier.medium);
    await step(tester);
    return rootKey;
  }

  // La fascia oraria in cui il Maestro dato e' quello attivo della striscia,
  // cosi' striscia ed eroe della home derivano dallo stesso istante e mostrano
  // un momento coerente: Soffio per Aura, Oracolo per Medora, Runa per Caligo.
  DateTime Function() clockFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.aura:
        return () => DateTime(2026, 7, 14, 11, 0);
      case Maestro.medora:
        return () => DateTime(2026, 7, 14, 13, 0);
      case Maestro.caligo:
        return () => DateTime(2026, 7, 14, 19, 0);
    }
  }

  void selectCentral(WidgetTester tester, Maestro maestro) {
    tester
        .element(find.byType(MaterialApp))
        .read<MaestroController>()
        .selectMaestro(maestro);
  }

  // Precarica i volti dei tre Maestri, cosi' busti e avatar sono decodificati
  // alla cattura, senza cerchi vuoti.
  Future<void> precacheFaces(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), element);
      }
      // Anche il fondale del tempio, cosi' e' decodificato alla cattura.
      await precacheImage(
        const AssetImage('brand_assets/santuario/tempio.png'),
        element,
      );
    });
    await step(tester);
  }

  // Dal Santuario: mette il Maestro al centro, entra nel dominio toccando il
  // busto, poi apre la chat.
  Future<void> openChat(WidgetTester tester, Maestro maestro) async {
    selectCentral(tester, maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await step(tester);
    await step(tester);
  }

  Future<void> capture(
      WidgetTester tester, GlobalKey rootKey, String name) async {
    await tester.runAsync(() async {
      final boundary =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('$previewDir/$name');
      out.createSync(recursive: true);
      out.writeAsBytesSync(data!.buffer.asUint8List());
    });
    expect(File('$previewDir/$name').existsSync(), isTrue);
  }

  // --- Il Santuario, con al centro ciascun Maestro (aura e cosmo virati) ---
  for (final maestro in Maestro.fixedOrder) {
    testWidgets('Cattura il Santuario, ${maestro.id}', (tester) async {
      silenceSensors();
      await loadFonts();
      // Istante forzato nella fascia del Maestro: striscia ed eroe coerenti.
      final rootKey = await mount(
          tester, await buildServices(maestro, seeded: false),
          clock: clockFor(maestro));
      selectCentral(tester, maestro);
      await step(tester);
      await precacheFaces(tester);
      await capture(tester, rootKey, 'santuario-${maestro.id}.png');
    });
  }

  // --- Il Sigillo dell'Intenzione, su due altezze ---
  //
  // Catturato A FINE TRACCIAMENTO: il cammino si disegna in 2,4 secondi e
  // fotografarlo prima mostrerebbe un sigillo incompleto.
  for (final basso in const [false, true]) {
    testWidgets('Cattura il Sigillo${basso ? ", schermo basso" : ""}',
        (tester) async {
      silenceSensors();
      await loadFonts();
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = basso ? schermoBasso : schermoAlto;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final rootKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) =>
                    MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: SigilloIntenzioneScreen()),
          ),
        ),
      ));
      await tester.pump();
      await tester.tap(find.byKey(const Key('sigillo_inizia')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('sigillo_campo')),
          'Chiedo chiarezza sulla mia strada');
      await tester.pump();
      await tester.tap(find.byKey(const Key('sigillo_traccia')));
      // Fine tracciamento: 3,2 secondi su 2,4 di animazione.
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await capture(tester, rootKey,
          'sigillo-intenzione${basso ? "-2392" : ""}.png');
    });
  }

  // --- La stessa home a 2392, l'altezza del telefono di Mauro ---
  //
  // La bolla di Medora era stata corretta, verificata verde sull'anteprima a
  // 2532, e sul telefono a 2392 copriva ancora l'avatar. Una sola altezza non
  // e' una verifica, e' una fotografia fortunata: da qui in avanti le
  // schermate che possono stringersi si guardano su due.
  testWidgets('Cattura il Santuario, Medora, schermo basso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora),
        schermo: schermoBasso);
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'santuario-medora-2392.png');
  });

  // --- Il Santuario con l'invito al cielo visibile (mano del tap) ---
  testWidgets('Cattura il Santuario con l\'invito al cielo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Oltre i tre secondi di inattivita', senza toccare nulla, cosi' l'invito
    // compare; poi qualche frame perche' la dissolvenza e l'animazione si
    // assestino a meta' gesto.
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, rootKey, 'santuario-invito.png');
  });

  // --- La cartolina condivisibile del cielo, costruita apposta ---
  testWidgets('Cattura la cartolina del cielo, verticale e quadrata',
      (tester) async {
    await loadFonts();
    await tester.runAsync(() async {
      final now = DateTime(2026, 7, 13, 22);
      final moon = MoonPhase.forDate(now);
      final high = NightSky.constellationsHighTonight(now);
      for (final (format, name) in const [
        (PostcardFormat.story, 'cartolina-cielo.png'),
        (PostcardFormat.feed, 'cartolina-cielo-quadrata.png'),
      ]) {
        final bytes = await SkyPostcard.render(
          now: now,
          moon: moon,
          high: high,
          palette: MaestroPalette.medora,
          format: format,
        );
        final out = File('$previewDir/$name');
        out.createSync(recursive: true);
        out.writeAsBytesSync(bytes);
      }
    });
    expect(File('$previewDir/cartolina-cielo.png').existsSync(), isTrue);
    expect(File('$previewDir/cartolina-cielo-quadrata.png').existsSync(),
        isTrue);
  });

  // --- La schermata "Il cielo sopra di te", aperta dal cielo del Santuario ---
  testWidgets('Cattura Il cielo sopra di te', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_sky_tap')));
    await step(tester);
    await step(tester);
    // All'ingresso compare il pre-avviso della posizione: prima lo catturo,
    // poi lo declino per la veduta pulita del cielo.
    if (find.byKey(const Key('sky_location_prompt')).evaluate().isNotEmpty) {
      await capture(tester, rootKey, 'cielo-avvio-posizione.png');
      await tester.tap(find.byKey(const Key('sky_location_decline')));
      await step(tester);
      await step(tester);
    }
    await precacheFaces(tester);
    await capture(tester, rootKey, 'cielo-sopra-di-te.png');
  });

  // --- Chiedi ai Maestri: parte dal dominio, poi il confronto degli sguardi ---
  testWidgets('Cattura Chiedi ai Maestri, vista comparativa', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Tier a pagamento, cosi' il confronto e' disponibile per l'anteprima.
    tester
        .element(find.byType(MaterialApp))
        .read<EntitlementService>()
        .setTier(Tier.tier1);
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Dal dominio si entra nella Consulta, poi dall'header della chat si apre
    // il confronto a piu' voci.
    await tester.ensureVisible(find.byKey(const Key('domain_consulta_card')));
    await step(tester);
    await tester.tap(find.byKey(const Key('domain_consulta_card')));
    await step(tester);
    await step(tester);
    final accept = find.text('Ho capito, entriamo');
    if (accept.evaluate().isNotEmpty) {
      await tester.tap(accept);
      await step(tester);
    }
    await tester.tap(find.byKey(const Key('chat_compare')));
    await step(tester);
    await step(tester);
    await tester.enterText(
        find.byKey(const Key('ask_field')), 'Devo cambiare lavoro?');
    await step(tester);
    await tester.tap(find.byKey(const Key('ask_submit')));
    await step(tester);
    await step(tester);
    // Porta la stessa domanda anche allo sguardo di Aura: appare la sintesi.
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await step(tester);
    await step(tester);
    // Decodifica gli avatar, cosi' i mezzi busti delle lenti si vedono nel
    // preview invece dell'icona di ripiego che sta dietro l'anello.
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chiedi-ai-maestri.png');
  });

  // --- Il Test Archetipo di Aura: il responso, visivo prima del testo ---
  testWidgets('Cattura il Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Dal dominio di Aura si apre il Test Archetipo, che ora ha la sua
    // esperienza vera e non piu' la soglia dell'arte.
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await step(tester);
    // Le dodici risposte: sempre la quarta, che porta al Realista.
    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(const Key('archetype_answer_3')));
      await step(tester);
    }
    // Le catture locali non decodificano gli asset da sole: si precarica la
    // statua del dominante e le dodici miniature della classifica, altrimenti
    // nell'anteprima resta il ripiego.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          AssetImage(Archetype.realista.artePiena), element);
      for (final a in Archetype.values) {
        await precacheImage(AssetImage(a.arteThumb), element);
      }
    });
    await step(tester);
    // Superficie alta, cosi' l'anteprima mostra la ruota, la statua, i testi,
    // la classifica dei dodici e i due pulsanti in fondo.
    tester.view.physicalSize = const Size(360, 3600);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo.png');

    // La statua nell'Ombra: al tocco sulla statua in cima si volta.
    await tester.tap(
        find.byKey(const Key('archetype_statue_realista')).first);
    await step(tester);
  });

  testWidgets('Cattura la card del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.physicalSize = const Size(460, 1160);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    final profilo = ArchetypeScoring.calcola(List.filled(12, 3));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF03140F),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: ArchetypeShareCard(profilo: profilo),
          ),
        ),
      ),
    ));
    // La statua del dominante e le miniature della classifica compatta.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          AssetImage(profilo.dominante.artePiena), element);
      for (final a in profilo.graduatoria.take(3)) {
        await precacheImage(AssetImage(a.arteThumb), element);
      }
    });
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-card.png');
  });

  // La soglia del Test, col selettore dei transiti prima delle domande.
  testWidgets('Cattura la soglia del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    // La soglia mostra il selettore del cielo prima di cominciare.
    expect(find.byKey(const Key('archetype_sky_setting')), findsOneWidget);
    tester.view.physicalSize = const Size(360, 640);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-soglia.png');
  });

  // Una domanda in corso, con l'avanzamento in chiaro.
  testWidgets('Cattura una domanda del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await step(tester);
    // Qualche risposta, cosi' l'avanzamento non e' alla prima domanda.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('archetype_answer_1')));
      await step(tester);
    }
    expect(find.byKey(const Key('archetype_question')), findsOneWidget);
    tester.view.physicalSize = const Size(360, 700);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-domanda.png');
  });

  // --- La Costellazione del Viso di Aura: la fotocamera dal vivo non si cattura
  // in headless, quindi si usa la sagoma neutra come stand-in deterministico. ---
  Widget faceApp(Widget schermata) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: MaestroScope(child: schermata)),
      );

  Future<GlobalKey> mountFace(WidgetTester tester, Widget schermata,
      {required Size size}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
        RepaintBoundary(key: rootKey, child: faceApp(schermata)));
    await step(tester);
    await step(tester);
    return rootKey;
  }

  testWidgets('Cattura la soglia della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 820));
    expect(find.byKey(const Key('face_sky_setting')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-soglia.png');
  });

  testWidgets('Cattura la costellazione sulla sagoma', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 1400));
    // Si entra nella cattura: senza fotocamera resta la sagoma neutra con la
    // costellazione sopra, che e' proprio lo stand-in deterministico.
    await tester.tap(find.byKey(const Key('face_start')));
    await step(tester);
    await step(tester);
    expect(find.byKey(const Key('face_constellation_live')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-sagoma.png');
  });

  testWidgets('Cattura il responso della Costellazione del Viso',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 2200));
    // Percorso deterministico: si entra nella cattura e si scatta sulla sagoma.
    await tester.tap(find.byKey(const Key('face_start')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('face_shutter')));
    await step(tester);
    await step(tester);
    expect(find.byKey(const Key('face_result')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso.png');
  });

  testWidgets('Cattura la card della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.physicalSize = const Size(460, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final contorni = FaceSilhouette.contorni();
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF03140F),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: FaceShareCard(
              reading: FaceClassifier.leggi(contorni),
              costellazione: FaceConstellation.da(contorni),
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await capture(tester, rootKey, 'costellazione-viso-card.png');
  });

  testWidgets('Cattura il ripiego della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(
        tester, const FaceConstellationScreen(partiDalRipiego: true),
        size: const Size(360, 1080));
    expect(find.byKey(const Key('face_fallback')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-ripiego.png');
  });

  // --- La Meditazione di Aura: cimatica, respiro e suono generato a runtime ---
  testWidgets('Cattura la Meditazione di Aura', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Nel dominio di Aura, la card della Meditazione nel riquadro Energia apre
    // la schermata.
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_meditation')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await step(tester);
    await tester.tap(find.byKey(const Key('art_meditation')));
    await step(tester);
    await step(tester);
    // Avvio il suono e porto il respiro verso il pieno: il mandala si apre.
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(milliseconds: 2600));
    await capture(tester, rootKey, 'meditazione-aura.png');
  });

  // --- I quattro rituali del giorno ---
  Future<void> captureRitual(
    WidgetTester tester,
    GlobalKey rootKey,
    Route<void> route,
    Future<void> Function() reveal,
    String name,
  ) async {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(route));
    await step(tester);
    await step(tester);
    await reveal();
    await tester.pump(const Duration(milliseconds: 700));
    await capture(tester, rootKey, name);
  }

  testWidgets('Cattura il Rito dell\'Alba, velato e col dono', (tester) async {
    silenceSensors();
    // Semina la continuita' in locale cosi' la cattura del dono mostra il chip
    // dei giorni consecutivi e se ne validano posizione e stile. Ieri l'ultimo
    // rito, sei di fila: il gesto di oggi lo porta a sette, come sul device di
    // chi torna ogni mattina. La logica dello streak non cambia, si prepara solo
    // lo stato di partenza che sul device arriva dai giorni precedenti.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'ritual.dawn.lastDay': '2026-07-12',
      'ritual.dawn.streak': 6,
    });
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Il Rito dell'Alba compone tre livelli reali: si precaricano cosi' nella
    // cattura headless sono gia' decodificati e la scena appare, senza restare
    // in caricamento.
    final element = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      for (final a in const [
        'assets/ritual_backgrounds/dawn_sky_night.png',
        'assets/ritual_backgrounds/dawn_sky_day.png',
        'assets/ritual_backgrounds/dawn_sun.png',
      ]) {
        await precacheImage(AssetImage(a), element);
      }
    });
    await step(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(DawnRiteScreen.route(now: DateTime(2026, 7, 13))));
    await step(tester);
    await step(tester);
    // Lascia che lo screen risolva i tre livelli dalla cache immagini.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await step(tester);
    await step(tester);
    // Stato velato: la notte con la luna e mezzo sole sull'orizzonte, l'invito.
    await capture(tester, rootKey, 'rito-alba.png');

    // Il gesto tattile solleva l'alba e porge il dono del giorno.
    await tester.tap(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await step(tester);
    await capture(tester, rootKey, 'rito-alba-dono.png');

    // La base apribile del dono: da dove nasce, con l'ancora natale reale e i
    // livelli provvisori chiaramente marcati. Superficie piu' alta, cosi'
    // l'anteprima mostra il pannello intero, che sul device e' scorrevole.
    await tester.tap(find.byKey(const Key('gift_base_toggle')));
    await step(tester);
    tester.view.physicalSize = const Size(360, 1150);
    await step(tester);
    await capture(tester, rootKey, 'rito-alba-base.png');
  });

  testWidgets('Cattura il Soffio del Destino, testa piena e col dono',
      (tester) async {
    silenceSensors();
    // Continuita' seminata, cosi' la cattura del dono mostra il chip.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'ritual.breath.lastDay': '2026-07-12',
      'ritual.breath.streak': 4,
    });
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    // I due livelli reali del Soffio: prato e soffione. Si precaricano.
    final element = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      for (final a in const [
        'assets/ritual_backgrounds/breath_meadow.png',
        'assets/ritual_backgrounds/breath_dandelion.png',
      ]) {
        await precacheImage(AssetImage(a), element);
      }
    });
    await step(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(BreathDestinyScreen.route(now: DateTime(2026, 7, 13))));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await step(tester);
    await step(tester);
    // Stato di partenza: testa piena col soffione e l'invito.
    await capture(tester, rootKey, 'soffio-destino.png');

    // Ripiego tattile per la cattura, dato che in headless il microfono non c'e'.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await step(tester);
    await capture(tester, rootKey, 'soffio-destino-dono.png');
  });

  testWidgets('Cattura l\'Oracolo del Giorno', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await captureRitual(
      tester,
      rootKey,
      DayOracleScreen.route(now: DateTime(2026, 7, 13)),
      () async => tester.drag(
          find.byKey(const Key('ritual_gesture')), const Offset(250, 0)),
      'oracolo-giorno.png',
    );
  });

  // La Runa del Tramonto ha un flusso lungo: attesa, getto, incisione, due voci,
  // striscia della settimana, sigillo alla settima sera. La sera e' fissata alle
  // 20 e la nascita al 2 novembre 1975, cosi' esce Laguz, una runa a due tratti
  // con un rovescio vero, buona da mostrare tratto per tratto.
  final serataTramonto = DateTime(2026, 7, 13, 20);
  final nascitaTramonto = DateTime(1975, 11, 2);

  Route<dynamic> rottaTramonto() => SunsetRuneScreen.route(
        now: serataTramonto,
        dataNascita: nascitaTramonto,
      );

  // Precarica gli artwork rune_bone, cosi' il glifo inciso e' decodificato alla
  // cattura e non resta un buco al posto dell'arte finale.
  Future<void> precacheTramonto(WidgetTester tester) async {
    // I tre fondali sono 1284 per 2778: decodificati pesano una quarantina di
    // megabyte in tutto e, sommati alle ventiquattro pietre, sfondano il tetto
    // predefinito della cache immagini, che espelle le miniature gia' caricate e
    // lascia le caselle della settimana vuote. Qui il tetto si alza: e' solo la
    // cattura, l'app in esercizio non ha bisogno di tenerle tutte insieme.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 512 << 20;
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SunsetRuneScreen));
      for (final r in kElderFuthark) {
        if (r.hasImage) {
          await precacheImage(AssetImage(r.fullPath!), element);
          // Anche le miniature, per le caselle della striscia settimanale.
          await precacheImage(AssetImage(r.thumbPath!), element);
        }
      }
      // E i tre fondali del tramonto: senza, la cattura sorprende il momento
      // successivo con l'immagine non ancora decodificata e finisce sul ripiego
      // procedurale. La lista si legge da `kFondaliTramonto`, la stessa della
      // schermata, cosi' i percorsi non possono divergere.
      for (final slot in kFondaliTramonto) {
        await precacheImage(AssetImage(slot), element);
      }
    });
    await step(tester);
    // L'AnimatedSwitcher del fondale dura novecento millisecondi: si lascia
    // arrivare a regime, altrimenti lo scatto coglie la dissolvenza a meta'.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // Semina alcune sere gia' vissute, per una striscia che non sia vuota.
  String sereSeminate(int quante) {
    final giorno = SunsetRune.giornoRituale(serataTramonto);
    const rune = ['Fehu', 'Uruz', 'Ansuz', 'Raidho', 'Gebo', 'Wunjo'];
    final voci = <String>[];
    for (var i = quante; i >= 1; i--) {
      final g = SunsetRune.iso(giorno.subtract(Duration(days: i)));
      voci.add('{"giorno":"$g","rune":"${rune[(i - 1) % rune.length]}",'
          '"ombra":false,"lasciare":"la fretta","porta":"la quiete"}');
    }
    return '[${voci.join(',')}]';
  }

  // Incide tenendo il dito finche' il segno e' compiuto e si apre la lettura.
  Future<void> incidiTramonto(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await step(tester);
    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    final g = await tester.startGesture(centro);
    // Tiene il dito a lungo: nel gesto manuale ogni frame scava al piu' 50 ms,
    // quindi servono parecchie battute per compiere il segno e aprire la lettura.
    for (var i = 0; i < 44; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await g.up();
    await step(tester);
    await step(tester);
    // Col segno compiuto il fondale passa al terzo momento: si lascia finire la
    // dissolvenza da novecento millisecondi prima di scattare.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // Che cosa fotografa davvero ciascuno dei tre nomi. I nomi sono piu' vecchi
  // del flusso e non corrispondono piu' alla lettera, ma NON si rinominano: il
  // lucchetto in preview_integrity_test.dart e la relazione li citano per nome, e
  // una rinomina costerebbe senza portare niente. Quindi si dichiara qui:
  //   runa-tramonto-attesa.png    la pietra velata prima del getto, cioe' la
  //                               fase di attesa vera e propria.
  //   runa-tramonto-getto.png     il momento SUBITO DOPO il getto, con la pietra
  //                               gia' scoperta e pronta a essere incisa: e' la
  //                               fase di incisione appena cominciata, non il
  //                               lancio in volo, che non ha una cattura.
  //   runa-tramonto-incisione.png il segno a meta', col solco in corso di scavo.
  testWidgets('Cattura la Runa del Tramonto, attesa getto e incisione',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    // Attesa: la pietra velata sotto il tramonto.
    await capture(tester, rootKey, 'runa-tramonto-attesa.png');
    // Il getto col tocco, ripiego dello scuotimento: la pietra si scopre.
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 700));
    await capture(tester, rootKey, 'runa-tramonto-getto.png');
    // L'incisione a meta': il dito resta sulla pietra, il segno nasce a tratti.
    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    final g = await tester.startGesture(centro);
    // Oltre la soglia del tocco prolungato, poi incide a meta' della runa: piu'
    // battute brevi fanno avanzare il ticker un passo alla volta.
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 140));
    }
    await capture(tester, rootKey, 'runa-tramonto-incisione.png');
    expect(find.byKey(const Key('sunset_voce_uno')), findsNothing);
    await g.up();
  });

  testWidgets('Cattura la Runa del Tramonto, le due voci e la settimana',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // Quattro sere gia' vissute: stasera fa cinque, la striscia respira.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'sunset_rune.settimana': sereSeminate(4),
    });
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    await incidiTramonto(tester);
    // La prima voce e la trasparenza dei tre fattori.
    expect(find.byKey(const Key('sunset_voce_uno')), findsOneWidget);
    await capture(tester, rootKey, 'runa-tramonto-voce-uno.png');
    // La seconda voce dietro la rotazione, ripiego doppio tap.
    final loc = tester.getCenter(find.byKey(const Key('sunset_gira_doppio')));
    await tester.tapAt(loc);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(loc);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-voce-due.png');
    // La striscia delle sette sere, portata a vista.
    await tester.ensureVisible(find.byKey(const Key('sunset_settimana')));
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-settimana.png');
  });

  testWidgets('Cattura il Sigillo del Tramonto, alla settima sera',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // Sei sere gia' vissute: stasera fa sette, il sigillo si compone.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'sunset_rune.settimana': sereSeminate(6),
    });
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    await incidiTramonto(tester);
    await tester.ensureVisible(find.byKey(const Key('sunset_sigillo')));
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-sigillo.png');
  });

  // --- Il Rito del Sogno: nebbia, cielo, costellazione unita, saluto ---
  testWidgets('Cattura il Rito del Sogno', (tester) async {
    silenceSensors();
    await loadFonts();
    final quando = DateTime(2026, 7, 13, 22, 40);
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(DreamRiteScreen.route(now: quando)));
    await step(tester);
    await step(tester);
    // Apertura nella nebbia, buio e ovattato.
    await capture(tester, rootKey, 'rito-sogno-nebbia.png');

    // La nebbia si dirada col ripiego tattile, emergono le stelle.
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await step(tester);
    await capture(tester, rootKey, 'rito-sogno-cielo.png');

    // Si uniscono le stelle della costellazione del segno della Luna.
    final figura = kZodiacConstellations
        .firstWhere((c) => c.sign == NightSky.moonSign(quando));
    for (var i = 0; i < figura.points.length; i++) {
      await tester.tap(find.byKey(Key('dream_star_$i')));
      await tester.pump(const Duration(milliseconds: 80));
    }
    await capture(tester, rootKey, 'rito-sogno-costellazione.png');

    // Dalla figura unita scende il saluto della notte.
    tester.view.physicalSize = const Size(360, 1250);
    await tester.pump(const Duration(milliseconds: 1000));
    await step(tester);
    expect(find.byKey(const Key('dream_message')), findsOneWidget);
    await capture(tester, rootKey, 'rito-sogno.png');
  });

  testWidgets('Cattura la carta della notte del Rito del Sogno',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final quando = DateTime(2026, 7, 13, 22, 40);
    tester.view.physicalSize = const Size(460, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final maestro = DailyRituals.nightMaestro(quando);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF05060C),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: DreamRiteCard(
              luna: DreamRiteCorpus.lunaDi(quando),
              palette: MaestroPalette.forKey(ThemeKey.of(maestro)),
              saluto: DreamRiteCorpus.saluto(quando),
              maestroNome: maestro.displayName,
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await capture(tester, rootKey, 'rito-sogno-carta.png');
  });

  // --- Il Sigillo del Cerchio, emblema personale procedurale ---
  testWidgets('Cattura il Sigillo del Cerchio', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(CircleSealScreen.route(name: 'Sofia')));
    await step(tester);
    // Lascia comporre il sigillo con la sua animazione, fino al Sole posato e al
    // Numero acceso.
    await tester.pump(const Duration(milliseconds: 2700));
    await capture(tester, rootKey, 'sigillo-cerchio.png');
  });

  // --- La Sinastria VIP, raggiungibile dallo scaffale del Santuario ---
  Future<void> precacheSinastria(WidgetTester tester) async {
    // Decodifica la cornice VIP e il ritratto pieno del VIP in testa, cosi'
    // l'anteprima del responso mostra l'arte reale e non il ripiego.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SinastriaVipScreen));
      await precacheImage(const AssetImage('assets/vip_cornice.webp'), element);
      final first = VipCatalog.first;
      if (first.fullPath != null) {
        await precacheImage(AssetImage(first.fullPath!), element);
      }
    });
    await step(tester);
    await step(tester);
  }

  testWidgets('Cattura la galleria di scelta della Sinastria VIP',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Superficie alta, cosi' la galleria mostra ricerca, filtri, In evidenza col
    // tasto A caso e le prime righe della griglia dei volti.
    tester.view.physicalSize = const Size(360, 1720);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SinastriaGalleryScreen.route(userSign: Zodiac.gemini)));
    await step(tester);
    await step(tester);
    // Decodifica tutte le miniature, cosi' le tessere mostrano i volti.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SinastriaGalleryScreen));
      for (final vip in VipCatalog.vips) {
        if (vip.thumbPath != null) {
          await precacheImage(AssetImage(vip.thumbPath!), element);
        }
      }
    });
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'sinastria-galleria.png');
  });

  testWidgets('Cattura la Sinastria VIP', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Superficie alta quanto basta perche' l'anteprima mostri, oltre ai due
    // poli, anche le quattro barre, la riga di sfida, il tasto Condividi e il
    // tasto Cambia VIP che ha preso il posto del selettore in fondo.
    tester.view.physicalSize = const Size(360, 1340);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SinastriaVipScreen.route()));
    await step(tester);
    await step(tester);
    await precacheSinastria(tester);
    await capture(tester, rootKey, 'sinastria-vip.png');
  });

  testWidgets('Cattura la Sinastria VIP col nome utente reale', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    tester.view.physicalSize = const Size(360, 1340);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Nome e data reali sul polo di sinistra, cosi' si vede l'effetto personale.
    unawaited(nav.push(SinastriaVipScreen.route(
        userName: 'Sofia', userBirth: DateTime(1993, 4, 12))));
    await step(tester);
    await step(tester);
    await precacheSinastria(tester);
    await capture(tester, rootKey, 'sinastria-vip-personale.png');
  });

  // --- L'Animale Guida di Caligo: popup, rivelazione, responso, card ---
  Widget caligoApp(Widget schermata) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: MaestroScope(child: schermata)),
      );

  Future<GlobalKey> mountAnimal(WidgetTester tester, Widget schermata,
      {required Size size}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
        RepaintBoundary(key: rootKey, child: caligoApp(schermata)));
    await step(tester);
    await step(tester);
    return rootKey;
  }

  Future<void> precacheTotem(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(GuideAnimalScreen));
      final animal = GuideAnimalDerivation.forSign(Zodiac.cancer);
      await precacheImage(AssetImage(animal.fullPath), element);
    });
    await step(tester);
  }

  // Precarica l'arte di scena del tamburo, cosi' l'immagine compare nel viaggio.
  Future<void> precacheTamburo(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(GuideAnimalScreen));
      await precacheImage(
          const AssetImage('assets/img/caligo/tamburo_sciamanico_v1.webp'),
          element);
    });
    await step(tester);
  }

  void seedArchetipoCaligo() {
    final esito = ArchetypeEsito(
      quando: DateTime(2026, 7, 22, 10),
      percentuali: ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
      dominante: Archetype.realista,
    );
    SharedPreferences.setMockInitialValues({
      'archetipo.storico': [jsonEncode(esito.toJson())],
    });
  }

  testWidgets('Cattura il popup dell\'Animale Guida', (tester) async {
    silenceSensors();
    await loadFonts();
    // Senza Test Archetipo, il popup evocativo compare all'ingresso.
    SharedPreferences.setMockInitialValues({});
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    await precacheTotem(tester);
    expect(find.byKey(const Key('animal_test_popup')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale-popup.png');
  });

  testWidgets('Cattura il viaggio col tamburo', (tester) async {
    silenceSensors();
    await loadFonts();
    // Con un archetipo salvato niente popup: si vede il viaggio col tamburo.
    seedArchetipoCaligo();
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    await precacheTamburo(tester);
    expect(find.byKey(const Key('animal_journey')), findsOneWidget);
    // Un paio di battiti, cosi' i pallini si accendono e gli occhi affiorano.
    await tester.tap(find.byKey(const Key('animal_drum')));
    await step(tester);
    await tester.tap(find.byKey(const Key('animal_drum')));
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-viaggio.png');
  });

  testWidgets('Cattura la rivelazione nella nebbia', (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    await precacheTotem(tester);
    // Compie il viaggio col tasto di ripiego, poi coglie un istante fisso della
    // dissolvenza: la nebbia e' ancora densa, gli occhi accesi, il totem affiora.
    await tester.tap(find.byKey(const Key('animal_journey_skip')));
    await tester.pump(const Duration(milliseconds: 400)); // supera il ritardo
    await tester.pump(const Duration(milliseconds: 600)); // dentro la nebbia
    await capture(tester, rootKey, 'guide-animale-rivelazione.png');
  });

  testWidgets('Cattura il Messaggio del Giorno col blocco di trasparenza',
      (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    // Con la data di nascita la trasparenza mostra anche la Luna natale.
    final rootKey = await mountAnimal(
        tester,
        GuideAnimalScreen(
            userSign: Zodiac.cancer, userBirth: DateTime(1988, 7, 5, 9, 30)),
        size: const Size(360, 2000));
    await precacheTotem(tester);
    // Compie il viaggio, poi lascia posare la rivelazione, cosi' il totem e'
    // pieno e si vede il Messaggio del Giorno col blocco di trasparenza.
    await tester.tap(find.byKey(const Key('animal_journey_skip')));
    await tester.pump(const Duration(milliseconds: 400));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 800));
    }
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    expect(find.byKey(const Key('animal_transparency')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale.png');
  });

  testWidgets('Cattura la lettura di identita\' dell\'Animale Guida',
      (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    // La lettura fissa di identita', come si apre dal Cosmic Passport.
    final rootKey = await mountAnimal(
        tester,
        const GuideAnimalScreen(
            userSign: Zodiac.cancer, modo: GuideAnimalMode.identita),
        size: const Size(360, 1980));
    await precacheTotem(tester);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 800));
    }
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale-identita.png');
  });

  testWidgets('Cattura la card dell\'Animale Guida', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final animal = GuideAnimalDerivation.forSign(Zodiac.cancer);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF14060A),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: GuideAnimalShareCard(
                animal: animal, origine: 'Dal tuo cielo, Cancro'),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(AssetImage(animal.fullPath), element);
    });
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-card.png');
  });

  testWidgets('Cattura la faccia dell\'Animale Guida nel Passport',
      (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: const MaestroScope(child: CosmicPassport()),
        ),
      ),
    ));
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(CosmicPassport));
      final animal = GuideAnimalDerivation.forSign(
          NightSky.sunSign(BirthIdentity.example.birthMoment));
      await precacheImage(AssetImage(animal.thumbPath), element);
    });
    await step(tester);
    await tester.ensureVisible(find.byKey(const Key('passport_guide_animal')));
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-passport.png');
  });

  testWidgets('Cattura la chat aperta con la domanda gia\' scritta',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final services = await buildServices(Maestro.caligo, seeded: false);
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.caligo,
              services: services,
              initialUserMessage:
                  ChatOpeners.animale(GuideAnimalDerivation.forSign(Zodiac.cancer).name),
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await precacheFaces(tester);
    await capture(tester, rootKey, 'guide-animale-chat.png');
  });

  // --- L'Estrazione Rune di Caligo: soglia, lancio, rivelazioni, card ---
  Future<void> precacheRune(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(RuneDrawScreen));
      for (final r in kElderFuthark) {
        if (r.hasImage) {
          await precacheImage(AssetImage(r.thumbPath!), element);
          await precacheImage(AssetImage(r.fullPath!), element);
        }
      }
    });
    await step(tester);
  }

  // Sceglie la gettata e getta le rune col pulsante di ripiego.
  Future<void> lancia(WidgetTester tester, String segmento) async {
    await tester.tap(find.byKey(Key('rune_segment_$segmento')));
    await step(tester);
    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    await step(tester);
  }

  testWidgets('Cattura la soglia dell\'Estrazione Rune', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(7)),
        size: const Size(360, 1960));
    expect(find.byKey(const Key('rune_selector')), findsOneWidget);
    await capture(tester, rootKey, 'rune-soglia.png');
  });

  testWidgets('Cattura il lancio nel Pozzo di Urdhr', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(5)),
        size: const Size(360, 840));
    await precacheRune(tester);
    await lancia(tester, 'norne');
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    await capture(tester, rootKey, 'rune-lancio.png');
  });

  testWidgets('Cattura la rivelazione a tre Norne col presagio',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(5)),
        size: const Size(360, 2900));
    await precacheRune(tester);
    await lancia(tester, 'norne');
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
    expect(find.byKey(const Key('rune_sigillo')), findsOneWidget);
    await capture(tester, rootKey, 'rune-norne.png');
  });

  testWidgets('Cattura la Runa di Odino, una runa', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(9)),
        size: const Size(360, 2120));
    await precacheRune(tester);
    await lancia(tester, 'odino');
    await capture(tester, rootKey, 'rune-odino.png');
  });

  testWidgets('Cattura la Croce delle Cinque', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(4)),
        size: const Size(360, 3500));
    await precacheRune(tester);
    await lancia(tester, 'croce');
    await capture(tester, rootKey, 'rune-croce.png');
  });

  testWidgets('Cattura il getto sul telo, la sorte libera', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(6)),
        size: const Size(360, 3100));
    await precacheRune(tester);
    await lancia(tester, 'telo');
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_sigillo')), findsOneWidget);
    await capture(tester, rootKey, 'rune-getto.png');
  });

  testWidgets('Cattura la card dell\'Estrazione Rune', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.physicalSize = const Size(460, 1320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    final presagio = RunePresagio.componi(esito);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF14060A),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: RuneShareCard(esito: esito, presagio: presagio),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final r in esito.rune) {
        if (r.rune.hasImage) {
          await precacheImage(AssetImage(r.rune.thumbPath!), element);
        }
      }
    });
    await step(tester);
    await capture(tester, rootKey, 'rune-card.png');
  });

  // --- L'Oroscopo a quattro schede, la headline di Medora ---
  testWidgets('Cattura l\'Oroscopo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Un segno mostrato per intero, giorno fisso per un'anteprima stabile.
    // Superficie alta quanto basta prima di aprire, cosi' le forme a tema
    // finiscono il riempimento una volta sola: il segno per intero, quattro
    // schede piu' il tasto Condividi e il disclaimer, senza troppo vuoto.
    tester.view.physicalSize = const Size(360, 1560);
    // Ariete al 10 luglio 2026: valori variati tra le schede (2, 4, 5, 3), cosi'
    // si vede la differenza tra le quattro forme a tema.
    unawaited(nav.push(OroscopoScreen.route(
        userSign: Zodiac.aries, now: DateTime(2026, 7, 10))));
    await step(tester);
    await step(tester);
    // Decodifica l'emblema 3D del segno e i simboli dei chip, cosi' l'anteprima
    // mostra l'arte vera e non un posto vuoto.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(OroscopoScreen));
      await precacheImage(
          AssetImage(ZodiacArt.emblemPath(Zodiac.aries)), element);
    });
    await step(tester);
    // Lascia completare la micro-animazione di riempimento delle forme.
    await tester.pump(const Duration(seconds: 2));
    await capture(tester, rootKey, 'oroscopo.png');
  });

  // --- La card condivisibile dell'Oroscopo ---
  testWidgets('Cattura la card Oroscopo', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final cards =
        Horoscope.forSign(sign: Zodiac.aries, dayOfYear: 190, year: 2026);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Center(
            child: SingleChildScrollView(
              child: OroscopoShareCard(
                  sign: Zodiac.aries, cards: cards, palette: palette),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // L'emblema del segno decodificato anche nella card.
    await tester.runAsync(() async => precacheImage(
        AssetImage(ZodiacArt.emblemPath(Zodiac.aries)),
        tester.element(find.byType(OroscopoShareCard))));
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'oroscopo-card.png');
  });

  // --- La Stesa a Tre Carte, con una carta rovesciata ---
  testWidgets('Cattura la Stesa a Tre Carte', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // La schermata e' lunga: sintesi, tre posizioni lette, dialogo, carta
    // chiave, consiglio, domanda, azioni e disclaimer.
    tester.view.physicalSize = const Size(360, 2360);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Seme 1: Fante di Bastoni rovesciato, Dieci di Coppe, La Luna rovesciata.
    // Scelto perche' contiene una carta di corte col suo numero, un nome su due
    // righe e due rovesciate.
    const spread = TarotSpread.reversedChance; // documenta la meccanica
    assert(spread > 0);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(
          seed: 1,
          revealAll: true,
          topic: TarotTopic.bivio,
        ),
      ),
    )));
    await step(tester);
    await step(tester);
    // Decodifica l'arte delle tre carte, cosi' l'anteprima mostra le carte vere.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      for (final drawn in TarotSpread.draw(seed: 1).cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await step(tester);
    await tester.pump(const Duration(seconds: 2));
    await capture(tester, rootKey, 'stesa-tre-carte.png');
  });

  // --- La scena della Stesa a riposo, prima della scelta ---
  testWidgets('Cattura la scena della Stesa a riposo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    tester.view.physicalSize = const Size(360, 910);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Senza intro e senza carte gia' scelte: e' il ventaglio che aspetta, con
    // Medora sopra e i gesti del mazzo sotto.
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
    });
    // Si lascia finire l'ingresso a spirale e ci si ferma sul respiro. Serve
    // un secondo battito: la scena passa a riposo quando la Future
    // dell'ingresso si risolve, non nello stesso fotogramma.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await capture(tester, rootKey, 'stesa-scena.png');
  });

  // --- La Stesa con una carta gia' scelta, per vedere slot e ventaglio ---
  testWidgets('Cattura la Stesa in corso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    tester.view.physicalSize = const Size(360, 1020);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
      for (final drawn in TarotSpread.draw(seed: 1).cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    // Si pesca una carta: cosi' si vede il rapporto fra slot e ventaglio, col
    // primo slot gia' scoperto e gli altri due che aspettano.
    await tester.tap(find.byKey(const Key('stesa_fan_38')));
    await tester.pump();
    // Il volo, poi il flip: servono due attese distinte, perche' il flip
    // parte solo quando la carta e' arrivata nel suo slot.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await capture(tester, rootKey, 'stesa-in-corso.png');
    // La schermata lascia in piedi un tempo che scade dopo la cattura: senza
    // farlo scadere qui, la prova finisce con un timer ancora vivo e cade per
    // quello, non per l'immagine.
    await tester.pump(const Duration(seconds: 6));
  });

  // --- L'aura elementale delle quattro carte, ferma a meta' fioritura ---
  testWidgets('Cattura il reveal elementale', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // Una carta per elemento, piu' un Maggiore per la fioritura solenne.
    final carte = [
      'Asso di Bastoni',
      'Asso di Coppe',
      'Asso di Denari',
      'Asso di Spade',
      'Il Mondo',
    ].map((n) => TarotDeck.cards.firstWhere((c) => c.name == n)).toList();

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 250);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                for (final c in carte)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          AspectRatio(
                            aspectRatio: TarotFrame.aspect,
                            child: TarotCardArt(card: c, palette: palette),
                          ),
                          Positioned.fill(
                            child: ElementalReveal(
                              spec: RevealSpec.of(c),
                              // Fermi a meta' fioritura: e' li' che l'aura si
                              // vede al suo pieno.
                              progress: 0.5,
                              palette: palette,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(() async {
      final el = tester.element(find.byType(TarotCardArt).first);
      for (final c in carte) {
        await precacheImage(AssetImage(c.fullPath), el);
      }
    });
    await tester.pump();
    await capture(tester, rootKey, 'stesa-reveal.png');
  });

  // --- La card condivisibile della Stesa ---
  testWidgets('Cattura la card Stesa', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final spread = TarotSpread.draw(seed: 1);
    tester.view.devicePixelRatio = 1.0;
    // La card e' cresciuta: argomento, estratto della lettura, carta chiave e
    // consiglio oltre alla sintesi.
    tester.view.physicalSize = const Size(420, 1080);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Center(
            child: SingleChildScrollView(
              child: StesaShareCard(
              spread: spread,
              palette: palette,
              topic: TarotTopic.bivio,
            ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaShareCard));
      for (final drawn in spread.cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'stesa-card.png');
  });

  // --- Il Santuario, alto pulito senza bolle sopra l'immagine ---
  testWidgets('Cattura il Santuario, alto pulito', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'santuario-alto.png');
  });

  // --- L'area Utente, aperta dall'icona in alto a destra nel Cerchio ---
  testWidgets('Cattura l\'area Utente', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await tester.tap(find.byKey(const Key('santuario_user_avatar')));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'area-utente.png');
  });

  // --- Il Santuario, scaffale delle funzioni a scorrimento ---
  testWidgets('Cattura il Santuario, scaffale funzioni', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Scorre sotto l'alto, cosi' l'anteprima mostra lo scaffale delle funzioni.
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await step(tester);
    await capture(tester, rootKey, 'santuario-scaffale.png');
  });

  // --- La striscia del giorno, dove ora vivono i quattro riti ---
  //
  // La card del Rito dell'Alba non sta piu' nel dominio del Maestro: il dominio
  // e' il luogo delle arti, i riti del giorno appartengono alla striscia del
  // Santuario. L'anteprima segue il posto vero.
  testWidgets('Cattura la striscia del giorno', (tester) async {
    silenceSensors();
    await loadFonts();
    final dawn = DailyRituals.dawnMaestro(DateTime.now());
    final rootKey =
        await mount(tester, await buildServices(dawn, seeded: false));
    selectCentral(tester, dawn);
    await step(tester);
    await precacheFaces(tester);
    await tester.ensureVisible(find.byKey(const Key('santuario_daily_strip')));
    await step(tester);
    await capture(tester, rootKey, 'striscia-del-giorno.png');
  });

  // --- L'hub di dominio e il Cosmic Passport ---
  testWidgets('Cattura l\'hub di dominio, medora', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    // Superficie alta, cosi' l'anteprima mostra la presenza, la Consulta e il
    // primo riquadro di sottocategoria per intero.
    tester.view.physicalSize = const Size(360, 2800);
    await step(tester);
    await capture(tester, rootKey, 'dominio-medora.png');

    // Lo stesso dominio coi gruppi APERTI: il collasso raccoglie le arti in
    // cammino, quindi la seconda anteprima mostra cosa c'e' dietro. Si aprono
    // gli apri e chiudi delle sottocategorie vive e le intestazioni di quelle
    // tutte in arrivo, poi si cattura.
    // La lista e' pigra e le sottocategorie in fondo non sono ancora costruite:
    // si scorre fino a ciascuna prima di toccarla, nell'ordine in cui stanno.
    for (final chiave in const [
      'art_soon_toggle_astrologia',
      'art_soon_toggle_cartomanzia',
      'art_section_header_lunologia',
      'art_section_header_destino',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    // Coi gruppi aperti la lista cresce oltre la finestra della cattura: si
    // guarda il fondo, dove stanno le sottocategorie tutte in cammino.
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-medora-aperto.png');
  });

  // Lo stesso impianto generico visto dal dominio di Aura: nessun codice suo,
  // solo il catalogo diverso, quindi l'anteprima serve a verificarlo a video.
  testWidgets('Cattura l\'hub di dominio, aura', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    tester.view.physicalSize = const Size(360, 2800);
    await step(tester);
    await capture(tester, rootKey, 'dominio-aura.png');

    for (final chiave in const [
      'art_soon_toggle_energia',
      'art_soon_toggle_archetipi',
      'art_section_header_chakra',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    final posAura =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posAura.jumpTo(posAura.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-aura-aperto.png');
  });

  // Caligo: tre sottocategorie tutte miste, ciascuna con la sua distintiva.
  testWidgets('Cattura l\'hub di dominio, caligo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    selectCentral(tester, Maestro.caligo);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    tester.view.physicalSize = const Size(360, 2800);
    await step(tester);
    await capture(tester, rootKey, 'dominio-caligo.png');

    // La Cabala non ha piu' un'arte viva, uscito l'Albero della Vita dalla
    // Demo: si apre dalla sua intestazione invece che dal toggle.
    for (final chiave in const [
      'art_soon_toggle_rune',
      'art_soon_toggle_rituali',
      'art_section_header_cabala',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    final posCaligo =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posCaligo.jumpTo(posCaligo.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-caligo-aperto.png');
  });

  testWidgets('Cattura il Cosmic Passport', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    await capture(tester, rootKey, 'passport.png');
  });

  // --- Il cielo di nascita, aperto dal portale del Cosmic Passport ---
  testWidgets('Cattura Il tuo cielo di nascita', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    // Dal portale attivo del passaporto si apre la volta di nascita, immersiva
    // e fissa. Non chiede la posizione: il luogo e' quello della nascita.
    await tester.tap(find.byKey(const Key('passport_birth_sky')));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'cielo-di-nascita.png');
  });

  testWidgets('Cattura le Impostazioni', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    await tester.tap(find.byKey(const Key('passport_settings')));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'impostazioni.png');
  });

  // --- La sezione Profilo dell'Area Utente, col volto dell'utente ---
  testWidgets('Cattura il Profilo', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Un segno impostato, cosi' l'avatar di default mostra l'emblema del segno.
    final birth = BirthIdentityController()
      ..setBirth(
        BirthDetails(
          date: DateTime(1990, 8, 10),
          time: const TimeOfDay(hour: 12, minute: 0),
          place: const astro.BirthPlace(
              label: 'Roma',
              latitude: 41.9,
              longitude: 12.5,
              timezone: 'Europe/Rome'),
        ),
        NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
      );

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider<BirthIdentityController>.value(value: birth),
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          const AssetImage('assets/img/zodiac/zod_leone.webp'), element);
    });
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'profilo.png');
  });

  // --- I piani del Cerchio, aperti dalle Impostazioni ---
  testWidgets('Cattura i piani del Cerchio', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    await tester.tap(find.byKey(const Key('passport_settings')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('settings_plans')));
    await step(tester);
    await step(tester);
    // Superficie alta, cosi' l'anteprima mostra la card Demo e i quattro livelli.
    tester.view.physicalSize = const Size(360, 2600);
    await step(tester);
    await capture(tester, rootKey, 'piani.png');
  });

  // --- La chat che instrada verso una funzione immersiva ---
  testWidgets('Cattura la chat che instrada a una funzione', (tester) async {
    silenceSensors();
    await loadFonts();
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
        UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final intent = ImmersiveIntents.all
        .firstWhere((i) => i.target == ImmersiveTarget.tarocchiStesa);
    await memory.appendMessage(Maestro.medora,
        const ChatMessage(role: ChatRole.user, text: 'Puoi leggermi i tarocchi?'));
    await memory.appendMessage(
        Maestro.medora,
        ChatMessage(
            role: ChatRole.maestro, text: intent.invite, intentId: intent.id));
    final services = AppServices(
      ai: _ScriptedMaestro(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
    final rootKey = await mount(tester, services);
    await openChat(tester, Maestro.medora);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chat-instradamento.png');
  });

  // --- Le chat: conversazione, pannello suggerimenti, stato vuoto ---
  for (final maestro in Maestro.values) {
    final id = maestro.id;

    testWidgets('Cattura la conversazione, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: true));
      await openChat(tester, maestro);
      await precacheFaces(tester);
      await capture(tester, rootKey, '$id-chat.png');
    });

    testWidgets('Cattura il pannello dei suggerimenti, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: true));
      await openChat(tester, maestro);
      await tester.tap(find.text('Suggerimenti'));
      await step(tester);
      await step(tester);
      await capture(tester, rootKey, '$id-chat-suggerimenti.png');
    });

    testWidgets('Cattura lo stato vuoto, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: false));
      await openChat(tester, maestro);
      await precacheFaces(tester);
      await capture(tester, rootKey, '$id-chat-vuoto.png');
    });
  }

  // --- Il Risveglio, rituale a passi, e la rivelazione del cielo ---
  // Riduci Movimento attivo su tutte le route: accensioni e ruota gia' compiute
  // e ferme alla cattura, cosi' l'anteprima e' netta e deterministica.
  Future<GlobalKey> mountRisveglio(WidgetTester tester,
      {DateTime Function()? clock, Size? schermo}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = schermo ?? schermoReale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => OnboardingController()),
            // Il Risveglio ora poggia sul cosmo profondo: servono i controller
            // che lo animano (fermo sotto Riduci Movimento) e il tema neutro.
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: OnboardingScreen(clock: clock),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), element);
      }
    });
    await tester.pumpAndSettle();
    return rootKey;
  }

  Future<void> continua(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await tester.pumpAndSettle();
  }

  testWidgets('Cattura il Risveglio, la data col Sole nel segno',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // accoglienza -> data
    await capture(tester, rootKey, 'risveglio-data.png');
  });

  testWidgets('Cattura il Risveglio, l\'ora e l\'Ascendente', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await capture(tester, rootKey, 'risveglio-ora.png');
  });

  testWidgets('Cattura il Risveglio, il luogo offline', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Roma');
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'risveglio-luogo.png');
  });

  // Il planisfero col luogo SCELTO: la stella accesa nel punto giusto e' il
  // senso della cosa, quindi va guardata, non dedotta.
  testWidgets('Cattura il Risveglio, il luogo scelto', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Roma');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('citta_Roma_RM')));
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'risveglio-luogo-scelto.png');
  });

  // L'accoglienza, col suo astrolabio. Catturata A FINE COSTRUZIONE, non a
  // meta': gli anelli si tracciano in 2,6 secondi e fotografarli prima
  // direbbe che l'astrolabio e' incompleto.
  testWidgets('Cattura il Risveglio, accoglienza', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await capture(tester, rootKey, 'risveglio-accoglienza.png');
  });

  // La schermata del genere, con una scelta fatta: Mauro dice di non vedere
  // nessuna frase d'esempio, quindi va guardata invece che dedotta. Su due
  // altezze, perche' se la frase sta sotto la piega su uno schermo basso e'
  // come non averla scritta.
  for (final basso in const [false, true]) {
    testWidgets('Cattura il Risveglio, il genere${basso ? ', schermo basso' : ''}',
        (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey = await mountRisveglio(tester,
          clock: () => DateTime(2026, 7, 15),
          schermo: basso ? schermoBasso : schermoAlto);
      await continua(tester); // -> data
      await continua(tester); // -> ora
      await continua(tester); // -> luogo
      await continua(tester); // -> nome
      await tester.enterText(
          find.byKey(const Key('risveglio_nome_field')), 'Mauro');
      await tester.pumpAndSettle();
      await continua(tester); // -> vocativo
      await tester.tap(find.byKey(const Key('vocativo_lui')));
      // A fine scrittura, non a meta': la frase si scrive lettera per lettera
      // e fotografarla a meta' direbbe che manca.
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await capture(tester, rootKey,
          'risveglio-genere${basso ? '-2392' : ''}.png');
    });
  }

  testWidgets('Cattura il Risveglio, il sigillo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await continua(tester); // -> nome
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Sofia');
    await tester.pumpAndSettle();
    await continua(tester); // -> vocativo
    await tester.tap(find.byKey(const Key('vocativo_lei')));
    await tester.pumpAndSettle();
    await continua(tester); // -> sigillo
    await capture(tester, rootKey, 'risveglio-sigillo.png');
  });

  // Il ponte per le catture della coda: dai dati di nascita nascono la carta
  // (essenziale senza chiave API) e i fatti identitari, come nel Risveglio.
  Future<
      ({
        NatalChartController chart,
        IdentityController ident,
        BirthIdentityController birth,
        BirthDetails details,
      })> natalBridge(WidgetTester tester) async {
    final details = BirthDetails(
      date: DateTime(1990, 6, 15),
      time: const TimeOfDay(hour: 2, minute: 30),
      place: const astro.BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome',
      ),
      gender: Gender.female,
    );
    final chart = NatalChartController();
    await tester.runAsync(() => chart.compute(details));
    final birth = BirthIdentityController()..setBirth(details, chart.chart);
    final ident = IdentityController()
      ..setName('Sofia')
      ..setForm(AddressForm.feminine);
    return (chart: chart, ident: ident, birth: birth, details: details);
  }

  /// Una carta natale PIENA, costruita a mano: pianeti, angoli, case e
  /// aspetti.
  ///
  /// Serve perche' l'anteprima della carta natale e' sempre stata quella
  /// essenziale, senza pianeti: la ruota ornata non si e' mai potuta guardare,
  /// e ogni modifica alle linee d'aspetto restava una cosa scritta e mai
  /// vista. Le longitudini qui sono verosimili e fisse, non calcolate: questa
  /// e' una posa per il ritratto, non una carta di qualcuno.
  NatalChart cartaPiena() {
    PlanetPosition p(String id, String nome, String glifo, double lon) =>
        PlanetPosition(
          id: id,
          name: nome,
          glyph: glifo,
          longitude: lon,
          sign: Zodiac.values[(lon ~/ 30) % 12],
          house: (lon ~/ 30) + 1,
        );
    final pianeti = [
      p('sun', 'Sole', '\u2609', 84),
      p('moon', 'Luna', '\u263D', 212),
      p('mercury', 'Mercurio', '\u263F', 71),
      p('venus', 'Venere', '\u2640', 116),
      p('mars', 'Marte', '\u2642', 3),
      p('jupiter', 'Giove', '\u2643', 158),
      p('saturn', 'Saturno', '\u2644', 292),
      p('uranus', 'Urano', '\u2645', 268),
      p('neptune', 'Nettuno', '\u2646', 283),
      p('pluto', 'Plutone', '\u2647', 227),
    ];
    // Gli aspetti fra le coppie che cadono vicine agli angoli canonici.
    final aspetti = <ChartAspect>[];
    for (var i = 0; i < pianeti.length; i++) {
      for (var j = i + 1; j < pianeti.length; j++) {
        var d = (pianeti[i].longitude - pianeti[j].longitude).abs();
        if (d > 180) d = 360 - d;
        AspectType? tipo;
        if (d < 8) {
          tipo = AspectType.conjunction;
        } else if ((d - 60).abs() < 6) {
          tipo = AspectType.sextile;
        } else if ((d - 90).abs() < 7) {
          tipo = AspectType.square;
        } else if ((d - 120).abs() < 7) {
          tipo = AspectType.trine;
        } else if ((d - 180).abs() < 8) {
          tipo = AspectType.opposition;
        }
        if (tipo != null) {
          aspetti.add(ChartAspect(
            aLongitude: pianeti[i].longitude,
            bLongitude: pianeti[j].longitude,
            type: tipo,
          ));
        }
      }
    }
    return NatalChart(
      sunSign: Zodiac.gemini,
      moonSign: Zodiac.scorpio,
      ascendant: Zodiac.aquarius,
      ascendantLongitude: 312,
      midheaven: Zodiac.scorpio,
      midheavenLongitude: 222,
      planets: pianeti,
      houses: [
        for (var i = 0; i < 12; i++)
          HouseCusp(number: i + 1, longitude: (312 + i * 30) % 360),
      ],
      aspects: aspetti,
      hasTime: true,
    );
  }

  Widget natalHost({required Widget home}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: MaestroScope(child: child!),
      ),
      home: home,
    );
  }

  // La ruota natale PIENA, con pianeti e aspetti: era il buco permanente del
  // corredo delle anteprime, perche' la carta d'anteprima e' sempre stata
  // quella essenziale e la ruota non si e' mai potuta guardare.
  testWidgets('Cattura la ruota natale piena, con gli aspetti',
      (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 420);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
          ],
          child: natalHost(
            home: Scaffold(
              backgroundColor: const Color(0xFF0B0A1A),
              body: Center(
                child: NatalWheel(
                  chart: cartaPiena(),
                  size: 340,
                  showAspects: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // La ruota entra in 3,6 secondi e gli aspetti compaiono nell'ultimo
    // quinto: catturare prima vorrebbe dire fotografare una ruota senza le
    // linee e concludere che non ci sono.
    for (var i = 0; i < 26; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await capture(tester, rootKey, 'carta-ruota-piena.png');
  });

  testWidgets('Cattura il cielo reale di nascita', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final b = await natalBridge(tester);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<IdentityController>.value(value: b.ident),
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: natalHost(
            // Il cielo alla nascita e' ora la STESSA schermata del cielo in
            // tempo reale, ancorata al momento di nascita, con la CTA del
            // flusso: e' quello che l'onboarding monta davvero.
            home: SkyOverviewScreen(
              now: b.details.dateTime,
              birth: true,
              showBack: false,
              ctaLabel: 'Leggi la tua carta',
              onCta: () {},
            ),
          ),
        ),
      ),
    );
    // La volta pulsa in continuo: non si attende l'idle, si pompano pochi
    // frame per far posare la scena, poi si cattura.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await capture(tester, rootKey, 'cielo-nascita.png');
  });

  testWidgets('Cattura la carta natale, ruota ornata e legenda',
      (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    // Alta abbastanza da mostrare la ruota ornata e la legenda viva a tessere
    // (una tessera per pianeta) sotto di essa, senza scorrere.
    tester.view.physicalSize = const Size(360, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final b = await natalBridge(tester);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<NatalChartController>.value(value: b.chart),
            ChangeNotifierProvider<BirthIdentityController>.value(
                value: b.birth),
            ChangeNotifierProvider<IdentityController>.value(value: b.ident),
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: natalHost(
            home: ImmersiveScaffold(
              child: NatalChartReveal(onContinue: () {}),
            ),
          ),
        ),
      ),
    );
    // Le tre miniature degli angeli vanno decodificate prima dello scatto.
    // Senza, la cattura ne mostra una sola e le altre due restano vuote: e'
    // un artefatto dell'headless, non un difetto della tessera, ma
    // un'anteprima che mostra un volto su tre non serve a nessuno.
    await tester.runAsync(() async {
      for (final a in AngelCatalog.all) {
        await precacheImage(
            AssetImage(FamilyImage.thumb(AssetFamily.angeli, a.artStem)),
            tester.element(find.byType(NatalChartReveal)));
      }
    });
    // La legenda ha micro-animazioni: pochi frame invece dell'idle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await capture(tester, rootKey, 'carta-natale.png');
  });

  // --- La mano che invita al tocco, isolata e ingrandita ---
  //
  // Stava in un file suo che scriveva dritto in docs/preview senza passare di
  // qui: era la SECONDA PORTA, e per questo la sua anteprima non ha mai visto
  // la misura reale. Una regola messa in una porta quando le porte sono due non
  // e' una regola.
  testWidgets('Cattura la mano del tocco', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = schermoReale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color(0xFF0B0714),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final f in const [-1.0, 0.35, 0.7])
                SizedBox(
                  width: 100,
                  height: 260,
                  child: CustomPaint(
                    painter: TapHandPainter(phase: f, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await capture(tester, rootKey, 'mano-terza-stesura.png');
  });

  // --- Lo scaffale personale, alla misura reale ---
  //
  // Era nata da una prova temporanea poi cancellata: nessuno la rigenerava e
  // restava ferma a 390 per 844, cioe' a uno schermo che non esiste.
  testWidgets('Cattura Le tue arti', (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    final pref = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await pref.carica();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = schermoReale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<ArtiPreferiteController>.value(value: pref),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF0B0714),
            body: SingleChildScrollView(child: TueArtiView(onOpen: (_) {})),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'le-tue-arti.png');
  });
}

/// Maestro offline: risponde con un testo fisso, senza rete.
class _ScriptedMaestro implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    return 'Le stelle ti ascoltano. Dimmi ancora, cerchiamo insieme il filo.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    // Testo per Maestro, cosi' l'anteprima del confronto mostra sguardi diversi.
    switch (maestro) {
      case Maestro.medora:
        return const MaestroReply(
          glance: 'Le stelle segnano un tempo di scelta.',
          reading: 'Un transito passa, non una sentenza: le posizioni invitano, '
              'non obbligano.',
          invite: 'Qual è la prima piccola mossa che senti giusta ora?',
        );
      case Maestro.aura:
        return const MaestroReply(
          glance: 'Il corpo sa già qualcosa su questo.',
          reading: 'Se stringe la gola o il petto, chiede ascolto, non '
              'battaglia. Accolgo l\'emozione senza gonfiarla.',
          invite: 'Fai un respiro lento, una mano sul cuore: cosa si scioglie?',
        );
      case Maestro.caligo:
        return const MaestroReply(
          glance: 'La runa indica una soglia da varcare.',
          reading: 'Un passaggio di crescita e protezione, mai potere sugli '
              'altri: il simbolo mostra la via, non forza la mano.',
          invite: 'Quale gesto semplice segnerebbe il tuo passo, stasera?',
        );
    }
  }

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
