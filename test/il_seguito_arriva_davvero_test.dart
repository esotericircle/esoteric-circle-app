import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_risposta_nel_merito.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/seguito_della_lettura.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL SEGUITO ARRIVA DAVVERO.** Ordine EQ, 27 settembre 2026.
///
/// Il fatto: sul Realme tre tocchi su "Vai più a fondo" non hanno fatto
/// niente (`docs/collaudo/EQ/realme/difetto_build_eq_vai_piu_a_fondo_non_risponde.png`).
/// Al banco col modello vero (`tool/sonda_del_seguito.dart`) il seguito
/// arrivava 1 volta su 9 tocchi, e 2 su 9 sul codice di prima dell'ordine
/// (`docs/collaudo/EQ/seguito/`): il modello riceveva come ultimo turno la
/// domanda di prima e l'istruzione del seguito sepolta sotto le regole della
/// prima risposta, rispondeva di nuovo, e il filtro buttava tutto in
/// silenzio. PROVENIENZA IGNOTA: il difetto c'era gia' prima dell'ordine EQ.
///
/// **Le guardie precedenti non lo vedevano**: `il_seguito_scende_sotto`
/// guarda il testo dell'istruzione del seguito, non che arrivi al modello e
/// dove; restava verde togliendola dall'istruzione del Maestro.
const String _breve =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.\n'
    '✦ Non decidere adesso: guarda dove ti fermi.';

void main() {
  group('L\'istruzione del seguito', () {
    final seguito = MaestroPersona.systemInstruction(
      maestro: Maestro.caligo,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
      rispostaGiaData: _breve,
    );
    final prima = MaestroPersona.systemInstruction(
      maestro: Maestro.caligo,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );

    test('e\' l\'ultima cosa che il modello legge', () {
      expect(seguito.trimRight(),
          endsWith(SeguitoDellaLettura.istruzione(_breve).trimRight()),
          reason: 'l\'istruzione del seguito sta a meta\', sotto le regole '
              'della prima risposta: il modello risponde di nuovo');
    });

    test('non porta le regole della prima risposta', () {
      expect(seguito, isNot(contains(LaRispostaNelMerito.primaDiScrivere)),
          reason: 'il controllo della prima frase chiede di rispondere alla '
              'domanda, e il seguito la riscrive da capo');
      expect(seguito, isNot(contains(ConsiglioFinale.istruzione)),
          reason: 'il seguito non scrive un consiglio nuovo');
    });

    test('e la prima risposta le porta ancora', () {
      expect(prima, contains(LaRispostaNelMerito.primaDiScrivere));
      expect(prima, contains(ConsiglioFinale.istruzione));
      expect(prima, isNot(contains('SCRIVI SOLTANTO IL SEGUITO')));
    });
  });

  group('La richiesta del tocco', () {
    test('arriva dopo la risposta gia\' data, come turno della persona',
        () async {
      final voce = _Voce();
      final chat = await _chat(voce);
      await chat.send('Da dove comincio, dal lavoro o dal viaggio?');
      await chat.approfondisci();
      expect(voce.ultimoTurno, SeguitoDellaLettura.laRichiesta,
          reason: 'il turno del seguito e\' ancora la domanda di prima');
      expect(voce.ultimaStoria.last.isMaestro, isTrue,
          reason: 'la risposta gia\' data non e\' nella storia');
      expect(voce.ultimaStoria.last.text, contains('Laguz'));
    });

    test('un seguito tutto ripetuto si chiede di nuovo, una volta', () async {
      final voce = _Voce(seguiti: [
        _breve,
        'Sotto la superficie lavora un secondo movimento, più lento, che '
            'dura da mesi.',
      ]);
      final chat = await _chat(voce);
      await chat.send('Da dove comincio?');
      final arrivato = await chat.approfondisci();
      expect(arrivato, isTrue);
      expect(chat.messages.last.approfondita, isTrue);
      expect(chat.seguitiRichiestiDiNuovo, 1);
    });

    test('e se non arriva, il tocco lo dice invece di tacere', () async {
      final voce = _Voce(seguiti: [_breve, _breve]);
      final chat = await _chat(voce);
      await chat.send('Da dove comincio?');
      final arrivato = await chat.approfondisci();
      expect(arrivato, isFalse,
          reason: 'un tocco senza seguito deve dirlo allo schermo');
      expect(chat.messages.last.approfondita, isFalse);
    });
  });

  test('la stella in coda a una riga toglie la stella, non la riga', () {
    expect(
        SeguitoDellaLettura.senzaLaRigaDelConsiglio(
            'Laguz scorre anche sotto il ghiaccio. ✦ Guarda dove ti fermi.'),
        'Laguz scorre anche sotto il ghiaccio.',
        reason: 'un seguito su una riga sola con la stella in coda spariva');
  });
}

Future<MaestroChatController> _chat(_Voce voce) async {
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

class _Voce implements MaestroAiProvider {
  _Voce({this.seguiti = const []});

  /// Cosa risponde alle chiamate del seguito, in ordine; poi un seguito buono.
  final List<String> seguiti;
  int _seguitiDati = 0;
  String? ultimoTurno;
  List<ChatMessage> ultimaStoria = const [];

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
    if (rispostaGiaData == null) return _breve;
    ultimoTurno = userMessage;
    ultimaStoria = history;
    if (_seguitiDati < seguiti.length) return seguiti[_seguitiDati++];
    return 'Sotto la superficie lavora un secondo movimento, più lento, che '
        'dura da mesi. Laguz continua a scorrere anche quando non la guardi.';
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
      const MaestroReply(glance: 'g', reading: 'r', invite: 'i');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async =>
      's';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
