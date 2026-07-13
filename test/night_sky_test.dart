import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il motore del cielo del momento usa astronomia vera per cio' che non dipende
/// dal luogo: la longitudine del Sole dalla data e, di conseguenza, quali
/// costellazioni gli stanno all'opposizione, cioe' alte a mezzanotte.
void main() {
  // Il Sole in mezzo a ciascuna stagione sta nel segno atteso (date scelte
  // lontane dai confini per non dipendere dal grado esatto).
  test('Il segno del Sole segue le stagioni', () {
    expect(NightSky.sunSign(DateTime.utc(2026, 4, 5)), Zodiac.aries);
    expect(NightSky.sunSign(DateTime.utc(2026, 7, 10)), Zodiac.cancer);
    expect(NightSky.sunSign(DateTime.utc(2026, 10, 10)), Zodiac.libra);
    expect(NightSky.sunSign(DateTime.utc(2026, 1, 10)), Zodiac.capricorn);
  });

  test('Le costellazioni alte stanotte stanno di fronte al Sole', () {
    for (final d in [
      DateTime.utc(2026, 4, 5),
      DateTime.utc(2026, 7, 10),
      DateTime.utc(2026, 10, 10),
      DateTime.utc(2026, 1, 10),
    ]) {
      final sun = NightSky.sunSign(d);
      final high = NightSky.constellationsHighTonight(d);
      expect(high.length, 3);
      // Il primo, il piu' alto, e' il segno opposto al Sole (a sei segni).
      final oppIndex = (sun.index + 6) % 12;
      expect(high.first, Zodiac.values[oppIndex],
          reason: 'Sole in ${sun.italianName}, atteso opposto '
              '${Zodiac.values[oppIndex].italianName}');
      // Senza duplicati.
      expect(high.toSet().length, high.length);
    }
  });

  test('La longitudine del Sole resta in [0, 360)', () {
    for (var m = 1; m <= 12; m++) {
      final lon = NightSky.sunEclipticLongitude(DateTime.utc(2026, m, 15));
      expect(lon, inInclusiveRange(0.0, 360.0));
      expect(lon, lessThan(360.0));
    }
  });

  // Nessun accento scritto con l'apostrofo nelle righe del cielo.
  test('Le righe del cielo usano accenti corretti', () {
    final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
    final letter = RegExp('[a-zA-Zàèéìòù]');
    String? offending(String s) {
      for (final m in vowelApostrophe.allMatches(s)) {
        final ap = m.end - 1;
        if (ap + 1 < s.length && letter.hasMatch(s[ap + 1])) continue; // elisione
        final vowel = m.start;
        final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
        final pair = '$prev${s[vowel].toLowerCase()}';
        if (pair == 'po' || pair == 'mo' || pair == 'be') continue;
        return s;
      }
      return null;
    }

    for (final z in Zodiac.values) {
      expect(offending(NightSky.describe(z)), isNull,
          reason: 'accento con apostrofo in ${z.id}: ${NightSky.describe(z)}');
    }
    for (final d in [
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 6, 15),
      DateTime.utc(2026, 12, 20),
    ]) {
      final line = NightSky.describeMoon(MoonPhase.forDate(d));
      expect(offending(line), isNull, reason: 'accento con apostrofo: $line');
    }
  });
}
