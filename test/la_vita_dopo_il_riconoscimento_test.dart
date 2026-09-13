import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_segno_che_risponde.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tamburo_che_nutre.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LA VITA DOPO IL RICONOSCIMENTO.** Ordine DI voci 11, 12, 13 e 14,
/// 12 settembre 2026.
///
/// **Il principio dell'ordine:** *"prima della quarta si scende per scoprire
/// chi e'; dopo la quarta si scende per chiedergli qualcosa, ed e' solo da qui
/// che il nome della funzione diventa vero. Se la discesa sparisse, la
/// funzione si esaurirebbe in quattro giorni."*
///
/// **Si percorre la schermata vera**, per ognuna delle quattro voci: cosa
/// sparisce e cosa compare al riconoscimento, la discesa che cambia scopo, il
/// tamburo che nutre, il segno che risponde. E la lingua delle righe nuove si
/// pretende accordata col genere dell'animale, perche' l'ordine le scrive al
/// maschile e quattro animali su dodici sono femmine.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<DiarioDelloSciamanoDiProva> apri(
    WidgetTester tester, {
    Zodiac segno = Zodiac.sagittarius,
    int discese = 4,
    ChiamataDelSegno? chiamata,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelloSciamanoDiProva(discese);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            key: ValueKey('$segno $discese'),
            userSign: segno,
            now: DateTime(2026, 9, 12, 12),
            diario: diario,
            chiamataDelSegno: chiamata,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return diario;
  }

  group('DI.11, al riconoscimento', () {
    testWidgets('SPARISCE L APPARATO DELLA RIVELAZIONE, e compare l animale '
        'col suo nome, due righe e tre azioni', (tester) async {
      await apri(tester);
      // **COSA SPARISCE**, per nome: le impronte, il conteggio, le tre righe
      // della voce DI.07, la girandola dei candidati.
      const spariscono = [
        'viaggio_i_quattro_segni',
        'viaggio_a_che_punto',
        'viaggio_dove_ti_trovi',
        'viaggio_cosa_stai_facendo',
        'viaggio_cosa_otterrai',
        'viaggio_promessa',
      ];
      final ancora = [
        for (final k in spariscono)
          if (find.byKey(Key(k)).evaluate().isNotEmpty) k,
      ];
      expect(ancora, isEmpty,
          reason: 'riconosciuto l animale restano accesi a vuoto: $ancora');
      // **COSA COMPARE.**
      expect(find.byKey(const Key('viaggio_animale_riconosciuto')),
          findsOneWidget);
      final nome = find.byKey(const Key('viaggio_nome_riconosciuto'));
      expect(nome, findsOneWidget);
      expect(find.text('Il Cavallo resta con te. Scendi quando hai una '
              'domanda.'),
          findsOneWidget);
      expect(find.text('Si allontana se lo lasci solo. Il tamburo lo '
              'richiama.'),
          findsOneWidget);
      // **TRE AZIONI E NON DI PIU'**, e la domanda non c'e' finche' non la si
      // chiede.
      const azioni = [
        'viaggio_azione_scendi',
        'viaggio_azione_nutri',
        'viaggio_azione_segno',
      ];
      for (final k in azioni) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: 'manca $k');
      }
      expect(find.text('Scendi con una domanda'), findsOneWidget);
      expect(find.text('Nutrilo'), findsOneWidget);
      expect(find.text('Chiedigli un segno'), findsOneWidget);
      expect(find.byKey(const Key('viaggio_scendi')), findsNothing,
          reason: 'la scelta della domanda e gia aperta: le azioni sotto '
              'l animale non sono piu tre');
      await tester.tap(find.byKey(const Key('viaggio_azione_scendi')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('viaggio_scendi')), findsOneWidget,
          reason: 'toccata la prima azione, la domanda non si apre');
      // ignore: avoid_print
      print('ORDINE DI VOCE 11: spariti ${spariscono.length} pezzi della '
          'rivelazione, comparsi l animale, il nome, due righe e tre azioni');
    });

    testWidgets('LE RIGHE E LE AZIONI SI ACCORDANO CON L ANIMALE FEMMINA',
        (tester) async {
      await apri(tester, segno: Zodiac.gemini);
      expect(find.text('La Volpe resta con te. Scendi quando hai una domanda.'),
          findsOneWidget);
      expect(find.text('Si allontana se la lasci sola. Il tamburo la '
              'richiama.'),
          findsOneWidget,
          reason: 'l ordine scrive "se lo lasci solo", e detto della Volpe e '
              'lo stesso errore di "e il Lince"');
      expect(find.text('Nutrila'), findsOneWidget);
      expect(find.text('Chiedile un segno'), findsOneWidget);
    });

    testWidgets('PRIMA DEL RICONOSCIMENTO LE AZIONI DEL DOPO NON CI SONO',
        (tester) async {
      await apri(tester, discese: 3);
      expect(find.byKey(const Key('viaggio_azione_segno')), findsNothing);
      expect(find.byKey(const Key('viaggio_animale_riconosciuto')),
          findsNothing,
          reason: 'l animale si mostra scoperto prima della quarta');
    });
  });

  group('DI.12, dopo il riconoscimento si scende per chiedere', () {
    testWidgets('LA DISCESA C E ANCORA, si salta, e non passa piu dal velo',
        (tester) async {
      // **CINQUE DISCESE E NON QUATTRO**: il diario di prova non conta la
      // discesa che si fa qui, e con quattro la risalita crederebbe di essere
      // quella della rivelazione.
      await apri(tester, discese: 5);
      await tester.tap(find.byKey(const Key('viaggio_azione_scendi')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Una scelta da fare'));
      await tester.tap(find.text('Una scelta da fare'));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
      await tester.tap(find.byKey(const Key('viaggio_scendi')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.byKey(const Key('viaggio_salta_la_discesa')), findsOneWidget,
          reason: 'la discesa dopo il riconoscimento non si puo saltare');
      await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
      await tester.pump(const Duration(seconds: 1));
      // La nebbia si apre passando la mano.
      final nebbia = find.byKey(const Key('viaggio_nebbia'));
      for (var i = 0; i < 80 &&
          find.byKey(const Key('viaggio_nebbia')).evaluate().isNotEmpty; i++) {
        await tester.drag(nebbia, const Offset(120, 40));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 300));
      final ombra = find.byKey(const Key('viaggio_ombra_Cavallo'));
      expect(ombra, findsOneWidget, reason: 'la nebbia non porta all incontro');
      await tester.tap(ombra);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Image).evaluate().where((e) =>
              (e.widget.key as ValueKey?)?.value.toString().startsWith(
                  'viaggio_lente') ??
              false),
          isEmpty);
      expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
          findsOneWidget,
          reason: 'dopo il riconoscimento seguire l animale non porta alla '
              'risposta');
      expect(find.byKey(const Key('viaggio_il_nome')), findsNothing,
          reason: 'il nome si ripete a ogni discesa dopo la rivelazione');
      expect(find.byKey(const Key('viaggio_ancora_no')), findsNothing,
          reason: 'il conteggio delle apparizioni resta acceso dopo il '
              'riconoscimento');
      // ignore: avoid_print
      print('ORDINE DI VOCE 12: dopo il riconoscimento la discesa porta alla '
          'risposta senza passare dal velo');
    });
  });

  group('DI.13, il tamburo che nutre', () {
    testWidgets('SI BATTE PER QUARANTA SECONDI, l animale arriva dal fondo, e '
        'senza battere non si avanza', (tester) async {
      final diario = await apri(tester);
      final prima = diario.nutrimentiCheContano;
      await tester.tap(find.byKey(const Key('viaggio_azione_nutri')));
      await tester.pump();
      final animale = find.byKey(const Key('viaggio_animale_che_si_avvicina'));
      expect(animale, findsOneWidget);
      final allInizio = tester.getRect(animale);
      // **SENZA BATTERE NON SI AVANZA.**
      await tester.pump(const Duration(seconds: 10));
      expect(tester.getRect(animale), allInizio,
          reason: 'l animale si avvicina anche senza battere: e un orologio, '
              'non un tamburo');
      // **SI BATTE UNA VOLTA AL SECONDO**, per quaranta secondi e poco piu'.
      for (var s = 0; s < 20; s++) {
        await tester.tapAt(const Offset(195, 700));
        await tester.pump(const Duration(seconds: 1));
      }
      final aMeta = tester.getRect(animale);
      expect(aMeta.width, greaterThan(allInizio.width),
          reason: 'battendo l animale non si avvicina');
      expect(aMeta.bottom, greaterThan(allInizio.bottom),
          reason: 'l animale non scende dal fondo verso il primo piano');
      expect(find.byKey(const Key('viaggio_torna_dal_tamburo')), findsNothing,
          reason: 'il rito finisce prima dei quaranta secondi');
      for (var s = 0; s < 22; s++) {
        await tester.tapAt(const Offset(195, 700));
        await tester.pump(const Duration(seconds: 1));
      }
      final allaFine = tester.getRect(animale);
      // ignore: avoid_print
      print('ORDINE DI VOCE 13: l animale e largo ${allInizio.width.round()} '
          'all inizio, ${aMeta.width.round()} a meta, '
          '${allaFine.width.round()} alla fine');
      expect(find.byKey(const Key('viaggio_torna_dal_tamburo')), findsOneWidget,
          reason: 'dopo quaranta secondi di battito il rito non finisce');
      expect(diario.nutrimentiCheContano, prima + 1,
          reason: 'il rito finito non registra il nutrimento');
      // **NESSUN PUNTEGGIO, NESSUNA BARRA.**
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining(RegExp(r'\d')), findsNothing,
          reason: 'il rito del tamburo mostra un numero');
      await tester.tap(find.byKey(const Key('viaggio_torna_dal_tamburo')));
      await tester.pump(const Duration(milliseconds: 600));
    });

    test('il nutrimento conta un giorno solo, anche battuto piu volte', () {
      // La forma dell'avvicinarsi: dal fondo al primo piano, e crescendo.
      final lontano = IlTamburoCheNutre.doveSta(0);
      final vicino = IlTamburoCheNutre.doveSta(1);
      expect(vicino.larga, greaterThan(lontano.larga * 3));
      expect(vicino.piedi, greaterThan(lontano.piedi));
      expect(IlTamburoCheNutre.quantoDura, const Duration(seconds: 40));
    });
  });

  group('DI.14, il segno', () {
    testWidgets('L ANIMALE RISPONDE COL GESTO DEL MODELLO E UNA RIGA SOLA, e il '
        'segno si conserva', (tester) async {
      final diario = await apri(tester, chiamata: (istruzione, domanda) async {
        expect(istruzione, contains('siVolta'));
        return '{"gesto":"siAvvicina","riga":"Il Cavallo ti si avvicina. '
            'Vuol dire che quello che chiedi non è lontano."}';
      });
      await tester.tap(find.byKey(const Key('viaggio_azione_segno')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('viaggio_domanda_del_segno')),
          'Troverò lavoro?');
      await tester.tap(find.byKey(const Key('viaggio_chiedi_il_segno')));
      await tester.pump();
      await tester.pump(IlSegnoCheRisponde.quantoDuraIlGesto);
      await tester.pump(const Duration(milliseconds: 100));
      final riga = tester
          .widget<ParagrafiDiLettura>(
              find.byKey(const Key('viaggio_riga_del_segno')))
          .testo;
      // ignore: avoid_print
      print('ORDINE DI VOCE 14: il segno dice "$riga"');
      expect(riga, contains('ti si avvicina'));
      expect(diario.segni, hasLength(1));
      expect(diario.segni.first.gesto, 'siAvvicina');
    });

    testWidgets('UN GESTO FUORI DAL REPERTORIO SI SCARTA, e risponde la riserva',
        (tester) async {
      final diario = await apri(tester, chiamata: (_, __) async =>
          '{"gesto":"parla","riga":"Il Cavallo ti dice di sì."}');
      await tester.tap(find.byKey(const Key('viaggio_azione_segno')));
      await tester.pump();
      await tester.enterText(
          find.byKey(const Key('viaggio_domanda_del_segno')), 'Andrà bene?');
      await tester.tap(find.byKey(const Key('viaggio_chiedi_il_segno')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      final riga = tester
          .widget<ParagrafiDiLettura>(
              find.byKey(const Key('viaggio_riga_del_segno')))
          .testo;
      // ignore: avoid_print
      print('ORDINE DI VOCE 14: col gesto inventato risponde la riserva: '
          '"$riga"');
      expect(riga, isNot(contains('ti dice')),
          reason: 'l animale parla: il gesto inventato dal modello e passato');
      expect(riga, startsWith('Il Cavallo '));
      expect(GestoDelSegno.values.map((g) => g.name),
          contains(diario.segni.first.gesto));
    });

    testWidgets('AL TETTO DEI SEGNI NON C E UN MURO: si dice quando torna e si '
        'offre il nutrimento', (tester) async {
      // **SUL WIDGET DEL SEGNO, E NON SULLA SCHERMATA**: in Demo ogni tetto
      // del Viaggio cade, e la schermata vera il tetto non lo mostra mai. La
      // riga del quando la pretende la guardia dei limiti, qui si pretende
      // che il segno la mostri al posto della domanda, con il nutrimento.
      var nutri = 0;
      final cavallo =
          AnimalCatalog.animals.firstWhere((a) => a.name == 'Cavallo');
      await tester.pumpWidget(MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              body: IlSegnoCheRisponde(
                animale: cavallo,
                palette: MaestroPalette.caligo,
                siPuoChiedere: false,
                quandoTorna: 'Un altro segno potrai chiederlo giovedì. Intanto '
                    'puoi nutrire il Cavallo: il tamburo è sempre aperto.',
                chiedi: (_) async => throw StateError('chiesto oltre il tetto'),
                quandoTorni: () {},
                quandoNutri: () => nutri++,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('viaggio_domanda_del_segno')), findsNothing,
          reason: 'oltre il tetto si puo scrivere un altra domanda');
      expect(find.byKey(const Key('viaggio_quando_torna_un_segno')),
          findsOneWidget);
      expect(find.text('Nutrilo'), findsOneWidget);
      await tester.tap(find.byKey(const Key('viaggio_nutri_dal_segno')));
      expect(nutri, 1, reason: 'il nutrimento offerto al tetto non si apre');
    });

    test('IL REPERTORIO E CHIUSO: sei gesti, e la riga si legge prima', () {
      final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
      final aquila = AnimalCatalog.animals.firstWhere((a) => a.name == 'Aquila');
      expect(GestoDelSegno.values, hasLength(6));
      expect(GestiDelSegno.leggi('{"gesto":"vola","riga":"Il Lupo vola via."}',
          lupo), isNull);
      expect(
          GestiDelSegno.leggi(
              '{"gesto":"portaQualcosa","riga":"Il Lupo ti porta una cosa."}',
              lupo),
          isNull,
          reason: 'porta qualcosa senza dire cosa, fuori dal vocabolario');
      expect(
          GestiDelSegno.leggi(
              '{"gesto":"siSiede","riga":"Il Lupo si siede: vuol dire: aspetta."}',
              lupo),
          isNull,
          reason: 'due punti dentro due punti');
      expect(
          GestiDelSegno.leggi(
              '{"gesto":"siSiede","riga":"Il Lupo si siede. Sei pronto."}',
              lupo),
          isNull,
          reason: 'un aggettivo al maschile riferito a chi legge');
      expect(GestoDelSegno.portaQualcosa.descrizione(aquila), contains('becco'));
      expect(GestoDelSegno.siSiede.descrizione(aquila), contains('posa'));
      // **OGNI GESTO SI MUOVE, E IN UN MODO SUO.**
      final alla = {
        for (final g in GestoDelSegno.values)
          g: IlSegnoCheRisponde.movimento(g, 1),
      };
      final allInizio = {
        for (final g in GestoDelSegno.values)
          g: IlSegnoCheRisponde.movimento(g, 0),
      };
      for (final g in GestoDelSegno.values) {
        expect(alla[g], isNot(allInizio[g]), reason: '$g non si muove');
      }
      expect(alla.values.toSet(), hasLength(GestoDelSegno.values.length),
          reason: 'due gesti si muovono nello stesso modo');
    });
  });
}
