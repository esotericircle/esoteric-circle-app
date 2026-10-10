// L'ECLITTICA STA DOVE STA. Ordine FH parte 13.
//
// I settantatre punti del filo stanno sull'eclittica dell'epoca J2000: a
// novanta gradi dal polo nord dell'eclittica (ascensione retta 270, declinazione
// 66,56) e il primo, la longitudine zero, sul punto vernale.

import 'dart:math' as math;

import 'package:esoteric_circle/features/real_time_cosmo/l_eclittica_in_scena.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('i punti del filo stanno sull\'eclittica', () {
    final e = EclitticaInScena();
    final v = e.versoriEquatoriali;
    const g = math.pi / 180;
    const decPolo = 66.5607 * g, raPolo = 270 * g;
    final px = math.cos(decPolo) * math.cos(raPolo);
    final py = math.cos(decPolo) * math.sin(raPolo);
    final pz = math.sin(decPolo);
    final n = v.length ~/ 3;
    expect(n, 73);
    var peggiore = 0.0;
    for (var k = 0; k < n; k++) {
      final c = v[k * 3] * px + v[k * 3 + 1] * py + v[k * 3 + 2] * pz;
      final scarto = (math.acos(c.clamp(-1.0, 1.0)) / g - 90).abs();
      if (scarto > peggiore) peggiore = scarto;
    }
    // ignore: avoid_print
    print(
        'FH.13: scarto peggiore dal cerchio dell\'eclittica: $peggiore gradi');
    expect(peggiore, lessThan(0.01));
    // La longitudine zero e' il punto vernale.
    expect(v[0], closeTo(1, 1e-6));
    expect(v[1], closeTo(0, 1e-6));
    expect(v[2], closeTo(0, 1e-6));
  });
}
