import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/intent_classifier.dart';
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

/// Instradamento della chat verso le funzioni immersive: un classificatore
/// deterministico riconosce l'intento e il Maestro invita ad aprire la funzione,
/// senza chiamare l'AI.
void main() {
  const classifier = IntentClassifier();

  group('Classificatore d\'intento', () {
    test('Riconosce gli intenti immersivi per Maestro', () {
      expect(classifier.classify(Maestro.medora, 'fammi una stesa di tarocchi')?.target,
          ImmersiveTarget.tarocchiStesa);
      expect(classifier.classify(Maestro.medora, 'mostrami la mia carta natale')?.target,
          ImmersiveTarget.cartaNatale);
      expect(classifier.classify(Maestro.medora, 'voglio l\'oroscopo di oggi')?.target,
          ImmersiveTarget.oroscopoGiorno);
      expect(classifier.classify(Maestro.aura, 'guidami in una meditazione')?.target,
          ImmersiveTarget.meditazione);
      expect(classifier.classify(Maestro.aura, 'parlami dei miei chakra')?.target,
          ImmersiveTarget.scanChakra);
      expect(classifier.classify(Maestro.caligo, 'lancia le rune per me')?.target,
          ImmersiveTarget.lancioRune);
      expect(classifier.classify(Maestro.caligo, 'consultiamo l\'i-ching')?.target,
          ImmersiveTarget.iChing);
    });

    test('L\'allow-list e per Maestro: le rune non scattano per Medora', () {
      expect(classifier.classify(Maestro.medora, 'lancia le rune'), isNull);
      expect(classifier.classify(Maestro.caligo, 'stesa di tarocchi'), isNull);
    });

    test('Una domanda normale del dominio non instrada', () {
      expect(classifier.classify(Maestro.medora, 'cosa significa la mia Venere?'),
          isNull);
      expect(classifier.classify(Maestro.aura, 'perché mi sento agitato oggi?'),
          isNull);
    });

    test('La chiave scatta solo come parola intera', () {
      // "rune" dentro "prune" non deve attivare l'intento.
      expect(classifier.classify(Maestro.caligo, 'le prune sono buone'), isNull);
    });
  });

  group('Instradamento in chat', () {
    test('Un intento immersivo invita senza chiamare l\'AI', () async {
      final ai = _RecordingAi();
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
      );
      await controller.init();

      await controller.send('puoi farmi una stesa di tarocchi?');

      // Ultimo messaggio: l'invito del Maestro con il pulsante immersivo.
      final last = controller.messages.last;
      expect(last.isMaestro, isTrue);
      expect(last.intentId, ImmersiveTarget.tarocchiStesa.name);
      expect(last.text, contains('stendiamole'));
      // L'AI non e' stata chiamata.
      expect(ai.replies, 0);
    });

    test('Una domanda normale chiama l\'AI come sempre', () async {
      final ai = _RecordingAi();
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
      );
      await controller.init();

      await controller.send('cosa significa la mia Venere?');
      expect(ai.replies, 1);
      expect(controller.messages.last.intentId, isNull);
    });
  });
}

/// Provider AI che conta le chiamate, per provare che l'instradamento non
/// tocca l'AI.
class _RecordingAi implements MaestroAiProvider {
  int replies = 0;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<dynamic> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool aDueStrati = true,
  }) async {
    replies++;
    return 'Una risposta a testo.';
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
    required List<dynamic> history,
  }) async =>
      null;
}
