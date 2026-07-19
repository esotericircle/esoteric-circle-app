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
/// sempre dentro il blu piatto, mai sull'oro, e sempre dritti anche quando la
/// carta e' rovesciata.
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

    testWidgets('I cartigli ci sono, dritti, anche sulla carta rovesciata',
        (tester) async {
      for (final reversed in [false, true]) {
        await pumpCard(tester, reversed: reversed);
        // I due cartigli sono in campo.
        expect(find.byType(CartiglioText), findsNWidgets(2));
        // E nessuno dei due sta dentro una rotazione: restano sempre dritti.
        expect(
          find.descendant(
              of: find.byType(Transform), matching: find.byType(CartiglioText)),
          findsNothing,
          reason: reversed
              ? 'i cartigli ruotano con la carta rovesciata'
              : 'i cartigli sono dentro una rotazione',
        );
      }
    });

    testWidgets('Solo la carta rovesciata ruota l\'artwork', (tester) async {
      await pumpCard(tester, reversed: false);
      final dritta = tester.widgetList(find.byType(Transform)).length;
      await pumpCard(tester, reversed: true);
      final rovesciata = tester.widgetList(find.byType(Transform)).length;
      expect(rovesciata, greaterThan(dritta),
          reason: 'la rovesciata non aggiunge la rotazione dell\'artwork');
    });
  });
}
