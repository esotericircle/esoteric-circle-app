import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/arts/le_arti_del_giorno.dart';
import 'package:esoteric_circle/core/chat/la_marca_del_genere.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/santuario/la_categoria_intera.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA HOME PIU' FITTA.** Ordine EP, voci 02, 03, 04, 05, 06, 07 e 08, 26
/// settembre 2026.
///
/// Si misura la composizione vera che la home monta, `LeRigheDellaCasaView`,
/// contro i numeri dell'ordine scritti qui come numeri, e non contro le
/// costanti del codice: una costante cambiata cambierebbe anche la soglia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // I numeri dell'ordine EP.
  const verticaleInCasa = 162.0, orizzontaleInCasa = 253.0;
  const verticaleNeiDomini = 184.0, orizzontaleNeiDomini = 288.0;
  const margineASinistra = 16.0, spazioFraLeSchede = 12.0;
  const vuotoFraLeRighe = 24.0, fraTitoloESchede = 8.0;

  /// L'ordine delle righe, copiato dall'ordine EP voce 05.
  const righeDelFondatore = [
    'Le arti preferite',
    'Trova una risposta',
    'Da condividere',
    'Amore e affinità',
    'Le stelle parlano',
    'Conosci te stesso',
    'Il tuo corpo',
    'La tua serenità',
    'La tua intenzione',
    'La tua energia',
  ];

  Future<void> monta(WidgetTester tester,
      {double larghezza = 390, double scala = 1}) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(larghezza * 3, 844 * 3);
    addTearDown(tester.view.reset);
    final pref = ArtiPreferiteController();
    addTearDown(pref.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<ArtiPreferiteController>.value(value: pref),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Il tema vero dell'app: senza, "Vedi tutto" non eredita la
        // spaziatura delle lettere che sul Realme lo tagliava.
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data:
              MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: const Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
              child: LeRigheDellaCasaView(sensore: false)),
        ),
      ),
    ));
    await tester.pump();
  }

  List<LaRigaDelleSchede> righe(WidgetTester tester) => tester
      .widgetList<LaRigaDelleSchede>(find.byType(LaRigaDelleSchede))
      .toList();

  Finder schedeDi(String chiave) => find.byWidgetPredicate((w) =>
      w is LaSchedaDellArte &&
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('riga_${chiave}_'));

  // --- EP.02 ----------------------------------------------------------------

  for (final scala in const [1.0, 1.3]) {
    testWidgets(
        'EP.02: in home le schede sono all\'88 per cento e nessun titolo '
        'spezza una parola (testo a $scala)', (tester) async {
      await monta(tester, scala: scala);
      final lette = righe(tester);
      cardinaleMinimo(lette.length, 10,
          cosa: 'righe della home', perche: 'la home ha dieci righe.');
      var schede = 0;
      var parolaPiuLunga = '';
      var larghezzaPiuLunga = 0.0;
      for (final r in lette) {
        final attesa = (r.formato == FormatoDellaScheda.orizzontale
                ? orizzontaleInCasa
                : verticaleInCasa) *
            scala;
        for (final e in schedeDi(r.chiave).evaluate()) {
          final s = e.widget as LaSchedaDellArte;
          schede++;
          expect(s.larghezza, closeTo(attesa, 0.01),
              reason: '${r.chiave}/${s.art.id}: larga ${s.larghezza}');
        }
      }
      // Nessuna parola piu' larga della scheda: si spezzerebbe. Si guardano
      // TUTTE le arti delle righe, anche quelle fuori vista a destra.
      final tutte = {
        for (final r in LeRigheDellaCasa.righe)
          ...LeRigheDellaCasa.artiDi(r.arti),
        ...LeRigheDellaCasa.artiDi(ArtiPreferiteController.semePer(null)),
      };
      for (final art in tutte) {
        {
          for (final parola in art.title.split(' ')) {
            final p = TextPainter(
              text: TextSpan(
                  text: parola, style: LaSchedaDellArte.stileDelTitolo()),
              textDirection: TextDirection.ltr,
              textScaler: TextScaler.linear(scala),
            )..layout();
            if (p.width > larghezzaPiuLunga) {
              larghezzaPiuLunga = p.width;
              parolaPiuLunga = parola;
            }
            expect(p.width, lessThanOrEqualTo(verticaleInCasa * scala),
                reason: '${art.id}: "$parola" misura ${p.width} su '
                    '${verticaleInCasa * scala}, si spezza');
            p.dispose();
          }
        }
      }
      // ignore: avoid_print
      print('EP.02 MISURA (testo a $scala): schede montate $schede, arti '
          'della home ${tutte.length}, la '
          'parola piu\' lunga "$parolaPiuLunga" ${larghezzaPiuLunga.toStringAsFixed(1)} '
          'punti su ${(verticaleInCasa * scala).toStringAsFixed(1)}');
      cardinaleMinimo(schede, 20,
          cosa: 'schede della home montate',
          perche: 'le righe montano almeno due schede ciascuna.');
    });
  }

  testWidgets('EP.02: nei domini le schede restano 184 e 288', (tester) async {
    expect(LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale),
        verticaleNeiDomini);
    expect(LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.quadrata),
        verticaleNeiDomini);
    expect(LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.orizzontale),
        orizzontaleNeiDomini);
  });

  // --- EP.03 ----------------------------------------------------------------

  for (final larghezza in const [360.0, 390.0, 412.0]) {
    testWidgets('EP.03: margine 16 e spazio 12, a $larghezza punti',
        (tester) async {
      await monta(tester, larghezza: larghezza);
      final misure = <String>[];
      for (final r in righe(tester)) {
        // Il riquadro della scheda PRIMA del sollevamento: la scheda al
        // centro si ingrandisce dall'alto, e il suo bordo a video si sposta.
        final rect = [
          for (final e in schedeDi(r.chiave).evaluate())
            tester.getRect(find
                .ancestor(
                    of: find.byWidget(e.widget),
                    matching: find.byType(Transform))
                .first)
        ]..sort((a, b) => a.left.compareTo(b.left));
        expect(rect.length, greaterThanOrEqualTo(2), reason: r.chiave);
        expect(rect.first.left, closeTo(margineASinistra, 0.5),
            reason: '${r.chiave}: margine ${rect.first.left}');
        final passo = rect[1].left - rect[0].left;
        final larga = LaSchedaDellArte.larghezzaPer(r.formato, inCasa: true);
        expect(passo - larga, closeTo(spazioFraLeSchede, 0.5),
            reason: '${r.chiave}: spazio ${passo - larga}');
        final intere = ((larghezza - margineASinistra + spazioFraLeSchede) /
                (larga + spazioFraLeSchede))
            .floor();
        final resto =
            larghezza - margineASinistra - intere * (larga + spazioFraLeSchede);
        misure.add('${r.formato.name}: $intere intere e '
            '${(resto / larga * 100).clamp(0, 100).toStringAsFixed(0)}% della '
            'successiva');
      }
      // ignore: avoid_print
      print('EP.03 MISURA a $larghezza punti: ${misure.toSet().join('; ')}');
    });
  }

  // --- EP.04 ----------------------------------------------------------------

  for (final scala in const [1.0, 1.3]) {
    testWidgets(
        'EP.04: fra una riga e l\'altra 24 punti di vuoto, fra titolo e schede '
        '8 (testo a $scala)', (tester) async {
      await monta(tester, scala: scala);
      final lette = righe(tester);
      final vuoti = <double>[];
      final aRiposo = <double>[];
      for (var i = 0; i < lette.length; i++) {
        final r = lette[i];
        final titolo = find.byKey(i == 0
            ? const Key('tue_arti_titolo')
            : Key('riga_titolo_${r.chiave}'));
        final rTitolo = tester.getRect(titolo);
        // Fra il titolo della riga e le sue schede: 8 punti.
        final cimaImmagini = [
          for (final e in schedeDi(r.chiave).evaluate())
            tester.getRect(find.byWidget(e.widget)).top
        ].reduce((a, b) => a < b ? a : b);
        expect(cimaImmagini - rTitolo.bottom, closeTo(fraTitoloESchede, 0.5),
            reason: '${r.chiave}: fra titolo e schede '
                '${cimaImmagini - rTitolo.bottom}');
        if (i == 0) continue;
        // **Dalla fine della riga prima al titolo di questa.** La riga finisce
        // dove arriva il titolo piu' alto fra le sue arti, sulla scheda al
        // centro sollevata: nessun titolo la supera, e da li' al titolo dopo
        // restano 24 punti. Le schede in vista a riposo, coi titoli piu'
        // corti o non sollevate, finiscono piu' su: il loro vuoto si stampa.
        final prima = lette[i - 1];
        final fineRiga = tester
            .getRect(find.byKey(Key('riga_scorre_${prima.chiave}')))
            .bottom;
        vuoti.add(rTitolo.top - fineRiga);
        final fondi = [
          for (final e in schedeDi(prima.chiave).evaluate())
            tester
                .getRect(find.descendant(
                    of: find.byWidget(e.widget),
                    matching: find.byKey(Key(
                        'scheda_titolo_${(e.widget as LaSchedaDellArte).art.id}'))))
                .bottom
        ];
        final fondo = fondi.reduce((a, b) => a > b ? a : b);
        expect(fondo, lessThanOrEqualTo(fineRiga + 0.5),
            reason: '${prima.chiave}: un titolo esce dalla sua riga');
        aRiposo.add(rTitolo.top - fondo);
      }
      // ignore: avoid_print
      print('EP.04 MISURA (testo a $scala): vuoti fra le righe '
          '${vuoti.map((v) => v.toStringAsFixed(1)).join(', ')}; a riposo, dal '
          'titolo piu\' basso in vista, '
          '${aRiposo.map((v) => v.toStringAsFixed(1)).join(', ')}');
      cardinaleMinimo(vuoti.length, 9,
          cosa: 'vuoti fra le righe', perche: 'dieci righe fanno nove vuoti.');
      for (final v in vuoti) {
        expect(v, greaterThanOrEqualTo(vuotoFraLeRighe - 0.5),
            reason: 'un titolo di scheda arriva a $v punti dalla riga dopo');
        expect(v, lessThanOrEqualTo(vuotoFraLeRighe + 0.5),
            reason: 'fra una riga e l\'altra restano $v punti di vuoto');
      }
    });
  }

  // --- EP.05 ----------------------------------------------------------------

  testWidgets(
      'EP.05: le righe nell\'ordine del fondatore, con "Trova una '
      'risposta" seconda', (tester) async {
    await monta(tester);
    expect([for (final r in righe(tester)) r.titolo], righeDelFondatore);
    expect(find.text('Cerca una risposta'), findsNothing);
    expect(find.text('Trova una risposta'), findsOneWidget);
  });

  // --- EP.06 ----------------------------------------------------------------

  testWidgets(
      'EP.06: il puntino d\'oro sulle arti del giorno finche\' non si aprono, '
      'e il giorno dopo torna', (tester) async {
    addTearDown(LeArtiDelGiorno.istanza.azzera);
    LeArtiDelGiorno.istanza.azzera();
    LeArtiDelGiorno.adesso = () => DateTime(2026, 9, 26, 10);
    await monta(tester);
    await tester.pump();
    Finder puntino(String id) => find.byKey(Key('scheda_puntino_$id'));
    // In home l'Oroscopo sta nelle preferite: una scheda, un puntino.
    expect(puntino('horoscope'), findsWidgets,
        reason: 'l\'Oroscopo non ha il puntino prima di aprirlo');
    // Ogni arte del giorno a video ha il puntino, nessun'altra lo ha.
    final conPuntino = find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('scheda_puntino_'))
        .evaluate()
        .map((e) => (e.widget.key! as ValueKey<String>)
            .value
            .substring('scheda_puntino_'.length))
        .toSet();
    expect(conPuntino.difference(LeArtiDelGiorno.ids), isEmpty);
    // Il puntino non copre la "i": sta in basso, lei in alto.
    final rPuntino = tester.getRect(puntino('horoscope').first);
    final rI =
        tester.getRect(find.byKey(const Key('scheda_i_horoscope')).first);
    expect(rPuntino.overlaps(rI), isFalse, reason: 'il puntino copre la "i"');

    await LeArtiDelGiorno.istanza.aperta('horoscope');
    await tester.pump();
    expect(puntino('horoscope'), findsNothing,
        reason: 'aperto oggi, il puntino resta');
    expect(
        puntino('biorhythm').evaluate().isNotEmpty ||
            !find.byKey(const Key('riga_il_tuo_corpo_biorhythm')).hasFound,
        isTrue);

    LeArtiDelGiorno.adesso = () => DateTime(2026, 9, 27, 8);
    // Il giorno cambia: una ricostruzione qualunque lo rilegge.
    LeArtiDelGiorno.istanza.notifyListeners();
    await tester.pump();
    expect(puntino('horoscope'), findsWidgets,
        reason: 'il giorno dopo il puntino non e\' tornato');
  });

  test('EP.06: le arti del giorno sono arti del catalogo', () {
    final ids = {for (final a in ArtCatalog.all) a.id};
    cardinaleMinimo(LeArtiDelGiorno.ids.length, 4,
        cosa: 'arti del giorno',
        perche: 'Oroscopo, Affermazioni, Bioritmo, '
            'Luna.');
    expect(LeArtiDelGiorno.ids.difference(ids), isEmpty);
    expect(LeArtiDelGiorno.ids,
        containsAll(['horoscope', 'daily_affirmations', 'biorhythm']));
  });

  // --- EP.07 ----------------------------------------------------------------

  testWidgets('EP.07: "Vedi tutto" su ogni riga, e apre la categoria intera',
      (tester) async {
    await monta(tester);
    final lette = righe(tester);
    var aperte = 0;
    for (final r in lette) {
      final vedi = find.byKey(Key('riga_vedi_tutto_${r.chiave}'));
      expect(vedi, findsOneWidget, reason: '${r.chiave}: manca Vedi tutto');
      await tester.ensureVisible(vedi);
      await tester.tap(vedi);
      await tester.pumpAndSettle();
      final griglia = find.byType(LaCategoriaIntera);
      expect(griglia, findsOneWidget, reason: '${r.chiave}: nessuna griglia');
      final attese = r.chiave == LeRigheDellaCasa.preferite
          ? ArtiPreferiteController.semePer(null)
          : LeRigheDellaCasa.righe.firstWhere((x) => x.chiave == r.chiave).arti;
      final mostrate = tester.widget<LaCategoriaIntera>(griglia).arti;
      expect([for (final a in mostrate) a.id], attese,
          reason: '${r.chiave}: la griglia non ha tutte le arti');
      expect(
          find.descendant(of: griglia, matching: find.byType(LaSchedaDellArte)),
          findsNWidgets(attese.length));
      expect(
          tester
              .widget<Text>(find.byKey(const Key('categoria_intera_titolo')))
              .data,
          LaMarcaDelGenere.risolvi(r.titolo));
      aperte++;
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(aperte, 10);
    // Nelle preferite la matita resta.
    expect(find.byKey(const Key('tue_arti_matita')), findsOneWidget);
  });

  // **NATA DAL REALME, build 2284 di prova.** Con "Vedi tutto" accanto, i
  // titoli delle righe si spezzavano a meta' parola ("LE ARTI PREFER / ITE")
  // e "Trova una risposta" andava su tre righe: lo spazio vuoto e il titolo
  // si dividevano a meta' la riga. Nessuna prova guardava i titoli delle
  // righe, solo quelli delle schede.
  for (final larghezza in const [360.0, 390.0]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets(
          'EP.07: coi "Vedi tutto" accanto, i titoli delle righe non spezzano '
          'parole e stanno su una riga (a $larghezza punti, testo $scala)',
          (tester) async {
        await monta(tester, larghezza: larghezza, scala: scala);
        final lette = righe(tester);
        final misure = <String>[];
        for (var i = 0; i < lette.length; i++) {
          final titolo = find.byKey(i == 0
              ? const Key('tue_arti_titolo')
              : Key('riga_titolo_${lette[i].chiave}'));
          final p = tester.renderObject<RenderParagraph>(find
              .descendant(
                  of: titolo, matching: find.byType(RichText), matchRoot: true)
              .first);
          final una = TextPainter(
            text: TextSpan(text: 'A', style: p.text.style),
            textDirection: TextDirection.ltr,
            textScaler: p.textScaler,
          )..layout();
          final quante = (p.size.height / una.height).round();
          una.dispose();
          misure.add('${lette[i].titolo}: $quante');
          for (final parola in p.text.toPlainText().split(' ')) {
            final w = TextPainter(
              text: TextSpan(text: parola, style: p.text.style),
              textDirection: TextDirection.ltr,
              textScaler: p.textScaler,
            )..layout();
            expect(w.width, lessThanOrEqualTo(p.constraints.maxWidth + 0.5),
                reason: '"${lette[i].titolo}": "$parola" misura '
                    '${w.width.toStringAsFixed(1)} su '
                    '${p.constraints.maxWidth.toStringAsFixed(1)}, si spezza');
            w.dispose();
          }
          if (scala == 1.0) {
            expect(quante, 1,
                reason: '"${lette[i].titolo}" va su $quante righe');
          }
          // **"VEDI TUTTO" INTERO.** Sul Realme, build 2284 di prova, si
          // leggeva "Vedi tutt": il pulsante ereditava dal tema una
          // spaziatura delle lettere che la larghezza riservata non contava.
          final vedi = tester.renderObject<RenderParagraph>(find
              .descendant(
                  of: find.byKey(Key('riga_vedi_tutto_${lette[i].chiave}')),
                  matching: find.byType(RichText))
              .first);
          expect(vedi.didExceedMaxLines, isFalse,
              reason: '${lette[i].chiave}: "Vedi tutto" e\' tagliato');
          expect(
              vedi.size.width,
              greaterThanOrEqualTo(
                  vedi.getMaxIntrinsicWidth(double.infinity) - 0.5),
              reason: '${lette[i].chiave}: "Vedi tutto" non ci sta intero');
        }
        // ignore: avoid_print
        print('EP.07 MISURA a $larghezza punti, testo $scala: righe dei '
            'titoli ${misure.join('; ')}');
      });
    }
  }

  test('EP.07: la griglia sta in due colonne anche a 360 punti', () {
    expect(LaCategoriaIntera.colonne(360, verticaleInCasa), 2);
    expect(LaCategoriaIntera.colonne(412, verticaleInCasa), 2);
  });

  // --- EP.08 ----------------------------------------------------------------

  testWidgets('EP.08: i titoli delle righe sono in oro, in home e nei domini',
      (tester) async {
    await monta(tester);
    final lette = righe(tester);
    var inOro = 0;
    for (var i = 0; i < lette.length; i++) {
      final t = tester.widget<Text>(find.byKey(i == 0
          ? const Key('tue_arti_titolo')
          : Key('riga_titolo_${lette[i].chiave}')));
      expect(t.style?.color, ColorTokens.gold, reason: lette[i].chiave);
      inOro++;
    }
    expect(inOro, 10);
    // Nei domini la riga e' la stessa, senza le misure della home.
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              body: LaRigaDelleSchede(
                chiave: 'dominio_prova',
                titolo: 'Divinazione',
                formato: FormatoDellaScheda.verticale,
                arti: LeRigheDellaCasa.artiDi(const ['rune_draw', 'pendulum']),
              ),
            ),
          ),
        )));
    expect(
        tester
            .widget<Text>(find.byKey(const Key('riga_titolo_dominio_prova')))
            .style
            ?.color,
        ColorTokens.gold);
  });
}
