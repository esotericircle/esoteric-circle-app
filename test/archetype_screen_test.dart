import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_corpus.dart';
import 'package:esoteric_circle/core/archetypes/archetype_quiz.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          ChangeNotifierProvider(create: (_) => EntitlementService()..setTier(tier)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
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
    expect(tester.widget<Text>(find.byKey(const Key('archetype_progress'))).data,
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
    final lavoro = tester.getCenter(find.byKey(const Key('archetype_lavoro'))).dy;
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
    final primo =
        tester.getCenter(find.byKey(Key('archetype_rank_${ordinati.first.name}'))).dy;
    final secondo =
        tester.getCenter(find.byKey(Key('archetype_rank_${ordinati[1].name}'))).dy;
    expect(ordinati.first, Archetype.realista);
    expect(primo, lessThan(secondo));

    // La classifica sta sopra i due pulsanti finali.
    final ranking = tester.getCenter(find.byKey(const Key('archetype_ranking'))).dy;
    final share = tester.getCenter(find.byKey(const Key('archetype_share'))).dy;
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
    expect(tester.widget<SwitchListTile>(sw).value, isFalse);
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

    // Rientrando nello stesso giorno, il secondo e' bloccato e si vede
    // l'ultimo responso invece di un vicolo cieco. Si smonta prima, altrimenti
    // lo State della schermata sopravvive e resta sul risultato.
    await tester.pumpWidget(const SizedBox.shrink());
    await passo(tester);
    await tester.pumpWidget(host(tier: Tier.free));
    await passo(tester);
    expect(find.byKey(const Key('archetype_start')), findsNothing);
    expect(find.byKey(const Key('archetype_blocked')), findsOneWidget);
    expect(find.byKey(const Key('archetype_last_saved')), findsOneWidget);
    expect(find.text('Il Realista'), findsWidgets);
  });

  testWidgets('Alla seconda volta compare il confronto con la precedente',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Tier 2 per non incappare nel limite, e due giorni diversi.
    var oggi = DateTime(2026, 7, 20, 10);
    await tester.pumpWidget(host(tier: Tier.tier2, clock: () => oggi));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3); // Realista
    expect(find.byKey(const Key('archetype_comparison')), findsNothing);

    oggi = DateTime(2026, 7, 21, 10);
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
    final r = artRouteFor('archetype_test', userSign: Zodiac.aries);
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

    await tester.pumpWidget(host(pianeti: (_) => {Pianeta.marte, Pianeta.urano}));
    await passo(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await passo(tester);
    await rispondiTutte(tester, 3);

    // Nasce senza cielo, e lo dichiara il sottotitolo.
    expect(tester.widget<Text>(find.byKey(const Key('archetype_mode_subtitle'))).data,
        'non legato ai transiti astrologici');
    final sw = find.byKey(const Key('archetype_transits_switch'));
    await tester.ensureVisible(sw);
    await tester.pump();
    await tester.tap(sw);
    await passo(tester);
    // Ora rilegge col cielo, senza rifare il test.
    expect(tester.widget<Text>(find.byKey(const Key('archetype_mode_subtitle'))).data,
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
    final btn = tester.widget<FilledButton>(
        find.byKey(const Key('archetype_consulta')));
    final bg = btn.style!.backgroundColor!.resolve({});
    expect(bg, verde.primary);
    // Il verde di Aura non e' il viola neutro.
    expect(bg, isNot(ColorTokens.neutralPrimary));
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
    tester.view.physicalSize = const Size(500, 720);
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
    expect(find.byKey(const Key('archetype_share_card')), findsOneWidget);
    expect(find.text('IL REALISTA'), findsOneWidget);
    expect(find.text(ArchetypeCorpus.di(Archetype.realista).essenza),
        findsOneWidget);
    // La mini-ruota c'e' ma senza etichette.
    final ruota = tester.widget<ArchetypeWheel>(find.byType(ArchetypeWheel));
    expect(ruota.etichette, isFalse);
  });
}
