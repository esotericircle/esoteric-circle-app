import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/horoscope_visuals.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oroscopo, i tre interventi lato widget: emblema brandizzato mai di sistema,
/// forme a tema legate al valore, card condivisibile senza overflow.
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

  bool hasGlyphPainter(WidgetTester tester) => tester
      .widgetList(find.byType(CustomPaint))
      .any((w) => (w as CustomPaint).painter is ZodiacGlyphPainter);

  group('Emblema zodiacale, mai il glifo di sistema', () {
    testWidgets('Con asset assente si usa il ripiego dipinto', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: ZodiacEmblem(
                sign: Zodiac.leo,
                size: 80,
                color: palette.goldSoft,
                assetPath: 'assets/img/zodiac/zod_inesistente.webp'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Nessun Text con glifo di sistema, ma il glifo dipinto a vettori.
      expect(hasGlyphPainter(tester), isTrue);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Con asset presente si usa l\'immagine', (tester) async {
      // Un asset realmente bundlato (un ritratto VIP) prova il ramo immagine.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: ZodiacEmblem(
                sign: Zodiac.leo,
                size: 80,
                color: palette.goldSoft,
                assetPath:
                    'assets/img/ritratti-vip/vip_angelina-jolie_v1.webp'),
          ),
        ),
      ));
      await tester.pump();
      // L'immagine e' in campo, il ripiego dipinto no.
      expect(find.byType(Image), findsOneWidget);
      expect(hasGlyphPainter(tester), isFalse);
    });
  });

  group('Card di condivisione', () {
    testWidgets('Si costruisce senza overflow per tutti i dodici segni',
        (tester) async {
      await loadFonts();
      for (final sign in Zodiac.values) {
        final cards =
            Horoscope.forSign(sign: sign, dayOfYear: 200, year: 2026);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: OroscopoShareCard(
                    sign: sign, cards: cards, palette: palette),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'overflow nella card di ${sign.italianName}');

        // I visivi a tema restano legati al valore deterministico 2..5.
        final visuals = tester
            .widgetList<DomainVisual>(find.byType(DomainVisual))
            .toList();
        expect(visuals.length, 4);
        for (final v in visuals) {
          final expected = cards
              .firstWhere((c) => c.domain == v.domain)
              .indicator;
          expect(v.value, expected);
          expect(v.value, inInclusiveRange(2, 5));
        }
      }
    });
  });
}
