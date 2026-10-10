// IL CIELO FERMO NON TREMA. Segnalato dal fondatore il 10 ottobre 2026:
// "se resto con il telefono fermo, anche appoggiato su superficie, c'e' un
// fastidioso continuo tremolio".
//
// Il telefono fermo, con il rumore vero dei sensori: il magnetometro sbaglia
// di circa un grado a ogni lettura, la gravita' di qualche decimo. Si fanno
// girare dieci secondi a sessanta fotogrammi e si misura quanto si sposta la
// direzione della camera: a settanta gradi di campo un punto dello schermo e'
// circa un sesto di grado (411 punti per 70 gradi). Poi il telefono gira
// davvero di trenta gradi, e la vista lo deve seguire in fretta: un filtro
// che non trema perche' non si muove piu' non serve.

import 'dart:async';
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import 'package:esoteric_circle/core/motion/l_orientamento_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// L'angolo in gradi fra le direzioni "avanti" di due orientamenti.
double _angolo(OrientamentoDellaCamera a, OrientamentoDellaCamera b) {
  final d = a.m[6] * b.m[6] + a.m[7] * b.m[7] + a.m[8] * b.m[8];
  return math.acos(d.clamp(-1.0, 1.0)) * 180 / math.pi;
}

/// L'azimut in gradi della direzione "avanti".
double _azimut(OrientamentoDellaCamera o) =>
    (math.atan2(o.m[6], o.m[7]) * 180 / math.pi + 360) % 360;

void main() {
  test('col telefono fermo la vista non trema, e segue un giro vero', () {
    final caso = math.Random(7);
    double rumore(double s) {
      // Gaussiano con Box-Muller.
      final u = 1 - caso.nextDouble(), v = caso.nextDouble();
      return s * math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
    }

    // Il telefono in piedi davanti a chi guarda: la camera (-z del telefono)
    // verso l'azimut [giro], venti gradi sopra l'orizzonte. Gli assi del
    // telefono nel mondo (est, nord, alto), e da li' cio' che leggono i
    // sensori: la gravita' verso l'alto, il campo di 45 microtesla inclinato
    // di 60 gradi verso il basso.
    var giro = 0.0;
    const e = 20 * math.pi / 180;
    List<List<double>> assi() {
      final a = giro * math.pi / 180;
      final f = [
        math.sin(a) * math.cos(e),
        math.cos(a) * math.cos(e),
        math.sin(e)
      ];
      final y = [
        -math.sin(a) * math.sin(e),
        -math.cos(a) * math.sin(e),
        math.cos(e)
      ];
      final z = [-f[0], -f[1], -f[2]];
      final x = [
        y[1] * z[2] - y[2] * z[1],
        y[2] * z[0] - y[0] * z[2],
        y[0] * z[1] - y[1] * z[0],
      ];
      return [x, y, z];
    }

    ({double x, double y, double z}) nelTelefono(List<double> w) {
      final a = assi();
      double p(List<double> u) => u[0] * w[0] + u[1] * w[1] + u[2] * w[2];
      return (x: p(a[0]), y: p(a[1]), z: p(a[2]));
    }

    ({double x, double y, double z}) campo() =>
        nelTelefono([0, 45 * 0.5, -45 * 0.866]);
    ({double x, double y, double z}) gravitaVera() => nelTelefono([0, 0, 9.81]);

    final eventi = StreamController<MagnetometerEvent>.broadcast(sync: true);
    final t = OrientamentoDelTelefono(
      gravita: () {
        final g = gravitaVera();
        return (
          x: g.x + rumore(0.05),
          y: g.y + rumore(0.05),
          z: g.z + rumore(0.05),
        );
      },
      bussola: () => eventi.stream,
    )..accendi();

    final costante = costanteDiTempoPerCampo(70);
    const dt = 1 / 60;
    OrientamentoDellaCamera? passo() {
      final c = campo();
      eventi.add(MagnetometerEvent(c.x + rumore(0.6), c.y + rumore(0.6),
          c.z + rumore(0.6), DateTime(2026)));
      return t.passo(dt, costante);
    }

    // Due secondi per assestarsi, poi dieci secondi fermi.
    for (var i = 0; i < 120; i++) {
      passo();
    }
    OrientamentoDellaCamera? prima;
    var piuGrande = 0.0, somma = 0.0, n = 0;
    final azimut = <double>[];
    for (var i = 0; i < 600; i++) {
      final o = passo()!;
      azimut.add(_azimut(o));
      if (prima != null) {
        final a = _angolo(prima, o);
        piuGrande = math.max(piuGrande, a);
        somma += a;
        n++;
      }
      prima = o;
    }
    var escursione = 0.0;
    for (final z in azimut) {
      final d = (((z - azimut.first + 540) % 360) - 180).abs();
      escursione = math.max(escursione, d);
    }
    // Il cammino totale della vista in dieci secondi, in punti a 70 gradi.
    const puntiPerGrado = 411 / 70;
    // ignore: avoid_print
    print('FERMO: passo piu\' grande ${piuGrande.toStringAsFixed(4)} gradi, '
        'cammino in dieci secondi ${(somma * puntiPerGrado).toStringAsFixed(1)} '
        'punti, escursione dell\'azimut ${escursione.toStringAsFixed(3)} gradi');
    expect(n, 599);
    // Fermo vuol dire fermo: in dieci secondi la vista non percorre piu' di
    // tre punti in tutto, e non salta mai di piu' di un quarto di punto.
    expect(somma * puntiPerGrado, lessThan(3));
    expect(piuGrande * puntiPerGrado, lessThan(0.25));

    // Il giro vero: trenta gradi a destra, di colpo.
    final partenza = _azimut(prima!);
    giro = 30;
    var dopo = 0.0;
    for (var i = 0; i < 36; i++) {
      dopo = _azimut(passo()!);
    }
    final seguito = ((dopo - partenza + 540) % 360) - 180;
    // ignore: avoid_print
    print('GIRO: dopo 0,6 secondi la vista ha girato di '
        '${seguito.toStringAsFixed(1)} gradi su 30');
    expect(seguito.abs(), greaterThan(27));
    eventi.close();
  });
}
