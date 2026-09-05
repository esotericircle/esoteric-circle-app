import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_corpus.dart';
import 'package:esoteric_circle/core/archetypes/archetype_quiz.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_test_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_wheel.dart';
import 'package:esoteric_circle/design_system/components/interruttore_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';

/// La schermata del Test Archetipo.
///
/// Il calcolo e' gia' provato nel cuore (`archetype_core_test.dart`): qui si
/// verifica la messa in scena, cioe' che il flusso arrivi in fondo, che il
/// visivo venga prima del testo, che l'Ombra sia la stessa statua trattata e
/// che i limiti e la memoria si comportino.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget host({
    Tier tier = Tier.free,
    DateTime Function()? clock,
    Set<Pianeta> Function(DateTime)? pianeti,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService()..setTier(tier)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          // LO STORICO CONDIVISO, che la schermata NON si costruisce piu' da
          // sola: chi la monta glielo fornisce, qui come nell'app.
          ChangeNotifierProvider(
              create: (_) => ArchetypeHistory(clock: clock)..carica()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: ArchetypeTestScreen(clock: clock, pianetiDelGiorno: pianeti),
          ),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Percorre le dodici domande scegliendo sempre la stessa risposta.
  Future<void> rispondiTutte(WidgetTester tester, int scelta) async {
    for (var i = 0; i < ArchetypeQuiz.tutte.length; i++) {
      await tester.tap(find.byKey(Key('archetype_answer_$scelta')));
      await passo(tester);
    }
  }

  testWidgets('Il flusso arriva in fondo e produce un risultato',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('archetype_start')), findsOneWidget);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);

    // Avanzamento in chiaro, una domanda alla volta.
    expect(find.byKey(const Key('archetype_progress')), findsOneWidget);
    expect(
        tester.widget<Text>(find.byKey(const Key('archetype_progress'))).data,
        '1 di 12');
    expect(find.byKey(const Key('archetype_question')), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(Key('archetype_answer_$i')), findsOneWidget);
    }

    await rispondiTutte(tester, 3);
    expect(find.byKey(const Key('archetype_result')), findsOneWidget);

    // Rispondendo sempre per quarta il dominante e' il Realista, e il cuore lo
    // ha gia' dimostrato: qui si verifica che a video arrivi lo stesso.
    final atteso = ArchetypeScoring.calcola(List.filled(12, 3));
    expect(atteso.dominante, Archetype.realista);
    expect(tester.widget<Text>(find.byKey(const Key('archetype_name'))).data,
        'IL REALISTA');
  });

  testWidgets('Il visivo viene prima del testo, e la ruota ha dodici raggi',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    final statua = find.byKey(const Key('archetype_statue_realista'));
    final ruota = find.byKey(const Key('archetype_wheel'));
    final nome = find.byKey(const Key('archetype_name'));
    final luce = find.byKey(const Key('archetype_luce'));
    expect(ruota, findsOneWidget);
    // L'ordine e' statua, ruota, nome, primo testo: il visivo prima della
    // parola, e la statua NON e' dentro la ruota ma sopra.
    expect(tester.getCenter(statua.first).dy,
        lessThan(tester.getCenter(ruota).dy));
    expect(tester.getCenter(ruota).dy, lessThan(tester.getCenter(nome).dy));
    expect(tester.getCenter(nome).dy, lessThan(tester.getCenter(luce).dy));
    // La ruota non contiene la statua.
    expect(
      find.descendant(
          of: ruota,
          matching: find.byKey(const Key('archetype_statue_realista'))),
      findsNothing,
    );

    // I dodici raggi sono i dodici archetipi: la ruota li disegna tutti.
    expect(Archetype.values.length, 12);
    final w = tester.widget<ArchetypeWheel>(find.byType(ArchetypeWheel));
    expect(w.profilo.percentuali.length, 12);
    expect(w.profilo.dominante, Archetype.realista);
  });

  testWidgets('I cinque testi vengono dal corpus, nell\'ordine giusto',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    final r = ArchetypeCorpus.di(Archetype.realista);
    expect(find.text(r.luce), findsOneWidget);
    expect(find.text(r.ombra), findsOneWidget);
    expect(find.text(r.amore), findsOneWidget);
    expect(find.text(r.lavoro), findsOneWidget);
    expect(find.text(r.quotidianita), findsOneWidget);
    expect(find.text(r.essenza), findsOneWidget);

    // Ordine dall'alto: Luce, le tre stanze della vita, poi l'Ombra.
    final luce = tester.getCenter(find.byKey(const Key('archetype_luce'))).dy;
    final amore = tester.getCenter(find.byKey(const Key('archetype_amore'))).dy;
    final lavoro =
        tester.getCenter(find.byKey(const Key('archetype_lavoro'))).dy;
    final quot =
        tester.getCenter(find.byKey(const Key('archetype_quotidianita'))).dy;
    final ombra = tester.getCenter(find.byKey(const Key('archetype_ombra'))).dy;
    expect(luce, lessThan(amore));
    expect(amore, lessThan(lavoro));
    expect(lavoro, lessThan(quot));
    expect(quot, lessThan(ombra));
  });

  testWidgets('La classifica dei dodici sta prima dei pulsanti, ordinata',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // Dodici righe, una per archetipo, sola lettura.
    expect(find.byKey(const Key('archetype_ranking')), findsOneWidget);
    for (final a in Archetype.values) {
      expect(find.byKey(Key('archetype_rank_${a.name}')), findsOneWidget);
    }

    // Il primo della classifica e' il dominante, e sta sopra gli altri.
    final profilo = ArchetypeScoring.calcola(List.filled(12, 3));
    final ordinati = profilo.graduatoria;
    final primo = tester
        .getCenter(find.byKey(Key('archetype_rank_${ordinati.first.name}')))
        .dy;
    final secondo = tester
        .getCenter(find.byKey(Key('archetype_rank_${ordinati[1].name}')))
        .dy;
    expect(ordinati.first, Archetype.realista);
    expect(primo, lessThan(secondo));

    // La classifica sta sopra i pulsanti finali.
    //
    // **LA CHIAVE E CAMBIATA, ordine CG voci 06 e 08**: Condividi non e piu
    // un pulsante di questa schermata, viene da AzioniDelResponso, che e la
    // porta sola per tutte e tredici le arti col responso. Cio che questa
    // riga misura non cambia: la classifica sta sopra i comandi.
    final ranking =
        tester.getCenter(find.byKey(const Key('archetype_ranking'))).dy;
    final share =
        tester.getCenter(find.byKey(const Key('responso_condividi'))).dy;
    expect(ranking, lessThan(share));
  });

  testWidgets('L\'Ombra e\' la stessa statua, trattata', (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // Stesso archetipo, quindi stesso asset: cambia solo il trattamento.
    final ombra = find.byKey(const Key('archetype_shadow_statue_realista'));
    expect(ombra, findsOneWidget);
    expect(
      find.descendant(of: ombra, matching: find.byType(ColorFiltered)),
      findsOneWidget,
    );
    final img = tester.widget<Image>(
        find.descendant(of: ombra, matching: find.byType(Image)));
    expect((img.image as AssetImage).assetName, Archetype.realista.artePiena);
  });

  testWidgets('Il selettore transiti modula e mostra le motivazioni',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      pianeti: (_) => {Pianeta.marte, Pianeta.urano},
    ));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // Spento di partenza: nessuna riga di transito.
    final sw = find.byKey(const Key('archetype_transits_switch'));
    // L'interruttore adesso e' quello del design system e non lo Switch di
    // Material: erano gli unici due elementi che sembravano venire da un'altra
    // app, grigi e viola dentro una schermata tutta oro e verde.
    expect(tester.widget<InterruttoreDelCerchio>(sw).acceso, isFalse);
    expect(find.byKey(const Key('archetype_transit_marte')), findsNothing);

    await tester.ensureVisible(sw);
    await tester.pump();
    await tester.tap(sw);
    await passo(tester);

    expect(find.byKey(const Key('archetype_transit_marte')), findsOneWidget);
    expect(find.byKey(const Key('archetype_transit_urano')), findsOneWidget);
    expect(find.byKey(const Key('archetype_synchronicity')), findsOneWidget);
    // Le righe sono quelle che produce il cuore, non un testo scritto qui.
    final atteso = ArchetypeTransits.applica(
        ArchetypeScoring.calcola(List.filled(12, 3)),
        {Pianeta.marte, Pianeta.urano});
    expect(find.text(atteso.motivazioni.first.testo), findsOneWidget);
  });

  testWidgets('Il limite blocca il test in piu\' e mostra l\'ultimo salvato',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Un Viandante ha un test al giorno: il primo passa.
    await tester.pumpWidget(host(tier: Tier.free));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);
    expect(find.byKey(const Key('archetype_result')), findsOneWidget);

    // Rientrando, il secondo test non si puo' fare e non c'e' un vicolo
    // cieco: si vede il proprio archetipo. Si smonta prima, altrimenti lo
    // State della schermata sopravvive e resta sul risultato.
    //
    // **QUESTA PROVA E' CAMBIATA DI FORMA, ordine AO voce 06, e la sostanza
    // e' cresciuta.** Pretendeva `archetype_blocked`, cioe' il riquadro del
    // limite giornaliero con l'ultimo responso. Adesso chi ha gia' un
    // archetipo trova la LETTURA DI OGGI col suo emblema, piu' la data in
    // cui potra' rifare il test: e' la stessa promessa, mai un vicolo cieco,
    // mantenuta meglio. Il riquadro del limite non compare piu' perche' non
    // si arriva piu' li': l'attesa di tre mesi scatta prima del tetto
    // giornaliero.
    await tester.pumpWidget(const SizedBox.shrink());
    await passo(tester);
    await tester.pumpWidget(host(tier: Tier.free));
    await passo(tester);
    expect(find.byKey(const Key('archetype_start')), findsNothing);
    expect(find.byKey(const Key('archetype_lettura_di_oggi')), findsOneWidget,
        reason: 'chi ha gia\' fatto il test non vede il suo archetipo');
    expect(find.byKey(const Key('archetype_attesa')), findsOneWidget,
        reason: 'non si dice quando si potra\' rifare');
    expect(find.text('Il Realista'), findsWidgets);
  });

  testWidgets('Alla seconda volta compare il confronto con la precedente',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // **DUE TEST A TRE MESI DI DISTANZA, e non piu' due giorni. Ordine AO
    // voce 06.** La decisione di Mauro del 18 agosto 2026 dice che il test
    // si rifa' dopo tre mesi: rifarlo il giorno dopo era la slot machine che
    // quella decisione ha escluso. Questa prova non e' stata allentata, e'
    // stata portata sul tempo vero della regola nuova: cio' che misura, il
    // confronto con la volta precedente, e' identico.
    var oggi = DateTime(2026, 7, 20, 10);
    await tester.pumpWidget(host(tier: Tier.tier2, clock: () => oggi));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3); // Realista
    expect(find.byKey(const Key('archetype_comparison')), findsNothing);

    oggi = DateTime(2026, 10, 20, 10);
    await tester.pumpWidget(const SizedBox.shrink());
    await passo(tester);
    await tester.pumpWidget(host(tier: Tier.tier2, clock: () => oggi));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 0); // un dominante diverso

    final confronto = find.byKey(const Key('archetype_comparison'));
    expect(confronto, findsOneWidget);
    final testo = tester.widget<Text>(confronto).data!;
    expect(testo, contains('L\'ultima volta eri soprattutto Realista'));
    expect(find.byKey(const Key('archetype_timeline')), findsOneWidget);
  });

  testWidgets('Fonti e metodo apre il testo del corpus', (tester) async {
    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_sources')));
    await passo(tester);
    expect(find.byKey(const Key('archetype_sources_sheet')), findsOneWidget);
    expect(find.text(ArchetypeCorpus.fontiEMetodo), findsOneWidget);
  });

  test('La rotta dell\'arte porta alla schermata vera, non alla soglia', () {
    final r = artRouteFor('archetype_test');
    expect(r, isNotNull);
    expect(artiSullaSoglia.containsKey('archetype_test'), isFalse);
  });

  test('Il cielo del giorno dichiara solo i pianeti che sa calcolare', () {
    // Nel progetto non esiste un motore per i dieci pianeti: si restituisce
    // quel che e' vero, il Sole sempre e la Luna quando e' abbastanza piena.
    final p = ArchetypeSky.pianetiDelGiorno(DateTime(2026, 7, 22));
    expect(p, contains(Pianeta.sole));
    expect(p.length, lessThanOrEqualTo(ArchetypeSky.pianetiCalcolabili));
    // Deterministico sul giorno: l'ora non cambia l'esito.
    expect(ArchetypeSky.pianetiDelGiorno(DateTime(2026, 7, 22, 3)),
        ArchetypeSky.pianetiDelGiorno(DateTime(2026, 7, 22, 23)));
  });

  test('Ogni archetipo ha il nome con l\'articolo giusto', () {
    expect(Archetype.innocente.conArticolo, 'L\'Innocente');
    expect(Archetype.eroe.conArticolo, 'L\'Eroe');
    expect(Archetype.amante.conArticolo, 'L\'Amante');
    expect(Archetype.esploratore.conArticolo, 'L\'Esploratore');
    expect(Archetype.realista.conArticolo, 'Il Realista');
    expect(Archetype.saggio.conArticolo, 'Il Saggio');
    expect(Archetype.sovrano.conArticolo, 'Il Sovrano');
    // Tutti coprono l'elisione o l'articolo pieno, nessuno vuoto.
    for (final a in Archetype.values) {
      expect(a.conArticolo.endsWith(a.nome), isTrue, reason: a.name);
    }
  });

  test('La Luce del corpus e\' il testo lungo arricchito', () {
    for (final a in Archetype.values) {
      expect(ArchetypeCorpus.di(a).luce.length, greaterThan(180),
          reason: a.name);
    }
    expect(ArchetypeCorpus.di(Archetype.realista).luce,
        contains('senza smettere di essere umano'));
  });

  testWidgets('La scelta del cielo sta sulla soglia, prima delle domande',
      (tester) async {
    await tester.pumpWidget(host());
    await passo(tester);
    // L'interruttore del cielo si vede prima di cominciare.
    expect(find.byKey(const Key('archetype_sky_setting')), findsOneWidget);
    expect(find.byKey(const Key('archetype_question')), findsNothing);
  });

  testWidgets('Sul responso l\'interruttore vivo rilegge col cielo',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester
        .pumpWidget(host(pianeti: (_) => {Pianeta.marte, Pianeta.urano}));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // Nasce senza cielo, e lo dichiara il sottotitolo.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('archetype_mode_subtitle')))
            .data,
        'non legato ai transiti astrologici');
    final sw = find.byKey(const Key('archetype_transits_switch'));
    await tester.ensureVisible(sw);
    await tester.pump();
    await tester.tap(sw);
    await passo(tester);
    // Ora rilegge col cielo, senza rifare il test.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('archetype_mode_subtitle')))
            .data,
        'legato ai transiti astrologici di oggi');
    expect(find.byKey(const Key('archetype_transit_marte')), findsOneWidget);
  });

  testWidgets('Il pulsante Parlane con Aura e\' nel verde di Aura',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    final verde = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    // Stessa ragione della riga sopra: il pulsante verso Aura adesso nasce
    // dalla porta sola, e il verde di Aura ci arriva dalla palette.
    final btn =
        tester.widget<FilledButton>(find.byKey(const Key('responso_parlane')));
    final bg = btn.style!.backgroundColor!.resolve({});
    // **IL VERDE DI AURA PORTATO ALLA SOGLIA, e non piu' il token nudo.**
    // Ordine CO voce 14, coda del 3 settembre 2026.
    //
    // Questa riga pretendeva `verde.primary` esatto, ed era il modo di dire
    // "il pulsante porta il colore di Aura e non il viola neutro". Giusto
    // come intenzione, sbagliato come misura: **legava la guardia al valore
    // del token invece che al fatto**, e il giorno che quel valore e' dovuto
    // passare da una porta la guardia e' caduta pur essendo il pulsante piu'
    // giusto di prima.
    //
    // Il verde di Aura e' il piu' luminoso dei tre primari: con l'inchiostro
    // chiaro sopra misurava **2,84 a uno**, contro il 6,89 di Medora e il
    // 5,88 di Caligo. Adesso il riempimento passa da `portatoSu`, che lo
    // scurisce finche' la sua etichetta non si legge, e chi e' gia' sopra
    // soglia torna indietro identico.
    expect(bg, AccentoDelMaestro.portatoSu(verde.primary, verde.onPrimary),
        reason: 'il riempimento non e piu il verde di Aura portato alla '
            'soglia: o e tornato il token nudo, che con la sua etichetta '
            'sopra misura 2,84, o e diventato un colore che con Aura non '
            'c entra');
    // Il verde di Aura non e' il viola neutro.
    expect(bg, isNot(ColorTokens.neutralPrimary));
    // **E L'ETICHETTA CI SI DEVE LEGGERE SOPRA, che e' la cosa per cui il
    // colore esiste.** E' la misura che mancava: nessuno chiedeva che il
    // testo del pulsante si leggesse sul pulsante, e per Aura non si leggeva.
    final fg = btn.style!.foregroundColor!.resolve({})!;
    expect(AccentoDelMaestro.contrastoFra(fg, bg!), greaterThanOrEqualTo(4.5),
        reason: 'l etichetta del pulsante non si legge sul suo stesso '
            'riempimento: il contrasto qui non dipende da cosa c e dietro, e '
            'fra le due parti del pulsante');
  });

  testWidgets('La statua si volta nell\'Ombra al tocco', (tester) async {
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // In cima la statua piena; toccandola diventa la stessa in Ombra.
    expect(find.byKey(const Key('archetype_statue_realista')), findsWidgets);
    await tester.tap(find.byKey(const Key('archetype_statue_realista')).first);
    await passo(tester);
    // Ora in cima c'e' la versione in ombra (oltre a quella fissa della card Ombra).
    expect(find.byKey(const Key('archetype_shadow_statue_realista')),
        findsWidgets);
  });

  testWidgets('La card condivisibile si genera col dominante', (tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        child: ArchetypeShareCard(
            profilo: ArchetypeScoring.calcola(List.filled(12, 3))),
      ),
    ));
    await tester.pump();
    final profilo = ArchetypeScoring.calcola(List.filled(12, 3));
    expect(find.byKey(const Key('archetype_share_card')), findsOneWidget);
    expect(find.text('IL REALISTA'), findsOneWidget);
    expect(find.text(ArchetypeCorpus.di(Archetype.realista).essenza),
        findsOneWidget);
    // La ruota e' quella vera del risultato, coi nomi e col co-dominante acceso.
    final ruota = tester.widget<ArchetypeWheel>(find.byType(ArchetypeWheel));
    expect(ruota.etichette, isTrue);
    expect(ruota.accendiSecondo, isTrue);
    // La bolla della Luce col testo dal corpus.
    expect(find.text('La sua luce'), findsOneWidget);
    expect(
        find.text(ArchetypeCorpus.di(Archetype.realista).luce), findsOneWidget);

    // Provenienza in alto e invito in fondo, senza indirizzi web inventati.
    expect(find.text('TEST ARCHETIPO'), findsOneWidget);
    expect(find.text('Scopri il tuo archetipo su Esoteric Circle'),
        findsOneWidget);
    expect(find.text('Esoteric Circle · Aura'), findsOneWidget);

    // Il responso sulla card: percentuale del dominante e co-dominante.
    final pct = profilo.percentualeDi(Archetype.realista).round();
    expect(profilo.secondo, isNotNull);
    expect(find.text('$pct% · accanto ${profilo.secondo!.conArticolo}'),
        findsOneWidget);

    // La classifica compatta dei primi tre: nome e percentuale per ciascuno.
    for (final a in profilo.graduatoria.take(3)) {
      expect(find.text(a.nome), findsWidgets);
      expect(find.text('${profilo.percentualeDi(a).round()}%'), findsWidgets);
    }
  });
}
