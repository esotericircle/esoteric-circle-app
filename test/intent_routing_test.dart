import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
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
      expect(
          classifier
              .classify(Maestro.medora, 'fammi una stesa di tarocchi')
              ?.target,
          ImmersiveTarget.tarocchiStesa);
      expect(
          classifier
              .classify(Maestro.medora, 'mostrami la mia carta natale')
              ?.target,
          ImmersiveTarget.cartaNatale);
      expect(
          classifier
              .classify(Maestro.medora, 'voglio l\'oroscopo di oggi')
              ?.target,
          ImmersiveTarget.oroscopoGiorno);
      expect(
          classifier
              .classify(Maestro.aura, 'guidami in una meditazione')
              ?.target,
          ImmersiveTarget.meditazione);
      expect(
          classifier.classify(Maestro.aura, 'parlami dei miei chakra')?.target,
          ImmersiveTarget.scanChakra);
      expect(
          classifier.classify(Maestro.caligo, 'lancia le rune per me')?.target,
          ImmersiveTarget.lancioRune);
      expect(
          classifier.classify(Maestro.caligo, 'consultiamo l\'i-ching')?.target,
          ImmersiveTarget.iChing);
    });

    test('L\'allow-list e per Maestro: le rune non scattano per Medora', () {
      expect(classifier.classify(Maestro.medora, 'lancia le rune'), isNull);
      expect(classifier.classify(Maestro.caligo, 'stesa di tarocchi'), isNull);
    });

    test('Una domanda normale del dominio non instrada', () {
      expect(
          classifier.classify(Maestro.medora, 'cosa significa la mia Venere?'),
          isNull);
      expect(classifier.classify(Maestro.aura, 'perché mi sento agitato oggi?'),
          isNull);
    });

    test('La chiave scatta solo come parola intera', () {
      // "rune" dentro "prune" non deve attivare l'intento.
      expect(
          classifier.classify(Maestro.caligo, 'le prune sono buone'), isNull);
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

    // **LA CARTA DEL GIORNO CONSEGNA UNA CARTA. Ordine DS voce 08.**
    //
    // Sulle catture di un fondatore, *"Carta del giorno"* due volte, e due
    // volte il modello parlava di Saturno e della Luna senza nominare nessun
    // arcano. La carta adesso non la sceglie il modello: e' l'Arcano del
    // Giorno, e deve essere **la stessa** che il Dono mostra alla persona.
    for (final domanda in const [
      'Carta del giorno',
      'Tira una carta per me',
      'qual e la mia carta di oggi?',
    ]) {
      test('"$domanda" nomina la carta del giorno, senza chiamare il modello',
          () async {
        final ai = _RecordingAi();
        final nascita = DateTime(1984, 3, 9);
        final oggi = DateTime(2026, 9, 17, 0, 21);
        final controller = MaestroChatController(
          maestro: Maestro.medora,
          ai: ai,
          memory: InMemoryMaestroMemoryRepository(),
          nascita: () => nascita,
          orologio: () => oggi,
        );
        await controller.init();
        await controller.send(domanda);
        final carta = ArcanoDelGiorno.di(oggi, nascita: nascita);
        final last = controller.messages.last;
        expect(last.isMaestro, isTrue);
        expect(last.text, contains(carta.name),
            reason: 'la risposta a "$domanda" non nomina la carta del giorno, '
                '${carta.name}: "${last.text}"');
        expect(last.intentId, ImmersiveTarget.arcanoDelGiorno.name,
            reason: 'sotto la carta manca il pulsante che la apre');
        expect(ai.replies, 0,
            reason: 'la carta del giorno e passata dal modello, che la '
                'inventerebbe');
      });
    }

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
    String? rispostaGiaData,
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
