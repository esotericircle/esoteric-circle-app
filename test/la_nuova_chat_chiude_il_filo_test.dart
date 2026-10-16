import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
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

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **NUOVA CHAT CHIUDE IL CONSULTO, NON LA MEMORIA. Ordine FE voce 22.4**,
/// prova c) dell'aggiunta: dopo "Nuova chat" una domanda che tocca il tema
/// vecchio arriva al Maestro senza le battute e senza la scheda del consulto
/// di prima, e con la memoria della persona intatta.
class _CapturingAi implements MaestroAiProvider {
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

  List<ChatMessage> ultimaStoria = const [];
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
    ultimaStoria = history;
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
    UserProfile? profile,
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
  });

  test('Nuova chat: niente filo di prima, memoria intatta', () async {
    final repo = InMemoryMaestroMemoryRepository();
    await repo.saveProfile(UserProfile(
        displayName: 'Sofia', disclaimerAcceptedAt: DateTime(2026, 1, 1)));
    await repo.saveMemory(
        Maestro.medora, const MaestroMemory(facts: ['Segno solare Gemelli']));
    final ai = _CapturingAi();
    final c = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: repo,
        attesaMinima: Duration.zero);
    await c.init();
    await c.send('Riceverò la promozione che aspetto?');
    await _settle();
    expect(
        IlFiloDelConsulto.scheda?.tema, 'Riceverò la promozione che aspetto?');

    c.iniziaUnaConversazioneNuova();
    expect(IlFiloDelConsulto.scheda, isNull,
        reason: "la scheda del consulto di prima e' rimasta");
    expect(IlFiloDelConsulto.bloccoPer(Maestro.medora), isEmpty);

    await c.send('E allora, per quella promozione?');
    await _settle();
    expect(ai.ultimaStoria.map((m) => m.text),
        isNot(contains('Riceverò la promozione che aspetto?')),
        reason: 'le battute del consulto di prima sono arrivate al Maestro');
    expect(ai.lastMemory!.facts, contains('Segno solare Gemelli'),
        reason: "la memoria della persona si e' persa con la chat");
    expect(ai.lastProfile!.displayName, 'Sofia');
  });
}
