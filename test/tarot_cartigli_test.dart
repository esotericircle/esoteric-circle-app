import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:esoteric_circle/features/tarot/tarot_cartiglio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// I cartigli delle carte, riempiti a runtime: numerale (o emblema del seme) in
/// alto e nome in basso, sempre dentro il blu piatto, mai sull'oro, alla massima
/// misura che ci sta. Quando la carta e' rovesciata gira tutta la carta,
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

  /// La larghezza del testo alla misura scelta.
  double larghezza(String testo, TextStyle base, CartiglioAreaFit fit) {
    final tp = TextPainter(
      text: TextSpan(
        text: testo.toUpperCase(),
        style: base.copyWith(
            fontSize: fit.fontSize, letterSpacing: fit.letterSpacing),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

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

    test('I Minori usano l\'arabo, le corti la figura', () {
      const corti = {11: 'Fante', 12: 'Cavaliere', 13: 'Regina', 14: 'Re'};
      for (final card in TarotDeck.cards) {
        if (card.arcana != TarotArcana.minore) continue;
        final n = card.number!;
        if (corti.containsKey(n)) {
          expect(card.numeral, corti[n]);
        } else {
          expect(card.numeral, '$n');
          expect(int.tryParse(card.numeral), inInclusiveRange(1, 10));
        }
      }
    });
  });

  group('Carte di corte', () {
    test('Le sedici carte di corte sono riconosciute, e solo quelle', () {
      final corti = TarotDeck.cards.where((c) => c.isCorte).toList();
      expect(corti.length, 16, reason: 'quattro figure per quattro semi');
      for (final c in corti) {
        expect(c.number, inInclusiveRange(11, 14));
        expect(CartiglioNumero.emblemFor(c), isNotNull,
            reason: '${c.name} senza emblema del seme');
      }
      for (final c in TarotDeck.cards.where((c) => !c.isCorte)) {
        expect(CartiglioNumero.emblemFor(c), isNull,
            reason: '${c.name} non e\' una carta di corte');
      }
    });

    test('L\'emblema segue il seme della carta', () {
      const atteso = {
        TarotSeme.bastoni: SuitEmblem.bastoni,
        TarotSeme.coppe: SuitEmblem.coppe,
        TarotSeme.denari: SuitEmblem.denari,
        TarotSeme.spade: SuitEmblem.spade,
      };
      for (final c in TarotDeck.cards.where((c) => c.isCorte)) {
        expect(CartiglioNumero.emblemFor(c), atteso[c.seme!]);
      }
    });

    testWidgets('Nel cartiglio alto c\'e\' l\'emblema, non la parola',
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
      expect(find.byType(SuitEmblemMark), findsOneWidget);
      // La parola CAVALIERE compare solo nel cartiglio basso, come grado, e non
      // nella placca stretta in alto dove risulterebbe illeggibile.
      expect(find.text('CAVALIERE'), findsOneWidget);
      final rettCarta = tester.getRect(find.byType(TarotCardArt));
      final rettParola = tester.getRect(find.text('CAVALIERE'));
      expect(rettParola.center.dy, greaterThan(rettCarta.center.dy),
          reason: 'la parola sta in alto invece che nel cartiglio del nome');
    });
  });

  group('Cartigli dentro il blu, mai sull\'oro', () {
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
        final cap = fit.fontSize * kCapRatio;
        // Ogni riga sta nella sua banda: il vuoto fra le lettere di due righe
        // vicine e' la banda meno la lettera.
        final banda = maxH / righe.length;
        final interlinea = banda - cap;
        // La soglia e' relativa alla lettera: su una placca cosi' bassa un
        // minimo in pixel non direbbe nulla, il rapporto si'.
        expect(interlinea / cap, greaterThan(0.10),
            reason: 'le due righe di ${card.name} si toccano');
        // E il testo intero, interlinee comprese, sta nell'area.
        expect(altezzaOccupata(fit.fontSize, righe.length),
            lessThanOrEqualTo(maxH + 0.5),
            reason: 'il nome di ${card.name} esce in altezza');
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
          // 2. Non esce in altezza: lettere piu' interlinee stanno nell'area.
          expect(altezzaOccupata(fit.fontSize, righe.length),
              lessThanOrEqualTo(maxH + 0.5),
              reason: 'le lettere di ${card.name} escono in altezza');

          // 3. Riempie: la misura e' massimale, il dieci per cento in piu'
          // sfonderebbe uno dei due limiti. E' questo che distingue un testo che
          // riempie il cartiglio da uno che ci galleggia dentro piccolo.
          final cresciuto = CartiglioAreaFit(
              fontSize: fit.fontSize * 1.10,
              letterSpacing: fit.letterSpacing * 1.10);
          final sfondaAltezza =
              altezzaOccupata(cresciuto.fontSize, righe.length) > maxH;
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

      // Verticale: conta il centro della LETTERA, non quello della riga di
      // testo, che include ascendenti e discendenti qui mai usati.
      final tp = TextPainter(
        text: TextSpan(text: card.numeral.toUpperCase(), style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final baseline =
          tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final cap = style.fontSize! * kCapRatio;
      final centroLettera = riga.top + baseline - cap / 2;
      expect((centroLettera - area.center.dy).abs(), lessThan(2.0),
          reason: 'il numerale non e centrato in verticale');
    });

    testWidgets('L\'emblema di corte e centrato nella placca', (tester) async {
      final regina =
          TarotDeck.cards.firstWhere((c) => c.name == 'Regina di Denari');
      await pumpCard(tester, reversed: false, card: regina);
      final carta = tester.getRect(find.byType(TarotCardArt));
      final area = Rect.fromLTRB(
        carta.left + TarotFrame.cartiglioNumero.left * carta.width,
        carta.top + TarotFrame.cartiglioNumero.top * carta.height,
        carta.left + TarotFrame.cartiglioNumero.right * carta.width,
        carta.top + TarotFrame.cartiglioNumero.bottom * carta.height,
      );
      final emblema = tester.getRect(find.descendant(
          of: find.byType(SuitEmblemMark), matching: find.byType(CustomPaint)));
      expect((emblema.center.dx - area.center.dx).abs(), lessThan(2.0));
      expect((emblema.center.dy - area.center.dy).abs(), lessThan(2.0));
    });
  });
}
