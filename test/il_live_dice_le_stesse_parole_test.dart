// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/features/maestri/live/il_parlato_del_maestro.dart';
import 'package:esoteric_circle/features/maestri/live/le_tre_frasi_del_live.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **NEL LIVE LA VOCE, IL VIDEO E LA CHAT DICONO LE STESSE PAROLE; QUATTRO
/// FRASI QUANDO LA DOMANDA HA PIU' PARTI.** Ordine ET voci 02 e 06, 28
/// settembre 2026.
///
/// Il fondatore: *"la trascrizione nella chat era diversa e più corta"*; e,
/// sulla ER.12, *"quattro frasi quando la domanda ha più parti"*. Prima la
/// voce e il video dicevano il taglio a tre frasi e la chat salvava la
/// risposta intera; il taglio a tre perdeva la parte di una domanda con piu'
/// parti.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ET.06: le domande con piu\' parti, sulle domande vere', () {
    const conPiuParti = [
      // Dal banco della ER.12: un fatto e poi la domanda, piu' domande,
      // piu' desideri.
      'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei '
          'avessi successo col lavoro che sto facendo.',
      'Mia madre dice che è una follia partire. Cosa le rispondo?',
      'Il mio capo non mi dà mai un riconoscimento. Come glielo chiedo?',
      'Ho scelto: parto a marzo. E adesso?',
      // Dal banco delle trenta domande.
      'Gli piaccio? Mi guarda sempre ma non mi dice niente.',
    ];
    const conUnaParte = [
      'Da dove comincio, dal lavoro o dal viaggio?',
      'Ho paura che in Australia mi senta solo.',
      'Grazie. Cosa faccio domani mattina, appena sveglio?',
      'Lui mi ama davvero?',
      'Devo scrivergli io o aspettare che si faccia vivo lui?',
      'Sono innamorata di due persone: chi devo scegliere?',
      'Mia madre non accetta la persona che amo: come faccio?',
    ];
    for (final d in conPiuParti) {
      expect(LeTreFrasiDelLive.haPiuParti(d), isTrue, reason: d);
    }
    for (final d in conUnaParte) {
      expect(LeTreFrasiDelLive.haPiuParti(d), isFalse, reason: d);
    }
  });

  test('ET.06: tre frasi a una parte, quattro a piu\' parti, mai a meta\'', () {
    const lunga = 'Uno uno. Due due. Tre tre. Quattro quattro. Cinque cinque.'
        '\n✦ Il gesto di stasera.';
    const unaParte = 'Lui mi ama davvero?';
    const piuParti = 'Mia madre dice che è una follia partire. Cosa le '
        'rispondo?';
    final tre = LeTreFrasiDelLive.frasiDi(
        LeTreFrasiDelLive.di(lunga, domanda: unaParte));
    final quattro = LeTreFrasiDelLive.frasiDi(
        LeTreFrasiDelLive.di(lunga, domanda: piuParti));
    expect(tre, ['Uno uno.', 'Due due.', 'Il gesto di stasera.']);
    expect(
        quattro, ['Uno uno.', 'Due due.', 'Tre tre.', 'Il gesto di stasera.']);
  });

  test(
      'ET.02: la forma scritta dice le stesse parole della voce, sulle '
      'risposte vere del LIVE', () {
    final cartella = Directory('docs/collaudo/EQ/eq03/dopo_seconda_stesura');
    final risposte = <(String, String)>[];
    for (final f in cartella.listSync().whereType<File>()) {
      if (!f.path.contains('LIVE_con_Flash_giro')) continue;
      String? domanda;
      final righe = <String>[];
      for (final r in [...f.readAsLinesSync(), '## fine']) {
        final t = RegExp(r'^## \d+\. (.*)$').firstMatch(r);
        if (r.startsWith('## ') && domanda != null) {
          risposte.add((domanda, righe.join('\n').trim()));
          righe.clear();
        }
        if (t != null) domanda = t.group(1);
        if (r.startsWith('>')) righe.add(r.replaceFirst(RegExp(r'^>\s?'), ''));
      }
    }
    cardinaleMinimo(risposte.length, 72,
        cosa: 'risposte vere del LIVE con Flash',
        perche: 'le dodici domande per tre Maestri in due giri dell\'ordine '
            'EQ voce 03');
    final diverse = <String>[];
    for (final (d, r) in risposte) {
      final voce = LeTreFrasiDelLive.di(r, domanda: d);
      final chat = LeTreFrasiDelLive.scritta(r, domanda: d);
      if (IlParlatoDelMaestro.daDire(chat) != voce) diverse.add(d);
    }
    print('ORDINE ET VOCE 2: risposte vere ${risposte.length}, chat diversa '
        'dalla voce ${diverse.length}');
    expect(diverse, isEmpty, reason: diverse.take(3).join('; '));
  });

  test('ET.02: nel LIVE la chat salva le frasi che il Maestro dice', () async {
    const intera = 'Le carte dicono di sì: ti pensa, anche se tace. Il Fante '
        'di Coppe parla di un sentimento timido. La Luna in Ariete spinge a '
        'muoversi. Il tuo cielo chiede pazienza. Non forzare i tempi.\n✦ '
        'Stasera scrivigli due righe semplici.';
    for (final live in [false, true]) {
      final c = MaestroChatController(
        maestro: Maestro.medora,
        ai: _UnaRisposta(intera),
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      )..nelLive = live;
      await c.init();
      const domanda = 'Lui mi ama davvero?';
      await c.send(domanda);
      final salvata = c.messages.last.text;
      final detta = LeTreFrasiDelLive.di(salvata, domanda: domanda);
      print('ORDINE ET VOCE 2 ${live ? 'LIVE' : 'chat'}: salvata «$salvata»');
      if (live) {
        expect(IlParlatoDelMaestro.daDire(salvata), detta,
            reason: 'nel LIVE la chat salva parole diverse da quelle dette');
        expect(LeTreFrasiDelLive.frasiDi(IlParlatoDelMaestro.daDire(salvata)),
            hasLength(3));
      } else {
        expect(salvata, contains('Non forzare i tempi.'),
            reason: 'nella chat scritta la risposta resta intera');
      }
    }
  });
}

class _UnaRisposta implements MaestroAiProvider {
  _UnaRisposta(this.testo);
  final String testo;

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
      testo;

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
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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
  }) async =>
      null;
}
