import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/frase_del_limite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/firebase/attestazione.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'app non dice il falso: ne' sul numero, ne' con la voce di un altro.
void main() {
  group('Il limite dice il NUMERO VERO, letto dal dato', () {
    test('Il Viandante ha TRE domande al giorno', () {
      // Il numero deciso e approvato dal fondatore. Diceva UNO, e l'app non
      // mentiva: leggeva questo dato e lo ripeteva fedelmente. A mentire era
      // il dato.
      expect(
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, Tier.free),
        3,
      );
      expect(QuestionAllowance().dailyLimit(Tier.free), 3);
    });

    test('La frase LEGGE il numero, non lo scrive', () {
      // Se domani il limite diventa cinque, la frase lo dice da sola.
      for (final maestro in Maestro.values) {
        expect(FraseDelLimite.per(maestro, limite: 3), contains('tre domande'));
        expect(
            FraseDelLimite.per(maestro, limite: 5), contains('cinque domande'));
        // Sopra il nove la cifra: nessuno legge "dodici" come una voce.
        expect(FraseDelLimite.per(maestro, limite: 12), contains('12 domande'));
        expect(FraseDelLimite.per(maestro, limite: 1), contains('una domanda'));
      }
    });

    test('Nessuna frase del limite contiene una cifra scritta a mano', () {
      // La sola cifra ammessa e' quella che arriva dal dato: con limite tre non
      // deve comparire nessun altro numero.
      for (final maestro in Maestro.values) {
        final frase = FraseDelLimite.per(maestro, limite: 3);
        final cifre = RegExp(r'\d+').allMatches(frase).length;
        expect(cifre, 0,
            reason: '${maestro.id}: "tre" si scrive in lettere, e qualunque '
                'altra cifra sarebbe scritta a mano');
      }
    });

    test('Il vantaggio del piano dice lo stesso numero della matrice', () {
      // Erano due testi diversi per lo stesso numero, e uno dei due mentiva.
      final viandante =
          PlanCatalog.plans.firstWhere((p) => p.tier == Tier.free);
      expect(
        viandante.highlights.any((h) => h.toLowerCase().contains('tre domande')),
        isTrue,
        reason: 'il vantaggio scritto a mano diceva "Una domanda al giorno" '
            'mentre la matrice adesso ne promette tre',
      );
    });
  });

  group('Il limite lo dice CIASCUNO A MODO SUO', () {
    test('Le tre frasi sono tre, e nessuna e\' vuota', () {
      final viste = <String>{};
      for (final maestro in Maestro.values) {
        final frase = FraseDelLimite.per(maestro, limite: 3);
        expect(frase.trim(), isNotEmpty, reason: '${maestro.id} tace');
        viste.add(frase);
      }
      expect(viste.length, Maestro.values.length,
          reason: 'il 2 agosto Caligo e Aura hanno detto la STESSA IDENTICA '
              'frase, parola per parola: e\' il messaggio che l\'utente '
              'gratuito vede piu\' spesso di ogni altro');
    });

    test('Vale anche per il piano senza limite', () {
      final viste = <String>{};
      for (final maestro in Maestro.values) {
        viste.add(FraseDelLimite.per(maestro, limite: null));
      }
      expect(viste.length, Maestro.values.length);
    });

    test('Ognuna porta comunque la via d\'uscita', () {
      for (final maestro in Maestro.values) {
        expect(FraseDelLimite.per(maestro, limite: 3).toLowerCase(),
            contains('allarg'),
            reason: '${maestro.id}: mai un vicolo cieco, l\'invito a salire '
                'resta, detto a modo suo');
      }
    });

    testWidgets('La chat mostra la frase del suo Maestro', (tester) async {
      for (final maestro in Maestro.values) {
        final memoria = InMemoryMaestroMemoryRepository();
        await memoria.saveProfile(
            UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
        final conto = QuestionAllowance();
        final chat = MaestroChatController(
          maestro: maestro,
          ai: _VoceCheTace(),
          memory: memoria,
          allowance: conto,
          tier: () => Tier.free,
        );
        await chat.init();
        // Si bruciano le tre del Viandante con risposte VERE.
        while (conto.remaining(Tier.free) > 0) {
          conto.record(Tier.free);
        }
        await chat.send('ancora una');
        expect(chat.messages.last.text,
            FraseDelLimite.per(maestro, limite: 3),
            reason: '${maestro.id} deve parlare con la sua voce');
      }
    });
  });

  group('L\'invito a scendere non compare dove non c\'e\' un responso', () {
    // Enumerati: TUTTI i tipi di messaggio, e su quali l'invito ha senso.
    const atteso = <TipoDiMessaggio, bool>{
      TipoDiMessaggio.domanda: false,
      TipoDiMessaggio.responso: true,
      TipoDiMessaggio.ripiego: false,
      TipoDiMessaggio.limiteRaggiunto: false,
      TipoDiMessaggio.errore: false,
      TipoDiMessaggio.instradamento: false,
    };

    test('Ogni tipo dichiara se porta un responso, e uno solo lo porta', () {
      expect(atteso.keys.toSet(), TipoDiMessaggio.values.toSet(),
          reason: 'un tipo non dichiarato e\' un tipo su cui nessuno ha '
              'deciso se l\'invito compare');
      for (final voce in atteso.entries) {
        final m = ChatMessage(
          role: voce.key == TipoDiMessaggio.domanda
              ? ChatRole.user
              : ChatRole.maestro,
          text: 'x',
          tipo: voce.key,
        );
        expect(m.portaUnResponso, voce.value,
            reason: '${voce.key.name} dovrebbe '
                '${voce.value ? "portare" : "NON portare"} un responso');
      }
    });

    test('Un messaggio vecchio senza tipo si ricava dai flag', () {
      // La cronologia gia' salvata non ha il tipo: non deve perdere il senso.
      const ripiego = ChatMessage(
          role: ChatRole.maestro, text: 'x', ripiego: true, failed: true);
      expect(ripiego.tipoEffettivo, TipoDiMessaggio.ripiego);
      const responso = ChatMessage(role: ChatRole.maestro, text: 'x');
      expect(responso.portaUnResponso, isTrue);
    });

    testWidgets('Dopo il messaggio del limite non si puo\' approfondire',
        (tester) async {
      final memoria = InMemoryMaestroMemoryRepository();
      await memoria.saveProfile(
          UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final conto = QuestionAllowance();
      final chat = MaestroChatController(
        maestro: Maestro.medora,
        ai: _VoceCheTace(),
        memory: memoria,
        allowance: conto,
        tier: () => Tier.free,
      );
      await chat.init();
      while (conto.remaining(Tier.free) > 0) {
        conto.record(Tier.free);
      }
      await chat.send('ancora una');
      expect(chat.messages.last.tipoEffettivo, TipoDiMessaggio.limiteRaggiunto);
      expect(chat.puoiChiedereDiApprofondire, isFalse,
          reason: 'non c\'e\' nessuna lettura da approfondire in una frase che '
              'dice che hai finito le domande');
    });
  });

  group('Il pannello dice la verita\' su se stesso', () {
    test('Il testo del token segue l\'interruttore, non il contrario', () {
      // Non si prova il widget: si prova che la REGOLA leghi il testo allo
      // stato, cosi' il giorno in cui l'attestazione tornera' il pannello
      // cambiera' da solo. La prova sta sul dato che il pannello legge.
      expect(Attestazione.vaInstallata(releaseMode: true),
          Attestazione.installaSempre,
          reason: 'in release l\'attestazione si installa se e solo se '
              'l\'interruttore e\' acceso');
      // E la ragione mostrata dice la cosa vera, non che manca un token.
      final ragione =
          Attestazione.ragioneDi(EsitoAttestazione.nonInstallataPerScelta);
      expect(ragione, contains('NON installata'));
      expect(ragione, contains('Play Store'),
          reason: 'senza la condizione che lo chiude non e\' un compromesso');
      // Il vecchio testo faceva credere che l'attestazione ci fosse e che
      // MANCASSE solo il token. La ragione nuova puo' nominare il token,
      // purche' dica che non serve invece che manca.
      expect(ragione.toLowerCase().contains('manca'), isFalse,
          reason: 'il vecchio testo faceva credere che mancasse solo un token, '
              'ed e\' il difetto che questa voce corregge');
    });
  });
}

/// Una voce che non risponde: qui serve solo ad arrivare al ramo del limite.
class _VoceCheTace implements MaestroAiProvider {
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
  }) async =>
      throw Exception('non deve essere chiamata');

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
