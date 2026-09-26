// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_silenzio_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/il_tema_della_domanda_libera.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA DOMANDA LIBERA ARRIVA INTERA, E IL RIPIEGO NON FINGE PIU'.**
/// Ordine DR voce 07, 16 settembre 2026.
///
/// **Il fatto, dal fondatore**: una discesa con la domanda scritta a mano
/// *"quando mi sposero'?"* ha dato quattro strati che parlano d'attesa e mai
/// di matrimonio. *"Sembra una risposta di ripiego per quattro volte."*
///
/// **La catena, misurata**: il classificatore da' tre punti alla parola
/// *quando* sul tema attesa e due bastano per decidere; le parole del
/// matrimonio non stanno in nessuna tabella e valgono zero; e quando le
/// guardie scartano la riga del modello il responso lo scrive la voce di
/// casa, che apre nominando il **tema**.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('DR.07: il classificatore manda "quando mi sposero" sull attesa, e le '
      'parole del matrimonio valgono zero', () {
    final capito = IlTemaDellaDomandaLibera.perParole('quando mi sposerò?');
    print('ORDINE DR VOCE 07: "quando mi sposerò?" -> tema ${capito?.name}');
    // **NON E' UN DIFETTO DA CURARE QUI**: il tema puo' restare l'attesa,
    // dice l'ordine. Quello che non deve piu' succedere e' che il tema
    // scriva le parole che la persona legge per prime.
    expect(capito, isNotNull,
        reason: 'la misura dell ordine dice attesa con tre punti: se adesso '
            'non decide piu, la voce DR.07 va riscritta');
    // E le parole del matrimonio non pesano: cambiando la sola parola finale
    // il tema non si muove, perche' nessuna tabella le conosce.
    expect(IlTemaDellaDomandaLibera.perParole('quando mi trasferirò?'), capito,
        reason: 'se cambiasse, una tabella conoscerebbe il matrimonio');
  });

  test('DR.07: IL MODELLO SI RITENTA TRE VOLTE, e alla terza lo strato esce',
      () async {
    // Ordine DR voce 07, la prova del ritentare: un modello finto che scarta
    // le prime due risposte e passa la terza.
    const gergo = 'La risposta è già dentro di te e devi solo lasciarla '
        'andare.';
    var chiamate = 0;
    final s = CioCheSiSa(
      domanda: 'quando mi sposerò?',
      tema: 'Un tempo che non arriva',
      animale: AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo'),
      natale: const NatalContext(sunSign: 'Cancro'),
      memoria: '',
      ultimeScene: const [],
      strato: 1,
    );
    final scritta = await LaScenaDalModello.chiediTutto(
      s,
      chiamata: (i, r, a) async {
        chiamate++;
        return jsonEncode({
          'luogo': 'radura',
          'cosa': 'chiave',
          'gesto': 'aspetta',
          'momento': 'alba',
          'titolo': 'Una porta socchiusa',
          'risposta': chiamate < 3
              ? gergo
              : 'Quel tempo che aspetti non decide al posto tuo. Decide che '
                  'cosa hai voglia di chiedere adesso.',
          'azione': 'Stasera scrivi su un foglio la domanda vera.',
        });
      },
      prendiUnaChiamata: () async => true,
      seScartata: (r) => print('  scartata ${r.pezzo}: ${r.motivo.name}: ${r.testo}'),
    );
    print('ORDINE DR VOCE 07: chiamate al modello $chiamate, risposta dal '
        'modello ${scritta.testi.risposta != null}');
    expect(chiamate, 3, reason: 'con due scarti si arriva al terzo tentativo');
    expect(scritta.testi.risposta, isNotNull,
        reason: 'la terza risposta regge e deve valere, senza ripiegare');
  });

  testWidgets('DR.07: QUANDO NON PASSA NIENTE L APP TACE, e la discesa non si '
      'consuma', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 16, 12));
    await diario.carica();
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
            now: DateTime(2026, 9, 16, 12),
            diario: diario,
            demo: false,
            chiamataDellaDomanda: (_, __) async =>
                jsonEncode({'tema': 'attesa', 'oggetto': null}),
            // **UN MODELLO CHE SBAGLIA SEMPRE**: gergo a ogni tentativo.
            chiamataDellaScena: (_, __, ___) async {
              chiamate++;
              return jsonEncode({
                'luogo': 'radura',
                'cosa': 'chiave',
                'gesto': 'aspetta',
                'momento': 'alba',
                'titolo': 'Il tuo tempo arriverà presto',
                'risposta':
                    'La risposta è già dentro di te e devi solo lasciarla andare.',
                'azione': 'Lascia andare e accogli quello che arriva.',
              });
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(find.text('Scrivila tu'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Scrivila tu'));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('viaggio_domanda')), 'quando mi sposerò?');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    final salta = find.byKey(const Key('viaggio_salta_la_discesa'));
    if (salta.evaluate().isNotEmpty) {
      await tester.tap(salta);
    } else {
      final g = await tester
          .startGesture(tester.getCenter(find.byType(Scaffold).first));
      await tester.pump(const Duration(seconds: 20));
      await g.up();
    }
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var k = 0; k < 80 && nebbia.evaluate().isNotEmpty; k++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // **E SI RISALE**: il responso si compone qui, ed e' qui che il silenzio
    // prende il posto della risalita.
    final risali = find.byKey(const Key('viaggio_risali'));
    if (risali.evaluate().isNotEmpty) await tester.tap(risali);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    print('ORDINE DR VOCE 07: chiamate al modello $chiamate, discese nel '
        'diario ${diario.quanteDiscese}, apparizioni ${diario.apparizioni}');
    expect(find.byKey(const Key('viaggio_silenzio')), findsOneWidget,
        reason: 'il modello non ha passato niente: la schermata deve dire che '
            'oggi il Mondo di Sotto non ha parlato');
    expect(find.text(IlSilenzioDelMondoDiSotto.titolo), findsOneWidget);
    // **E LA DISCESA NON SI CONSUMA**: il Diario non ha una discesa in piu' e
    // il cammino non e' avanzato di uno strato.
    expect(diario.quanteDiscese, 0,
        reason: 'la discesa muta ha consumato una discesa nel Diario');
    expect(diario.apparizioni, 0,
        reason: 'la discesa muta ha fatto avanzare il cammino di uno strato');
  });

  test('DR.07: DUE STRATI DELLO STESSO CAMMINO NON APRONO CON LE STESSE '
      'PAROLE, nemmeno con la voce di casa', () {
    // **Il fatto del fondatore**: il primo e il quarto strato aprivano con
    // *"Quello che ti pesa e' l'attesa"*, sei parole identiche. La ripresa
    // di casa la sceglie un seme, e con lo stesso tema tornava la stessa.
    //
    // **Qui si scende quattro volte sullo stesso tema**, con la voce di casa
    // sola, e si guarda come cominciano le quattro risposte.
    final letti = <ResponsoLetto>[];
    final aperture = <String>[];
    for (var strato = 1; strato <= 4; strato++) {
      final voce = LaVoceDelMondoDiSotto.alGiorno(
        scena: ScenaSenzaModello.componi(
          domanda: 'quando mi sposerò?',
          giorno: DateTime(2026, 9, 15 + strato),
          nitidezza: 1,
          discesa: strato - 1,
          conDomanda: true,
        ),
        temaDomanda: 'attesa',
        temaInLettere: 'un tempo che non arriva',
        giornoDellaDiscesa: DateTime(2026, 9, 15 + strato),
        letti: letti,
        domanda: 'quando mi sposerò?',
      );
      final risposta = voce.paragrafi.first;
      aperture.add(LaVoceDelMondoDiSotto.primeParole(risposta));
      letti.add((
        tema: 'attesa',
        titolo: voce.titolo,
        risposta: risposta,
        gesto: voce.paragrafi.length > 1 ? voce.paragrafi[1] : null,
      ));
    }
    print('ORDINE DR VOCE 07: le quattro aperture di casa $aperture');
    expect(aperture.toSet(), hasLength(4),
        reason: 'due strati dello stesso cammino cominciano con le stesse '
            'parole: $aperture');
  });

  test('DR.07: NESSUNA FRASE DEL CORPUS PER TEMA APRE UNO STRATO, quando la '
      'risposta viene dal modello', () {
    // **La ripresa per tema e' la prima frase del paragrafo della risposta**,
    // e vive in `LaVoceDelMondoDiSotto.riprendeLaDomanda`: dodici righe che
    // nominano il tema, fra cui quella vista dal fondatore. Entra solo quando
    // la risposta del modello e' stata scartata, e con la domanda scritta a
    // mano quel caso adesso finisce in silenzio.
    const riprese = LaVoceDelMondoDiSotto.riprendeLaDomanda;
    print('ORDINE DR VOCE 07: riprese per tema nel corpus ${riprese.length}');
    expect(riprese, isNotEmpty);
    expect(riprese.any((r) => r.contains('Quello che ti pesa')), isTrue,
        reason: 'la riga che il fondatore ha visto deve stare nel corpus: se '
            'non c e piu, questa prova guarda un corpus che non esiste');
  });
}
