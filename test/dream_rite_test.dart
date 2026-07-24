import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il Rito del Sogno, ex Rito della Buonanotte: contenuto deterministico dal
/// cielo notturno reale.
void main() {
  final commaE = RegExp(r',\s+ed?\b', caseSensitive: false);
  final date = DateTime(2026, 7, 13, 22, 40);

  group('La rinomina', () {
    test('Il rito si chiama Rito del Sogno, l\'id resta night', () {
      expect(DailyElement.night.title, 'Rito del Sogno');
      expect(DailyElement.night.id, 'night');
      // Il vecchio nome non compare piu' in nessuna stringa mostrata.
      expect(DailyElement.night.title.contains('Buonanotte'), isFalse);
      expect(DailyElement.night.description.contains('Buonanotte'), isFalse);
      for (final e in DailyElement.values) {
        expect(e.title.contains('Buonanotte'), isFalse, reason: e.id);
      }
    });
  });

  group('Il cielo reale', () {
    test('Segno e fase della Luna vengono da NightSky e da MoonPhase', () {
      final luna = DreamRiteCorpus.lunaDi(date);
      expect(luna.sign, NightSky.moonSign(date));
      expect(luna.phase.italianName, MoonPhase.forDate(date).italianName);
      expect(luna.phase.waxing, MoonPhase.forDate(date).waxing);
    });

    test('La costellazione e\' quella del segno della Luna', () {
      for (var g = 0; g < 40; g++) {
        final quando = date.add(Duration(days: g));
        final luna = DreamRiteCorpus.lunaDi(quando);
        final figura =
            kZodiacConstellations.firstWhere((c) => c.sign == luna.sign);
        expect(figura.sign, NightSky.moonSign(quando), reason: 'giorno $g');
        expect(figura.points.length, greaterThanOrEqualTo(3));
        expect(figura.edges, isNotEmpty);
      }
    });

    test('Ogni segno ha la sua voce e la sua costellazione', () {
      for (final z in Zodiac.values) {
        final v = DreamRiteCorpus.voce(z);
        for (final campo in [
          v.parola,
          v.immagine,
          v.giorno,
          v.riconoscimento,
          v.posa,
        ]) {
          expect(campo.trim(), isNotEmpty, reason: z.id);
        }
        expect(kZodiacConstellations.any((c) => c.sign == z), isTrue,
            reason: z.id);
      }
    });
  });

  group('Il saluto della notte', () {
    test('Nomina il segno reale e la fase reale della Luna', () {
      for (var g = 0; g < 30; g++) {
        final quando = date.add(Duration(days: g));
        final luna = DreamRiteCorpus.lunaDi(quando);
        final saluto = DreamRiteCorpus.saluto(quando);
        expect(saluto, contains(luna.sign.italianName), reason: 'giorno $g');
        // La fase reale compare almeno nella provenienza della carta.
        expect(DreamRiteCorpus.provenienza(luna),
            contains(luna.phase.italianName.toLowerCase()));
        // L'apertura dichiara la fase: piena, nuova, cresce oppure cala.
        final apertura = DreamRiteCorpus.aperturaLuna(luna);
        expect(
            apertura.contains('piena') ||
                apertura.contains('nuova') ||
                apertura.contains('cresce') ||
                apertura.contains('cala'),
            isTrue,
            reason: apertura);
      }
    });

    test('Guarda al passato e al presente, mai al futuro', () {
      for (final z in Zodiac.values) {
        final v = DreamRiteCorpus.voce(z);
        // La riga del giorno e' al passato prossimo.
        expect(v.giorno.startsWith('hai '), isTrue, reason: z.id);
        expect(v.riconoscimento.startsWith('hai '), isTrue, reason: z.id);
        // Nessuna promessa al futuro nel corpo del saluto.
        for (final futuro in const [
          'domani sarà',
          'ti aspetta',
          'accadrà',
          'succederà',
          'vedrai',
        ]) {
          expect(v.giorno.contains(futuro), isFalse, reason: '${z.id} $futuro');
          expect(v.riconoscimento.contains(futuro), isFalse, reason: z.id);
        }
      }
    });

    test('E\' deterministico e chiude con la buonanotte', () {
      final a = DreamRiteCorpus.saluto(date);
      final b = DreamRiteCorpus.saluto(date);
      expect(a, b);
      expect(a.trim().endsWith('Buonanotte.'), isTrue, reason: a);
      // Ruota col Maestro di turno, come il Rito dell'Alba.
      expect(DailyRituals.nightMaestro(date), DailyRituals.dawnMaestro(date));
    });

    test('Nessun testo del rito e\' troncato o viola la regola di lingua', () {
      for (var g = 0; g < 40; g++) {
        final quando = date.add(Duration(days: g));
        final luna = DreamRiteCorpus.lunaDi(quando);
        final testi = <String>[
          DreamRiteCorpus.saluto(quando),
          DreamRiteCorpus.provenienza(luna),
          DreamRiteCorpus.daDoveNasce(luna),
          DreamRiteCorpus.aperturaLuna(luna),
          DreamRiteCorpus.parola(luna.sign),
        ];
        for (final t in testi) {
          expect(t.trim(), isNotEmpty);
          // Niente ellissi da troncamento, niente trattino lungo.
          expect(t.contains('...'), isFalse, reason: t);
          expect(t.contains('…'), isFalse, reason: t);
          expect(t.contains('—'), isFalse, reason: t);
          expect(commaE.hasMatch(t), isFalse, reason: t);
        }
      }
    });
  });

  group('La trasparenza', () {
    test('Dichiara cielo reale, segno, fase e il confine onesto', () {
      final luna = DreamRiteCorpus.lunaDi(date);
      final t = DreamRiteCorpus.daDoveNasce(luna);
      expect(t, contains('cielo notturno reale di questo momento'));
      expect(t, contains(luna.sign.italianName));
      expect(t, contains(luna.phase.italianName.toLowerCase()));
      // Il confine: nessuna promessa di allineamento esatto.
      expect(t, contains('non è allineata'));
      expect(t, contains('GPS'));
      // Fondato sul corpus del segno lunare gia' nel repo.
      expect(t, contains(BirthMoon.meaningFor(luna.sign)));
    });
  });
}
