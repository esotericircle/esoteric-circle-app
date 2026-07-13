import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:flutter_test/flutter_test.dart';

/// La cartolina del cielo e' costruita apposta (non uno screenshot) ed esportata
/// in PNG ad alta risoluzione.
void main() {
  testWidgets('La cartolina si genera nei due formati, verticale e quadrato',
      (tester) async {
    await tester.runAsync(() async {
      final now = DateTime(2026, 7, 13, 22);
      final moon = MoonPhase.forDate(now);
      final high = NightSky.constellationsHighTonight(now);

      Future<(int, int, int)> renderInfo(PostcardFormat format) async {
        final bytes = await SkyPostcard.render(
          now: now,
          moon: moon,
          high: high,
          palette: MaestroPalette.medora,
          format: format,
        );
        expect(bytes.length, greaterThan(2000));
        expect(bytes.sublist(0, 8),
            [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return (bytes.length, frame.image.width, frame.image.height);
      }

      final story = await renderInfo(PostcardFormat.story);
      final feed = await renderInfo(PostcardFormat.feed);
      // Verticale 1080x1920, quadrato 1080x1080.
      expect((story.$2, story.$3), (1080, 1920));
      expect((feed.$2, feed.$3), (1080, 1080));
    });
  });

  test('Data, riga poetica e testo di condivisione', () {
    expect(SkyPostcard.formatDate(DateTime(2026, 7, 13)), '13 luglio 2026');
    expect(SkyPostcard.poeticLine(DateTime(2026, 7, 13)), isNotEmpty);
    final text = SkyPostcard.shareText(DateTime(2026, 7, 13));
    expect(text, contains('#EsotericCircle'));
    expect(text, contains('Esoteric Circle'));
  });

  // Le righe poetiche non hanno accenti scritti con l'apostrofo.
  test('Le righe poetiche usano accenti corretti', () {
    final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
    final letter = RegExp('[a-zA-Zàèéìòù]');
    for (var doy = 0; doy < 366; doy++) {
      final line = SkyPostcard.poeticLine(DateTime(2026).add(Duration(days: doy)));
      for (final m in vowelApostrophe.allMatches(line)) {
        final ap = m.end - 1;
        final elision = ap + 1 < line.length && letter.hasMatch(line[ap + 1]);
        expect(elision, isTrue, reason: 'accento con apostrofo in: $line');
      }
      // Mai una proposizione dopo la virgola che inizia con "e".
      expect(line.contains(RegExp(r', e\b')), isFalse,
          reason: 'proposizione dopo virgola con "e" in: $line');
    }
  });
}
