import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter_test/flutter_test.dart';

/// La selezione deterministica dell'elemento della fascia oraria attiva.
///
/// **Dall'ordine DT i doni sono quattro**, voce 01: l'Arcano dell'Alba prende
/// il posto del Rito dell'Alba e dell'Arcano del Giorno, il Soffio passa alle
/// tredici (voce 14) e il Sigillo del Sogno va a Medora (voce 15).
void main() {
  DateTime at(int h, int m) => DateTime(2026, 7, 14, h, m);

  group('Elemento corrente per fascia oraria', () {
    test('Quattro appuntamenti giornalieri, nell\'ordine della giornata', () {
      expect(DailyElement.values, [
        DailyElement.dawn,
        DailyElement.breath,
        DailyElement.rune,
        DailyElement.night,
      ]);
      final ancore = DailyElement.values.map((e) => e.anchorMinutes).toList();
      expect(ancore, [...ancore]..sort(),
          reason: 'l\'ordine di dichiarazione e\' l\'ordine delle ore');
    });

    test('Prima dell\'alba la notte fonda resta al Sigillo del Sogno', () {
      expect(DailyElements.current(at(0, 0)), DailyElement.night);
      expect(DailyElements.current(at(6, 59)), DailyElement.night);
    });

    test('L\'Arcano dell\'Alba tiene la fascia dalle 7:00 alle 13:00', () {
      expect(DailyElements.current(at(7, 0)), DailyElement.dawn);
      expect(DailyElements.current(at(10, 30)), DailyElement.dawn);
      expect(DailyElements.current(at(12, 59)), DailyElement.dawn);
    });

    test('Il Soffio del Destino dalle 13:00 alle 18:30', () {
      expect(DailyElements.current(at(13, 0)), DailyElement.breath);
      expect(DailyElements.current(at(18, 29)), DailyElement.breath);
    });

    test('La Runa del Tramonto dalle 18:30 alle 22:30', () {
      expect(DailyElements.current(at(18, 30)), DailyElement.rune);
      expect(DailyElements.current(at(22, 29)), DailyElement.rune);
    });

    test('Il Sigillo del Sogno dalle 22:30 fino all\'alba', () {
      expect(DailyElements.current(at(22, 30)), DailyElement.night);
      expect(DailyElements.current(at(23, 30)), DailyElement.night);
    });

    test('E deterministica: stessa ora, stesso elemento', () {
      expect(
          DailyElements.current(at(12, 45)), DailyElements.current(at(12, 45)));
    });

    test(
        'ogni minuto del giorno appartiene al dono la cui ancora e\' l\'ultima '
        'passata, senza nomi scritti a mano', () {
      final perOra = [...DailyElement.values]
        ..sort((a, b) => a.anchorMinutes.compareTo(b.anchorMinutes));
      for (var minuto = 0; minuto < 24 * 60; minuto += 7) {
        final atteso = perOra.lastWhere((e) => e.anchorMinutes <= minuto,
            orElse: () => perOra.last);
        expect(DailyElements.current(at(minuto ~/ 60, minuto % 60)), atteso,
            reason: 'minuto $minuto');
      }
    });
  });

  group('Maestro, avviso e deep-link', () {
    test('ogni dono ha il suo Maestro: Medora all\'alba e al Sogno', () {
      expect(DailyElement.dawn.guide, Maestro.medora);
      expect(DailyElement.breath.guide, Maestro.aura);
      expect(DailyElement.rune.guide, Maestro.caligo);
      expect(DailyElement.night.guide, Maestro.medora);
    });

    test('il Sigillo del Sogno e\' di Medora in ogni giorno dell\'anno', () {
      for (var giorno = 0; giorno < 366; giorno++) {
        final d = DateTime(2026, 1, 1).add(Duration(days: giorno));
        expect(DailyElements.maestroFor(DailyElement.night, d), Maestro.medora);
        expect(DailyElements.maestroFor(DailyElement.dawn, d), Maestro.medora);
      }
    });

    test('il numero dell\'avviso e\' del dono, unico, e il due non torna', () {
      final numeri = DailyElement.values.map((e) => e.numeroDellAvviso);
      expect(numeri.toSet(), hasLength(DailyElement.values.length));
      expect(numeri, isNot(contains(2)),
          reason: 'il 2 era dell\'Arcano del Giorno');
      expect(DailyElement.dawn.numeroDellAvviso, 0);
      expect(DailyElement.breath.numeroDellAvviso, 1);
      expect(DailyElement.rune.numeroDellAvviso, 3);
      expect(DailyElement.night.numeroDellAvviso, 4);
    });

    test('L\'id serve al deep-link e torna all\'elemento', () {
      for (final e in DailyElement.values) {
        expect(DailyElement.fromId(e.id), e);
      }
      expect(DailyElement.fromId('oracle'), isNull,
          reason: 'un avviso vecchio dell\'Arcano del Giorno non apre niente');
      expect(DailyElement.fromId('inesistente'), isNull);
    });
  });

  group('Notifiche push di default', () {
    test('Di default notificano l\'Arcano dell\'Alba e il Sigillo del Sogno',
        () {
      expect(DailyElements.defaultPushElements, [
        DailyElement.dawn,
        DailyElement.night,
      ]);
    });
  });

  group('Orario, nome e descrizione dell\'elemento', () {
    test('L\'orario segue l\'ancora della fascia, nel formato h:mm', () {
      expect(DailyElement.dawn.clockLabel, '7:00');
      expect(DailyElement.breath.clockLabel, '13:00');
      expect(DailyElement.rune.clockLabel, '18:30');
      expect(DailyElement.night.clockLabel, '22:30');
    });

    test(
        'i nomi a video: l\'Arcano dell\'Alba e nessun dono che se ne e\' '
        'andato', () {
      expect(DailyElement.dawn.title, 'Arcano dell\'Alba');
      final titoli = DailyElement.values.map((e) => e.title).join(' ');
      expect(titoli, isNot(contains('Rito dell\'Alba')));
      expect(titoli, isNot(contains('Arcano del Giorno')));
    });

    test('l\'elenco in una frase e il numero in lettere vengono dai doni', () {
      expect(
          DailyElements.elencoInFrase,
          'l\'Arcano dell\'Alba, il Soffio del Destino, la Runa del Tramonto '
          'e il Sigillo del Sogno');
      expect(DailyElements.quantiInLettere, 'quattro');
    });

    test('Ogni elemento ha una descrizione per il popup informativo', () {
      for (final e in DailyElement.values) {
        expect(e.description, isNotEmpty);
      }
    });
  });
}
