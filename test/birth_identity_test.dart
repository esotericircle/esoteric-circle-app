import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Numero della vita', () {
    test('riduzione deterministica a cifra singola', () {
      expect(lifePathNumber(DateTime(1990, 6, 1)), 8);
      expect(lifePathNumber(DateTime(2000, 1, 1)), 4);
    });

    test('conserva i numeri maestri', () {
      // 29 -> 11 (giorno), 9 (mese), 9 (anno 1980) => 29 -> 11.
      expect(lifePathNumber(DateTime(1980, 9, 29)), 11);
    });

    test('titolo e significato coerenti col numero', () {
      expect(lifeTitleOf(8), contains('Realizzatore'));
      expect(lifeMeaningOf(11), contains('maestro'));
    });
  });

  group('Fase lunare', () {
    MoonIllumination m(double f, bool wax) =>
        MoonIllumination(fraction: f, waxing: wax);

    test('i nomi delle fasi sono corretti', () {
      expect(phaseNameOf(m(0.0, true)), 'Luna nuova');
      expect(phaseNameOf(m(1.0, false)), 'Luna piena');
      expect(phaseNameOf(m(0.5, true)), 'Primo quarto');
      expect(phaseNameOf(m(0.5, false)), 'Ultimo quarto');
      expect(phaseNameOf(m(0.3, true)), 'Luna crescente');
      expect(phaseNameOf(m(0.8, true)), 'Gibbosa crescente');
      expect(phaseNameOf(m(0.8, false)), 'Gibbosa calante');
      expect(phaseNameOf(m(0.3, false)), 'Luna calante');
    });
  });
}
