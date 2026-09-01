import 'dart:math';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/resonance.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'equilibrio della Risonanza, che e' il momento in cui l'app dice alla
/// persona quale Maestro l'ha scelta.
///
/// Prima di questo lavoro, su ventimila carte, Medora vinceva nel 72,2 per
/// cento dei casi, Caligo nel 26,3, Aura nell'1,5: una persona su sessantasei.
/// Non era sfortuna, era il conto dei pesi: Medora partiva da 11,5 punti
/// possibili contro i 7,5 degli altri due, perche' ha piu' indicatori.
///
/// Questo test e' permanente e vive nella suite. Gira su un seme fisso, quindi
/// non e' instabile: la stessa corsa da' sempre gli stessi numeri.
void main() {
  /// I pianeti che una carta completa porta, coi loro identificativi veri.
  const pianeti = [
    ('sun', 'Sole'),
    ('moon', 'Luna'),
    ('mercury', 'Mercurio'),
    ('venus', 'Venere'),
    ('mars', 'Marte'),
    ('jupiter', 'Giove'),
    ('saturn', 'Saturno'),
    ('uranus', 'Urano'),
    ('neptune', 'Nettuno'),
    ('pluto', 'Plutone'),
    ('chiron', 'Chirone'),
    ('lilith', 'Lilith'),
    ('north_node', 'Nodo'),
  ];

  /// Una carta natale pseudocasuale ma riproducibile: stesso seme, stessa
  /// carta. I pianeti cadono in segni e case a caso, come nella realta'.
  NatalChart cartaCasuale(Random rnd) {
    final planets = <PlanetPosition>[];
    for (final (id, nome) in pianeti) {
      final segno = Zodiac.values[rnd.nextInt(12)];
      planets.add(PlanetPosition(
        id: id,
        name: nome,
        glyph: '*',
        longitude: Zodiac.values.indexOf(segno) * 30.0 + rnd.nextDouble() * 30,
        sign: segno,
        house: rnd.nextInt(12) + 1,
      ));
    }
    return NatalChart(
      sunSign: planets.first.sign,
      moonSign: planets[1].sign,
      ascendant: Zodiac.values[rnd.nextInt(12)],
      midheaven: Zodiac.values[rnd.nextInt(12)],
      planets: planets,
      hasTime: true,
    );
  }

  Map<Maestro, double> distribuzione(NatalChart Function(Random) genera,
      {int quante = 20000, int seme = 4242}) {
    final rnd = Random(seme);
    final conti = <Maestro, int>{for (final m in Maestro.values) m: 0};
    for (var i = 0; i < quante; i++) {
      final r = computeResonance(genera(rnd));
      conti[r.winner] = conti[r.winner]! + 1;
    }
    return {
      for (final e in conti.entries) e.key: e.value * 100 / quante,
    };
  }

  String leggibile(Map<Maestro, double> d) => Maestro.values
      .map((m) => '${m.name} ${d[m]!.toStringAsFixed(1)}%')
      .join(', ');

  test('La distribuzione, per il verbale', () {
    // Non e' una verifica, e' la misura che finisce nell'esito.
    final piena = distribuzione(cartaCasuale);
    final ripiego = distribuzione(
      (rnd) => NatalChart.essential(
        sunSign: Zodiac.values[rnd.nextInt(12)],
        hasTime: false,
      ),
    );
    // ignore: avoid_print
    print('CARTA COMPLETA: ${leggibile(piena)}');
    // ignore: avoid_print
    print('CARTA ESSENZIALE: ${leggibile(ripiego)}');
    expect(piena.values.reduce((a, b) => a + b), closeTo(100, 0.01));
  });

  group('Carta completa', () {
    test('Nessun Maestro sotto il 25 per cento ne\' sopra il 40', () {
      final d = distribuzione(cartaCasuale);
      for (final m in Maestro.values) {
        expect(d[m], greaterThanOrEqualTo(25.0),
            reason: 'distribuzione: ${leggibile(d)}');
        expect(d[m], lessThanOrEqualTo(40.0),
            reason: 'distribuzione: ${leggibile(d)}');
      }
    });
  });

  group('Carta essenziale, il ripiego', () {
    test('Nessun Maestro sotto il 20 per cento', () {
      // Il ripiego porta il solo Sole: l'informazione e' povera, ma dodici
      // segni si dividono in tre gruppi da quattro, quindi nessuno resta fuori.
      final d = distribuzione(
        (rnd) => NatalChart.essential(
          sunSign: Zodiac.values[rnd.nextInt(12)],
          hasTime: false,
        ),
      );
      for (final m in Maestro.values) {
        expect(d[m], greaterThanOrEqualTo(20.0),
            reason: 'distribuzione sul ripiego: ${leggibile(d)}');
      }
    });

    test('Ogni Maestro governa quattro segni, senza sovrapposizioni', () {
      final perMaestro = <Maestro, List<Zodiac>>{
        for (final m in Maestro.values) m: [],
      };
      for (final z in Zodiac.values) {
        final r =
            computeResonance(NatalChart.essential(sunSign: z, hasTime: false));
        perMaestro[r.winner]!.add(z);
      }
      for (final m in Maestro.values) {
        expect(perMaestro[m]!.length, 4,
            reason: '${m.name} governa ${perMaestro[m]!.length} segni');
      }
    });
  });

  group('Determinismo', () {
    test('La stessa carta da\' cento volte lo stesso Maestro', () {
      final carta = cartaCasuale(Random(7));
      final primo = computeResonance(carta).winner;
      for (var i = 0; i < 100; i++) {
        expect(computeResonance(carta).winner, primo);
      }
      // Anche i punteggi non si muovono di un millesimo.
      final punti = computeResonance(carta).scores;
      final ancora = computeResonance(carta).scores;
      for (final m in Maestro.values) {
        expect(ancora[m], closeTo(punti[m]!, 1e-12));
      }
    });
  });

  group('Significativita\'', () {
    /// Una carta con tutti i pianeti nello stesso segno e nella stessa casa:
    /// serve a costruire cieli molto diversi fra loro.
    NatalChart cartaTutta(Zodiac segno, int casa) => NatalChart(
          sunSign: segno,
          ascendant: segno,
          midheaven: segno,
          hasTime: true,
          planets: [
            for (final (id, nome) in pianeti)
              PlanetPosition(
                id: id,
                name: nome,
                glyph: '*',
                longitude: Zodiac.values.indexOf(segno) * 30.0 + 15,
                sign: segno,
                house: casa,
              ),
          ],
        );

    test('Cieli molto diversi non danno tutti lo stesso Maestro', () {
      final vincitori = {
        computeResonance(cartaTutta(Zodiac.gemini, 3)).winner,
        computeResonance(cartaTutta(Zodiac.cancer, 4)).winner,
        computeResonance(cartaTutta(Zodiac.scorpio, 8)).winner,
        computeResonance(cartaTutta(Zodiac.capricorn, 12)).winner,
        computeResonance(cartaTutta(Zodiac.aquarius, 9)).winner,
        computeResonance(cartaTutta(Zodiac.pisces, 6)).winner,
      };
      expect(vincitori.length, greaterThanOrEqualTo(2),
          reason: 'se un solo Maestro vince sempre non e\' piu\' una lettura');
    });

    test('Cieli quasi identici danno lo stesso Maestro', () {
      // Tre coppie costruite a mano: cambia un solo grado dentro lo stesso
      // segno, quindi la lettura non deve cambiare.
      for (final (segno, casa) in const [
        (Zodiac.gemini, 3),
        (Zodiac.scorpio, 8),
        (Zodiac.cancer, 4),
      ]) {
        final a = cartaTutta(segno, casa);
        final b = NatalChart(
          sunSign: segno,
          ascendant: segno,
          midheaven: segno,
          hasTime: true,
          planets: [
            for (final p in a.planets)
              PlanetPosition(
                id: p.id,
                name: p.name,
                glyph: p.glyph,
                longitude: p.longitude + 1,
                sign: p.sign,
                house: p.house,
              ),
          ],
        );
        expect(computeResonance(b).winner, computeResonance(a).winner,
            reason: 'un grado di differenza ha cambiato il Maestro');
      }
    });
  });
}
