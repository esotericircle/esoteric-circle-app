// GUARDIA 15.4 DELL'ORDINE FH: IL PESO SEGUE IL DATO.
//
// Nel cielo vero le figure dello zodiaco non pesano uguale: fra le stelle che
// formano la figura, lo Scorpione ne ha sedici fino alla quarta magnitudine,
// il Leone undici, il Cancro due (ordine FH, fatto 2: il numero e' quello del
// file, che conta le stelle della figura e non della regione). La prova legge
// le forze dalla porta che il cielo usa, LeLineeDelleFigure sul file vero, e
// cade se Scorpione, Leone e Cancro non stanno in quell'ordine, o se le loro
// forze non sono quelle della formula della voce 4.2. Pretende anche il
// minimo di 0,70 del velo del segno della persona (voce 4.4).

import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/real_time_cosmo/le_linee_delle_figure.dart';
import 'package:esoteric_circle/features/real_time_cosmo/gli_asset_del_cosmo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'real_time_cosmo_nessuna_linea_inventata_test.dart' show catalogo;

void main() {
  test('Scorpione, Leone e Cancro pesano in quest\'ordine, dal file', () {
    final linee = LeLineeDelleFigure.daJson(
        File(kLineeDelleFigure).readAsStringSync(), catalogo());
    double forza(String iau) => linee.figure[linee.indiceDi(iau)!].forza;
    final sco = forza('Sco'), leo = forza('Leo'), cnc = forza('Cnc');
    // ignore: avoid_print
    print('forze: Scorpione $sco, Leone $leo, Cancro $cnc '
        '(divisore dal file: ${linee.contoPiuRicco})');
    expect(linee.contoPiuRicco, 16);
    expect(sco > leo && leo > cnc, isTrue,
        reason: 'Scorpione $sco, Leone $leo, Cancro $cnc');
    expect(sco, closeTo(1.0, 1e-9));
    expect(leo, closeTo(math.sqrt(11 / 16), 1e-9));
    expect(cnc, closeTo(math.sqrt(2 / 16), 1e-9));
    // Il velo del segno della persona non scende sotto 0,70.
    expect(forzaDelVelo(cnc, eIlSegno: true), 0.70);
    expect(forzaDelVelo(cnc, eIlSegno: false), cnc);
    expect(forzaDelVelo(sco, eIlSegno: true), sco);
  });
}
