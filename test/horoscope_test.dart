import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oroscopo a quattro schede: composizione deterministica su dispositivo, senza
/// costi a runtime. Stesso ingresso, stessa uscita, sempre.
void main() {
  group('Determinismo', () {
    test('Stessa coppia (segno, giorno, anno, dominio) da lo stesso esito', () {
      for (final sign in Zodiac.values) {
        for (final domain in HoroscopeDomain.values) {
          final a = Horoscope.cardFor(
              sign: sign, dayOfYear: 200, year: 2026, domain: domain);
          final b = Horoscope.cardFor(
              sign: sign, dayOfYear: 200, year: 2026, domain: domain);
          expect(a.text, b.text);
          expect(a.title, b.title);
          expect(a.indicator, b.indicator);
          expect(a.luckyNumber, b.luckyNumber);
          expect(a.dayColor, b.dayColor);
        }
      }
    });

    test('Giorni diversi cambiano la corrente, ma l\'ancora resta stabile', () {
      final d1 = Horoscope.cardFor(
          sign: Zodiac.leo,
          dayOfYear: 10,
          year: 2026,
          domain: HoroscopeDomain.generale);
      final d2 = Horoscope.cardFor(
          sign: Zodiac.leo,
          dayOfYear: 11,
          year: 2026,
          domain: HoroscopeDomain.generale);
      // Il titolo (ancora) non cambia mai col giorno.
      expect(d1.title, d2.title);
    });
  });

  group('Intervalli deterministici, giro di un anno', () {
    test('L\'indicatore resta sempre fra 2 e 5', () {
      for (final sign in Zodiac.values) {
        for (var day = 0; day <= 365; day++) {
          for (final domain in HoroscopeDomain.values) {
            final card = Horoscope.cardFor(
                sign: sign, dayOfYear: day, year: 2026, domain: domain);
            expect(card.indicator, inInclusiveRange(2, 5),
                reason:
                    'indicatore ${card.indicator} per ${sign.id} giorno $day ${domain.label}');
          }
        }
      }
    });

    test('La corrente del giorno resta nel pool del dominio', () {
      for (final sign in Zodiac.values) {
        for (var day = 0; day <= 365; day++) {
          for (final domain in HoroscopeDomain.values) {
            final card = Horoscope.cardFor(
                sign: sign, dayOfYear: day, year: 2026, domain: domain);
            final anchor = HoroscopeData.anchors[sign.id]![domain.index][1];
            // Il testo e' ancora piu' spazio piu' corrente: la coda deve essere
            // una frase del pool.
            expect(card.text.startsWith('$anchor '), isTrue);
            final current = card.text.substring(anchor.length + 1);
            expect(
                HoroscopeData.dayPools[domain.index]!.contains(current), isTrue,
                reason: 'corrente fuori pool per ${sign.id} giorno $day');
          }
        }
      }
    });

    test('Il numero fortunato resta fra 1 e 90, solo nella scheda Fortuna', () {
      for (final sign in Zodiac.values) {
        for (var day = 0; day <= 365; day++) {
          final fortuna = Horoscope.cardFor(
              sign: sign,
              dayOfYear: day,
              year: 2026,
              domain: HoroscopeDomain.fortuna);
          expect(fortuna.luckyNumber, inInclusiveRange(1, 90));
          expect(fortuna.dayColor, isNotNull);
          expect(HoroscopeData.palettes[sign.id]!.contains(fortuna.dayColor),
              isTrue);

          // Gli altri domini non portano numero ne colore.
          for (final domain in const [
            HoroscopeDomain.generale,
            HoroscopeDomain.amore,
            HoroscopeDomain.carriera,
          ]) {
            final card = Horoscope.cardFor(
                sign: sign, dayOfYear: day, year: 2026, domain: domain);
            expect(card.luckyNumber, isNull);
            expect(card.dayColor, isNull);
          }
        }
      }
    });
  });

  group('Apertura personalizzata', () {
    test('Il vocativo segue la forma di cortesia', () {
      expect(
          Horoscope.vocativeFor('Sofia', CourtesyForm.feminine), 'Cara Sofia');
      expect(
          Horoscope.vocativeFor('Marco', CourtesyForm.masculine), 'Caro Marco');
      expect(Horoscope.vocativeFor('Alex', CourtesyForm.neutral), 'Ciao Alex');
      expect(Horoscope.vocativeFor('Alex', CourtesyForm.unknown), 'Ciao Alex');
    });

    test('L\'apertura porta il nome e viene dal pool del corpus', () {
      for (final sign in Zodiac.values) {
        for (var day = 0; day <= 365; day += 7) {
          final opening = Horoscope.openingFor(
              sign: sign, dayOfYear: day, year: 2026, vocative: 'Cara Sofia');
          expect(opening, contains('Cara Sofia'));
          final atteso = HoroscopeData.openings.map(
              (o) => o.replaceAll(HoroscopeData.namePlaceholder, 'Cara Sofia'));
          expect(atteso.contains(opening), isTrue,
              reason: 'apertura fuori pool: $opening');
        }
      }
    });

    test('L\'apertura e\' deterministica a seme fisso', () {
      final a = Horoscope.openingFor(
          sign: Zodiac.leo, dayOfYear: 200, year: 2026, vocative: 'Caro Marco');
      final b = Horoscope.openingFor(
          sign: Zodiac.leo, dayOfYear: 200, year: 2026, vocative: 'Caro Marco');
      expect(a, b);
    });

    test('L\'apertura sta solo sulla scheda Generale', () {
      final cards = Horoscope.forSign(
          sign: Zodiac.aries,
          dayOfYear: 190,
          year: 2026,
          opening: 'Cara Sofia, oggi il tuo cielo si accende.');
      expect(cards[0].opening, isNotNull);
      for (final c in cards.skip(1)) {
        expect(c.opening, isNull);
      }
      // Senza apertura la Generale resta senza.
      final senza =
          Horoscope.forSign(sign: Zodiac.aries, dayOfYear: 190, year: 2026);
      expect(senza[0].opening, isNull);
    });
  });

  group('Completezza del catalogo', () {
    test('Tutti i dodici segni, tutti e quattro i domini, titolo e ancora', () {
      expect(HoroscopeData.anchors.length, 12);
      for (final sign in Zodiac.values) {
        final anchors = HoroscopeData.anchors[sign.id];
        expect(anchors, isNotNull, reason: 'ancore mancanti per ${sign.id}');
        expect(anchors!.length, 4);
        for (final a in anchors) {
          expect(a[0].trim(), isNotEmpty); // titolo
          expect(a[1].trim(), isNotEmpty); // ancora
        }
      }
    });

    test('Quattro pool da dieci correnti, e palette non vuote', () {
      expect(HoroscopeData.dayPools.length, 4);
      for (final pool in HoroscopeData.dayPools.values) {
        expect(pool.length, 10);
        for (final s in pool) {
          expect(s.trim(), isNotEmpty);
        }
      }
      expect(HoroscopeData.palettes.length, 12);
      for (final palette in HoroscopeData.palettes.values) {
        expect(palette, isNotEmpty);
      }
      expect(HoroscopeData.disclaimer.trim(), isNotEmpty);
    });
  });

  group('Accenti veri, mai apostrofo al posto dell\'accento', () {
    // Una vocale seguita da apostrofo di fine parola e' un accento scritto male;
    // l'elisione (l'amore) e i troncamenti (po', mo', be') sono leciti.
    final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
    final letter = RegExp('[a-zA-Zàèéìòù]');

    String? offending(String s) {
      for (final m in vowelApostrophe.allMatches(s)) {
        final apo = m.end - 1;
        if (apo + 1 < s.length && letter.hasMatch(s[apo + 1])) continue;
        final vowel = m.start;
        final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
        final pair = '$prev${s[vowel].toLowerCase()}';
        // Troncamenti e imperativi apocopati leciti: po', mo', be', di' (dire),
        // fa', da', va'. Non collidono con gli accenti veri (citta', piu', ...).
        const troncamenti = {'po', 'mo', 'be', 'di', 'fa', 'da', 'va'};
        if (troncamenti.contains(pair)) continue;
        final start = (vowel - 10).clamp(0, s.length);
        return s.substring(start, (apo + 2).clamp(0, s.length));
      }
      return null;
    }

    test('Nessun apostrofo-accento nei testi del corpus modellato', () {
      final strings = <String>[HoroscopeData.disclaimer];
      strings.addAll(HoroscopeData.openings);
      for (final anchors in HoroscopeData.anchors.values) {
        for (final a in anchors) {
          strings.add(a[0]);
          strings.add(a[1]);
        }
      }
      for (final pool in HoroscopeData.dayPools.values) {
        strings.addAll(pool);
      }
      for (final palette in HoroscopeData.palettes.values) {
        strings.addAll(palette);
      }
      for (final s in strings) {
        expect(offending(s), isNull, reason: 'Accento con apostrofo in: "$s"');
      }
    });

    test('Nessun apostrofo-accento nelle schede composte', () {
      for (final sign in Zodiac.values) {
        for (final card
            in Horoscope.forSign(sign: sign, dayOfYear: 123, year: 2026)) {
          expect(offending(card.text), isNull, reason: card.text);
          expect(offending(card.title), isNull, reason: card.title);
        }
      }
    });
  });
}
