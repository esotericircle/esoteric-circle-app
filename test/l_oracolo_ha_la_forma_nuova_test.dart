// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/l_ora_degli_angeli.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_giro_dell_oracolo.dart';

/// **L'ORACOLO HA LA FORMA NUOVA.** Ordine GA voci GA.03, GA.04, GA.05,
/// GA.06 e GA.07, 20 ottobre 2026. Il fondatore, 19 ottobre 2026: *"tutte le
/// risposte composte da paragrafi ognuno con tra 40 a 50 parole ognuno. Per
/// le risposte brevi 2 paragrafi di cui il secondo messo in evidenza in un
/// riquadro e questo riquadro deve intitolarsi 'cosa fare adesso' [...] Per
/// le risposte lunghe aggiungi 2 paragrafi sempre con il primo in riquadro.
/// Sotto sempre il paragrafo in corsivo 'da dove viene'. Restano all'inizio i
/// titoli, anche per le singola carte"*; 20 ottobre 2026: *"Profondità lunga
/// solo dal tier 1 e solo per il responso principale e non per le singole
/// carte"*.
///
/// Pretende: ogni messaggio e ogni consiglio del corpus fra 40 e 50 parole;
/// il responso del corpus e quello del modello (finto, regola SPESE), Breve e
/// Lunga, senza difetti della forma (`ResponsoInterpretato.difetti`), col
/// salmo dell'angelo del Custode; una risposta fuori misura scartata e mai
/// troncata; l'istruzione comune una volta sola; a video il titolo, "Cosa
/// fare adesso", "Il salmo propiziatorio" nella Lunga e il "Da dove viene" in
/// corsivo, una volta sola, in fondo. Vista rossa: `docs/collaudo/GA/
/// oracolo_regola_a.txt`.
const _catture = String.fromEnvironment('CATTURE');

AngelTriad _triade() => GuardianAngels.forBirth(BirthIdentity(
        birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true)
    .toBirthDetails());

/// Le tre carte di una consultazione col Custode [n] (gli altri due diversi).
List<CartaDellOracolo> _carteColCustode(int n) {
  final altri = [
    for (var k = 1; k <= 72; k++)
      if (k != n) k
  ];
  return EstrazioneDellOracolo.dalleScelte(
      _triade(), [n, altri[n % altri.length], altri[(n + 7) % altri.length]]);
}

class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

