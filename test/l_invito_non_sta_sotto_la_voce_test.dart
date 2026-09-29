// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
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

/// **L'INVITO A TORNARE NON STA SOTTO UNA RISPOSTA DETTA A VOCE. Ordine ES
/// voce 20, 29 settembre 2026.**
///
/// Il fondatore: *"Deve anche verificare che quello che il maestro dice
/// corrisponda a quello che ha detto."*; e sulla domanda *"Invito a tornare
/// nella chat del LIVE: esce, perché la chat deve dire solo quello che dice
/// la voce. Confermi?"*, *"Confermo tutto"*. Sul Realme, sotto l'ultima
/// risposta di Calìgo nel LIVE, la chat mostrava l'invito che l'app compone
/// da sola (ordine EJ voce 05), e la voce non l'aveva detto.
void main() {
  test('la regola: l\'invito solo sotto l\'ultima, e mai sotto la voce', () {
    expect(
        ConsiglioFinale.invitoSotto(posizione: 9, ultimaDelMaestro: 9), isTrue);
    expect(
        ConsiglioFinale.invitoSotto(
            posizione: 9, ultimaDelMaestro: 9, dettoNelLive: true),
        isFalse,
        reason: 'sotto la risposta detta nel LIVE c\'e\' l\'invito');
  });

  test('il controller segna la risposta detta nel LIVE, e resta segnata',
      () async {
    const intera = 'Le carte dicono di sì, se gli scrivi tu. Il Fante di '
        'Coppe parla di un sentimento timido. La Luna in Ariete spinge a '
        'muoversi.\n✦ Stasera scrivigli due righe semplici.';
    final esiti = <String>[];
    for (final live in [false, true]) {
      final memoria = InMemoryMaestroMemoryRepository();
      final c = MaestroChatController(
        maestro: Maestro.medora,
        ai: _UnaRisposta(intera),
        memory: memoria,
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      )..nelLive = live;
      await c.init();
      await c.send('Lui mi ama davvero?');
      // Il salvataggio nel LIVE corre dietro la voce: si aspetta un giro.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final detta = c.messages.last.dettoNelLive;
      // Riaprendo la conversazione il segno c'e' ancora.
      final riaperta = MaestroChatController(
        maestro: Maestro.medora,
        ai: _UnaRisposta(intera),
        memory: memoria,
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      );
      await riaperta.init();
      final dopo = riaperta.messages.last.dettoNelLive;
      final ultima = riaperta.messages.lastIndexWhere((m) => m.isMaestro);
      final invito = ConsiglioFinale.invitoSotto(
          posizione: ultima,
          ultimaDelMaestro: ultima,
          dettoNelLive: riaperta.messages[ultima].dettoNelLive);
      esiti.add('${live ? 'LIVE' : 'chat'}: detta $detta, riaperta $dopo, '
          'invito $invito');
      expect(detta, live);
      expect(dopo, live);
      expect(invito, !live);
    }
    print('ORDINE ES VOCE 20: $esiti');
  });

  test('il segno viaggia fino a Firestore e torna', () {
    final repo =
        File('lib/services/memory/firestore_maestro_memory_repository.dart')
            .readAsStringSync();
    expect(repo.contains("if (m.dettoNelLive) 'dettoNelLive': true"), isTrue,
        reason: 'il segno non si scrive col messaggio');
    expect(
        repo.contains("dettoNelLive: (data['dettoNelLive'] as bool?)"), isTrue,
        reason: 'il segno non si rilegge riaprendo la conversazione');
  });
}

class _UnaRisposta implements MaestroAiProvider {
  _UnaRisposta(this.testo);
  final String testo;

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
      testo;

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
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
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
