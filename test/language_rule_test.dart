import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/identity/numerology.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_suggestions.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regola di lingua: mai iniziare una proposizione dopo la virgola con la
/// congiunzione "e" (o "ed"). Questo test setaccia i testi statici e generati
/// dell'app, cosi' la violazione non puo' rientrare di nascosto.
void main() {
  // Virgola, spazi, poi "e"/"ed" come parola: e' l'inizio di proposizione
  // vietato. Si escludono i troncamenti tipo "po'".
  final commaE = RegExp(r',\s+ed?\b', caseSensitive: false);

  String? offending(String s) {
    final m = commaE.firstMatch(s);
    if (m == null) return null;
    final start = (m.start - 12).clamp(0, s.length);
    final end = (m.end + 6).clamp(0, s.length);
    return s.substring(start, end);
  }

  void expectClean(String text, String where) {
    final bad = offending(text);
    expect(bad, isNull,
        reason: 'Proposizione dopo la virgola con "e" in $where, vicino a '
            '"$bad".');
  }

  test('La persona dei Maestri rispetta la regola della virgola', () {
    const full = UserProfile(
      displayName: 'Sofia',
      courtesyForm: CourtesyForm.feminine,
    );
    const memoryFull = MaestroMemory(
      facts: ['Segno solare Gemelli', 'Cerca chiarezza sul lavoro'],
      sessionSummary: 'Avete parlato del suo Ascendente e della carriera.',
    );
    for (final maestro in Maestro.values) {
      expectClean(
        MaestroPersona.systemInstruction(
            maestro: maestro, profile: full, memory: memoryFull),
        'persona ${maestro.id} (pieno)',
      );
      expectClean(
        MaestroPersona.systemInstruction(
            maestro: maestro,
            profile: UserProfile.empty,
            memory: MaestroMemory.empty),
        'persona ${maestro.id} (vuoto)',
      );
      expectClean(MaestroPersona.distillInstruction(maestro),
          'distillato ${maestro.id}');
    }
  });

  test('I suggerimenti rispettano la regola della virgola', () {
    for (final maestro in Maestro.values) {
      for (final q in SuggestionSets.frequent(maestro)) {
        expectClean(q, 'frequente ${maestro.id}');
      }
      for (final q in SuggestionSets.personal(maestro)) {
        expectClean(q, 'personale ${maestro.id}');
      }
    }
    for (final g in SuggestionGroup.values) {
      expectClean(g.label, 'etichetta gruppo');
    }
  });

  test('I testi del cielo rispettano la regola della virgola', () {
    for (final z in Zodiac.values) {
      expectClean(NightSky.describe(z), 'cielo ${z.id}');
    }
    for (var d = 0; d < 60; d++) {
      final now = DateTime(2026).add(Duration(days: d * 6));
      expectClean(NightSky.describeMoon(MoonPhase.forDate(now)), 'luna $d');
    }
  });

  test('La cartolina rispetta la regola della virgola', () {
    for (var doy = 0; doy < 366; doy++) {
      final now = DateTime(2026).add(Duration(days: doy));
      expectClean(SkyPostcard.poeticLine(now), 'riga poetica $doy');
    }
    expectClean(SkyPostcard.shareText(DateTime(2026, 7, 13)), 'testo condivisione');
    expectClean(SkyPostcard.shareText(DateTime(2026, 7, 13), birth: true),
        'testo condivisione nascita');
    for (final birth in [false, true]) {
      expectClean(SkyPostcard.titleFor(birth: birth), 'titolo cartolina $birth');
    }
  });

  test('I fatti identitari del passaporto rispettano la regola della virgola', () {
    final numbers = <int>{};
    final signs = <String>{};
    for (var i = 0; i < 400; i++) {
      final d = DateTime(1970, 1, 1).add(Duration(days: i * 3));
      final lp = LifePath.forDate(d);
      if (numbers.add(lp.number)) {
        expectClean(lp.title, 'titolo numero ${lp.number}');
        expectClean(lp.meaning, 'significato numero ${lp.number}');
      }
      final bm = BirthMoon.forDate(d);
      if (signs.add(bm.sign.id)) {
        expectClean(bm.meaning, 'luna ${bm.sign.id}');
      }
    }
  });
}
