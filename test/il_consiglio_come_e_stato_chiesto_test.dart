import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
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
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CONSIGLIO, COME IL FONDATORE L'HA CHIESTO.
///
/// Aveva chiesto una cosa sola: al tocco si arriva alla schermata del
/// confronto. Ne era uscita una stanza dove tre carte tenevano dentro tre
/// copie della scena di attesa della chat, la sintesi occupava da sola il
/// primo schermo, il corpo delle carte era piu' piccolo di quello della chat,
/// il dominio si tagliava a meta' parola, le tre porte avevano tutte lo stesso
/// colore e nessuna portava con se' la domanda.
const String _tema = 'devo cambiare lavoro';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  /// LO SCHERMO E' QUELLO DELLA CONSEGNA: 360 per 797 punti a rapporto 3.
  ///
  /// **Perche' non e' un dettaglio.** Senza questa riga la finestra di prova
  /// vale 800 per 600, e su quella larghezza il dominio aveva 544 punti a
  /// disposizione invece di 104,84: nessun testo si tagliava, quindi la prova
  /// del rosso che rimetteva il difetto restava verde. Un difetto di spazio si
  /// misura solo sullo spazio vero.
  Future<void> apri(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host());
  }

  testWidgets('Nessuna scena di attesa dentro le carte', (tester) async {
    await apri(tester);
    // **DUE FOTOGRAMMI, NON UNO.** Le voci partono da un callback dopo il
    // primo fotogramma: al primo nessuna carta sta ancora aspettando, e questa
    // prova misurava il vuoto. Se ne e' accorta una prova del rosso rimasta
    // verde con una bolla pulsante rimessa dentro la carta.
    await tester.pump();
    await tester.pump();
    expect(find.byType(ConsultoDelCieloView), findsNothing,
        reason: 'la scena del consulto e\' tornata dentro una carta: vive '
            'nella chat, dove c\'e'
            ' una superficie sola e tutta l\'altezza. '
            'Dentro tre carte in colonna gli emblemi finiscono sotto la piega '
            'e restano tre bolle che scattano');
    // E LA CARTA CHE ASPETTA STA FERMA.
    //
    // Non si conta `transientCallbackCount`: nel Consiglio girano gia' i tre
    // volti dei Maestri, che e' moto legittimo e c'era anche prima. Cio' che
    // il fondatore ha visto sono le bolle che scattano DENTRO la carta, e si
    // misura li' dentro.
    var guardate = 0;
    for (final m in Maestro.fixedOrder) {
      final attesa = find.byKey(Key('ask_loading_${m.id}'));
      if (attesa.evaluate().isEmpty) continue;
      guardate++;
      expect(find.descendant(of: attesa, matching: find.byType(FadeTransition)),
          findsNothing,
          reason: 'nella carta di ${m.displayName} qualcosa pulsa ancora: '
              'una lista che aspetta si dice stando ferma');
    }
    // Senza questa riga il ciclo passava a vuoto, e la prova era verde per
    // niente: e' esattamente cio' che era successo.
    expect(guardate, greaterThan(0),
        reason: 'nessuna carta stava aspettando: non c\'era niente da '
            'guardare, e una prova che non guarda niente e\' verde per caso');
    // Le tre voci si lasciano arrivare, altrimenti resta un timer appeso e la
    // prova cade su quello invece che sul difetto.
    await _finoAllaFine(tester);
  });

  testWidgets('La sintesi sta SOTTO le tre carte', (tester) async {
    await apri(tester);
    await _finoAllaFine(tester);

    // PRIMA SI GUARDA IN CIMA, dove la sintesi stava e non deve piu' stare.
    //
    // Una lista non costruisce cio' che non entra a schermo, quindi in cima
    // la sintesi si trova solo se e' davvero in cima: e' la misura piu'
    // diretta del difetto, cioe' "aprendo il Consiglio si vede un muro di
    // testo invece di tre Maestri".
    final sintesi = find.byKey(const Key('ask_synthesis'));
    expect(sintesi, findsNothing,
        reason: 'la sintesi e\' a schermo appena si apre il Consiglio: da '
            'sola occupa il primo schermo, e le carte cominciano dove lei '
            'finisce. Una sintesi e\' la conclusione di un confronto, quindi '
            'prima si legge chi si e\' espresso');

    // Poi si scorre finche' compare, e li' la si trova SOTTO le carte.
    await tester.scrollUntilVisible(sintesi, 200,
        scrollable: find.byType(Scrollable).first);
    expect(sintesi, findsOneWidget,
        reason: 'la sintesi non compare nemmeno scorrendo: senza sintesi '
            'questa prova non misura niente');

    final yDellaSintesi = tester.getTopLeft(sintesi).dy;
    var confrontate = 0;
    for (final m in Maestro.fixedOrder) {
      final carta = find.byKey(Key('ask_card_${m.id}'));
      if (carta.evaluate().isEmpty) continue;
      confrontate++;
      expect(tester.getTopLeft(carta).dy, lessThan(yDellaSintesi),
          reason: 'la sintesi e\' disegnata sopra la carta di '
              '${m.displayName}');
    }
    // Senza questa riga, una lista che non costruisce nessuna carta insieme
    // alla sintesi lascerebbe passare il ciclo a vuoto.
    expect(confrontate, greaterThan(0),
        reason: 'nessuna carta era a schermo insieme alla sintesi: il '
            'confronto non e\' avvenuto');
  });

  testWidgets('Il dominio si legge INTERO, nessuna parola tagliata',
      (tester) async {
    await apri(tester);
    await _finoAllaFine(tester);

    // TUTTI E TRE, non solo quelli che entrano nel primo schermo: la terza
    // carta sta sotto la piega, e una lista non costruisce cio' che non vede.
    // Senza lo scorrimento il ciclo saltava Aura e nessuno se ne accorgeva.
    var misurati = 0;
    for (final m in Maestro.fixedOrder) {
      await tester.scrollUntilVisible(find.byKey(Key('ask_card_${m.id}')), 200,
          scrollable: find.byType(Scrollable).first);
      final trovato = find.byKey(Key('ask_dominio_${m.id}'));
      expect(trovato, findsOneWidget,
          reason: 'il dominio di ${m.displayName} non e\' a schermo');
      final rp = trovato.evaluate().first.renderObject! as RenderParagraph;
      misurati++;
      // LA MISURA, non l'occhio: `didExceedMaxLines` e' vero esattamente
      // quando il testo che serve non ci sta nelle righe concesse, cioe'
      // quando qualcosa viene tagliato via. A oggi la frase piu' lunga, quella
      // di Medora, misura 239,96 punti su una riga sola.
      expect(rp.didExceedMaxLines, isFalse,
          reason: 'il dominio di ${m.displayName} e\' tagliato: si legge '
              '"Astrologia, Cartomanzia e" e Destino sparisce. Un dato '
              'accorciato almeno lo dichiara, uno tagliato no');
      // E OGNI ARTE E' DAVVERO NEL TESTO DIPINTO.
      //
      // Da sola questa riga non basterebbe: `toPlainText` restituisce il
      // testo intero anche quando le righe di troppo vengono tagliate via.
      // E' la riga qui sopra che sorveglia il taglio, questa il contenuto.
      for (final arte in m.domainArts.split(',').map((s) => s.trim())) {
        expect(rp.text.toPlainText(), contains(arte),
            reason: '"$arte" non e\' a schermo sulla carta di '
                '${m.displayName}');
      }
    }
    expect(misurati, Maestro.fixedOrder.length,
        reason: 'non sono stati misurati tutti i domini');
  });

  testWidgets('OGNI carta porta il suo consiglio in oro', (tester) async {
    // Vale anche dentro il Consiglio dei Maestri, su tutte e tre le carte: e'
    // la cosa che una persona di fretta legge al posto di tutto il resto, e
    // qui di testo da leggere ce n'e' tre volte tanto.
    await apri(tester);
    await _finoAllaFine(tester);
    var trovati = 0;
    for (final m in Maestro.fixedOrder) {
      await tester.scrollUntilVisible(find.byKey(Key('ask_card_${m.id}')), 200,
          scrollable: find.byType(Scrollable).first);
      final riga = find.byKey(Key('consiglio_${m.id}'));
      expect(riga, findsOneWidget,
          reason: 'la carta di ${m.displayName} non porta il consiglio');
      trovati++;
      // E la stella, non la freccia che non portava da nessuna parte.
      expect(
          find.descendant(of: riga, matching: find.byIcon(Icons.arrow_forward)),
          findsNothing,
          reason: 'e\' tornata la freccia sulla carta di ${m.displayName}');
    }
    expect(trovati, Maestro.fixedOrder.length);
  });

  testWidgets('Ogni "Continua con" ha il colore del SUO Maestro',
      (tester) async {
    await apri(tester);
    await _finoAllaFine(tester);

    final visti = <Maestro, Color>{};
    for (final m in Maestro.fixedOrder) {
      final porta = find.byKey(Key('ask_continue_${m.id}'));
      if (porta.evaluate().isEmpty) continue;
      final scatola = tester.widget<Container>(
          find.descendant(of: porta, matching: find.byType(Container)).first);
      final sfumatura =
          (scatola.decoration! as BoxDecoration).gradient! as LinearGradient;
      final atteso = MaestroPalette.forKey(ThemeKey.of(m)).primary;
      expect(sfumatura.colors.first.toARGB32(),
          atteso.withValues(alpha: 0.55).toARGB32(),
          reason: 'la porta di ${m.displayName} non e\' del suo colore: la '
              'schermata e\' avvolta nel MaestroScope di chi ha fatto la '
              'domanda, quindi tutte e tre uscivano del colore del primo');
      visti[m] = sfumatura.colors.first;
    }
    expect(visti.length, greaterThan(1),
        reason: 'con una porta sola questa prova non distingue niente');
    expect(visti.values.toSet(), hasLength(visti.length),
        reason: 'due porte hanno lo stesso colore: $visti');
  });

  testWidgets('La chat che si apre PORTA la domanda di partenza',
      (tester) async {
    await apri(tester);
    await _finoAllaFine(tester);

    // Si esce da una voce che NON e' quella di partenza: quella di partenza
    // torna indietro alla chat che c'e' gia' sotto nella pila.
    final altro = Maestro.fixedOrder.firstWhere((m) => m != Maestro.medora);
    final porta = find.byKey(Key('ask_continue_${altro.id}'));
    await tester.scrollUntilVisible(porta, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(porta);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final trovata = find.byType(MaestroChatScreen);
    expect(trovata, findsOneWidget,
        reason: 'il tocco non ha aperto nessuna chat');
    final aperta = tester.widget<MaestroChatScreen>(trovata);
    expect(aperta.initialUserMessage, isNotNull,
        reason: 'la chat si apre da zero: chi entra trova un Maestro che non '
            'sa niente della domanda a cui ha appena risposto, e deve '
            'riscriverla. Ogni altra arte porta con se\' il suo argomento');
    expect(aperta.initialUserMessage, contains(_tema),
        reason: 'la chat porta qualcosa, ma non la domanda: '
            '"${aperta.initialUserMessage}"');
    // La chat aperta manda davvero quel turno: si lascia finire, altrimenti
    // resta un timer appeso e la prova cade su quello invece che sul difetto.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  });
}

/// Aspetta che tutte e tre le voci siano arrivate: si raccolgono UNA ALLA
/// VOLTA, quindi servono piu' giri di orologio.
Future<void> _finoAllaFine(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Widget _host() => MultiProvider(
      providers: [
        Provider<AppServices>.value(
            value: AppServices(
                ai: _VoceViva(),
                memory: InMemoryMaestroMemoryRepository(),
                memoryPersistent: true)),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(
          child: AskMaestriScreen(starter: Maestro.medora, temaIniziale: _tema),
        ),
      ),
    );

class _VoceViva implements MaestroAiProvider {
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
      'La voce viva di ${maestro.displayName}.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    // **LA VOCE CI METTE DEL TEMPO, come la rete vera.**
    //
    // Senza questa attesa il finto rispondeva dentro lo stesso fotogramma, e
    // lo stato "sta aspettando" non esisteva mai: la prova che sorveglia la
    // carta in attesa girava a vuoto e restava verde con una bolla pulsante
    // rimessa dentro. La rete misurata sta fra 1,41 e 2,09 secondi.
    await Future<void>.delayed(const Duration(seconds: 2));
    return MaestroReply(
      glance: 'Lo sguardo di ${maestro.displayName}.',
      reading: 'La lettura di ${maestro.displayName}, per esteso.',
      invite: 'Il passo di ${maestro.displayName}.',
    );
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      'La sintesi del confronto, che da sola occupa la sua parte di schermo.';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
