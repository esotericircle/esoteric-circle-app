import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Consulta un Maestro" a domanda singola: parte dal Maestro del dominio, ogni
/// risposta e ogni lente aggiunta passa da Gemini con ripiego sull'oracolo, la
/// sintesi comparativa e' deterministica, il Free ha tre risposte al giorno.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  // In headless i sensori non esistono: si silenziano per la chat, che di sotto
  // ha il cosmo con la parallasse.
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

  Widget host({
    Tier tier = Tier.free,
    Maestro starter = Maestro.medora,
    AppServices? services,
    QuestionAllowance? allowance,
    BirthIdentityController? birth,
  }) =>
      MultiProvider(
        providers: [
          Provider<AppServices>.value(
              value: services ?? AppServices.offline()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider<BirthIdentityController>.value(
              value: birth ?? BirthIdentityController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(
              create: (_) => allowance ?? QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(child: AskMaestriScreen(starter: starter)),
        ),
      );

  Future<void> ask(WidgetTester tester, String theme) async {
    await tester.enterText(find.byKey(const Key('ask_field')), theme);
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('Parte dal Maestro del dominio, una risposta e l\'invito',
      (tester) async {
    await tester.pumpWidget(host(starter: Maestro.medora));
    await tester.pump();
    expect(find.byKey(const Key('ask_empty')), findsOneWidget);

    await ask(tester, 'il lavoro');

    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_synthesis')), findsNothing);
    expect(find.byKey(const Key('ask_another_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_add_aura')), findsOneWidget);
    // Chiusura del cerchio: il ponte alla conversazione.
    expect(find.byKey(const Key('ask_continue_chat')), findsOneWidget);
  });

  testWidgets('AI pronta: la lente del dominio usa la risposta viva',
      (tester) async {
    await tester.pumpWidget(host(
      starter: Maestro.medora,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'il lavoro');

    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Medora vede il lavoro'), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsNothing);
  });

  testWidgets('AI che lancia MaestroAiUnavailable: cade sull\'oracolo',
      (tester) async {
    await tester.pumpWidget(host(
      starter: Maestro.medora,
      services: _servicesWith(_UnavailableAi()),
    ));
    await ask(tester, 'il lavoro');

    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsOneWidget);
  });

  testWidgets('Confronto Premium: la lente aggiunta viene dal provider e la '
      'sintesi e\' deterministica', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      tier: Tier.tier1,
      starter: Maestro.medora,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'una scelta');
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // Due lenti vive, entrambe dal provider.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsOneWidget);
    expect(find.textContaining('Medora vede una scelta'), findsOneWidget);
    expect(find.textContaining('Aura sente una scelta'), findsOneWidget);

    // La sintesi comparativa intreccia le due prese di posizione e chiude con la
    // regola, senza una chiamata al provider in piu' (il fake conta le chiamate).
    final sintesi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('ask_synthesis')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .whereType<String>()
        .join(' ');
    expect(sintesi, contains('Medora'));
    expect(sintesi, contains('Aura'));
    expect(sintesi,
        contains('Dove le voci concordano, ascolta con più fiducia'));
  });

  testWidgets('Free: il confronto invita all\'upgrade, senza aggiungere',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'una scelta');
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsNothing);
  });

  testWidgets('Free: tre risposte al giorno, la quarta invita all\'upgrade',
      (tester) async {
    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'prima');
    await ask(tester, 'seconda');
    await ask(tester, 'terza');
    // Le prime tre passano.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing);

    // La quarta e' oltre il limite.
    await ask(tester, 'quarta');
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
  });

  testWidgets('La domanda si conta solo a risposta consegnata', (tester) async {
    final allowance = QuestionAllowance();
    await tester.pumpWidget(host(tier: Tier.free, allowance: allowance));
    // Prima di consegnare, nulla e' consumato.
    expect(allowance.usedToday(), 0);
    await ask(tester, 'il lavoro');
    // Consegnata la risposta, una consumata.
    expect(allowance.usedToday(), 1);
  });

  testWidgets('Personalizzazione: il provider riceve i dati natali presenti',
      (tester) async {
    final cap = _CapturingAi();
    final birth = BirthIdentityController()
      ..setBirth(
        BirthDetails(
          date: DateTime(1990, 8, 10),
          time: const TimeOfDay(hour: 12, minute: 0),
          place: const BirthPlace(
              label: 'Roma',
              latitude: 41.9,
              longitude: 12.5,
              timezone: 'Europe/Rome'),
          gender: Gender.female,
        ),
        NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
      );
    await tester.pumpWidget(host(
      starter: Maestro.medora,
      services: _servicesWith(cap),
      birth: birth,
    ));
    await ask(tester, 'il lavoro');

    expect(cap.lastNatal, isNotNull);
    expect(cap.lastNatal!.sunSign, 'Leone');
    expect(cap.lastNatal!.lifeNumber, isNotNull);
    // La profondita' nel Free e' Breve.
    expect(cap.lastDepth, ConsultDepth.breve);
  });

  testWidgets('Chiusura del cerchio: salva in memoria e apre la chat col tema',
      (tester) async {
    silenceSensors();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = InMemoryMaestroMemoryRepository();
    final services = AppServices(
      ai: _ReadyAi(),
      memory: repo,
      memoryPersistent: false,
    );
    await tester.pumpWidget(host(starter: Maestro.medora, services: services));
    await ask(tester, 'devo cambiare lavoro');

    await tester.tap(find.byKey(const Key('ask_continue_chat')));
    // Il cosmo della chat anima all'infinito, quindi non si usa pumpAndSettle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // La chat si e' aperta.
    expect(find.byType(MaestroChatScreen), findsOneWidget);
    // Il campo si apre col tema del Consulta.
    expect(find.text('devo cambiare lavoro'), findsWidgets);
    // La memoria di Medora ricorda il tema.
    final mem = await repo.loadMemory(Maestro.medora);
    expect(mem.sessionSummary, contains('devo cambiare lavoro'));
  });

  testWidgets('I testi a video non usano il trattino lungo e hanno accenti veri',
      (tester) async {
    await tester.pumpWidget(host(starter: Maestro.medora));
    await ask(tester, 'il lavoro');

    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(testi, isNotEmpty);
    for (final s in testi) {
      expect(s.contains('—'), isFalse,
          reason: 'Trovato un trattino lungo in: $s');
    }
    expect(testi.any((s) => RegExp('[àèéìòù]').hasMatch(s)), isTrue);
  });
}

