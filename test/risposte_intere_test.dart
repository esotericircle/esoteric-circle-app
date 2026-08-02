import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/esito_del_turno.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le risposte non sono piu' tronche a meta' frase.
///
/// **Il dato che ha fatto nascere questo file.** Il 2 agosto 2026, sul telefono
/// del fondatore, Medora rispondeva "Il cielo in questo momento non", "Un
/// velo", "Un velo argenteo si". Erano consegnate come RISPOSTE VERE: si
/// prendevano una delle tre domande del giorno, e sotto compariva pure "Vai
/// piu' a fondo". Un terzo della giornata bruciato per due parole.
///
/// La causa, misurata sulla strada viva prima di toccare una riga:
/// `finishReason: MAX_TOKENS`, `thoughtsTokenCount: 150` su un tetto di 160,
/// `candidatesTokenCount: 6`. Il ragionamento interno del modello si mangiava
/// il budget prima che il modello scrivesse.
void main() {
  const natalCancro = NatalContext(sunSign: 'Cancro');

  Future<MaestroChatController> conVoce(
    _VoceCheTronca voce, {
    QuestionAllowance? contatore,
  }) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: voce,
      memory: memoria,
      allowance: contatore ?? QuestionAllowance(),
      tier: () => Tier.free,
      natal: () => natalCancro,
    );
    await controller.init();
    return controller;
  }

  group('Una risposta tronca non e\' una risposta consegnata', () {
    test('Non costa la domanda del giorno', () {
      expect(CostoDelTurno.consuma(EsitoDelTurno.rispostaTroncata), isFalse);
    });

    test('Costa SOLO la risposta vera, e l\'elenco e\' chiuso', () {
      // Enumerata, non campionata: l'enum e' chiuso apposta perche' chi ne
      // aggiunge uno sia costretto dal compilatore a dire se costa.
      for (final esito in EsitoDelTurno.values) {
        expect(
          CostoDelTurno.consuma(esito),
          esito == EsitoDelTurno.rispostaVera,
          reason: 'l\'esito ${esito.name} costa quando non dovrebbe, '
              'oppure non costa quando dovrebbe',
        );
      }
    });
  });

  group('La chat riprova una volta sola, poi dichiara', () {
    test('Tronca la prima, riesce la seconda: e\' una risposta vera e costa',
        () async {
      final voce = _VoceCheTronca(troncaLePrime: 1, testo: 'La tua Luna in '
          'Cancro apre il ciclo, e il ciclo si chiude quando lo guardi.');
      final contatore = QuestionAllowance();
      final controller = await conVoce(voce, contatore: contatore);

      await controller.send('mi sento fermo');

      expect(voce.chiamate, 2, reason: 'una rigenerazione, non zero e non due');
      expect(controller.rigenerazioniPerTroncatura, 1);
      expect(controller.troncatureConsegnate, 0);
      final ultima = controller.messages.last;
      expect(ultima.ripiego, isFalse);
      expect(ultima.tipoEffettivo, TipoDiMessaggio.responso);
      expect(ultima.text, contains('Cancro'));
      expect(contatore.usedToday(), 1,
          reason: 'il Maestro ha risposto davvero, quindi si paga');
    });

    test('Tronca due volte: ripiego dichiarato, e NON costa niente', () async {
      final voce = _VoceCheTronca(troncaLePrime: 2, testo: 'Un velo');
      final contatore = QuestionAllowance();
      final controller = await conVoce(voce, contatore: contatore);

      await controller.send('mi sento fermo');

      expect(voce.chiamate, 2,
          reason: 'mai una terza: far aspettare la persona per un difetto '
              'nostro sarebbe farglielo pagare in tempo');
      expect(controller.rigenerazioniPerTroncatura, 1);
      expect(controller.troncatureConsegnate, 1);

      final ultima = controller.messages.last;
      expect(ultima.ripiego, isTrue, reason: 'dichiarato, non spacciato');
      expect(ultima.text, isNot('Un velo'),
          reason: 'il moncone non arriva a video: al suo posto una lettura '
              'vera costruita dai dati sul dispositivo');
      expect(ultima.text.length, greaterThan(40));
      expect(contatore.usedToday(), 0,
          reason: 'si paga una domanda per una risposta, e "Un velo" non lo è');
    });

    test('Sotto una risposta tronca non compare "Vai piu\' a fondo"', () async {
      // E' la regola 2b, e vive nel DATO del messaggio: `portaUnResponso`
      // guarda il tipo, non una condizione scritta dentro una schermata.
      final voce = _VoceCheTronca(troncaLePrime: 2, testo: 'Un velo argenteo si');
      final controller = await conVoce(voce);

      await controller.send('mi sento fermo');

      final ultima = controller.messages.last;
      expect(ultima.tipoEffettivo, TipoDiMessaggio.ripiego);
      expect(ultima.portaUnResponso, isFalse);
      expect(controller.puoiChiedereDiApprofondire, isFalse);
    });

    test('Una risposta intera porta l\'invito, cosi\' la prova non e\' cieca',
        () async {
      // Il controllo negativo: senza questo, una prova che dice sempre "niente
      // invito" resterebbe verde anche se l'invito sparisse per tutti.
      final voce = _VoceCheTronca(troncaLePrime: 0, testo: 'La tua Luna in '
          'Cancro apre il ciclo, e il ciclo si chiude quando lo guardi.');
      final controller = await conVoce(voce);

      await controller.send('mi sento fermo');

      expect(controller.messages.last.portaUnResponso, isTrue);
      expect(controller.puoiChiedereDiApprofondire, isTrue);
    });
  });
}

/// Una voce che si ferma a meta' frase le prime [troncaLePrime] volte.
///
/// Solleva cio' che solleva il provider vero quando il modello risponde
/// `finishReason: MAX_TOKENS`, cioe' [MaestroAiTroncata].
class _VoceCheTronca implements MaestroAiProvider {
  _VoceCheTronca({required this.troncaLePrime, required this.testo});

  final int troncaLePrime;
  final String testo;
  int chiamate = 0;

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
    bool approfondisci = false,
  }) async {
    chiamate++;
    if (chiamate <= troncaLePrime) throw const MaestroAiTroncata();
    return testo;
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
      throw const MaestroAiUnavailable();

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
    required List<ChatMessage> history,
  }) async =>
      null;
}
