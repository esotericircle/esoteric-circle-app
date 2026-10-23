import 'dart:async';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/il_seguito_nascosto.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL "VAI PIÙ A FONDO" È GIÀ PRONTO QUANDO LA PERSONA TOCCA.** Ordine EX
/// Aggiunta 4, voce EX.04: *"il testo ci sia sempre già quando la persona
/// tocca"*. Al banco il modello saltava il seguito in 3 o 4 risposte su 24,
/// e il tocco chiamava (0,17 chiamate al tocco). Adesso, se il seguito non
/// arriva con la risposta, l'app lo prepara subito in sottofondo; il tocco
/// lo scopre, o aspetta quello in preparazione, senza chiamare.
const String _risposta =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.\n'
    '✦ Non decidere adesso: guarda dove ti fermi.';

const String _seguito =
    'Laguz scende dove il terreno cede: guarda in quali giorni della '
    'settimana il lavoro ti pesa di più e scrivili, perché lì sta il '
    'passaggio da preparare prima di muoverti.';

void main() {
  // La suite la spegne (`flutter_test_config.dart`): qui si riaccende.
  setUpAll(() => MaestroChatController.preparaIlSeguitoDiSerie = true);
  tearDownAll(() => MaestroChatController.preparaIlSeguitoDiSerie = false);
  Future<MaestroChatController> con(_Voce voce) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final c = MaestroChatController(
      maestro: Maestro.medora,
      ai: voce,
      memory: memoria,
      allowance: QuestionAllowance(),
      tier: () => Tier.tier3,
      natal: () => const NatalContext(sunSign: 'Cancro'),
      attesaMinima: Duration.zero,
    );
    await c.init();
    return c;
  }

  test(
      'il seguito che non arriva con la risposta si prepara, e il tocco '
      'non chiama', () async {
    final voce = _Voce();
    final c = await con(voce);
    await c.send('devo cambiare lavoro');
    // La preparazione parte da sola dopo la risposta.
    await voce.seguitoChiesto.future;
    await Future<void>.delayed(Duration.zero);
    expect(voce.seguitiChiesti, 1);
    expect(c.messages.last.seguitoNascosto, isNotNull);
    final chiamatePrimaDelTocco = voce.chiamate;
    expect(await c.approfondisci(), isTrue);
    expect(voce.chiamate, chiamatePrimaDelTocco,
        reason: 'al tocco il seguito era gia\' pronto');
    expect(c.messages.last.seguito, contains('Laguz scende'));
    expect(c.seguitiChiestiAlTocco, 0);
  });

  test('il tocco durante la preparazione la aspetta, senza chiamare', () async {
    final voce = _Voce()..trattieni = Completer<void>();
    final c = await con(voce);
    await c.send('devo cambiare lavoro');
    await voce.seguitoChiesto.future;
    final chiamatePrimaDelTocco = voce.chiamate;
    final tocco = c.approfondisci();
    voce.trattieni!.complete();
    expect(await tocco, isTrue);
    expect(voce.chiamate, chiamatePrimaDelTocco);
    expect(c.seguitiAttesi, 1);
    expect(c.seguitiChiestiAlTocco, 0);
    expect(c.messages.last.seguito, contains('Laguz scende'));
  });

  test('una risposta col suo seguito non ne prepara un altro', () async {
    final voce = _Voce()..conIlSeguito = true;
    final c = await con(voce);
    await c.send('devo cambiare lavoro');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(voce.seguitiChiesti, 0);
    expect(c.seguitiPreparati, 0);
    expect(await c.approfondisci(), isTrue);
    expect(voce.seguitiChiesti, 0);
  });

  test('uscendo dal LIVE, il seguito dell\'ultima risposta si prepara',
      () async {
    final voce = _Voce();
    final c = await con(voce);
    c.nelLive = true;
    await c.send('devo cambiare lavoro');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(voce.seguitiChiesti, 0, reason: 'nel LIVE non si prepara');
    c.nelLive = false;
    await voce.seguitoChiesto.future;
    await Future<void>.delayed(Duration.zero);
    expect(voce.seguitiChiesti, 1);
    expect(c.messages.last.seguitoNascosto, isNotNull);
  });
}

/// Una voce che risponde senza il seguito (o col seguito, a richiesta) e
/// scrive il seguito quando lo si chiede con la risposta gia' data.
class _Voce implements MaestroAiProvider {
  int chiamate = 0;
  int seguitiChiesti = 0;
  bool conIlSeguito = false;
  Completer<void>? trattieni;
  final Completer<void> seguitoChiesto = Completer<void>();

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
    if (rispostaGiaData != null) {
      seguitiChiesti++;
      if (!seguitoChiesto.isCompleted) seguitoChiesto.complete();
      if (trattieni != null) await trattieni!.future;
      return _seguito;
    }
    return conIlSeguito
        ? '$_risposta\n${IlSeguitoNascosto.segno}\n$_seguito'
        : _risposta;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
