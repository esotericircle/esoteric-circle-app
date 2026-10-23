import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MOTORE LOCALE VALE PER OGGI E PER LE NASCITE, DAL 1900 AL 2099.
///
/// **LAPIDE, ordine FD voce 02, 5 ottobre 2026.** Qui stavano quattro prove
/// dell'ordine 2170 voce 5, sul motore `Effemeridi` (elementi medi): l'epoca
/// verificata era il 2020-2030, Saturno sbagliava 0,570 gradi al 1950, e una
/// prova vietava di usare quel motore per una nascita. Difendevano la regola
/// di un motore che non esiste piu': l'ordine FD lo ha cancellato e ogni
/// posizione passa da `IlCieloDiMeeus`, verificato contro il JPL DE440s dal
/// 31 dicembre 1899 al 31 dicembre 2099 (`il_cielo_di_meeus_contro_il_jpl_
/// test.dart`). La regola nuova si prova qui sui due punti che le prove di
/// prima guardavano: Saturno al 1950 e nel 2026, e le nascite del secolo
/// scorso dentro l'intervallo.
///
/// La guardia sulla carta di nascita col motore locale cade con la sua
/// ragione: la carta natale resta del motore remoto, ma una nascita calcolata
/// in locale adesso e' verificata quanto il cielo di oggi.
void main() {
  double scarto(double a, double b) {
    final d = (a - b).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }

  test('le nascite del secolo scorso stanno dentro l\'intervallo verificato',
      () {
    for (final nascita in [
      DateTime.utc(1900, 1, 1),
      DateTime.utc(1950, 3, 21),
      DateTime.utc(1972, 3, 7),
      DateTime.utc(1985, 12, 21),
      DateTime.utc(1990, 6, 15),
      DateTime.utc(2026, 8, 10),
    ]) {
      expect(IlCieloDiMeeus.istanteVerificato(nascita), isTrue,
          reason: 'il ${nascita.year} cade fuori dall\'intervallo verificato');
    }
  });

  test('Saturno al 1950 e nel 2026 sta entro lo scarto dichiarato', () {
    // I due valori di JPL Horizons che le prove di prima usavano.
    final jd1950 =
        IlCieloDiMeeus.giornoGiuliano(DateTime.utc(1950, 3, 21, 6, 15));
    final s1950 = scarto(
        IlCieloDiMeeus.longitudine(CorpoCeleste.saturno, jd1950), 164.9486174);
    final jdOggi = IlCieloDiMeeus.giornoGiuliano(DateTime.utc(2026, 8, 24));
    final sOggi = scarto(
        IlCieloDiMeeus.longitudine(CorpoCeleste.saturno, jdOggi), 14.0890698);
    // ignore: avoid_print
    print(
        'ORDINE FD VOCE 02: Saturno sbaglia ${(s1950 * 3600).toStringAsFixed(1)} '
        'secondi d\'arco al 1950 e ${(sOggi * 3600).toStringAsFixed(1)} nel '
        '2026 (col motore di prima 0,570 e 0,141 gradi)');
    // Lo scarto dichiarato vale per il JPL DE440s; Horizons e' lo stesso JPL,
    // con un margine di due secondi d'arco per l'arrotondamento dei valori.
    final dichiarato =
        IlCieloDiMeeus.scartoMisurato[CorpoCeleste.saturno]! + 2 / 3600;
    expect(s1950, lessThan(dichiarato));
    expect(sOggi, lessThan(dichiarato));
  });
}
