import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/identity/numerology.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fatti identitari deterministici dalla sola data di nascita: Numero della
/// vita (numerologia) e Fase lunare di nascita (fase e segno lunare).
void main() {
  group('Numero della vita', () {
    test('riduce la data in modo deterministico', () {
      // 15/06/1990: giorno 15 -> 6, mese 6 -> 6, anno 1990 -> 1; 6+6+1 = 13 -> 4.
      expect(LifePath.forDate(DateTime(1990, 6, 15)).number, 4);
      // Stessa data, stesso numero: nessuna casualita'.
      expect(LifePath.forDate(DateTime(1990, 6, 15)).number,
          LifePath.forDate(DateTime(1990, 6, 15)).number);
    });

    test('conserva i numeri maestri 11, 22, 33', () {
      // 29/09/1980: 29 -> 11, 9, 1980 -> 9; 11+9+9 = 29 -> 11 (maestro).
      final eleven = LifePath.forDate(DateTime(1980, 9, 29));
      expect(eleven.number, 11);
      expect(eleven.isMaster, isTrue);
      // 29/09/2000: 29 -> 11, 9, 2000 -> 2; 11+9+2 = 22 (maestro).
      final twentyTwo = LifePath.forDate(DateTime(2000, 9, 29));
      expect(twentyTwo.number, 22);
      expect(twentyTwo.isMaster, isTrue);
    });

    test('produce sempre una cifra valida con titolo e significato', () {
      const valid = {1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33};
      for (var y = 1970; y <= 2010; y++) {
        for (final md in const [
          [1, 1],
          [6, 15],
          [12, 31],
          [9, 29],
          [2, 22]
        ]) {
          final lp = LifePath.forDate(DateTime(y, md[0], md[1]));
          expect(valid.contains(lp.number), isTrue,
              reason:
                  'numero fuori insieme per $y-${md[0]}-${md[1]}: ${lp.number}');
          expect(lp.title, isNotEmpty);
          expect(lp.meaning, isNotEmpty);
        }
      }
    });

    group('Riduzione passo per passo', () {
      test('mostra ogni passaggio, coerente col numero finale', () {
        final b = LifePath.breakdown(DateTime(1990, 6, 15));
        expect(b.number, LifePath.forDate(DateTime(1990, 6, 15)).number);
        expect(b.number, 4);
        expect(b.dayRoot, 6);
        expect(b.monthRoot, 6);
        expect(b.yearRoot, 1);
        expect(b.sum, 13);
        expect(b.steps, [
          'Giorno 15: 1 + 5 = 6',
          'Mese 6: 6',
          'Anno 1990: 1 + 9 + 9 + 0 = 19 → 1 + 9 = 10 → 1 + 0 = 1',
          'Somma: 6 + 6 + 1 = 13 → 4',
        ]);
      });

      test('spiega la riduzione di un singolo numero', () {
        expect(LifePath.explainReduction(6), '6');
        expect(LifePath.explainReduction(15), '1 + 5 = 6');
        expect(LifePath.explainReduction(1990),
            '1 + 9 + 9 + 0 = 19 → 1 + 9 = 10 → 1 + 0 = 1');
        // I numeri maestri non si riducono.
        expect(LifePath.explainReduction(11), '11');
      });

      test('conserva il numero maestro nella somma', () {
        final b = LifePath.breakdown(DateTime(1980, 9, 29));
        expect(b.number, 11);
        // Giorno 29 -> 11 (maestro), 9, anno 1980 -> 9; 11 + 9 + 9 = 29 -> 11.
        expect(b.dayRoot, 11);
        expect(b.steps.last, 'Somma: 11 + 9 + 9 = 29 → 11');
      });
    });
  });

  group('Fase lunare di nascita', () {
    test('e\' deterministica e coerente col motore reale', () {
      final a = BirthMoon.forDate(DateTime(1990, 6, 15, 2, 30));
      final b = BirthMoon.forDate(DateTime(1990, 6, 15, 2, 30));
      expect(a.sign, b.sign);
      expect(a.phase.italianName, b.phase.italianName);
      // Il segno viene dalla longitudine lunare reale.
      expect(a.sign, NightSky.moonSign(DateTime(1990, 6, 15, 2, 30)));
      // Etichetta e significato pieni.
      expect(a.label, contains(' in '));
      expect(a.label, contains(a.sign.italianName));
      expect(a.meaning, isNotEmpty);
    });

    test('la longitudine lunare resta nel giro [0, 360)', () {
      for (var d = 0; d < 60; d++) {
        final lon = NightSky.moonEclipticLongitude(
            DateTime(2026).add(Duration(days: d * 6)));
        expect(lon, greaterThanOrEqualTo(0.0));
        expect(lon, lessThan(360.0));
      }
    });

    test('la Luna attraversa piu\' segni in un mese', () {
      final signs = <String>{};
      for (var d = 0; d < 28; d++) {
        signs.add(
            NightSky.moonSign(DateTime(1990, 6, 1).add(Duration(days: d))).id);
      }
      // In un mese la Luna percorre tutto lo zodiaco: molti segni distinti.
      expect(signs.length, greaterThanOrEqualTo(10));
    });
  });

  test('Il dato d\'esempio e\' dichiarato tale', () {
    expect(BirthIdentity.example.isExample, isTrue);
  });
}
