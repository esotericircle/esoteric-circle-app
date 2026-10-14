import 'package:esoteric_circle/core/synastry_approfondita/legame_e_eta.dart';
import 'package:flutter_test/flutter_test.dart';

/// FT.04: LO SBARRAMENTO DI ETA' SUL LEGAME AMORE. Ordine FT, 14 ottobre
/// 2026.
///
/// Guardia dichiarata dall'ordine: "rossa con una persona di 15 anni e 364
/// giorni, verde a 16 anni e 0 giorni, sui due lati della coppia e sui due
/// punti di controllo" (qui il punto app; il punto server e' la sua
/// controparte TypeScript, `functions/src/sinastria_approfondita.test.ts`).
void main() {
  final oggi = DateTime.utc(2026, 10, 14);

  test('15 anni e 364 giorni: non ancora sedici', () {
    final nascita = DateTime.utc(2010, 10, 15); // compleanno domani
    expect(SbarramentoDEta.anniCompiuti(nascita, oggi), 15);
    expect(SbarramentoDEta.haAlmeno16Anni(nascita, adesso: oggi), false);
  });

  test('16 anni e 0 giorni: il compleanno e oggi', () {
    final nascita = DateTime.utc(2010, 10, 14); // compleanno oggi
    expect(SbarramentoDEta.anniCompiuti(nascita, oggi), 16);
    expect(SbarramentoDEta.haAlmeno16Anni(nascita, adesso: oggi), true);
  });

  test('16 anni passati da un pezzo', () {
    final nascita = DateTime.utc(1990, 1, 1);
    expect(SbarramentoDEta.haAlmeno16Anni(nascita, adesso: oggi), true);
  });

  test('29 febbraio: il compleanno in un anno non bisestile cade il primo marzo',
      () {
    final nata = DateTime.utc(2008, 2, 29); // bisestile
    // Al 28 febbraio 2026 (non bisestile) il compleanno non e' ancora
    // passato: ancora 17, non 18. Qui verifichiamo solo che il calcolo non
    // esploda e dia un numero coerente col giorno dopo.
    final il28 = DateTime.utc(2026, 2, 28);
    final il1marzo = DateTime.utc(2026, 3, 1);
    expect(SbarramentoDEta.anniCompiuti(nata, il28),
        SbarramentoDEta.anniCompiuti(nata, il1marzo) - 1);
  });

  group('il legame amore, sui due lati della coppia', () {
    final maggiorenne = DateTime.utc(1990, 1, 1);
    final quasiSedici = DateTime.utc(2010, 10, 15); // 15 anni e 364 giorni
    final appenaSedici = DateTime.utc(2010, 10, 14); // 16 anni e 0 giorni

    test('entrambi sopra i sedici: amore aperto', () {
      expect(
          SbarramentoDEta.legameApribile(
              Legame.amore, maggiorenne, appenaSedici,
              adesso: oggi),
          true);
    });

    test('tu sotto i sedici: amore chiuso', () {
      expect(
          SbarramentoDEta.legameApribile(
              Legame.amore, quasiSedici, maggiorenne,
              adesso: oggi),
          false);
    });

    test('lei sotto i sedici: amore chiuso', () {
      expect(
          SbarramentoDEta.legameApribile(
              Legame.amore, maggiorenne, quasiSedici,
              adesso: oggi),
          false);
    });

    test('entrambi sotto i sedici: amore chiuso', () {
      expect(
          SbarramentoDEta.legameApribile(
              Legame.amore, quasiSedici, quasiSedici,
              adesso: oggi),
          false);
    });
  });

  group('gli altri tre legami non hanno limite di eta', () {
    final bambino = DateTime.utc(2020, 1, 1);
    for (final legame in [Legame.amicizia, Legame.famiglia, Legame.lavoro]) {
      test('${legame.nome}: aperto anche fra due bambini', () {
        expect(
            SbarramentoDEta.legameApribile(legame, bambino, bambino,
                adesso: oggi),
            true);
      });
    }
  });
}
