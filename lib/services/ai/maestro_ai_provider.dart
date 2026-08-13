import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';
import '../../core/responsi/anatomia_del_responso.dart';
import '../../core/rituals/rune_cast.dart';
import '../../core/maestro/natal_context.dart';
import 'maestro_oracle.dart';

/// Confine astratto verso l'AI a runtime dei Maestri.
///
/// Regola d'oro dello stack: l'AI a runtime e' Gemini. La UI e i
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
  /// Il [natal] NON e' facoltativo per comodita': e' il dato che rende la
  /// risposta di questa persona invece che di chiunque. Sta sul confine, e non
  /// nella singola implementazione, perche' cosi' nessuna superficie puo'
  /// chiamare il Maestro dimenticandolo: prima la chat lo faceva, e i dati
  /// natali arrivavano alla frase di benvenuto e non alla risposta.
  ///
  /// Con [insistiSullAncoraggio] a vero l'implementazione stringe l'istruzione:
  /// serve alla SECONDA e unica rigenerazione, quando la prima risposta non ha
  /// nominato nessuno dei dati disponibili.
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
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

  /// IL PRESAGIO DELLE RUNE, composto dal modello. Ordine S voce 19, punto 3
  /// della decisione D5 di Mauro.
  ///
  /// **Perche' questa e' l'unica bolla che passa dal modello.** E' la sola che deve
  /// DAVVERO rispondere alla domanda posta, ed e' una sola per gettata: le
  /// ventiquattro rune singole restano corpus, brevi e ancorate al simbolo, perche'
  /// altrimenti servirebbero 576 testi generati per ogni lettura.
  ///
  /// **UNA GENERAZIONE AL GIORNO NEL PIANO GRATUITO, e non serve un contatore
  /// nuovo.** Il presagio si chiede una volta per gettata, e le gettate del giorno
  /// sono gia' limitate dal tier: nel piano gratuito e' una, quindi una generazione.
  /// Aggiungere un secondo limite qui vorrebbe dire due contatori per la stessa
  /// cosa, e al primo ritocco direbbero numeri diversi.
  ///
  /// Riceve i FATTI e non il prompt: la gettata, le rune uscite coi loro versi,
  /// posizioni e significati dal corpus, e la domanda scelta (vuota se la persona
  /// non ne ha scelta nessuna). La composizione dell'istruzione e'
  /// dell'implementazione.
  ///
  /// **Se il modello non c'e' o non trova le parole solleva [MaestroAiUnavailable]**,
  /// e chi chiama cade sul ripiego deterministico: cornice dell'allegato B piu' la
  /// frase della runa. **Il ripiego non si dichiara mai come ripiego**, quindi la
  /// persona non deve poter capire quale dei due sta leggendo.
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  });

  /// Genera la Sintesi comparativa di "Consulta un Maestro" quando i Maestri
  /// interpellati sono piu' di uno: mette a confronto le [lenses] gia' ottenute
  /// sul [theme] (le stesse tre strati per Maestro gia' vive, non le rifa'), col
  /// [natal] a personalizzare, e chiude con la regola dove gli sguardi concordano
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

/// Il modello si e' fermato perche' ha finito lo spazio, non perche' aveva
/// finito di dire: cio' che e' tornato e' un moncone.
///
/// **Il dato che ha fatto nascere questa eccezione.** Il 2 agosto 2026 la chat
/// consegnava "Il cielo in questo momento non", "Un velo", "Un velo argenteo
/// si", e li consegnava come RISPOSTE VERE: la persona pagava una domanda del
/// giorno per tre parole, e sotto le compariva pure l'invito ad andare piu' a
/// fondo. Il modello lo diceva, con `finishReason: MAX_TOKENS`, ma quel campo
/// non lo leggeva nessuno: la SDK non solleva niente in quel caso, e la
/// troncatura passava muta fino a video.
///
/// **Estende [MaestroAiUnavailable] apposta.** Chi non la distingue la tratta
/// come una voce che non ha risposto, cioe' ripiego dichiarato e nessun costo,
/// che e' gia' l'esito giusto. Chi vuole fare di meglio, cioe' la chat, la
/// prende per prima e riprova una volta prima di arrendersi.
class MaestroAiTroncata extends MaestroAiUnavailable {
  const MaestroAiTroncata([super.message = 'Il Maestro si è fermato a metà.']);

  @override
  String toString() => 'MaestroAiTroncata: $message';
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
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
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
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
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
