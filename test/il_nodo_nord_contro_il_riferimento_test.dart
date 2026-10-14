import 'dart:io';

import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL NODO NORD CONTRO IL RIFERIMENTO. Ordine FT voce FT.05, 14 ottobre
/// 2026.
///
/// La fonte terza e' Swiss Ephemeris (`pyswisseph`, serie Moshier, lo stesso
/// motore che sta dietro FreeAstroAPI in produzione, CLAUDE.md: "Dati
/// astrologici: FreeAstroAPI basata su effemeridi svizzere"), letta con
/// `tool/riferimenti_del_nodo_nord.py`: dieci istanti, uno per coppia, in
/// `docs/collaudo/FT/riferimenti_del_nodo_nord.csv`.
///
/// Il Nodo Nord medio e' un elemento dell'orbita (una formula sulle
/// costanti), non una posizione da un'effemeride numerica integrata: le due
/// fonti (la serie di Meeus, Astronomical Algorithms cap. 22, e la serie di
/// Swiss Ephemeris) sono approssimazioni diverse dello stesso elemento
/// medio, quindi uno scarto di qualche millesimo di grado e' atteso, non un
/// errore: e' la stessa distanza che si vede fra le costanti del nodo medio
/// di due libri diversi di meccanica celeste.
void main() {
  final righe = File('docs/collaudo/FT/riferimenti_del_nodo_nord.csv')
      .readAsLinesSync()
      .where((r) => r.isNotEmpty && !r.startsWith('#'))
      .toList();
  final dati = righe.skip(1).map((r) {
    final campi = r.split(',');
    return (jdUt: double.parse(campi[1]), nodoNord: double.parse(campi[2]));
  }).toList();

  double scarto(double a, double b) => ((a - b + 540) % 360 - 180).abs();

  test('il nodo nord sta entro lo scarto dichiarato dalla porta', () {
    expect(dati.length, 10,
        reason: 'il riferimento deve portare le dieci coppie dichiarate');
    var peggio = 0.0;
    for (final d in dati) {
      final nostro = IlCieloDiMeeus.longitudineDelNodoNord(d.jdUt);
      final s = scarto(nostro, d.nodoNord);
      if (s > peggio) peggio = s;
      expect(s, lessThan(IlCieloDiMeeus.scartoMisuratoNodoNord),
          reason: 'al giorno giuliano ${d.jdUt}: nostro $nostro, '
              'riferimento ${d.nodoNord}, scarto $s');
    }
    expect(peggio, greaterThan(0.0),
        reason: 'lo scarto peggiore non puo essere zero su dati veri');
  });

  test('lo scarto decide ancora il segno', () {
    // Un segno e' trenta gradi: uno scarto sotto un decimo di grado non
    // sposta mai il nodo da un segno all'altro, nemmeno al bordo.
    for (final d in dati) {
      final nostro = IlCieloDiMeeus.longitudineDelNodoNord(d.jdUt);
      expect(scarto(nostro, d.nodoNord), lessThan(0.1));
    }
  });
}
