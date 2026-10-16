// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

/// **NESSUNA BOLLA VUOTA.** Ordine ET voce 01, 28 settembre 2026.
///
/// Nel banco delle trenta domande, sul commit di partenza, Aura nel LIVE ha
/// risposto a *"Riuscirò ad avere un figlio?"* con un testo che, passate le
/// reti del controller, era vuoto: la bolla e' arrivata vuota e nel LIVE non
/// e' stato detto niente (`docs/collaudo/ET/trenta_domande/prima/
/// aura_live_esecuzione_1.md`, domanda 14). Nessun contatore delle reti era
/// scattato: nessuna rete controllava il testo che restava.
///
/// Qui un modello finto risponde con il solo marcatore `[[CHIEDO]]`, che
/// l'app toglie: la risposta si chiede di nuovo una volta, e se anche la
/// seconda e' vuota arriva la lettura di ripiego, dichiarata. Mai una bolla
/// vuota, in chat e nel LIVE.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<(MaestroChatController, _ColCopione)> conversa(
      List<String> copione, bool live) async {
    final ai = _ColCopione(copione);
    final c = MaestroChatController(
      maestro: Maestro.aura,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      natal: () => NatalContext.none,
      demo: true,
      attesaMinima: Duration.zero,
    )..nelLive = live;
    await c.init();
    await c.send('Riuscirò ad avere un figlio?');
    return (c, ai);
  }

  for (final live in [false, true]) {
    final dove = live ? 'nel LIVE' : 'in chat';
    test('ET.01 $dove: una risposta vuota dopo le reti si chiede di nuovo',
        () async {
      final (c, ai) = await conversa([
        '[[CHIEDO]]',
        'I tuoi centri dicono di sì, se ascolti il corpo con calma e col medico '
            'accanto.\n✦ Stasera scrivi due domande per il tuo medico.',
      ], live);
      final ultima = c.messages.last;
      print('ORDINE ET VOCE 1 $dove: chiamate ${ai.volte}, testo della bolla '
          '«${ultima.text}»');
      expect(ultima.role, ChatRole.maestro);
      expect(ultima.text.trim(), isNotEmpty, reason: 'la bolla e\' vuota');
      expect(ai.volte, 2,
          reason: 'la risposta vuota non si e\' chiesta di '
              'nuovo');
      expect(ultima.ripiego, isFalse);
    });

    test('ET.01 $dove: vuota due volte, arriva la lettura di ripiego',
        () async {
      final (c, ai) = await conversa(['[[CHIEDO]]', '[[CHIEDO]]'], live);
      final ultima = c.messages.last;
      expect(ultima.text.trim(), isNotEmpty, reason: 'la bolla e\' vuota');
      expect(ultima.ripiego, isTrue,
          reason: 'la lettura di ripiego va dichiarata');
      expect(ai.volte, 2);
    });
  }
}

/// Un modello finto che risponde col suo copione, una risposta per chiamata.
class _ColCopione implements MaestroAiProvider {
  _ColCopione(this.copione);
  final List<String> copione;
  int volte = 0;

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
      copione[(volte++).clamp(0, copione.length - 1)];

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
