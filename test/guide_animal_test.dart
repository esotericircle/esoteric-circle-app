import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_corpus.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_day.dart';
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
        // Repertorio ricco: almeno dodici segni per ogni animale, cosi' il
        // viaggio ripetibile ha sempre qualcosa di nuovo da portare.
        expect(r.messaggi.length, greaterThanOrEqualTo(12), reason: a.name);
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

  group('Messaggio del Giorno', () {
    final lupo = GuideAnimalDerivation.forSign(Zodiac.cancer); // Sole in Cancro
    final base = DateTime(2026, 7, 22);

    test('Stabile nello stesso giorno e con la stessa carta', () {
      final a = GuideAnimalDay.per(
          animale: lupo, soleNatale: Zodiac.cancer, giorno: base);
      final b = GuideAnimalDay.per(
          animale: lupo, soleNatale: Zodiac.cancer, giorno: base);
      expect(a.testo, b.testo);
      expect(a.transito, b.transito);
      expect(a.datiNatali, b.datiNatali);
    });

    test('Cambia al cambio di data', () {
      final oggi = GuideAnimalDay.per(
              animale: lupo, soleNatale: Zodiac.cancer, giorno: base)
          .testo;
      // In un mese la Luna passa tutti i segni: il transito e quindi il
      // messaggio devono cambiare almeno una volta.
      var cambia = false;
      for (var g = 1; g <= 40 && !cambia; g++) {
        final t = GuideAnimalDay.per(
                animale: lupo,
                soleNatale: Zodiac.cancer,
                giorno: base.add(Duration(days: g)))
            .testo;
        if (t != oggi) cambia = true;
      }
      expect(cambia, isTrue,
          reason: 'in 40 giorni il messaggio deve cambiare almeno una volta');
    });

    test('Differisce per totem, a parita\' di giorno e carta', () {
      // Stesso Sole natale e stesso giorno: cambia solo il totem, cosi' si
      // isola che il messaggio dipende davvero dall'animale.
      final aquila = GuideAnimalDerivation.forSign(Zodiac.leo);
      final delLupo = GuideAnimalDay.per(
              animale: lupo, soleNatale: Zodiac.cancer, giorno: base)
          .testo;
      final dellAquila = GuideAnimalDay.per(
              animale: aquila, soleNatale: Zodiac.cancer, giorno: base)
          .testo;
      expect(delLupo, isNot(dellAquila));
    });

    test('La trasparenza riporta transito e dati natali non vuoti', () {
      final nascita = DateTime(1988, 7, 5, 9, 30); // Sole in Cancro
      final m = GuideAnimalDay.per(
          animale: lupo,
          soleNatale: Zodiac.cancer,
          giorno: base,
          nascita: nascita);
      expect(m.transito.trim(), isNotEmpty);
      expect(m.transito, contains('Luna')); // la Luna di transito
      expect(m.transito, contains('Sole')); // il Sole natale toccato
      expect(m.transito, contains('Cancro')); // il segno del Sole natale
      expect(m.datiNatali, contains('Sole in Cancro'));
      expect(m.datiNatali, contains('Luna in')); // la Luna natale, con la data
    });

    test('Senza data di nascita, i dati natali mostrano il solo Sole', () {
      final m = GuideAnimalDay.per(
          animale: lupo, soleNatale: Zodiac.cancer, giorno: base);
      expect(m.datiNatali, contains('Sole in Cancro'));
      // L'Ascendente non si inventa e la Luna natale serve la data di nascita.
      expect(m.datiNatali.contains('Luna'), isFalse);
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
