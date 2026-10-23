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
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **"QUEL GIORNO" RIAPRE LA CONVERSAZIONE VERA, E DICE L'ANNO.** Ordine GB
/// voce 07, 22 ottobre 2026. Il rapporto dell'ordine GA, punto 7: *"il
/// Diario si riapre in 'Quel giorno' senza la chat; non ha l'anno"*.
///
/// Qui si prova il punto che conta davvero: `MaestroChatScreen` con
/// `apriConversazioneId` non nullo carica i messaggi VERI di quella
/// conversazione (non un riassunto a parte) e, con `apriConversazioneQuando`
/// noto, dice la data con l'anno. `RicordoApertoScreen.rottaDelTurno`
/// (in `lib/features/ricordi/ricordi_screen.dart`) non e' altro che questa
/// stessa rotta, con l'identificativo letto dal Diario: provarla qui, sulla
/// rotta vera che costruisce, vale anche per lei.
class _VoceMuta implements MaestroAiProvider {
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
      throw const MaestroAiUnavailable('non chiamata in questa prova');

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
    UserProfile? profile,
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

void main() {
  testWidgets(
      'apriConversazioneId carica i messaggi veri di quella conversazione, '
      'e la striscia dice la data con l\'anno', (tester) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2025, 1, 1)));
    await memoria.appendMessage(
      Maestro.medora,
      ChatMessage(
        role: ChatRole.user,
        text: 'Devo cambiare lavoro quest\'anno?',
        at: DateTime(2025, 8, 27, 10),
        conversazione: 'c_2025_08_27',
      ),
    );
    await memoria.appendMessage(
      Maestro.medora,
      ChatMessage(
        role: ChatRole.maestro,
        text: 'Il cielo di quel giorno mostrava un passaggio lento.',
        at: DateTime(2025, 8, 27, 10, 1),
        conversazione: 'c_2025_08_27',
      ),
    );
    // Una conversazione DIVERSA, piu' recente: la prova deve mostrare solo
    // quella del 27 agosto 2025, non la storia intera.
    await memoria.appendMessage(
      Maestro.medora,
      ChatMessage(
        role: ChatRole.user,
        text: 'Una domanda di oggi, non di quel giorno',
        at: DateTime(2026, 10, 20, 9),
        conversazione: 'c_oggi',
      ),
    );

    final servizi = AppServices(
      ai: _VoceMuta(),
      memory: memoria,
      memoryPersistent: false,
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Navigator(
          onGenerateRoute: (_) => MaestroChatScreen.route(
            maestro: Maestro.medora,
            services: servizi,
            apriConversazioneId: 'c_2025_08_27',
            apriConversazioneQuando: DateTime(2025, 8, 27),
          ),
        ),
      ),
    ));
    await tester.pump();
    // apriLaConversazione chiede alla memoria, che e' asincrona anche a
    // vuoto: qualche giro di coda basta sulla finta in RAM.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Devo cambiare lavoro quest\'anno?'), findsOneWidget,
        reason: 'la conversazione vera del 27 agosto 2025 non e\' arrivata '
            'in chat');
    expect(
        find.text('Il cielo di quel giorno mostrava un passaggio lento.'),
        findsOneWidget);
    expect(find.text('Una domanda di oggi, non di quel giorno'), findsNothing,
        reason: 'e\' arrivata la conversazione di oggi, non quella di quel '
            'giorno');

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Hai riaperto la conversazione del 27 agosto 2025'),
        findsOneWidget,
        reason: 'la striscia della data non dice l\'anno, o non compare');
  });
}
