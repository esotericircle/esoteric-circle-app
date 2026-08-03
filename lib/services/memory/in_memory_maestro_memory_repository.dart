import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/maestro.dart';
import 'maestro_memory_repository.dart';
import 'memory_hooks.dart';

/// Memoria volatile, tenuta solo in RAM per la durata della sessione.
///
/// E' il ripiego quando Firestore non e' disponibile (ambiente senza
/// credenziali, avvio a freddo prima della configurazione): la chat resta
/// usabile e non perde il filo dentro la stessa apertura, ma non ricorda fra un
/// avvio e l'altro. Nessun crash, nessun vicolo cieco. Espone le stesse prese
/// dei livelli profondi (indice semantico, archivio), a vuoto per default, cosi'
/// il comportamento e' identico a quello persistente.
class InMemoryMaestroMemoryRepository implements MaestroMemoryRepository {
  InMemoryMaestroMemoryRepository({
    this.uid = 'local',
    SemanticIndexHook semanticIndex = const NoopSemanticIndexHook(),
    HistoryArchiveHook archive = const NoopHistoryArchiveHook(),
  })  : _semanticIndex = semanticIndex,
        _archive = archive;

  final String uid;
  final SemanticIndexHook _semanticIndex;
  final HistoryArchiveHook _archive;

  UserProfile _profile = UserProfile.empty;
  final Map<Maestro, MaestroMemory> _memory = {};
  final Map<Maestro, List<ChatMessage>> _messages = {};

  @override
  Future<UserProfile> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<MaestroMemory> loadMemory(Maestro maestro) async =>
      _memory[maestro] ?? MaestroMemory.empty;

  @override
  Future<void> saveMemory(Maestro maestro, MaestroMemory memory) async {
    _memory[maestro] = memory;
  }

  @override
  Future<List<ChatMessage>> recentMessages(Maestro maestro,
      {int limit = 40}) async {
    final list = _messages[maestro] ?? const [];
    if (list.length <= limit) return List.of(list);
    return list.sublist(list.length - limit);
  }

  @override
  Future<void> appendMessage(Maestro maestro, ChatMessage message) async {
    (_messages[maestro] ??= []).add(message);
    // Prese verso i livelli profondi: a vuoto per default.
    await _semanticIndex.index(uid, maestro, message);
    await _archive.archive(uid, maestro, message);
  }

  @override
  Future<void> sostituisciUltimoMessaggio(
      Maestro maestro, ChatMessage messaggio) async {
    final lista = _messages[maestro];
    if (lista == null || lista.isEmpty) {
      await appendMessage(maestro, messaggio);
      return;
    }
    lista[lista.length - 1] = messaggio;
    await _semanticIndex.index(uid, maestro, messaggio);
    await _archive.archive(uid, maestro, messaggio);
  }

  @override
  Future<void> deleteAllData() async {
    _profile = UserProfile.empty;
    _memory.clear();
    _messages.clear();
    await _semanticIndex.forget(uid);
    await _archive.purge(uid);
  }
}
