import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/lettura_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Vai piu' a fondo", e il silenzio che non lascia a mani vuote.
///
/// La profondita' non si sceglie PRIMA di leggere: la prima risposta arriva
/// sempre alla stessa misura per tutti, e chi vuole scendere lo chiede dopo.
/// Chi lo chiede ha gia' deciso che quella risposta gli interessa.
/// Una lettura lunga come quelle vere, cioe' con un secondo strato dentro.
const String _letturaLunga =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'Quello che senti come confusione e\' un confine che si sposta. '
    'Guarda dove ti fermi a respirare: quella e\' la direzione. '
    'Sotto la superficie c\'e\' un secondo movimento, piu\' lento, che '
    'lavora da mesi senza chiedere il tuo permesso. Non e\' la scelta a '
    'spaventarti, e\' quello che la scelta rende definitivo. Aspetta la '
    'prossima luna nuova e rileggi queste stesse parole.';

void main() {
  const natalCancro = NatalContext(sunSign: 'Cancro');

  Future<MaestroChatController> conVoce(
    _VoceContata voce, {
    Tier piano = Tier.tier1,
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
      tier: () => piano,
      natal: () => natalCancro,
    );
    await controller.init();
    return controller;
  }

  group('Una generazione sola, e due lunghezze', () {
    test('Centottanta per chi legge a due strati, cinquanta per gli altri', () {
      expect(MisuraDellaRisposta.letturaDellaChat.parole, 180);
      expect(MisuraDellaRisposta.letturaBreve.parole, 50);
      expect(MisuraDellaRisposta.perChat(aDueStrati: true),
          MisuraDellaRisposta.letturaDellaChat);
      expect(MisuraDellaRisposta.perChat(aDueStrati: false),
          MisuraDellaRisposta.letturaBreve);
    });

    test('La lunghezza chiesta arriva al Maestro, e cambia col piano', () {
      final intera = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      final breve = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        aDueStrati: false,
      );
      expect(intera, contains('circa centottanta parole'));
      expect(breve, contains('circa cinquanta parole'));
    });

    test('La regola dei due strati e\' in OGNI istruzione, non in una sola',
        () {
      // Prima esisteva una regola che entrava solo nella seconda chiamata. Non
      // c'e' piu' una seconda chiamata, quindi non c'e' piu' un ramo: le prime
      // frasi devono reggere da sole SEMPRE, perche' molte persone leggeranno
      // solo quelle.
      for (final maestro in Maestro.values) {
        final istr = MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
        );
        expect(istr, contains(MaestroPersona.regolaDeiDueStrati),
            reason: '${maestro.displayName} non sa che le prime frasi devono '
                'reggere da sole');
      }
    });
  });

  group('Il budget governa cio\' che si SCRIVE, non cio\' che si legge', () {
    test('Il Viandante non ha il secondo strato nel piano', () {
      final contatore = QuestionAllowance();
      expect(contatore.pianoConApprofondimento(Tier.free), isFalse);
      expect(contatore.puoiApprofondire(Tier.free), isFalse);
    });

    test('Iniziato tre, Adepto dieci, Illuminato senza limite', () {
      final contatore = QuestionAllowance();
      expect(contatore.limiteApprofondimenti(Tier.tier1), 3);
      expect(contatore.limiteApprofondimenti(Tier.tier2), 10);
      expect(contatore.limiteApprofondimenti(Tier.tier3), isNull);
      expect(contatore.approfondimentiRimasti(Tier.tier3),
          QuestionAllowance.kTettoDiCorrettezza);
    });

    test('Una lettura intera NON consuma una domanda del giorno', () {
      final contatore = QuestionAllowance();
      final domandePrima = contatore.remaining(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.remaining(Tier.tier1), domandePrima,
          reason: 'se consumasse una domanda la persona esiterebbe, e '
              'l\'esitazione uccide l\'intimita\'');
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
    });

    test('I due budget ribaltano insieme, perche\' il giorno e\' lo stesso',
        () {
      var oggi = DateTime(2026, 8, 2, 23, 0);
      final contatore = QuestionAllowance(clock: () => oggi);
      contatore.record(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
      oggi = DateTime(2026, 8, 3, 1, 0);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 3);
      expect(contatore.usedToday(), 0);
    });

    test('Il budget si consuma quando la lettura ARRIVA, non al tocco',
        () async {
      final contatore = QuestionAllowance();
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce, contatore: contatore);
      final prima = contatore.approfondimentiRimasti(Tier.tier1);
      await controller.send('cosa mi manca');
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima - 1,
          reason: 'la lettura intera e\' stata scritta, quindi e\' stata '
              'pagata: e\' li\' che si conta');
      // E il tocco, che non spende niente, non conta niente.
      controller.approfondisci();
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima - 1,
          reason: 'rivelare del testo gia\' scritto non costa niente, quindi '
              'non puo\' consumare un budget');
    });

    test('Finito il budget, si scrive la lettura BREVE', () async {
      final contatore = QuestionAllowance();
      for (var i = 0; i < 3; i++) {
        contatore.registraApprofondimento(Tier.tier1);
      }
      expect(contatore.puoiApprofondire(Tier.tier1), isFalse);
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce, contatore: contatore);
      await controller.send('cosa mi manca');
      expect(voce.ultimaADueStrati, isFalse,
          reason: 'finito il budget si continua a chiedere al Maestro la '
              'lettura intera, e centotrenta parole finiscono dietro un '
              'lucchetto: si paga per parole che nessuno leggera\'');
    });
  });

  group('L\'invito, e cosa succede al tocco', () {
    test('Compare su una lettura che ha davvero un secondo strato', () async {
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'a conversazione vuota non c\'e\' niente da rivelare');
      await controller.send('cosa mi manca');
      expect(controller.puoiChiedereDiApprofondire, isTrue);
      controller.approfondisci();
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'due volte sarebbe una scala senza fine');
    });

    test('Su una lettura corta la freccia NON compare', () async {
      final voce = _VoceContata(['Il tuo Sole in Cancro chiede riparo.']);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'sotto non c\'e\' niente: una freccia che promette del '
              'testo inesistente e\' il difetto da cui questa voce e\' nata');
    });

    test('Rivelare NON chiama il modello, e non cambia il testo', () async {
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      final quanteBolle = controller.messages.length;
      final chiamatePrima = voce.chiamate;
      final testoPrima = controller.messages.last.text;

      controller.approfondisci();
      expect(voce.chiamate, chiamatePrima,
          reason: 'la freccia ha chiesto un\'altra risposta al Maestro: '
              'rivela, non rigenera');
      expect(controller.messages.length, quanteBolle,
          reason: 'e\' la stessa lettura, non una seconda risposta');
      expect(controller.messages.last.text, testoPrima,
          reason: 'il testo non cambia: cambia quanto se ne mostra');
      expect(controller.messages.last.approfondita, isTrue);
    });

    test('Non compare su un ripiego', () async {
      final voce = _VoceContata([], sempreInGuasto: true);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.messages.last.ripiego, isTrue);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'non si rivela cio\' che il Maestro non ha detto');
    });
  });

  group('Il silenzio consegna una lettura vera', () {
    test('Con dei dati, legge davvero e dichiara di essere un ripiego', () {
      final testo = LetturaDiRipiego.componi(
        maestro: Maestro.medora,
        domanda: 'cosa mi manca',
        natal: natalCancro,
      );
      // 1. Dichiara di non essere la sua voce.
      expect(testo, startsWith('Il cielo si è coperto'));
      // 2. Legge DAVVERO, col dato vero di questa persona.
      expect(testo, contains('Cancro'));
      // 3. E porta da qualche parte: nessuno stato senza uscita.
      expect(testo, contains('carta natale'));
    });

    test('Senza dati non inventa, ma la via d\'uscita resta', () {
      final testo = LetturaDiRipiego.componi(
        maestro: Maestro.caligo,
        domanda: 'cosa mi manca',
        natal: NatalContext.none,
      );
      expect(testo, contains('nebbia'),
          reason: 'il ripiego di Caligo apre come sempre');
      expect(testo, contains('runa'),
          reason: 'anche senza dati la porta c\'è');
      // Non deve nominare un segno che non esiste.
      expect(testo.contains('in Cancro'), isFalse);
    });

    test('Ogni Maestro ha la sua lettura e la sua uscita', () {
      // Enumerati: la regola vale per i tre, e per quello che nascera' domani.
      final uscite = <String>{};
      for (final maestro in Maestro.values) {
        final testo = LetturaDiRipiego.componi(
          maestro: maestro,
          domanda: 'cosa mi manca',
          natal: natalCancro,
        );
        expect(testo.trim(), isNotEmpty);
        uscite.add(testo.split('\n').last);
      }
      expect(uscite.length, Maestro.values.length,
          reason: 'tre Maestri con la stessa uscita non sono tre Maestri');
    });

    test('La chat consegna la lettura vera quando la voce tace', () async {
      final voce = _VoceContata([], sempreInGuasto: true);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      final bolla = controller.messages.last;
      expect(bolla.ripiego, isTrue);
      expect(bolla.text, contains('Cancro'),
          reason: 'il ripiego deve LEGGERE, non solo scusarsi');
      expect(bolla.text, contains('carta natale'),
          reason: 'nessuno stato senza una via di uscita');
    });
  });
}

/// Una voce che conta come e' stata chiamata e sa fallire su richiesta.
class _VoceContata implements MaestroAiProvider {
  _VoceContata(
    this._risposte, {
    this.sempreInGuasto = false,
  });

  final List<String> _risposte;
  final bool sempreInGuasto;
  int chiamate = 0;

  /// Con quale lunghezza e' stata chiesta l'ultima risposta. E' il modo di
  /// verificare che il budget governi cio' che si SCRIVE.
  bool? ultimaADueStrati;

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
    bool aDueStrati = true,
  }) async {
    ultimaADueStrati = aDueStrati;
    if (sempreInGuasto) throw Exception('la voce tace');
    final indice = chiamate.clamp(0, _risposte.length - 1);
    chiamate++;
    return _risposte[indice];
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
