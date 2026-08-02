import 'dart:io';

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

/// Un ripiego non costa la domanda del giorno.
///
/// **Il dato che ha fatto nascere questa prova.** Il 2 agosto 2026, sul
/// telefono di Mauro: alle 13:23 la domanda a Medora riceve un ripiego, cioe'
/// nessuna risposta. Alle 13:24 e alle 13:25 Caligo e Aura dicono che per oggi
/// ha finito. L'unica domanda del giorno se l'era presa un messaggio d'errore.
void main() {
  /// TUTTI gli esiti possibili di un turno, e per ognuno se costa.
  ///
  /// Enumerati e non campionati: una prova su un caso solo avrebbe lasciato
  /// fuori esattamente quello che e' successo quel giorno.
  const attesi = <EsitoDelTurno, bool>{
    EsitoDelTurno.rispostaVera: true,
    EsitoDelTurno.ripiego: false,
    // Il 2 agosto 2026 "Un velo" si prendeva una delle tre domande del giorno.
    EsitoDelTurno.rispostaTroncata: false,
    EsitoDelTurno.erroreDiAttestazione: false,
    EsitoDelTurno.erroreGenerico: false,
    EsitoDelTurno.limiteRaggiunto: false,
    EsitoDelTurno.instradamento: false,
  };

  test('Ogni esito possibile dice se costa, e uno solo costa', () {
    // Se qualcuno aggiunge un esito e non lo dichiara qui, questa cade.
    expect(attesi.keys.toSet(), EsitoDelTurno.values.toSet(),
        reason: 'un esito non dichiarato e\' un esito il cui costo nessuno ha '
            'deciso');
    for (final voce in attesi.entries) {
      expect(CostoDelTurno.consuma(voce.key), voce.value,
          reason: '${voce.key.name} dovrebbe '
              '${voce.value ? "costare" : "NON costare"} una domanda');
    }
    expect(
      EsitoDelTurno.values.where(CostoDelTurno.consuma).length,
      1,
      reason: 'si paga una domanda per una risposta, mai per un errore',
    );
  });

  group('La chat, sui turni veri', () {
    Future<({MaestroChatController chat, QuestionAllowance conto})> conVoce(
      _Voce voce, {
      Tier piano = Tier.free,
    }) async {
      final memoria = InMemoryMaestroMemoryRepository();
      await memoria.saveProfile(
          UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final conto = QuestionAllowance();
      final chat = MaestroChatController(
        maestro: Maestro.medora,
        ai: voce,
        memory: memoria,
        allowance: conto,
        tier: () => piano,
        natal: () => const NatalContext(sunSign: 'Cancro'),
      );
      await chat.init();
      return (chat: chat, conto: conto);
    }

    test('Una risposta vera costa una domanda', () async {
      final t = await conVoce(_Voce(['Il tuo Sole in Cancro chiede riparo.']));
      final prima = t.conto.remaining(Tier.free);
      await t.chat.send('cosa mi manca');
      expect(t.conto.remaining(Tier.free), prima - 1);
    });

    test('UN RIPIEGO NON COSTA NIENTE', () async {
      final t = await conVoce(_Voce([], guasto: 'la voce tace'));
      final prima = t.conto.remaining(Tier.free);
      await t.chat.send('cosa mi manca');
      expect(t.chat.messages.last.ripiego, isTrue,
          reason: 'il turno deve essere davvero finito in ripiego');
      expect(t.conto.remaining(Tier.free), prima,
          reason: 'il 2 agosto un messaggio d\'errore si e\' preso l\'unica '
              'domanda del giorno');
    });

    test('L\'attestazione fallita non costa niente', () async {
      final t = await conVoce(
          _Voce([], guasto: 'code: 403 body: App attestation failed.'));
      final prima = t.conto.remaining(Tier.free);
      await t.chat.send('cosa mi manca');
      expect(t.conto.remaining(Tier.free), prima);
    });

    test('Dopo un ripiego si puo\' chiedere ancora, subito', () async {
      // E' la frase di accettazione, provata.
      final voce = _Voce([], guasto: 'la voce tace');
      final t = await conVoce(voce);
      for (var i = 0; i < 4; i++) {
        await t.chat.send('cosa mi manca $i');
      }
      expect(t.conto.remaining(Tier.free), greaterThan(0),
          reason: 'quattro guasti non possono chiudere la giornata');
    });

    test('L\'instradamento a una funzione immersiva non costa', () async {
      final t = await conVoce(_Voce(['non mi chiameranno']));
      final prima = t.conto.remaining(Tier.free);
      // "tarocchi" instrada alla Stesa, senza passare dall'AI.
      await t.chat.send('vorrei una stesa di tarocchi');
      expect(t.conto.remaining(Tier.free), prima,
          reason: 'il costo vive dentro la funzione immersiva');
    });

    test('Il rifiuto per limite raggiunto non costa un\'altra domanda',
        () async {
      final t = await conVoce(_Voce(['Il tuo Sole in Cancro chiede riparo.']));
      // Si esaurisce il gratuito.
      while (t.conto.remaining(Tier.free) > 0) {
        await t.chat.send('ancora');
      }
      final consumateDopo = t.conto.usedToday();
      await t.chat.send('e adesso');
      expect(t.conto.usedToday(), consumateDopo,
          reason: 'un rifiuto non e\' una domanda');
    });

    test('Un Riprova riuscito costa UNA volta, non due', () async {
      // Prima fallisce, poi riesce: la persona paga una domanda per una
      // risposta, non una per il guasto piu' una per la risposta.
      final voce = _Voce(['La tua Luna in Cancro tiene l\'acqua.'],
          guastoAlPrimoTurno: true);
      final t = await conVoce(voce);
      final prima = t.conto.remaining(Tier.free);
      await t.chat.send('cosa mi manca');
      expect(t.conto.remaining(Tier.free), prima,
          reason: 'il turno fallito non paga');
      await t.chat.retryLast();
      expect(t.conto.remaining(Tier.free), prima - 1,
          reason: 'il Riprova riuscito paga una volta sola');
    });
  });

  test('Nessuna superficie conta di testa sua', () {
    // La regola vive nel dato: chi chiama `record` deve prima chiedere a
    // CostoDelTurno. Si enumerano i chiamanti nel sorgente, cosi' la terza
    // superficie che nascera' domani non potra' sbagliarlo in silenzio.
    final colpe = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = file.path.replaceAll(r'\', '/');
      if (percorso.endsWith('core/entitlement/question_allowance.dart')) {
        continue;
      }
      final sorgente = file.readAsStringSync();
      final chiamate = RegExp(r'\.record\(').allMatches(sorgente);
      if (chiamate.isEmpty) continue;
      if (!sorgente.contains('CostoDelTurno.consuma')) {
        colpe.add('$percorso chiama record senza chiedere a CostoDelTurno: '
            'decide da solo se una domanda si paga');
      }
    }
    expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
  });
}

/// Una voce che risponde, oppure fallisce, a comando.
class _Voce implements MaestroAiProvider {
  _Voce(this._risposte, {this.guasto, this.guastoAlPrimoTurno = false});

  final List<String> _risposte;
  final String? guasto;
  final bool guastoAlPrimoTurno;
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
    final indice = chiamate;
    chiamate++;
    if (guasto != null) throw Exception(guasto);
    if (guastoAlPrimoTurno && indice == 0) throw Exception('la voce tace');
    return _risposte[
        (indice - (guastoAlPrimoTurno ? 1 : 0)).clamp(0, _risposte.length - 1)];
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
