import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:async';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/raccolta_delle_risposte.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/esito_del_turno.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA DOMANDA NON RESTA MAI SENZA IL SUO TURNO DI RISPOSTA.
///
/// **Il dato che ha fatto nascere questo file.** Negli screenshot del fondatore
/// del 2 agosto 2026, riaprendo la chat si leggevano SETTE domande di fila e
/// nessuna risposta, come se avesse parlato al muro.
///
/// **L'ipotesi, verificata prima di correggere.** Il turno dell'utente veniva
/// salvato subito, quello del Maestro solo quando la risposta era VERA: dei
/// quattro punti in cui un turno si consegna, uno solo passava dalla
/// persistenza. Ripiego, troncatura ed errore restavano nella sessione e
/// sparivano alla chiusura dell'app. Le prove qui sotto lo verificano su ogni
/// esito, non su uno campione.
void main() {
  /// Riapre la chat sulla stessa memoria: e' il gesto che il fondatore ha
  /// fatto, cioe' chiudere l'app e tornare.
  MaestroChatController riapri(InMemoryMaestroMemoryRepository memoria,
          MaestroAiProvider ai) =>
      MaestroChatController(
        maestro: Maestro.medora,
        memory: memoria,
        ai: ai,
      );

  /// Gli esiti che una domanda puo' avere, ENUMERATI dall'enum chiuso invece
  /// che scelti a mano: chi ne aggiunge uno domani viene qui a dire come si
  /// persiste, e non se ne dimentica.
  final provider = <EsitoDelTurno, MaestroAiProvider>{
    EsitoDelTurno.rispostaVera: _VoceCheRisponde(),
    EsitoDelTurno.ripiego: _VoceNonConfigurata(),
    EsitoDelTurno.erroreGenerico: _VoceCheCade(),
    EsitoDelTurno.rispostaTroncata: _VoceCheTronca(),
  };

  for (final caso in provider.entries) {
    test('Dopo chiusura e riapertura, la domanda ha il suo turno: ${caso.key}',
        () async {
      final memoria = InMemoryMaestroMemoryRepository();
      final prima = riapri(memoria, caso.value);
      await prima.init();
      await prima.send('Devo cambiare lavoro?');

      // La sessione ce l'ha: questo gia' funzionava.
      expect(prima.messages.length, 2,
          reason: 'nella sessione mancano gia' ' i due turni');
      expect(prima.messages.last.isMaestro, isTrue);

      // E dopo aver chiuso l'app?
      final dopo = riapri(memoria, caso.value);
      await dopo.init();

      expect(dopo.messages.length, 2,
          reason: 'riaprendo la chat la domanda e\' rimasta senza il suo '
              'turno di risposta: ${dopo.messages.map((m) => m.role).toList()}');
      expect(dopo.messages.first.isUser, isTrue);
      expect(dopo.messages.last.isMaestro, isTrue);
      expect(dopo.messages.last.text.trim(), isNotEmpty,
          reason: 'il turno del Maestro e\' tornato vuoto');
      // E PORTA QUELLO CHE ERA STATO CONSEGNATO, per ogni esito.
      //
      // Non basta che un turno ci sia. Se la consegna non completa il turno
      // salvato, quello resta in attesa e riaprendo diventa "interrotto":
      // c'e' un turno, ha i contrassegni giusti, e racconta un guasto che non
      // e' quello successo. Solo il confronto del TESTO distingue i due casi,
      // ed e' il motivo per cui questa riga sta dentro il ciclo che enumera
      // gli esiti invece che in una prova sola.
      expect(dopo.messages.last.text, prima.messages.last.text,
          reason: 'riaprendo, il turno racconta un guasto diverso da quello '
              'consegnato: "${dopo.messages.last.text}"');
    });
  }

  test('Il turno fallito torna con il suo Riprova', () async {
    final memoria = InMemoryMaestroMemoryRepository();
    final prima = riapri(memoria, _VoceCheCade());
    await prima.init();
    await prima.send('Devo cambiare lavoro?');
    expect(prima.messages.last.failed, isTrue);

    final dopo = riapri(memoria, _VoceCheCade());
    await dopo.init();
    // Il Riprova sta attaccato a una bolla FALLITA: se il flag non sopravvive,
    // la persona riapre e trova una risposta che sembra riuscita.
    expect(dopo.messages.last.failed, isTrue,
        reason: 'riaprendo, il turno fallito non si dichiara piu\' fallito e '
            'il Riprova sparisce');
    expect(dopo.messages.last.ripiego, isTrue,
        reason: 'riaprendo, il ripiego passa per la voce del Maestro');

    // IL TESTO CONSEGNATO, non un altro ripiego che gli somiglia.
    //
    // Questa riga nasce da una prova del rosso rimasta VERDE. Togliendo il
    // completamento del turno, la domanda AVEVA ancora il suo turno, perche'
    // quello in attesa era gia' salvato, e riaprendo diventava un turno
    // "interrotto": stessi contrassegni, `failed` e `ripiego`, testo diverso.
    // La chat avrebbe detto "ci siamo persi per strada" mentre il Maestro
    // aveva davvero consegnato la sua lettura di ripiego. Due guasti diversi
    // non possono raccontare la stessa cosa.
    expect(dopo.messages.last.text, prima.messages.last.text,
        reason: 'riaprendo, il turno non porta quello che era stato '
            'consegnato: dice "${dopo.messages.last.text}" invece di '
            '"${prima.messages.last.text}"');
  });

  test('L\'app muore con la risposta in volo: il turno torna interrotto',
      () async {
    // LA MORTE DELL'APP, simulata dove succede davvero: la domanda e' salvata,
    // il turno del Maestro e' in attesa, e il processo non arriva mai alla
    // riga che lo consegna.
    final memoria = InMemoryMaestroMemoryRepository();
    final morente = riapri(memoria, _VoceCheNonTornaMai());
    await morente.init();
    // Non si aspetta: la chiamata resta appesa, come quando il sistema chiude
    // l'app mentre la rete e' aperta.
    unawaited(morente.send('Devo cambiare lavoro?'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(morente.messages.last.pending, isTrue,
        reason: 'la prova non sta simulando una risposta in volo');

    final dopo = riapri(memoria, _VoceCheRisponde());
    await dopo.init();

    expect(dopo.messages.length, 2,
        reason: 'la domanda e\' tornata senza il suo turno');
    final turno = dopo.messages.last;
    expect(turno.isMaestro, isTrue);
    expect(turno.pending, isFalse,
        reason: 'il turno e\' tornato IN ATTESA: aspetterebbe per sempre una '
            'risposta che nessuno sta piu\' generando');
    expect(turno.failed, isTrue,
        reason: 'un turno interrotto va dichiarato interrotto, col suo '
            'Riprova: e\' un turno che non ha una risposta');
    expect(turno.text.trim(), isNotEmpty,
        reason: 'un turno interrotto muto non dice niente a nessuno');
  });

  test('Il raccoglimento regge quando il turno e un fallimento', () async {
    // SI SPOSA CON CIO' CHE C'ERA GIA'.
    //
    // Il raccoglimento tiene aperta solo la risposta VIVA, cioe' l'ultima
    // LETTURA VERA e non l'ultima bolla: un ripiego e' due righe, e farlo
    // passare per l'ultima risposta richiuderebbe la lettura vera che sta
    // sopra, cioe' toglierebbe di mano proprio cio' che vale. Adesso che i
    // turni falliti SOPRAVVIVONO alla riapertura, quel caso non e' piu' raro:
    // capita ogni volta che si riapre dopo un guasto.
    final memoria = InMemoryMaestroMemoryRepository();
    final buona = riapri(memoria, _VoceCheRisponde());
    await buona.init();
    await buona.send('La prima domanda');

    final rotta = riapri(memoria, _VoceCheCade());
    await rotta.init();
    await rotta.send('La seconda domanda');

    final dopo = riapri(memoria, _VoceCheRisponde());
    await dopo.init();
    expect(dopo.messages.length, 4,
        reason: 'due domande devono tornare con due turni');

    // La risposta VIVA resta la lettura vera in posizione 1, non il ripiego
    // in posizione 3: un ripiego non e' una risposta da tenere aperta.
    expect(RaccoltaDelleRisposte.indiceDellaViva(dopo.messages), 1,
        reason: 'il ripiego arrivato dopo ha preso il posto della lettura '
            'vera, che quindi si richiuderebbe sotto gli occhi di chi legge');
    expect(
        RaccoltaDelleRisposte.eAperta(dopo.messages, 1, riaperte: const {}),
        isTrue,
        reason: 'la lettura vera si richiude da sola');
  });

  test('Lo scorrimento trova la sua risposta anche se e un fallimento',
      () async {
    // Lo scorrimento si ferma all'INIZIO della risposta viva. Se il turno
    // fallito non esistesse in cronologia, riaprendo la chat l'ultima cosa
    // sarebbe una domanda, e non c'e' nessuna risposta a cui portarsi.
    final memoria = InMemoryMaestroMemoryRepository();
    final rotta = riapri(memoria, _VoceCheCade());
    await rotta.init();
    await rotta.send('Una domanda che fallisce');

    final dopo = riapri(memoria, _VoceCheRisponde());
    await dopo.init();
    expect(dopo.messages.last.isMaestro, isTrue,
        reason: 'l\'ultima cosa in cronologia e\' una domanda senza turno: '
            'lo scorrimento non ha nessuna risposta a cui fermarsi');
  });
}

/// Non torna mai: e' l'app che muore mentre la risposta e' in volo.
class _VoceCheNonTornaMai implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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
  }) => Completer<String>().future;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) => Completer<MaestroReply>().future;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) => Completer<String>().future;

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async => null;
}

/// Quattro voci, una per esito. Le firme sono lunghe apposta: implementare
/// l'interfaccia vera invece di un finto stretto significa che se domani il
/// provider cambia forma, queste prove lo dicono.
abstract class _VoceDiProva implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  bool get isReady => true;

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

class _VoceCheRisponde extends _VoceDiProva {
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
      'Le stelle dicono che il tempo di muoversi si apre fra due lune. '
      'Guarda dove ti chiama, non dove ti spinge.';
}

class _VoceNonConfigurata extends _VoceDiProva {
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
  }) async =>
      throw const MaestroAiUnavailable('non configurata');
}

class _VoceCheCade extends _VoceDiProva {
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
      throw StateError('la rete non risponde');
}

class _VoceCheTronca extends _VoceDiProva {
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
      throw const MaestroAiTroncata('un velo');
}