// L'ECLITTICA STA DOVE STA. Ordine FH parte 13.
//
// I settantatre punti del filo stanno sull'eclittica dell'epoca J2000: a
// novanta gradi dal polo nord dell'eclittica (ascensione retta 270, declinazione
// 66,56) e il primo, la longitudine zero, sul punto vernale.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
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

  // LA SCRITTA NON COPRE NIENTE. Visto sul Realme il 10 ottobre 2026: la
  // Luna corre sull'eclittica e sta al centro, e il nome del filo le passava
  // sopra. Si cerca, su piu' orientamenti, il posto della scritta senza
  // ostacoli; poi si mette un ostacolo proprio li' (la Luna), e la scritta
  // deve andare altrove senza toccarlo, oppure tacere.
  test("la scritta dell'eclittica non copre la Luna ne' l'indicatore", () {
    final e = EclitticaInScena();
    final assi = Float64List.fromList([1, 0, 0, 0, 1, 0, 0, 0, 1]);
    final p = ProiezioneDelCielo(larghezza: 360, altezza: 797, campoGradi: 70);
    const mezza = 110.0, alta = 40.0;
    var provati = 0, spostate = 0, tacciono = 0;
    for (var az = 0; az < 360; az += 15) {
      for (final alt in [10.0, 30.0, 50.0]) {
        final o = OrientamentoDellaCamera.daAngoli(
            azimutGradi: az.toDouble(), altezzaGradi: alt);
        e.prepara(o, p, assi, null, 0,
            mezzaScritta: mezza, altezzaScritta: alta);
        if (!e.scrittaVisibile) continue;
        final libera = EclitticaInScena.scatolaDellaScritta(
            e.scrittaX, e.scrittaY, mezza, alta);
        // La Luna sul punto scelto, col suo bordo.
        final luna = Rect.fromCircle(
            center: Offset(e.scrittaX, e.scrittaY - alta / 2), radius: 30);
        e.prepara(o, p, assi, null, 0,
            mezzaScritta: mezza, altezzaScritta: alta, ostacoli: [luna]);
        provati++;
        if (!e.scrittaVisibile) {
          tacciono++;
          continue;
        }
        final ora = EclitticaInScena.scatolaDellaScritta(
            e.scrittaX, e.scrittaY, mezza, alta);
        expect(ora.overlaps(luna), isFalse,
            reason: 'a $az gradi e $alt di altezza la scritta copre la Luna');
        expect(ora == libera, isFalse);
        spostate++;
      }
    }
    // ignore: avoid_print
    print(
        'ECLITTICA: $provati orientamenti con la scritta, $spostate spostate, '
        '$tacciono tacciono');
    // Il cardinale minimo: senza orientamenti la prova non guarda niente.
    expect(provati, greaterThanOrEqualTo(20));
  });
}
