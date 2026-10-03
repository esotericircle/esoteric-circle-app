import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_passo_da_non_dare.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/design_system/components/riga_del_consiglio.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA RIGA D'ORO CHE NON VA DATA.** Ordine EQ voce 01, 27 settembre 2026.
///
/// Le catture del fondatore della chat di Calìgo: la stessa riga d'oro,
/// *"Scrivi su un foglio di carta bianca tre cose che vorresti realizzare"*,
/// sotto la presentazione, sotto la domanda sull'amore e il lavoro, nel LIVE
/// dopo *"Ok, gli ho scritto adesso."* e sotto *"Ok, le ho scritte e adesso
/// cosa faccio?"*. Qui quella conversazione si rifa' com'era, con un modello
/// finto che scrive ogni volta quella riga, e si guarda che cosa arriva a
/// schermo.
void main() {
  const rigaDelleCatture =
      'Scrivi su un foglio di carta bianca tre cose che vorresti realizzare.';

  group('la regola, sui casi delle catture e dei collaudi', () {
    test('le presentazioni, e le domande vere che le somigliano', () {
      for (final d in const [
        'Ciao, chi sei? Come puoi aiutarmi?',
        'Chi sono gli altri Maestri oltre a te?',
        'E chi sono gli altri Maestri?',
        'Buonasera. Tu chi sei e cosa fai?',
        'Ciao Calìgo',
        'Medora, chi sei?',
        'Di cosa ti occupi?',
      ]) {
        expect(IlPassoDaNonDare.eUnaPresentazione(d), isTrue, reason: d);
      }
      for (final d in const [
        'Come puoi aiutarmi con il mio ex?',
        'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei '
            'avessi successo col lavoro che sto facendo.',
        'Ciao Medora, da qualche giorno mi sento inquieto e non capisco perché.',
        'Chi sei tu per dirmi cosa fare con mia madre?',
        'Ok, gli ho scritto adesso.',
      ]) {
        expect(IlPassoDaNonDare.eUnaPresentazione(d), isFalse, reason: d);
      }
    });

    test('le righe uguali o simili, tarate sulle coppie vere dei collaudi', () {
      // Dalle 1.202 coppie di righe d'oro dei collaudi EJ, EK ed EN.
      const simili = [
        (rigaDelleCatture, rigaDelleCatture),
        (
          'Scrivi su un foglio le tre cose che ti spingono al cambiamento e '
              'brucialo all\'aperto.',
          'Scrivi su un foglio tre cose che vorresti trovare nella tua nuova '
              'città.'
        ),
        (
          'Porta una mano al centro del petto e senti il tuo respiro.',
          'Poggia una mano sul tuo addome e senti il movimento del respiro.'
        ),
        (
          'Prepara un piccolo oggetto di metallo, stasera, da portare con te.',
          'Cerca un oggetto di legno, stasera e portalo con te per Ansuz.'
        ),
      ];
      const diverse = [
        (
          'Il presagio è un mutamento di soglia, un sentiero si apre.',
          'Il presagio è un periodo di stasi, non di arresto.'
        ),
        (
          'Osserva un\'immagine che ti rasserena, stasera prima di dormire.',
          'Scrivi un piccolo elenco di tre cose che ti sono riuscite bene '
              'oggi, prima di dormire.'
        ),
        (
          'Stasera, scegli tre punti chiave da esporre al tuo capo.',
          'Scegli una parola chiave per ognuno dei tre punti e ripetila prima '
              'dell\'incontro.'
        ),
        (
          'Domani sera scrivi un messaggio con le parole che hai scelto.',
          'Questa sera, rivedi il tuo messaggio e togli ogni parola che suona '
              'come una richiesta.'
        ),
      ];
      for (final (a, b) in simili) {
        expect(IlPassoDaNonDare.simili(a, b), isTrue, reason: '$a | $b');
      }
      for (final (a, b) in diverse) {
        expect(IlPassoDaNonDare.simili(a, b), isFalse, reason: '$a | $b');
      }
    });

    test('il passo appena fatto, e cio\' che non lo e\'', () {
      bool rifare(String d, String r) =>
          IlPassoDaNonDare.chiedeDiRifare(domanda: d, riga: r);
      expect(rifare('Ok, gli ho scritto adesso.', rigaDelleCatture), isTrue);
      expect(
          rifare('Ok, le ho scritte e adesso cosa faccio?', rigaDelleCatture),
          isTrue);
      expect(
          rifare('Ho appena acceso una candela come mi hai detto.',
              'Accendi una candela bianca e guardala per un minuto.'),
          isTrue);
      expect(rifare('L\'ho chiamata ieri sera.', 'Chiamala domani mattina.'),
          isTrue);
      // Parla del Maestro, non di cio' che la persona ha fatto.
      expect(
          rifare(
              'Mi hai detto di scrivergli, ma non so cosa.', rigaDelleCatture),
          isFalse);
      // Fare non conta: il passo nuovo e' un altro.
      expect(
          rifare('Ho fatto quello che mi hai detto.',
              'Fai tre respiri lenti prima di rispondergli.'),
          isFalse);
      expect(rifare('Ho acceso una candela.', rigaDelleCatture), isFalse);
    });
  });

  group('il controller, sulla conversazione delle catture', () {
    test('la riga arriva una volta sola, e mai sotto la presentazione',
        () async {
      final ai = _SempreLaStessaRiga('✦ $rigaDelleCatture');
      final c = MaestroChatController(
        maestro: Maestro.caligo,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      );
      await c.init();
      final righe = <String?>[];
      for (final (domanda, live) in const [
        ('Ciao, chi sei? Come puoi aiutarmi?', false),
        (
          'Beh, vorrei avere una compagna, vorrei andare in Australia e '
              'vorrei avessi successo col lavoro che sto facendo.',
          false
        ),
        ('Ok, gli ho scritto adesso.', true),
        ('Ok, le ho scritte e adesso cosa faccio?', false),
      ]) {
        c.nelLive = live;
        await c.send(domanda);
        final ultima = c.messages.last;
        expect(ultima.isMaestro, isTrue);
        expect(ultima.text.trim(), isNotEmpty);
        righe.add(ConsiglioFinale.sintesiDa(ultima.text));
      }
      // ignore: avoid_print
      print('EQ.01 MISURA: righe d\'oro arrivate $righe, tolte '
          '${c.righeDOroTolte}');
      expect(righe, [null, rigaDelleCatture, null, null],
          reason: 'la riga delle catture arriva dove non deve');
      expect(c.righeDOroTolte, 3);
    });

    test('nel LIVE la riga non compare mentre il testo arriva', () async {
      final ai = _SempreLaStessaRiga('✦ $rigaDelleCatture');
      final c = MaestroChatController(
        maestro: Maestro.caligo,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      )..nelLive = true;
      await c.init();
      final visti = <String>[];
      c.testoInArrivo.addListener(() => visti.add(c.testoInArrivo.value));
      await c.send('Ok, gli ho scritto adesso.');
      expect(visti, isNotEmpty, reason: 'il testo non e\' arrivato a pezzi');
      expect(visti.where((v) => v.contains('foglio')), isEmpty,
          reason: 'la riga tolta dalle reti e\' passata a video mentre '
              'arrivava: $visti');
      expect(visti.last, contains('Hai fatto un passo'));
    });
  });

  group('la risposta fatta della sola riga da togliere', () {
    // **DAL COLLAUDO CON GEMINI VERO**: nel LIVE, a "Ok, gli ho scritto
    // adesso.", Aura ha risposto con la sola riga d'oro della risposta
    // prima. La regola la lasciava, perche' togliendola non restava niente.
    Future<MaestroChatController> dueTurni(List<String> copione) async {
      final c = MaestroChatController(
        maestro: Maestro.aura,
        ai: _ColCopione(copione),
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      );
      await c.init();
      await c.send('Vorrei cambiare lavoro, cosa faccio?');
      c.nelLive = true;
      await c.send('Ok, gli ho scritto adesso.');
      return c;
    }

    test('si chiede di nuovo, una volta, e arriva la risposta nuova', () async {
      final c = await dueTurni([
        'Parti dal corpo prima che dalla testa: la scelta si sente.\n'
            '✦ $rigaDelleCatture',
        '✦ $rigaDelleCatture',
        'Hai fatto un passo: adesso aspetta la sua risposta senza '
            'aggiungere altro.\n'
            '✦ Stasera rileggi il suo ultimo messaggio ad alta voce.',
      ]);
      final ultima = c.messages.last;
      // ignore: avoid_print
      print('EQ.01 MISURA, sola riga: richieste di nuovo '
          '${c.rigenerazioniPerRigaDOro}, a schermo "${ultima.text}"');
      expect(c.rigenerazioniPerRigaDOro, 1);
      expect(ultima.ripiego, isFalse);
      expect(ultima.text, contains('Hai fatto un passo'));
      expect(ultima.text, isNot(contains(rigaDelleCatture)));
    });

    test(
        'se anche la seconda e\' solo la riga, arriva il ripiego e mai la '
        'riga', () async {
      final c = await dueTurni([
        'Parti dal corpo prima che dalla testa: la scelta si sente.\n'
            '✦ $rigaDelleCatture',
        '✦ $rigaDelleCatture',
        '✦ $rigaDelleCatture',
      ]);
      final ultima = c.messages.last;
      expect(c.rigenerazioniPerRigaDOro, 1);
      expect(ultima.ripiego, isTrue,
          reason: 'la riga da togliere e\' arrivata da sola: '
              '"${ultima.text}"');
      expect(ultima.text, isNot(contains(rigaDelleCatture)));
    });

    test('nel LIVE l\'istruzione non pretende la riga sotto ogni risposta', () {
      expect(MaestroPersona.rispostaDettaAVoce,
          contains('quando c\'è un passo da dare'));
    });
  });

  group('la bolla, sotto una presentazione gia\' salvata', () {
    for (final (domanda, attese) in const [
      ('Ciao, chi sei? Come puoi aiutarmi?', 0),
      ('Vorrei cambiare lavoro, cosa faccio?', 1),
    ]) {
      testWidgets('"$domanda": righe d\'oro a video $attese', (tester) async {
        await _apriLaConversazione(tester, [
          ChatMessage(role: ChatRole.user, text: domanda),
          const ChatMessage(
              role: ChatRole.maestro,
              text: 'Io sono Calìgo, custode dei segni antichi e dei riti. '
                  'Ti do un verdetto netto sulle scelte che hai davanti.\n'
                  '✦ $rigaDelleCatture'),
        ]);
        final righe = find.byType(RigaDelConsiglio);
        // ignore: avoid_print
        print('EQ.01 MISURA sulla bolla: "$domanda", righe d\'oro a video '
            '${righe.evaluate().length}');
        expect(righe, findsNWidgets(attese));
      });
    }
  });
}

