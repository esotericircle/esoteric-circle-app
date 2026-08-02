import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/lettura_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
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

  group('Il tetto dell\'approfondimento vive con gli altri', () {
    test('E\' 420, ed e\' una costante come tutte', () {
      expect(FirebaseMaestroAiProvider.kApprofondimentoMaxTokens, 420);
      // Piu' alto della Profonda del Consulta: li' si sceglie prima di
      // leggere, qui si chiede dopo aver letto.
      expect(FirebaseMaestroAiProvider.kApprofondimentoMaxTokens,
          greaterThan(FirebaseMaestroAiProvider.kProfondaMaxTokens));
    });

    test('La regola dell\'approfondimento entra nella persona', () {
      final normale = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      final piuGiu = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        approfondisci: true,
      );
      expect(normale.contains(MaestroPersona.regolaDellApprofondimento),
          isFalse);
      expect(piuGiu.contains(MaestroPersona.regolaDellApprofondimento), isTrue);
      // Non e' "scrivi di piu'": e' "scendi".
      expect(MaestroPersona.regolaDellApprofondimento,
          contains('Non ripeterla con altre parole'));
    });
  });

  group('I budget sono due, e il giorno e\' uno', () {
    test('Il Viandante non ha l\'approfondimento nel piano', () {
      final contatore = QuestionAllowance();
      expect(contatore.pianoConApprofondimento(Tier.free), isFalse);
      expect(contatore.puoiApprofondire(Tier.free), isFalse);
    });

    test('Iniziato tre, Adepto dieci, Illuminato senza limite', () {
      final contatore = QuestionAllowance();
      expect(contatore.limiteApprofondimenti(Tier.tier1), 3);
      expect(contatore.limiteApprofondimenti(Tier.tier2), 10);
      expect(contatore.limiteApprofondimenti(Tier.tier3), isNull);
      // Senza limite, ma col tetto di correttezza.
      expect(contatore.approfondimentiRimasti(Tier.tier3),
          QuestionAllowance.kTettoDiCorrettezza);
    });

    test('L\'approfondimento NON consuma una domanda del giorno', () {
      final contatore = QuestionAllowance();
      final domandePrima = contatore.remaining(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.remaining(Tier.tier1), domandePrima,
          reason: 'se consumasse una domanda la persona esiterebbe, e '
              'l\'esitazione uccide l\'intimita\'');
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
    });

    test('I due budget ribaltano insieme, perche\' il giorno e\' lo stesso', () {
      var oggi = DateTime(2026, 8, 2, 23, 0);
      final contatore = QuestionAllowance(clock: () => oggi);
      contatore.record(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
      oggi = DateTime(2026, 8, 3, 1, 0);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 3);
      expect(contatore.usedToday(), 0);
    });
  });

  group('L\'invito, e cosa succede al tocco', () {
    test('Compare sull\'ultima risposta vera, e una volta sola', () async {
      final voce = _VoceContata(['Il tuo Sole in Cancro chiede riparo.']);
      final controller = await conVoce(voce);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'a conversazione vuota non c\'e' ' niente da approfondire');
      await controller.send('cosa mi manca');
      expect(controller.puoiChiedereDiApprofondire, isTrue);

      await controller.approfondisci();
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'due volte sarebbe una scala senza fine');
    });

    test('Approfondire rigenera la STESSA risposta, non ne aggiunge una',
        () async {
      final voce = _VoceContata([
        'Il tuo Sole in Cancro chiede riparo.',
        'Il tuo Sole in Cancro chiede riparo, e sotto quel riparo c\'è altro.',
      ]);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      final quanteBolle = controller.messages.length;

      await controller.approfondisci();
      expect(controller.messages.length, quanteBolle,
          reason: 'e\' la stessa lettura portata piu\' giu\', non una seconda '
              'risposta alla stessa domanda');
      expect(controller.messages.last.approfondita, isTrue);
      expect(voce.approfondimenti, 1,
          reason: 'la seconda chiamata deve chiedere di scendere');
    });

    test('Non compare su un ripiego', () async {
      final voce = _VoceContata([], sempreInGuasto: true);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.messages.last.ripiego, isTrue);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'non si approfondisce cio\' che il Maestro non ha detto');
    });

    test('Finiti gli approfondimenti, non si scende e non si consuma',
        () async {
      final contatore = QuestionAllowance();
      final voce = _VoceContata(['Il tuo Sole in Cancro chiede riparo.']);
      final controller = await conVoce(voce, contatore: contatore);
      await controller.send('cosa mi manca');
      // Si bruciano i tre dell'Iniziato.
      for (var i = 0; i < 3; i++) {
        contatore.registraApprofondimento(Tier.tier1);
      }
      expect(contatore.puoiApprofondire(Tier.tier1), isFalse);
      final chiamatePrima = voce.chiamate;
      await controller.approfondisci();
      expect(voce.chiamate, chiamatePrima,
          reason: 'senza budget non si chiama il modello');
    });

    test('Se l\'approfondimento fallisce, la risposta gia\' letta resta',
        () async {
      final voce = _VoceContata(
        ['Il tuo Sole in Cancro chiede riparo.'],
        falliscoApprofondendo: true,
      );
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      await controller.approfondisci();
      expect(controller.messages.last.text,
          'Il tuo Sole in Cancro chiede riparo.',
          reason: 'chi ha gia\' letto non deve perdere cio\' che ha letto');
      expect(controller.messages.last.approfondita, isTrue,
          reason: 'e non si ritenta all\'infinito');
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
    this.falliscoApprofondendo = false,
  });

  final List<String> _risposte;
  final bool sempreInGuasto;
  final bool falliscoApprofondendo;
  int chiamate = 0;
  int approfondimenti = 0;

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
    if (approfondisci) {
      approfondimenti++;
      if (falliscoApprofondendo) throw Exception('giu\' non si scende');
    }
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
