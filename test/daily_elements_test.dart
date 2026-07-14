import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:flutter_test/flutter_test.dart';

/// La selezione deterministica dell'elemento della fascia oraria attiva.
void main() {
  DateTime at(int h, int m) => DateTime(2026, 7, 14, h, m);

  group('Elemento corrente per fascia oraria', () {
    test('Prima dell\'alba resta la Runa della sera precedente', () {
      expect(DailyElements.current(at(0, 0)), DailyElement.rune);
      expect(DailyElements.current(at(6, 59)), DailyElement.rune);
    });

    test('Il Rito dell\'Alba tiene la fascia dalle 7:00 alle 10:30', () {
      expect(DailyElements.current(at(7, 0)), DailyElement.dawn);
      expect(DailyElements.current(at(9, 0)), DailyElement.dawn);
      expect(DailyElements.current(at(10, 29)), DailyElement.dawn);
    });

    test('Il Soffio del Destino dalle 10:30 alle 12:30', () {
      expect(DailyElements.current(at(10, 30)), DailyElement.breath);
      expect(DailyElements.current(at(12, 29)), DailyElement.breath);
    });

    test('L\'Oracolo del Giorno dalle 12:30 alle 18:00', () {
      expect(DailyElements.current(at(12, 30)), DailyElement.oracle);
      expect(DailyElements.current(at(17, 59)), DailyElement.oracle);
    });

    test('La Runa del Tramonto dalle 18:00 a mezzanotte', () {
      expect(DailyElements.current(at(18, 0)), DailyElement.rune);
      expect(DailyElements.current(at(23, 30)), DailyElement.rune);
    });

    test('E deterministica: stessa ora, stesso elemento', () {
      expect(DailyElements.current(at(12, 45)),
          DailyElements.current(at(12, 45)));
    });
  });

  group('Colore della Guida e deep-link', () {
    test('Alba oro senza Guida fissa, gli altri seguono la loro Guida', () {
      expect(DailyElement.dawn.guide, isNull);
      expect(DailyElement.breath.guide, Maestro.aura);
      expect(DailyElement.oracle.guide, Maestro.medora);
      expect(DailyElement.rune.guide, Maestro.caligo);
    });

    test('L\'id serve al deep-link e torna all\'elemento', () {
      for (final e in DailyElement.values) {
        expect(DailyElement.fromId(e.id), e);
      }
      expect(DailyElement.fromId('inesistente'), isNull);
    });
  });

  group('Orario e descrizione dell\'elemento', () {
    test('L\'orario segue l\'ancora della fascia, nel formato h:mm', () {
      expect(DailyElement.dawn.clockLabel, '7:00');
      expect(DailyElement.breath.clockLabel, '10:30');
      expect(DailyElement.oracle.clockLabel, '12:30');
      expect(DailyElement.rune.clockLabel, '18:00');
    });

    test('Ogni elemento ha una descrizione per il popup informativo', () {
      for (final e in DailyElement.values) {
        expect(e.description, isNotEmpty);
      }
    });
  });

  group('Maestro attivo dell\'elemento', () {
    test('Gli elementi fissi seguono la loro Guida', () {
      final now = at(12, 0);
      expect(DailyElements.maestroFor(DailyElement.breath, now), Maestro.aura);
      expect(DailyElements.maestroFor(DailyElement.oracle, now), Maestro.medora);
      expect(DailyElements.maestroFor(DailyElement.rune, now), Maestro.caligo);
    });

    test('Il Rito dell\'Alba segue il Maestro di turno del giorno', () {
      final now = at(8, 0);
      expect(DailyElements.maestroFor(DailyElement.dawn, now),
          DailyRituals.dawnMaestro(now));
    });
  });
}