/// Un modello finto che risponde sempre col suo corpo e la stessa riga d'oro,
/// e nel LIVE la scrive a pezzi come il provider vero.
class _SempreLaStessaRiga implements MaestroAiProvider {
  _SempreLaStessaRiga(this.riga);
  final String riga;
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
  }) async {
    volte++;
    // I corpi delle catture, uno per domanda.
    final corpo = userMessage.contains('chi sei')
        ? 'Io sono Calìgo, Maestro dei segni antichi e dei riti.'
        : userMessage.contains('Australia')
            ? 'Il tuo desiderio di successo nel lavoro indica la via del '
                'sentiero numerologico, quello che tracci con i tuoi atti.'
            : userMessage.contains('gli ho scritto')
                ? 'Hai fatto un passo. Ora attendi la sua risposta.'
                : 'Il tuo gesto è compiuto. Ora lascia che il tempo faccia '
                    'il suo corso.';
    final intera = '$corpo\n$riga';
    final suTesto = LaRichiestaDelTurno.corrente.suTesto;
    if (suTesto != null) {
      suTesto(corpo);
      suTesto('$corpo\n${riga.substring(0, 12)}');
      suTesto(intera);
    }
    return intera;
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

/// Un modello finto che risponde col suo copione, una risposta per chiamata.
class _ColCopione extends _SempreLaStessaRiga {
  _ColCopione(this.copione) : super('');
  final List<String> copione;

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
    volte++;
    return copione[(volte < copione.length ? volte : copione.length) - 1];
  }
}

