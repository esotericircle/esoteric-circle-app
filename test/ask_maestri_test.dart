import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Consulta un Maestro" a domanda singola: parte dal Maestro del dominio, ogni
/// risposta e ogni lente aggiunta passa da Gemini con ripiego sull'oracolo, la
/// sintesi comparativa e' deterministica, il Free ha tre risposte al giorno.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  // In headless i sensori non esistono: si silenziano per la chat, che di sotto
  // ha il cosmo con la parallasse.
  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Widget host({
    Tier tier = Tier.free,
    Maestro starter = Maestro.medora,
    AppServices? services,
    QuestionAllowance? allowance,
    BirthIdentityController? birth,
    String tema = 'il lavoro',
  }) =>
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services ?? AppServices.offline()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider<BirthIdentityController>.value(
              value: birth ?? BirthIdentityController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(
              create: (_) => allowance ?? QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: AskMaestriScreen(starter: starter, temaIniziale: tema),
          ),
        ),
      );

  /// LA DOMANDA ARRIVA DA FUORI, e non si digita piu' qui.
  ///
  /// Il campo di scrittura in cima al confronto e' stato tolto il 5 agosto
  /// 2026: nel confronto non si scrive, si legge e si sceglie con chi
  /// proseguire. Le prove montano la schermata col tema gia' dentro, cioe'
  /// esattamente come ci si arriva dalla chat, e qui si aspetta soltanto che
  /// la prima voce arrivi.
  Future<void> ask(WidgetTester tester, String theme) async {
    await tester.pumpAndSettle();
  }

  testWidgets('Parte dal Maestro del dominio, una risposta e l\'invito',
      (tester) async {
    await tester.pumpWidget(
        host(tema: 'il lavoro', starter: Maestro.medora, tier: Tier.tier1));
    await tester.pump();
    // NIENTE STATO VUOTO: qui si arriva sempre con una domanda gia' fatta, e
    // senza campo per farne una non ci sarebbe niente da invitare a fare.
    expect(find.byKey(const Key('ask_empty')), findsNothing);

    await ask(tester, 'il lavoro');

    // TRE CARTE, e nessun invito ad aggiungerne: ci sono gia' tutte.
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    // LA SINTESI STA IN FONDO, dal 4 agosto 2026, e una lista non costruisce
    // cio' che non entra a schermo: per trovarla si scorre. In cima occupava
    // da sola il primo schermo, e le carte cominciavano dove finiva lei.
    await tester.scrollUntilVisible(find.byKey(const Key('ask_synthesis')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('ask_synthesis')), findsOneWidget,
        reason: 'con tre voci la sintesi deve esserci');
    expect(find.byKey(const Key('ask_another_invite')), findsNothing);
    expect(find.byKey(const Key('ask_add_aura')), findsNothing);
  });

  testWidgets('AI pronta: la lente del dominio usa la risposta viva',
      (tester) async {
    await tester.pumpWidget(host(
      tema: 'il lavoro',
      starter: Maestro.medora,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'il lavoro');

    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Medora vede il lavoro'), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsNothing);
  });

  testWidgets('AI che lancia MaestroAiUnavailable: cade sull\'oracolo',
      (tester) async {
    await tester.pumpWidget(host(
      tema: 'il lavoro',
      starter: Maestro.medora,
      services: _servicesWith(_UnavailableAi()),
    ));
    await ask(tester, 'il lavoro');

    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.textContaining('Da astrologa guardo tempi e tendenze'),
        findsOneWidget);
  });

  testWidgets('Confronto Premium: lenti dal provider e sintesi viva da Gemini',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      tema: 'una scelta',
      tier: Tier.tier1,
      starter: Maestro.medora,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'una scelta');
    // LE ALTRE DUE VOCI ARRIVANO DA SOLE, dal 5 agosto 2026: qui si toccava
    // un chip per chiederle, e quel chip non esiste piu'.
    await tester.pumpAndSettle();

    // Due lenti vive, entrambe dal provider.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsOneWidget);
    expect(find.textContaining('Medora vede una scelta'), findsOneWidget);
    expect(find.textContaining('Aura sente una scelta'), findsOneWidget);

    // La Sintesi comparativa viene dal provider (testo distintivo), non dalla
    // deterministica, e chiude con la regola.
    await tester.scrollUntilVisible(find.byKey(const Key('ask_synthesis')), 300,
        scrollable: find.byType(Scrollable).first);
    final sintesi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('ask_synthesis')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .whereType<String>()
        .join(' ');
    expect(sintesi, contains('Sintesi viva dal provider'));
    expect(sintesi, contains('Medora'));
    expect(sintesi, contains('Aura'));
    expect(sintesi,
        contains('Dove gli sguardi concordano, ascolta con più fiducia'));
    expect(sintesi, isNot(contains('Stessa domanda')));
  });

  testWidgets('Il titolo della Sintesi si legge intero, su schermo stretto',
      (tester) async {
    // LO SPAZIO E' UNA MISURA, NON UN GUSTO.
    //
    // Il segno dei tre volti e' piu' largo dell'icona che ha sostituito, e
    // l'ho scoperto guardando l'anteprima: il titolo era diventato "Sintesi
    // comparat...". Il taglio era silenzioso, l'ellissi non lo dichiara a
    // nessuno. Qui si misura sullo schermo PIU' STRETTO che il corredo
    // fotografa, 360 punti: se qualcuno ingrandisce i volti, o allunga il
    // titolo, o cambia il carattere, questa prova cade prima dell'anteprima.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 2200) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
        host(tema: 'una scelta', tier: Tier.tier1, starter: Maestro.medora));
    await ask(tester, 'una scelta');
    // LE ALTRE DUE VOCI ARRIVANO DA SOLE, dal 5 agosto 2026: qui si toccava
    // un chip per chiederle, e quel chip non esiste piu'.
    await tester.pumpAndSettle();

    final titolo = find.descendant(
      of: find.byKey(const Key('ask_synthesis')),
      matching: find.text('Sintesi comparativa'),
    );
    expect(titolo, findsOneWidget);

    // Quanto e' alta una riga sola di quel titolo, con quel carattere.
    //
    // **LA MISURA SI LEGGE DAL RUOLO, NON SI RICOPIA.** Ordine CE voce 11:
    // qui c'era scritto diciassette, e il giorno che il titolo e' entrato
    // nella scala dei ruoli quel numero e' diventato falso senza che nessuno
    // se ne accorgesse. Adesso lo chiede al ruolo che la schermata usa.
    final unaRiga = (TextPainter(
      text: TextSpan(
          text: 'Sintesi comparativa', style: TypographyTokens.titoloScheda()),
      textDirection: TextDirection.ltr,
    )..layout())
        .height;
    final dipinto = tester.getSize(titolo);

    expect(dipinto.height, lessThan(unaRiga * 1.5),
        reason: 'il titolo della Sintesi va a capo: i tre volti occupano '
            'troppo, restringili invece di accorciare il titolo');
    expect(dipinto.width, greaterThanOrEqualTo(206.0),
        reason: 'il titolo della Sintesi resta piu stretto di quanto il '
            'testo chieda: e in corso un taglio');
  });

  testWidgets('Sintesi comparativa: cade sulla deterministica se non pronto',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Provider non pronto (offline): lenti dall'oracolo e sintesi deterministica.
    await tester.pumpWidget(
        host(tema: 'una scelta', tier: Tier.tier1, starter: Maestro.medora));
    await ask(tester, 'una scelta');
    // LE ALTRE DUE VOCI ARRIVANO DA SOLE, dal 5 agosto 2026: qui si toccava
    // un chip per chiederle, e quel chip non esiste piu'.
    await tester.pumpAndSettle();

    final sintesi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('ask_synthesis')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .whereType<String>()
        .join(' ');
    // La deterministica (synthesisFor) apre con "Stessa domanda" e non e' quella
    // viva del provider.
    expect(sintesi, contains('Stessa domanda'));
    expect(sintesi, isNot(contains('Sintesi viva dal provider')));
    expect(sintesi,
        contains('Dove gli sguardi concordano, ascolta con più fiducia'));
  });

  testWidgets(
      'Free: il confronto invita a salire, e le altre voci non '
      'arrivano', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(tema: 'una scelta', tier: Tier.free));
    await ask(tester, 'una scelta');
    // LE ALTRE DUE VOCI ARRIVANO DA SOLE, dal 5 agosto 2026: qui si toccava
    // un chip per chiederle, e quel chip non esiste piu'.
    await tester.pumpAndSettle();

    // **L'INVITO A SALIRE LO APRE LA PORTA, NON QUESTA STANZA.** Prima lo
    // apriva il chip che chiedeva una voce, e quel chip non esiste piu'.
    // Aprirlo qui vorrebbe dire accogliere chi entra con una finestra di
    // vendita, e per due volte di fila, perche' la porta lo ha gia' fatto.
    // Qui resta cio' che il Free deve vedere: la sua voce, e nessun'altra.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsNothing);
    expect(find.byKey(const Key('ask_lens_caligo')), findsNothing);
    expect(find.byKey(const Key('ask_synthesis')), findsNothing,
        reason: 'con una voce sola non c\'e\' niente da mettere a confronto');
  });

  // LE DUE PROVE QUI SOTTO CODIFICAVANO IL DIFETTO, e vanno lette sapendolo.
  //
  // Usavano `AppServices.offline()`, cioe' un provider non pronto: il Consulta
  // saltava l'AI e cadeva sull'oracolo, quindi ogni risposta era un RIPIEGO.
  // Dal 2 agosto 2026 un ripiego non costa una domanda, e queste prove
  // pretendevano che costasse. Adesso montano una voce che risponde davvero,
  // che e' cio' che intendevano misurare, e sotto c'e' la prova nuova che il
  // ripiego NON conta.
  testWidgets('Free: oltre il limite, il confronto invita a salire',
      (tester) async {
    // **QUESTA PROVA E' CAMBIATA IL 5 agosto 2026, e va detto perche'.**
    // Faceva quattro domande di fila su questa schermata, digitandole nel
    // campo in cima. Il campo non c'e' piu': nel confronto non si scrive, e la
    // domanda arriva dalla chat. Il conteggio delle tre al giorno resta
    // provato dove ora avviene davvero, cioe' nella chat. Qui resta cio' che
    // e' ancora di questa schermata: con le domande gia' finite, la prima voce
    // non parte e si vede l'invito a salire invece di un comando muto.
    final contatore = QuestionAllowance();
    for (var i = 0; i < 3; i++) {
      contatore.record(Tier.free);
    }
    await tester.pumpWidget(host(
      tema: 'quarta',
      tier: Tier.free,
      allowance: contatore,
      services: _servicesWith(_ReadyAi()),
    ));
    await ask(tester, 'quarta');
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
  });

  testWidgets('La domanda si conta solo a risposta consegnata', (tester) async {
    final allowance = QuestionAllowance();
    await tester.pumpWidget(host(
      tema: 'il lavoro',
      tier: Tier.free,
      allowance: allowance,
      services: _servicesWith(_ReadyAi()),
    ));
    // **L'ISTANTE "PRIMA" NON E' PIU' OSSERVABILE, e non lo fingo.** La voce
    // si chiede da se' appena la schermata si monta, quindi non c'e' nessun
    // momento in cui la prova possa guardare col montaggio finito e la
    // risposta non ancora arrivata. Resta il conto: una risposta VERA consuma
    // una domanda, e una sola. Che un ripiego NON consumi lo prova la voce
    // qui sotto, che e' la meta' che conta.
    await ask(tester, 'il lavoro');
    expect(allowance.usedToday(), 1);
  });

  testWidgets('Una lente di RIPIEGO non consuma la domanda', (tester) async {
    // Col provider non pronto la lente viene dall'oracolo deterministico ed e'
    // dichiarata come ripiego: il Maestro non ha parlato, quindi non si paga.
    // E' il difetto del 2 agosto visto dalla seconda superficie.
    final allowance = QuestionAllowance();
    await tester.pumpWidget(
        host(tema: 'il lavoro', tier: Tier.free, allowance: allowance));
    await ask(tester, 'il lavoro');
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget,
        reason: 'la lente di ripiego viene consegnata lo stesso');
    expect(allowance.usedToday(), 0,
        reason: 'una risposta che non viene dal Maestro non costa');
  });

  testWidgets('Personalizzazione: il provider riceve i dati natali presenti',
      (tester) async {
    final cap = _CapturingAi();
    final birth = BirthIdentityController()
      ..setBirth(
        BirthDetails(
          date: DateTime(1990, 8, 10),
          time: const TimeOfDay(hour: 12, minute: 0),
          place: const BirthPlace(
              label: 'Roma',
              latitude: 41.9,
              longitude: 12.5,
              timezone: 'Europe/Rome'),
          gender: Gender.female,
        ),
        NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
      );
    await tester.pumpWidget(host(
      tema: 'il lavoro',
      starter: Maestro.medora,
      services: _servicesWith(cap),
      birth: birth,
    ));
    await ask(tester, 'il lavoro');

    expect(cap.lastNatal, isNotNull);
    expect(cap.lastNatal!.sunSign, 'Leone');
    expect(cap.lastNatal!.lifeNumber, isNotNull);
    // La profondita' nel Free e' Breve.
    expect(cap.lastDepth, ConsultDepth.breve);
  });

  testWidgets('Chiusura del cerchio: salva in memoria e TORNA alla chat',
      (tester) async {
    // **QUESTA PROVA E' CAMBIATA IL 5 agosto 2026.** "Continua con" apriva una
    // rotta NUOVA, quindi il Maestro ripartiva da zero e la conversazione
    // precedente spariva dalla vista. Adesso, per il Maestro da cui si e'
    // arrivati, si TORNA: al Consiglio ci si arriva dalla sua chat, che e'
    // rimasta sotto nella pila. Qui sotto non c'e' nessuna chat, quindi cio'
    // che si misura e' che la schermata si chiuda, piu' la nota lasciata in
    // memoria, che e' la parte che vale.
    silenceSensors();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = InMemoryMaestroMemoryRepository();
    final services = AppServices(
      ai: _ReadyAi(),
      memory: repo,
      memoryPersistent: false,
    );
    await tester.pumpWidget(host(
        tema: 'devo cambiare lavoro',
        starter: Maestro.medora,
        tier: Tier.tier1,
        services: services));
    await ask(tester, 'devo cambiare lavoro');

    await tester.tap(find.text('Continua con ${Maestro.medora.displayName}'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // La nota resta nella memoria del Maestro: la conversazione riprende
    // sapendo cosa e' successo nel Consiglio.
    final mem = await repo.loadMemory(Maestro.medora);
    expect(mem.sessionSummary, contains('devo cambiare lavoro'));
  });

  testWidgets(
      'I testi a video non usano il trattino lungo e hanno accenti veri',
      (tester) async {
    await tester.pumpWidget(host(tema: 'il lavoro', starter: Maestro.medora));
    await ask(tester, 'il lavoro');

    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(testi, isNotEmpty);
    for (final s in testi) {
      expect(s.contains('—'), isFalse,
          reason: 'Trovato un trattino lungo in: $s');
    }
    // NESSUN ACCENTO SCRITTO CON L'APOSTROFO, che e' la regola vera.
    //
    // **La riga di prima diceva un'altra cosa, e il 5 agosto 2026 e' caduta
    // per una ragione falsa.** Chiedeva che ALMENO UNO dei testi a video
    // portasse una vocale accentata. Ma questa schermata mostra un invito che
    // ruota col giorno, e il testo del 5 agosto, "Torna domani: la Luna passa
    // in Toro", di accenti non ne ha nessuno: la prova cascava senza che
    // niente fosse rotto, e nei giorni in cui reggeva non stava sorvegliando
    // gli accenti, stava sorvegliando la rotazione.
    //
    // La regola che conta e' il contrario: che non compaia mai "perche'" o
    // "piu'" o "e'" con l'apostrofo al posto dell'accento. Questa si puo'
    // misurare su ogni testo, e non dipende dal giorno.
    final conApostrofo = RegExp(
        r"\b(perche|poiche|benche|affinche|finche|nonche|cioe|piu|gia|puo|"
        r"citta|volonta|verita|liberta|meta|eta|qualita|realta|felicita)'",
        caseSensitive: false);
    for (final s in testi) {
      expect(conApostrofo.hasMatch(s), isFalse,
          reason: 'Un accento scritto con l\'apostrofo in: $s');
    }
    // E il guardiano: il controllo deve saper cascare, altrimenti questo
    // ciclo e' un ciclo che passa sempre.
    expect(conApostrofo.hasMatch('perche\' non lo dici'), isTrue);
    expect(conApostrofo.hasMatch('perché non lo dici'), isFalse);
  });
}

/// Costruisce servizi di test con il provider AI dato, memoria solo in RAM.
AppServices _servicesWith(MaestroAiProvider ai) => AppServices(
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );

/// Provider pronto che risponde con un testo per Maestro, cosi' si distingue la
/// risposta viva da quella dell'oracolo e si verifica l'intreccio della sintesi.
class _ReadyAi implements MaestroAiProvider {
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

  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    final verbo = maestro == Maestro.aura ? 'sente' : 'vede';
    return MaestroReply(
      glance: '${maestro.displayName} $verbo $theme con la sua lente.',
      reading:
          'Testo narrato vivo di ${maestro.displayName} su $theme, così è.',
      invite: 'Un invito vivo di ${maestro.displayName}.',
    );
  }

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
      'Le stelle ti ascoltano.';

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async {
    final nomi = lenses.map((l) => l.maestro.displayName).join(' e ');
    return 'Sintesi viva dal provider di $nomi su $theme. Dove gli sguardi '
        'concordano, ascolta con più fiducia; dove divergono, hai più strade '
        'tra cui scegliere.';
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Cattura i parametri passati a consult, per verificare la personalizzazione.
class _CapturingAi implements MaestroAiProvider {
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

  NatalContext? lastNatal;
  ConsultDepth? lastDepth;

  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    lastNatal = natal;
    lastDepth = depth;
    return MaestroReply(
      glance: '${maestro.displayName} vede $theme.',
      reading: 'Testo di ${maestro.displayName}, così.',
      invite: 'Un invito.',
    );
  }

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
      throw UnimplementedError();

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

/// Provider pronto che pero' non trova le parole: cade sull'oracolo.
class _UnavailableAi implements MaestroAiProvider {
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

  @override
  bool get isReady => true;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    throw const MaestroAiUnavailable();
  }

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
      throw UnimplementedError();

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
