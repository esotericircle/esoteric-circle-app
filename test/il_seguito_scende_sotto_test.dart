import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
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
import 'package:esoteric_circle/core/maestro/seguito_della_lettura.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/components/riga_del_consiglio.dart';
import 'package:esoteric_circle/design_system/components/testo_che_si_scrive.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL SEGUITO SCENDE SOTTO, E QUELLO CHE SI STA LEGGENDO NON SI MUOVE.
///
/// **Il difetto visto dal fondatore, e sono tre difetti in uno.** Al tocco di
/// "Vai piu' a fondo" ripartiva la scena di attesa a schermo intero, la bolla
/// si svuotava, e il testo appena letto spariva per qualche secondo per poi
/// tornare uguale. Sembrava di essere tornati indietro e di aver rifatto la
/// domanda, quando invece stava solo scendendo dell'altro sotto.
///
/// Le tre regole che questo file sorveglia, e ognuna vive in un posto solo:
///
/// 1. la scena piena la decide `MaestroChatController.mostraLaScenaDiAttesa`,
///    non la schermata: e' vera solo per una risposta che ancora non esiste;
/// 2. il messaggio non viene sostituito, prende `seguitoInArrivo` e resta;
/// 3. il seguito entra FRA la prima parte e la stella, mai sotto.
const String _breve =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.\n'
    '✦ Non decidere adesso: guarda dove ti fermi.';

const String _corpo =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'La runa che ti accompagna è Laguz, l\'acqua che trova la sua via.';

const String _seguito =
    'Sotto la superficie lavora un secondo movimento, più lento, che dura da '
    'mesi. Laguz continua a scorrere anche quando non la guardi.';

