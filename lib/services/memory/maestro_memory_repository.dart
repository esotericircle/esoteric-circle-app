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

  /// SOSTITUISCE l'ultimo messaggio salvato, che e' il turno del Maestro
  /// ancora in attesa, con quello definitivo.
  ///
  /// Serve perche' la domanda e il suo turno di risposta nascono INSIEME e si
  /// salvano insieme: il turno esiste gia', in attesa, dal momento in cui la
  /// domanda parte. Quando la risposta arriva non se ne aggiunge un altro, si
  /// completa quello. Senza questo, l'unico modo di avere il turno persistito
  /// sarebbe salvarlo alla fine, cioe' non averlo se la fine non arriva.
  Future<void> sostituisciUltimoMessaggio(
      Maestro maestro, ChatMessage messaggio);

  /// Cancella tutta la memoria dell'utente, per il diritto all'oblio (GDPR):
  /// profilo, memoria di ogni Maestro e cronologia completa, più gli eventuali
  /// livelli profondi predisposti (indice semantico, archivio freddo). Isolata
  /// al solo utente corrente. Dopo, il cerchio riparte come al primo giorno.
  Future<void> deleteAllData();
}
