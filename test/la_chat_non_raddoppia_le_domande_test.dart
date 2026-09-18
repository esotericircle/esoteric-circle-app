import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/cronologia_senza_doppioni.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/firestore_maestro_memory_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'server_fedele_della_memoria.dart';

/// Il Maestro risponde una riga fissa: qui non si misura cosa dice.
class _MaestroCheRisponde implements MaestroAiProvider {
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
    return 'Oggi la tua energia chiede una cosa sola: fermarti un momento.';
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
  }) async =>
      null;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();
}

/// **LA CHAT NON RADDOPPIA LE DOMANDE, e la cronologia riaperta nemmeno.**
/// Ordine DV, 18 settembre 2026.
///
/// Le prove della chat usavano il repository in memoria, che non ha la coda
/// verso il server: per questo il difetto non si vedeva al banco. Qui la chat
/// parla col **repository vero**, con una porta viva come nell'app e un server
/// finto che fa cio' che fa `functions/src/cerchio.ts`: `messaggio` aggiunge
/// un documento nuovo col suo tempo, `ultimoMessaggio` riscrive l'ultimo.
/// Risponde con un ritardo, come la rete, ed e' quel ritardo a far
/// sovrapporre le scritture.
///
/// Si misura cio' che il server ha scritto, non cio' che lo schermo disegna:
/// e' li' che il difetto viveva, ed e' da li' che la chat riaperta rilegge.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const uid = 'chi-tocca-le-domande-suggerite';
  final adesso = DateTime(2026, 9, 18, 10, 30);

  late FakeFirebaseFirestore db;
  late ServerFedeleDellaMemoria server;
  late _MaestroCheRisponde ai;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ArchivioDellAlba.dimenticaLaMemoria();
    db = FakeFirebaseFirestore();
    server = ServerFedeleDellaMemoria(db, uid);
    ai = _MaestroCheRisponde();
  });

  MaestroChatController chat(Maestro m) => MaestroChatController(
        maestro: m,
        ai: ai,
        memory: FirestoreMaestroMemoryRepository(
            uid: uid, firestore: db, porta: server),
        orologio: () => adesso,
        attesaMinima: Duration.zero,
        demo: false,
      );

  /// Cio' che il server ha scritto per [m], nell'ordine: `ruolo:testo`.
  Future<List<String>> scritto(Maestro m) async {
    final snap = await server.messaggiDi(m).orderBy('createdAt').get();
    return [
      for (final d in snap.docs) '${d.data()['role']}:${d.data()['text']}',
    ];
  }

  /// Le domande della persona che compaiono piu' di una volta di fila.
  List<String> doppie(List<String> righe) => [
        for (var i = 1; i < righe.length; i++)
          if (righe[i].startsWith('user:') && righe[i] == righe[i - 1])
            righe[i],
      ];

  Future<void> lasciaFinireLaCoda() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  group('LA DOMANDA ARRIVA AL SERVER UNA VOLTA SOLA', () {
    // Le domande delle catture del fondatore, ognuna col suo Maestro.
    for (final (maestro, domanda, strada) in [
      (Maestro.medora, 'Lettura generale energia oggi', 'al modello'),
      (Maestro.medora, 'Carta del giorno', 'instradamento'),
      (Maestro.caligo, 'Estrai una runa per me', 'instradamento'),
      (Maestro.caligo, 'Quale rito sostiene un mio traguardo?', 'al modello'),
      (
        Maestro.aura,
        'Il mio soffio di oggi dice: «La Luna è in Toro». '
            'Cosa mi chiede di lasciare andare?',
        'al modello'
      ),
    ]) {
      test('${maestro.displayName}, "$domanda" ($strada)', () async {
        final c = chat(maestro);
        await c.init();
        await c.send(domanda);
        await lasciaFinireLaCoda();

        final righe = await scritto(maestro);
        expect(doppie(righe), isEmpty,
            reason: 'il server ha scritto $righe: la domanda compare due '
                'volte di fila, ed e\' il difetto delle catture');
        expect(righe.where((r) => r == 'user:$domanda').length, 1,
            reason: 'il server ha scritto $righe');
        expect(righe.last.startsWith('maestro:'), isTrue,
            reason: 'dopo la domanda manca il turno del Maestro: $righe');
      });
    }
  });

  test(
      'I CONTATORI: una domanda al modello lo chiama una volta e consuma una '
      'domanda, un instradamento non chiama e non consuma', () async {
    // **Ordine DV voce 02.** Il doppione nasceva DOPO l'invio, nella coda
    // verso il server: non passava dalla generazione e non passava dal
    // contatore. Qui si misura su tutte e due le strade, col contatore vero.
    final contatore = QuestionAllowance();
    await contatore.load();
    MaestroChatController conIlContatore(Maestro m) => MaestroChatController(
          maestro: m,
          ai: ai,
          memory: FirestoreMaestroMemoryRepository(
              uid: uid, firestore: db, porta: server),
          orologio: () => adesso,
          attesaMinima: Duration.zero,
          demo: false,
          allowance: contatore,
          tier: () => Tier.free,
        );

    final medora = conIlContatore(Maestro.medora);
    await medora.init();
    await medora.send('Carta del giorno');
    await lasciaFinireLaCoda();
    expect(ai.chiamate, 0,
        reason: 'la carta del giorno e\' un instradamento: non chiama il '
            'modello');
    expect(contatore.usedToday(), 0,
        reason: 'un instradamento non consuma una domanda');

    await medora.send('Lettura generale energia oggi');
    await lasciaFinireLaCoda();
    expect(ai.chiamate, 1,
        reason: 'una domanda vera chiama il modello una volta sola, anche '
            'se la coda la scriveva due volte');
    expect(contatore.usedToday(), 1,
        reason: 'una domanda vera consuma una domanda, e una sola');
  });

  test('UN DOPPIO TOCCO produce una domanda sola, anche sugli instradamenti',
      () async {
    // Il pannello chiama l'invio e poi si chiude: due tocchi in fila sono
    // due chiamate, e sugli instradamenti niente fermava la seconda.
    final c = chat(Maestro.caligo);
    await c.init();
    final primo = c.send('Estrai una runa per me');
    final secondo = c.send('Estrai una runa per me');
    await Future.wait([primo, secondo]);
    await lasciaFinireLaCoda();

    final aSchermo = [
      for (final m in c.messages)
        if (m.isUser) m.text,
    ];
    expect(aSchermo, ['Estrai una runa per me'],
        reason: 'a schermo le domande sono $aSchermo');
    final righe = await scritto(Maestro.caligo);
    expect(righe.where((r) => r.startsWith('user:')).length, 1,
        reason: 'il server ha scritto $righe');
  });

  test('RIAPERTA LA CHAT, la cronologia non ha doppioni', () async {
    // Chiudere e riaprire l'app vuol dire un controllore nuovo che rilegge
    // dal server: e' li' che il fondatore vedeva le coppie.
    final prima = chat(Maestro.medora);
    await prima.init();
    await prima.send('Carta del giorno');
    await lasciaFinireLaCoda();
    await prima.send('Lettura generale energia oggi');
    await lasciaFinireLaCoda();

    final riaperta = chat(Maestro.medora);
    await riaperta.init();
    final domande = [
      for (final m in riaperta.messages)
        if (m.isUser) m.text,
    ];
    expect(domande, ['Carta del giorno', 'Lettura generale energia oggi'],
        reason: 'riaprendo la chat le domande sono $domande');
  });

  test(
      'I DOPPIONI GIA\' SCRITTI dal difetto si leggono una volta sola, e una '
      'domanda ripetuta davvero resta', () async {
    // Una cronologia com'e' davvero sul server di chi ha usato l'app fra
    // l'11 agosto e oggi: la domanda due volte, poi la risposta. E piu'
    // sotto una domanda ripetuta davvero, con la sua risposta in mezzo.
    var t = 0;
    Future<void> scrivi(String ruolo, String testo) =>
        server.messaggiDi(Maestro.medora).add({
          'role': ruolo,
          'text': testo,
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(
              1789600000000 + (t++) * 1000),
        });
    await scrivi('user', 'Carta del giorno');
    await scrivi('user', 'Carta del giorno');
    await scrivi('maestro', 'Oggi la tua carta e\' la Stella.');
    await scrivi('user', 'Carta del giorno');
    await scrivi('maestro', 'La tua carta di oggi resta la Stella.');

    final c = chat(Maestro.medora);
    await c.init();
    final testi = [for (final m in c.messages) '${m.role.name}:${m.text}'];
    expect(testi, [
      'user:Carta del giorno',
      'maestro:Oggi la tua carta e\' la Stella.',
      'user:Carta del giorno',
      'maestro:La tua carta di oggi resta la Stella.',
    ]);
  });

  group('IL RICONOSCITORE DEI DOPPIONI', () {
    ChatMessage u(String t, {String? c}) =>
        ChatMessage(role: ChatRole.user, text: t, conversazione: c);
    ChatMessage m(String t) => ChatMessage(role: ChatRole.maestro, text: t);

    test('toglie la domanda che ripete quella subito prima', () {
      final pulita = CronologiaSenzaDoppioni.di(
          [u('a'), u('a'), m('r'), u('b'), u('b'), u('b'), m('s')]);
      expect(pulita.map((x) => x.text), ['a', 'r', 'b', 's']);
      expect(
          CronologiaSenzaDoppioni.quanti(
              [u('a'), u('a'), m('r'), u('b'), u('b'), u('b'), m('s')]),
          3);
    });

    test('non tocca una domanda ripetuta con la risposta in mezzo', () {
      final c = [u('a'), m('r'), u('a'), m('r2')];
      expect(CronologiaSenzaDoppioni.di(c), c);
    });

    test('non unisce due conversazioni diverse', () {
      final c = [u('a', c: 'c1'), u('a', c: 'c2')];
      expect(CronologiaSenzaDoppioni.di(c), c);
    });

    test('non unisce due risposte uguali del Maestro', () {
      final c = [u('a'), m('r'), m('r')];
      expect(CronologiaSenzaDoppioni.di(c), c);
    });
  });
}
