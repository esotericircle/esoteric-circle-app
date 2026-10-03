import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_risposta_da_programma.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL TURNO DEL LIVE, LA RISPOSTA GIA' DATA E LA MEMORIA DEGLI ALTRI DUE.**
/// Ordine EN voci 01, 06 e 09, 25 settembre 2026.
///
/// - EN.01, *"bisogna ridurre questa pausa"*: nel LIVE il turno chiede la
///   misura della voce, il modello non aspetta il salvataggio del turno in
///   attesa, la voce non aspetta quello della risposta, e l'ancoraggio non
///   fa una seconda chiamata.
/// - EN.06, Medora che restituisce la stessa risposta parola per parola: una
///   risposta che ricalca una gia' data si chiede di nuovo, nominandola; e
///   cosi' una risposta che parla da programma.
/// - EN.09, *"siamo sicuri che i maestri sia live che non, accedano alle
///   memorie dell'utente"*: cio' che la persona ha detto a un Maestro arriva
///   agli altri due, per chi ha la memoria nel suo piano.
void main() {
  group('EN.01, il turno del LIVE', () {
    test('il LIVE chiede la misura della voce, la chat quella di sempre',
        () async {
      for (final live in [true, false]) {
        final ai = _AiFinta();
        final c = _controller(ai, _MagazzinoLento(Duration.zero))
          ..nelLive = live;
        await c.init();
        await c.send('Cosa mi dice il cielo di questa settimana?');
        expect(ai.nelLive.single, live,
            reason: 'il turno ${live ? 'del LIVE' : 'della chat'} non arriva '
                'al provider per quello che e\'');
      }
      final nelLive = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        nelLive: true,
      );
      expect(nelLive,
          contains('circa ${MisuraDellaRisposta.nelLive.inLettere} parole'));
      expect(MisuraDellaRisposta.nelLive.parole,
          lessThan(MisuraDellaRisposta.perChat.parole));
    });

    test('il modello non aspetta il salvataggio del turno in attesa', () async {
      final ai = _AiFinta();
      final magazzino = _MagazzinoLento(const Duration(milliseconds: 400));
      final c = _controller(ai, magazzino)..nelLive = true;
      await c.init();
      final orologio = Stopwatch()..start();
      ai.orologio = orologio;
      await c.send('Cosa mi dice il cielo di questa settimana?');
      expect(ai.chiamataA.single, lessThan(200),
          reason: 'il modello e\' partito a ${ai.chiamataA.single} ms: '
              'aspettava il salvataggio del turno in attesa');
      // **E la sostituzione non arriva prima del turno in attesa**: nella
      // cronologia l'ordine resta quello di prima.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(magazzino.eventi, ['in attesa salvato', 'sostituito'],
          reason: 'la sostituzione e\' arrivata prima del turno in attesa');
    });

    test('nel LIVE la voce non aspetta il salvataggio della risposta',
        () async {
      for (final live in [true, false]) {
        final ai = _AiFinta();
        final c =
            _controller(ai, _MagazzinoLento(const Duration(milliseconds: 400)))
              ..nelLive = live;
        await c.init();
        final orologio = Stopwatch()..start();
        await c.send('Cosa mi dice il cielo di questa settimana?');
        final ms = orologio.elapsedMilliseconds;
        if (live) {
          expect(ms, lessThan(600),
              reason: 'nel LIVE il turno e\' tornato a $ms ms: la voce '
                  'aspetta i due salvataggi');
        } else {
          expect(ms, greaterThanOrEqualTo(750),
              reason: 'nella chat il turno aspetta i due salvataggi, come '
                  'prima: e\' tornato a $ms ms');
        }
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }
    });

    test('nel LIVE l\'ancoraggio non fa una seconda chiamata', () async {
      const natal = NatalContext(sunSign: 'Cancro', ascendant: 'Gemelli');
      for (final live in [true, false]) {
        final ai = _AiFinta();
        final c = _controller(ai, _MagazzinoLento(Duration.zero), natal: natal)
          ..nelLive = live;
        await c.init();
        await c.send('Cosa mi dice il cielo di questa settimana?');
        expect(ai.nelLive.length, live ? 1 : 2,
            reason: live
                ? 'nel LIVE la risposta senza un dato della persona ha '
                    'chiamato di nuovo il modello, e la persona aspetta'
                : 'nella chat la rete dell\'ancoraggio non c\'e\' piu\'');
      }
    });
  });

  group('EN.06, una risposta gia\' data non si rida\'', () {
    test('la risposta che ricalca si chiede di nuovo, nominandola', () async {
      final ai = _AiFinta(risposte: [
        _medora,
        _medora,
        'Parlale da persona a persona, senza chiederle di tornare.',
      ]);
      final c = _controller(ai, _MagazzinoLento(Duration.zero));
      await c.init();
      await c.send('Mia moglie mi ha lasciato con l\'avvocato. Cosa posso '
          'fare per farla tornare?');
      await c.send('Prova ancora a rispondergli su via moglie.');
      final dette = [
        for (final m in c.messages)
          if (m.isMaestro) m.text
      ];
      expect(dette, hasLength(2));
      expect(dette.last, isNot(dette.first),
          reason: 'la seconda risposta e\' la prima, parola per parola');
      expect(c.rigenerazioniPerRipetizione, 1);
      // La risposta gia' data e' quella consegnata: la prima porta anche la
      // frase sull'avvocato, perche' la domanda lo nominava.
      expect(ai.daNonRipetere.whereType<String>().single, startsWith(_medora),
          reason: 'la richiesta non nomina al modello la risposta ripetuta');
      expect(dette.first, contains('a un avvocato tuo'),
          reason: 'la persona ha nominato l\'avvocato e la risposta non le '
              'dice a chi rivolgersi');
    });

    // **LA RISPOSTA DA PROGRAMMA.** Le parole vere di Calìgo nell'ultimo giro
    // del collaudo con Gemini vero, con la regola "sei un Maestro, non un
    // programma" gia' scritta:
    // docs/collaudo/EN/risposte/ultimo/chat_caligo_moglie.md.
    const daProgramma = 'Non ho memoria delle conversazioni precedenti, salvo '
        'l\'ultima riga con ✦. Puoi dirmi che cosa ti ha spinto a tornare '
        'sulla questione di tua moglie?';

    test('la risposta da programma si chiede di nuovo, nominandola', () async {
      final ai = _AiFinta(risposte: [
        _medora,
        daProgramma,
        'Parlale da persona a persona, senza chiederle di tornare.',
      ]);
      final c = _controller(ai, _MagazzinoLento(Duration.zero));
      await c.init();
      await c.send('Mia moglie mi ha lasciato con l\'avvocato. Cosa posso '
          'fare per farla tornare?');
      await c.send('Prova ancora a rispondergli su via moglie.');
      final dette = [
        for (final m in c.messages)
          if (m.isMaestro) m.text
      ];
      expect(dette, hasLength(2));
      expect(dette.last, isNot(contains('memoria delle conversazioni')),
          reason: 'la risposta da programma e\' arrivata alla persona');
      expect(c.rigenerazioniPerProgramma, 1);
      expect(ai.daProgramma.whereType<String>().single, daProgramma,
          reason: 'la richiesta non nomina al modello la risposta da non '
              'dare');
      final istruzione = MaestroPersona.systemInstruction(
        maestro: Maestro.caligo,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        daProgramma: daProgramma,
      );
      expect(istruzione, contains('PARLAVA DI TE COME DI UN PROGRAMMA'));
      expect(istruzione, contains(daProgramma));
    });

    test('una risposta breve che ridice un fatto non si chiede di nuovo',
        () async {
      // **La suite intera l'ha mostrato alla prima stesura della rete**: una
      // risposta di tre parole piene e' "uguale" a un'altra di tre parole
      // che cambia per un numero, e la rete la chiedeva di nuovo. Ridire un
      // fatto non e' ricalcare una lettura.
      final ai = _AiFinta(risposte: [
        'Il tuo cane si chiama Argo.',
        'Il tuo cane si chiama Argo.',
      ]);
      final c = _controller(ai, _MagazzinoLento(Duration.zero));
      await c.init();
      await c.send('Come si chiama il mio cane?');
      await c.send('Ricordi il nome del mio cane?');
      expect(c.rigenerazioniPerRipetizione, 0,
          reason: 'la rete ha chiesto di nuovo una risposta di tre parole');
      expect(ai.nelLive, hasLength(2),
          reason: 'due domande, due chiamate: ${ai.nelLive.length}');
    });

    test('le frasi da programma del collaudo si riconoscono, le buone no', () {
      // Le tre del collaudo, una per giro in cui sono comparse.
      const vere = [
        'Il mio sistema mi dice che ho già risposto a questa domanda. Non '
            'posso aggiungere altro per ora.',
        'Chiedo scusa, la risposta precedente è stata inviata per errore '
            'senza una chiusura adeguata.',
        daProgramma,
      ];
      for (final v in vere) {
        expect(LaRispostaDaProgramma.segno(v), isNotNull,
            reason: 'la rete non riconosce una risposta da programma vera: '
                '$v');
      }
      // Risposte buone che toccano le stesse parole: sul Realme e nel
      // collaudo, e il Maestro che ricorda (voce EN.09).
      const buone = [
        'Il tuo sistema nervoso chiede riposo: il respiro lo calma.',
        'La memoria del corpo custodisce ciò che la mente dimentica.',
        'Nelle nostre conversazioni precedenti mi hai parlato di Argo.',
        'Prova a scriverle un messaggio semplice, senza chiedere nulla, solo '
            'per farle sapere che stai pensando a lei.',
        'Il tuo cane si chiama Argo. Questo nome risuona con un\'energia '
            'antica e forte.',
      ];
      for (final b in buone) {
        expect(LaRispostaDaProgramma.segno(b), isNull,
            reason: 'la rete prende per programma una risposta buona: $b');
      }
    });
  });

  group('EN.09, la memoria passa fra i Maestri', () {
    Future<(MaestroChatController, _AiFinta)> aura(Tier piano) async {
      final magazzino = _MagazzinoLento(Duration.zero);
      await magazzino.appendMessage(
          Maestro.medora,
          ChatMessage(
              role: ChatRole.user,
              text: 'Mia sorella Clara si sposa a maggio e io sono agitata.',
              at: _istante));
      await magazzino.appendMessage(
          Maestro.medora,
          ChatMessage(
              role: ChatRole.maestro,
              text: 'Il tuo cielo di maggio e\' aperto.',
              at: _istante));
      final ai = _AiFinta();
      final c = MaestroChatController(
        maestro: Maestro.aura,
        ai: ai,
        memory: magazzino,
        tier: () => piano,
        demo: false,
        attesaMinima: Duration.zero,
        orologio: () => _istante,
      );
      await c.init();
      await c.send('Come posso calmarmi prima del matrimonio?');
      return (c, ai);
    }

    test('cio\' che la persona ha detto a Medora arriva ad Aura', () async {
      final (c, ai) = await aura(Tier.tier2);
      // La prima chiamata: la chat la rifa' se non nomina un dato della
      // persona, e i ricordi degli altri due sono dati della persona.
      final fatti = ai.memorie.first.facts;
      expect(fatti.where((f) => f.contains('Clara si sposa a maggio')),
          hasLength(1),
          reason: 'Aura non sa cio\' che la persona ha detto a Medora');
      expect(fatti.single, startsWith('Detto a Medora'));
      // La voce di Medora resta a Medora.
      expect(fatti.any((f) => f.contains('cielo di maggio')), isFalse);
      // E nell'istruzione che parte davvero.
      expect(
          MaestroPersona.systemInstruction(
            maestro: Maestro.aura,
            profile: UserProfile.empty,
            memory: ai.memorie.first,
          ),
          contains('Clara si sposa a maggio'));
      expect(c.ricordiDegliAltri, hasLength(1));
    });

    test('un fatto detto prima di otto domande arriva lo stesso', () async {
      // **Il caso del Realme, 25 settembre 2026.** Nel LIVE di Aura la
      // persona ha detto il nome del cane come seconda frase, poi ha fatto
      // sette domande; Medora non lo sapeva, perche' dagli altri due
      // arrivavano solo le ultime sei frasi.
      final magazzino = _MagazzinoLento(Duration.zero);
      final frasi = [
        'Ora sai chi si sposa a maggio nella mia famiglia.',
        'Il mio cane si chiama Argo e ha paura dei temporali.',
        for (var i = 0; i < 7; i++) 'Domanda numero $i sul respiro.',
      ];
      for (final f in frasi) {
        await magazzino.appendMessage(Maestro.aura,
            ChatMessage(role: ChatRole.user, text: f, at: _istante));
        await magazzino.appendMessage(
            Maestro.aura,
            ChatMessage(
                role: ChatRole.maestro, text: 'Risposta.', at: _istante));
      }
      final ai = _AiFinta();
      final c = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: magazzino,
        tier: () => Tier.tier2,
        demo: false,
        attesaMinima: Duration.zero,
        orologio: () => _istante,
      );
      await c.init();
      expect(c.ricordiDegliAltri.where((r) => r.contains('Argo')), hasLength(1),
          reason: 'il nome del cane detto ad Aura non arriva a Medora: '
              '${c.ricordiDegliAltri.length} righe');
    });

    test('chi non ha la memoria nel suo piano non la riceve', () async {
      final (_, ai) = await aura(Tier.free);
      expect(ai.memorie.first.facts, isEmpty,
          reason: 'la memoria e\' esclusiva dei piani che la comprano');
    });
  });
}

