import 'package:esoteric_circle/core/astro/maestro_assignment.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Segno solare dalla data', () {
    test('date note cadono nel segno giusto', () {
      expect(Zodiac.fromDate(DateTime(1990, 3, 25)), Zodiac.aries);
      expect(Zodiac.fromDate(DateTime(1990, 4, 20)), Zodiac.taurus);
      expect(Zodiac.fromDate(DateTime(1990, 6, 15)), Zodiac.gemini);
      expect(Zodiac.fromDate(DateTime(1990, 8, 10)), Zodiac.leo);
      expect(Zodiac.fromDate(DateTime(1990, 11, 25)), Zodiac.sagittarius);
    });

    test('il Capricorno attraversa l\'anno', () {
      expect(Zodiac.fromDate(DateTime(1990, 12, 25)), Zodiac.capricorn);
      expect(Zodiac.fromDate(DateTime(1991, 1, 10)), Zodiac.capricorn);
    });

    test('i confini dei segni', () {
      expect(Zodiac.fromDate(DateTime(1990, 4, 19)), Zodiac.aries);
      expect(Zodiac.fromDate(DateTime(1990, 3, 21)), Zodiac.aries);
    });
  });

  group('Assegnazione provvisoria del Maestro', () {
    test('per elemento', () {
      expect(assignMaestro(Zodiac.leo), Maestro.caligo); // fuoco
      expect(assignMaestro(Zodiac.gemini), Maestro.medora); // aria
      expect(assignMaestro(Zodiac.cancer), Maestro.aura); // acqua
      expect(assignMaestro(Zodiac.taurus), Maestro.aura); // terra
    });

    test('ogni segno ha un Maestro', () {
      for (final z in Zodiac.values) {
        expect(Maestro.values.contains(assignMaestro(z)), isTrue);
      }
    });
  });
}
