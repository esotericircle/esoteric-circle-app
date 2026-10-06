import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/la_rete_della_coerenza.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_diario_finto.dart';

/// **LA RIGA DELLA PERSONA NON PARTE VERSO NESSUN MODELLO. Ordine FE voce
/// 22.10, prova g).**
///
/// Il fondatore: *"la riga dell'utente resta con la voce e non viene mandata
/// a nessun modello, dimostrato con la misura di cosa parte nella
/// chiamata"*. La guardia sui sorgenti (`il_diario_cosmico_sul_server_test`,
/// g) guarda dove la riga puo' andare; questa misura cosa parte davvero:
/// una conversazione con la stella e la riga, un turno vero del controllore
/// della chat in un consulto dove ha gia' parlato un altro Maestro (cosi'
/// parte anche la rete della coerenza), e ogni testo che arriva alla porta
/// del modello, raccolto e cercato.
void main() {
  // Oltre gli 80 caratteri: la rete legge le frasi del consulto da 80 in
  // su, e una riga corta non arriverebbe al modello nemmeno col difetto.
  const riga = 'La rileggo ogni volta che penso a mia nonna Teresa, che mi '
      'diceva di non avere paura di chiedere quello che mi spetta';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
  });

  test('g) FE.22.10: nella chiamata al modello la riga non c\'e\'', () async {
    final diario = PortaFintaDelDiario();
    final registro = RegistroDeiRicordi(porta: diario);
    final voce = laConversazione(Maestro.caligo,
        id: 'c1',
        titolo: 'Devo chiedere la promozione?',
        quando: DateTime(2026, 10, 6, 9));
    diario.metti(voce);
    await registro.ripesca(voce.mese);
    await registro.mettiLaStella(voce, true, nota: riga);

    // Un altro Maestro ha gia' parlato: la rete della coerenza parte.
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Devo chiedere la promozione?',
        risposta: 'Il cielo ti chiede di preparare con calma gli argomenti. '
            'Prima di parlare col tuo responsabile aspetta il novilunio.\n\n'
            '✦ Scrivi su un foglio i tre risultati di quest\'anno.');

    final ai = _LaPortaCheRaccoglie();
    final chat = MaestroChatController(
      maestro: Maestro.caligo,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      attesaMinima: Duration.zero,
      segnaNeiRicordi: (d) => registro.toccaLaConversazione(
          maestro: 'caligo',
          conversazione: d.conversazione,
          tema: d.text,
          quando: d.at ?? DateTime.now()),
    );
    await chat.init();
    await chat.apriLaConversazione('c1');
    await chat.send('Devo chiedere la promozione?');
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    final partiti = ai.testi.join('\n');
    final volte = riga.allMatches(partiti).length;
    // ignore: avoid_print
    print('FE.22.10 MISURA: chiamate al modello ${ai.chiamate}, di cui alla '
        'rete ${ai.allaRete}; caratteri partiti ${partiti.length}; '
        'occorrenze della riga della persona $volte; la riga e\' andata al '
        'server con la stella ${diario.chiamate.where((c) => c['nota'] == riga).length} '
        'volte');
    expect(ai.chiamate, greaterThanOrEqualTo(2),
        reason: 'la prova non ha fatto partire la risposta e la rete: '
            'misurerebbe una chiamata che non c\'e\'');
    expect(ai.allaRete, greaterThanOrEqualTo(1),
        reason: 'la rete della coerenza non e\' partita');
    expect(diario.chiamate.where((c) => c['nota'] == riga), isNotEmpty,
        reason: 'la riga non e\' arrivata al Diario: la prova cercherebbe '
            'una riga che non esiste');
    expect(volte, 0,
        reason: 'la riga della persona e\' partita verso il modello: '
            '${ai.testi.where((t) => t.contains(riga)).map((t) => t.length > 160 ? '${t.substring(0, 160)}...' : t).join(' | ')}');
  });
}

/// Una porta del modello che raccoglie tutto cio' che le arriva: l'istruzione
/// come la compone l'app (persona, memoria, filo), la storia, la domanda, e
/// cio' che va alla rete della coerenza.
class _LaPortaCheRaccoglie implements MaestroAiProvider, LaPortaDellaCoerenza {
  final List<String> testi = [];
  int chiamate = 0;
  int allaRete = 0;

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
    testi
      ..add(MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: profile,
          memory: memory,
          filo: IlFiloDelConsulto.bloccoPer(maestro, storia: history)))
      ..addAll([for (final m in history) m.text])
      ..add(userMessage);
    return 'Chiedila venerdì, con i tre risultati scritti davanti.\n\n'
        '✦ Scrivi la prima frase che dirai.';
  }

  @override
  Future<String?> giudicaLaCoerenza(String istruzione, String testo) async {
    chiamate++;
    allaRete++;
    testi.addAll([istruzione, testo]);
    return '{"contraddice": false, "punto": "", "perche": ""}';
  }

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    testi.addAll([for (final m in history) m.text]);
    return null;
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async =>
      throw const MaestroAiUnavailable();
}
