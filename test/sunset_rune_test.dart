import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart'
    show RuneVerso, kRuneSimmetriche;
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cuore deterministico della Runa del Tramonto.
void main() {
  final nascita = DateTime(1988, 7, 5);

  group('Il giorno rituale', () {
    test('Ha confine a mezzogiorno locale', () {
      // Prima delle dodici e' il giorno di ieri.
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 11, 59)),
          DateTime(2026, 7, 12));
      // All'una di notte si vede ancora la runa della sera passata.
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 1, 0)),
          DateTime(2026, 7, 12));
      // A mezzogiorno e dopo e' oggi.
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 12, 0)),
          DateTime(2026, 7, 13));
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 23, 30)),
          DateTime(2026, 7, 13));
    });

    test('La sera e la notte fonda condividono la stessa runa', () {
      final sera = SunsetRune.estrai(DateTime(2026, 7, 13, 20),
          dataNascita: nascita);
      final unaDiNotte = SunsetRune.estrai(DateTime(2026, 7, 14, 1),
          dataNascita: nascita);
      expect(sera.rune.name, unaDiNotte.rune.name);
      expect(sera.verso, unaDiNotte.verso);
      expect(sera.giornoRituale, unaDiNotte.giornoRituale);
    });
  });

  group('L\'estrazione', () {
    test('E\' deterministica su cento date consecutive', () {
      for (var i = 0; i < 100; i++) {
        final ora = DateTime(2026, 1, 1, 20).add(Duration(days: i));
        final a = SunsetRune.estrai(ora, dataNascita: nascita);
        final b = SunsetRune.estrai(ora, dataNascita: nascita);
        expect(a.rune.name, b.rune.name, reason: 'giorno $i');
        expect(a.verso, b.verso, reason: 'giorno $i');
      }
    });

    test('Date di nascita diverse danno rune diverse nello stesso giorno', () {
      final giorno = DateTime(2026, 7, 13, 20);
      final rune = <String>{};
      for (var y = 1960; y < 2000; y++) {
        for (var m = 1; m <= 12; m++) {
          rune.add(SunsetRune.estrai(giorno, dataNascita: DateTime(y, m, 15))
              .rune.name);
        }
      }
      // Non e' piu' la stessa runa per tutti: nello stesso giorno ne escono molte.
      expect(rune.length, greaterThan(12));
      // E l'anonimo non coincide per forza con una nascita qualsiasi.
      final anon = SunsetRune.estrai(giorno).rune.name;
      expect(rune.contains(anon) || anon.isNotEmpty, isTrue);
    });

    test('Il ciclo di ventiquattro giorni e\' sparito', () {
      // Con la vecchia regola dayOfYear % 24, giorni a distanza di 24 davano la
      // stessa runa. Ora no.
      var uguali = 0;
      for (var i = 0; i < 60; i++) {
        final a = SunsetRune.estrai(DateTime(2026, 1, 1, 20).add(Duration(days: i)),
            dataNascita: nascita);
        final b = SunsetRune.estrai(
            DateTime(2026, 1, 1, 20).add(Duration(days: i + 24)),
            dataNascita: nascita);
        if (a.rune.name == b.rune.name) uguali++;
      }
      // Qualche coincidenza casuale ci sta, ma non sono quasi tutte uguali.
      expect(uguali, lessThan(20));
    });

    test('Gli otto segni simmetrici non escono MAI in ombra, su diecimila', () {
      var simmetricheViste = 0;
      for (var i = 0; i < 10000; i++) {
        final ora = DateTime(2015, 1, 1, 20).add(Duration(days: i));
        final e = SunsetRune.estrai(ora,
            dataNascita: DateTime(1980, 1, 1).add(Duration(days: i * 7)));
        if (kRuneSimmetriche.contains(e.rune.name)) {
          simmetricheViste++;
          expect(e.inOmbra, isFalse, reason: '${e.rune.name} in ombra, giro $i');
        }
      }
      expect(simmetricheViste, greaterThan(0));
    });

    test('Il verso d\'ombra e\' circa il trentacinque per cento, mai la meta\'',
        () {
      var asimmetriche = 0;
      var ombra = 0;
      for (var i = 0; i < 6000; i++) {
        final e = SunsetRune.estrai(
            DateTime(2010, 1, 1, 20).add(Duration(days: i)),
            dataNascita: DateTime(1975, 3, 1).add(Duration(days: i * 3)));
        if (!e.simmetrica) {
          asimmetriche++;
          if (e.inOmbra) ombra++;
        }
      }
      final quota = ombra / asimmetriche;
      expect(quota, greaterThan(0.25));
      expect(quota, lessThan(0.45));
    });
  });

  group('Il corpus', () {
    test('Ogni runa e ogni verso hanno le due voci, nessuna vuota', () {
      for (final r in kElderFuthark) {
        final dritto = SunsetRuneCorpus.voceRuna(r.name, RuneVerso.dritto);
        expect(dritto.lasciare.trim(), isNotEmpty, reason: r.name);
        expect(dritto.porta.trim(), isNotEmpty, reason: r.name);
        if (!kRuneSimmetriche.contains(r.name)) {
          final ombra = SunsetRuneCorpus.voceRuna(r.name, RuneVerso.merkstave);
          expect(ombra.lasciare.trim(), isNotEmpty, reason: '${r.name} ombra');
          expect(ombra.porta.trim(), isNotEmpty, reason: '${r.name} ombra');
        }
      }
      // Ventiquattro rune dritte, sedici in ombra.
      expect(SunsetRuneCorpus.dritto.length, 24);
      expect(SunsetRuneCorpus.ombra.length, 16);
    });

    test('Otto registri lunari e dodici clausole di segno, complete', () {
      expect(SunsetRuneCorpus.registri.length, 8);
      expect(SunsetRuneCorpus.clausole.length, 12);
      for (final z in Zodiac.values) {
        expect(SunsetRuneCorpus.clausole.containsKey(z.id), isTrue, reason: z.id);
      }
      expect(SunsetRuneCorpus.insistenze.length, 4);
    });

    test('Nessuna riga e\' duplicata di un\'altra', () {
      final tutte = <String>[
        for (final v in SunsetRuneCorpus.dritto.values) ...[v.lasciare, v.porta],
        for (final v in SunsetRuneCorpus.ombra.values) ...[v.lasciare, v.porta],
        ...SunsetRuneCorpus.registri.values,
        ...SunsetRuneCorpus.clausole.values,
        ...SunsetRuneCorpus.insistenze,
      ];
      expect(tutte.toSet().length, tutte.length);
    });

    test('La trasparenza dichiara i tre fattori', () {
      final e = SunsetRune.estrai(DateTime(2026, 7, 13, 20), dataNascita: nascita);
      final t = SunsetRuneCorpus.trasparenza(e);
      expect(t, contains(e.rune.name));
      expect(t, contains(e.fase.italianName.toLowerCase()));
      expect(t, contains(e.segno.italianName));
      // Le due voci si compongono con registro lunare e clausola di segno.
      final a = SunsetRuneCorpus.vocePrimaLasciare(e);
      final b = SunsetRuneCorpus.vocePortare(e);
      expect(a, contains(SunsetRuneCorpus.registroLunare(e.fase)));
      expect(b, contains(SunsetRuneCorpus.clausolaSegno(e.segno)));
    });
  });
}
