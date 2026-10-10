// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/features/maestri/live/schermata_live.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/ricordi/ricordi_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_diario_finto.dart';

/// LE ANTEPRIME DELL'ORDINE FE, a 360 per 797 punti logici col rapporto di
/// pixel 3. Le tre della consegna dell'ordine: il messaggio del Maestro non
/// raggiungibile, il passaggio alla forma scritta quando la voce non parte,
/// un consulto dove il secondo Maestro nomina il parere del primo. E le
/// cinque dell'aggiunta FE.22: il menu' della chat coi nomi nuovi, il Diario
/// col filtro dei segnati, la voce con la stella e la riga della persona, la
/// settimana con un giorno segnato, la conferma del cestino.
///
/// **Girano sempre** e controllano a ogni giro che i testi a video siano
/// quelli dell'ordine; **scrivono le immagini solo con**
/// `AGGIORNA_ANTEPRIME=1`, in `docs/preview/FE/`.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();
  final scrivi = Platform.environment['AGGIORNA_ANTEPRIME'] == '1';
  final adesso = DateTime(2026, 10, 6, 21);

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    m.setMockMethodCallHandler(SystemChannels.platform, (c) async => null);
  }

  void finestra(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
  }

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    if (!scrivi) return;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FE');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FE ANTEPRIMA: ${dir.path}/$nome.png ${img.width}x${img.height}');
      img.dispose();
    });
  }

  VoceDelRicordo responso(DateTime quando, String arte, String titolo,
      {String maestro = 'medora', bool stella = false}) {
    final chiave = '${quando.millisecondsSinceEpoch ~/ 60000}.$arte';
    return VoceDelRicordo(
      quando: quando,
      arte: arte,
      maestro: maestro,
      titolo: titolo,
      tipo: TipoDelRicordo.responso,
      riferimento: chiave,
      chiaveDelDiario: chiave,
      stella: stella,
    );
  }

  /// Un Diario d'autunno: conversazioni coi tre Maestri e qualche responso,
  /// due con la stella.
  PortaFintaDelDiario ilDiario() {
    final porta = PortaFintaDelDiario();
    porta.metti(laConversazione(Maestro.medora,
        id: 'c${DateTime(2026, 10, 5, 18).millisecondsSinceEpoch}',
        titolo: 'Come affronto il colloquio di giovedì?',
        quando: DateTime(2026, 10, 5, 18)));
    porta.metti(laConversazione(Maestro.medora,
        id: 'c${DateTime(2026, 10, 2, 9).millisecondsSinceEpoch}',
        titolo: 'Che energia porta questo ottobre nelle relazioni?',
        quando: DateTime(2026, 10, 2, 9)));
    porta.metti(laConversazione(Maestro.medora,
        id: 'c${DateTime(2026, 9, 29, 21).millisecondsSinceEpoch}',
        titolo: 'Devo rispondere a mia sorella?',
        quando: DateTime(2026, 9, 29, 21)));
    porta.metti(responso(
        DateTime(2026, 10, 3, 9), 'gettata', 'La tua gettata: le tre Norne',
        maestro: 'caligo', stella: true));
    porta.metti(responso(
        DateTime(2026, 10, 1, 8), 'oroscopo', 'Il tuo oroscopo, Bilancia'));
    porta.metti(responso(
        DateTime(2026, 9, 14, 20), 'stesa', 'La tua stesa a tre carte',
        stella: true));
    return porta;
  }

  Widget conIlDiario(Widget figlio, RegistroDeiRicordi registro) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
        ],
        child: RepaintBoundary(
          key: radice,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: MaestroScope(maestro: Maestro.medora, child: figlio),
          ),
        ),
      );

  Future<void> laChat(WidgetTester tester,
      {Maestro maestro = Maestro.medora,
      MaestroAiProvider ai = const UnavailableMaestroAiProvider(),
      bool apriIlMenu = true}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    await memoria.appendMessage(
        Maestro.medora,
        ChatMessage(
            role: ChatRole.user,
            text: 'Come affronto il colloquio di giovedì?',
            at: DateTime(2026, 10, 5, 18),
            conversazione:
                'c${DateTime(2026, 10, 5, 18).millisecondsSinceEpoch}'));
    final svc = AppServices(
      ai: ai,
      memory: memoria,
      memoryPersistent: true,
      diagnostics: 'Anteprima.',
    );
    final registro =
        RegistroDeiRicordi(orologio: () => adesso, porta: ilDiario());
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: svc),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance(freeDailyLimit: 3)),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: Navigator(
            onGenerateRoute: (_) =>
                MaestroChatScreen.route(maestro: maestro, services: svc),
          ),
        ),
      ),
    ));
    await passa(tester, 14);
    if (!apriIlMenu) return;
    await tester.tap(find.byKey(const Key('chat_menu_della_barra')));
    await passa(tester, 6);
  }

  Future<void> ilLive(
      WidgetTester tester, Map<Object?, Object?> sessione) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final prima = PortaDelLive.chiama;
    PortaDelLive.chiama = (porta, dati) async =>
        porta == 'apriUnaSessioneLive' ? sessione : const {};
    addTearDown(() => PortaDelLive.chiama = prima);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: const MaestroScope(
              maestro: Maestro.medora,
              child: SchermataLive(maestro: Maestro.medora)),
        ),
      ),
    ));
    await passa(tester, 30);
  }

  testWidgets('FE.03: il Maestro non raggiungibile', (tester) async {
    // La sessione arriva senza l'avatar: e' la configurazione incompleta
    // che faceva chiudere l'app sul Redmi.
    await ilLive(tester, {
      'url': 'wss://prova',
      'gettone': 'g',
      'stanza': 's',
      'sessione': 'x',
    });
    expect(find.text(QuadroDelLive.rigaDelMaestroNonRaggiungibile),
        findsOneWidget);
    expect(find.text('Continua per iscritto'), findsOneWidget,
        reason: 'la persona non vede la strada per la chat scritta');
    await scatta(tester, 'fe03_maestro_non_raggiungibile');
  });

  testWidgets('FE.07: la voce che non parte passa alla forma scritta',
      (tester) async {
    // La sessione e' completa, ma la stanza della voce non si collega: sul
    // banco non c'e' un server LiveKit, come sul telefono quando la rete
    // della voce non regge.
    final prima = SchermataLive.collega;
    SchermataLive.collega =
        (stanza, url, gettone) async => throw StateError('stanza assente');
    addTearDown(() => SchermataLive.collega = prima);
    await ilLive(tester, {
      'url': 'wss://prova.invalid',
      'gettone': 'g',
      'stanza': 's',
      'sessione': 'x',
      'avatar': 'a',
      'minutiRimasti': 120,
    });
    // Il tentativo di collegarsi alla stanza vive nel tempo vero.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 500)));
      await passa(tester, 4);
    }
    expect(find.text(QuadroDelLive.rigaDellaVocePerduta), findsOneWidget);
    expect(find.text('Continua per iscritto'), findsOneWidget,
        reason: 'la persona non vede la strada per la chat scritta');
    await scatta(tester, 'fe07_la_voce_non_parte');
  });

  testWidgets('FE.14: il secondo Maestro nomina il parere del primo',
      (tester) async {
    // **I TESTI SONO VERI**, dal banco del filo col modello, percorso B, giro
    // del 6 ottobre 2026 alle 02:43
    // (docs/collaudo/banchi_col_modello/filo/2026-10-06T0243/percorso_b.txt).
    IlFiloDelConsulto.dimentica();
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: _domanda,
        risposta: _rispostaDiMedora);
    await laChat(tester,
        maestro: Maestro.caligo,
        ai: _VoceConUnTesto(_rispostaDiCaligo),
        apriIlMenu: false);
    final campo = find.descendant(
        of: find.byType(ChatComposer), matching: find.byType(TextField));
    await tester.enterText(campo, _domanda);
    await passa(tester, 2);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)));
      await passa(tester, 10);
    }
    expect(
        find.textContaining('Medora ha già tracciato il sentiero',
            findRichText: true),
        findsWidgets);
    expect(find.byKey(const Key('filo_in_cima')), findsOneWidget,
        reason: 'in cima alla chat di Calìgo manca il filo di Medora');
    await scatta(tester, 'fe14_il_secondo_maestro_nomina_il_primo');
    IlFiloDelConsulto.dimentica();
  });

  testWidgets('FE.23: il filo in cima, aperto, coi pareri di chi ha parlato',
      (tester) async {
    // La richiesta del fondatore del 5 ottobre 2026: "in alto la domanda
    // dell'utente venga ripetuta [...] e magari aggiungere cosa ha risposto
    // il maestro precedente". Lo stesso consulto della FE.14, testi veri dal
    // banco del filo, col filo toccato e aperto.
    IlFiloDelConsulto.dimentica();
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: _domanda,
        risposta: _rispostaDiMedora);
    await laChat(tester,
        maestro: Maestro.caligo,
        ai: _VoceConUnTesto(_rispostaDiCaligo),
        apriIlMenu: false);
    await passa(tester, 4);
    expect(find.byKey(const Key('filo_in_cima_chiusa')), findsOneWidget);
    await tester.tap(find.byKey(const Key('filo_in_cima')));
    await passa(tester, 6);
    expect(find.byKey(const Key('filo_in_cima_chiusa')), findsNothing,
        reason: 'il tocco non ha aperto il filo');
    expect(find.byKey(const Key('filo_in_cima_medora')), findsOneWidget,
        reason: 'aperto, il filo non mostra il parere di Medora');
    await scatta(tester, 'fe23_il_filo_aperto');
    IlFiloDelConsulto.dimentica();
  });

  testWidgets('FE.22.1: il menu\' della chat coi nomi nuovi', (tester) async {
    await laChat(tester);
    expect(find.text('Nuova chat'), findsOneWidget);
    expect(find.text('Chat precedenti'), findsOneWidget);
    expect(find.text('LIVE con Medora'), findsOneWidget);
    expect(
        find.byKey(const Key('chat_conversazione_passata_0')), findsOneWidget,
        reason: 'il menu\' non mostra le conversazioni del Diario');
    // **LA DATA CORTA, perche' il titolo si legga.** La prima anteprima
    // mostrava "Devo ris... 29 settembre": il titolo leggibile per tre
    // lettere. Si misura la data e lo spazio che resta al titolo.
    expect(find.text('29 set'), findsOneWidget,
        reason: 'nel menu\' la data e\' ancora per esteso');
    final riga = tester
        .getSize(find.byKey(const Key('chat_conversazione_passata_2')))
        .width;
    final titolo = tester.getSize(find.textContaining('Devo rispondere')).width;
    print('FE.22 MISURA: nel menu\' il titolo prende ${titolo.round()} punti '
        'su ${riga.round()}');
    expect(titolo / riga, greaterThan(0.40),
        reason: 'il titolo ha meno di due quinti della riga');
    await scatta(tester, 'fe22_menu_della_chat');
  });

  testWidgets('FE.22.17: la conferma del cestino', (tester) async {
    await laChat(tester);
    await tester.tap(find.byKey(const Key('chat_cancella_passata_0')));
    await passa(tester, 6);
    expect(
        find.text(
            'Vuoi cancellare questa conversazione? Non si potrà recuperare.'),
        findsOneWidget);
    expect(find.text('Cancella'), findsOneWidget);
    expect(find.text('Non ora'), findsOneWidget);
    // **IL DIALOGO E' ALTO QUANTO IL SUO TESTO.** La prima anteprima lo
    // mostrava alto tutto lo schermo, con un vuoto in mezzo.
    // Si misura la superficie del dialogo, il suo Material: la scatola
    // dell'AlertDialog e' sempre grande quanto lo schermo.
    final alto = tester
        .getSize(find
            .descendant(
                of: find.byKey(const Key('chat_conferma_cancella')),
                matching: find.byType(Material))
            .first)
        .height;
    print('FE.22 MISURA: il dialogo del cestino e\' alto ${alto.round()} '
        'punti su 797');
    expect(alto, lessThan(797 * 0.6),
        reason: 'il dialogo del cestino occupa quasi tutto lo schermo');
    await scatta(tester, 'fe22_conferma_del_cestino');
  });

  testWidgets('FE.22.9: il Diario col filtro dei segnati', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final registro =
        RegistroDeiRicordi(orologio: () => adesso, porta: ilDiario());
    await tester.pumpWidget(
        conIlDiario(RicordiScreen(orologio: () => adesso), registro));
    await passa(tester, 10);
    final pastiglia = find.byKey(const Key('ricordi_pastiglia_segnati'));
    await tester.scrollUntilVisible(pastiglia, 120,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(pastiglia);
    await passa(tester, 6);
    expect(find.text('Solo i segnati'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ricordi_mese_10')));
    await passa(tester, 6);
    await scatta(tester, 'fe22_diario_solo_i_segnati');
  });

  testWidgets('FE.22.8: la settimana con un giorno segnato', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final registro =
        RegistroDeiRicordi(orologio: () => adesso, porta: ilDiario());
    await tester.pumpWidget(
        conIlDiario(RicordiScreen(orologio: () => adesso), registro));
    await passa(tester, 10);
    await tester.tap(find.byKey(const Key('ricordi_mese_10')));
    await passa(tester, 6);
    final settimana = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('ricordi_settimana_'));
    await tester.tap(settimana.first);
    await passa(tester, 6);
    expect(find.byKey(const Key('ricordi_giorno_con_stella_2026-10-03')),
        findsOneWidget);
    await scatta(tester, 'fe22_settimana_col_giorno_segnato');
  });

  testWidgets('FE.22.10: la voce con la stella e la riga della persona',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    finestra(tester);
    final porta = ilDiario();
    final carta = RicordoCustodito(
      quando: DateTime(2026, 10, 3, 9),
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'La tua gettata: le tre Norne',
      testo: 'Uruz ti chiede di non trattenere la forza che hai già. '
          'Quello che stai rimandando non aspetta te, aspetta un tuo gesto.',
      comeENato: ComeENato.gesto,
      dati: const {'gettata': 'le tre Norne', 'rune': 'Uruz,Fehu,Laguz'},
    );
    final voce = responso(carta.quando, 'gettata', carta.titolo,
        maestro: 'caligo', stella: true);
    porta.contenuti[voce.chiave] = {
      'v': 1,
      'c': carta.aMappa(),
      'nota': 'Il giorno in cui ho deciso di partire.',
    };
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          onGenerateRoute: (_) => RicordoApertoScreen.dallaVoce(voce),
        ),
      ),
    ));
    await passa(tester, 10);
    final riga = find.byKey(const Key('ricordo_aperto_riga'));
    await tester.scrollUntilVisible(riga, 120,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 4);
    expect(find.text('Il giorno in cui ho deciso di partire.'), findsOneWidget);
    await scatta(tester, 'fe22_voce_con_la_stella_e_la_riga');
  });
}