Future<void> _monta(WidgetTester tester, Tier tier) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const SizedBox());
  // Il rapporto del corredo delle anteprime (`corredo_anteprime_test.dart`):
  // in questo file si scrivono anche le catture, e ogni misura dichiara il
  // rapporto 3. Lo schermo resta di 390 per 844 punti.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: false)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (c, figlio) => MaestroScope(child: figlio!),
      home: OracoloDegliAngeliScreen(
        fabbricaDellaScena: _Ferma.new,
        caso: Random(7),
        adesso: () => DateTime(2026, 10, 15, 10, 5),
        identita: BirthIdentity(
            birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true),
        chiamata: (i, r, c) async => jsonFintoDellOracolo(c),
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = true);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('il corpus nella misura nuova', () {
    test('ogni messaggio e ogni consiglio ha da 40 a 50 parole', () {
      final fuori = <String>[];
      var misurati = 0;
      var caratteri = 0.0;
      for (final e in corpusDellOracolo.entries) {
        // Il dono e la via (ordine GA voce GA.06) sono pezzi di frase del
        // responso composto, non paragrafi: la loro misura la tiene lo
        // strumento, e quella del responso l_oracolo_risponde_dai_doni_test.
        if (e.key.endsWith('|rito') ||
            e.key.startsWith('doni|') ||
            e.key.startsWith('letture|')) {
          continue;
        }
        for (final (i, t) in e.value.indexed) {
          misurati++;
          final n = LaFormaDelResponso.parole(t);
          if (!LaFormaDelResponso.aMisura(t)) {
            fuori.add('${e.key} variante ${i + 1}: $n parole');
          }
          caratteri = max(caratteri, t.length / n);
        }
      }
      cardinaleMinimo(misurati, 1296,
          cosa: 'messaggi e consigli dell\'Oracolo misurati',
          perche: '648 messaggi e 648 consigli (ordine GA)');
      print('GA.03 MISURA corpus dell\'Oracolo: paragrafi misurati $misurati, '
          'fuori da 40-50 parole ${fuori.length}; caratteri per parola al '
          'piu\' ${caratteri.toStringAsFixed(2)} (tetto '
          '${LaLetturaDellOracolo.caratteriPerParola})');
      expect(fuori, isEmpty, reason: 'fuori misura: $fuori');
      // I tetti dei gettoni si scrivono dalla misura (GA.07).
      expect(caratteri,
          lessThanOrEqualTo(LaLetturaDellOracolo.caratteriPerParola));
    });

    test('ogni carta singola e\' un responso breve senza difetti', () {
      final colpe = <String>[];
      var carte = 0;
      for (final a in AngelCatalog.all) {
        for (final ruolo in RuoloDellAngelo.values) {
          for (var v = 0; v < 3; v++) {
            // Una carta scoperta: il portatore c'e'.
            final c = CartaDellOracolo(ruolo: ruolo, angelo: a, portatore: a);
            final r = LaLetturaDellOracolo.responsoDellaCarta(
                corpusDellOracolo, c, v);
            carte++;
            if (r == null) {
              colpe.add('${ruolo.name} ${a.number}: nessun responso');
              continue;
            }
            expect(r.lungo, isFalse);
            expect(r.titolo, a.name);
            colpe.addAll(r.difetti(conLaFonte: false));
          }
        }
      }
      cardinaleMinimo(carte, 648, cosa: 'carte singole guardate');
      print('GA.05 MISURA carte singole guardate $carte, difetti '
          '${colpe.length}');
      expect(colpe, isEmpty, reason: '$colpe');
    });
  });

  group('il responso principale', () {
    test(
        'del corpus (assaggio e ripiego): composto dai doni, breve, senza '
        'difetti, mai la carta del Custode copiata', () {
      // LAPIDE, ordine GA voce GA.06: qui si pretendeva che il responso del
      // corpus FOSSE la carta del Custode (GA.05). Il lettore cieco l'ha
      // trovata copiata 40 volte su 40 (D1): adesso si pretende il contrario,
      // e le guardie della cura stanno in l_oracolo_risponde_dai_doni_test.
      final colpe = <String>[];
      var visti = 0;
      for (var n = 1; n <= 72; n++) {
        final carte = _carteColCustode(n);
        for (final solo in const [false, true]) {
          final r = LaLetturaDellOracolo.delCorpus(
              domanda: 'Devo cambiare lavoro?',
              carte: carte,
              corpus: corpusDellOracolo,
              variante: n % 3,
              soloIlCustode: solo);
          visti++;
          expect(r.dalModello, isFalse);
          expect(r.responso.lungo, isFalse);
          expect(
              r.responso.risposta,
              isNot(corpusDellOracolo[LOraDegliAngeli.chiave(
                  RuoloDellAngelo.custode, AngelCatalog.byNumber(n))]![n % 3]));
          expect(r.responso.risposta, contains(AngelCatalog.byNumber(n).name));
          colpe.addAll(r.responso.difetti());
        }
      }
      cardinaleMinimo(visti, 144, cosa: 'responsi del corpus guardati');
      expect(colpe, isEmpty, reason: '$colpe');
    });

    test(
        'del modello, Breve e Lunga, senza difetti, col salmo dell\'angelo '
        'del Custode e la sua fonte nel "Da dove viene"', () async {
      final colpe = <String>[];
      var lunghe = 0;
      for (var n = 1; n <= 72; n++) {
        final carte = _carteColCustode(n);
        final custode = AngelCatalog.byNumber(n);
        for (final profonda in const [false, true]) {
          final r = await LaLetturaDellOracolo.leggi(
              domanda: 'Devo cambiare lavoro?',
              carte: carte,
              corpus: corpusDellOracolo,
              variante: 0,
              profonda: profonda,
              chiamata: (i, rr, c) async => jsonFintoDellOracolo(c));
          expect(r.dalModello, isTrue);
          colpe.addAll(r.responso.difetti());
          expect(r.responso.lungo, profonda);
          if (!profonda) {
            expect(r.responso.daDoveViene, isNot(contains('Martini')));
            continue;
          }
          lunghe++;
          final salmo = IRitiPropiziatori.rito(IRitiPropiziatori.salmiMartini,
              ['${custode.number}', custode.name]);
          expect(salmo, isNotNull, reason: 'manca il salmo di ${custode.name}');
          expect(r.responso.rito, salmo,
              reason: 'il salmo non e\' quello dell\'angelo del Custode');
          expect(r.responso.approfondimento, approfondimentoFintoDellOracolo);
          expect(
              r.responso.daDoveViene,
              contains(IRitiPropiziatori.fonte(IRitiPropiziatori.salmiMartini,
                  ['${custode.number}', custode.name])!));
          expect(r.responso.daDoveViene, contains('Martini'));
        }
      }
      cardinaleMinimo(lunghe, 72, cosa: 'responsi Lunghi guardati');
      print('GA.03 e GA.04 MISURA responsi del modello finto: 144 (72 Brevi '
          'e $lunghe Lunghi), difetti della forma ${colpe.length}');
      expect(colpe, isEmpty, reason: '$colpe');
    });

    test(
        'una risposta del modello fuori misura non si tronca: si scarta e '
        'parla il corpus', () async {
      final carte = _carteColCustode(7);
      final lunga = List.filled(30, rispostaFintaDellOracolo).join(' ');
      for (final (nome, json) in [
        (
          'risposta di 70 parole',
          jsonEncode({
            'titolo': 'Un passo lento',
            'risposta': '$rispostaFintaDellOracolo $cosaFareFintoDellOracolo'
                .split(' ')
                .take(70)
                .join(' '),
            'cosaFare': cosaFareFintoDellOracolo,
          })
        ),
        (
          'riquadro di 12 parole',
          jsonEncode({
            'titolo': 'Un passo lento',
            'risposta': rispostaFintaDellOracolo,
            'cosaFare': 'Scrivi stasera tre cose che sai fare e scegline una.',
          })
        ),
        (
          'approfondimento enorme',
          jsonEncode({
            'titolo': 'Un passo lento',
            'risposta': rispostaFintaDellOracolo,
            'cosaFare': cosaFareFintoDellOracolo,
            'approfondimento': lunga,
          })
        ),
      ]) {
        final r = await LaLetturaDellOracolo.leggi(
            domanda: 'Come ritrovo la calma in questi giorni?',
            carte: carte,
            corpus: corpusDellOracolo,
            variante: 0,
            profonda: true,
            chiamata: (i, rr, c) async => json);
        expect(r.dalModello, isFalse, reason: '$nome: non e\' stata scartata');
        // Al posto del testo del modello, intero o tagliato, parla il corpus:
        // dall'ordine GA voce GA.06 il responso composto dai doni.
        expect(
            r.responso.risposta,
            LaLetturaDellOracolo.delCorpus(
                    domanda: 'Come ritrovo la calma in questi giorni?',
                    carte: carte,
                    corpus: corpusDellOracolo,
                    variante: 0)
                .responso
                .risposta,
            reason: '$nome: un testo del modello e\' passato, forse tagliato');
        expect(r.responso.difetti(), isEmpty);
      }
    });

    test('l\'istruzione comune della forma compare una volta sola', () {
      for (final lunga in const [false, true]) {
        final comune = LaFormaDelResponso.perIlModello(
            arte: ArteInterpretata.oracolo, lunga: lunga);
        final istruzione = LaLetturaDellOracolo.istruzione(null, lunga);
        final volte = istruzione.split(comune).length - 1;
        print('GA.06 MISURA l\'istruzione comune nell\'istruzione '
            '${lunga ? 'Lunga' : 'Breve'}: $volte');
        expect(volte, 1);
        // **DOPO L'UNIONE CON I TAROCCHI**, 20 ottobre 2026: la forma comune
        // e' quella scritta per la Stesa, con la sua intestazione
        // (`LaFormaDelResponso.intestazioneDelModello`). Si conta anche
        // l'intestazione: un secondo pezzo della forma, anche diverso da
        // questo, la porterebbe due volte.
        final intestazioni = LaFormaDelResponso.intestazioneDelModello
            .allMatches(istruzione)
            .length;
        print('GA.06 MISURA l\'intestazione della forma nell\'istruzione '
            '${lunga ? 'Lunga' : 'Breve'}: $intestazioni');
        expect(intestazioni, 1);
        // La regola di casa la dice una volta: nessuna seconda misura.
        expect('da 40 a 50 parole'.allMatches(istruzione).length, 1);
        expect(istruzione, isNot(contains('400 caratteri')));
        // Il campo dell'approfondimento solo nella Lunga.
        expect(istruzione.contains('APPROFONDIMENTO (campo "approfondimento")'),
            lunga);
        // Il salmo propiziatorio non lo scrive il modello (GA.04, "nessuna
        // formula inventata"): l'istruzione non lo nomina, ne' Breve ne'
        // Lunga, e il modello non ha un campo per scriverlo.
        expect(
            istruzione.contains(
                LaFormaDelResponso.titoloDelRito(ArteInterpretata.oracolo)),
            isFalse);
        expect(LaLetturaDellOracolo.campi(profonda: lunga).keys,
            isNot(contains('rito')));
      }
    });
  });

  group('a video', () {
    testWidgets(
        'la Lunga dell\'Iniziato: titolo, "Cosa fare adesso", '
        '"Il salmo propiziatorio", e il "Da dove viene" in corsivo una volta '
        'sola, in fondo', (tester) async {
      await _monta(tester, Tier.tier1);
      // GC.19: la Lunga si sceglie nel selettore; all'apertura e' Breve.
      await scegliLaLunga(tester);
      await consultaLOracolo(tester, 'Devo cambiare lavoro?');
      final principale = find.byKey(const Key('oracolo_responso_principale'));
      expect(principale, findsOneWidget);
      expect(
          find.descendant(
              of: principale,
              matching: find.byKey(const Key('oracolo_principale_titolo'))),
          findsOneWidget);
      for (final titolo in const [
        'Cosa fare adesso',
        'Il salmo propiziatorio'
      ]) {
        expect(find.descendant(of: principale, matching: find.text(titolo)),
            findsOneWidget,
            reason: 'manca "$titolo" nel responso principale');
      }
      expect(
          find.descendant(
              of: principale, matching: find.byType(RiquadroInEvidenza)),
          findsOneWidget);
      expect(
          find.descendant(
              of: principale, matching: find.byType(RiquadroArancione)),
          findsOneWidget);
      // **DALL'ORDINE GC VOCE GC.15** la carta singola ha il titolo e un
      // paragrafo, "Il suo messaggio per te", senza riquadro. LAPIDE: "ogni
      // carta ha il suo riquadro" (GA.05).
      for (final r in const ['custode', 'cuore', 'intelletto']) {
        expect(find.byKey(Key('oracolo_carta_singola_${r}_cosa_fare')),
            findsNothing,
            reason: 'la carta $r ha ancora il suo "Cosa fare adesso"');
        expect(
            find.byKey(Key('oracolo_carta_singola_${r}_titolo')), findsNothing);
        expect(find.byKey(Key('oracolo_carta_singola_${r}_rito')), findsNothing,
            reason: 'la Lunga e\' solo del responso principale');
      }
      // Ogni paragrafo della forma e' UN paragrafo a video: un testo solo,
      // intero, non spezzato in blocchi.
      for (final (chiave, atteso) in const [
        ('oracolo_principale_risposta', rispostaFintaDellOracolo),
        ('oracolo_principale_cosa_fare', cosaFareFintoDellOracolo),
        ('oracolo_principale_approfondimento', approfondimentoFintoDellOracolo),
      ]) {
        final testi = [
          for (final e in find
              .descendant(
                  of: find.byKey(Key(chiave)), matching: find.byType(RichText))
              .evaluate())
            (e.widget as RichText).text.toPlainText(),
        ];
        expect(testi, [atteso],
            reason: '$chiave non e\' un paragrafo solo: $testi');
      }
      final etichette = find.text('Da dove viene').evaluate().length;
      final fonte = find.byKey(const Key('oracolo_da_dove_viene'));
      print('GA.03 MISURA a video, Iniziato: "Da dove viene" $etichette, '
          'riquadri "Cosa fare adesso" '
          '${find.text('Cosa fare adesso').evaluate().length}');
      expect(etichette, 1);
      expect(fonte, findsOneWidget);
      expect(tester.widget<Text>(fonte).style?.fontStyle, FontStyle.italic);
      expect(tester.widget<Text>(fonte).data, contains('Martini'));
      // In fondo: sotto l'ultima carta.
      expect(
          tester.getTopLeft(fonte).dy,
          greaterThan(tester
              .getBottomLeft(find.byKey(const Key('oracolo_bolla_intelletto')))
              .dy));
    });

    testWidgets(
        'l\'assaggio del Viandante: la Breve composta dai doni, e la bolla '
        'del Custode porta il suo messaggio', (tester) async {
      // LAPIDE, ordine GA voce GA.06: qui la bolla del Custode taceva, perche'
      // il principale era la sua carta copiata. Adesso il principale si
      // compone dai doni e la bolla porta il messaggio della carta.
      await _monta(tester, Tier.free);
      await consultaLOracolo(tester, 'Devo cambiare lavoro?');
      final principale = find.byKey(const Key('oracolo_responso_principale'));
      expect(
          find.descendant(
              of: principale, matching: find.text('Cosa fare adesso')),
          findsOneWidget);
      expect(find.text('Il salmo propiziatorio'), findsNothing);
      expect(find.byKey(const Key('oracolo_messaggio_custode')), findsWidgets,
          reason: 'la bolla del Custode deve portare il suo messaggio');
      expect(find.text('Da dove viene').evaluate().length, 1);
    });
  });

  // **LE CATTURE**, solo con `--dart-define=CATTURE=si`: la schermata a 360
  // per 797 punti col rapporto 3, in docs/collaudo/GA/oracolo/, per guardare
  // la forma a video (regola R6 dell'ordine: ogni affermazione visiva e' una
  // cattura). Senza, la prova non fa niente.
  testWidgets('GA: le catture dell\'Oracolo nella forma nuova', (tester) async {
    if (_catture.isEmpty) return;
    final radice = GlobalKey();
    Future<void> scatta(String nome) async {
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 3.0);
        final dati = await img.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('docs/collaudo/GA/oracolo');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/$nome.png')
            .writeAsBytesSync(dati!.buffer.asUint8List());
        print('GA CATTURA: ${dir.path}/$nome.png');
        img.dispose();
      });
    }

    Future<void> monta(Tier tier) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const SizedBox());
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2391);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(
              create: (_) => SettingsController(suonoEVibrazione: false)),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
        ],
        child: RepaintBoundary(
          key: radice,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            builder: (c, figlio) => MaestroScope(child: figlio!),
            home: OracoloDegliAngeliScreen(
              fabbricaDellaScena: _Ferma.new,
              caso: Random(7),
              adesso: () => DateTime(2026, 10, 15, 10, 5),
              identita: BirthIdentity(
                  birthMoment: DateTime(1990, 5, 12, 14, 30),
                  hasBirthTime: true),
              chiamata: (i, r, c) async => jsonFintoDellOracolo(c),
            ),
          ),
        ),
      ));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> vai(String chiave, [double dove = 0.1]) async {
      await Scrollable.ensureVisible(tester.element(find.byKey(Key(chiave))),
          alignment: dove);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await monta(Tier.tier1);
    await scatta('ga08_01_apertura_altare_vuoto');
    await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
    await toccaIlDorso(tester, dorsiDelGiro[0]);
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await tester.pump(const Duration(milliseconds: 500));
    await scatta('ga08_02_il_primo_dorso_scelto');
    await toccaIlDorso(tester, dorsiDelGiro[1]);
    await toccaIlDorso(tester, dorsiDelGiro[2]);
    await avviaLaLettura(tester);
    await vai('oracolo_responso_principale');
    await scatta('ga03_03_iniziato_lunga_titolo_e_risposta');
    await vai('oracolo_principale_approfondimento', 0.3);
    await scatta('ga04_04_iniziato_lunga_il_salmo');
    await vai('oracolo_bolla_cuore');
    await scatta('ga05_05_la_carta_singola_del_cuore');
    await vai('oracolo_messaggio_cuore', 0.2);
    await scatta('ga05_06_la_carta_singola_cosa_fare');
    await vai('oracolo_da_dove_viene', 0.6);
    await scatta('ga03_07_da_dove_viene_in_fondo');
    await monta(Tier.free);
    await consultaLOracolo(tester, 'Devo cambiare lavoro?');
    await vai('oracolo_responso_principale');
    await scatta('ga05_08_viandante_breve_del_custode');
    await vai('oracolo_bolla_custode');
    await scatta('ga05_09_viandante_la_bolla_non_ripete');
  });
}
