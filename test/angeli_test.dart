import 'dart:io';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

/// I tre Angeli dello Shemhamphorash: catalogo e regole di attribuzione.
///
/// Le tre regole hanno confini netti, ed e' li' che un calcolo sbaglia: il
/// primo grado e l'ultimo, la mezzanotte esatta, il minuto in cui l'angelo
/// cambia, il passaggio d'anno. Questi test stanno tutti sui confini.
void main() {
  group('Catalogo', () {
    test('Settantadue angeli, nove cori da otto', () {
      expect(AngelCatalog.all.length, 72);
      expect(AngelCatalog.choirs.length, 9);
      for (var i = 0; i < 72; i++) {
        expect(AngelCatalog.all[i].number, i + 1);
        // Il coro segue la posizione: otto per coro, senza eccezioni.
        expect(AngelCatalog.all[i].choir.name,
            AngelCatalog.choirs[i ~/ 8].name,
            reason: 'angelo ${i + 1} nel coro sbagliato');
      }
      // Ogni coro ha il suo arcangelo, tutti distinti.
      final arcangeli =
          AngelCatalog.choirs.map((c) => c.archangel).toSet();
      expect(arcangeli.length, 9);
      for (final c in AngelCatalog.choirs) {
        expect(c.domain.trim(), isNotEmpty);
      }
    });

    test('Ogni angelo ha la sua arte, e sono tutte diverse', () {
      final stems = <String>{};
      for (final a in AngelCatalog.all) {
        expect(a.name.trim(), isNotEmpty);
        stems.add(a.artStem);
        final file = File('assets/img/angeli/${a.artStem}.webp');
        expect(file.existsSync(), isTrue,
            reason: 'manca l\'arte di ${a.name}: ${a.artStem}.webp');
      }
      expect(stems.length, 72);
    });
  });

  group('Angelo Custode, dal grado del Sole', () {
    test('I confini dei cinque gradi', () {
      // Primo grado dell'Ariete: il primo angelo.
      expect(GuardianAngels.guardianFor(0).number, 1);
      expect(GuardianAngels.guardianFor(4.999).number, 1);
      // A cinque gradi esatti si passa al secondo.
      expect(GuardianAngels.guardianFor(5).number, 2);
      expect(GuardianAngels.guardianFor(9.999).number, 2);
      // Ultimo grado del cerchio: il settantaduesimo.
      expect(GuardianAngels.guardianFor(355).number, 72);
      expect(GuardianAngels.guardianFor(359.9).number, 72);
      // Il giro si chiude: 360 e' di nuovo zero.
      expect(GuardianAngels.guardianFor(360).number, 1);
      expect(GuardianAngels.guardianFor(365).number, 2);
      // Anche una longitudine negativa rientra nel cerchio.
      expect(GuardianAngels.guardianFor(-1).number, 72);
    });

    test('Ogni angelo governa cinque gradi, e coprono il cerchio intero', () {
      final visti = <int>{};
      for (var g = 0.0; g < 360.0; g += 0.5) {
        visti.add(GuardianAngels.guardianFor(g).number);
      }
      expect(visti.length, 72);
      for (final a in AngelCatalog.all) {
        expect(GuardianAngels.guardianFor(a.startDegree).number, a.number);
        expect(GuardianAngels.guardianFor(a.startDegree + 4.9).number,
            a.number);
      }
    });
  });

  group('Angelo del Cuore, dal giorno', () {
    test('Il primo giorno dell\'anno tocca al primo angelo', () {
      expect(GuardianAngels.heartFor(DateTime(1990, 1, 1)).number, 1);
      expect(GuardianAngels.heartFor(DateTime(1990, 1, 2)).number, 2);
      // Il ciclo si ripete ogni settantadue giorni.
      expect(GuardianAngels.heartFor(DateTime(1990, 3, 13)).number, 72);
      expect(GuardianAngels.heartFor(DateTime(1990, 3, 14)).number, 1);
    });

    test('Il giorno dell\'anno non si conta sottraendo istanti', () {
      // Il 31 dicembre e' il 365esimo giorno, il 366esimo negli anni bisestili.
      expect(GuardianAngels.dayOfYear(DateTime(1990, 12, 31)), 365);
      expect(GuardianAngels.dayOfYear(DateTime(2000, 12, 31)), 366);
      expect(GuardianAngels.dayOfYear(DateTime(2000, 2, 29)), 60);
      expect(GuardianAngels.dayOfYear(DateTime(1990, 3, 1)), 60);
      expect(GuardianAngels.dayOfYear(DateTime(2000, 3, 1)), 61);

      // Il cambio dell'ora legale non sposta il giorno. In Italia l'ora legale
      // del 1990 comincia il 25 marzo: quella giornata dura ventitre' ore, e
      // una differenza fra istanti la conterebbe come giorno mancante.
      expect(GuardianAngels.dayOfYear(DateTime(1990, 3, 24)), 83);
      expect(GuardianAngels.dayOfYear(DateTime(1990, 3, 25)), 84);
      expect(GuardianAngels.dayOfYear(DateTime(1990, 3, 26)), 85);
      // E lo stesso al ritorno all'ora solare, il 30 settembre, di venticinque
      // ore: i giorni restano consecutivi.
      expect(GuardianAngels.dayOfYear(DateTime(1990, 9, 29)), 272);
      expect(GuardianAngels.dayOfYear(DateTime(1990, 9, 30)), 273);
      expect(GuardianAngels.dayOfYear(DateTime(1990, 10, 1)), 274);
    });

    test('Il cambio d\'anno riparte dal primo', () {
      expect(GuardianAngels.heartFor(DateTime(1989, 12, 31)).number,
          ((365 - 1) % 72) + 1);
      expect(GuardianAngels.heartFor(DateTime(1990, 1, 1)).number, 1);
    });
  });

  group('Angelo dell\'Intelletto, dall\'ora', () {
    test('Venti minuti per angelo, dai confini', () {
      expect(GuardianAngels.intellectFor(0, 0)!.number, 1);
      expect(GuardianAngels.intellectFor(0, 19)!.number, 1);
      // A 00:20 esatti cambia.
      expect(GuardianAngels.intellectFor(0, 20)!.number, 2);
      expect(GuardianAngels.intellectFor(0, 39)!.number, 2);
      expect(GuardianAngels.intellectFor(0, 40)!.number, 3);
      // Un'ora vale tre angeli.
      expect(GuardianAngels.intellectFor(1, 0)!.number, 4);
      expect(GuardianAngels.intellectFor(12, 0)!.number, 37);
      // L'ultimo minuto del giorno tocca al settantaduesimo.
      expect(GuardianAngels.intellectFor(23, 40)!.number, 72);
      expect(GuardianAngels.intellectFor(23, 59)!.number, 72);
    });

    test('I settantadue coprono la giornata senza buchi', () {
      final visti = <int>{};
      for (var m = 0; m < 1440; m++) {
        visti.add(GuardianAngels.intellectFor(m ~/ 60, m % 60)!.number);
      }
      expect(visti.length, 72);
    });

    test('Senza ora non esiste', () {
      expect(GuardianAngels.intellectFor(null, null), isNull);
      expect(GuardianAngels.intellectFor(null, 30), isNull);
    });
  });

  group('I tre insieme', () {
    test('Con l\'ora sono tre, senza sono due', () {
      final conOra = GuardianAngels.forBirth(BirthDetails(
        date: DateTime(1985, 3, 3),
        time: const TimeOfDay(hour: 7, minute: 20),
      ));
      expect(conOra.hasIntellect, isTrue);
      expect(conOra.known.length, 3);
      expect(conOra.minuteOfDay, 7 * 60 + 20);

      final senzaOra =
          GuardianAngels.forBirth(BirthDetails(date: DateTime(1985, 3, 3)));
      expect(senzaOra.hasIntellect, isFalse);
      expect(senzaOra.intellect, isNull);
      expect(senzaOra.known.length, 2);
      // Custode e Cuore restano quelli, perche' non dipendono dall'ora.
      expect(senzaOra.heart.number, conOra.heart.number);
    });

    test('Il Custode viene dal cielo, non dalla data di calendario', () {
      // Il 3 marzo il Sole sta attorno ai 342 gradi, cioe' nei Pesci: l'angelo
      // e' fra i tre che governano quella fascia, e non e' quello del giorno
      // dell'anno, che sarebbe il 62esimo.
      final t = GuardianAngels.forBirth(BirthDetails(
        date: DateTime(1985, 3, 3),
        time: const TimeOfDay(hour: 7, minute: 20),
      ));
      expect(t.sunLongitude, greaterThan(335));
      expect(t.sunLongitude, lessThan(350));
      expect(t.guardian.number, isNot(t.heart.number));
      expect(t.dayOfYear, 62);
      expect(t.heart.number, 62);
    });
  });
}
