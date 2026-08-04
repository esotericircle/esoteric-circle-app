import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/ritentativi_della_voce.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN 429 TRANSITORIO DEVE ESSERE INVISIBILE.
///
/// **Il dato che ha fatto nascere questo file.** Cinque chiamate ravvicinate a
/// Vertex hanno reso `429 RESOURCE_EXHAUSTED`. Al primo 429 la persona vedeva
/// il ripiego: un rifiuto TEMPORANEO di Google diventava un messaggio d'errore
/// in faccia a chi paga, mentre bastava richiedere.
void main() {
  MaestroChatController chatCon(MaestroAiProvider ai,
          {QuestionAllowance? contatore}) =>
      MaestroChatController(
        maestro: Maestro.medora,
        memory: InMemoryMaestroMemoryRepository(),
        ai: ai,
        allowance: contatore,
        tier: contatore == null ? null : () => Tier.free,
        // Qui si misura il ritentativo, non la pausa della scena.
        attesaMinima: Duration.zero,
      );

  test('Un 429 una volta sola: la persona non vede niente', () async {
    final voce = VoceSorvegliata(
        voce: _VoceCheInciampa(quanteVolte: 1), registro: RegistroDeiGuasti());
    final chat = chatCon(voce);
    await chat.init();
    await chat.send('Devo cambiare lavoro?');

    final risposta = chat.messages.last;
    expect(risposta.ripiego, isFalse,
        reason: 'un 429 transitorio e\' diventato un ripiego a video: '
            '"${risposta.text}"');
    expect(risposta.failed, isFalse);
    expect(risposta.text, contains('Le stelle'));
    // E il registro non porta un guasto, perche' guasto non ce n'e' stato.
    expect(voce.registro.haGuasti, isFalse,
        reason: 'un inciampo superato non e\' un guasto');
    // Ma il conto si vede, perche' chi sviluppa deve saperlo.
    expect(voce.ritentativiRiusciti, 1,
        reason: 'il ritentativo riuscito non e\' stato contato: un successo '
            'che nasconde un tentativo resta invisibile anche a noi');
  });

  test('Un 429 sempre: si cade sul ripiego DICHIARATO', () async {
    final voce = VoceSorvegliata(
        voce: _VoceCheInciampa(quanteVolte: 99), registro: RegistroDeiGuasti());
    final contatore = QuestionAllowance();
    final chat = chatCon(voce, contatore: contatore);
    await chat.init();
    await chat.send('Devo cambiare lavoro?');

    final risposta = chat.messages.last;
    expect(risposta.ripiego, isTrue,
        reason: 'un muro va dichiarato, non nascosto dietro altri tentativi');
    expect(risposta.failed, isTrue);
    // E NON consuma la domanda del giorno. La regola vive gia' in
    // `CostoDelTurno` sull'enum chiuso, e qui si verifica che il ritentativo
    // non le sia passato accanto.
    expect(contatore.usedToday(), 0,
        reason: 'un ripiego dopo tre tentativi si e\' preso la domanda del '
            'giorno: si paga per una risposta, mai per un errore');
    // Il registro dice che ci si e' provato, altrimenti si andrebbe a cercare
    // la causa dalla parte sbagliata.
    expect(voce.registro.ultimo!.operazione, contains('ritentativi'),
        reason: 'il registro non dice che si e\' ritentato');
    expect(voce.ritentativiFalliti,
        RitentativiDellaVoce.tentativi - 1);
  });

  test('Un errore NON temporaneo non si ritenta nemmeno una volta', () async {
    // Una chiave sbagliata non cambia riprovando: ritentare vorrebbe dire far
    // aspettare la persona tre volte per lo stesso no.
    final voce = VoceSorvegliata(
        voce: _VoceRotta(), registro: RegistroDeiGuasti());
    final chat = chatCon(voce);
    await chat.init();
    await chat.send('Devo cambiare lavoro?');

    expect(chat.messages.last.ripiego, isTrue);
    expect(voce.ritentativiFalliti, 0,
        reason: 'si e\' ritentato su un errore che non passa col tempo');
    expect(voce.registro.ultimo!.operazione, isNot(contains('ritentativi')));
  });

  test('I segnali temporanei sono un dato, non un if', () {
    // I SEGNALI CHE ABBIAMO VISTO DAVVERO, e questi non possono uscire.
    //
    // **Questa parte nasce da una prova del rosso rimasta VERDE.** La prova
    // scorreva l'elenco e verificava che ogni voce venisse riconosciuta:
    // togliendo `RESOURCE_EXHAUSTED` restava verde, perche' quello che non
    // c'e' non si controlla. Si poteva svuotare l'elenco intero senza che
    // nessuno se ne accorgesse. Il 429 e' il segnale che ha fatto nascere
    // questo file, misurato su Vertex, e va nominato.
    for (final visto in const ['RESOURCE_EXHAUSTED', '429']) {
      expect(RitentativiDellaVoce.segnaliTemporanei, contains(visto),
          reason: 'il segnale misurato $visto non e\' piu\' nell\'elenco');
    }
    // ENUMERATI: chi ne aggiunge uno domani aggiunge una riga a un elenco.
    for (final segnale in RitentativiDellaVoce.segnaliTemporanei) {
      expect(RitentativiDellaVoce.eTemporaneo(StateError('errore $segnale')),
          isTrue,
          reason: '$segnale e\' nell\'elenco ma non viene riconosciuto');
    }
    expect(RitentativiDellaVoce.eTemporaneo(StateError('chiave non valida')),
        isFalse);
  });

  test('Il tetto dei ritentativi non e\' un numero nuovo', () {
    // E' la durata minima della scena: finche' i ritentativi finiscono dentro
    // la pausa che ci sarebbe comunque, la persona non vede niente. Un secondo
    // numero scritto a mano avrebbe dovuto restare d'accordo con quello, e
    // prima o poi non lo sarebbe restato.
    expect(RitentativiDellaVoce.tetto,
        greaterThan(RitentativiDellaVoce.attese.reduce((a, b) => a + b)),
        reason: 'le attese dichiarate non ci stanno nemmeno nel loro tetto');
  });
}

/// Inciampa [quanteVolte] con un 429, poi risponde.
class _VoceCheInciampa implements MaestroAiProvider {
  _VoceCheInciampa({required this.quanteVolte});
  int quanteVolte;

  @override
  bool get isReady => true;

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
    if (quanteVolte > 0) {
      quanteVolte--;
      throw StateError(
          'Resource exhausted. RESOURCE_EXHAUSTED, please try again later.');
    }
    return 'Le stelle dicono che il tempo di muoversi si apre fra due lune. '
        'Guarda dove ti chiama, non dove ti spinge.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Rotta per una ragione che il tempo non aggiusta.
class _VoceRotta extends _VoceCheInciampa {
  _VoceRotta() : super(quanteVolte: 0);

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
  }) async =>
      throw StateError('API key not valid');
}
