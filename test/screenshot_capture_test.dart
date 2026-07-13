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
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Cattura headless della chat di Medora, con font reali (corpo e icone),
/// provider AI offline e una conversazione gia' seminata. Nessuna rete, nessun
/// device. Scrive il PNG in docs/preview/medora-chat.png.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<GlobalKey> mount(WidgetTester tester, AppServices services) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: EsotericCircleApp(services: services),
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
      final out = File('docs/preview/$name');
      out.createSync(recursive: true);
      out.writeAsBytesSync(data!.buffer.asUint8List());
    });
    expect(File('docs/preview/$name').existsSync(), isTrue);
  }

  // --- Il Santuario, con al centro ciascun Maestro (aura e cosmo virati) ---
  for (final maestro in Maestro.fixedOrder) {
    testWidgets('Cattura il Santuario, ${maestro.id}', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: false));
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
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
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
        final out = File('docs/preview/$name');
        out.createSync(recursive: true);
        out.writeAsBytesSync(bytes);
      }
    });
    expect(File('docs/preview/cartolina-cielo.png').existsSync(), isTrue);
    expect(File('docs/preview/cartolina-cielo-quadrata.png').existsSync(),
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

  testWidgets('Cattura il Rito dell\'Alba', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await captureRitual(
      tester,
      rootKey,
      DawnRiteScreen.route(now: DateTime(2026, 7, 13)),
      () async => tester.tap(find.byKey(const Key('ritual_gesture'))),
      'rito-alba.png',
    );
  });

  testWidgets('Cattura il Soffio del Destino', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    await captureRitual(
      tester,
      rootKey,
      BreathDestinyScreen.route(now: DateTime(2026, 7, 13)),
      () async => tester.longPress(find.byKey(const Key('ritual_gesture'))),
      'soffio-destino.png',
    );
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
    await capture(tester, rootKey, 'sinastria-vip.png');
  });

  // --- Il Santuario, alto pulito senza bolle sopra l'immagine ---
  testWidgets('Cattura il Santuario, alto pulito', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'santuario-alto.png');
  });

  // --- Il Santuario, scaffale delle funzioni a scorrimento ---
  testWidgets('Cattura il Santuario, scaffale funzioni', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
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
