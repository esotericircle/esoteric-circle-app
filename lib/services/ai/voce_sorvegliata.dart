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
import 'ritentativi_della_voce.dart';

/// La voce dei Maestri, sorvegliata, che RITENTA prima di arrendersi.
///
/// Avvolge un qualunque [MaestroAiProvider], ritenta quando il guasto e'
/// temporaneo, registra quello che resta e lo rilancia, poi lascia che chi
/// chiama decida il ripiego come ha sempre fatto.
///
/// Perche' un involucro e non un campo nei controllori: alla voce dell'AI si
/// arriva da piu' porte, la chat, il Consulta, la Sintesi comparativa e il
/// distillato di memoria, e ogni porta aveva il suo `catch (_)`. Correggere i
/// chiamanti uno per uno avrebbe lasciato scoperta la porta che nasce domani.
/// Qui la porta e' una sola, e chi ne apre un'altra ci passa senza saperlo.
///
/// **Il ritentativo e' arrivato qui per la stessa ragione.** Cinque chiamate
/// ravvicinate a Vertex hanno reso `429 RESOURCE_EXHAUSTED`, e al primo 429 la
/// persona vedeva il ripiego: un rifiuto temporaneo di Google diventava un
/// messaggio d'errore in faccia a chi paga. La politica, quante volte e per
/// quanto, vive in [RitentativiDellaVoce] e non in questo file: qui c'e' solo
/// il posto dove viene applicata.
///
/// **Un successo che nasconde tre tentativi va detto a chi sviluppa.** Il
/// conteggio finisce nel pannello di messa a punto, cosi' un problema di quota
/// resta invisibile alla persona ma non a noi.
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
    final orologio = Stopwatch()..start();
    for (var tentativo = 1;; tentativo++) {
      try {
        final esito = await azione();
        if (tentativo > 1) {
          // Il tentativo riuscito dopo un inciampo NON e' un guasto, ed e'
          // per questo che si conta invece di registrarsi come errore: chi
          // legge il registro deve poter distinguere cio' che e' andato male
          // da cio' che e' andato bene alla seconda.
          ritentativiRiusciti += tentativo - 1;
        }
        return esito;
      } catch (errore) {
        final ultimoPossibile = tentativo >= RitentativiDellaVoce.tentativi;
        final attesa = RitentativiDellaVoce.attesaPrima(tentativo);
        final sforerebbe = orologio.elapsed + attesa >
            RitentativiDellaVoce.tetto;
        if (!RitentativiDellaVoce.eTemporaneo(errore) ||
            ultimoPossibile ||
            sforerebbe) {
          // NIENTE SI PERDE IN SILENZIO. Il guasto che chiude la strada si
          // registra come ha sempre fatto, e se prima c'erano stati
          // ritentativi il registro lo dice: un ripiego che tace resta
          // vietato, e un ripiego che tace di averci provato tre volte
          // manderebbe a cercare la causa dalla parte sbagliata.
          ritentativiFalliti += tentativo - 1;
          registro.registra(
            operazione: tentativo > 1
                ? '$operazione, dopo ${tentativo - 1} ritentativi'
                : operazione,
            errore: errore,
          );
          rethrow;
        }
        await Future<void>.delayed(attesa);
      }
    }
  }

  /// Quante volte una chiamata e' riuscita DOPO un inciampo temporaneo.
  ///
  /// Sta a video nel pannello di messa a punto: la persona non vede niente,
  /// ed e' cio' che vogliamo, ma noi dobbiamo vedere che la quota sta
  /// stringendo prima che stringa del tutto.
  int ritentativiRiusciti = 0;

  /// Quante volte si e' ritentato senza riuscirci, cioe' i tentativi buttati
  /// prima di cadere sul ripiego.
  int ritentativiFalliti = 0;

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
  }) {
    return _sorvegliando(
      'reply',
      () => _voce.reply(
        maestro: maestro,
        profile: profile,
        memory: memory,
        history: history,
        userMessage: userMessage,
        natal: natal,
        insistiSullAncoraggio: insistiSullAncoraggio,
        rispostaGiaData: rispostaGiaData,
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
