import 'package:esoteric_circle/core/astro/moon_phase.dart';
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

  // Estrae passando l'identita' derivata dalla nascita, oppure da un id di
  // dispositivo di prova quando la nascita manca: la firma chiede sempre l'identita'.
  EstrazioneTramonto estrai(DateTime ora,
          {DateTime? nascita, Zodiac? segno, String device = 'dev-anon'}) =>
      SunsetRune.estrai(ora,
          dataNascita: nascita,
          segno: segno,
          identita: SunsetRune.identitaPer(nascita: nascita, deviceId: device));

  group('Il giorno rituale', () {
    test('Ha confine a mezzogiorno locale', () {
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 11, 59)),
          DateTime(2026, 7, 12));
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 1, 0)),
          DateTime(2026, 7, 12));
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 12, 0)),
          DateTime(2026, 7, 13));
      expect(SunsetRune.giornoRituale(DateTime(2026, 7, 13, 23, 30)),
          DateTime(2026, 7, 13));
    });

    test('La sera e la notte fonda condividono la stessa runa', () {
      final sera = estrai(DateTime(2026, 7, 13, 20), nascita: nascita);
      final unaDiNotte = estrai(DateTime(2026, 7, 14, 1), nascita: nascita);
      expect(sera.rune.name, unaDiNotte.rune.name);
      expect(sera.verso, unaDiNotte.verso);
      expect(sera.giornoRituale, unaDiNotte.giornoRituale);
    });
  });

  group('L\'identita\'', () {
    test('Compone data, data con ora, oppure id del dispositivo', () {
      expect(SunsetRune.identitaPer(nascita: DateTime(1988, 7, 5), deviceId: 'x'),
          '1988-07-05');
      expect(
          SunsetRune.identitaPer(
              nascita: DateTime(1988, 7, 5, 9, 4), oraNota: true, deviceId: 'x'),
          '1988-07-05T09:04');
      // Senza ora nota, resta la sola data anche se il momento porta un'ora.
      expect(
          SunsetRune.identitaPer(
              nascita: DateTime(1988, 7, 5, 9, 4), deviceId: 'x'),
          '1988-07-05');
      expect(SunsetRune.identitaPer(deviceId: 'abc123'), 'abc123');
    });

    test('Due utenti anonimi con id diversi non ricevono la stessa runa', () {
      final giorno = DateTime(2026, 7, 13, 20);
      final rune = <String>{};
      for (var i = 0; i < 60; i++) {
        rune.add(SunsetRune.estrai(giorno, identita: 'device-$i').rune.name);
      }
      // Gli anonimi si distribuiscono: non e' piu' la stessa runa per tutti.
      expect(rune.length, greaterThan(6));
    });

    test('Due nascite nello stesso giorno a ore diverse possono differire', () {
      final giorno = DateTime(2026, 7, 13, 20);
      final rune = <String>{};
      for (var h = 0; h < 24; h++) {
        final id = SunsetRune.identitaPer(
            nascita: DateTime(1990, 6, 15, h), oraNota: true, deviceId: 'x');
        rune.add(SunsetRune.estrai(giorno, identita: id).rune.name);
      }
      // Con l'ora nella chiave, chi nasce lo stesso giorno non collide per forza.
      expect(rune.length, greaterThan(1));
    });
  });

  group('L\'estrazione', () {
    test('E\' deterministica su cento date consecutive', () {
      for (var i = 0; i < 100; i++) {
        final ora = DateTime(2026, 1, 1, 20).add(Duration(days: i));
        final a = estrai(ora, nascita: nascita);
        final b = estrai(ora, nascita: nascita);
        expect(a.rune.name, b.rune.name, reason: 'giorno $i');
        expect(a.verso, b.verso, reason: 'giorno $i');
      }
    });

    test('Date di nascita diverse danno rune diverse nello stesso giorno', () {
      final giorno = DateTime(2026, 7, 13, 20);
      final rune = <String>{};
      for (var y = 1960; y < 2000; y++) {
        for (var m = 1; m <= 12; m++) {
          rune.add(estrai(giorno, nascita: DateTime(y, m, 15)).rune.name);
        }
      }
      expect(rune.length, greaterThan(12));
    });

    test('Il ciclo di ventiquattro giorni e\' sparito', () {
      var uguali = 0;
      for (var i = 0; i < 60; i++) {
        final a = estrai(DateTime(2026, 1, 1, 20).add(Duration(days: i)),
            nascita: nascita);
        final b = estrai(DateTime(2026, 1, 1, 20).add(Duration(days: i + 24)),
            nascita: nascita);
        if (a.rune.name == b.rune.name) uguali++;
      }
      expect(uguali, lessThan(20));
    });

    test('Gli otto segni simmetrici non escono MAI in ombra, su diecimila', () {
      var simmetricheViste = 0;
      for (var i = 0; i < 10000; i++) {
        final ora = DateTime(2015, 1, 1, 20).add(Duration(days: i));
        final e = estrai(ora,
            nascita: DateTime(1980, 1, 1).add(Duration(days: i * 7)));
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
        final e = estrai(DateTime(2010, 1, 1, 20).add(Duration(days: i)),
            nascita: DateTime(1975, 3, 1).add(Duration(days: i * 3)));
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

  group('La fase segue il tramonto, la runa no', () {
    test('Istanti diversi della stessa sera: stessa runa e verso', () {
      final giorno = DateTime(2026, 7, 13);
      final rune = <String>{};
      final versi = <RuneVerso>{};
      for (final istante in [
        DateTime(2026, 7, 13, 17, 30),
        DateTime(2026, 7, 13, 19, 0),
        DateTime(2026, 7, 13, 21, 15),
      ]) {
        final e = SunsetRune.estrai(DateTime(2026, 7, 13, 20),
            dataNascita: nascita,
            identita: SunsetRune.identitaPer(nascita: nascita, deviceId: 'x'),
            istanteTramonto: istante);
        expect(e.giornoRituale, giorno);
        rune.add(e.rune.name);
        versi.add(e.verso);
      }
      expect(rune.length, 1, reason: 'la runa non dipende dall\'istante');
      expect(versi.length, 1, reason: 'il verso non dipende dall\'istante');
    });

    test('Senza istante, la fase usa le diciotto del giorno rituale', () {
      final e = estrai(DateTime(2026, 7, 13, 20), nascita: nascita);
      final attesa = MoonPhase.forDate(DateTime(2026, 7, 13, 18));
      expect(e.fase.italianName, attesa.italianName);
    });
  });

  group('Il corpus e\' robusto', () {
    test('Ogni runa, segno e fase compone voci piene, mai vuote ne\' eccezioni',
        () {
      const fasi = [
        'Luna nuova',
        'Luna crescente',
        'Primo quarto',
        'Gibbosa crescente',
        'Luna piena',
        'Gibbosa calante',
        'Ultimo quarto',
        'Luna calante',
      ];
      for (final r in kElderFuthark) {
        for (final segno in Zodiac.values) {
          for (final nomeFase in fasi) {
            final fase = MoonPhase(
                fraction: 0.1,
                illumination: 0.1,
                waxing: true,
                italianName: nomeFase);
            final versi = kRuneSimmetriche.contains(r.name)
                ? [RuneVerso.dritto]
                : [RuneVerso.dritto, RuneVerso.merkstave];
            for (final v in versi) {
              final e = EstrazioneTramonto(
                giornoRituale: DateTime(2026, 7, 13),
                rune: r,
                verso: v,
                fase: fase,
                segno: segno,
                identita: 'x',
              );
              final a = SunsetRuneCorpus.vocePrimaLasciare(e);
              final b = SunsetRuneCorpus.vocePortare(e);
              expect(a.trim(), isNotEmpty, reason: '${r.name} $segno $nomeFase');
              expect(b.trim(), isNotEmpty, reason: '${r.name} $segno $nomeFase');
              // Nessuno spazio doppio ne' in coda.
              expect(a.contains('  '), isFalse);
              expect(b.endsWith(' '), isFalse);
            }
          }
        }
      }
    });

    test('Fase sconosciuta ripiega sul registro neutro, non lancia', () {
      const fase = MoonPhase(
          fraction: 0.1,
          illumination: 0.1,
          waxing: true,
          italianName: 'Fase fantasma');
      final registro = SunsetRuneCorpus.registroLunare(fase);
      expect(registro.trim(), isNotEmpty);
    });

    test('Verso d\'ombra su runa simmetrica ripiega sulla voce dritta', () {
      final dritto = SunsetRuneCorpus.voceRuna('Gebo', RuneVerso.dritto);
      final ombra = SunsetRuneCorpus.voceRuna('Gebo', RuneVerso.merkstave);
      expect(ombra.lasciare, dritto.lasciare);
      expect(ombra.porta.trim(), isNotEmpty);
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
      final e = estrai(DateTime(2026, 7, 13, 20), nascita: nascita);
      final t = SunsetRuneCorpus.trasparenza(e);
      expect(t, contains(e.rune.name));
      expect(t, contains(e.fase.italianName.toLowerCase()));
      expect(t, contains(e.segno.italianName));
    });
  });

  test('L\'insistenza e\' deterministica e usa l\'identita\' dell\'estrazione',
      () {
    final e = estrai(DateTime(2026, 7, 13, 20), nascita: nascita);
    final i1 = SunsetRune.indiceInsistenza(e);
    final i2 = SunsetRune.indiceInsistenza(e);
    expect(i1, i2);
    expect(i1, inInclusiveRange(0, 3));
  });
}
