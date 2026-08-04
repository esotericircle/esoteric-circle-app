import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/seguito_della_lettura.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// AL TOCCO SI GENERA SOLO IL SEGUITO.
///
/// **L'osservazione del fondatore, ed e' fondata.** Se un Premium non tocca
/// mai la freccia, la spesa per il testo lungo e' gia' stata sostenuta per
/// niente. Generare sempre intero costa 2157 token a risposta, sempre;
/// generare il seguito al tocco costa 1923 subito, piu' una seconda chiamata
/// solo per chi approfondisce. Il pareggio sta intorno all'11,5 per cento, e
/// quel numero non lo sappiamo.
const String _breve =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.\n'
    '✦ Non decidere adesso: guarda dove ti fermi.';

void main() {
  Future<MaestroChatController> con(
    _Voce voce, {
    Tier piano = Tier.tier1,
    QuestionAllowance? contatore,
    Tier Function()? livello,
  }) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final c = MaestroChatController(
      maestro: Maestro.medora,
      ai: voce,
      memory: memoria,
      allowance: contatore ?? QuestionAllowance(),
      tier: livello ?? () => piano,
      natal: () => const NatalContext(sunSign: 'Cancro'),
    );
    await c.init();
    return c;
  }

  group('La prima risposta e\' breve, per tutti', () {
    test('Si chiede la breve, e il seguito ha la sua misura', () {
      expect(MisuraDellaRisposta.perChat, MisuraDellaRisposta.letturaBreve);
      expect(MisuraDellaRisposta.perIlSeguito, MisuraDellaRisposta.seguito);
      // Centotrenta piu' cinquanta fanno centottanta, cioe' la lettura intera:
      // chi tocca la freccia legge in tutto la stessa quantita' di prima.
      expect(
          MisuraDellaRisposta.letturaBreve.parole +
              MisuraDellaRisposta.seguito.parole,
          MisuraDellaRisposta.letturaDellaChat.parole);
    });

    test('Nessuna prima chiamata porta la risposta gia\' data', () async {
      final voce = _Voce();
      final c = await con(voce, piano: Tier.tier3);
      await c.send('devo cambiare lavoro');
      expect(voce.chiamate, 1);
      expect(voce.ultimaRispostaGiaData, isNull,
          reason: 'la prima chiamata sta gia\' chiedendo un seguito');
      expect(
          MaestroPersona.systemInstruction(
            maestro: Maestro.medora,
            profile: UserProfile.empty,
            memory: MaestroMemory.empty,
          ),
          contains('circa cinquanta parole'),
          reason: 'la prima risposta non e\' piu\' breve per tutti, e chi non '
              'tocca mai la freccia paga parole che non leggera\'');
    });
  });

  group('Il seguito si genera, e continua', () {
    test('Il tocco fa UNA seconda chiamata, con la risposta gia\' data',
        () async {
      final voce = _Voce();
      final c = await con(voce);
      await c.send('devo cambiare lavoro');
      expect(voce.chiamate, 1);
      await c.approfondisci();
      expect(voce.chiamate, 2,
          reason: 'il tocco non ha chiesto niente: il seguito non si genera');
      expect(voce.ultimaRispostaGiaData, _breve,
          reason: 'il Maestro non ha ricevuto cio\' che aveva gia\' detto, '
              'quindi non puo\' continuare da li\'');
      expect(c.messages.last.seguito, isNotNull);
      expect(c.messages.last.approfondita, isTrue);
    });

    test('Il seguito NON ripete il breve, e l\'app lo verifica', () async {
      // L'istruzione dice al Maestro di non ripetersi. Un'istruzione non e'
      // una garanzia: qui il finto ripete apposta due frasi intere.
      final voce = _Voce(
        seguito: 'Il tuo Sole in Cancro chiede riparo prima di chiedere '
            'strada. Sotto la superficie lavora un movimento più lento. '
            'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.',
      );
      final c = await con(voce);
      await c.send('devo cambiare lavoro');
      await c.approfondisci();
      final seguito = c.messages.last.seguito!;
      expect(seguito, contains('movimento più lento'),
          reason: 'il seguito e\' stato buttato via invece che ripulito');
      expect(seguito, isNot(contains('chiede riparo prima di chiedere')),
          reason: 'la persona rilegge una frase che ha gia\' letto, e '
              'l\'approfondimento sembra una truffa');
      expect(c.frasiRipetuteNelSeguito, 2,
          reason: 'le ripetizioni non vengono contate, quindi nessuno sapra\' '
              'mai se l\'istruzione regge');
    });

    test('Un seguito TUTTO ripetuto non consuma e lascia la freccia',
        () async {
      final contatore = QuestionAllowance();
      final voce = _Voce(
          seguito: 'Il tuo Sole in Cancro chiede riparo prima di chiedere '
              'strada.');
      final c = await con(voce, contatore: contatore);
      await c.send('devo cambiare lavoro');
      final prima = contatore.approfondimentiRimasti(Tier.tier1);
      await c.approfondisci();
      expect(c.messages.last.seguito, isNull);
      expect(c.messages.last.approfondita, isFalse);
      expect(c.puoiChiedereDiApprofondire, isTrue,
          reason: 'la freccia sparisce dopo un seguito vuoto: non si puo\' '
              'nemmeno riprovare');
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima,
          reason: 'un seguito che non c\'e\' ha consumato un budget');
    });

    test('Il seguito resta coerente con l\'elemento oracolare gia\' dato',
        () async {
      // La runa e' deterministica e non si ripesca: il modello la vede dentro
      // il testo che riceve, quindi ci lavora sopra.
      final voce = _Voce();
      final c = await con(voce);
      await c.send('devo cambiare lavoro');
      await c.approfondisci();
      expect(voce.ultimaRispostaGiaData, contains('Laguz'),
          reason: 'il Maestro non vede la runa che ha gia\' consegnato, '
              'quindi puo\' nominarne un\'altra');
      // E l'istruzione glielo dice a parole, non solo col contesto.
      expect(SeguitoDellaLettura.istruzione('x'),
          contains('quello è già stato dato e non si cambia'));
    });

    test('Se il seguito fallisce, la risposta gia\' letta RESTA', () async {
      final voce = _Voce(fallisci: true);
      final c = await con(voce);
      await c.send('devo cambiare lavoro');
      await c.approfondisci();
      expect(c.messages.last.text, _breve,
          reason: 'chi ha gia\' letto non deve perdere cio\' che ha letto');
      expect(c.messages.last.approfondita, isFalse);
      expect(c.puoiChiedereDiApprofondire, isTrue,
          reason: 'riprovare e\' esattamente cio\' che si vuole fare qui');
    });
  });

  group('Il seguito sta PRIMA del consiglio', () {
    test('Il campo e\' suo, e non incollato in coda al testo', () async {
      final voce = _Voce();
      final c = await con(voce);
      await c.send('devo cambiare lavoro');
      await c.approfondisci();
      final m = c.messages.last;
      expect(m.seguito, isNotNull);
      expect(m.text, _breve,
          reason: 'il seguito e\' stato incollato in coda a `text`: cosi\' '
              'finisce SOTTO la riga del consiglio, e il consiglio smette di '
              'essere l\'ultima riga');
      // E la riga del consiglio si compone ancora dal testo breve, quindi
      // resta quella di prima.
      expect(ConsiglioFinale.sintesiDa(m.text),
          'Non decidere adesso: guarda dove ti fermi.');
    });

    test('Un copyWith che non lo nomina NON perde il seguito', () {
      // **UNA PROVA DEL ROSSO RESTATA VERDE l'ha chiesta.** Togliendo il
      // `?? this.seguito` dal `copyWith` nessuna prova cadeva, perche' oggi
      // l'unico punto che lo scrive lo passa sempre. Ma il messaggio passa da
      // altri `copyWith` che parlano d'altro, per esempio quello che spegne
      // `pending`, e li' il seguito sarebbe sparito in silenzio.
      const m = ChatMessage(
        role: ChatRole.maestro,
        text: 'la lettura breve.',
        seguito: 'il seguito, che deve sopravvivere.',
        approfondita: true,
      );
      expect(m.copyWith(pending: false).seguito, m.seguito);
      expect(m.copyWith(text: 'altro').seguito, m.seguito);
      expect(m.copyWith(failed: true).seguito, m.seguito);
    });
  });

  group('IL PERCORSO VERO: Viandante, abbonamento, ritorno, tocco', () {
    test('Da Viandante non legge, si abbona, ritocca e il seguito ARRIVA',
        () async {
      // **E' il percorso del fondatore, e va provato esatto.** Con la
      // generazione del seguito funziona sempre, perche' non serve che il
      // testo lungo esistesse gia' al momento della domanda.
      var livello = Tier.free;
      final voce = _Voce();
      final c = await con(voce, livello: () => livello);

      await c.send('devo cambiare lavoro');
      expect(c.puoiChiedereDiApprofondire, isTrue,
          reason: 'da Viandante la freccia deve vedersi');
      await c.approfondisci();
      expect(c.messages.last.seguito, isNull,
          reason: 'il Viandante ha letto il secondo strato');
      expect(voce.chiamate, 1,
          reason: 'il rifiuto ha comunque chiamato il modello');

      // Va agli abbonamenti, si abbona, torna indietro.
      livello = Tier.tier1;

      await c.approfondisci();
      expect(c.messages.last.seguito, isNotNull,
          reason: 'DOPO L\'ABBONAMENTO IL SEGUITO NON ARRIVA. E\' il percorso '
              'vero del fondatore, e deve funzionare senza rifare la domanda');
      expect(voce.chiamate, 2);
      expect(voce.ultimaRispostaGiaData, _breve,
          reason: 'il seguito e\' partito da una risposta diversa da quella '
              'che la persona ha davanti');
    });
  });
}

class _Voce implements MaestroAiProvider {
  _Voce({this.seguito, this.fallisci = false});

  /// Cosa risponde alla seconda chiamata. Nullo vuol dire un seguito pulito.
  final String? seguito;
  final bool fallisci;

  int chiamate = 0;
  String? ultimaRispostaGiaData;

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
    chiamate++;
    ultimaRispostaGiaData = rispostaGiaData;
    if (rispostaGiaData == null) return _breve;
    if (fallisci) throw Exception('il seguito non scende');
    return seguito ??
        'Sotto la superficie lavora un secondo movimento, più lento, che '
            'dura da mesi. Laguz continua a scorrere anche quando non la '
            'guardi.';
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
      const MaestroReply(glance: 'g', reading: 'r', invite: 'i');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      's';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
