import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "Chiedi ai Maestri" ridisegnato: parte da un Maestro, poi invita a portare la
/// stessa domanda a un altro con la sintesi a confronto. Accesso per tier. La
/// risposta del Maestro del dominio passa da Gemini quando pronto, con ripiego
/// sull'oracolo locale.
void main() {
  Widget host({
    Tier tier = Tier.free,
    Maestro starter = Maestro.medora,
    Size? surface,
    AppServices? services,
  }) =>
      MultiProvider(
        providers: [
          Provider<AppServices>.value(
              value: services ?? AppServices.offline()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
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

    // Solo la risposta di Medora, nessuna sintesi, piu' l'invito.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_synthesis')), findsNothing);
    expect(find.byKey(const Key('ask_another_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_add_aura')), findsOneWidget);
    expect(find.byKey(const Key('ask_add_caligo')), findsOneWidget);
  });

  testWidgets('Free: il confronto a un altro Maestro invita all\'upgrade',
      (tester) async {
    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'una scelta');
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // Appare l'invito gentile, e Aura non e' stata aggiunta.
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsNothing);
  });

  testWidgets('Free: la seconda domanda invita all\'upgrade', (tester) async {
    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'prima domanda');
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);

    // La seconda domanda del giorno e' oltre il limite del Free.
    await ask(tester, 'seconda domanda');
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
  });

  testWidgets('Tier a pagamento: il confronto aggiunge lo sguardo e la sintesi',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(tier: Tier.tier1, starter: Maestro.medora));
    await ask(tester, 'una scelta d\'amore');

    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // Ora due sguardi e la sintesi comparativa in cima.
    expect(find.byKey(const Key('ask_synthesis')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsOneWidget);
  });

  testWidgets('AI pronta: la card del Maestro del dominio usa la risposta viva',
      (tester) async {
    await tester.pumpWidget(host(
      starter: Maestro.medora,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'il lavoro');

    // La lente di Medora c'e', e porta il testo del provider, non quello
    // dell'oracolo locale.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.text('Il colpo d\'occhio vivo dal provider.'), findsOneWidget);
    expect(find.textContaining('Testo narrato vivo dal provider'),
        findsOneWidget);
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

    // Nessun errore a video, la lente c'e' col testo dell'oracolo di Medora.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsOneWidget);
    expect(find.textContaining('vivo dal provider'), findsNothing);
  });

  testWidgets('AI non pronta: cade sull\'oracolo, gating Free invariato',
      (tester) async {
    // AppServices.offline ha un provider non pronto (isReady falso).
    await tester.pumpWidget(host(tier: Tier.free, starter: Maestro.medora));
    await ask(tester, 'il lavoro');
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsOneWidget);

    // La seconda domanda del giorno resta oltre il limite del Free.
    await ask(tester, 'seconda domanda');
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
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
    // Almeno un accento vero, mai l'apostrofo di comodo al suo posto.
    expect(testi.any((s) => RegExp('[àèéìòù]').hasMatch(s)), isTrue);
  });
}

/// Costruisce servizi di test con il provider AI dato, memoria solo in RAM.
AppServices _servicesWith(MaestroAiProvider ai) => AppServices(
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );

/// Provider AI pronto che ritorna tre strati noti, per provare che la card usa
/// la risposta viva.
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
  }) async {
    return const MaestroReply(
      glance: 'Il colpo d\'occhio vivo dal provider.',
      reading: 'Testo narrato vivo dal provider, con accenti veri: è così.',
      invite: 'Un invito vivo dal provider.',
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

/// Provider AI pronto che pero' non trova le parole: solleva
/// [MaestroAiUnavailable], cosi' la schermata deve cadere sull'oracolo.
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
