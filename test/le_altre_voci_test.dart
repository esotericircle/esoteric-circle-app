import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:io';

import 'package:esoteric_circle/core/chat/altre_voci.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE ALTRE VOCI ENTRANO NELLA CONVERSAZIONE, e la bilancia sparisce.
///
/// **Il dato che ha fatto nascere questo file**, dal fondatore: l'icona a
/// bilancia in alto a destra, dorata, nell'intestazione di un Maestro di
/// astrologia **si legge come il segno zodiacale della Bilancia**. E portava a
/// una schermata dove la conversazione ricominciava da zero solo per sentire
/// gli altri Maestri, quando la domanda era gia' stata fatta.
void main() {
  const natal = NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');

  Future<MaestroChatController> conVoce(MaestroAiProvider voce) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: voce,
      memory: memoria,
      natal: () => natal,
    );
    await controller.init();
    return controller;
  }

  group('1a. La bilancia non e\' piu\' nell\'intestazione', () {
    // LA BILANCIA NON SI CONTROLLA PIU' QUI.
    //
    // C'era una prova che guardava DUE superfici scelte a mano. Dal 3 agosto
    // 2026 la regola vale per tutto `lib` e vive in `SimboliDelloZodiaco`, con
    // la sua prova in `simboli_dello_zodiaco_test.dart`: un elenco di due file
    // accanto a una regola che ne copre trecento e' una seconda porta, e la
    // seconda porta lascia passare proprio il terzo posto in cui il difetto
    // rinasce.

    test('E la vecchia porta non esiste piu\'', () {
      final chat = File('lib/features/maestri/chat/maestro_chat_screen.dart')
          .readAsStringSync();
      expect(chat.contains('chat_compare'), isFalse,
          reason: 'la vecchia porta portava a una schermata dove la '
              'conversazione ricominciava da zero');
    });
  });

  group('1b e 1d. Sotto quali risposte compare la riga', () {
    test('Gli altri due si ricavano, non si scrivono', () {
      for (final maestro in Maestro.values) {
        final altri = AltreVoci.altriDi(maestro);
        expect(altri.length, Maestro.values.length - 1);
        expect(altri.contains(maestro), isFalse);
        // Nell'ordine fisso del cerchio, non in quello di dichiarazione.
        expect(altri, [
          for (final m in Maestro.fixedOrder)
            if (m != maestro) m,
        ]);
      }
    });

    test('Dopo una lettura VERA la riga c\'e\'', () async {
      final voce = _VoceCheRisponde('La tua Luna in Pesci chiude un ciclo. '
          'Il ciclo torna fra sette giorni.');
      final controller = await conVoce(voce);
      await controller.send('mi sento fermo');
      expect(controller.puoiChiedereAgliAltri, isTrue);
    });

    test('Sotto un RIPIEGO la riga non c\'e\'', () async {
      // Stessa regola gia' scritta per "Vai piu' a fondo", e viene dallo
      // stesso dato del messaggio: `portaUnResponso`.
      final controller = await conVoce(_VoceMuta());
      await controller.send('mi sento fermo');
      expect(controller.messages.last.ripiego, isTrue);
      expect(controller.puoiChiedereAgliAltri, isFalse);
    });

    test('Sotto una risposta TRONCA la riga non c\'e\'', () async {
      final controller = await conVoce(_VoceTronca());
      await controller.send('mi sento fermo');
      expect(controller.puoiChiedereAgliAltri, isFalse);
    });

    test('Sotto il messaggio del LIMITE la riga non c\'e\'', () {
      // Il messaggio del limite e' una bolla dichiarata, non una lettura.
      const limite = ChatMessage(
        role: ChatRole.maestro,
        text: 'Per oggi le domande sono finite.',
        tipo: TipoDiMessaggio.limiteRaggiunto,
      );
      expect(limite.portaUnResponso, isFalse);
      expect(AltreVoci.vociNella([limite], Maestro.medora), isEmpty,
          reason: 'un messaggio di limite non e\' la voce di un Maestro');
    });
  });

  // **IL GRUPPO 1c E' STATO TOLTO IL 5 agosto 2026, e va detto perche'.**
  //
  // Provava che le altre voci arrivassero NELLA STESSA conversazione: due
  // bolle nuove sotto, ognuna col suo autore. Il fondatore ha visto cosa
  // significava sul telefono, cioe' la chat di Medora piena di bolle rosse di
  // Caligo e verdi di Aura, e ha deciso il contrario: nella chat di un Maestro
  // parla soltanto quel Maestro, e le altre voci si ascoltano nel Consiglio
  // del Cerchio.
  //
  // Cio' che quel gruppo proteggeva e che vale ancora e' provato altrove:
  // che a un messaggio appartenga CHI l'ha detto sta in `chat_message`, e che
  // nessun punto aggiunga a una chat il turno di un altro Maestro sta in
  // `una_porta_per_il_confronto_test.dart`, che scandisce tutto lib.

  group('1e. La sintesi si raggiunge solo quando c\'e\' da sintetizzare', () {
    test('Con una voce sola, no. Con due, si\'', () async {
      final voce = _VoceCheRisponde(
          'La tua Luna in Pesci chiude un ciclo. Torna presto.');
      final controller = await conVoce(voce);
      await controller.send('mi sento fermo');
      expect(controller.vociDelCerchio.length, 1);
      expect(
        AltreVoci.siPuoSintetizzare(controller.messages, Maestro.medora),
        isFalse,
        reason: 'mettere a confronto una voce sola con se stessa non e\' un '
            'confronto, e la schermata che lo faceva si raggiungeva sempre',
      );

      // NON si arriva piu' a due voci dentro la chat: dal 5 agosto 2026 le
      // altre voci si ascoltano nel Consiglio. La regola qui resta la sua,
      // cioe' che una voce sola non e' un confronto, e si prova sul DATO
      // invece che sul giro completo.
      final conDue = [
        ...controller.messages,
        ChatMessage(
          role: ChatRole.maestro,
          text: 'La tua Luna in Pesci chiude un ciclo. Torna presto.',
          autore: AltreVoci.altriDi(Maestro.medora).first,
        ),
      ];
      expect(AltreVoci.siPuoSintetizzare(conDue, Maestro.medora), isTrue);
    });

    test('Due ripieghi non sono due voci', () async {
      final controller = await conVoce(_VoceMuta());
      await controller.send('mi sento fermo');
      await controller.send('e adesso');
      expect(
        AltreVoci.siPuoSintetizzare(controller.messages, Maestro.medora),
        isFalse,
        reason: 'un ripiego lo scrive l\'app, non il Maestro',
      );
    });
  });

  group('1e. La risposta di chat si legge nei tre strati', () {
    test('Con tre frasi: colpo d\'occhio, lettura, chiusura', () {
      final tre = AltreVoci.treStratiDa(
          'Un velo di Luna nuova ti avvolge. La tua Luna in Pesci sente due '
          'volte. Il ciclo si chiude fra sette giorni.');
      expect(tre.glance, 'Un velo di Luna nuova ti avvolge.');
      expect(tre.reading, 'La tua Luna in Pesci sente due volte.');
      expect(tre.invite, 'Il ciclo si chiude fra sette giorni.',
          reason: 'l\'ultima frase e\' la CHIUSURA del Maestro, che la sua '
              'persona gli chiede gia\' di mettere li\'');
    });

    test('Uno strato vuoto e\' peggio di uno strato in meno', () {
      // A video una riga bianca e una freccia senza niente accanto: si e'
      // vista nell'anteprima del 3 agosto 2026.
      final due =
          AltreVoci.treStratiDa('Le stelle ti ascoltano. Dimmi ancora.');
      expect(due.glance, 'Le stelle ti ascoltano.');
      expect(due.reading, 'Dimmi ancora.');
      expect(due.invite, isEmpty);

      final una = AltreVoci.treStratiDa('Le stelle ti ascoltano.');
      expect(una.glance, isEmpty);
      expect(una.reading, 'Le stelle ti ascoltano.');
      expect(una.invite, isEmpty);
    });

    test('Non si perde niente per strada', () {
      const testo = 'Prima. Seconda. Terza. Quarta.';
      final strati = AltreVoci.treStratiDa(testo);
      expect('${strati.glance} ${strati.reading} ${strati.invite}', testo);
    });
  });

  group('1f. Il gating resta quello di oggi', () {
    test('Il confronto passa dallo stesso canCompare di prima', () {
      // Non si allarga ne' si stringe: la chat chiede al contatore la stessa
      // cosa che gli chiedeva la schermata del confronto.
      final chat = File('lib/features/maestri/chat/maestro_chat_screen.dart')
          .readAsStringSync();
      expect(chat.contains('canCompare('), isTrue,
          reason: 'senza questa riga le altre voci sarebbero gratis per tutti, '
              'cioe'
              ' il gating si sarebbe allargato in silenzio');
    });

    // **LA PROVA SUL LIMITE E' STATA TOLTA IL 5 agosto 2026.** Verificava che
    // chiedere agli altri dentro la chat non intaccasse le domande del
    // giorno. Dentro la chat non si chiede piu' agli altri: si apre il
    // Consiglio, e li' il limite lo controlla `canCompare` come prima.
  });
}

/// Una voce che risponde, e RICORDA che cosa le e' stato passato.
class _VoceCheRisponde implements MaestroAiProvider {
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

  _VoceCheRisponde(this.testo);

  final String testo;
  int chiamate = 0;

  /// Con chi questa voce tace, per costruire uno stato parziale.
  Maestro? taceCon;

  /// Quanti messaggi di storia ha ricevuto a ogni chiamata.
  final List<int> storieViste = [];

  /// Quale domanda ha ricevuto a ogni chiamata.
  final List<String> domandeViste = [];

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
    if (maestro == taceCon) throw const MaestroAiUnavailable('tace');
    chiamate++;
    storieViste.add(history.length);
    domandeViste.add(userMessage);
    return testo;
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

class _VoceMuta extends _VoceCheRisponde {
  _VoceMuta() : super('');

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
      throw const MaestroAiUnavailable('la voce tace');
}

class _VoceTronca extends _VoceCheRisponde {
  _VoceTronca() : super('');

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
      throw const MaestroAiTroncata();
}