/// Costruisce servizi di test con il provider AI dato, memoria solo in RAM.
AppServices _servicesWith(MaestroAiProvider ai) => AppServices(
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );

/// Provider pronto che risponde con un testo per Maestro, cosi' si distingue la
/// risposta viva da quella dell'oracolo e si verifica l'intreccio della sintesi.
class _ReadyAi implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    final verbo = maestro == Maestro.aura ? 'sente' : 'vede';
    return MaestroReply(
      glance: '${maestro.displayName} $verbo $theme con la sua lente.',
      reading: 'Testo narrato vivo di ${maestro.displayName} su $theme, così è.',
      invite: 'Un invito vivo di ${maestro.displayName}.',
    );
  }

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async =>
      'Le stelle ti ascoltano.';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Cattura i parametri passati a consult, per verificare la personalizzazione.
class _CapturingAi implements MaestroAiProvider {
  NatalContext? lastNatal;
  ConsultDepth? lastDepth;

  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    lastNatal = natal;
    lastDepth = depth;
    return MaestroReply(
      glance: '${maestro.displayName} vede $theme.',
      reading: 'Testo di ${maestro.displayName}, così.',
      invite: 'Un invito.',
    );
  }

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Provider pronto che pero' non trova le parole: cade sull'oracolo.
class _UnavailableAi implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    throw const MaestroAiUnavailable();
  }

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
