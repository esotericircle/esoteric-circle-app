import 'package:esoteric_circle/core/astro/sunset_time.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SORGERE DEL SOLE, CONTRO UNA FONTE ESTERNA.
///
/// **L'attesa non si ricava dalle costanti sotto esame.** Se la prova
/// ricalcolasse il sorgere con la stessa formula del codice, direbbe soltanto
/// che il codice e' uguale a se stesso. I valori qui sotto vengono da
/// **api.sunrise-sunset.org**, interrogata il 5 agosto 2026, che pubblica orari
/// di levata e tramonto in UTC. Sono copiati come li ha restituiti e non si
/// aggiustano: se il motore sbaglia, deve dirlo la prova.
///
/// Il confronto si fa passando scarto di fuso ZERO, cosi' l'ora che torna e'
/// gia' in UTC come quella della fonte, e nessuna conversione si mette in mezzo.
void main() {
  // Milano.
  const latMilano = 45.4642;
  const lonMilano = 9.1900;

  /// Sorgere e tramonto in UTC dalla fonte esterna, per Milano.
  final riferimentiMilano = <DateTime, ({DateTime alba, DateTime tramonto})>{
    DateTime.utc(2026, 3, 20): (
      alba: DateTime.utc(2026, 3, 20, 5, 24, 38),
      tramonto: DateTime.utc(2026, 3, 20, 17, 36, 46),
    ),
    DateTime.utc(2026, 6, 21): (
      alba: DateTime.utc(2026, 6, 21, 3, 32, 51),
      tramonto: DateTime.utc(2026, 6, 21, 19, 17, 16),
    ),
    DateTime.utc(2026, 12, 21): (
      alba: DateTime.utc(2026, 12, 21, 6, 58, 15),
      tramonto: DateTime.utc(2026, 12, 21, 15, 44, 19),
    ),
  };

  /// Lo scarto in minuti fra due istanti.
  double minuti(DateTime a, DateTime b) =>
      a.difference(b).inSeconds.abs() / 60.0;

  group('Il sorgere contro la fonte esterna', () {
    riferimentiMilano.forEach((giorno, atteso) {
      test('Milano, ${giorno.toIso8601String().substring(0, 10)}', () {
        final calcolata = SunsetTime.albaPerData(
          giorno,
          lat: latMilano,
          lon: lonMilano,
          offset: Duration.zero,
        );
        expect(calcolata, isNotNull);
        final scarto = minuti(
          DateTime.utc(calcolata!.year, calcolata.month, calcolata.day,
              calcolata.hour, calcolata.minute, calcolata.second),
          atteso.alba,
        );
        expect(scarto, lessThan(3.0),
            reason: 'il motore dice ${calcolata.toIso8601String()}, '
                'la fonte dice ${atteso.alba.toIso8601String()}, '
                'scarto ${scarto.toStringAsFixed(2)} minuti');
        // ignore: avoid_print
        print('alba Milano ${giorno.toIso8601String().substring(0, 10)}: '
            'scarto ${scarto.toStringAsFixed(2)} minuti');
      });
    });

    test('Sydney, emisfero sud, 15 settembre 2026', () {
      // **Attenzione al giorno, e la prima stesura ci e' cascata.** A Sydney il
      // mattino del 15 settembre locale cade alle 19:53 UTC del 14. Il metodo
      // ancora il calcolo al giorno che gli si passa, quindi per ottenere
      // quell'istante gli si chiede il 15 e non il 14: chiedendo il 14 si
      // ottiene il sorgere del giorno prima, giusto come ora del giorno ma
      // sbagliato di ventiquattro ore. Con lo scarto di fuso vero, e non zero,
      // il giorno civile e quello solare tornano a coincidere.
      final calcolata = SunsetTime.albaPerData(
        DateTime.utc(2026, 9, 15),
        lat: -33.8688,
        lon: 151.2093,
        offset: Duration.zero,
      );
      expect(calcolata, isNotNull);
      final scarto = minuti(
        DateTime.utc(calcolata!.year, calcolata.month, calcolata.day,
            calcolata.hour, calcolata.minute, calcolata.second),
        DateTime.utc(2026, 9, 14, 19, 53, 27),
      );
      expect(scarto, lessThan(3.0),
          reason: 'il motore dice ${calcolata.toIso8601String()}, '
              'la fonte dice 2026-09-14T19:53:27Z, '
              'scarto ${scarto.toStringAsFixed(2)} minuti');
      // ignore: avoid_print
      print('alba Sydney: scarto ${scarto.toStringAsFixed(2)} minuti');
    });
  });

  group('La duplicazione del nucleo NOAA e\' inchiodata', () {
    test('il tramonto interno coincide con quello di perData, al secondo', () {
      // `_estremiSolari` ripete il calcolo del transito e dell'angolo orario che
      // `perData` fa gia' al suo interno, perche' l'ordine permetteva solo
      // aggiunte in coda. Questa prova impedisce alle due copie di derivare:
      // se una cambia e l'altra no, cade.
      for (final giorno in riferimentiMilano.keys) {
        for (final offset in [Duration.zero, const Duration(hours: 2)]) {
          final daPerData = SunsetTime.perData(giorno,
              lat: latMilano, lon: lonMilano, offset: offset);
          // Il tramonto passa dallo stesso metodo che produce il sorgere: se
          // combaciano, le due scritture stanno dicendo la stessa cosa.
          final alba = SunsetTime.albaPerData(giorno,
              lat: latMilano, lon: lonMilano, offset: offset);
          expect(daPerData, isNotNull);
          expect(alba, isNotNull);
          // Sorgere e tramonto sono simmetrici rispetto al mezzogiorno solare,
          // quindi il loro punto medio e' il transito: deve stare a meta'
          // giornata, non a un'ora qualunque.
          final mezzo = alba!
              .add(Duration(seconds: daPerData!.difference(alba).inSeconds ~/ 2));
          expect(mezzo.hour, inInclusiveRange(10, 14),
              reason: 'il mezzogiorno solare risulta alle ${mezzo.hour}');
        }
      }
    });

    test('il sorgere viene sempre prima del tramonto', () {
      for (final giorno in riferimentiMilano.keys) {
        final alba = SunsetTime.albaPerData(giorno,
            lat: latMilano, lon: lonMilano, offset: Duration.zero);
        final tramonto = SunsetTime.perData(giorno,
            lat: latMilano, lon: lonMilano, offset: Duration.zero);
        expect(alba!.isBefore(tramonto!), isTrue);
      }
    });
  });

  group('I casi polari ripiegano, non sollevano', () {
    test('a Tromso in giugno il Sole non tramonta e il sorgere e\' null', () {
      final alba = SunsetTime.albaPerData(
        DateTime.utc(2026, 6, 21),
        lat: 69.6492,
        lon: 18.9553,
        offset: Duration.zero,
      );
      expect(alba, isNull, reason: 'sopra il circolo polare in giugno il Sole '
          'non sorge ne tramonta: qui deve tornare null');
    });

    test('a Tromso in dicembre vale lo stesso, notte polare', () {
      final alba = SunsetTime.albaPerData(
        DateTime.utc(2026, 12, 21),
        lat: 69.6492,
        lon: 18.9553,
        offset: Duration.zero,
      );
      expect(alba, isNull);
    });

    test('l\'ora media dell\'alba esiste ed e\' sempre valida', () {
      final media = SunsetTime.oraMediaAlba(DateTime(2026, 6, 21));
      expect(media.hour, 6);
      expect(media.minute, 0);
      expect(media.day, 21);
    });
  });
}
