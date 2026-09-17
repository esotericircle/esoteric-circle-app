import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/intent_classifier.dart';
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

/// Instradamento della chat verso le funzioni immersive: un classificatore
/// deterministico riconosce l'intento e il Maestro invita ad aprire la funzione,
/// senza chiamare l'AI.
void main() {
  const classifier = IntentClassifier();

  group('Classificatore d\'intento', () {
    test('Riconosce gli intenti immersivi per Maestro', () {
      expect(
          classifier
              .classify(Maestro.medora, 'fammi una stesa di tarocchi')
              ?.target,
          ImmersiveTarget.tarocchiStesa);
      expect(
          classifier
              .classify(Maestro.medora, 'mostrami la mia carta natale')
              ?.target,
          ImmersiveTarget.cartaNatale);
      expect(
          classifier
              .classify(Maestro.medora, 'voglio l\'oroscopo di oggi')
              ?.target,
          ImmersiveTarget.oroscopoGiorno);
      expect(
          classifier
              .classify(Maestro.aura, 'guidami in una meditazione')
              ?.target,
          ImmersiveTarget.meditazione);
      expect(
          classifier.classify(Maestro.aura, 'parlami dei miei chakra')?.target,
          ImmersiveTarget.scanChakra);
      expect(
          classifier.classify(Maestro.caligo, 'lancia le rune per me')?.target,
          ImmersiveTarget.lancioRune);
      expect(
          classifier.classify(Maestro.caligo, 'consultiamo l\'i-ching')?.target,
          ImmersiveTarget.iChing);
    });

    test('L\'allow-list e per Maestro: le rune non scattano per Medora', () {
      expect(classifier.classify(Maestro.medora, 'lancia le rune'), isNull);
      expect(classifier.classify(Maestro.caligo, 'stesa di tarocchi'), isNull);
    });

    test('Una domanda normale del dominio non instrada', () {
      expect(
          classifier.classify(Maestro.medora, 'cosa significa la mia Venere?'),
          isNull);
      expect(classifier.classify(Maestro.aura, 'perché mi sento agitato oggi?'),
          isNull);
    });

    test('La chiave scatta solo come parola intera', () {
      // "rune" dentro "prune" non deve attivare l'intento.
      expect(
          classifier.classify(Maestro.caligo, 'le prune sono buone'), isNull);
    });
  });

  group('Instradamento in chat', () {
    test('Un intento immersivo invita senza chiamare l\'AI', () async {
      final ai = _RecordingAi();
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
      );
      await controller.init();

      await controller.send('puoi farmi una stesa di tarocchi?');

      // Ultimo messaggio: l'invito del Maestro con il pulsante immersivo.
      final last = controller.messages.last;
      expect(last.isMaestro, isTrue);
      expect(last.intentId, ImmersiveTarget.tarocchiStesa.name);
      expect(last.text, contains('stendiamole'));
      // L'AI non e' stata chiamata.
      expect(ai.replies, 0);
    });

    // **LA CARTA DEL GIORNO CONSEGNA UNA CARTA. Ordine DS voce 08.**
    //
    // Sulle catture di un fondatore, *"Carta del giorno"* due volte, e due
    // volte il modello parlava di Saturno e della Luna senza nominare nessun
    // arcano. La carta non la sceglie il modello.
    //
    // **E DALL'ORDINE DT VOCE 25 E' L'ARCANO DELL'ALBA DI OGGI**, col suo
    // verso: la sola estrazione del giorno per quella persona, letta dal suo
    // archivio. Se la carta non e' stata girata, la chat non ne estrae una
    // seconda.
    for (final domanda in const [
      'Carta del giorno',
      'Tira una carta per me',
      'qual e la mia carta di oggi?',
    ]) {
      test(
          '"$domanda": estratto l\'Arcano dell\'Alba, la chat nomina la stessa '
          'carta e lo stesso verso, senza chiamare il modello', () async {
        SharedPreferences.setMockInitialValues({});
        ArchivioDellAlba.dimenticaLaMemoria();
        final oggi = DateTime(2026, 9, 17, 9, 21);
        final alba = await ArchivioDellAlba.estraiOggi(oggi,
            caso: Random(domanda.length));
        final ai = _RecordingAi();
        final controller = MaestroChatController(
          maestro: Maestro.medora,
          ai: ai,
          memory: InMemoryMaestroMemoryRepository(),
          orologio: () => oggi,
        );
        await controller.init();
        await controller.send(domanda);
        final last = controller.messages.last;
        final attesa = ResponsoDellAlba.cartaColVerso(alba.stato);
        expect(last.isMaestro, isTrue);
        expect(last.text, contains(attesa),
            reason: 'la chat dice "${last.text}" e l\'Arcano dell\'Alba di '
                'oggi e\' $attesa');
        expect(last.intentId, ImmersiveTarget.arcanoDellAlba.name,
            reason: 'sotto la carta manca il pulsante che la apre');
        expect(ai.replies, 0,
            reason: 'la carta del giorno e passata dal modello, che la '
                'inventerebbe');
      });
    }

    test('senza la carta girata la chat non ne estrae una seconda', () async {
      SharedPreferences.setMockInitialValues({});
      ArchivioDellAlba.dimenticaLaMemoria();
      final oggi = DateTime(2026, 9, 17, 9, 21);
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: _RecordingAi(),
        memory: InMemoryMaestroMemoryRepository(),
        orologio: () => oggi,
      );
      await controller.init();
      await controller.send('Carta del giorno');
      expect(controller.messages.last.text, contains('ancora coperta'));
      expect(await ArchivioDellAlba.diOggi(oggi), isNull,
          reason: 'chiedere la carta in chat ha estratto la carta del dono');
    });

    // **LA STESSA DOMANDA NELLO STESSO GIORNO DA' LA STESSA LETTURA. Ordine
    // DS voce 08.** Sulle catture di un fondatore la stessa domanda a due
    // minuti di distanza dava *"il cielo si vela di un'ombra sottile"* e
    // *"una luce inattesa filtra tra le nubi"*. La regola sta nel briefing
    // operativo, sezione 15: la stessa domanda nello stesso giorno da' lo
    // stesso responso, e cambia il giorno dopo.
    test('la stessa domanda tre volte nello stesso giorno: una lettura sola',
        () async {
      final ai = _RecordingAi();
      var adesso = DateTime(2026, 9, 17, 0, 21);
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
        orologio: () => adesso,
        attesaMinima: Duration.zero,
      );
      await controller.init();
      final risposte = <String>[];
      for (final domanda in const [
        'Cosa mi dice il cielo oggi sul lavoro?',
        'cosa mi dice il cielo oggi sul lavoro',
        'Cosa mi dice il cielo, oggi, sul lavoro?!',
      ]) {
        await controller.send(domanda);
        risposte.add(controller.messages.last.text);
        adesso = adesso.add(const Duration(minutes: 2));
      }
      expect(ai.replies, 1,
          reason: 'la stessa domanda nello stesso giorno e tornata al modello '
              '${ai.replies} volte: ogni volta una lettura nuova');
      final prima = risposte.first;
      for (final r in risposte.skip(1)) {
        expect(r, contains(prima),
            reason: 'la lettura ripetuta non e la lettura data: "$r"');
      }
      // **E IL GIORNO DOPO LA LETTURA CAMBIA**, perche' il cielo e' un altro.
      adesso = DateTime(2026, 9, 18, 9);
      await controller.send('Cosa mi dice il cielo oggi sul lavoro?');
      expect(ai.replies, 2,
          reason: 'il giorno dopo la stessa domanda deve avere una lettura '
              'nuova: il cielo e cambiato');
    });

    // **IL CIELO DETTO DAL MODELLO SI CONTROLLA COL CALCOLO. Ordine DS voce
    // 08.** Il 17 settembre 2026 la Luna entra in Capricorno il 19: un
    // modello che dice "domani" dice il falso, e la frase non arriva.
    test('una frase sul cielo smentita dal calcolo non arriva a schermo',
        () async {
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: _CieloSbagliato(),
        memory: InMemoryMaestroMemoryRepository(),
        orologio: () => DateTime(2026, 9, 17, 0, 21),
        attesaMinima: Duration.zero,
      );
      await controller.init();
      await controller.send('Come si muove la Luna in questi giorni?');
      final testo = controller.messages.last.text;
      expect(testo, isNot(contains('Domani la Luna entra in Capricorno')),
          reason:
              'la frase smentita dal calcolo e arrivata a schermo: "$testo"');
      expect(testo, contains('La tua Luna chiede ascolto.'),
          reason: 'togliendo la frase sbagliata e sparito anche il resto');
      expect(controller.frasiDelCieloSmentite, 1);
    });

    test('Una domanda normale chiama l\'AI come sempre', () async {
      final ai = _RecordingAi();
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
      );
      await controller.init();

      await controller.send('cosa significa la mia Venere?');
      expect(ai.replies, 1);
      expect(controller.messages.last.intentId, isNull);
    });
  });
}

/// Un modello che sbaglia il giorno di un ingresso della Luna.
class _CieloSbagliato extends _RecordingAi {
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
    replies++;
    return 'La tua Luna chiede ascolto. Domani la Luna entra in Capricorno. '
        'Tieni il passo lento.';
  }
}

/// Provider AI che conta le chiamate, per provare che l'instradamento non
/// tocca l'AI.
class _RecordingAi implements MaestroAiProvider {
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

  int replies = 0;

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
    replies++;
    // Ogni chiamata risponde diverso, come il modello vero a temperatura
    // alta: e' cosi' che due letture dello stesso giorno si smentivano.
    return 'Una risposta a testo, la numero $replies.';
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
