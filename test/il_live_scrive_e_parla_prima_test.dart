import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/features/maestri/live/il_parlato_del_maestro.dart';
import 'package:esoteric_circle/features/maestri/live/la_domanda_finita.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LIVE SCRIVE E PARLA PRIMA.** Ordine EO voce 14, 26 settembre 2026.
///
/// Il fondatore: *"nelle chat live bisogna ridurre il tempo in cui la
/// risposta viene scritta e il tempo di risposta del maestro, il più
/// possibile."* Sul Realme, prima di quest'ordine, il testo compariva a 4,1
/// secondi dalla fine della domanda e il volto parlava a 6,3 (mediane su nove
/// domande ai tre Maestri, `docs/collaudo/EO/`). Quattro cose, una prova per
/// ciascuna:
///
/// - una domanda gia' finita parte dopo 1,3 secondi di silenzio invece di 2;
/// - il testo si mostra mentre il modello lo scrive;
/// - nel LIVE risponde Flash-Lite, nella chat scritta resta Flash;
/// - il primo pezzo di voce e' la sola prima frase.
///
/// **La voce non parte mentre la chat scrive**: resta la regola che il
/// fondatore ha scelto con l'ordine EM, e l'ultima prova la sorveglia.
void main() {
  group('una domanda finita non aspetta due secondi', () {
    test('si riconosce dal punto interrogativo e da almeno tre parole', () {
      for (final finita in [
        'Medora, come sarà la mia settimana in amore?',
        'Aura, la sera non riesco a rilassarmi. Cosa faccio?',
        'Calìgo, quale runa mi accompagna questa settimana?',
      ]) {
        expect(LaDomandaFinita.eFinita(finita), isTrue, reason: finita);
      }
      for (final aperta in [
        // Trascritta col punto: resta sui due secondi.
        'Medora, questo mese conviene cambiare casa.',
        // Una pausa a meta' domanda.
        'Aura, quando parlo con mio padre',
        // Troppo corta per essere una domanda finita.
        'Medora, come?',
        '[SILENZIO]',
        '',
      ]) {
        expect(LaDomandaFinita.eFinita(aperta), isFalse, reason: aperta);
      }
    });

    test('aspetta fino a 1,3 secondi di silenzio, mai meno', () {
      expect(LaDomandaFinita.silenzioMinimo.inMilliseconds, 1300);
      expect(LaDomandaFinita.daAspettare(const Duration(milliseconds: 900)),
          const Duration(milliseconds: 400));
      expect(LaDomandaFinita.daAspettare(const Duration(seconds: 2)),
          Duration.zero);
    });

    test('la schermata chiude la frase finita nella stessa pausa', () {
      final schermata = File('lib/features/maestri/live/schermata_live.dart')
          .readAsStringSync();
      final orecchio =
          File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
      expect(schermata, contains('_chiudiSeEFinita(t, frase, pausa)'),
          reason: 'la trascrizione in pausa non chiede la chiusura');
      expect(schermata, contains('_orecchio.chiudiInPausa(frase, pausa)'));
      expect(orecchio, contains('_silenzio.pause != pausa'),
          reason: 'una voce arrivata nel frattempo non protegge piu\' la '
              'domanda dal troncarsi');
    });
  });

  group('il testo del LIVE arriva mentre il modello scrive', () {
    test('nel LIVE il controller mostra il testo a pezzi, nella chat no',
        () async {
      for (final live in [true, false]) {
        final ai = _AiAFlusso();
        final c = MaestroChatController(
          maestro: Maestro.medora,
          ai: ai,
          memory: InMemoryMaestroMemoryRepository(),
          natal: () => NatalContext.none,
          demo: true,
          attesaMinima: Duration.zero,
        )..nelLive = live;
        await c.init();
        final visti = <String>[];
        c.testoInArrivo.addListener(() => visti.add(c.testoInArrivo.value));
        await c.send('Medora, come sarà la mia settimana in amore?');
        if (live) {
          expect(visti, isNotEmpty,
              reason: 'nel LIVE il testo non arriva mentre si scrive');
          expect(visti.first, 'Questa settimana',
              reason: 'il segno del chiarimento arriva a video');
          expect(visti.last, contains('parla con calma'));
        } else {
          expect(ai.chiestoAFlusso, isFalse,
              reason: 'la chat scritta chiede la risposta a flusso');
          expect(visti, isEmpty);
        }
      }
    });

    test('il provider vero chiede a flusso solo quando qualcuno aspetta', () {
      final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
          .readAsStringSync();
      expect(provider, contains('chat.sendMessageStream('));
      expect(provider, contains('final suTesto = turno.suTesto;'));
      final schermata = File('lib/features/maestri/live/schermata_live.dart')
          .readAsStringSync();
      expect(
          schermata, contains('chat.testoInArrivo.addListener(mentreArriva)'),
          reason: 'la schermata del LIVE non mostra il testo che arriva');
    });
  });

  test('nel LIVE risponde Flash-Lite, nella chat scritta Flash', () {
    expect(FirebaseMaestroAiProvider.modelloDelTurno(nelLive: true),
        'gemini-2.5-flash-lite');
    expect(FirebaseMaestroAiProvider.modelloDelTurno(nelLive: false),
        FirebaseMaestroAiProvider.kMaestroChatModel);
    final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(
        provider,
        contains(
            'model: modelloDelTurno(nelLive: turno.nelLive, chatModel: chatModel)'),
        reason: 'il provider non usa il modello del turno');
  });

  group('la voce', () {
    const risposta = 'Questa settimana chiedi un segno. Venere ti sostiene '
        'nei giorni centrali. Il sabato e\' il giorno piu\' aperto.\n\n'
        '✦ Scrivi stasera due righe a chi ti manca.';

    test('nel LIVE il primo pezzo e\' la sola prima frase', () {
      final pezzi = IlParlatoDelMaestro.pezzi(risposta, primaFraseSola: true);
      expect(pezzi.first, 'Questa settimana chiedi un segno.');
      expect(pezzi.join(' '), IlParlatoDelMaestro.pezzi(risposta).join(' '),
          reason: 'la prima frase da sola ha perso parole');
      // Il saluto e le altre voci restano come prima.
      expect(IlParlatoDelMaestro.pezzi(risposta).first,
          isNot('Questa settimana chiedi un segno.'));
    });

    test('la voce parte solo dalla risposta intera', () {
      final schermata = File('lib/features/maestri/live/schermata_live.dart')
          .readAsStringSync();
      // La voce si chiede con il testo del messaggio consegnato, non con
      // quello che arriva a pezzi.
      expect(
          schermata, contains('await _dillo(risposta.text, conAttesa: true)'));
      expect(schermata, isNot(contains('_dillo(chat.testoInArrivo')));
    });
  });
}

/// Un modello finto che, quando qualcuno aspetta il testo, lo manda in tre
/// pezzi come il modello vero.
class _AiAFlusso implements MaestroAiProvider {
  bool chiestoAFlusso = false;

  static const _pezzi = [
    '[[CHIEDO]]\nQuesta settimana',
    ' Venere ti sostiene,',
    ' parla con calma e scegli il sabato.\n\n✦ Scrivi due righe stasera.',
  ];

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
    final suTesto = LaRichiestaDelTurno.corrente.suTesto;
    final scritto = StringBuffer();
    for (final p in _pezzi) {
      scritto.write(p);
      if (suTesto != null) {
        chiestoAFlusso = true;
        suTesto(scritto.toString());
      }
    }
    return _pezzi.join().replaceFirst('[[CHIEDO]]\n', '');
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
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
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
