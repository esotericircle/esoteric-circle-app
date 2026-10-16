// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **UN RIFIUTO VALE PER TUTTA LA CONVERSAZIONE, E UN INVITO NON SI RIPETE.**
/// Ordine EB voce 05, 21 settembre 2026.
///
/// **Il fatto, dalle due catture del fondatore.** Alla richiesta di
/// interpretare le carte che aveva gia', Medora ha risposto *"Le carte
/// vogliono essere viste, non raccontate. Vieni, stendiamole insieme."* con
/// il pulsante. Il fondatore ha scritto *"Ma io non voglio fare un'altra
/// stesa di tarocchi. Voglio solo la tua interpretazione"*, e ha ricevuto **la
/// stessa identica frase e lo stesso pulsante**. Parole sue: *"l'utente deve
/// avere l'illusione di parlare con una persona vera"*.
///
/// **Cosa misura.** Che dopo un rifiuto quell'arte non si riproponga piu', e
/// che lo stesso invito non compaia due volte nella stessa conversazione.
/// **In tutti e due i casi il Maestro deve RISPONDERE**, non tacere: un
/// pulsante tolto che lascia il vuoto non e' una cura.
void main() {
  test('dopo un rifiuto quell\'arte non si ripropone, e il Maestro risponde',
      () async {
    final ai = _AiCheConta();
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
    );
    await controller.init();

    // Le due frasi vere delle catture, in ordine.
    await controller.send('Nella mia stesa sono uscite Il Papa, Re di Spade e '
        'Dieci di Spade. Come si legge questa sequenza sulla mia situazione?');
    await controller.send('Ma io non voglio fare un\'altra stesa di tarocchi. '
        'Voglio solo la tua interpretazione');
    // E poi la persona la nomina di nuovo, questa volta chiedendola.
    await controller.send('fammi una stesa di tarocchi');

    final inviti = controller.messages
        .where((m) => m.intentId == ImmersiveTarget.tarocchiStesa.name)
        .length;
    print('ORDINE EB VOCE 05: inviti alla Stesa $inviti, '
        'chiamate al modello ${ai.quante}');
    expect(inviti, 0,
        reason: 'la Stesa e\' stata riproposta dopo che la persona l\'aveva '
            'rifiutata');
    expect(ai.quante, 3,
        reason: 'il Maestro non ha risposto a tutte e tre: un pulsante tolto '
            'che lascia il vuoto non e\' una cura');
  });

  test('lo stesso invito non compare due volte nella stessa conversazione',
      () async {
    final ai = _AiCheConta();
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
    );
    await controller.init();

    await controller.send('fammi una stesa di tarocchi');
    await controller.send('fammi una stesa di tarocchi');

    final inviti = controller.messages
        .where((m) => m.intentId == ImmersiveTarget.tarocchiStesa.name)
        .length;
    print('ORDINE EB VOCE 05, due richieste uguali: inviti $inviti, '
        'chiamate al modello ${ai.quante}');
    expect(inviti, 1,
        reason: 'l\'invito si e\' ripetuto identico: e\' il momento esatto in '
            'cui una persona capisce di parlare con una macchina');
    expect(ai.quante, 1,
        reason: 'alla seconda richiesta il Maestro deve rispondere, non '
            'tacere');
  });

  _laMossaSette();
}

/// **LA MOSSA 7 DEL CATALOGO: un messaggio vuoto non parte.** Ordine EB voce
/// 07. Sta qui e non nella prova del catalogo perche' qui il Maestro finto
/// c'e' gia', e una seconda copia di settanta righe sarebbe due copie che un
/// giorno divergono.
void _laMossaSette() {
  test('un messaggio vuoto non parte, e non costa niente', () async {
    final ai = _AiCheConta();
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
    );
    await controller.init();
    final prima = controller.messages.length;

    await controller.send('');
    await controller.send('   ');
    await controller.send('\n\t ');

    print('ORDINE EB VOCE 07, mossa 7: messaggi prima $prima, dopo '
        '${controller.messages.length}, chiamate al modello ${ai.quante}');
    expect(controller.messages.length, prima,
        reason: 'un messaggio vuoto e\' finito nella conversazione');
    expect(ai.quante, 0,
        reason: 'un messaggio vuoto ha chiamato il modello, e un modello '
            'chiamato a vuoto e\' una domanda pagata per niente');
  });
}

/// Un modello finto che conta quante volte lo chiamano. E' la stessa
/// finta di `intent_routing_test.dart`, col contatore rinominato.
class _AiCheConta implements MaestroAiProvider {
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

  int quante = 0;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<dynamic> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    quante++;
    // Ogni chiamata risponde diverso, come il modello vero a temperatura
    // alta: e' cosi' che due letture dello stesso giorno si smentivano.
    return 'Una risposta a testo, la numero $quante.';
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
    required List<dynamic> history,
  }) async =>
      null;
}
