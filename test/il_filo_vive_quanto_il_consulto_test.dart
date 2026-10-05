import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL FILO VIVE QUANTO IL CONSULTO. Ordine FE voce 12.** Lo schermo si
/// apre sempre vuoto (ordine EA voce 06), ma chi torna sullo stesso Maestro
/// entro un'ora ritrova il suo filo: il Maestro riceve le ultime battute
/// della conversazione di prima. Oltre l'ora il consulto e' nuovo e il
/// Maestro non finge di ricordare.
class _AiCheGuardaLaStoria implements MaestroAiProvider {
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

  List<ChatMessage> ultimaStoria = const [];
  MaestroMemory? lastMemory;
  UserProfile? lastProfile;
  int distills = 0;

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
    ultimaStoria = history;
    lastMemory = memory;
    lastProfile = profile;
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
  }) async {
    return const MaestroReply(
      glance: 'Un colpo d\'occhio.',
      reading: 'Il testo narrato.',
      invite: 'Un invito.',
    );
  }

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
  }) async {
    distills++;
    return const MemoryDigest(
      summary: 'Avete parlato del lavoro.',
      facts: ['Cerca chiarezza sul lavoro'],
    );
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  final adesso = DateTime(2026, 10, 6, 12);

  Future<_AiCheGuardaLaStoria> apriDopo(Duration trascorso,
      {int battute = 2}) async {
    final repo = InMemoryMaestroMemoryRepository();
    await repo
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 1, 1)));
    final quando = adesso.subtract(trascorso);
    for (var i = 0; i < battute; i++) {
      await repo.appendMessage(
          Maestro.medora,
          ChatMessage(
            role: i.isEven ? ChatRole.user : ChatRole.maestro,
            text: i == 0
                ? 'Quando riceverò una promozione?'
                : 'Battuta di prima numero $i.',
            at: quando.subtract(Duration(seconds: battute - i)),
            conversazione: 'c1',
          ));
    }
    final ai = _AiCheGuardaLaStoria();
    final c = MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: repo,
      orologio: () => adesso,
      attesaMinima: Duration.zero,
      conversazioneNuova: true,
    );
    await c.init();
    expect(c.messages, isEmpty,
        reason: "ordine EA voce 06: ogni apertura e' una chat vuota");
    await c.send('E per il mese prossimo?');
    await _settle();
    return ai;
  }

  test("entro l'ora il Maestro riceve le battute di prima", () async {
    final ai = await apriDopo(const Duration(minutes: 30));
    expect(ai.ultimaStoria.map((m) => m.text),
        contains('Quando riceverò una promozione?'),
        reason: "chi torna entro l'ora deve ritrovare il suo filo");
  });

  test("il filo porta al piu' venti battute", () async {
    final ai = await apriDopo(const Duration(minutes: 30), battute: 30);
    final diPrima =
        ai.ultimaStoria.where((m) => m.text.startsWith('Battuta di prima'));
    expect(diPrima.length, lessThanOrEqualTo(20));
    expect(diPrima.length, greaterThanOrEqualTo(10));
  });

  test("oltre l'ora il consulto e' nuovo", () async {
    final ai = await apriDopo(const Duration(minutes: 61));
    expect(ai.ultimaStoria.map((m) => m.text),
        isNot(contains('Quando riceverò una promozione?')),
        reason: "oltre l'ora il Maestro non finge di ricordare");
  });
}
