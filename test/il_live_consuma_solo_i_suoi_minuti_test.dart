import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LIVE CONSUMA SOLO I SUOI MINUTI.** Ordine EG voce 06, 23 settembre
/// 2026.
///
/// Il fatto: il fondatore ha parlato con Medora a voce e poi, tornato nella
/// chat, ha letto *"Non ti resta nessuna domanda ai Maestri, oggi"*. Il LIVE
/// usa lo stesso controller della chat scritta, e il costo lo spegneva in
/// `_applicaIlCosto`; ma la strada principale del turno addebitava a mano,
/// fuori da quel punto, e ogni frase detta a voce si prendeva una domanda.
///
/// **La seconda prova tiene onesta la prima**: senza LIVE lo stesso turno
/// deve costare, altrimenti un contatore rotto passerebbe per un LIVE giusto.
void main() {
  MaestroChatController chatCon(QuestionAllowance contatore) =>
      MaestroChatController(
        maestro: Maestro.medora,
        memory: InMemoryMaestroMemoryRepository(),
        ai: _VoceCheRisponde(),
        allowance: contatore,
        tier: () => Tier.free,
        attesaMinima: Duration.zero,
      );

  test('UN TURNO DETTO NEL LIVE NON SI PRENDE LA DOMANDA DEL GIORNO', () async {
    final contatore = QuestionAllowance();
    final chat = chatCon(contatore)..nelLive = true;
    await chat.init();
    await chat.send('Che cosa mi consigli per domani?');
    expect(chat.messages.last.isMaestro, isTrue,
        reason: 'il Maestro doveva rispondere, o la prova non misura niente');
    expect(contatore.usedToday(), 0,
        reason: 'un turno a voce ha consumato una domanda della chat: il LIVE '
            'si paga coi suoi minuti, non due volte');
  });

  // **E NON ASPETTA UNA SCENA CHE NON C'E'.** La chat scritta consegna la
  // risposta dopo almeno quattro secondi, il tempo della scena dell'attesa;
  // nel LIVE quella scena non si vede, e i quattro secondi erano attesa pura
  // a ogni turno detto a voce. Il telefono di collaudo non li mostrava perche'
  // ha le animazioni spente, e la pausa li' scende a 0,7.
  test('NEL LIVE LA RISPOSTA ARRIVA SENZA LA PAUSA DELLA SCENA', () async {
    final chat = MaestroChatController(
      maestro: Maestro.medora,
      memory: InMemoryMaestroMemoryRepository(),
      ai: _VoceCheRisponde(),
    )..nelLive = true;
    await chat.init();
    await chat.send('Che cosa mi consigli per domani?');
    expect(chat.ultimaAttesaMs, lessThan(1000),
        reason: 'nel LIVE il turno ha aspettato ${chat.ultimaAttesaMs} ms una '
            'scena che a video non c\'e\'');
  });

  test('E FUORI DAL LIVE LA SCENA HA IL SUO TEMPO', () async {
    final chat = MaestroChatController(
      maestro: Maestro.medora,
      memory: InMemoryMaestroMemoryRepository(),
      ai: _VoceCheRisponde(),
    );
    await chat.init();
    await chat.send('Che cosa mi consigli per domani?');
    expect(chat.ultimaAttesaMs, greaterThanOrEqualTo(3900),
        reason: 'la pausa della chat scritta non deve cambiare');
  });

  test('E LO STESSO TURNO NELLA CHAT SCRITTA COSTA UNA DOMANDA', () async {
    final contatore = QuestionAllowance();
    final chat = chatCon(contatore);
    await chat.init();
    await chat.send('Che cosa mi consigli per domani?');
    expect(contatore.usedToday(), 1,
        reason: 'fuori dal LIVE una risposta vera deve costare');
  });
}

class _VoceCheRisponde implements MaestroAiProvider {
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
      'Domani la Luna ti chiede di rallentare prima di scegliere. Ascolta '
      'cosa ti muove, non cosa ti spinge.';

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
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
      throw UnimplementedError();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
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
