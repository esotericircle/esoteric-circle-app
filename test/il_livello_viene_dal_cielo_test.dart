// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/il_cielo_del_segno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';

/// **IL LIVELLO DI OGNI SCHEDA VIENE DAL CIELO.** Ordine ES voce 28, 29
/// settembre 2026.
///
/// Il fatto: l'indicatore era `2 + (seed % 4)`, una hash su segno, giorno,
/// anno e dominio. Due prove:
/// - senza carta, per ogni segno e dominio, trenta giorni: i giorni con la
///   Luna nella stessa casa solare danno lo stesso livello. Con la hash i
///   livelli cambiavano con la data anche a cielo uguale;
/// - con la carta, tre carte dello stesso segno nello stesso giorno danno
///   livelli diversi, e la riga nomina i passaggi che li fanno.
void main() {
  test('senza carta: a cielo uguale livello uguale, 48 schede su 48', () {
    final dallaData = <String>[];
    var schede = 0;
    for (final segno in Zodiac.values) {
      for (final dominio in HoroscopeDomain.values) {
        schede++;
        final perCasa = <int, Set<int>>{};
        for (var g = 250; g < 280; g++) {
          final carta = Horoscope.cardFor(
              sign: segno, dayOfYear: g, year: 2026, domain: dominio);
          final quando = DateTime.utc(2026).add(Duration(days: g, hours: 12));
          // Il cielo del giorno senza carta: la casa solare della Luna e
          // quella del corpo del dominio (vista sul Realme, ordine ES).
          final casa = IlCieloDelSegno.casaSolare(segno,
                      IlSegnoDelCielo.delCorpo(CorpoCeleste.luna, quando)) *
                  100 +
              IlCieloDelSegno.casaSolare(
                  segno,
                  IlSegnoDelCielo.delCorpo(
                      IlCieloDelSegno.corpoDi[dominio]!, quando));
          perCasa.putIfAbsent(casa, () => {}).add(carta.indicator);
          expect(carta.rigaDelLivello, contains('Luna di oggi'));
          // E il corpo del dominio, visto sul Realme: con la sola Luna le
          // quattro schede avevano lo stesso livello e la stessa riga.
          final corpo = IlCieloDelSegno.corpoDi[dominio]!;
          expect(
              carta.rigaDelLivello,
              contains(
                  '${corpo == CorpoCeleste.sole ? 'il Sole' : corpo.nome} è in'));
        }
        if (perCasa.values.any((s) => s.length > 1)) {
          dallaData.add('${segno.id} ${dominio.name}: $perCasa');
        }
      }
    }
    cardinaleMinimo(schede, 48, cosa: 'schede senza carta');
    print('ORDINE ES VOCE 28: schede il cui livello non dipende dal cielo '
        '${dallaData.length} su $schede');
    expect(dallaData, isEmpty, reason: dallaData.take(5).join('\n'));
  });

  test('con la carta: tre carte dello stesso segno, tre cieli', () {
    NatalChart carta(double luna, double venere, double marte) => NatalChart(
          sunSign: Zodiac.pisces,
          planets: [
            const PlanetPosition(
                id: 'sun',
                name: 'Sole',
                glyph: '☉',
                longitude: 354.4,
                sign: Zodiac.pisces),
            PlanetPosition(
                id: 'moon',
                name: 'Luna',
                glyph: '☽',
                longitude: luna,
                sign: Zodiac.values[(luna ~/ 30) % 12]),
            PlanetPosition(
                id: 'venus',
                name: 'Venere',
                glyph: '♀',
                longitude: venere,
                sign: Zodiac.values[(venere ~/ 30) % 12]),
            PlanetPosition(
                id: 'mars',
                name: 'Marte',
                glyph: '♂',
                longitude: marte,
                sign: Zodiac.values[(marte ~/ 30) % 12]),
          ],
          ascendantLongitude: 45.0,
          midheavenLongitude: 315.0,
          houses: [
            for (var n = 1; n <= 12; n++)
              HouseCusp(number: n, longitude: (45.0 + (n - 1) * 30.0) % 360.0),
          ],
          hasTime: true,
        );
    final adesso = DateTime.utc(2026, 9, 29, 12);
    final carte = [
      carta(217.5, 330.0, 280.0),
      carta(40.0, 20.0, 100.0),
      carta(120.0, 200.0, 10.0),
    ];
    final righe = <String>[];
    final livelli = <List<int>>[];
    for (final c in carte) {
      final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: c);
      final schede = Horoscope.forSign(
          sign: Zodiac.pisces, dayOfYear: 271, year: 2026, cielo: cielo);
      livelli.add([for (final s in schede) s.indicator]);
      for (final s in schede) {
        righe.add('Luna ${c.planets[1].longitude}, ${s.domain.name}: '
            '${s.indicator}, ${s.rigaDelLivello}');
      }
    }
    for (final r in righe) {
      print(r);
    }
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/indicatore.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('ORDINE ES VOCE 28: tre carte dei Pesci, 29 '
            'settembre 2026, il livello e la riga che lo spiega.\n\n'
            '${righe.join('\n')}\n');
    }
    // Tre carte diverse dello stesso segno non danno tre volte gli stessi
    // livelli: con la hash erano identici.
    expect({for (final l in livelli) l.join(',')}.length, greaterThan(1));
  });
}
