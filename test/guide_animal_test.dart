import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart'
    show Pianeta;
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_corpus.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cuore deterministico dell'Animale Guida di Caligo.
void main() {
  group('Derivazione segno-animale', () {
    const attesi = {
      Zodiac.aries: 'Falco',
      Zodiac.taurus: 'Orso',
      Zodiac.gemini: 'Volpe',
      Zodiac.cancer: 'Lupo',
      Zodiac.leo: 'Aquila',
      Zodiac.virgo: 'Gufo',
      Zodiac.libra: 'Cervo',
      Zodiac.scorpio: 'Serpente',
      Zodiac.sagittarius: 'Cavallo',
      Zodiac.capricorn: 'Tartaruga',
      Zodiac.aquarius: 'Corvo',
      Zodiac.pisces: 'Lince',
    };

    test('Ogni segno da\' il suo animale, per tutti e dodici', () {
      for (final e in attesi.entries) {
        expect(GuideAnimalDerivation.forSign(e.key).name, e.value,
            reason: e.key.name);
      }
    });

    test('La tabella e\' biiettiva: dodici animali distinti dal catalogo', () {
      final animali =
          Zodiac.values.map((z) => GuideAnimalDerivation.forSign(z).name);
      expect(animali.toSet().length, 12);
      // Ogni animale derivato ha la sua arte a bundle.
      for (final z in Zodiac.values) {
        final a = GuideAnimalDerivation.forSign(z);
        expect(AnimalCatalog.animals.contains(a), isTrue, reason: z.name);
      }
    });

    test('La derivazione e\' deterministica: stesso segno, stesso animale', () {
      for (final z in Zodiac.values) {
        expect(GuideAnimalDerivation.forSign(z).name,
            GuideAnimalDerivation.forSign(z).name);
      }
    });

    test('Il rovescio della tabella torna al segno', () {
      for (final z in Zodiac.values) {
        final a = GuideAnimalDerivation.forSign(z);
        expect(GuideAnimalDerivation.signOf(a.name), z, reason: z.name);
      }
    });
  });

  group('Corpus', () {
    test('Ogni animale derivato ha una lettura piena', () {
      for (final z in Zodiac.values) {
        final a = GuideAnimalDerivation.forSign(z);
        final r = GuideAnimalCorpus.di(a.name);
        for (final campo in [
          r.natura,
          r.dono,
          r.lezione,
          r.quando,
          r.invito,
        ]) {
          expect(campo.trim(), isNotEmpty, reason: a.name);
          expect(campo.length, greaterThan(40), reason: a.name);
        }
        expect(r.messaggi.length, greaterThanOrEqualTo(3), reason: a.name);
        for (final m in r.messaggi) {
          expect(m.trim(), isNotEmpty, reason: a.name);
        }
      }
    });

    test('Fonti e metodo cita le opere e dichiara la curatela', () {
      const f = GuideAnimalCorpus.fontiEMetodo;
      expect(f, contains('Harner'));
      expect(f, contains('Andrews'));
      expect(f, contains('Farmer'));
      expect(f, contains('Carson'));
      expect(f, contains('ponte di curatela'));
    });
  });

  group('Messaggio dall\'Animale', () {
    test('E\' deterministico sul giorno e cambia coi giorni', () {
      final animal = GuideAnimalDerivation.forSign(Zodiac.cancer); // Lupo
      final giorno = DateTime(2026, 7, 22);
      final a =
          GuideAnimalCorpus.messaggioDelGiorno(animal, giorno, {Pianeta.sole});
      final b =
          GuideAnimalCorpus.messaggioDelGiorno(animal, giorno, {Pianeta.sole});
      expect(a, b);
      // In un altro giorno la riga scelta puo' cambiare, ma resta stabile in se.
      final domani = DateTime(2026, 7, 23);
      final c =
          GuideAnimalCorpus.messaggioDelGiorno(animal, domani, {Pianeta.sole});
      expect(c, GuideAnimalCorpus.messaggioDelGiorno(animal, domani, {Pianeta.sole}));
    });

    test('La cornice viene dal Sole e dalla Luna', () {
      final animal = GuideAnimalDerivation.forSign(Zodiac.leo);
      final giorno = DateTime(2026, 7, 22);
      final soloSole =
          GuideAnimalCorpus.messaggioDelGiorno(animal, giorno, {Pianeta.sole});
      final conLuna = GuideAnimalCorpus.messaggioDelGiorno(
          animal, giorno, {Pianeta.sole, Pianeta.luna});
      expect(soloSole, contains('Sole'));
      expect(conLuna, contains('Luna'));
    });
  });

  test('L\'intreccio con l\'archetipo cita archetipo e animale, non li fonde',
      () {
    final animal = GuideAnimalDerivation.forSign(Zodiac.cancer); // Lupo
    final testo =
        GuideAnimalCorpus.intreccioArchetipo(animal, Archetype.eroe);
    expect(testo, contains(Archetype.eroe.conArticolo));
    expect(testo, contains(animal.summary));
    // L'archetipo non cambia l'animale: il Lupo resta il Lupo.
    expect(GuideAnimalDerivation.forSign(Zodiac.cancer).name, 'Lupo');
  });
}
