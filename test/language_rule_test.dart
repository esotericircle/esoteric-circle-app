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
import 'dart:io';

import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regola di lingua: mai la sequenza virgola piu' "e" (o "ed"), non solo a
/// inizio di proposizione ma anche a meta' frase. Questo test setaccia i testi
/// statici e generati dell'app, e in piu' scandaglia tutte le stringhe del
/// codice, cosi' la violazione non puo' rientrare di nascosto.
void main() {
  // Virgola, spazi, poi "e"/"ed" come parola: vietata ovunque nella frase, non
  // solo in apertura. Si escludono i troncamenti tipo "po'".
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
    final full = UserProfile(
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

  test('Chiedi ai Maestri rispetta la regola della virgola', () {
    const oracle = MaestroOracle();
    const temi = ['amore', 'il lavoro', 'una scelta difficile', 'la fortuna'];
    for (final t in temi) {
      final r = oracle.consult(theme: t, maestri: Maestro.values);
      expectClean(r.synthesis!, 'sintesi «$t»');
      for (final lens in r.lenses) {
        expectClean(lens.glance, 'colpo d\'occhio ${lens.maestro.id}');
        expectClean(lens.reading, 'testo ${lens.maestro.id}');
        expectClean(lens.invite, 'invito ${lens.maestro.id}');
      }
    }
  });

  test('Il controllo segnala la virgola piu "e" anche a meta frase', () {
    // A meta' frase, non solo in apertura.
    expect(commaE.hasMatch('Vado al mare, e poi torno'), isTrue);
    expect(commaE.hasMatch('Prendo il libro, ed esco di casa'), isTrue);
    // Usi legittimi restano puliti.
    expect(commaE.hasMatch('Vado al mare e poi torno'), isFalse);
    expect(commaE.hasMatch('mele, pere e uva'), isFalse);
    expect(commaE.hasMatch('la casa, è bella'), isFalse); // "è" non "e"
  });

  // Setaccio profondo: scandaglia ogni stringa nel codice sotto lib/, unendo le
  // stringhe adiacenti spezzate su piu' righe, cosi' nessun copy sfugge, ne'
  // statico ne' a capo. Salta i commenti.
  test('Anche nel file in deroga il trattino lungo resta vietato', () {
    // **LA DEROGA VALE PER UNA REGOLA SOLA.** L'allegato B esce dalla regola
    // della virgola perche' e' testo di Mauro consegnato verbatim, ma il trattino
    // lungo non e' una scelta d'autore, e' un carattere che questa app non usa
    // mai. Senza questa prova la deroga si sarebbe allargata in silenzio.
    final testo =
        File('lib/core/domande/cornici_del_presagio.dart').readAsStringSync();
    expect(testo.contains('—'), isFalse,
        reason: 'trattino lungo nelle cornici del presagio');
  });

  test('Nessuna stringa del codice viola la regola della virgola', () {
    // **NESSUNA DEROGA, e c'e' stata una richiesta respinta.** Avevo chiesto di
    // esentare le cornici del presagio, undici testi su trentadue con la virgola
    // prima della "e", perche' l'allegato B le vuole verbatim. Mauro ha negato con
    // la ragione giusta: in quelle cornici la virgola e' sempre stilistica e mai
    // portante, quindi si toglie senza cambiare il senso, e una regola con un
    // elenco di eccezioni diventa un elenco che nessuno mantiene. Le undici
    // virgole sono state togliete e questo file guarda tutto `lib`, cornici
    // comprese.
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final strings = _logicalStrings(file.readAsStringSync());
      for (final s in strings) {
        expect(commaE.hasMatch(s), isFalse,
            reason: 'Virgola piu "e" in ${file.path}, nella stringa: "$s".');
        expect(s.contains('—'), isFalse,
            reason: 'Trattino lungo in ${file.path}, nella stringa: "$s".');
      }
    }
  });
}

/// Estrae le stringhe letterali da sorgente Dart, saltando i commenti e unendo
/// le stringhe adiacenti (concatenazione implicita a capo). Gestisce apici
/// singoli e doppi, stringhe grezze (r'...') e a tripla virgoletta. Basta per il
/// controllo di lingua: non decodifica gli escape, che non toccano la sequenza
/// virgola piu' "e".
List<String> _logicalStrings(String src) {
  final result = <String>[];
  final n = src.length;
  var i = 0;
  StringBuffer? logical;

  void flush() {
    if (logical != null) {
      result.add(logical.toString());
      logical = null;
    }
  }

  while (i < n) {
    final c = src[i];
    // Commenti.
    if (c == '/' && i + 1 < n && src[i + 1] == '/') {
      flush();
      i += 2;
      while (i < n && src[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && i + 1 < n && src[i + 1] == '*') {
      flush();
      i += 2;
      while (i + 1 < n && !(src[i] == '*' && src[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    // Inizio stringa, eventualmente grezza.
    var raw = false;
    var j = i;
    if (c == 'r' && i + 1 < n && (src[i + 1] == '\'' || src[i + 1] == '"')) {
      raw = true;
      j = i + 1;
    }
    final ch = src[j];
    if (ch == '\'' || ch == '"') {
      final triple =
          j + 2 < n && src[j + 1] == ch && src[j + 2] == ch;
      final quoteLen = triple ? 3 : 1;
      var k = j + quoteLen;
      final content = StringBuffer();
      while (k < n) {
        if (!raw && src[k] == '\\') {
          if (k + 1 < n) content.write(src[k + 1]);
          k += 2;
          continue;
        }
        if (triple) {
          if (k + 2 < n && src[k] == ch && src[k + 1] == ch && src[k + 2] == ch) {
            k += 3;
            break;
          }
        } else {
          if (src[k] == ch) {
            k += 1;
            break;
          }
          if (src[k] == '\n') break;
        }
        content.write(src[k]);
        k++;
      }
      logical ??= StringBuffer();
      logical!.write(content.toString());
      i = k;
      // Adiacenza: se la prossima cosa non-spazio e' un'altra stringa, unisci.
      var p = i;
      while (p < n &&
          (src[p] == ' ' || src[p] == '\t' || src[p] == '\n' || src[p] == '\r')) {
        p++;
      }
      final adjacent = p < n &&
          (src[p] == '\'' ||
              src[p] == '"' ||
              (src[p] == 'r' &&
                  p + 1 < n &&
                  (src[p + 1] == '\'' || src[p + 1] == '"')));
      if (adjacent) {
        i = p;
      } else {
        flush();
      }
      continue;
    }
    i++;
  }
  flush();
  return result;
}
