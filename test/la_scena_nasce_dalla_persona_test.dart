import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:firebase_ai/firebase_ai.dart' show ThinkingLevel;
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LA SCENA NASCE DALLA PERSONA, NON DA UN HASH.** Ordine DI voce 03,
/// 12 settembre 2026.
///
/// **La misura dell'ordine:** la via buona non era montata, e la scena la
/// sceglievano quattro divisioni intere su un hash. Adesso la sceglie il
/// modello dal vocabolario chiuso, con cio' che si sa della persona.
///
/// **Qui il modello e' una finta**, e deve esserlo: in una prova Firebase non
/// c'e'. La finta **registra cio' che riceve**, e cosi' si pretende che al
/// modello arrivi davvero tutto cio' che l'ordine elenca; e **risponde cio'
/// che le si dice**, e cosi' si pretende che la scena a schermo sia quella del
/// modello quando e' valida e quella deterministica quando non lo e', con il
/// guasto nel registro e mai alla persona. **La prova col modello vero** sta
/// nel manifesto dell'ordine, fatta con lo stesso testo dell'istruzione.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
  final aquila = AnimalCatalog.animals.firstWhere((a) => a.name == 'Aquila');

  /// Scende per la strada vera con la domanda scelta, e torna la scena.
  Future<({String? istruzione, String? richiesta, RegistroDeiGuasti registro})>
      scendi(WidgetTester tester, ChiamataDellaScena chiamata) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    String? istruzione;
    String? richiesta;
    final registro = RegistroDeiGuasti();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: registro),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(1),
            chiamataDellaScena: (i, r, a) {
              istruzione = i;
              richiesta = r;
              return chiamata(i, r, a);
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // La lente: si risale.
    await tester.tap(find.byKey(const Key('viaggio_risali')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return (istruzione: istruzione, richiesta: richiesta, registro: registro);
  }

  String laScena(WidgetTester tester) => tester
      .widgetList<Widget>(find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('viaggio_scena_')))
      .map((w) => w.toString())
      .join(' ');

  testWidgets('LA SCENA A SCHERMO E QUELLA DEL MODELLO, e il modello riceve '
      'tutto cio che l ordine elenca', (tester) async {
    final r = await scendi(tester, (_, __, ___) async =>
        '{"luogo":"grotta","cosa":"chiave","gesto":"aspetta","momento":"alba"}');
    final testo = find.textContaining('alla grotta').evaluate().isNotEmpty ||
        find.textContaining('la grotta').evaluate().isNotEmpty;
    // ignore: avoid_print
    print('ORDINE DI VOCE 03: il modello ha ricevuto\n${r.richiesta}');
    expect(r.richiesta, isNotNull, reason: 'il modello non e stato chiamato');
    for (final atteso in [
      'Domanda: Ho una scelta davanti',
      'Tema: Una scelta da fare',
      'Animale: Lupo',
      'Carta natale: Sole in Cancro',
      'Memoria: ',
      'Scene precedenti',
    ]) {
      expect(r.richiesta, contains(atteso),
          reason: 'al modello non arriva "$atteso"');
    }
    expect(laScena(tester), isNotEmpty);
    expect(testo || laScena(tester).contains('grotta'), isTrue,
        reason: 'la scena a schermo non e quella del modello');
    expect(r.registro.guasti.where((g) => g.operazione == 'viaggio_scena_del_modello'),
        isEmpty);
  });

  testWidgets('UN ID FUORI DAL VOCABOLARIO SI SCARTA: risponde la via '
      'deterministica, e il guasto va nel registro', (tester) async {
    final r = await scendi(tester, (_, __, ___) async =>
        '{"luogo":"castello","cosa":"chiave","gesto":"aspetta","momento":"alba"}');
    final guasti = r.registro.guasti
        .where((g) => g.operazione == 'viaggio_scena_del_modello')
        .toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 03: col luogo inventato il registro dice '
        '${guasti.map((g) => g.riga).toList()}');
    // **DUE GUASTI, E NON UNO**: dall'ordine DI voce 16 una scena scartata si
    // richiede una volta, e la finta risponde di nuovo col luogo inventato.
    expect(guasti, hasLength(2),
        reason: 'il luogo inventato non e dichiarato nel registro dei guasti, '
            'o la scena scartata non si e richiesta');
    expect(find.textContaining('castello'), findsNothing,
        reason: 'il luogo inventato dal modello e arrivato a schermo');
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget,
        reason: 'col modello fuori vocabolario la persona resta senza risposta');
  });

  testWidgets('UN MODELLO CHE NON RISPONDE NON TRATTIENE LA RISALITA',
      (tester) async {
    final mai = Completer<String?>();
    final r = await scendi(tester, (_, __, ___) => mai.future);
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget,
        reason: 'il modello muto tiene ferma la risposta');
    expect(
        r.registro.guasti
            .where((g) => g.operazione == 'viaggio_scena_del_modello'),
        isNotEmpty,
        reason: 'il modello muto non e dichiarato nel registro');
  });

  /// **LA SCENA SI CHIEDE AL TOCCO DI SCENDI, E UNA VOLTA SOLA.** Ordine DK
  /// voce 03: *"la chiamata al modello parte quando comincia la discesa, non
  /// quando finisce [...] il dito alzato a meta' discesa: la chiamata
  /// prosegue, non si annulla e non si rilancia"*.
  testWidgets('DK.03: LA SCENA SI CHIEDE AL TOCCO DI SCENDI, e il dito alzato '
      'non la rilancia', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    var chiamate = 0;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(1),
            chiamataDellaScena: (_, __, ___) async {
              chiamate++;
              return '{"luogo":"grotta","cosa":"chiave","gesto":"aspetta",'
                  '"momento":"alba"}';
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(chiamate, 1,
        reason: 'la scena non si chiede al tocco di Scendi: la chiamata parte '
            'a discesa finita, e perde gli otto secondi del filmato');
    // Il dito si posa e si alza a meta' discesa.
    final dito = await tester.startGesture(const Offset(195, 420));
    await tester.pump(const Duration(milliseconds: 500));
    await dito.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(chiamate, 1, reason: 'il dito alzato ha rilanciato la chiamata');
    // Si salta e si arriva in fondo: la chiamata non riparte.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    expect(chiamate, 1,
        reason: 'a discesa finita la scena si chiede una seconda volta');
  });

  /// **I SEI SECONDI VALGONO PER I DUE TENTATIVI INSIEME.** La scena scartata
  /// si richiede solo col tempo che resta: provato con un'attesa corta, di
  /// trecento millesimi, e un modello che risponde in duecento.
  test('DK.03: LA SCADENZA E UNA SOLA, dalla partenza, per tutti e due i '
      'tentativi', () async {
    var chiamate = 0;
    final guasti = <Object>[];
    final orologio = Stopwatch()..start();
    final scelti = await LaScenaDalModello.chiedi(
      CioCheSiSa(
        domanda: 'Ho una scelta davanti',
        tema: 'Una scelta da fare',
        animale: lupo,
        natale: const NatalContext(sunSign: 'Cancro'),
        memoria: '',
        ultimeScene: const [],
      ),
      chiamata: (_, __, ___) async {
        chiamate++;
        await Future<void>.delayed(const Duration(milliseconds: 200));
        // Un luogo inventato: la risposta si scarta e si richiede.
        return '{"luogo":"castello","cosa":"chiave","gesto":"aspetta",'
            '"momento":"alba"}';
      },
      prendiUnaChiamata: () async => true,
      seGuasto: guasti.add,
      attesa: const Duration(milliseconds: 300),
    );
    final durata = orologio.elapsed;
    // ignore: avoid_print
    print('ORDINE DK VOCE 03: due tentativi in ${durata.inMilliseconds} '
        'millesimi con trecento di attesa, guasti $guasti');
    expect(scelti, isNull);
    expect(chiamate, 2);
    expect(guasti.whereType<TimeoutException>(), isNotEmpty,
        reason: 'il secondo tentativo ha avuto di nuovo tutta l attesa');
    expect(durata, lessThan(const Duration(milliseconds: 420)),
        reason: 'la risalita aspetta ${durata.inMilliseconds} millesimi: la '
            'seconda richiesta ha ricominciato a contare da capo');
  });

  /// **LO SCHEMA NON AMMETTE I LUOGHI E I GESTI DELLE ULTIME CINQUE SCENE.**
  /// Ordine DI voce 16: la prova a cento discese col modello vero ne trovava
  /// scartate fino a meta', perche' il modello ne riprendeva piu' di uno.
  test('LO SCHEMA NON AMMETTE I LUOGHI E I GESTI GIA VISTI, e lascia la cosa',
      () {
    final ultime = [
      ['ponte', 'seme', 'si_volta', 'notte'],
      ['grotta', 'chiave', 'aspetta', 'alba'],
      ['fiume', 'specchio', 'si_accuccia', 'nebbia'],
      ['cima', 'nido', 'ti_precede', 'pioggia'],
      ['radura', 'osso', 'scava', 'notte'],
      ['bivio', 'maschera', 'si_ferma', 'alba'],
    ];
    final a = LaScenaDalModello.ammessi(lupo, ultime);
    for (final visto in ['ponte', 'grotta', 'fiume', 'cima', 'radura']) {
      expect(a.luoghi, isNot(contains(visto)),
          reason: 'lo schema ammette il luogo gia visto $visto');
    }
    for (final visto in ['si_volta', 'aspetta', 'si_accuccia', 'ti_precede',
        'scava']) {
      expect(a.gesti, isNot(contains(visto)),
          reason: 'lo schema ammette il gesto gia visto $visto');
    }
    // La sesta scena e' oltre le cinque: il suo luogo torna ammesso.
    expect(a.luoghi, contains('bivio'));
    // **LA COSA PUO' TORNARE, ma non subito**: il seme e la chiave sono delle
    // due scene di prima e restano fuori, lo specchio e' della terza e torna.
    expect(a.cose, contains('specchio'),
        reason: 'la cosa deve poter tornare: e il pezzo del richiamo');
    expect(a.cose, isNot(contains('seme')),
        reason: 'torna una cosa della scena di ieri');
    expect(a.cose, isNot(contains('chiave')),
        reason: 'torna una cosa della scena di due giorni fa');
    final dueVolte = LaScenaDalModello.ammessi(lupo, [
      ['ponte', 'nido', 'si_volta', 'notte'],
      ['grotta', 'chiave', 'aspetta', 'alba'],
      ['fiume', 'osso', 'si_accuccia', 'nebbia'],
      ['cima', 'osso', 'ti_precede', 'pioggia'],
    ]);
    expect(dueVolte.cose, isNot(contains('osso')),
        reason: 'una cosa gia tornata due volte nelle cinque torna ancora');
    // **NON TORNA CIO' CHE TORNA SEMPRE**: la grotta e' uscita due volte
    // fra la sesta e la decima scena, fuori dalle cinque, e resta fuori.
    final dieci = LaScenaDalModello.ammessi(lupo, [
      ['ponte', 'nido', 'si_volta', 'notte'],
      ['cima', 'chiave', 'aspetta', 'alba'],
      ['fiume', 'seme', 'si_accuccia', 'nebbia'],
      ['radura', 'specchio', 'ti_precede', 'pioggia'],
      ['bivio', 'maschera', 'scava', 'notte'],
      ['grotta', 'osso', 'si_volta', 'alba'],
      ['soglia', 'filo', 'aspetta', 'notte'],
      ['grotta', 'osso', 'scava', 'nebbia'],
    ]);
    expect(dieci.luoghi, isNot(contains('grotta')),
        reason: 'torna un luogo gia usato due volte nelle ultime dieci');
    expect(dieci.cose, isNot(contains('osso')),
        reason: 'torna una cosa gia usata due volte nelle ultime dieci');
    expect(dieci.luoghi, contains('soglia'),
        reason: 'un luogo usato una volta sola fuori dalle cinque torna');
    expect(a.gesti, isNotEmpty);
    expect(a.luoghi.length, VocabolarioDelViaggio.luoghi.length - 5);
  });

  /// **UNA SCENA SCARTATA SI RICHIEDE UNA VOLTA**, senza il luogo e la cosa
  /// scartati. Ordine DI voce 16: con la regola della scena rifatta, senza
  /// questa richiesta meta' delle discese tornava alla via deterministica.
  test('UNA SCENA SCARTATA SI RICHIEDE UNA VOLTA, senza il suo luogo e la '
      'sua cosa', () async {
    final ricevuti = <PezziAmmessi>[];
    final risposte = [
      // Rifatta: tre pezzi uguali alla scena della storia.
      '{"luogo":"ponte","cosa":"seme","gesto":"si_volta","momento":"alba"}',
      '{"luogo":"cima","cosa":"chiave","gesto":"scava","momento":"alba"}',
    ];
    final storia = [
      for (var i = 0; i < 6; i++) ['radura', 'nido', 'ti_precede', 'notte'],
      ['ponte', 'seme', 'si_volta', 'notte'],
    ];
    final scelti = await LaScenaDalModello.chiedi(
      CioCheSiSa(
        domanda: 'x',
        tema: null,
        animale: lupo,
        natale: NatalContext.none,
        memoria: '',
        ultimeScene: storia,
      ),
      chiamata: (_, __, a) async {
        ricevuti.add(a);
        return risposte[ricevuti.length - 1];
      },
      prendiUnaChiamata: () async => true,
    );
    expect(ricevuti, hasLength(2), reason: 'la scena scartata non si richiede');
    expect(ricevuti.last.luoghi, isNot(contains('ponte')));
    expect(ricevuti.last.cose, isNot(contains('seme')));
    expect(scelti?.luogo.id, 'cima',
        reason: 'la seconda risposta, buona, non diventa la scena');
  });

  group('LA LETTURA DELLA RISPOSTA', () {
    test('una scena che rifa luogo, cosa e gesto di una scena della storia si '
        'scarta, anche lontana', () {
      final storia = [
        for (var i = 0; i < 8; i++) ['cima', 'nido', 'ti_precede', 'pioggia'],
        ['ponte', 'seme', 'si_volta', 'notte'],
      ];
      // La scena ripetuta e' la nona, oltre le cinque del richiamo.
      final rifatta = LaScenaDalModello.leggi(
          '{"luogo":"ponte","cosa":"seme","gesto":"si_volta","momento":"alba"}',
          lupo,
          ultimeScene: storia);
      expect(rifatta, isNull,
          reason: 'la scena rifatta a settimane di distanza passa');
      final nuova = LaScenaDalModello.leggi(
          '{"luogo":"ponte","cosa":"chiave","gesto":"scava","momento":"alba"}',
          lupo,
          ultimeScene: storia);
      expect(nuova, isNotNull,
          reason: 'una scena con un solo pezzo in comune si scarta');
    });

    test('quattro id del vocabolario passano, e diventano la scena', () {
      final p = LaScenaDalModello.leggi(
          '{"luogo":"ponte","cosa":"seme","gesto":"si_volta","momento":"notte"}',
          lupo);
      expect(p, isNotNull);
      expect([p!.luogo.id, p.cosa.id, p.gesto.id, p.momento.id],
          ['ponte', 'seme', 'si_volta', 'notte']);
    });

    test('un gesto che il corpo non sa fare si scarta', () {
      expect(
          LaScenaDalModello.leggi(
              '{"luogo":"ponte","cosa":"seme","gesto":"mostra_i_denti",'
              '"momento":"notte"}',
              aquila),
          isNull,
          reason: 'l Aquila mostra i denti');
    });

    test('due pezzi che ripetono la stessa parola si scartano', () {
      expect(
          LaScenaDalModello.leggi(
              '{"luogo":"fiume","cosa":"acqua_ferma","gesto":"si_ferma",'
              '"momento":"notte"}',
              lupo),
          isNull,
          reason: 'l acqua ferma e si ferma nella stessa scena');
    });

    test('piu di un pezzo gia visto nelle ultime cinque scene si scarta', () {
      // **LO HA CHIESTO LA PROVA COL MODELLO VERO**: con la prima istruzione
      // il modello riprendeva qualcosa in ventisei scene su ventisette, e un
      // profilo tornava dieci volte al bivio col seme.
      const prima = [
        ['ponte', 'seme', 'si_volta', 'notte'],
      ];
      expect(
          LaScenaDalModello.leggi(
              '{"luogo":"ponte","cosa":"seme","gesto":"aspetta","momento":"alba"}',
              lupo,
              ultimeScene: prima),
          isNull,
          reason: 'due pezzi ripresi dalla scena di prima');
      expect(
          LaScenaDalModello.leggi(
              '{"luogo":"ponte","cosa":"chiave","gesto":"aspetta","momento":"notte"}',
              lupo,
              ultimeScene: prima),
          isNotNull,
          reason: 'un pezzo solo ripreso, piu il momento, e il richiamo');
    });

    test('ogni chiamata del Viaggio spegne il ragionamento', () {
      // **LO HA TROVATO LA PROVA COL MODELLO VERO**: i token del pensiero si
      // contano nel tetto dell'uscita, e Gemini 3.6 Flash rispondeva "Here" e
      // si fermava trenta volte su trenta. Nell'app nessuno lo diceva nemmeno a
      // Gemini 2.5 Flash, e ogni scena sarebbe caduta sulla riserva.
      expect(LaDomandaCapita.ragionamentoPer('gemini-2.5-flash').thinkingBudget,
          0);
      expect(
          LaDomandaCapita.ragionamentoPer('gemini-3.6-flash').thinkingLevel,
          ThinkingLevel.minimal);
      final chiamate = <String, int>{};
      for (final f in [
        'lib/core/viaggio/la_domanda_capita.dart',
        'lib/core/viaggio/la_scena_dal_modello.dart',
        'lib/core/viaggio/il_segno_dell_animale.dart',
      ]) {
        final testo = File(f).readAsStringSync();
        final configurazioni = 'GenerationConfig('.allMatches(testo).length;
        final spente = RegExp(r'thinkingConfig:\s*(LaDomandaCapita\.)?'
                r'ragionamentoPer\(modello\)')
            .allMatches(testo)
            .length;
        chiamate[f] = configurazioni;
        expect(configurazioni, greaterThan(0), reason: '$f non chiama piu');
        expect(spente, configurazioni,
            reason: '$f ha una chiamata al modello col ragionamento acceso');
      }
      // ignore: avoid_print
      print('ORDINE DI VOCE 03: chiamate del Viaggio col ragionamento spento '
          '$chiamate');
    });

    test('testo libero, pezzi mancanti o JSON rotto si scartano', () {
      for (final r in [
        'Scelgo il ponte',
        '{"luogo":"ponte"}',
        '{"luogo":"ponte","cosa":"seme","gesto":"si_volta","momento":"domani"}',
        null,
      ]) {
        expect(LaScenaDalModello.leggi(r, lupo), isNull, reason: '$r');
      }
    });

    test('l istruzione nomina tutto il vocabolario e solo i gesti possibili',
        () {
      final i = LaScenaDalModello.istruzione(aquila);
      for (final p in [
        ...VocabolarioDelViaggio.luoghi,
        ...VocabolarioDelViaggio.cose,
        ...VocabolarioDelViaggio.momenti,
      ]) {
        expect(i, contains('- ${p.id}: ${p.nome}'));
      }
      expect(i, isNot(contains('mostra_i_denti')),
          reason: 'all Aquila si offre un gesto che non sa fare');
      final richiesta = LaScenaDalModello.richiesta(CioCheSiSa(
        domanda: 'Resto o parto?',
        tema: 'Una scelta da fare',
        animale: aquila,
        natale: const NatalContext(
            sunSign: 'Leone', moonSign: 'Pesci', ascendant: 'Vergine'),
        memoria: 'ha fatto 6 discese nel Mondo di Sotto',
        ultimeScene: List.generate(8, (i) => ['ponte', 'seme', 'si_volta', 'n$i']),
      ));
      // ignore: avoid_print
      print('ORDINE DI VOCE 03: la richiesta per esteso\n$richiesta');
      expect('- ponte'.allMatches(richiesta).length, 5,
          reason: 'al modello arrivano piu di cinque scene precedenti');
      expect(richiesta, contains('Luna in Pesci'));
      expect(richiesta, contains('Ascendente Vergine'));
    });

    test('il tetto tecnico chiude la porta al modello', () async {
      var chiamato = false;
      final p = await LaScenaDalModello.chiedi(
        CioCheSiSa(
          domanda: 'x',
          tema: null,
          animale: lupo,
          natale: NatalContext.none,
          memoria: '',
          ultimeScene: const [],
        ),
        chiamata: (_, __, ___) async {
          chiamato = true;
          return '{"luogo":"ponte","cosa":"seme","gesto":"si_volta","momento":"notte"}';
        },
        prendiUnaChiamata: () async => false,
      );
      expect(p, isNull);
      expect(chiamato, isFalse);
    });
  });

  test('la scena dai pezzi del modello e marcata come sua, mai detto alla '
      'persona', () {
    final s = ScenaSenzaModello.daiPezzi(
      luogo: VocabolarioDelViaggio.luoghi.first,
      cosa: VocabolarioDelViaggio.cose.first,
      gesto: VocabolarioDelViaggio.gesti.first,
      momento: VocabolarioDelViaggio.momenti.first,
      domanda: 'x',
      giorno: DateTime(2026, 9, 12),
      nitidezza: 1,
    );
    expect(s.dalModello, isTrue);
    expect(s.testo.toLowerCase(), isNot(contains('modello')));
  });
}
