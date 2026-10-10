// L'ARIA FRA NOI E LE STELLE. Ordine FH parte 11.
//
// 11.1: la magnitudine cresce di 0,28 per la massa d'aria meno uno, con la
// massa d'aria limitata a 38; il colore scivola verso l'ambra con la stessa
// legge. 11.2: lo scintillio c'e' solo sotto i venti gradi, appena li' e pieno
// a due. 11.3: l'alone dell'aria si spegne entro i quindici gradi.

import 'dart:math' as math;

import 'package:esoteric_circle/features/real_time_cosmo/lo_stile_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

double _seno(double gradi) => math.sin(gradi * math.pi / 180);

void main() {
  test('l\'estinzione segue la massa d\'aria', () {
    expect(estinzione(1), closeTo(0, 1e-12));
    // A trenta gradi la massa d'aria e' due: 0,28 magnitudini.
    expect(estinzione(_seno(30)), closeTo(0.28, 1e-9));
    // All'orizzonte la massa d'aria si ferma a 38: 0,28 per 37.
    expect(estinzione(0), closeTo(0.28 * 37, 1e-9));
    expect(estinzione(_seno(0.5)), closeTo(0.28 * 37, 1e-9));
    // Allo specchio sotto l'orizzonte, senza gradino sulla linea.
    expect(estinzione(-_seno(10)), closeTo(estinzione(_seno(10)), 1e-12));
    // Cresce sempre scendendo.
    var prima = -1.0;
    for (var a = 90.0; a >= 1; a -= 1) {
      final e = estinzione(_seno(a));
      expect(e >= prima, isTrue, reason: '$a gradi');
      prima = e;
    }
  });

  test('il colore scivola verso l\'ambra con la stessa legge', () {
    expect(ambraDellaStella(0), 0);
    expect(ambraDellaStella(3), closeTo(0.5, 1e-12));
    expect(ambraDellaStella(estinzione(_seno(30))), lessThan(0.1));
    expect(ambraDellaStella(estinzione(0)), greaterThan(0.7));
  });

  test('lo scintillio solo sotto i venti gradi, pieno a due', () {
    expect(ampiezzaDelloScintillio(20), 0);
    expect(ampiezzaDelloScintillio(45), 0);
    expect(ampiezzaDelloScintillio(2), kScintillioMassimo);
    expect(ampiezzaDelloScintillio(0.5), kScintillioMassimo);
    // A diciannove gradi appena percepibile.
    expect(ampiezzaDelloScintillio(19), lessThan(0.01));
    expect(ampiezzaDelloScintillio(10),
        inExclusiveRange(0.01, kScintillioMassimo));
  });

  test('l\'alone dell\'aria si spegne entro i quindici gradi', () {
    expect(kAltezzaDellAlone, 15);
    expect(kLuceDellAloneAllOrizzonte, greaterThan(0));
  });
}
