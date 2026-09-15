import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:flutter_test/flutter_test.dart';

/// La fase lunare, con un motore solo e i confini nell'ora giusta.
///
/// C'erano DUE motori. `MoonPhase.forDate` partiva dal mese sinodico MEDIO,
/// cioe' da una luna nuova di riferimento piu' una durata costante, mentre
/// `Celestial.moonIllumination` calcola l'elongazione vera fra Luna e Sole. Il
/// mese medio sbaglia l'istante della sizigia fino a mezza giornata, perche'
/// l'orbita non e' un cerchio percorso a velocita' costante.
///
/// Il difetto che si vedeva era peggiore, ed era nel NOME: la soglia valeva
/// 0,035 di ciclo, cioe' piu' o meno un giorno intero, quindi il nome "Luna
/// piena" restava a schermo per **cinquanta ore**. La sera del giorno dopo la
/// sizigia l'app dichiarava ancora Luna piena, e chi controllava con
/// un'effemeride vedeva che era stata il giorno prima.
void main() {
  /// Le sizigie note dalle effemeridi, in UTC.
  const pieneNote = [
    (2024, 1, 25, 17, 54),
    (2024, 8, 19, 18, 26),
    (2025, 3, 14, 6, 55),
  ];
  const nuoveNote = [
    (2024, 2, 9, 22, 59),
    (2025, 1, 29, 12, 36),
  ];

  DateTime d0((int, int, int, int, int) t) =>
      DateTime.utc(t.$1, t.$2, t.$3, t.$4, t.$5);

  group('Un motore solo, quello vero', () {
    test('La fase coincide con l\'elongazione, non col mese medio', () {
      // La posizione nel ciclo dichiarata da MoonPhase deve essere quella che
      // discende dall'elongazione vera: un motore, non due che si somigliano.
      for (var g = 0; g < 60; g++) {
        final d = DateTime.utc(2026, 6, 1).add(Duration(hours: g * 11));
        final fase = MoonPhase.forDate(d);
        final vero = Celestial.moonIllumination(Celestial.julianDay(d));
        expect(fase.illumination, closeTo(vero.fraction, 0.001),
            reason: 'a ${d.toIso8601String()} i due motori divergono: '
                '${fase.illumination.toStringAsFixed(4)} contro '
                '${vero.fraction.toStringAsFixed(4)}');
        expect(fase.waxing, vero.waxing,
            reason: 'a ${d.toIso8601String()} i due motori non concordano '
                'nemmeno sul crescente');
      }
    });

    test('Il mese sinodico medio non esiste piu\' nel codice', () {
      // Rete strutturale, dichiarata come tale: il comportamento e' misurato
      // dalla prova qui sopra, questa protegge dalla ricomparsa della causa.
      final codice = File('lib/core/astro/moon_phase.dart')
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      expect(codice.contains('29.530588853'), isFalse,
          reason: 'la durata media del mese sinodico e\' tornata nel codice, '
              'e con quella torna l\'errore di mezza giornata');
      expect(codice.contains('_referenceNewMoonJd'), isFalse,
          reason: 'la luna nuova di riferimento e\' tornata nel codice');
    });
  });

  group('Le sizigie cadono nell\'ora giusta', () {
    for (final t in pieneNote) {
      test('Luna piena il ${t.$3}/${t.$2}/${t.$1}', () {
        final fase = MoonPhase.forDate(d0(t));
        expect(fase.illumination, greaterThan(0.995),
            reason: 'all\'istante della sizigia il disco non risulta pieno');
        expect(fase.italianName, 'Luna piena');
      });
    }

    for (final t in nuoveNote) {
      test('Luna nuova il ${t.$3}/${t.$2}/${t.$1}', () {
        final fase = MoonPhase.forDate(d0(t));
        expect(fase.illumination, lessThan(0.005),
            reason: 'all\'istante della sizigia il disco non risulta buio');
        expect(fase.italianName, 'Luna nuova');
      });
    }
  });

  group('Il confine cade nell\'ora, non nel giorno', () {
    /// Quanti campioni a passo orario portano un dato nome, attorno a una
    /// sizigia.
    ///
    /// Sono campioni, non durata continua: una finestra di dodici ore per lato
    /// ne contiene ventiquattro piu' quello centrale, cioe' venticinque, e la
    /// velocita' orbitale variabile puo' aggiungerne uno. Il numero che conta e'
    /// l'ordine di grandezza: ventisei significa un giorno, quarantanove
    /// significavano due.
    int oreDelNome(DateTime attorno, String nome) {
      var ore = 0;
      for (var h = -96; h <= 96; h++) {
        if (MoonPhase.forDate(attorno.add(Duration(hours: h))).italianName ==
            nome) {
          ore++;
        }
      }
      return ore;
    }

    test('"Luna piena" non dura piu\' di un giorno', () {
      for (final t in pieneNote) {
        final ore = oreDelNome(d0(t), 'Luna piena');
        expect(ore, lessThanOrEqualTo(27),
            reason: 'attorno al ${t.$3}/${t.$2}/${t.$1} il nome "Luna piena" '
                'resta per $ore ore: piu\' di un giorno, quindi lo si legge '
                'anche il giorno dopo la sizigia');
        expect(ore, greaterThanOrEqualTo(20),
            reason: 'la finestra e\' cosi\' stretta che il nome quasi non '
                'compare: $ore ore');
      }
    });

    test('"Luna nuova" non dura piu\' di un giorno', () {
      for (final t in nuoveNote) {
        final ore = oreDelNome(d0(t), 'Luna nuova');
        expect(ore, lessThanOrEqualTo(27),
            reason: 'il nome "Luna nuova" resta per $ore ore');
      }
    });

    test('Il giorno dopo la sizigia il nome e\' cambiato', () {
      // E' esattamente il caso che Mauro ha visto: piena ieri, e l'app che
      // dichiara ancora Luna piena oggi.
      for (final t in pieneNote) {
        final dopo = d0(t).add(const Duration(hours: 24));
        expect(MoonPhase.forDate(dopo).italianName, isNot('Luna piena'),
            reason: 'ventiquattro ore dopo la sizigia del '
                '${t.$3}/${t.$2}/${t.$1} l\'app dichiara ancora Luna piena');
      }
    });

    test('La sizigia di luglio 2026, quella che Mauro ha controllato', () {
      // Il massimo di illuminazione cade il 29; il 30 il nome deve essere
      // cambiato, perche' la Luna e' gia' calante.
      final il30 = MoonPhase.forDate(DateTime.utc(2026, 7, 30, 20));
      expect(il30.italianName, isNot('Luna piena'),
          reason: 'il 30 luglio sera l\'app dichiara ancora Luna piena, '
              'mentre la sizigia e\' stata il 29');
      expect(il30.waxing, isFalse, reason: 'il 30 la Luna e\' calante');
    });
  });

  group('La nomenclatura vive in un punto solo', () {
    test('phaseNameOf del passaporto da lo stesso nome di MoonPhase', () {
      // Le porte della nomenclatura erano DUE: MoonPhase con soglie sulla
      // posizione nel ciclo, e phaseNameOf con soglie sulla frazione
      // illuminata. La stessa Luna prendeva due nomi a seconda di chi la
      // chiedeva, e nessuno dei due sembrava sbagliato.
      var confronti = 0;
      for (var h = 0; h < 24 * 40; h += 7) {
        final d = DateTime.utc(2026, 5, 1).add(Duration(hours: h));
        final luce = Celestial.moonIllumination(Celestial.julianDay(d));
        expect(phaseNameOf(luce), MoonPhase.forDate(d).italianName,
            reason: 'a ${d.toIso8601String()} il passaporto e il Santuario '
                'chiamano la stessa Luna con due nomi diversi');
        confronti++;
      }
      expect(confronti, greaterThan(100),
          reason: 'il confronto ha coperto troppo poche date per valere');
    });

    test('Il nome nasce dal ciclo e non dalla sola luce', () {
      // Due istanti con la STESSA luce, uno crescente e uno calante, devono
      // avere nomi diversi: e' cio' che una soglia sulla sola illuminazione non
      // sa distinguere.
      MoonPhase? crescente;
      MoonPhase? calante;
      for (var h = 0; h < 24 * 30; h++) {
        final f =
            MoonPhase.forDate(DateTime.utc(2026, 5, 1).add(Duration(hours: h)));
        if ((f.illumination - 0.5).abs() < 0.01) {
          if (f.waxing) {
            crescente ??= f;
          } else {
            calante ??= f;
          }
        }
      }
      expect(crescente, isNotNull);
      expect(calante, isNotNull);
      expect(crescente!.italianName, isNot(calante!.italianName),
          reason: 'a mezza luce crescente e calante ricevono lo stesso nome: '
              'il nome sta guardando la luce invece del ciclo');
    });
  });
}
