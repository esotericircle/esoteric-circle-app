import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/core/chat/le_conversazioni_passate.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';

/// La chat che si apre da un pulsante di approfondimento ("Parlane con il
/// Maestro", "Continua con") porta la domanda contestuale.
///
/// **ORDINE DX VOCE 01: LA DOMANDA STA NEL CAMPO, NON PARTE.** Fino alla build
/// 2270 partiva da sola appena la chat era pronta, e il fondatore l'ha vista
/// consumare una delle tre domande del giorno senza toccare niente. Queste
/// prove misurano tre cose che il fondatore ha chiesto: la domanda e' nel
/// campo, nessuna domanda arriva al modello e nessuna si consuma finche' la
/// persona non manda, e la persona puo' mandare un'altra domanda al suo posto.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppServices> services(MaestroAiProvider ai) async {
    final memory = InMemoryMaestroMemoryRepository();
    // Disclaimer gia' accettato, cosi' non copre la chat con la modale.
    await memory
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    return AppServices(
      ai: ai,
      memory: memory,
      memoryPersistent: false,
      diagnostics: 'test',
    );
  }

  const domanda = 'Il mio animale guida e\' il Lupo, cosa vuole dirmi?';
  const risposta = 'Il Lupo ti parla di lealta\'.';

  Future<QuestionAllowance> pumpChat(WidgetTester tester, AppServices svc,
      {required String initial}) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final contatore = QuestionAllowance(freeDailyLimit: 3);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: svc),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: contatore),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Navigator(
          onGenerateRoute: (_) => MaestroChatScreen.route(
            maestro: Maestro.caligo,
            services: svc,
            initialUserMessage: initial,
          ),
        ),
      ),
    ));
    // Un secondo e mezzo: quanto bastava alla vecchia chat per mandare la
    // domanda da sola e ricevere la risposta.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    return contatore;
  }

  String campo(WidgetTester tester) => tester
      .widget<TextField>(find.descendant(
          of: find.byKey(const Key('chat_campo')),
          matching: find.byType(TextField)))
      .controller!
      .text;

  Future<void> manda(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('chat_invio')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets(
      'DX.01: la domanda contestuale sta nel campo, non parte e non consuma',
      (tester) async {
    final ai = _ReadyAi();
    final contatore =
        await pumpChat(tester, await services(ai), initial: domanda);

    expect(campo(tester), domanda,
        reason: 'la domanda preimpostata deve aspettare nel campo');
    expect(ai.chieste, isEmpty,
        reason: 'nessuna domanda arriva al modello finche\' non si manda');
    expect(find.text(risposta), findsNothing,
        reason: 'il Maestro ha risposto senza che nessuno mandasse niente');
    expect(contatore.usedToday(), 0,
        reason: 'si e\' consumata una domanda senza toccare la freccia');
  });

  testWidgets(
      'DX.01: mandata dalla persona, parte, risponde, consuma una e svuota',
      (tester) async {
    final ai = _ReadyAi();
    final contatore =
        await pumpChat(tester, await services(ai), initial: domanda);
    await manda(tester);

    expect(ai.chieste, [domanda]);
    expect(find.text(risposta), findsOneWidget);
    expect(contatore.usedToday(), 1);
    expect(campo(tester), isEmpty,
        reason: 'DX.04: dopo l\'invio il campo e\' vuoto');
  });

  testWidgets(
      'DX.01: la persona cambia la domanda e parte la sua, non quella scritta',
      (tester) async {
    final ai = _ReadyAi();
    final contatore =
        await pumpChat(tester, await services(ai), initial: domanda);
    await tester.enterText(
        find.descendant(
            of: find.byKey(const Key('chat_campo')),
            matching: find.byType(TextField)),
        'Cosa devo fare della mia lettura?');
    await manda(tester);

    expect(ai.chieste, ['Cosa devo fare della mia lettura?']);
    expect(find.text(domanda), findsNothing,
        reason: 'la domanda preimpostata non doveva partire');
    expect(contatore.usedToday(), 1);
  });

  testWidgets('Col Maestro offline, la domanda resta e la chat non si rompe',
      (tester) async {
    await pumpChat(tester, await services(_OfflineAi()), initial: domanda);

    // La domanda c'e' comunque, nel campo, e non c'e' stato nessun crash.
    expect(campo(tester), domanda);
  });
  // --- ORDINE DZ ---------------------------------------------------------

  /// Una conversazione di ieri con Caligo, gia' salvata.
  Future<void> semina(AppServices svc) async {
    await svc.memory.appendMessage(
        Maestro.caligo,
        ChatMessage(
          role: ChatRole.user,
          text: 'Vecchia domanda sul lavoro',
          at: DateTime(2026, 9, 17, 10),
          conversazione: 'c1',
        ));
    await svc.memory.appendMessage(
        Maestro.caligo,
        ChatMessage(
          role: ChatRole.maestro,
          text: 'Vecchia risposta sul lavoro',
          at: DateTime(2026, 9, 17, 10, 1),
          conversazione: 'c1',
        ));
  }

  testWidgets(
      'DZ.01: da un approfondimento la chat e\' pulita, e la conversazione '
      'di prima si riapre dal menu\'', (tester) async {
    final svc = await services(_ReadyAi());
    await semina(svc);
    await pumpChat(tester, svc, initial: domanda);

    expect(find.text('Vecchia domanda sul lavoro'), findsNothing,
        reason: 'la chat dall\'approfondimento mostra la conversazione di '
            'prima: e\' la confusione della cattura del fondatore');
    expect(campo(tester), domanda);

    // DZ.03: la conversazione di prima e' nel menu', col suo titolo.
    await tester.tap(find.byKey(const Key('chat_menu_della_barra')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('chat_conversazione_passata_0')), findsOneWidget,
        reason: 'la conversazione di prima non e\' nel menu\'');
    expect(find.text('Vecchia domanda sul lavoro'), findsOneWidget,
        reason: 'senza un titolo scritto, il titolo e\' la prima domanda');

    await tester.tap(find.byKey(const Key('chat_conversazione_passata_0')));
    await tester.pumpAndSettle();
    expect(find.text('Vecchia risposta sul lavoro'), findsOneWidget,
        reason: 'toccando il titolo la conversazione non si riapre');
  });

  test('DZ.04: dopo la prima risposta vera la conversazione ha il suo titolo',
      () async {
    final svc = await services(_ReadyAi());
    await semina(svc);
    final scrittore = _ScrittoreFinto();
    final chat = MaestroChatController(
      maestro: Maestro.caligo,
      ai: svc.ai,
      memory: svc.memory,
      titoli: scrittore,
      attesaMinima: Duration.zero,
    );
    await chat.init();
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    chat.iniziaUnaConversazioneNuova(adesso: DateTime(2026, 9, 18, 9));
    await chat.send(domanda);
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(scrittore.chieste, [domanda],
        reason: 'il titolo si chiede una volta, con la prima domanda');
    chat.iniziaUnaConversazioneNuova(adesso: DateTime(2026, 9, 18, 10));
    final titoli = [for (final c in chat.conversazioniPassate) c.titolo];
    expect(titoli.first, 'Il lupo e la lealta',
        reason: 'la conversazione appena lasciata non porta il titolo '
            'scritto: $titoli');
    expect(titoli, contains('Vecchia domanda sul lavoro'));
    final letto = await LeConversazioniPassate.titoli(Maestro.caligo);
    expect(letto.values, contains('Il lupo e la lealta'),
        reason: 'il titolo non resta sul telefono');
  });
}

class _ScrittoreFinto extends ScrittoreDeiTitoli {
  final List<String> chieste = [];

  @override
  Future<String?> scrivi({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  }) async {
    chieste.add(domanda);
    return '"Il lupo e la lealta."';
  }
}

/// Un provider pronto che risponde una riga fissa.
class _ReadyAi implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  bool get isReady => true;

  /// Le domande arrivate al modello, cioe' quelle che costano.
  final List<String> chieste = [];

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
    chieste.add(userMessage);
    return 'Il Lupo ti parla di lealta\'.';
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
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();
}

/// Un provider offline: non pronto, non genera. La chat resta normale.
class _OfflineAi implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  bool get isReady => false;

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
      throw const MaestroAiUnavailable();

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
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();
}
