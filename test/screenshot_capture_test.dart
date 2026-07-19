import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/components/immersive_scaffold.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:esoteric_circle/features/onboarding/birth_sky_hero.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

  Future<GlobalKey> mount(WidgetTester tester, AppServices services,
      {DateTime Function()? clock}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
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
    await tester.tap(find.text('Parla con ${maestro.displayName}'));
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
    // Dal dominio si apre "Chiedi a Medora".
    await tester.ensureVisible(find.byKey(const Key('domain_ask_card')));
    await step(tester);
    await tester.tap(find.byKey(const Key('domain_ask_card')));
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
    await capture(tester, rootKey, 'chiedi-ai-maestri.png');
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
    // Nel dominio di Aura, la tessera della Meditazione apre la schermata.
    await tester.ensureVisible(find.byKey(const Key('aura_meditation_card')));
    await step(tester);
    await tester.tap(find.byKey(const Key('aura_meditation_card')));
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
    tester.view.physicalSize = const Size(390, 1150);
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

  testWidgets('Cattura la Runa del Tramonto, stato chiuso ed estratto',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SunsetRuneScreen.route(now: DateTime(2026, 7, 13))));
    await step(tester);
    await step(tester);
    // Stato chiuso: la pietra runica velata.
    await capture(tester, rootKey, 'runa-tramonto-chiusa.png');
    // Il tocco, ripiego dello scuotimento, svela la runa.
    await tester.tap(find.byKey(const Key('ritual_gesture')));
    await tester.pump(const Duration(milliseconds: 700));
    await capture(tester, rootKey, 'runa-tramonto.png');
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
  testWidgets('Cattura la Sinastria VIP', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SinastriaVipScreen.route()));
    await step(tester);
    await step(tester);
    // Decodifica il ritratto pieno del VIP in testa e le prime miniature del
    // selettore, cosi' l'anteprima mostra l'arte reale e non i ripieghi.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SinastriaVipScreen));
      // La cornice VIP per il polo dell'utente.
      await precacheImage(const AssetImage('assets/vip_cornice.webp'), element);
      final first = VipCatalog.first;
      if (first.fullPath != null) {
        await precacheImage(AssetImage(first.fullPath!), element);
      }
      for (final vip in VipCatalog.vips.take(4)) {
        if (vip.thumbPath != null) {
          await precacheImage(AssetImage(vip.thumbPath!), element);
        }
      }
    });
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'sinastria-vip.png');
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
    tester.view.physicalSize = const Size(390, 1560);
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
    tester.view.physicalSize = const Size(390, 2360);
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

  // --- La card Rito dell'Alba, col Maestro di turno del giorno ---
  testWidgets('Cattura la card Rito dell\'Alba', (tester) async {
    silenceSensors();
    await loadFonts();
    final dawn = DailyRituals.dawnMaestro(DateTime.now());
    final rootKey =
        await mount(tester, await buildServices(dawn, seeded: false));
    selectCentral(tester, dawn);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    await tester.ensureVisible(find.byKey(const Key('ritual_dawn')));
    await step(tester);
    await capture(tester, rootKey, 'card-rito-alba.png');
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
    await capture(tester, rootKey, 'dominio-medora.png');
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
    tester.view.physicalSize = const Size(390, 2600);
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
      {DateTime Function()? clock}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
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

  testWidgets('Cattura il cielo reale di nascita', (tester) async {
    silenceSensors();
    await loadFonts();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
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
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: natalHost(
            home: ImmersiveScaffold(
              child: BirthSkyHero(details: b.details, onContinue: () {}),
            ),
          ),
        ),
      ),
    );
    // BirthSkyHero pulsa in continuo: non si attende l'idle, si pompano pochi
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
    tester.view.physicalSize = const Size(390, 1600);
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
    // La legenda ha micro-animazioni: pochi frame invece dell'idle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await capture(tester, rootKey, 'carta-natale.png');
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
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
