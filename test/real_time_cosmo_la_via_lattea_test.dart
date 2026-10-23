// LA VIA LATTEA STA DOVE STA IN CIELO. Ordine FH parte 9.
//
// 9.1: la rotazione dalle coordinate galattiche alle equatoriali porta il
// centro galattico (l 0, b 0) a ascensione retta 266,40 e declinazione
// -28,94, e il polo nord galattico (b 90) alle costanti della voce.
// La rotazione del cielo di un istante, i tre assi di CieloInUnIstante, gira
// ogni stella del catalogo esattamente come la porta unica della conversione:
// se la Via Lattea usasse un'altra rotazione, scivolerebbe via dalle stelle.
// Il taglio dell'asset a 45,5 gradi dal piano e' spento dal colore dei
// vertici.

import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/la_via_lattea.dart';
import 'package:esoteric_circle/features/real_time_cosmo/la_via_lattea_in_scena.dart';
import 'package:flutter_test/flutter_test.dart';

import 'real_time_cosmo_la_densita_del_cielo_test.dart' show catalogoDalDisco;

void main() {
  test('il centro e il polo della galassia cadono dove devono', () {
    final centro = galatticheInEquatoriali(0, 0);
    expect(centro.ra, closeTo(266.405, 0.01));
    expect(centro.dec, closeTo(-28.936, 0.01));
    final polo = galatticheInEquatoriali(37, 90);
    expect(polo.ra, closeTo(kRaDelPoloGalattico, 0.01));
    expect(polo.dec, closeTo(kDecDelPoloGalattico, 0.01));
    // Il polo nord celeste sta a longitudine galattica 122,93.
    final nord = galatticheInEquatoriali(kLongitudineDelPoloCeleste, 27.12825);
    expect(nord.dec, closeTo(90, 0.01));
  });

  test('i tre assi girano le stelle come la porta unica', () {
    final catalogo = catalogoDalDisco();
    final cielo = CieloInUnIstante.calcola(catalogo,
        jd: Celestial.julianDay(DateTime.utc(2026, 10, 8, 20)),
        latitudine: 40.85,
        longitudine: 14.27);
    // Dall'aggiunta della Macchina del tempo (voce E8) anche le stelle del
    // cielo di un istante si girano con gli assi: la prova le confronta con
    // la porta unica chiamata qui, stella per stella, cosi' misura sia la Via
    // Lattea sia le stelle, e non confronta gli assi con se stessi.
    final lst = Celestial.localSiderealDegrees(cielo.jd, 14.27);
    var peggiore = 0.0;
    for (var i = 0; i < catalogo.numeroDiStelle; i += 7) {
      final h = Celestial.equatorialToHorizontal(
          raDeg: catalogo.raGradi[i],
          decDeg: catalogo.decGradi[i],
          latDeg: 40.85,
          lstDeg: lst);
      final alt = h.altDeg * math.pi / 180, az = h.azDeg * math.pi / 180;
      final x = math.cos(alt) * math.sin(az);
      final y = math.cos(alt) * math.cos(az);
      final z = math.sin(alt);
      final d = (x - cielo.x[i]).abs() +
          (y - cielo.y[i]).abs() +
          (z - cielo.z[i]).abs();
      if (d > peggiore) peggiore = d;
    }
    // ignore: avoid_print
    print('FH.9: scarto peggiore fra la rotazione e la porta: $peggiore');
    expect(peggiore, lessThan(1e-4));
  });

  test('il taglio dell\'asset a 45 gradi dal piano e\' spento', () {
    expect(luceDellaFascia(0), 1);
    expect(luceDellaFascia(-30), 1);
    expect(luceDellaFascia(45), 0);
    expect(luceDellaFascia(-50), 0);
    expect(luceDellaFascia(37.5), closeTo(0.5, 1e-9));
  });
}
