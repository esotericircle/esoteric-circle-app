// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/il_titolo_della_gettata.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LE RUNE HANNO LA FORMA NUOVA.** Ordine GA voci GA.03, GA.04, GA.05 e
/// GA.07, 20 ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026 alle 23:08: *"tutte le risposte composte da
/// paragrafi ognuno con tra 40 a 50 parole ognuno. Per le risposte brevi 2
/// paragrafi di cui il secondo messo in evidenza in un riquadro e questo
/// riquadro deve intitolarsi "cosa fare adesso" e di conseguenza adattare il
/// testo. Per le risposte lunghe aggiungi 2 paragrafi sempre con il primo in
/// riquadro. Sotto sempre il paragrafo in corsivo "da dove viene". Restano
/// all'inizio i titoli, anche per le singola carte o le singole rune."*; 20
/// ottobre 2026 alle 00:10: *"Profondità lunga solo dal tier 1 e solo per il
/// responso principale e non per le singole carte"*; alle 00:16: *"Per le
/// rune 'il galdr propiziatorio'"*.
///
/// **DUE META'.** La prima compone presagi veri dal corpus vero, in tutte e
/// quattro le gettate, con ogni valore di `{cosa}`, Breve e Lunga, e pretende
/// la forma: nessun difetto di `ResponsoInterpretato.difetti`, il titolo
/// dalla pietra che decide, il galdr giusto nella Lunga, le schede brevi e
/// senza difetti. La seconda monta la schermata vera e guarda cio' che si
/// vede: il titolo, "Cosa fare adesso", "Il galdr propiziatorio" nella
/// Lunga, il lucchetto nella Breve, "Da dove viene" in corsivo una volta
/// sola, nessuna chiamata al modello, e nessun presagio della gettata di
/// prima dopo "Getta ancora".
void main() {
  /// Le domande che danno ogni valore di `{cosa}`: nessuna domanda, le
  /// dodici del Cerchio, una per famiglia di parole e una che l'app non
  /// riconosce ("ciò che hai chiesto").
  final domande = <String>[
    '',
    for (final d in DomandeDelCerchio.generichePerLaGettata) d.testo,
    for (final d in DomandeDelCerchio.personaliPerLaGettata) d.testo,
    'Il mio amore tornerà da me?',
    'Il colloquio di domani andrà bene?',
    'Devo cambiare casa quest’anno?',
    'Con mio fratello come andrà?',
    'Un amico mi ha deluso, che faccio?',
    'I soldi messi da parte bastano?',
    'Passerò l’esame di settembre?',
    'Quale decisione prendere?',
    'Che cosa mi aspetta?',
  ];

  test(
      'LA FORMA SUI PRESAGI VERI: quattro gettate, ogni {cosa}, Breve e '
      'Lunga, il titolo dalla pietra che decide e il galdr giusto', () {
    expect(corpusDelPresagio.completo, isTrue);
    final difetti = <String>[];
    final cose = <String>{};
    var composti = 0;
    var schede = 0;
    var lunghi = 0;
    for (final gettata in gettate) {
      for (var seme = 0; seme < 24; seme++) {
        final esito = RuneCast.getta(gettata, random: Random(seme));
        final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
        for (final domanda in domande) {
          cose.add(IlPresagioDalCorpus.cosaDellaDomanda(domanda));
          for (final lunga in const [false, true]) {
            final p = IlPresagioDalCorpus.componi(
              corpus: corpusDelPresagio,
              esito: esito,
              domanda: domanda,
              persona: 'persona-$seme',
              oggi: DateTime(2026, 10, 20),
              memoria: LaMemoriaDelPresagio(),
              lunga: lunga,
              forma: CourtesyForm.values[seme % CourtesyForm.values.length],
            );
            composti++;
            final r = p.principale;
            final dove = '${gettata.id}, seme $seme, "$domanda", '
                '${lunga ? 'Lunga' : 'Breve'}';
            for (final d in r.difetti()) {
              difetti.add('$dove: $d');
            }
            if (r.titolo != decide.riga.trim() ||
                r.titolo != IlTitoloDellaGettata.di(esito)) {
              difetti.add('$dove: il titolo «${r.titolo}» non e\' la riga '
                  'della pietra che decide, ${decide.rune.name}');
            }
            if (lunga) {
              lunghi++;
              final galdr = IRitiPropiziatori.rito(IRitiPropiziatori.galdr, [
                decide.rune.name,
                decide.inOmbra ? 'in ombra' : 'dritta',
              ]);
              if (galdr == null || r.rito != galdr) {
                difetti.add('$dove: il galdr non e\' quello di '
                    '${decide.rune.name} ${decide.inOmbra ? 'in ombra' : 'dritta'}');
              }
              if (r.approfondimento == null) {
                difetti.add('$dove: la Lunga senza approfondimento');
              }
              if (!r.daDoveViene!.contains('Thorsson')) {
                difetti.add('$dove: il "Da dove viene" della Lunga non dice '
                    'da dove viene il galdr');
              }
            } else if (r.rito != null || r.approfondimento != null) {
              difetti.add('$dove: la Breve porta i paragrafi della Lunga');
            }
            for (final pietra in esito.rune) {
              if (!r.daDoveViene!.contains(pietra.rune.name)) {
                difetti.add('$dove: il "Da dove viene" non cita '
                    '${pietra.rune.name}');
              }
            }
            final tutto = [...r.paragrafi, r.titolo, r.daDoveViene!];
            if (esito.rune.length == 1) {
              if (p.schede.isNotEmpty) {
                difetti.add('$dove: la Runa di Odino ha una scheda in piu\'');
              }
            } else if (p.schede.length != esito.rune.length) {
              difetti.add('$dove: ${p.schede.length} schede per '
                  '${esito.rune.length} pietre');
            }
            for (var i = 0; i < p.schede.length; i++) {
              schede++;
              final s = p.schede[i];
              final pietra = esito.rune[i];
              for (final d in s.difetti(conLaFonte: false)) {
                difetti.add('$dove, scheda di ${pietra.rune.name}: $d');
              }
              if (s.lungo || s.daDoveViene != null) {
                difetti.add('$dove, scheda di ${pietra.rune.name}: non e\' '
                    'breve o porta la fonte');
              }
              if (s.titolo != pietra.riga.trim()) {
                difetti.add('$dove, scheda di ${pietra.rune.name}: il titolo '
                    'non e\' la riga della runa');
              }
              if (!s.risposta.contains(pietra.rune.name)) {
                difetti.add('$dove, scheda di ${pietra.rune.name}: il '
                    'paragrafo non nomina la sua runa');
              }
              tutto.addAll(s.paragrafi);
            }
            for (final testo in tutto) {
              if (testo.contains('{') || testo.contains('[')) {
                difetti.add('$dove: uno spazio o una marca non riempiti in '
                    '«$testo»');
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCI 03-07, LE RUNE: presagi composti $composti (lunghi '
        '$lunghi), schede $schede, valori di {cosa} ${cose.length}, difetti '
        '${difetti.length}');
    cardinaleMinimo(composti, 4 * 24 * 2 * 20,
        cosa: 'presagi composti dal corpus vero',
        perche: 'quattro gettate, ventiquattro semi, Breve e Lunga, almeno '
            'venti domande');
    cardinaleMinimo(cose.length, 20,
        cosa: 'valori di {cosa} percorsi',
        perche: 'venti valori diversi nel compositore al 20 ottobre 2026 '
            '(SPECIFICA.md, sezione 2)');
    cardinaleMinimo(schede, 3 * 24 * 2 * 20 * 3,
        cosa: 'schede delle rune composte',
        perche: 'Norne, Croce e telo, almeno tre pietre ciascuna');
    expect(difetti, isEmpty, reason: difetti.take(20).join('\n'));
  });

  test(
      'LA MEMORIA DI PRIMA: dal testo senza versione restano solo le voci '
      'lette', () {
    const vecchia = '{"letti":{"risposta/Fehu/dritta/3":"2026-10-19"},'
        '"giornoDiOggi":"2026-10-20",'
        '"diOggi":{"odino|Fehu/dritta|":["risposta/Fehu/dritta/3"]}}';
    final m = LaMemoriaDelPresagio.daTesto(vecchia);
    expect(m.letti, {'risposta/Fehu/dritta/3': '2026-10-19'});
    expect(m.diOggi, isEmpty,
        reason: 'il presagio di oggi della forma di prima e\' un elenco in '
            'posizione fissa: letto con la regola nuova scambierebbe le parti');
    final nuova = LaMemoriaDelPresagio.daTesto(m.comeTesto());
    expect(nuova.letti, m.letti);
    expect(m.comeTesto(), contains('"versione":2'));
  });

  // -------------------------------------------------------------------------
  // A VIDEO
  // -------------------------------------------------------------------------

  void silenziaISensori(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
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

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<_IlModelloCheConta> monta(WidgetTester tester, Tier piano,
      {Duration disco = Duration.zero}) async {
    SharedPreferences.setMockInitialValues({});
    silenziaISensori(tester);
    tester.view.physicalSize = const Size(430, 6400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final modello = _IlModelloCheConta();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices?>.value(
            value: AppServices(
          ai: modello,
          memory: InMemoryMaestroMemoryRepository(),
          memoryPersistent: false,
        )),
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: piano)),
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance()..ilServerHaParlato()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        // **IL DISCO LENTO**, quando la prova lo chiede: il telefono vero
        // impiega un tempo a leggere e scrivere la memoria del presagio, e
        // in quel tempo la bolla non deve mostrare un testo sbagliato.
        home: RuneDrawScreen(
          random: Random(3),
          preferenze: disco == Duration.zero
              ? null
              : () => Future<SharedPreferences>.delayed(
                  disco, SharedPreferences.getInstance),
        ),
      ),
    ));
    await passo(tester);
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    await passo(tester);
    final getta = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(getta);
    await tester.pump();
    await tester.tap(getta);
    await passo(tester);
    return modello;
  }

  String testoDi(WidgetTester tester, Key chiave) {
    final testi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(chiave), matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .toList();
    if (testi.isNotEmpty) return testi.join(' ');
    final w = tester.widget(find.byKey(chiave));
    return w is Text ? (w.data ?? '') : '';
  }

  testWidgets(
      'A VIDEO, L\'INIZIATO: il titolo, Cosa fare adesso, il galdr, le schede '
      'brevi, Da dove viene in corsivo una volta, zero modello',
      (tester) async {
    expect(PlanCatalog.apre(RigaDelPiano.runeLunga, Tier.tier1), isTrue);
    final modello = await monta(tester, Tier.tier1);
    final esito = RuneCast.getta(gettataNorne, random: Random(3));
    final bolla = find.byKey(const Key('rune_presage'));
    expect(bolla, findsOneWidget);
    expect(find.byKey(const Key('rune_presage_attesa')), findsNothing,
        reason: 'il presagio non e\' arrivato a video');
    expect(testoDi(tester, const Key('rune_presage_titolo')),
        IlTitoloDellaGettata.di(esito),
        reason: 'il titolo a video non e\' la riga della pietra che decide');
    expect(find.descendant(of: bolla, matching: find.text('Cosa fare adesso')),
        findsOneWidget);
    expect(
        find.descendant(
            of: bolla, matching: find.text('Il galdr propiziatorio')),
        findsOneWidget,
        reason: 'la Lunga dell\'Iniziato non porta il riquadro del galdr');
    expect(
        find.byKey(const Key('rune_presage_approfondimento')), findsOneWidget);
    expect(find.byKey(const Key('rune_lucchetto_lunga')), findsNothing);
    final paragrafi = [
      for (final k in const [
        'rune_presage_risposta',
        'rune_presage_cosa_fare',
        'rune_presage_approfondimento',
        'rune_presage_rito',
      ])
        testoDi(tester, Key(k)),
    ];
    for (final p in paragrafi) {
      final n = LaFormaDelResponso.parole(p);
      expect(n, inInclusiveRange(40, 50), reason: 'a video $n parole: «$p»');
    }
    // Le tre schede, ognuna col suo titolo e il suo riquadro.
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(Key('rune_scheda_${i}_titolo')), findsOneWidget);
      expect(find.byKey(Key('rune_scheda_${i}_cosa_fare')), findsOneWidget);
      expect(find.byKey(Key('rune_scheda_${i}_rito')), findsNothing,
          reason: 'la scheda di una runa ha sempre la forma breve');
    }
    expect(find.text('Cosa fare adesso'), findsNWidgets(4));
    // Il "Da dove viene": una volta sola, in corsivo, in fondo.
    expect(find.text('Da dove viene'), findsOneWidget);
    final fonte = tester
        .widget<Text>(find.byKey(const Key('rune_presage_da_dove_viene')));
    expect(fonte.style?.fontStyle, FontStyle.italic);
    expect(fonte.data, contains('Thorsson'));
    expect(
        find.descendant(
            of: bolla,
            matching: find.byKey(const Key('rune_presage_da_dove_viene'))),
        findsNothing,
        reason: 'il "Da dove viene" sta in fondo alla consultazione, non '
            'nella bolla');
    expect(modello.presagi, 0, reason: 'le rune hanno chiamato il modello');
    print('ORDINE GA, LE RUNE A VIDEO (Iniziato): parole dei paragrafi '
        '${paragrafi.map(LaFormaDelResponso.parole).toList()}');
  });

  testWidgets(
      'A VIDEO, IL VIANDANTE: la Breve col lucchetto della Lunga, mai un '
      'vicolo cieco', (tester) async {
    expect(PlanCatalog.apre(RigaDelPiano.runeLunga, Tier.free), isFalse);
    final modello = await monta(tester, Tier.free);
    final bolla = find.byKey(const Key('rune_presage'));
    expect(find.descendant(of: bolla, matching: find.text('Cosa fare adesso')),
        findsOneWidget);
    expect(find.text('Il galdr propiziatorio'), findsNothing);
    expect(find.byKey(const Key('rune_presage_approfondimento')), findsNothing);
    expect(find.byKey(const Key('rune_lucchetto_lunga')), findsOneWidget,
        reason: 'il Viandante non vede che la Lunga esiste');
    expect(find.text('Da dove viene'), findsOneWidget);
    expect(modello.presagi, 0);
  });

  testWidgets(
      'GETTA ANCORA NON MOSTRA IL PRESAGIO DI PRIMA, nemmeno mentre il disco '
      'scrive', (tester) async {
    // **IL DIFETTO, e il suo padre e' l'ordine EX voce 03.** Nel ramo del
    // corpus l'attesa non si accendeva e il presagio vecchio non si
    // azzerava: finche' la composizione non tornava dal disco, la bolla
    // mostrava la lettura di casa alla prima gettata e il presagio della
    // gettata PRECEDENTE dopo "Getta ancora". Col disco istantaneo delle
    // prove non si vede; con trecento millesimi di disco si vede.
    const disco = Duration(milliseconds: 300);
    await monta(tester, Tier.tier1, disco: disco);
    await tester.pump(disco);
    await passo(tester);
    final prima = testoDi(tester, const Key('rune_presage_risposta'));
    expect(prima, isNotEmpty, reason: 'la prima gettata non ha un presagio');
    final ancora = find.byKey(const Key('rune_recast'));
    await tester.ensureVisible(ancora);
    await tester.pump();
    await tester.tap(ancora);
    // Il primo fotogramma dopo il tocco, e un altro a meta' della scrittura.
    final visti = <String>[];
    for (final attesa in const [Duration.zero, Duration(milliseconds: 150)]) {
      await tester.pump(attesa);
      visti.add(
          find.byKey(const Key('rune_presage_risposta')).evaluate().isEmpty
              ? ''
              : testoDi(tester, const Key('rune_presage_risposta')));
    }
    final conLAttesa =
        find.byKey(const Key('rune_presage_attesa')).evaluate().isNotEmpty;
    print('ORDINE GA, IL LAMPO: mentre il disco scrive la bolla mostra '
        '${visti.map((v) => v.isEmpty ? 'l’attesa' : v == prima ? 'IL PRESAGIO DI PRIMA' : 'un presagio nuovo').toList()}');
    expect(visti.where((v) => v == prima), isEmpty,
        reason: 'dopo Getta ancora la bolla mostra il presagio della gettata '
            'di prima mentre il disco scrive');
    expect(conLAttesa, isTrue,
        reason: 'mentre il presagio si compone la bolla non mostra l’attesa');
    await tester.pump(disco);
    await passo(tester);
    final dopo = testoDi(tester, const Key('rune_presage_risposta'));
    expect(dopo, isNotEmpty);
    expect(dopo == prima, isFalse);
  });
}

/// Un modello pronto che conta i presagi chiesti. Il resto dell'interfaccia
/// qui non serve.
class _IlModelloCheConta implements MaestroAiProvider {
  int presagi = 0;

  @override
  bool get isReady => true;

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async {
    presagi++;
    throw const MaestroAiUnavailable();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
