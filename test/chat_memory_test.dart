import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// La chat dei Maestri e' collegata alla memoria: la conversazione si persiste
/// e i ricordi rilevanti tornano nel contesto passato all'AI. La regola anti
/// invenzione vive nella persona (coperta da accents_test e dalla persona
/// stessa); qui si prova il flusso di persistenza e richiamo.
class _CapturingAi implements MaestroAiProvider {
  MaestroMemory? lastMemory;
  UserProfile? lastProfile;
  int distills = 0;

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
    lastMemory = memory;
    lastProfile = profile;
    return 'Le stelle ti ascoltano.';
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
    return const MaestroReply(
      glance: 'Un colpo d\'occhio.',
      reading: 'Il testo narrato.',
      invite: 'Un invito.',
    );
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
  }) async {
    distills++;
    return const MemoryDigest(
      summary: 'Avete parlato del lavoro.',
      facts: ['Cerca chiarezza sul lavoro'],
    );
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('La conversazione si persiste e i ricordi tornano nel contesto',
      () async {
    final repo = InMemoryMaestroMemoryRepository();
    await repo.saveProfile(
      UserProfile(
        displayName: 'Sofia',
        courtesyForm: CourtesyForm.feminine,
        disclaimerAcceptedAt: DateTime(2026, 1, 1),
      ),
    );
    await repo.saveMemory(
      Maestro.medora,
      const MaestroMemory(
        facts: ['Segno solare Gemelli'],
        sessionSummary: 'Del suo Ascendente.',
      ),
    );

    final ai = _CapturingAi();
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: repo,
    );
    await controller.init();

    // Il profilo e la memoria calda sono caricati.
    expect(controller.profile.displayName, 'Sofia');

    await controller.send('Parlami del mio segno');
    await _settle();

    // I ricordi rilevanti sono tornati nel contesto passato all'AI.
    expect(ai.lastMemory, isNotNull);
    expect(ai.lastMemory!.facts, contains('Segno solare Gemelli'));
    expect(ai.lastProfile!.displayName, 'Sofia');

    // La conversazione si e' persistita nella cronologia del repository.
    final saved = await repo.recentMessages(Maestro.medora);
    expect(saved.map((m) => m.text),
        containsAll(['Parlami del mio segno', 'Le stelle ti ascoltano.']));
  });

  test('Ogni tre turni la memoria calda si aggiorna dal distillato', () async {
    final repo = InMemoryMaestroMemoryRepository();
    await repo.saveProfile(
      UserProfile(disclaimerAcceptedAt: DateTime(2026, 1, 1)),
    );
    final ai = _CapturingAi();
    final controller = MaestroChatController(
      maestro: Maestro.aura,
      ai: ai,
      memory: repo,
    );
    await controller.init();

    for (var i = 0; i < 3; i++) {
      await controller.send('messaggio $i');
      await _settle();
    }

    expect(ai.distills, greaterThanOrEqualTo(1));
    final m = await repo.loadMemory(Maestro.aura);
    expect(m.facts, contains('Cerca chiarezza sul lavoro'));
    expect(m.sessionSummary, 'Avete parlato del lavoro.');
  });
}
