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

import 'package:esoteric_circle/core/astro/il_cielo_che_arriva.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';

/// **IL CIELO SI PREPARA QUANDO LA CHAT SI APRE. Ordine FE voci 05 e 06.**
/// Su Firebase Test Lab, Galaxy A16 5G, il primo turno fermava il filo fino
/// a 111 ms mentre l'isolate calcolava gli eventi in arrivo; col cielo gia'
/// pronto i turni restavano sotto i 35 ms. La chat, aprendosi, lo prepara:
/// il primo turno del LIVE, che si apre da una chat, lo trova pronto.
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

void main() {
  test('aprendo la chat con una nascita il cielo diventa pronto, senza domande',
      () async {
    IlCieloCheArriva.dimentica();
    final prima = IlCieloCheArriva.calcoli;
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: _CapturingAi(),
      memory: InMemoryMaestroMemoryRepository(),
      natal: () => const NatalContext(sunSign: 'Gemelli'),
    );
    await controller.init();
    final orologio = Stopwatch()..start();
    while (IlCieloCheArriva.gia(adesso: DateTime.now(), segno: Zodiac.gemini) ==
            null &&
        orologio.elapsed < const Duration(seconds: 30)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(IlCieloCheArriva.calcoli, prima + 1,
        reason: 'la chat aperta non ha preparato il cielo: il primo turno del '
            "LIVE lo calcolera' mentre la persona aspetta la voce");
    expect(IlCieloCheArriva.gia(adesso: DateTime.now(), segno: Zodiac.gemini),
        isNotNull);
  });
}