void main() {
  /// Il corpo del primo strato COME STA A VIDEO, preso dal widget che lo
  /// scrive. Nullo quando a video non c'e' nessun primo strato, che e'
  /// esattamente il caso che la bolla svuotata produceva.
  String? corpoAVideo(WidgetTester tester) {
    final testi = tester
        .widgetList<TestoCheSiScrive>(find.descendant(
          of: find.byType(ChatBubble),
          matching: find.byType(TestoCheSiScrive),
        ))
        .toList();
    for (final t in testi) {
      if (t.testo.contains('Cancro')) return t.testo;
    }
    return null;
  }

  /// Il confronto CARATTERE PER CARATTERE, che dice dove cascano invece di
  /// dire soltanto che cascano.
  void identici(String? dopo, String prima, String quando) {
    expect(dopo, isNotNull,
        reason: 'a video non c\'e\' piu\' nessun primo strato $quando: la '
            'bolla si e\' svuotata sotto gli occhi di chi stava leggendo');
    if (dopo == prima) return;
    final quanti = dopo!.length < prima.length ? dopo.length : prima.length;
    var dove = quanti;
    for (var i = 0; i < quanti; i++) {
      if (dopo[i] != prima[i]) {
        dove = i;
        break;
      }
    }
    fail('IL PRIMO STRATO E\' CAMBIATO $quando, al carattere $dove:\n'
        '  prima: «${prima.substring(0, prima.length.clamp(0, dove + 30))}»\n'
        '  dopo:  «${dopo.substring(0, dopo.length.clamp(0, dove + 30))}»');
  }

  Future<_Osservatore> monta(WidgetTester tester,
      {Duration ritardoDelSeguito = const Duration(seconds: 2)}) async {
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceLenta(ritardoDelSeguito),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'prova del seguito',
    );
    final osservatore = _Osservatore();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Navigator(
          observers: [osservatore],
          onGenerateRoute: (_) => MaestroChatScreen.route(
            maestro: Maestro.medora,
            services: servizi,
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    expect(campo, findsOneWidget);
    await tester.enterText(campo, 'devo cambiare lavoro');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    return osservatore;
  }

  /// **PORTA UN COMANDO DOVE IL DITO LO RAGGIUNGE DAVVERO.**
  ///
  /// Ordine CE voce 04: sopra il campo sono comparse due righe, il residuo
  /// delle domande e quello degli approfondimenti. Il compositore galleggia
  /// SOPRA la lista, quindi `ensureVisible` porta la freccia dentro la
  /// finestra di scorrimento ma sotto quelle righe, e il tocco cade su di
  /// loro: misurato, la riga "Ti restano 4 domande ai Maestri su 5, oggi"
  /// stava esattamente sul punto della freccia. Qui si scorre fino in fondo,
  /// dove il margine basso della lista tiene l'ultimo messaggio sopra il
  /// compositore.
  Future<void> portaSottoIlDito(WidgetTester tester, Finder bersaglio) async {
    await tester.ensureVisible(bersaglio);
    await tester.pump();
    final lista = find.byType(Scrollable).first;
    for (var i = 0; i < 8; i++) {
      await tester.drag(lista, const Offset(0, -200), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('VOCE 1. Al tocco non si torna indietro', () {
    testWidgets('La scena piena e\' per la domanda, MAI per il seguito',
        (tester) async {
      final osservatore = await monta(tester);

      // IL GUARDIANO: la scena deve esistere davvero, altrimenti questa prova
      // non prova niente. Con una voce che risponde nello stesso fotogramma il
      // ciclo qui sotto girerebbe a vuoto e resterebbe verde per finta.
      var vistaAllaDomanda = 0;
      for (var i = 0; i < 340; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(ConsultoDelCieloView).evaluate().isNotEmpty) {
          vistaAllaDomanda++;
        }
      }
      expect(vistaAllaDomanda, greaterThan(0),
          reason: 'la scena di attesa non e\' mai comparsa nemmeno alla '
              'domanda: questa prova non sta guardando niente');

      final freccia = find.byKey(const Key('chat_approfondisci'));
      expect(freccia, findsOneWidget);
      // **PRIMA SI PORTA SOTTO IL DITO, poi si tocca.** Ordine CE voce 04:
      // sopra il campo sono comparse due righe, il residuo delle domande e
      // quello degli approfondimenti, e la lista dei messaggi si e' accorciata
      // di quel tanto. La freccia c'era ancora ma stava fuori dalla vista, e
      // il tocco cadeva nel vuoto senza che la prova lo dicesse.
      await portaSottoIlDito(tester, freccia);
      await tester.tap(freccia);

      var vistaAlSeguito = 0;
      var vistoIlSegno = 0;
      for (var i = 0; i < 340; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(ConsultoDelCieloView).evaluate().isNotEmpty) {
          vistaAlSeguito++;
        }
        if (find
            .byKey(const Key('chat_seguito_in_arrivo'))
            .evaluate()
            .isNotEmpty) {
          vistoIlSegno++;
        }
      }
      expect(vistaAlSeguito, 0,
          reason: 'al tocco e\' ripartita la scena di attesa a schermo intero, '
              'in $vistaAlSeguito fotogrammi su 60: la conversazione sparisce '
              'e sembra di essere tornati indietro');
      expect(vistoIlSegno, greaterThan(0),
          reason: 'durante il seguito non si vede NIENTE: la persona tocca e '
              'per due secondi non succede niente a schermo');
      expect(osservatore.pop, 0,
          reason: 'al tocco la schermata e\' stata chiusa ${osservatore.pop} '
              'volte: si e\' tornati indietro davvero');
    });

    testWidgets('Il primo strato non cambia di un carattere, nemmeno DURANTE',
        (tester) async {
      await monta(tester);
      for (var i = 0; i < 340; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final prima = corpoAVideo(tester);
      expect(prima, _corpo,
          reason: 'la prova parte da un primo strato che non e\' quello vero');

      // Come sopra: la freccia si porta sotto il dito prima di toccarla.
      await portaSottoIlDito(
          tester, find.byKey(const Key('chat_approfondisci')));
      await tester.tap(find.byKey(const Key('chat_approfondisci')));

      // DURANTE, e non solo dopo: il difetto vero stava qui in mezzo. La bolla
      // veniva sostituita con una in sospeso, quindi per due secondi il testo
      // spariva, e poi tornava uguale: guardando solo prima e dopo la prova
      // sarebbe restata verde su un difetto che si vede a occhio nudo.
      var guardatoDurante = 0;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find
            .byKey(const Key('chat_seguito_in_arrivo'))
            .evaluate()
            .isNotEmpty) {
          guardatoDurante++;
          identici(corpoAVideo(tester), prima!, 'mentre il seguito scende');
        }
      }
      expect(guardatoDurante, greaterThan(0),
          reason: 'l\'attesa del seguito non e\' mai stata a video, quindi il '
              'ciclo qui sopra ha guardato zero volte');

      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byKey(const Key('chat_seguito')), findsOneWidget,
          reason: 'il seguito non e\' mai arrivato');
      identici(corpoAVideo(tester), prima!, 'dopo che il seguito e\' arrivato');
    });

    testWidgets('La bolla si allunga, e il seguito sta SOPRA la stella',
        (tester) async {
      await monta(tester);
      for (var i = 0; i < 340; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final bolla = find.ancestor(
        of: find.byType(RigaDelConsiglio),
        matching: find.byType(ChatBubble),
      );
      expect(bolla, findsOneWidget);
      final altezzaPrima = tester.getSize(bolla).height;

      // Come sopra: la freccia si porta sotto il dito prima di toccarla.
      await portaSottoIlDito(
          tester, find.byKey(const Key('chat_approfondisci')));
      await tester.tap(find.byKey(const Key('chat_approfondisci')));
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final seguito = find.byKey(const Key('chat_seguito'));
      expect(seguito, findsOneWidget, reason: 'il seguito non e\' arrivato');
      expect(tester.getSize(bolla).height, greaterThan(altezzaPrima),
          reason: 'la bolla e\' rimasta alta ${tester.getSize(bolla).height} '
              'punti come prima: il seguito e\' comparso da qualche altra '
              'parte, non dentro la bolla che si allunga');

      // IL POSTO DEL SEGUITO. Il consiglio in oro e' la firma della lettura e
      // sta in fondo: se il seguito gli finisce sotto, la stella smette di
      // essere l'ultima riga e diventa una frase in mezzo al testo.
      final dySeguito = tester.getTopLeft(seguito).dy;
      final dyStella = tester.getTopLeft(find.byType(RigaDelConsiglio)).dy;
      expect(dySeguito, lessThan(dyStella),
          reason: 'il seguito sta a $dySeguito e la stella a $dyStella: il '
              'seguito e\' finito SOTTO il consiglio');
      final dyCorpo = tester
          .getTopLeft(find.descendant(
            of: find.byType(ChatBubble),
            matching: find.byType(TestoCheSiScrive),
          ).last)
          .dy;
      expect(dySeguito, greaterThan(dyCorpo),
          reason: 'il seguito sta SOPRA la prima parte: si legge al contrario');
    });
  });

  group('VOCE 1b. La ripetizione si misura sul senso, non sulla forma', () {
    // **LA SOGLIA E' MISURATA, e queste sono le due frasi che la decidono.**
    // Vengono da sei coppie vere prese il 4 agosto 2026 con
    // `QUANTE_DOMANDE=6 flutter test tool/risposte_intere.dart`: quarantaquattro
    // frasi di seguito misurate contro tutte le frasi del primo strato.
    const diverseAlMassimo = (
      seguito: 'Per te io leggo la runa Raido, il viaggio e il suo ritmo.',
      gia: 'Per te io leggo il presagio di un nuovo inizio, che attende oltre '
          'la nebbia.',
      misurata: 0.286,
    );
    const ugualiAlMinimo = (
      seguito: 'Sofia, il tuo Cancro lunare può sentirsi smarrito, ma il Leone '
          'solare non cede il suo trono.',
      gia: 'Sofia, il tuo Cancro lunare sente il richiamo del rifugio, ma il '
          'Leone solare cerca la sua via.',
      misurata: 0.348,
    );

    test('La soglia sta in mezzo alle due popolazioni vere', () {
      // La misura di oggi deve dare ancora i numeri con cui la soglia e' stata
      // scelta: se il calcolo cambia, la calibrazione non vale piu' e va
      // rifatta sulle coppie vere, non aggiustata a mano.
      expect(
          SeguitoDellaLettura.somiglianza(
              diverseAlMassimo.seguito, diverseAlMassimo.gia),
          closeTo(diverseAlMassimo.misurata, 0.001));
      expect(
          SeguitoDellaLettura.somiglianza(
              ugualiAlMinimo.seguito, ugualiAlMinimo.gia),
          closeTo(ugualiAlMinimo.misurata, 0.001));
      expect(SeguitoDellaLettura.sogliaDiRipetizione,
          greaterThan(diverseAlMassimo.misurata),
          reason: 'la soglia taglia una frase che dice una cosa NUOVA');
      expect(SeguitoDellaLettura.sogliaDiRipetizione,
          lessThan(ugualiAlMinimo.misurata),
          reason: 'la soglia lascia passare una frase che ripete');
    });

    test('Una frase RISCRITTA viene tolta, e prima passava intera', () {
      final pulito = SeguitoDellaLettura.pulisci(
        gia: ugualiAlMinimo.gia,
        seguito: '${ugualiAlMinimo.seguito} La runa Isa ti mostra il bisogno '
            'di un silenzio che precede la forma.',
      );
      expect(pulito, isNot(contains('non cede il suo trono')),
          reason: 'la parafrasi e\' passata: la persona rilegge la stessa cosa '
              'girata in un altro modo, ed e\' il difetto che il filtro per '
              'identita\' esatta non vedeva');
      expect(pulito, contains('La runa Isa'),
          reason: 'il seguito e\' stato buttato invece che ripulito');
      expect(
          SeguitoDellaLettura.quanteRipetute(
              gia: ugualiAlMinimo.gia, seguito: ugualiAlMinimo.seguito),
          1);
    });

    test('La riga della stella non entra mai nel seguito', () {
      // Sulle sei coppie vere, SEI seguiti su sei riscrivevano la riga del
      // consiglio: non e' un caso di frontiera, e' la regola del modello.
      // Lasciarla passare avrebbe messo due stelle nella stessa bolla.
      const grezzo = 'Il moto lento continua sotto la superficie.\n'
          '✦ Non decidere adesso: guarda dove ti fermi.';
      expect(SeguitoDellaLettura.senzaLaRigaDelConsiglio(grezzo),
          'Il moto lento continua sotto la superficie.');
      final pulito =
          SeguitoDellaLettura.pulisci(gia: _corpo, seguito: grezzo);
      expect(pulito, isNot(contains('✦')));
      expect(pulito, contains('Il moto lento'));
    });

    test('L\'istruzione dice che il testo di sopra RESTA a video', () {
      // La regola vive nei dati: l'istruzione e' una sola, e la chat e ogni
      // altra porta che chiedesse un seguito passano di li'.
      expect(SeguitoDellaLettura.istruzione(_corpo),
          contains('RESTA SULLO SCHERMO'));
      expect(SeguitoDellaLettura.istruzione(_corpo), contains(_corpo));
    });
  });
}

class _Osservatore extends NavigatorObserver {
  int pop = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pop++;
    super.didPop(route, previousRoute);
  }
}

/// Una voce che sul SEGUITO ci mette del tempo.
///
/// **Senza il ritardo questa prova non prova niente.** Una finta che risponde
/// nello stesso fotogramma non ha nessuno stato di attesa: i cicli che
/// guardano la scena e il segno girerebbero a vuoto, e resterebbero verdi
/// esattamente sul difetto che devono prendere.
class _VoceLenta implements MaestroAiProvider {
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

  _VoceLenta(this.ritardoDelSeguito);

  final Duration ritardoDelSeguito;

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
    if (rispostaGiaData == null) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return _breve;
    }
    await Future<void>.delayed(ritardoDelSeguito);
    return _seguito;
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
      const MaestroReply(glance: 'g', reading: 'r', invite: 'i');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
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
