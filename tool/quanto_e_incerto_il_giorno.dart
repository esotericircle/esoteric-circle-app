import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:flutter_test/flutter_test.dart';

/// DI QUANTI GIORNI E' INCERTO IL GIORNO DI UN TRANSITO, corpo per corpo.
///
/// **Serve a decidere una regola di lingua, e la decide su un numero.** Un
/// oroscopo che dice "oggi Saturno tocca esatto il tuo Sole" promette una
/// precisione che il motore non ha: lo scarto misurato contro JPL Horizons e'
/// 0,1414 gradi e Saturno percorre tre centesimi di grado al giorno. Questo
/// programma stampa il conto per tutti i corpi, cosi' la soglia oltre la quale
/// la lingua deve diventare larga e' misurata invece che scelta.
///
/// ```
/// flutter test tool/quanto_e_incerto_il_giorno.dart
/// ```
void main() {
  test('Quanti giorni di incertezza sul giorno esatto, corpo per corpo', () {
    // Tre date distanti, perche' la velocita' di un pianeta cambia lungo
    // l'orbita e un solo giorno darebbe un solo numero.
    final giorni = <DateTime>[
      DateTime.utc(2026, 2, 14),
      DateTime.utc(2026, 8, 5),
      DateTime.utc(2027, 5, 30),
    ];
    stdout.writeln('corpo      scarto°   °/giorno        giorni di incertezza');
    for (final corpo in CorpoCeleste.values) {
      final valori = <double>[];
      for (final g in giorni) {
        valori.add(Effemeridi.giorniDiIncertezza(corpo, Celestial.julianDay(g)));
      }
      valori.sort();
      final jd = Celestial.julianDay(giorni[1]);
      stdout.writeln('${corpo.nome.padRight(10)} '
          '${Effemeridi.scartoMisurato[corpo]!.toStringAsFixed(4).padLeft(7)} '
          '${Effemeridi.velocitaGiornaliera(corpo, jd).abs().toStringAsFixed(4).padLeft(9)} '
          '   min ${valori.first.toStringAsFixed(2).padLeft(8)}  '
          'max ${valori.last.toStringAsFixed(2).padLeft(8)}');
    }
  });
}
