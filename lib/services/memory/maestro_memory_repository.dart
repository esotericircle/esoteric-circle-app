import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/maestro.dart';

/// Confine astratto verso la persistenza della memoria dei Maestri.
///
/// Per la Demo l'implementazione e' su Firestore (profilo piu' fatti piu'
/// sintesi di sessione). L'evoluzione verso Cloud SQL con pgvector, il memory
/// layer a tre strati pieno, vivra' dietro questa stessa interfaccia, senza
/// toccare controller ne' UI.
abstract interface class MaestroMemoryRepository {
  /// Profilo condiviso dell'utente (nome, forma di cortesia, disclaimer visto).
  Future<UserProfile> loadProfile();

  /// Salva il profilo, per esempio dopo l'accettazione del disclaimer.
  Future<void> saveProfile(UserProfile profile);

  /// Memoria specifica di un Maestro (fatti stabili piu' sintesi di sessione).
  Future<MaestroMemory> loadMemory(Maestro maestro);

  /// Aggiorna la memoria di un Maestro dopo il distillato della conversazione.
  Future<void> saveMemory(Maestro maestro, MaestroMemory memory);

  /// Ultimi messaggi scambiati con un Maestro, dal piu' vecchio al piu' nuovo.
  Future<List<ChatMessage>> recentMessages(Maestro maestro, {int limit = 40});

  /// Aggiunge un messaggio alla cronologia persistente del Maestro.
  Future<void> appendMessage(Maestro maestro, ChatMessage message);
}
