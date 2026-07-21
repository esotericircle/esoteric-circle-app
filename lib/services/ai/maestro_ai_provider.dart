import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';
import '../../core/maestro/natal_context.dart';
import 'maestro_oracle.dart';

/// Confine astratto verso l'AI a runtime dei Maestri.
///
/// Regola d'oro dello stack: Claude costruisce, Gemini fa girare. La UI e i
/// controller dipendono solo da questa astrazione, mai da Firebase o da Gemini
/// direttamente. Cosi' domani si potra' incastrare davanti il gateway di
/// caching (che intercetta circa il 70% delle richieste) senza toccare una riga
/// di presentazione, e si potra' cambiare fornitore riscrivendo solo l'impl.
///
/// L'implementazione concreta di oggi e' `FirebaseMaestroAiProvider`, che parla
/// con Gemini su Vertex tramite Firebase AI Logic, protetto da App Check.
abstract interface class MaestroAiProvider {
  /// Vero se il provider e' pronto a generare davvero. Falso quando Firebase o
  /// l'AI Logic non sono configurati: in quel caso la chat mostra un avviso di
  /// configurazione, mai un errore crudo.
  bool get isReady;

  /// Genera la risposta del Maestro al messaggio dell'utente, tenendo conto del
  /// profilo, della memoria e della storia recente della conversazione.
  ///
  /// La composizione del prompt (persona, regole di lingua, contesto di
  /// memoria) e' responsabilita' dell'implementazione: chi chiama passa solo i
  /// fatti, non il prompt gia' cotto.
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  });

  /// Consulta UN Maestro su un [theme], a domanda singola, e restituisce i tre
  /// strati della sua risposta ([MaestroReply]).
  ///
  /// E' la via di "Chiedi ai Maestri", distinta dalla chat: niente storia di
  /// conversazione, una sola domanda e una sola risposta nella lente del
  /// dominio. La composizione del prompt (persona, regole di lingua, contesto di
  /// memoria e, quando ci sara', il [natal]) e' dell'implementazione: chi chiama
  /// passa i fatti, non il prompt gia' cotto. La firma prevede gia' la
  /// personalizzazione natale, oggi inerte con [natal] a null, cosi' non andra'
  /// riscritta quando arrivera'.
  ///
  /// Se il provider non e' pronto o non trova le parole, solleva
  /// [MaestroAiUnavailable]: chi chiama cade sul ripiego deterministico, mai un
  /// errore crudo a video.
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  });

  /// Genera la Sintesi comparativa di "Consulta un Maestro" quando i Maestri
  /// interpellati sono piu' di uno: mette a confronto le [lenses] gia' ottenute
  /// sul [theme] (le stesse tre strati per Maestro gia' vive, non le rifa'), col
  /// [natal] a personalizzare, e chiude con la regola dove le voci concordano
  /// ascolta con piu' fiducia, dove divergono hai piu' strade.
  ///
  /// Se il provider non e' pronto o non trova le parole, solleva
  /// [MaestroAiUnavailable]: chi chiama cade sulla sintesi deterministica
  /// (`MaestroOracle.synthesisFor`), mai un errore crudo a video.
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  });

  /// Distilla la conversazione in una sintesi piu' pochi fatti stabili, per
  /// aggiornare la memoria. E' un'operazione a basso costo e best effort: se
  /// fallisce restituisce null e la memoria precedente resta valida.
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  });
}

/// Sollevata quando si prova a generare senza un provider pronto.
class MaestroAiUnavailable implements Exception {
  const MaestroAiUnavailable([this.message = 'AI dei Maestri non configurata.']);
  final String message;

  @override
  String toString() => 'MaestroAiUnavailable: $message';
}

/// Provider inerte usato quando l'AI non e' configurata (per esempio in un
/// ambiente senza credenziali Firebase). Non genera nulla e lo dichiara: la UI
/// se ne accorge da `isReady` e mostra l'avviso di configurazione con garbo,
/// senza far crollare il resto dell'app.
class UnavailableMaestroAiProvider implements MaestroAiProvider {
  const UnavailableMaestroAiProvider();

  @override
  bool get isReady => false;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    throw const MaestroAiUnavailable();
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
    throw const MaestroAiUnavailable();
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async {
    throw const MaestroAiUnavailable();
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    return null;
  }
}
