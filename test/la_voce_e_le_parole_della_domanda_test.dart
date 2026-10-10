import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA PAROLA DELLA PERSONA NON E' LA FIRMA DI UN ALTRO MAESTRO.** Ordine
/// EX Aggiunta 4, voce EX.07. Al banco della qualita' (giro fine4) quattro
/// risposte su trenta si rifacevano da capo per la rete del lessico (ordine
/// EC voce 03), e nessun contatore lo diceva: chiamate in piu' senza nome.
/// Una era Calìgo che a *"una in centro piccola, una in periferia grande.
/// Quale?"* rispondeva *"la casa in centro"*: "centro" e' una parola di
/// firma di Aura, ma qui e' la parola della persona, e la casa non si puo'
/// nominare altrimenti. Padre: la prima stesura della rete, ordine EC voce
/// 03, che non guardava la domanda.
void main() {
  Future<(int, VoceSorvegliata)> chiedi(String domanda) async {
    final voce = _Voce();
    final sorvegliata =
        VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
    await sorvegliata.reply(
      maestro: Maestro.caligo,
      profile: UserProfile(),
      memory: MaestroMemory.empty,
      history: const [],
      userMessage: domanda,
      natal: NatalContext.none,
    );
    return (voce.chiamate, sorvegliata);
  }

  test('la parola che la persona ha scritto non rifa\' la risposta', () async {
    final (chiamate, voce) = await chiedi('Devo scegliere fra due offerte di '
        'casa: una in centro piccola, una in periferia grande. Quale?');
    expect(chiamate, 1, reason: '"centro" e\' la parola della persona');
    expect(voce.confusioni, 0);
  });

  test('la stessa parola non scritta dalla persona la rifa\', e si conta',
      () async {
    final (chiamate, voce) = await chiedi('Dove vado a vivere?');
    expect(chiamate, 2);
    expect(voce.confusioni, 1);
    expect(voce.paroleConfuse, ['caligo: centro']);
  });
}

class _Voce implements MaestroAiProvider {
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
    String? rispostaGiaData,
  }) async {
    chiamate++;
    return 'Le rune dicono: scegli la casa in centro.\n'
        '✦ Domani fissa la visita.';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
