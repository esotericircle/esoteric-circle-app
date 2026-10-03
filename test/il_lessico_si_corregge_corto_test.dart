// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE PAROLE RISERVATE SI CORREGGONO CORTE.** Ordine EX Aggiunta 5, voce
/// EX.07. Il fondatore: *"Restano riservate, correzione corta
/// (Consigliata)"*. La rete del lessico (`LaVoceNonSiConfonde`, ordine EC
/// voce 03) rifaceva da capo la risposta che portava una parola di firma di
/// un altro Maestro: al banco della qualita' cinque risposte su ventiquattro,
/// ognuna con l'istruzione intera, la conversazione e le funzioni del cielo.
/// Adesso si corregge solo quella parola, con la correzione corta; e quando
/// un'altra rete corregge gia' la stessa risposta, la parola va nella stessa
/// correzione: una chiamata sola.
void main() {
  const domanda = 'Mi prenderanno al colloquio di giovedì?';
  const pulita = 'Le rune dicono di sì, se ti presenti puntuale. Tiwaz '
      'chiede di portare la tua fermezza dentro la prova.\n'
      '✦ Giovedì arriva dieci minuti prima.';

  Future<(MaestroChatController, VoceSorvegliata)> chiedi(
      MaestroAiProvider voce) async {
    SharedPreferences.setMockInitialValues({});
    final sorvegliata =
        VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
    final c = MaestroChatController(
      maestro: Maestro.caligo,
      ai: sorvegliata,
      memory: InMemoryMaestroMemoryRepository(),
      natal: () => NatalContext.none,
      demo: true,
      attesaMinima: Duration.zero,
    );
    await c.init();
    await c.send(domanda);
    return (c, sorvegliata);
  }

  test(
      'la parola di un altro Maestro si corregge corta, senza rifare la '
      'risposta', () async {
    final voce = _Corta(
      'Le rune dicono di sì, se ti presenti puntuale. Tiwaz chiede di '
      'portare il tuo centro dentro la prova.\n'
      '✦ Giovedì arriva dieci minuti prima.',
      pulita,
    );
    final (c, sorvegliata) = await chiedi(voce);
    print('ORDINE EX AGGIUNTA 5, EX.07: richieste intere ${voce.intere}, '
        'correzioni corte ${voce.corte.length}, correzione '
        '«${voce.corte.firstOrNull}»');
    expect(sorvegliata.confusioni, 1,
        reason: 'la rete del lessico e\' la '
            'stessa e conta la risposta scartata');
    expect(voce.intere, 1, reason: 'la risposta non si rifa\' da capo');
    expect(voce.corte, hasLength(1));
    expect(voce.corte.single, contains('"centro"'));
    // Nemmeno nel seguito: alla sonda la correzione rimetteva la parola nel
    // seguito che riscrive.
    expect(voce.corte.single, contains('nemmeno in ciò che scrivi dopo'));
    expect(c.correzioniDelLessico, 1);
    expect(c.messages.last.text, isNot(contains('centro')));
    expect(c.messages.last.text, contains('fermezza'));
  });

  test('insieme a un\'altra rete, la parola va nella stessa correzione',
      () async {
    final voce = _Corta(
      'Le rune dicono di sì, se ti presenti puntuale. Il tuo centro sarà '
      'premiato.\n'
      '✦ Giovedì arriva dieci minuti prima.',
      pulita,
    );
    final (c, _) = await chiedi(voce);
    print('ORDINE EX AGGIUNTA 5, EX.07: con la certezza, richieste intere '
        '${voce.intere}, correzioni corte ${voce.corte.length}');
    expect(voce.intere, 1);
    expect(voce.corte, hasLength(1),
        reason: 'una chiamata sola per la certezza e per la parola altrui');
    expect(voce.corte.single, contains('sarà premiato'));
    expect(voce.corte.single, contains('"centro"'));
    expect(c.lessicoNelleCorrezioni, 1);
    expect(c.correzioniDelLessico, 0);
    expect(c.messages.last.text, isNot(contains('centro')));
  });

  test(
      'se la correzione corta lascia la parola, la risposta si rifa\' '
      'intera come prima', () async {
    const confusa = 'Le rune dicono di sì, se ti presenti puntuale. Tiwaz '
        'chiede di portare il tuo centro dentro la prova.\n'
        '✦ Giovedì arriva dieci minuti prima.';
    final voce = _Corta(confusa, confusa, poi: pulita);
    final (c, _) = await chiedi(voce);
    print('ORDINE EX AGGIUNTA 5, EX.07: la corta non basta, richieste '
        'intere ${voce.intere}, correzioni corte ${voce.corte.length}');
    expect(voce.corte, hasLength(1));
    expect(voce.intere, 2, reason: 'la risposta intera, come prima');
    expect(c.lessicoAllaVecchia, 1);
    expect(c.messages.last.text, isNot(contains('centro')));
  });

  test('una voce che non sa correggere corto rifa\' la risposta come prima',
      () async {
    final voce = _Intera([
      'Le rune dicono di sì, se ti presenti puntuale. Tiwaz chiede di '
          'portare il tuo centro dentro la prova.\n'
          '✦ Giovedì arriva dieci minuti prima.',
      pulita,
    ]);
    final (c, _) = await chiedi(voce);
    expect(voce.volte, 2);
    expect(c.messages.last.text, isNot(contains('centro')));
  });
}

class _Corta implements MaestroAiProvider, LaCorrezioneCorta {
  _Corta(this.prima, this.corretta, {this.poi});
  final String prima;
  final String corretta;

  /// La risposta intera chiesta dopo la prima, se c'e'.
  final String? poi;
  int intere = 0;
  final List<String> corte = [];

  @override
  bool get isReady => true;

  @override
  bool get correggeCorto => true;

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
    intere++;
    return intere > 1 && poi != null ? poi! : prima;
  }

  @override
  Future<String> correggi({
    required Maestro maestro,
    required UserProfile profile,
    required String domanda,
    required String risposta,
    required String correzione,
    MaestroMemory memory = MaestroMemory.empty,
    bool nelLive = false,
    String? cieloDelTurno,
    bool conSeguito = false,
  }) async {
    corte.add(correzione);
    return corretta;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Intera implements MaestroAiProvider {
  _Intera(this.copione);
  final List<String> copione;
  int volte = 0;

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
      copione[(volte++).clamp(0, copione.length - 1)];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