const String _domanda = 'Riceverò la promozione che aspetto al lavoro?';

const String _rispostaDiMedora =
    'La tua domanda sulla promozione è legata a un transito che favorisce la '
    'crescita e il riconoscimento. Affinché si concretizzi, è fondamentale '
    'che tu metta in chiaro i tuoi obiettivi e le tue aspirazioni ai tuoi '
    'superiori, scegliendo il momento propizio per farlo.\n\n'
    '✦ Prepara un discorso lucido e presentalo al tuo responsabile domani '
    'mattina, con la Luna in aspetto favorevole.';

const String _rispostaDiCaligo =
    'La promozione è un tuo diritto conquistato. Non attendere che ti venga '
    'offerta.\n\n'
    'Medora ha già tracciato il sentiero: un discorso lucido è la soglia. La '
    'runa Gebo presagisce un dono o uno scambio equo. Questa è la tua '
    'occasione per sigillare il tuo valore. Prepara ogni parola con cura, '
    'come un metallo prezioso che forgia il suo destino.\n\n'
    '✦ Chiedi al tuo responsabile un incontro personale, indicando un orario '
    'preciso per domani mattina.';

/// Una voce che consegna un testo dato, per fotografarlo. Il testo e' copiato
/// da una risposta vera del banco, non inventato. La stessa finta
/// dell'ordine E (`anteprime_ordine_e_test.dart`).
class _VoceConUnTesto implements MaestroAiProvider {
  _VoceConUnTesto(this.testo);

  final String testo;

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
