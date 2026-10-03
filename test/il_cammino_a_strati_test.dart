import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:esoteric_circle/core/viaggio/le_parole_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL CAMMINO A STRATI.** Ordine DQ voci 01, 02, 03 e 04, 15 settembre
/// 2026.
///
/// **La decisione del fondatore**: la domanda e' una sola e accompagna tutte
/// e quattro le discese della rivelazione, e ogni discesa risale con uno
/// strato piu' profondo della stessa risposta. Cambiarla fa ripartire il
/// cammino dalla prima. Chi scende senza domanda ha i suoi quattro strati
/// sull'incontro.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown);

  UnViaggio discesa(DateTime quando, IlCammino c, int strato) => UnViaggio(
        quando: quando,
        domanda: c.domanda,
        temaDellaDomanda: c.tema,
        pezzi: const ['radura', 'ramo_secco', 'si_ferma', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1,
        titolo: 'Titolo $strato',
        risposta: 'Risposta $strato',
        gesto: 'Gesto $strato',
        cammino: c.id,
        strato: strato,
      );

  group('DQ.01 e DQ.03, il cammino nel Diario', () {
    test('quattro strati sulla stessa domanda, e al quarto si riconosce',
        () async {
      final d = DiarioDeiViaggi();
      await d.carica();
      final c = IlCammino(
          domanda: 'Mia sorella non mi parla',
          via: 'scritta',
          tema: 'persona',
          inizio: DateTime(2026, 9, 15, 12));
      await d.cominciaIlCammino(c);
      expect(d.apparizioni, 0);
      for (var s = 1; s <= 3; s++) {
        await d.segna(discesa(DateTime(2026, 9, 15 + s), c, s));
        expect(d.apparizioni, s, reason: 'lo strato $s non si e segnato');
        expect(d.riconosciuto, isFalse);
        expect(d.cammino?.domanda, 'Mia sorella non mi parla');
      }
      expect(d.stratiDi(d.cammino!).map((v) => v.strato), [1, 2, 3]);
      await d.segna(discesa(DateTime(2026, 9, 19), c, 4));
      expect(d.riconosciuto, isTrue);
      expect(d.cammino, isNull,
          reason: 'dopo la quarta il cammino e finito: consultazione libera');
      expect(d.cammini.single.strati.map((v) => v.strato), [1, 2, 3, 4]);
      // Riaperto, il Diario sa tutto.
      final r = DiarioDeiViaggi();
      await r.carica();
      expect(r.riconosciuto, isTrue);
      expect(r.cammini.single.strati, hasLength(4));
    });

    test('cambiare domanda azzera le apparizioni e lascia le discese',
        () async {
      final d = DiarioDeiViaggi();
      await d.carica();
      final c = IlCammino(
          domanda: 'Devo cambiare lavoro?',
          via: 'scritta',
          tema: 'scelta',
          inizio: DateTime(2026, 9, 15, 12));
      await d.cominciaIlCammino(c);
      await d.segna(discesa(DateTime(2026, 9, 15, 13), c, 1));
      await d.segna(discesa(DateTime(2026, 9, 16, 13), c, 2));
      await d.segnaCelleScoperte('Lupo', {1, 2, 3});
      expect(d.apparizioni, 2);
      await d.cambiaLaDomanda();
      expect(d.apparizioni, 0);
      expect(d.cammino, isNull);
      expect(d.viaggi, hasLength(2), reason: 'le discese fatte restano');
      expect(d.cammini.single.strati, hasLength(2),
          reason: 'restano con la loro domanda e i loro strati');
      expect(d.celleScoperteDi('Lupo'), isEmpty,
          reason: 'il cammino riparte dalla prima, e la cenere torna intera');
      final r = DiarioDeiViaggi();
      await r.carica();
      expect(r.apparizioni, 0, reason: 'riaprendo il Diario il cambio resta');
    });

    test('un Diario di prima: a meta prosegue, a quattro resta riconosciuto',
        () async {
      String vecchia(int i) => jsonEncode(UnViaggio(
            quando: DateTime(2026, 9, 1 + i, 12),
            domanda: 'Non so dove sto andando e vorrei una direzione.',
            temaDellaDomanda: 'direzione',
            pezzi: const ['radura', 'ramo_secco', 'si_ferma', 'alba'],
            animaleSeguito: 'Lupo',
            nitidezza: 1,
          ).toJson());
      SharedPreferences.setMockInitialValues({
        'viaggio.diario': [vecchia(2), vecchia(1)],
      });
      final a = DiarioDeiViaggi();
      await a.carica();
      expect(a.riconosciuto, isFalse);
      expect(a.apparizioni, 2, reason: 'chi era a meta non perde un passo');
      expect(a.cammino?.domanda,
          'Non so dove sto andando e vorrei una direzione.');
      expect(a.stratiDi(a.cammino!), hasLength(2));

      SharedPreferences.setMockInitialValues({
        'viaggio.diario': [for (var i = 4; i >= 0; i--) vecchia(i)],
      });
      final b = DiarioDeiViaggi();
      await b.carica();
      expect(b.riconosciuto, isTrue,
          reason: 'chi aveva gia riconosciuto il suo animale lo tiene');
      expect(b.cammino, isNull);
    });
  });

  group('DQ.14, il Diario di collaudo', () {
    test('senza archivio non scrive niente sul telefono, e resta per la '
        'sessione', () async {
      final d = DiarioDeiViaggi(archivio: false);
      await d.carica();
      final c = IlCammino(
          domanda: 'Devo cambiare lavoro?',
          via: 'scritta',
          tema: 'scelta',
          inizio: DateTime(2026, 9, 16, 12));
      await d.cominciaIlCammino(c);
      await d.segna(discesa(DateTime(2026, 9, 16, 13), c, 1));
      await d.segnaCelleScoperte('Lupo', {1, 2});
      await d.segnaISolchi('Lupo', [
        [const Offset(0.1, 0.1)]
      ]);
      await d.carica();
      expect(d.apparizioni, 1, reason: 'rientrare nel Viaggio ha azzerato');
      expect(d.viaggi, hasLength(1));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.startsWith('viaggio.')), isEmpty,
          reason: 'il Diario di collaudo ha scritto sul Viaggio del telefono');
    });

    test('la build che si consegna non accende il collaudo', () {
      expect(DiarioDeiViaggi.collaudoDelCammino, isFalse);
      for (final f in ['codemagic.yaml', 'docs/versione_distribuita.json',
          'tool/consegna.py', 'tool/sbarramento.sh']) {
        expect(File(f).readAsStringSync().contains('COLLAUDO_DEL_CAMMINO'),
            isFalse,
            reason: '$f accende il Diario di collaudo nella build vera');
      }
    });
  });

  group('DQ.02 e DQ.04, i quattro strati al modello', () {
    final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');

    test('ogni strato ha la sua istruzione, e senza domanda parla dell incontro',
        () {
      final conDomanda = [
        for (var s = 1; s <= 4; s++)
          LaScenaDalModello.istruzione(lupo, strato: s),
      ];
      for (var s = 0; s < 4; s++) {
        expect(conDomanda[s], contains(LaScenaDalModello.stratiConDomanda[s]));
      }
      expect(conDomanda.toSet(), hasLength(4));
      final incontro = LaScenaDalModello.istruzione(lupo,
          strato: 2, soloIncontro: true);
      expect(incontro, contains(LaScenaDalModello.stratiDellIncontro[1]));
      expect(incontro, isNot(contains('lasciali vuoti')),
          reason: 'chi scende senza domanda deve ricevere i suoi testi');
      // Senza strato, dopo il riconoscimento, l'istruzione non ne parla.
      expect(LaScenaDalModello.istruzione(lupo), isNot(contains('STRATO')));
    });

    test('la richiesta porta gli strati gia dati, da non ripetere', () {
      final s = CioCheSiSa(
        domanda: 'Mia sorella non mi parla',
        tema: 'Una persona',
        animale: lupo,
        natale: const NatalContext(sunSign: 'Cancro'),
        memoria: '',
        ultimeScene: const [],
        strato: 3,
        stratiPrecedenti: const [
          (titolo: 'Cerchi un ritorno', risposta: 'R uno', azione: 'A uno'),
          (titolo: 'Ti ferma una parola', risposta: 'R due', azione: 'A due'),
        ],
      );
      final r = LaScenaDalModello.richiesta(s);
      expect(r, contains('Strato di oggi: 3 di 4'));
      expect(r, contains('da non ripetere'));
      expect(r, contains('Cerchi un ritorno'));
      expect(r, contains('R due'));
    });

    test('prima della quarta l animale non si nomina, e uno strato non si ripete',
        () {
      final s = CioCheSiSa(
        domanda: 'Mia sorella non mi parla',
        tema: 'Una persona',
        animale: lupo,
        natale: const NatalContext(sunSign: 'Cancro'),
        memoria: '',
        ultimeScene: const [],
        strato: 2,
        stratiPrecedenti: const [
          (
            titolo: 'Cerchi un ritorno',
            risposta: 'Con tua sorella cerchi un modo per tornare vicino.',
            azione: 'Stasera scrivi due righe su un foglio.',
          ),
        ],
      );
      final letti = LaScenaDalModello.leggiTesti(
          jsonEncode({
            'titolo': 'Hai il passo del lupo',
            'risposta': 'Con tua sorella cerchi un modo per tornare vicino.',
            'azione': 'Domani mattina esci a camminare mezz\'ora.',
          }),
          s);
      final motivi = {for (final r in letti.scarti) r.pezzo: r.motivo};
      expect(motivi['titolo'], MotivoDelloScarto.animaleAnticipato);
      expect(motivi['risposta'], MotivoDelloScarto.ripeteUnoStrato);
      expect(letti.azione, isNotNull);
      // Alla quarta il nome si dice.
      final alla4 = LaScenaDalModello.leggiTesti(
          jsonEncode({'titolo': 'Hai il passo del lupo'}),
          CioCheSiSa(
            domanda: 'Mia sorella non mi parla',
            tema: 'Una persona',
            animale: lupo,
            natale: const NatalContext(sunSign: 'Cancro'),
            memoria: '',
            ultimeScene: const [],
            strato: 4,
          ));
      expect(alla4.titolo, 'Hai il passo del lupo');
    });

    test('chi scende soltanto per incontrarlo riceve i testi del modello', () {
      final letti = LaScenaDalModello.leggiTesti(
          jsonEncode({
            'titolo': 'Qualcosa ti ha chiamato giù',
            'risposta': 'Sei scesa perché qualcosa ti chiedeva silenzio.',
            'azione': 'Stasera spegni il telefono per un\'ora.',
          }),
          CioCheSiSa(
            domanda: '',
            tema: null,
            animale: lupo,
            natale: const NatalContext(sunSign: 'Cancro'),
            memoria: '',
            ultimeScene: const [],
            strato: 1,
            forma: CourtesyForm.feminine,
          ));
      expect(letti.titolo, isNotNull);
      expect(letti.azione, isNotNull);
    });
  });

  group('DQ.01, DQ.02 e DQ.03 sulla schermata vera', () {
    const domanda = 'Mia sorella non mi parla da due anni e non so se cercarla';
    const titoli = [
      'Cerchi un ritorno',
      'Hai paura della prima parola',
      'Hai più di quanto credi',
      'Puoi fare il primo passo',
    ];
    const risposte = [
      'Con tua sorella cerchi un modo per tornare vicino.',
      'Con tua sorella hai paura di sbagliare la prima parola.',
      'Con tua sorella hai la memoria degli anni belli.',
      'Con tua sorella puoi scegliere tu il primo passo.',
    ];
    const azioni = [
      'Stasera scrivi due righe su un foglio.',
      'Domani mattina esci a camminare mezz\'ora.',
      'Entro sabato riguarda una vostra fotografia.',
      'Stasera scrivi un messaggio di due righe.',
    ];

    testWidgets(
        'la domanda si scrive una volta, si legge tre, il riquadro del cambio '
        'ha le parole dell ordine, e alla quarta i quattro strati si rileggono',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      LaMarcaDelGenere.formaCorrente = CourtesyForm.feminine;
      final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 15, 12));
      var chiamateDellaDomanda = 0;
      Future<void> apri(int giorno) async {
        await tester.pumpWidget(MultiProvider(
          key: UniqueKey(),
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
          ],
          child: MaterialApp(
            home: MaestroScope(
              child: ViaggioDelloSciamanoScreen(
                userSign: Zodiac.cancer,
                now: DateTime(2026, 9, 15 + giorno, 12),
                diario: diario,
                demo: false,
                chiamataDellaDomanda: (_, __) async {
                  chiamateDellaDomanda++;
                  return jsonEncode(
                      {'tema': 'persona', 'oggetto': 'tua sorella'});
                },
                chiamataDellaScena: (_, richiesta, ___) async {
                  final m = RegExp(r'Strato di oggi: (\d)').firstMatch(richiesta);
                  final s = int.parse(m?.group(1) ?? '1') - 1;
                  return jsonEncode({
                    'luogo': 'grotta',
                    'cosa': 'chiave',
                    'gesto': 'aspetta',
                    'momento': 'alba',
                    'titolo': titoli[s],
                    'risposta': risposte[s],
                    'azione': azioni[s],
                  });
                },
              ),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      Future<void> scendiERisali() async {
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
        final risali = find.byKey(const Key('viaggio_risali'));
        if (risali.evaluate().isNotEmpty) await tester.tap(risali);
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
      }

      // **LA PRIMA DISCESA**: la domanda si scrive.
      await apri(0);
      await tester.scrollUntilVisible(find.text('Scrivila tu'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Scrivila tu'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('viaggio_domanda')), domanda);
      await tester.pump();
      await scendiERisali();
      expect(chiamateDellaDomanda, 1);
      expect(find.text(LeParoleDelCammino.etichettaDelloStrato(1,
          conDomanda: true)), findsOneWidget);
      expect(find.text(titoli[0]), findsOneWidget);

      // **LA SECONDA**: la domanda si legge, al femminile, e non si scrive.
      await apri(1);
      expect(find.text('SEI SCESA PER QUESTO'), findsOneWidget);
      expect(find.byKey(const Key('viaggio_le_tre_vie')), findsNothing,
          reason: 'dalla seconda discesa la domanda non si chiede piu');
      expect(find.text(domanda), findsOneWidget);

      // **IL RIQUADRO DEL CAMBIO**, con le parole dell'ordine.
      await tester.ensureVisible(
          find.byKey(const Key('viaggio_cambia_la_domanda')));
      await tester.tap(find.byKey(const Key('viaggio_cambia_la_domanda')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('viaggio_avviso_del_cambio')), findsOneWidget);
      for (final p in LeParoleDelCammino.avvisoDelCambio) {
        expect(find.textContaining(p.substring(0, 40)), findsOneWidget,
            reason: p);
      }
      await tester.tap(find.byKey(const Key('viaggio_tengo_questa_domanda')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(diario.apparizioni, 1, reason: 'tenere la domanda non azzera');

      await scendiERisali();
      expect(chiamateDellaDomanda, 1,
          reason: 'dentro il cammino la domanda non si fa ricapire');
      expect(find.text(titoli[1]), findsOneWidget,
          reason: 'il secondo strato non ha la sua istruzione');
      await apri(2);
      await scendiERisali();
      expect(find.text(titoli[2]), findsOneWidget);

      // **LA QUARTA**: lo strato pieno e la rivelazione cadono insieme.
      await apri(3);
      await scendiERisali();
      expect(diario.riconosciuto, isTrue);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('viaggio_il_nome')), findsOneWidget);
      final rileggi = find.byKey(const Key('viaggio_rileggi_gli_strati'));
      await tester.ensureVisible(rileggi);
      await tester.tap(rileggi);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      for (var s = 1; s <= 4; s++) {
        expect(
            find.text(LeParoleDelCammino.etichettaDelloStrato(s,
                conDomanda: true)),
            findsOneWidget,
            reason: 'il Diario non mostra lo strato $s di fila');
      }
      expect(find.text(domanda), findsOneWidget);
    });

    testWidgets('comincio un altro viaggio: il cammino riparte dalla prima',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 15, 12));
      await diario.carica();
      final c = IlCammino(
          domanda: domanda,
          via: 'scritta',
          tema: 'persona',
          inizio: DateTime(2026, 9, 14, 12));
      await diario.cominciaIlCammino(c);
      await diario.segna(discesa(DateTime(2026, 9, 14, 13), c, 1));
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
              now: DateTime(2026, 9, 15, 12),
              diario: diario,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(
          find.byKey(const Key('viaggio_cambia_la_domanda')));
      await tester.tap(find.byKey(const Key('viaggio_cambia_la_domanda')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester
          .tap(find.byKey(const Key('viaggio_comincio_un_altro_viaggio')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(diario.apparizioni, 0);
      expect(diario.viaggi, hasLength(1));
      expect(find.byKey(const Key('viaggio_le_tre_vie')), findsOneWidget,
          reason: 'dopo il cambio si sceglie di nuovo con che cosa scendere');
      expect(find.byKey(const Key('viaggio_la_domanda_del_cammino')),
          findsNothing);
    });
  });
}