/// **L'ISTANTE DICHIARATO delle prove della memoria.** I ricordi degli altri
/// due valgono quattordici giorni: con l'orologio vero i messaggi e il
/// controller starebbero nello stesso giorno oggi, ma una prova che legge
/// l'ora del telefono e' verde o rossa a seconda di quando la lanci.
final _istante = DateTime(2026, 9, 25, 11, 30);

const _medora = 'Scrivile stasera due righe, senza chiederle niente. Il tuo '
    'Cancro solare sente due volte quello che gli altri sentono una volta.';

MaestroChatController _controller(_AiFinta ai, _MagazzinoLento magazzino,
        {NatalContext natal = NatalContext.none}) =>
    MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: magazzino,
      natal: () => natal,
      demo: true,
      attesaMinima: Duration.zero,
    );

/// Un magazzino in RAM che salva con lentezza, come Firestore sul telefono.
class _MagazzinoLento extends InMemoryMaestroMemoryRepository {
  _MagazzinoLento(this.ritardo);

  final Duration ritardo;
  final List<String> eventi = [];

  @override
  Future<void> appendMessage(Maestro maestro, ChatMessage message) async {
    await Future<void>.delayed(ritardo);
    await super.appendMessage(maestro, message);
    if (message.pending) eventi.add('in attesa salvato');
  }

  @override
  Future<void> sostituisciUltimoMessaggio(
      Maestro maestro, ChatMessage message) async {
    eventi.add('sostituito');
    await Future<void>.delayed(ritardo);
    await super.sostituisciUltimoMessaggio(maestro, message);
  }
}

class _AiFinta implements MaestroAiProvider {
  _AiFinta({this.risposte = const []});

  final List<String> risposte;
  final List<bool> nelLive = [];
  final List<String?> daNonRipetere = [];
  final List<String?> daProgramma = [];
  final List<int> chiamataA = [];
  final List<MaestroMemory> memorie = [];
  Stopwatch? orologio;

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
    final turno = LaRichiestaDelTurno.corrente;
    nelLive.add(turno.nelLive);
    daNonRipetere.add(turno.daNonRipetere);
    daProgramma.add(turno.daProgramma);
    memorie.add(memory);
    if (orologio != null) chiamataA.add(orologio!.elapsedMilliseconds);
    final i = nelLive.length - 1;
    return i < risposte.length ? risposte[i] : 'Le stelle ti ascoltano.';
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
