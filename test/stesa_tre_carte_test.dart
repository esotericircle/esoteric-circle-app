import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stesa a Tre Carte: pescaggio distinto e riproducibile, versi coerenti col
/// testo del corpus, arte mappata per ogni carta, card condivisibile solida.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadFonts() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  group('Pescaggio', () {
    test('La stesa pesca tre carte distinte', () {
      for (var seed = 0; seed < 200; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        expect(spread.cards.length, 3);
        final stems = spread.cards.map((c) => c.card.stem).toSet();
        expect(stems.length, 3, reason: 'carta ripetuta col seme $seed');
        // Le tre posizioni sono quelle giuste, nell'ordine di lettura.
        expect(spread.cards.map((c) => c.position).toList(),
            SpreadPosition.values);
      }
    });

    test('Con seme fisso la stesa e\' sempre la stessa', () {
      final a = TarotSpread.draw(seed: 12345);
      final b = TarotSpread.draw(seed: 12345);
      for (var i = 0; i < a.cards.length; i++) {
        expect(a.cards[i].card.stem, b.cards[i].card.stem);
        expect(a.cards[i].reversed, b.cards[i].reversed);
      }
      expect(a.reading, b.reading);
      expect(a.synthesis, b.synthesis);
    });

    test('Il rovesciato esce, ma resta la minoranza', () {
      var reversed = 0;
      var total = 0;
      for (var seed = 0; seed < 400; seed++) {
        for (final drawn in TarotSpread.draw(seed: seed).cards) {
          total++;
          if (drawn.reversed) reversed++;
        }
      }
      final quota = reversed / total;
      // Intorno a 0,30, con margine largo perche' e' pur sempre un caso.
      expect(quota, greaterThan(0.20));
      expect(quota, lessThan(0.42));
    });
  });

  group('Versi coerenti col corpus', () {
    test('Il testo mostrato segue sempre il verso della carta', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final drawn in TarotSpread.draw(seed: seed).cards) {
          if (drawn.reversed) {
            expect(drawn.meaning, drawn.card.reversed);
            expect(drawn.summary, drawn.card.reversedSummary);
            expect(drawn.displayName, '${drawn.card.name} rovesciato');
          } else {
            expect(drawn.meaning, drawn.card.upright);
            expect(drawn.summary, drawn.card.uprightSummary);
            expect(drawn.displayName, drawn.card.name);
            expect(drawn.displayName, isNot(contains('rovesciato')));
          }
        }
      }
    });

    test('La sintesi viene dalla carta del Presente', () {
      for (var seed = 0; seed < 50; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        expect(spread.synthesis, spread.presente.summary);
        expect(spread.presente.position, SpreadPosition.presente);
      }
    });

    test('La lettura concatena le tre posizioni', () {
      final spread = TarotSpread.draw(seed: 7);
      for (final drawn in spread.cards) {
        expect(spread.reading, contains(drawn.displayName));
        expect(spread.reading, contains(drawn.meaning));
      }
    });
  });

  group('Mazzo e arte', () {
    test('Settantotto carte, stem unici', () {
      expect(TarotDeck.cards.length, 78);
      expect(TarotDeck.cards.map((c) => c.stem).toSet().length, 78);
    });

    test('Ogni carta ha la sua arte mappata, piena e miniatura', () {
      for (final card in TarotDeck.cards) {
        expect(File(card.fullPath).existsSync(), isTrue,
            reason: 'arte mancante per ${card.name}: ${card.fullPath}');
        expect(File(card.thumbPath).existsSync(), isTrue,
            reason: 'miniatura mancante per ${card.name}');
      }
      // E il dorso di Medora per le carte coperte.
      expect(File(TarotDeck.dorsoFull).existsSync(), isTrue);
    });

    test('Ogni carta porta entrambi i versi, non vuoti', () {
      for (final card in TarotDeck.cards) {
        expect(card.name.trim(), isNotEmpty);
        expect(card.uprightSummary.trim(), isNotEmpty);
        expect(card.upright.trim(), isNotEmpty);
        expect(card.reversedSummary.trim(), isNotEmpty);
        expect(card.reversed.trim(), isNotEmpty);
      }
      // I Minori hanno seme e numero, i Maggiori no.
      for (final card in TarotDeck.cards) {
        if (card.arcana == TarotArcana.minore) {
          expect(card.seme, isNotNull, reason: '${card.name} senza seme');
          expect(card.number, isNotNull);
        } else {
          expect(card.seme, isNull);
        }
      }
    });
  });

  group('Accenti veri, mai apostrofo al posto dell\'accento', () {
    final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
    final letter = RegExp('[a-zA-Zàèéìòù]');

    String? offending(String s) {
      for (final m in vowelApostrophe.allMatches(s)) {
        final apo = m.end - 1;
        if (apo + 1 < s.length && letter.hasMatch(s[apo + 1])) continue;
        final vowel = m.start;
        final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
        final pair = '$prev${s[vowel].toLowerCase()}';
        const troncamenti = {'po', 'mo', 'be', 'di', 'fa', 'da', 'va'};
        if (troncamenti.contains(pair)) continue;
        final start = (vowel - 10).clamp(0, s.length);
        return s.substring(start, (apo + 2).clamp(0, s.length));
      }
      return null;
    }

    test('Nessun apostrofo-accento nel mazzo e nei testi della stesa', () {
      for (final card in TarotDeck.cards) {
        for (final s in [
          card.name,
          card.uprightSummary,
          card.upright,
          card.reversedSummary,
          card.reversed,
        ]) {
          expect(offending(s), isNull, reason: 'in "$s"');
        }
      }
      expect(offending(TarotSpread.closing), isNull);
      expect(offending(TarotSpread.disclaimer), isNull);
      for (var seed = 0; seed < 30; seed++) {
        expect(offending(TarotSpread.draw(seed: seed).reading), isNull);
      }
    });

    test('Nessuna virgola seguita da e nei testi della stesa', () {
      final vietato = RegExp(r',\s+ed?\b');
      expect(vietato.hasMatch(TarotSpread.closing), isFalse);
      expect(vietato.hasMatch(TarotSpread.disclaimer), isFalse);
    });
  });

  group('Card di condivisione', () {
    testWidgets('Si costruisce senza overflow su un campione ampio di stese',
        (tester) async {
      await loadFonts();
      for (var seed = 0; seed < 24; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: StesaShareCard(spread: spread, palette: palette),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'overflow nella card col seme $seed');

        // I tre arcani col loro verso e la loro posizione ci sono. Il nome sta
        // su una riga sua e il verso sotto, cosi' nessuna parola si spezza.
        for (final drawn in spread.cards) {
          expect(find.text(drawn.displayName), findsOneWidget);
          expect(find.text(drawn.position.label.toUpperCase()), findsWidgets);
        }
        expect(find.text(spread.synthesis), findsOneWidget);
      }
    });
  });
}
