import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/natal_poetics.dart';
import 'package:esoteric_circle/core/astro/resonance.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

PlanetPosition _p(String id, Zodiac sign) =>
    PlanetPosition(id: id, name: id, glyph: '?', longitude: 0, sign: sign);

void main() {
  group('Risonanza', () {
    test('un cielo d\'aria risuona con Medora', () {
      final chart = NatalChart(
        sunSign: Zodiac.gemini,
        hasTime: true,
        ascendant: Zodiac.libra,
        planets: [
          _p('sun', Zodiac.gemini),
          _p('moon', Zodiac.aquarius),
          _p('mercury', Zodiac.libra),
        ],
      );
      final r = computeResonance(chart);
      expect(r.winner, Maestro.medora);
      // I punteggi normalizzati sommano a 1.
      final total = r.scores.values.fold<double>(0, (a, b) => a + b);
      expect(total, closeTo(1.0, 1e-9));
      expect(r.reason, contains('Medora'));
    });

    test('un cielo d\'acqua risuona con Aura', () {
      final chart = NatalChart(
        sunSign: Zodiac.cancer,
        hasTime: false,
        planets: [
          _p('sun', Zodiac.cancer),
          _p('moon', Zodiac.pisces),
          _p('venus', Zodiac.scorpio),
        ],
      );
      expect(computeResonance(chart).winner, Maestro.aura);
    });

    test('Sole Gemelli e Ascendente Bilancia risuonano con Medora, non Aura',
        () {
      // Il caso che prima era incoerente: cielo a maggioranza d'aria con Luna
      // in acqua. La firma di luminari e angoli deve vincere.
      final chart = NatalChart(
        sunSign: Zodiac.gemini,
        hasTime: true,
        ascendant: Zodiac.libra,
        planets: [
          _p('sun', Zodiac.gemini),
          _p('moon', Zodiac.pisces),
          _p('mercury', Zodiac.gemini),
          _p('venus', Zodiac.cancer),
        ],
      );
      final r = computeResonance(chart);
      expect(r.winner, Maestro.medora);
      // Il perche' cita davvero il fattore che ha deciso.
      expect(r.reason, contains(r.deciding.replaceFirst(RegExp('^.'), '')));
      final total = r.scores.values.fold<double>(0, (a, b) => a + b);
      expect(total, closeTo(1.0, 1e-9));
    });
  });

  group('Identita\' e forma di cortesia', () {
    test('il saluto cambia con la forma', () {
      final id = IdentityController()..setName('Mauro');
      id.setForm(AddressForm.feminine);
      expect(id.welcome(), contains('Benvenuta'));
      id.setForm(AddressForm.masculine);
      expect(id.welcome(), contains('Benvenuto'));
      id.setForm(AddressForm.neutral);
      expect(id.welcome(), contains('benvenuto'));
      expect(id.welcome(), contains('Mauro'));
    });
  });

  group('Dignita\' dei pianeti', () {
    test('domicilio, caduta e neutro', () {
      expect(NatalPoetics.dignityOf('sun', Zodiac.leo), Dignity.strong);
      expect(NatalPoetics.dignityOf('sun', Zodiac.libra), Dignity.weak);
      expect(NatalPoetics.dignityOf('sun', Zodiac.gemini), Dignity.neutral);
    });
  });
}
