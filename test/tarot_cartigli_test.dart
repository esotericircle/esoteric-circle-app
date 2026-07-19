import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:esoteric_circle/features/tarot/tarot_cartiglio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// I cartigli delle carte, riempiti a runtime: numerale in alto e nome in
/// basso, sempre dentro il blu piatto, mai sull'oro, alla massima misura che ci
/// sta. Quando la carta e' rovesciata gira tutta la carta,
/// cartigli inclusi, come una carta vera girata in mano.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  });

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  // Misura di riferimento della carta a schermo, dal lato conservativo.
  const cardW = 150.0;
  const cardH = cardW / TarotFrame.aspect;

  /// La larghezza del solo inchiostro alla misura scelta. Usa la stessa
  /// funzione del codice, cosi' misura e resa non possono divergere.
  double larghezza(String testo, TextStyle base, CartiglioAreaFit fit) =>
      larghezzaInchiostro(
        testo: testo.toUpperCase(),
        base: base,
        fontSize: fit.fontSize,
        letterSpacing: fit.letterSpacing,
      );

  group('Numerali', () {
    test('Ogni carta ha un numerale, romano ai Maggiori', () {
      const romani = {
        '0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', //
        'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX',
        'XXI'
      };
      var maggiori = 0;
      for (final card in TarotDeck.cards) {
        expect(card.numeral.trim(), isNotEmpty,
            reason: 'numerale vuoto per ${card.name}');
        if (card.arcana == TarotArcana.maggiore) {
          maggiori++;
          expect(romani.contains(card.numeral), isTrue,
              reason: '${card.name} ha numerale ${card.numeral}');
        }
      }
      expect(maggiori, 22);
      final numeraliMaggiori = TarotDeck.cards
          .where((c) => c.arcana == TarotArcana.maggiore)
          .map((c) => c.numeral)
          .toSet();
      expect(numeraliMaggiori.length, 22);
    });

    test('I Minori usano il numero arabo, corti comprese', () {
      for (final card in TarotDeck.cards) {
        if (card.arcana != TarotArcana.minore) continue;
        expect(card.numeral, '${card.number}');
        expect(int.tryParse(card.numeral), inInclusiveRange(1, 14));
      }
    });
  });

  group('Carte di corte', () {
    test('Le sedici carte di corte sono riconosciute, e solo quelle', () {
      final corti = TarotDeck.cards.where((c) => c.isCorte).toList();
      expect(corti.length, 16, reason: 'quattro figure per quattro semi');
      for (final c in corti) {
        expect(c.number, inInclusiveRange(11, 14));
      }
    });

    test('Nel cartiglio superiore le corti portano il numero', () {
      const atteso = {11: '11', 12: '12', 13: '13', 14: '14'};
      for (final c in TarotDeck.cards.where((c) => c.isCorte)) {
        expect(c.numeral, atteso[c.number],
            reason: '${c.name} non porta il suo numero');
        // Mai il grado scritto: in quella placca stretta non si leggerebbe.
        expect(int.tryParse(c.numeral), isNotNull);
      }
    });

    testWidgets('Nel cartiglio alto va il numero, non la parola',
        (tester) async {
      final cavaliere =
          TarotDeck.cards.firstWhere((c) => c.name == 'Cavaliere di Bastoni');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: TarotCardArt(card: cavaliere, palette: palette),
            ),
          ),
        ),
      ));
      await tester.pump();
      // Il numero e' in campo, in alto.
      final numero = find.descendant(
          of: find.byType(CartiglioNumero), matching: find.text('12'));
      expect(numero, findsOneWidget);
      final rettCarta = tester.getRect(find.byType(TarotCardArt));
      expect(tester.getRect(numero).center.dy,
          lessThan(rettCarta.center.dy));
      // La parola CAVALIERE resta solo nel cartiglio del nome, in basso.
      expect(find.text('CAVALIERE'), findsOneWidget);
      expect(tester.getRect(find.text('CAVALIERE')).center.dy,
          greaterThan(rettCarta.center.dy));
    });
  });

  group('Cartigli dentro il blu, mai sull\'oro', () {
    test('Il rettangolo di layout e la placca disegnata hanno una sola '
        'sorgente', () {
      // Il rettangolo in cui il testo viene disposto e dimensionato non e' un
      // riquadro a parte: e' la placca blu misurata sull'artwork meno il
      // respiro, ricavata dalla stessa funzione. Se qualcuno reintroducesse un
      // riquadro piu' piccolo, il testo riempirebbe quello invece della placca
      // che si vede, e qui cadrebbe.
      expect(TarotFrame.cartiglioNome,
          TarotFrame.areaUtile(TarotFrame.placcaNome));
      expect(TarotFrame.cartiglioNumero,
          TarotFrame.areaUtile(TarotFrame.placcaNumero));
    });

    test('Ogni cartiglio lascia lo stesso respiro sui quattro lati', () {
      for (final coppia in [
        [TarotFrame.cartiglioNumero, TarotFrame.placcaNumero],
        [TarotFrame.cartiglioNome, TarotFrame.placcaNome],
      ]) {
        final testo = coppia[0];
        final placca = coppia[1];
        // Dentro la placca, mai oltre.
        expect(testo.left, greaterThanOrEqualTo(placca.left));
        expect(testo.right, lessThanOrEqualTo(placca.right));
        expect(testo.top, greaterThanOrEqualTo(placca.top));
        expect(testo.bottom, lessThanOrEqualTo(placca.bottom));

        // Il respiro c'e' su tutti e quattro i lati, ed e' simmetrico. In
        // pixel vale uguale sopra, sotto e ai lati: in frazione l'orizzontale
        // e' piu' piccolo perche' la carta e' piu' alta che larga.
        final sopra = testo.top - placca.top;
        final sotto = placca.bottom - testo.bottom;
        final sx = testo.left - placca.left;
        final dx = placca.right - testo.right;
        for (final m in [sopra, sotto, sx, dx]) {
          expect(m, greaterThan(0), reason: 'un lato resta a filo dell\'oro');
        }
        expect((sopra - sotto).abs(), lessThan(1e-6));
        expect((sx - dx).abs(), lessThan(1e-6));
        // Il respiro e' proporzionale all'altezza della placca, non fisso.
        expect(sopra, closeTo(placca.height * TarotFrame.margineTesto, 1e-6));
        // In pixel su una carta 150 x 225, il respiro orizzontale e' quello
        // verticale, non di piu'.
        expect(sx * cardW, closeTo(sopra * cardH, 0.01));
      }
    });

    test('Le due righe di un nome lungo non si toccano', () {
      final base = cartiglioBaseStyle(palette);
      final rect = TarotFrame.cartiglioNome;
      final maxW = (rect.right - rect.left) * cardW;
      final maxH = (rect.bottom - rect.top) * cardH;

      for (final card in TarotDeck.cards) {
        final righe = splitNomeCartiglio(card.name);
        if (righe.length < 2) continue;
        final fit = resolveCartiglioArea(
            righe: [for (final r in righe) r.toUpperCase()],
            base: base,
            maxWidth: maxW,
            maxHeight: maxH);
        // Il vuoto fra l'inchiostro di due righe vicine, con le stesse
        // funzioni che usa il codice per disporle.
        final inchiostro = unitaInchiostro(righe, fit.fontSize);
        final interlinea = inchiostro * kInterlinea;
        // La soglia e' relativa all'inchiostro: su una placca cosi' bassa un
        // minimo in pixel non direbbe nulla, il rapporto si'.
        expect(interlinea / inchiostro, greaterThan(0.10),
            reason: 'le due righe di ${card.name} si toccano');
        // E il testo intero, interlinee comprese, sta nell'area.
        expect(altezzaOccupata(righe, fit.fontSize),
            lessThanOrEqualTo(maxH + 0.5),
            reason: 'il nome di ${card.name} esce in altezza');
        // Riempie su almeno uno dei due assi. Di solito su due righe comanda
        // l'altezza, perche' ogni pezzo e' corto, ma qualche nome molto lungo
        // resta largo anche spezzato e allora comanda la larghezza.
        final pienoInAltezza =
            altezzaOccupata(righe, fit.fontSize) > maxH - 0.5;
        final pienoInLarghezza = righe.any(
            (r) => larghezza(r, base, fit) > maxW - 0.5);
        expect(pienoInAltezza || pienoInLarghezza, isTrue,
            reason: 'il nome di ${card.name} lascia vuoto su tutti e due gli '
                'assi');
      }
    });

    test('Il testo riempie l\'area utile e non esce, su una e due righe', () {
      final base = cartiglioBaseStyle(palette);

      for (final card in TarotDeck.cards) {
        final prove = <List<Object>>[
          [splitNomeCartiglio(card.name), TarotFrame.cartiglioNome],
          if (!card.isCorte) [
              <String>[card.numeral],
              TarotFrame.cartiglioNumero
            ],
        ];
        for (final prova in prove) {
          final righe = prova[0] as List<String>;
          final rect = prova[1] as Rect;
          final maxW = (rect.right - rect.left) * cardW;
          final maxH = (rect.bottom - rect.top) * cardH;
          final fit = resolveCartiglioArea(
              righe: [for (final r in righe) r.toUpperCase()],
              base: base,
              maxWidth: maxW,
              maxHeight: maxH);

          // 1. Non esce in larghezza.
          for (final r in righe) {
            expect(larghezza(r, base, fit), lessThanOrEqualTo(maxW + 0.5),
                reason: '"$r" esce dal cartiglio di ${card.name}');
          }
          // 2. Non esce in altezza: inchiostro piu' interlinee stanno nell'area.
          expect(altezzaOccupata(righe, fit.fontSize),
              lessThanOrEqualTo(maxH + 0.5),
              reason: 'le lettere di ${card.name} escono in altezza');

          // 3. Riempie: la misura e' massimale, il cinque per cento in piu'
          // sfonderebbe uno dei due limiti. E' questo che distingue un testo che
          // riempie il cartiglio da uno che ci galleggia dentro piccolo.
          final cresciuto = CartiglioAreaFit(
              fontSize: fit.fontSize * 1.05,
              letterSpacing: fit.letterSpacing * 1.05);
          final sfondaAltezza =
              altezzaOccupata(righe, cresciuto.fontSize) > maxH;
          final sfondaLarghezza =
              righe.any((r) => larghezza(r, base, cresciuto) > maxW);
          expect(sfondaAltezza || sfondaLarghezza, isTrue,
              reason: 'il testo di ${card.name} sta piccolo, si poteva '
                  'ingrandire ancora');
        }
      }
    });

    test('Le due righe di un nome lungo condividono la stessa misura', () {
      final base = cartiglioBaseStyle(palette);
      final rect = TarotFrame.cartiglioNome;
      final maxW = (rect.right - rect.left) * cardW;
      final maxH = (rect.bottom - rect.top) * cardH;
      final righe = splitNomeCartiglio('Cavaliere di Bastoni');
      expect(righe.length, 2);
      final fit = resolveCartiglioArea(
          righe: [for (final r in righe) r.toUpperCase()],
          base: base,
          maxWidth: maxW,
          maxHeight: maxH);
      expect(fit.fontSize, greaterThan(0));
      for (final r in righe) {
        expect(larghezza(r, base, fit), lessThanOrEqualTo(maxW + 0.5));
      }
    });

    test('I nomi su due righe riempiono l\'altezza della placca', () {
      final base = cartiglioBaseStyle(palette);
      final rect = TarotFrame.cartiglioNome;
      final maxW = (rect.right - rect.left) * cardW;
      final maxH = (rect.bottom - rect.top) * cardH;

      for (final nome in const [
        'Cavaliere di Bastoni',
        'Regina di Denari',
        'Quattro di Denari',
      ]) {
        final righe = splitNomeCartiglio(nome);
        expect(righe.length, 2, reason: '$nome non va su due righe');
        final fit = resolveCartiglioArea(
            righe: [for (final r in righe) r.toUpperCase()],
            base: base,
            maxWidth: maxW,
            maxHeight: maxH);

        // Il blocco delle due righe riempie l'altezza utile: e' l'altezza a
        // comandare, perche' spezzato in due ogni pezzo e' corto e la
        // larghezza avanza.
        final blocco = altezzaOccupata(righe, fit.fontSize);
        expect(blocco, closeTo(maxH, 0.5),
            reason: '$nome non riempie: $blocco su $maxH');

        // E il cinque per cento in piu' sfonderebbe.
        final piuGrande = fit.fontSize * 1.05;
        final sfondaAltezza = altezzaOccupata(righe, piuGrande) > maxH;
        final sfondaLarghezza = righe.any((r) =>
            larghezzaInchiostro(
                testo: r.toUpperCase(),
                base: base,
                fontSize: piuGrande,
                letterSpacing: fit.letterSpacing * 1.05) >
            maxW);
        expect(sfondaAltezza || sfondaLarghezza, isTrue,
            reason: '$nome si poteva ingrandire ancora');
      }
    });

    test('I nomi corti restano su una riga, i lunghi si spezzano sul di', () {
      expect(splitNomeCartiglio('Il Matto'), ['Il Matto']);
      expect(splitNomeCartiglio('La Morte'), ['La Morte']);
      expect(splitNomeCartiglio('Cavaliere di Bastoni'),
          ['Cavaliere', 'di Bastoni']);
      expect(splitNomeCartiglio('Regina di Denari'), ['Regina', 'di Denari']);
      expect(splitNomeCartiglio('Quattro di Denari'), ['Quattro', 'di Denari']);
    });
  });

  group('Orientamento e centratura', () {
    Future<void> pumpCard(WidgetTester tester,
        {required bool reversed, TarotCard? card}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: TarotCardArt(
                card: card ?? TarotDeck.cards.first,
                palette: palette,
                reversed: reversed,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    /// Quante rotazioni di mezzo giro avvolgono il cartiglio del nome.
    int cartigliRuotati(WidgetTester tester) {
      return tester
          .widgetList<Transform>(find.ancestor(
              of: find.byType(CartiglioNome), matching: find.byType(Transform)))
          .where((t) {
        final m = t.transform;
        return (m.storage[0] + 1).abs() < 1e-6 &&
            (m.storage[5] + 1).abs() < 1e-6;
      }).length;
    }

    testWidgets('Sul rovesciato ruota tutta la carta, cartigli inclusi',
        (tester) async {
      await pumpCard(tester, reversed: false);
      expect(find.byType(CartiglioNome), findsOneWidget);
      expect(cartigliRuotati(tester), 0,
          reason: 'la carta dritta ruota qualcosa');

      await pumpCard(tester, reversed: true);
      expect(find.byType(CartiglioNome), findsOneWidget);
      expect(cartigliRuotati(tester), 1,
          reason: 'i cartigli non girano con la carta rovesciata');
    });

    testWidgets(
        'Il numerale e centrato nella placca, in orizzontale e in verticale',
        (tester) async {
      final card = TarotDeck.cards.first;
      await pumpCard(tester, reversed: false, card: card);

      final carta = tester.getRect(find.byType(TarotCardArt));
      final area = Rect.fromLTRB(
        carta.left + TarotFrame.cartiglioNumero.left * carta.width,
        carta.top + TarotFrame.cartiglioNumero.top * carta.height,
        carta.left + TarotFrame.cartiglioNumero.right * carta.width,
        carta.top + TarotFrame.cartiglioNumero.bottom * carta.height,
      );

      final testo = find.descendant(
          of: find.byType(CartiglioNumero),
          matching: find.text(card.numeral.toUpperCase()));
      expect(testo, findsOneWidget);
      final riga = tester.getRect(testo);
      final style = tester.widget<Text>(testo).style!;

      // Orizzontale: il centro della riga sul centro della placca.
      expect((riga.center.dx - area.center.dx).abs(), lessThan(2.0),
          reason: 'il numerale non e centrato in orizzontale');

      // Verticale: conta il centro dell'INCHIOSTRO, non quello della riga di
      // testo, che include ascendenti e discendenti qui mai usati.
      final tp = TextPainter(
        text: TextSpan(text: card.numeral.toUpperCase(), style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final baseline =
          tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final ink = inkExtentOf(card.numeral, style.fontSize!);
      final centroInchiostro = riga.top + baseline + ink.center;
      expect((centroInchiostro - area.center.dy).abs(), lessThan(1.0),
          reason: 'il numerale non e centrato in verticale');
    });

  });

  group('Inchiostro davvero dipinto', () {
    // Questi controlli non si fidano delle formule: disegnano il cartiglio e
    // contano i pixel accesi. Se la misura e la centratura divergessero dalla
    // resa, qui si vedrebbe.

    // Il cartiglio si disegna otto volte piu' grande del vero, cosi' si legge
    // un ottavo di pixel. La tolleranza di tre pixel di prova vale meno di
    // quattro decimi di pixel sulla carta reale: quel che resta e' sfumatura
    // dei bordi e arrotondamento del layout, non disallineamento.
    const scala = 8.0;
    const tolleranza = 3;

    /// Disegna un cartiglio dentro la sua placca, su fondo nero, e ritorna le
    /// righe di pixel accese (quelle con dell'oro).
    Future<
        ({
          int primaRiga,
          int ultimaRiga,
          int altezzaBanda,
          int primaColonna,
          int ultimaColonna,
          int larghezzaBanda
        })> inchiostro(
      WidgetTester tester,
      Widget cartiglio,
      Rect placca,
    ) async {
      // La placca alla scala di prova, col cartiglio nella sua area utile.
      const cardW = 150.0;
      const cardH = cardW / TarotFrame.aspect;
      final area = TarotFrame.areaUtile(placca);
      final pw = placca.width * cardW * scala;
      final ph = placca.height * cardH * scala;
      final ax = (area.left - placca.left) * cardW * scala;
      final ay = (area.top - placca.top) * cardH * scala;
      final aw = area.width * cardW * scala;
      final ah = area.height * cardH * scala;

      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: Container(
                width: pw,
                height: ph,
                color: const Color(0xFF000000),
                child: Stack(children: [
                  Positioned(
                      left: ax,
                      top: ay,
                      width: aw,
                      height: ah,
                      child: cartiglio),
                ]),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      late List<int> righeAccese;
      late List<int> colonneAccese;
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final bytes = data!.buffer.asUint8List();
        final w = image.width;
        // Fondo nero: qualunque cosa sopra soglia e' inchiostro.
        bool acceso(int x, int y) {
          final i = (y * w + x) * 4;
          return bytes[i] > 40 || bytes[i + 1] > 40 || bytes[i + 2] > 40;
        }

        righeAccese = <int>[];
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < w; x++) {
            if (acceso(x, y)) {
              righeAccese.add(y);
              break;
            }
          }
        }
        colonneAccese = <int>[];
        for (var x = 0; x < w; x++) {
          for (var y = 0; y < image.height; y++) {
            if (acceso(x, y)) {
              colonneAccese.add(x);
              break;
            }
          }
        }
      });
      expect(righeAccese, isNotEmpty, reason: 'nessun inchiostro dipinto');
      return (
        primaRiga: righeAccese.first,
        ultimaRiga: righeAccese.last,
        altezzaBanda: (placca.height * cardH * scala).round(),
        primaColonna: colonneAccese.first,
        ultimaColonna: colonneAccese.last,
        larghezzaBanda: (placca.width * cardW * scala).round(),
      );
    }

    testWidgets('Il numerale ha lo stesso spazio sopra e sotto', (tester) async {
      // Campione ampio: tutti i Maggiori, coi romani piu' diversi fra loro, e
      // una manciata di Minori numerati.
      final campione = [
        ...TarotDeck.cards.where((c) => c.arcana == TarotArcana.maggiore),
        ...TarotDeck.cards.where((c) => !c.isCorte).take(6),
      ];
      for (final card in campione) {
        final r = await inchiostro(
          tester,
          CartiglioNumero(card: card, palette: palette),
          TarotFrame.placcaNumero,
        );
        final sopra = r.primaRiga;
        final sotto = r.altezzaBanda - 1 - r.ultimaRiga;
        expect((sopra - sotto).abs(), lessThanOrEqualTo(tolleranza),
            reason: '${card.name}: sopra $sopra, sotto $sotto');
      }
    });

    testWidgets('Anche l\'emblema delle corti e centrato', (tester) async {
      for (final card in TarotDeck.cards.where((c) => c.isCorte)) {
        final r = await inchiostro(
          tester,
          CartiglioNumero(card: card, palette: palette),
          TarotFrame.placcaNumero,
        );
        final sopra = r.primaRiga;
        final sotto = r.altezzaBanda - 1 - r.ultimaRiga;
        expect((sopra - sotto).abs(), lessThanOrEqualTo(tolleranza),
            reason: '${card.name}: sopra $sopra, sotto $sotto');
      }
    });

    testWidgets('Il nome riempie la banda, su una e su due righe',
        (tester) async {
      // Un nome corto (una riga) e uno lungo (due righe).
      for (final nome in ['Il Matto', 'Cavaliere di Bastoni']) {
        final aDueRighe = splitNomeCartiglio(nome).length > 1;
        final card = TarotDeck.cards.firstWhere((c) => c.name == nome);
        final r = await inchiostro(
          tester,
          CartiglioNome(nome: card.name, palette: palette),
          TarotFrame.placcaNome,
        );
        final sopra = r.primaRiga;
        final sotto = r.altezzaBanda - 1 - r.ultimaRiga;
        // Centrato nella banda.
        expect((sopra - sotto).abs(), lessThanOrEqualTo(tolleranza),
            reason: '$nome: sopra $sopra, sotto $sotto');
        // E riempie. La misura e' massimale, quindi il testo arriva al margine
        // su almeno uno dei due assi: in altezza per i nomi che ci stanno larghi,
        // in larghezza per quelli lunghi. Pretendere sempre l'altezza sarebbe
        // sbagliato, perche' un nome corto e largo non puo' crescere oltre il
        // fianco della placca.
        final margineY = TarotFrame.placcaNome.height *
            (cardH * scala) *
            TarotFrame.margineTesto;
        final margineX = margineY;
        final sx = r.primaColonna;
        final pienoInAltezza = sopra <= margineY + tolleranza;
        final pienoInLarghezza = sx <= margineX + tolleranza;
        expect(pienoInAltezza || pienoInLarghezza, isTrue,
            reason: '$nome galleggia: $sopra px vuoti sopra e $sx a sinistra, '
                'col margine a ${margineY.toStringAsFixed(1)}');
        // Su due righe deve essere proprio l'altezza a riempire: ogni riga e'
        // corta, quindi la larghezza non puo' essere il vincolo.
        if (aDueRighe) {
          expect(pienoInAltezza, isTrue,
              reason: '$nome su due righe lascia $sopra px vuoti sopra, '
                  'col margine a ${margineY.toStringAsFixed(1)}');
        }
      }
    });
  });
}
