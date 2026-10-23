import '../../core/chat/chat_message.dart';
import '../../core/maestro/maestro.dart';

/// Ganci del memory layer verso i livelli piu' profondi, predisposti ma non
/// attivi.
///
/// Il memory layer pieno, previsto dai briefing, avra' tre strati: la memoria
/// calda su Firestore (profilo, fatti, sintesi, cronologia), un indice
/// semantico su Cloud SQL con pgvector per il richiamo dei ricordi rilevanti, e
/// l'archiviazione dello storico lungo su Cloud Storage. Qui vivono le prese di
/// quei due strati, con implementazioni a vuoto: la memoria calda funziona da
/// sola, e quando arriveranno pgvector e lo storage basta iniettare
/// un'implementazione vera al posto di quella a vuoto, senza toccare i
/// repository ne' la chat.

/// Indice semantico dei messaggi per il richiamo dei ricordi rilevanti.
/// Predisposto per pgvector su Cloud SQL, oggi a vuoto.
abstract interface class SemanticIndexHook {
  /// Indicizza un messaggio appena scritto, per poterlo poi richiamare.
  Future<void> index(String uid, Maestro maestro, ChatMessage message);

  /// Dimentica tutto l'indice di un utente, per la cancellazione GDPR.
  Future<void> forget(String uid);
}

/// Archiviazione dello storico lungo su un livello freddo.
/// Predisposta per Cloud Storage, oggi a vuoto.
abstract interface class HistoryArchiveHook {
  /// Archivia un messaggio nel livello freddo.
  Future<void> archive(String uid, Maestro maestro, ChatMessage message);

  /// Cancella l'archivio freddo di un utente, per la cancellazione GDPR.
  Future<void> purge(String uid);
}

/// Indice semantico a vuoto: la presa esiste, non fa nulla. Default finche' non
/// c'e' pgvector.
class NoopSemanticIndexHook implements SemanticIndexHook {
  const NoopSemanticIndexHook();

  @override
  Future<void> index(String uid, Maestro maestro, ChatMessage message) async {}

  @override
  Future<void> forget(String uid) async {}
}

/// Archivio a vuoto: la presa esiste, non fa nulla. Default finche' non c'e'
/// Cloud Storage.
class NoopHistoryArchiveHook implements HistoryArchiveHook {
  const NoopHistoryArchiveHook();

  @override
  Future<void> archive(
      String uid, Maestro maestro, ChatMessage message) async {}

  @override
  Future<void> purge(String uid) async {}
}
