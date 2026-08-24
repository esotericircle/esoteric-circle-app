import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
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

/// Le sette voci che producono danno economico diretto.
///
/// Un limite promesso e non imposto e' ricavo che non entra; un contenuto
/// venduto come esclusivo e regalato al gratuito e' valore che esce. Questi
/// test non abbelliscono niente: contano.
class _AiFinta implements MaestroAiProvider {
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

  int risposte = 0;
  int distillazioni = 0;

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
    risposte++;
    return 'Le stelle ti ascoltano.';
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
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    distillazioni++;
    return const MemoryDigest(summary: 's', facts: ['f']);
  }
}

/// Un repository che conta le scritture di memoria.
class _RepoContatore extends InMemoryMaestroMemoryRepository {
  int scrittureMemoria = 0;

  @override
  Future<void> saveMemory(Maestro maestro, MaestroMemory memory) async {
    scrittureMemoria++;
    return super.saveMemory(maestro, memory);
  }
}

Future<void> _posa() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('V4, la matrice e il contatore devono dire lo stesso numero', () {
    test('Il limite imposto coincide con quello promesso, per tutti i piani',
        () {
      final allowance = QuestionAllowance();
      // La matrice e' la fonte: "Domande a un Maestro" per i quattro piani.
      final riga = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Domande a un Maestro');

      int? promesso(String cella) {
        if (cella.toLowerCase().contains('illimitat')) return null;
        final m = RegExp(r'(\d+)').firstMatch(cella);
        return m == null ? null : int.parse(m.group(1)!);
      }

      const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
      for (var i = 0; i < ordine.length; i++) {
        expect(allowance.dailyLimit(ordine[i]), promesso(riga.values[i]),
            reason: 'il piano ${ordine[i]} promette "${riga.values[i]}" '
                'e impone ${allowance.dailyLimit(ordine[i])}');
      }
    });
  });

  group('V1, la chat deve rispettare il limite giornaliero', () {
    test('Con Viandante oltre il limite la chat rifiuta', () async {
      final ai = _AiFinta();
      final allowance = QuestionAllowance(freeDailyLimit: 1);
      final c = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
        allowance: allowance,
        tier: () => Tier.free,
      );

      final limite = allowance.dailyLimit(Tier.free)!;
      for (var i = 0; i < limite + 2; i++) {
        await c.send('domanda numero $i');
        await _posa();
      }

      expect(ai.risposte, limite,
          reason: 'la chat ha chiamato l\'AI ${ai.risposte} volte con un '
              'limite di $limite: le domande oltre soglia sono regalate');
      // Oltre soglia il Maestro risponde comunque QUALCOSA, che pero' non
      // viene dall'AI: un rifiuto muto sarebbe un pulsante che non fa niente.
      // Si misura il comportamento, non il vocabolario: la prima stesura di
      // questo test cercava la parola "limite" nella frase, che e' un modo per
      // legare un criterio economico a una scelta redazionale.
      final ultimo = c.messages.last;
      expect(ultimo.role, ChatRole.maestro);
      expect(ultimo.text, isNot(contains('Le stelle ti ascoltano')),
          reason: 'oltre soglia ha risposto la voce del Maestro generata '
              'dal provider, cioe\' quello che si voleva evitare');
      expect(ultimo.text.trim(), isNotEmpty,
          reason: 'oltre soglia non viene detto niente a chi scrive');
    });
  });

  group('V2, la memoria e\' esclusiva di chi paga', () {
    test('Con Viandante nessuna scrittura, con Iniziato si\'', () async {
      Future<int> scrittureCon(Tier tier, {bool demo = false}) async {
        final repo = _RepoContatore();
        final c = MaestroChatController(
          maestro: Maestro.medora,
          ai: _AiFinta(),
          memory: repo,
          // FUORI demo, per difetto: la legge del listino si misura sul
          // prodotto vero, non sulla presentazione (BG.03 tiene la memoria
          // accesa in demo, e il caso demo si misura in coda alla prova).
          demo: demo,
          tier: () => tier,
          // Qui si misurano i contatori, non la pausa: senza questo dieci turni
          // pagherebbero dieci volte i 3200 millisecondi della scena.
          attesaMinima: Duration.zero,
        );
        // Abbastanza turni da innescare la distillazione.
        for (var i = 0; i < 5; i++) {
          await c.send('turno $i');
          await _posa();
        }
        return repo.scrittureMemoria;
      }

      expect(await scrittureCon(Tier.free), 0,
          reason: 'la memoria, venduta come esclusiva, viene distillata '
              'anche per il gratuito');
      expect(await scrittureCon(Tier.tier1), greaterThan(0),
          reason: 'chi paga non riceve la memoria che ha comprato');

      // E IN DEMO LA MEMORIA E' ACCESA PER TUTTI, ordine BG voce 03: i
      // Maestri della presentazione non hanno la memoria spenta del tier free.
      expect(await scrittureCon(Tier.free, demo: true), greaterThan(0),
          reason: 'in demo il Maestro dimentica: la presentazione mostra '
              'un prodotto senza memoria');
    });
  });
}
