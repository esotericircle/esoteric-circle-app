import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// I cartigli delle carte, riempiti a runtime: numerale in alto e nome in basso,
/// sempre dentro il blu piatto, mai sull'oro. Quando la carta e' rovesciata gira
/// tutta la carta, cartigli inclusi, come una carta vera girata in mano.
/// Quante rotazioni di mezzo giro avvolgono il cartiglio del nome.
int _cartigliRuotati(WidgetTester tester) {
  return tester
      .widgetList<Transform>(find.ancestor(
          of: find.byType(CartiglioNome), matching: find.byType(Transform)))
      .where((t) {
        // Mezzo giro: il seno e' nullo e il coseno vale meno uno.
        final m = t.transform;
        return (m.storage[0] + 1).abs() < 1e-6 &&
            (m.storage[5] + 1).abs() < 1e-6;
      })
      .length;
}

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
      // I ventidue romani sono tutti diversi fra loro.
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

  group('Cartigli dentro il blu, mai sull\'oro', () {
    test('I riquadri di testo stanno dentro le placche misurate', () {
      for (final coppia in [
        [TarotFrame.cartiglioNumero, TarotFrame.placcaNumero],
        [TarotFrame.cartiglioNome, TarotFrame.placcaNome],
      ]) {
        final testo = coppia[0];
        final placca = coppia[1];
        expect(testo.left, greaterThanOrEqualTo(placca.left));
        expect(testo.right, lessThanOrEqualTo(placca.right));
        expect(testo.top, greaterThanOrEqualTo(placca.top));
        expect(testo.bottom, lessThanOrEqualTo(placca.bottom));
        // E c'e' davvero un margine, non e' a filo dell'oro.
        expect(testo.left - placca.left, greaterThan(0));
        expect(placca.right - testo.right, greaterThan(0));
      }
    });

    test('Nome e numerale entrano nel cartiglio per tutte e 78 le carte', () {
      // Misura di riferimento della carta a schermo, dal lato conservativo.
      const cardW = 150.0;
      const cardH = cardW / TarotFrame.aspect;
      final base = TypographyTokens.display(size: 40)
          .copyWith(letterSpacing: 1.0, color: const Color(0xFFFFFFFF));

      double larghezza(String testo, CartiglioFit fit) {
        final tp = TextPainter(
          text: TextSpan(
            text: testo.toUpperCase(),
            style: base.copyWith(
                fontSize: fit.fontSize,
                letterSpacing: fit.letterSpacing,
                wordSpacing: fit.wordSpacing),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        return tp.width * fit.scaleX;
      }

      for (final card in TarotDeck.cards) {
        for (final prova in [
          [card.numeral, TarotFrame.cartiglioNumero, false],
          [card.name, TarotFrame.cartiglioNome, true],
        ]) {
          final testo = prova[0] as String;
          final rect = prova[1] as Rect;
          final gap = prova[2] as bool;
          final maxW = (rect.right - rect.left) * cardW;
          final maxH = (rect.bottom - rect.top) * cardH;
          final fit = resolveCartiglioFit(
              text: testo.toUpperCase(),
              base: base,
              maxWidth: maxW,
              maxHeight: maxH,
              preserveWordGap: gap);
          expect(larghezza(testo, fit), lessThanOrEqualTo(maxW + 0.5),
              reason: '"$testo" non entra nel cartiglio di ${card.name}');
          expect(fit.scaleX, greaterThanOrEqualTo(0.80 - 1e-6));
        }
      }
    });
  });

  group('Orientamento', () {
    Future<void> pumpCard(WidgetTester tester,
        {required bool reversed}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: TarotCardArt(
                card: TarotDeck.cards.first,
                palette: palette,
                reversed: reversed,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('Sul rovesciato ruota tutta la carta, cartigli inclusi',
        (tester) async {
      // Dritta: nessun cartiglio dentro una rotazione di mezzo giro.
      await pumpCard(tester, reversed: false);
      expect(find.byType(CartiglioNome), findsOneWidget);
      expect(_cartigliRuotati(tester), 0,
          reason: 'la carta dritta ruota qualcosa');

      // Rovesciata: entrambi i cartigli girano con la carta.
      await pumpCard(tester, reversed: true);
      expect(find.byType(CartiglioNome), findsOneWidget);
      expect(_cartigliRuotati(tester), 1,
          reason: 'i cartigli non girano con la carta rovesciata');
    });

    testWidgets('Il numerale sta centrato nel cartiglio alto', (tester) async {
      await pumpCard(tester, reversed: false);
      final carta = tester.getRect(find.byType(TarotCardArt));
      // Il centro della banda misurata, in pixel.
      final centroBanda = carta.left +
          carta.width *
              (TarotFrame.cartiglioNumero.left +
                      TarotFrame.cartiglioNumero.right) /
                  2;
      final numerale = tester.getRect(find.descendant(
          of: find.byType(TarotCardArt),
          matching: find.text(TarotDeck.cards.first.numeral.toUpperCase())));
      expect((numerale.center.dx - centroBanda).abs(), lessThan(1.5),
          reason: 'il numerale non risulta centrato nella placca');
    });
  });

  group('Nome su due righe', () {
    test('I nomi corti restano su una riga', () {
      expect(splitNomeCartiglio('Il Matto'), ['Il Matto']);
      expect(splitNomeCartiglio('La Morte'), ['La Morte']);
    });

    test('I nomi lunghi si spezzano sul di', () {
      expect(splitNomeCartiglio('Cavaliere di Bastoni'),
          ['Cavaliere', 'di Bastoni']);
      expect(splitNomeCartiglio('Regina di Denari'), ['Regina', 'di Denari']);
      expect(splitNomeCartiglio('Quattro di Denari'), ['Quattro', 'di Denari']);
    });

    test('Nessuna riga resta compressa oltre il lecito', () {
      const cardW = 150.0;
      const cardH = cardW / TarotFrame.aspect;
      final base = TypographyTokens.display(size: 40)
          .copyWith(letterSpacing: 1.0, color: const Color(0xFFFFFFFF));
      const rect = TarotFrame.cartiglioNome;
      final maxW = (rect.right - rect.left) * cardW;
      // Su due righe ogni riga ha meta' altezza.
      for (final card in TarotDeck.cards) {
        final righe = splitNomeCartiglio(card.name);
        final maxH = (rect.bottom - rect.top) * cardH / righe.length;
        for (final riga in righe) {
          final fit = resolveCartiglioFit(
              text: riga.toUpperCase(),
              base: base,
              maxWidth: maxW,
              maxHeight: maxH,
              preserveWordGap: true);
          final tp = TextPainter(
            text: TextSpan(
                text: riga.toUpperCase(),
                style: base.copyWith(
                    fontSize: fit.fontSize,
                    letterSpacing: fit.letterSpacing,
                    wordSpacing: fit.wordSpacing)),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          // Dentro la placca, e mai schiacciato sotto lo 0.80.
          expect(tp.width * fit.scaleX, lessThanOrEqualTo(maxW + 0.5),
              reason: '"$riga" esce dal cartiglio di ${card.name}');
          expect(fit.scaleX, greaterThanOrEqualTo(0.80 - 1e-6),
              reason: '"$riga" risulta compresso troppo');
        }
      }
    });

    testWidgets('I nomi lunghi vanno a capo davvero', (tester) async {
      // Quattro di Denari: nome lungo, e il numerale resta una cifra, cosi'
      // le due righe del nome non si confondono col cartiglio alto.
      final carta = TarotDeck.cards
          .firstWhere((c) => c.name == 'Quattro di Denari');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: TarotCardArt(card: carta, palette: palette),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('QUATTRO'), findsOneWidget);
      expect(find.text('DI DENARI'), findsOneWidget);
    });
  });
}
