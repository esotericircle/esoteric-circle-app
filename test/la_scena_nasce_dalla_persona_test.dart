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
            chiamataDellaScena: (i, r) {
              istruzione = i;
              richiesta = r;
              return chiamata(i, r);
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
    final r = await scendi(tester, (_, __) async =>
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
    final r = await scendi(tester, (_, __) async =>
        '{"luogo":"castello","cosa":"chiave","gesto":"aspetta","momento":"alba"}');
    final guasti = r.registro.guasti
        .where((g) => g.operazione == 'viaggio_scena_del_modello')
        .toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 03: col luogo inventato il registro dice '
        '${guasti.map((g) => g.riga).toList()}');
    expect(guasti, hasLength(1),
        reason: 'il luogo inventato non e dichiarato nel registro dei guasti');
    expect(find.textContaining('castello'), findsNothing,
        reason: 'il luogo inventato dal modello e arrivato a schermo');
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget,
        reason: 'col modello fuori vocabolario la persona resta senza risposta');
  });

  testWidgets('UN MODELLO CHE NON RISPONDE NON TRATTIENE LA RISALITA',
      (tester) async {
    final mai = Completer<String?>();
    final r = await scendi(tester, (_, __) => mai.future);
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget,
        reason: 'il modello muto tiene ferma la risposta');
    expect(
        r.registro.guasti
            .where((g) => g.operazione == 'viaggio_scena_del_modello'),
        isNotEmpty,
        reason: 'il modello muto non e dichiarato nel registro');
  });

  group('LA LETTURA DELLA RISPOSTA', () {
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
        chiamata: (_, __) async {
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
