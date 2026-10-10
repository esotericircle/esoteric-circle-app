// IL TELEFONO ORIZZONTALE. Segnalato dal fondatore il 10 ottobre 2026: "se
// inclino il telefono, la rotazione automatica si attiva e la schermata
// diventa orizzontale, ma non il contenuto che continua ad essere
// verticale"; col dito il cielo si girava, con la bussola tornava verticale.
//
// La bussola dava "destra" e "su" dagli assi del telefono in verticale: con
// la schermata girata il cielo restava girato di novanta gradi. Qui il
// telefono e' in orizzontale, la camera verso il nord all'orizzonte, nelle
// due rotazioni (cima a sinistra e cima a destra): la vista deve guardare a
// nord, col "su" della schermata verso l'alto del cielo e la "destra" verso
// est. In verticale nulla cambia.

import 'package:esoteric_circle/core/motion/l_orientamento_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Il campo magnetico, di 45 microtesla inclinato di 60 gradi, nel mondo:
  // est 0, nord 22,5, alto -39. Gli assi del telefono nel mondo (est, nord,
  // alto) per ogni posa; la camera e' -z del telefono, verso nord.
  const nord = [0.0, 22.5, -39.0];
  const alto = [0.0, 0.0, 9.81];
  double p(List<double> u, List<double> w) =>
      u[0] * w[0] + u[1] * w[1] + u[2] * w[2];

  // (nome, asse x del telefono, asse y del telefono, orizzontale)
  final pose = [
    ('verticale', [1.0, 0.0, 0.0], [0.0, 0.0, 1.0], false),
    // Cima a sinistra: la cima (+y) verso ovest, il lato destro (+x) in alto.
    ('cima a sinistra', [0.0, 0.0, 1.0], [-1.0, 0.0, 0.0], true),
    // Cima a destra: la cima verso est, il lato destro in basso.
    ('cima a destra', [0.0, 0.0, -1.0], [1.0, 0.0, 0.0], true),
  ];
  var provate = 0;
  for (final (nome, x, y, orizzontale) in pose) {
    test('$nome: la vista guarda a nord, su in alto e destra a est', () {
      // z = x per y (destrorso): la camera guarda lungo -z, cioe' a nord.
      final z = [
        x[1] * y[2] - x[2] * y[1],
        x[2] * y[0] - x[0] * y[2],
        x[0] * y[1] - x[1] * y[0],
      ];
      expect(-z[1], closeTo(1, 1e-9), reason: 'la posa non guarda a nord');
      final o = OrientamentoDelTelefono.orientamentoDa(
        gx: p(x, alto),
        gy: p(y, alto),
        gz: p(z, alto),
        mx: p(x, nord),
        my: p(y, nord),
        mz: p(z, nord),
        orizzontale: orizzontale,
      )!;
      // avanti verso nord, su verso l'alto, destra verso est.
      expect(o.m[7], closeTo(1, 1e-6), reason: '$nome: avanti non e\' a nord');
      expect(o.m[5], closeTo(1, 1e-6),
          reason:
              '$nome: il su della schermata non va verso l\'alto del cielo');
      expect(o.m[0], closeTo(1, 1e-6),
          reason: '$nome: la destra della schermata non va a est');
      provate++;
    });
  }
  tearDownAll(() => expect(provate, 3));
}