/// Apre la chat di Calìgo sulla conversazione salvata [messaggi], come la
/// prova dell'ordine EQ voce 08: dal busto, dalla scheda della consulta e
/// dal menu' delle conversazioni passate.
Future<void> _apriLaConversazione(
    WidgetTester tester, List<ChatMessage> messaggi) async {
  final m = tester.binding.defaultBinaryMessenger;
  m.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
    (call) async => null,
  );
  for (final n in const [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
  ]) {
    m.setMockStreamHandler(
        EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
  }
  SharedPreferences.setMockInitialValues(const {
    'onboarding.done': true,
    'santuario.greeted': true,
    'cammino.generazione': 2,
    'avvisi.primoGiorno.chiesto': true,
    'settings.effettiSonori': false,
  });
  tester.view.physicalSize = const Size(402 * 3, 874 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  final memoria = InMemoryMaestroMemoryRepository();
  await memoria
      .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
  for (final messaggio in messaggi) {
    await memoria.appendMessage(Maestro.caligo, messaggio);
  }
  await tester.pumpWidget(EsotericCircleApp(
    conIntro: false,
    services: AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: memoria,
      memoryPersistent: true,
      diagnostics: 'Prova offline.',
    ),
  ));
  Future<void> passo() async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  await passo();
  tester
      .element(find.byType(MaterialApp))
      .read<MaestroController>()
      .selectMaestro(Maestro.caligo);
  await passo();
  await tester.tap(find.byKey(const Key('santuario_central_bust')));
  await passo();
  await passo();
  final scheda = find.byKey(const Key('scheda_tocco_consulta_caligo'));
  await tester.ensureVisible(scheda);
  await tester.pump();
  await tester.tap(scheda);
  await tester.pump(const Duration(milliseconds: 500));
  await passo();
  await tester.tap(find.byKey(const Key('chat_menu_della_barra')));
  await passo();
  await tester.tap(find.byKey(const Key('chat_conversazione_passata_0')));
  await passo();
  await passo();
  // La macchina da scrivere non c'e' sulle conversazioni riaperte, ma la
  // bolla ha le sue animazioni: si lascia finire tutto.
  await tester.pump(const Duration(seconds: 2));
}
