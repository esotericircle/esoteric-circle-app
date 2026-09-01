import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:flutter_test/flutter_test.dart';

/// La selezione deterministica dell'elemento della fascia oraria attiva.
void main() {
  DateTime at(int h, int m) => DateTime(2026, 7, 14, h, m);

  group('Elemento corrente per fascia oraria', () {
    test('Cinque appuntamenti giornalieri, nell\'ordine della striscia', () {
      expect(DailyElement.values, [
        DailyElement.dawn,
        DailyElement.breath,
        DailyElement.oracle,
        DailyElement.rune,
        DailyElement.night,
      ]);
    });

    test('Prima dell\'alba la notte fonda resta al Rito della Buonanotte', () {
      expect(DailyElements.current(at(0, 0)), DailyElement.night);
      expect(DailyElements.current(at(6, 59)), DailyElement.night);
    });

    test('Il Rito dell\'Alba tiene la fascia dalle 7:00 alle 10:30', () {
      expect(DailyElements.current(at(7, 0)), DailyElement.dawn);
      expect(DailyElements.current(at(9, 0)), DailyElement.dawn);
      expect(DailyElements.current(at(10, 29)), DailyElement.dawn);
    });

    test('Il Soffio del Destino dalle 10:30 alle 13:00', () {
      expect(DailyElements.current(at(10, 30)), DailyElement.breath);
      expect(DailyElements.current(at(12, 59)), DailyElement.breath);
    });

    test('L\'Oracolo del Giorno dalle 13:00 alle 18:30', () {
      expect(DailyElements.current(at(13, 0)), DailyElement.oracle);
      expect(DailyElements.current(at(18, 29)), DailyElement.oracle);
    });

    test('La Runa del Tramonto dalle 18:30 alle 22:30', () {
      expect(DailyElements.current(at(18, 30)), DailyElement.rune);
      expect(DailyElements.current(at(22, 29)), DailyElement.rune);
    });

    test('Il Rito della Buonanotte dalle 22:30 fino all\'alba', () {
      expect(DailyElements.current(at(22, 30)), DailyElement.night);
      expect(DailyElements.current(at(23, 30)), DailyElement.night);
    });

    test('E deterministica: stessa ora, stesso elemento', () {
      expect(
          DailyElements.current(at(12, 45)), DailyElements.current(at(12, 45)));
    });
  });

  group('Colore del Maestro e deep-link', () {
    test('Alba e Notte oro senza Maestro fisso, gli altri seguono il loro', () {
      expect(DailyElement.dawn.guide, isNull);
      expect(DailyElement.night.guide, isNull);
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

  group('Notifiche push di default', () {
    test('Di default notificano solo Alba, Oracolo e Sogno', () {
      expect(DailyElement.dawn.pushByDefault, isTrue);
      expect(DailyElement.oracle.pushByDefault, isTrue);
      expect(DailyElement.night.pushByDefault, isTrue);
      expect(DailyElement.breath.pushByDefault, isFalse);
      expect(DailyElement.rune.pushByDefault, isFalse);
    });

    test('L\'elenco dei push di default e\' esattamente i tre riti', () {
      expect(DailyElements.defaultPushElements, [
        DailyElement.dawn,
        DailyElement.oracle,
        DailyElement.night,
      ]);
    });
  });

  group('Orario e descrizione dell\'elemento', () {
    test('L\'orario segue l\'ancora della fascia, nel formato h:mm', () {
      expect(DailyElement.dawn.clockLabel, '7:00');
      expect(DailyElement.breath.clockLabel, '10:30');
      expect(DailyElement.oracle.clockLabel, '13:00');
      expect(DailyElement.rune.clockLabel, '18:30');
      expect(DailyElement.night.clockLabel, '22:30');
    });

    test('Ogni elemento ha una descrizione per il popup informativo', () {
      for (final e in DailyElement.values) {
        expect(e.description, isNotEmpty);
      }
    });
  });

  group('Maestro attivo dell\'elemento', () {
    test('Gli elementi fissi seguono il loro Maestro', () {
      final now = at(12, 0);
      expect(DailyElements.maestroFor(DailyElement.breath, now), Maestro.aura);
      expect(
          DailyElements.maestroFor(DailyElement.oracle, now), Maestro.medora);
      expect(DailyElements.maestroFor(DailyElement.rune, now), Maestro.caligo);
    });

    test('Alba e Sogno seguono il Maestro di turno del giorno', () {
      final now = at(8, 0);
      expect(DailyElements.maestroFor(DailyElement.dawn, now),
          DailyRituals.dawnMaestro(now));
      expect(DailyElements.maestroFor(DailyElement.night, now),
          DailyRituals.dawnMaestro(now));
    });
  });
}
