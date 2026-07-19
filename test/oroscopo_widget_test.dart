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

  group('Zodiaco brandizzato, due asset distinti per segno', () {
    test('Emblema e simbolo sono due percorsi diversi per ogni segno', () {
      for (final z in Zodiac.values) {
        final emblem = ZodiacArt.emblemPath(z);
        final symbol = ZodiacArt.symbolPath(z);
        expect(emblem, startsWith('assets/img/zodiac/'));
        expect(symbol, startsWith('assets/img_thumb/zodiac/'));
        expect(emblem, isNot(equals(symbol)),
            reason: 'emblema e simbolo coincidono per ${z.id}');
      }
    });

    test('Tutti i ventiquattro asset esistono nel bundle', () {
      for (final z in Zodiac.values) {
        expect(File(ZodiacArt.emblemPath(z)).existsSync(), isTrue,
            reason: 'emblema mancante: ${ZodiacArt.emblemPath(z)}');
        expect(File(ZodiacArt.symbolPath(z)).existsSync(), isTrue,
            reason: 'simbolo mancante: ${ZodiacArt.symbolPath(z)}');
      }
    });

    testWidgets('La testa carica l\'emblema, il chip carica il simbolo',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ZodiacEmblem(
                  sign: Zodiac.leo, size: 60, art: ZodiacEmblemArt.emblem),
              ZodiacEmblem(
                  sign: Zodiac.leo, size: 30, art: ZodiacEmblemArt.symbol),
            ],
          ),
        ),
      ));
      await tester.pump();
      final names = tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => (i.image as AssetImage).assetName)
          .toList();
      // Due immagini distinte, la miniatura non e' l'emblema scalato.
      expect(names, contains(ZodiacArt.emblemPath(Zodiac.leo)));
      expect(names, contains(ZodiacArt.symbolPath(Zodiac.leo)));
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
