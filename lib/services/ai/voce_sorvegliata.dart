import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';
import '../../core/maestro/natal_context.dart';
import 'maestro_ai_provider.dart';
import 'maestro_oracle.dart';
import 'registro_dei_guasti.dart';

/// La voce dei Maestri, sorvegliata.
///
/// Avvolge un qualunque [MaestroAiProvider] e registra ogni guasto prima di
/// rilanciarlo, poi lascia che chi chiama decida il ripiego come ha sempre
/// fatto. Non cambia il contratto: cambia solo che l'errore vero non si perde
/// piu' per strada.
///
/// Perche' un involucro e non un campo nei controllori: alla voce dell'AI si
/// arriva da piu' porte, la chat, il Consulta, la Sintesi comparativa e il
/// distillato di memoria, e ogni porta aveva il suo `catch (_)`. Correggere i
/// chiamanti uno per uno avrebbe lasciato scoperta la porta che nasce domani.
/// Qui la porta e' una sola, e chi ne apre un'altra ci passa senza saperlo.
class VoceSorvegliata implements MaestroAiProvider {
  VoceSorvegliata({required MaestroAiProvider voce, required this.registro})
      : _voce = voce;

  final MaestroAiProvider _voce;

  /// Dove finiscono i guasti. E' lo stesso oggetto che legge il pannello di
  /// messa a punto della chat.
  final RegistroDeiGuasti registro;

  /// La voce sorvegliata, per chi deve sapere chi c'e' davvero sotto.
  MaestroAiProvider get voce => _voce;

  @override
  bool get isReady => _voce.isReady;

  /// Esegue [azione] annotando il guasto sotto il nome dell'[operazione], poi
  /// rilancia. Il rilancio e' la parte che conta: la sorveglianza osserva, non
  /// decide, e il ripiego resta dove era gia'.
  Future<T> _sorvegliando<T>(
    String operazione,
    Future<T> Function() azione,
  ) async {
    try {
      return await azione();
    } catch (errore) {
      registro.registra(operazione: operazione, errore: errore);
      rethrow;
    }
  }

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) {
    return _sorvegliando(
      'reply',
      () => _voce.reply(
        maestro: maestro,
        profile: profile,
        memory: memory,
        history: history,
        userMessage: userMessage,
      ),
    );
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) {
    return _sorvegliando(
      'consult',
      () => _voce.consult(
        maestro: maestro,
        theme: theme,
        profile: profile,
        memory: memory,
        natal: natal,
        depth: depth,
      ),
    );
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) {
    return _sorvegliando(
      'synthesize',
      () => _voce.synthesize(theme: theme, lenses: lenses, natal: natal),
    );
  }

  /// Il distillato di memoria e' l'unica operazione che per contratto non
  /// solleva: chi chiama si aspetta null e tira avanti. La sorveglianza tiene
  /// il contratto, ma il guasto lo scrive lo stesso invece di lasciarlo
  /// evaporare come faceva il `catch (_)` dentro il provider.
  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    try {
      return await _voce.distill(
        maestro: maestro,
        profile: profile,
        previous: previous,
        history: history,
      );
    } catch (errore) {
      registro.registra(operazione: 'distill', errore: errore);
      return null;
    }
  }
}
