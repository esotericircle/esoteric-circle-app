// LA DENSITA' DEL CIELO DEL REAL TIME COSMO. Ordine FG parte 2, voce 2.5.
//
// Il bersaglio e' fra 158 e 218 punti luminosi a schermo a settanta gradi di
// campo, misurato sull'app di riferimento (docs/collaudo/FG/
// catture_del_fondatore/). Qui si misura la densita' vera in tre
// inquadrature, sul telefono di 360 per 797 punti: Roma, 8 ottobre 2026 alle
// 22 ora italiana (20 UTC), sud a 40 gradi d'altezza (la Via Lattea
// d'autunno, il Capricorno e l'Acquario), est a 30 gradi (Toro e Pleiadi che
// salgono), nord a 60 gradi (l'Orsa e Cassiopea, cielo povero di stelle).
//
// Un "punto luminoso" e' una stella dentro lo schermo con almeno meta' della
// sua luce (ScenaDelCielo.luminose): le stelle sotto il limite che
// sfumano non si contano, come non le conterebbe l'occhio.

import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/la_scena_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogoDelleStelle catalogoDalDisco() => CatalogoDelleStelle.daiByte(
    ByteData.sublistView(File(kCatalogoBinario).readAsBytesSync()),
    nomiJson: File(kCatalogoNomi).readAsStringSync(),
    costellazioniJson: File(kCatalogoCostellazioni).readAsStringSync());

const _inquadrature = <String, (double, double)>{
  'sud a 40 gradi': (180, 40),
  'est a 30 gradi': (90, 30),
  'nord a 60 gradi': (0, 60),
};

void main() {
  test('a settanta gradi i punti luminosi sono fra 158 e 218', () {
    final catalogo = catalogoDalDisco();
    final cielo = CieloInUnIstante.calcola(catalogo,
        jd: Celestial.julianDay(DateTime.utc(2026, 10, 8, 20)),
        latitudine: 41.9,
        longitudine: 12.5);
    final scena = ScenaDelCielo(catalogo);
    final proiezione = ProiezioneDelCielo(
        larghezza: 360, altezza: 797, campoGradi: kCampoDiPartenza);
    final misure = <String, int>{};
    _inquadrature.forEach((nome, dir) {
      scena.prepara(
        cielo: cielo,
        orientamento: OrientamentoDellaCamera.daAngoli(
            azimutGradi: dir.$1, altezzaGradi: dir.$2),
        proiezione: proiezione,
      );
      misure[nome] = scena.luminose;
    });
    // ignore: avoid_print
    print('punti luminosi a 70 gradi: $misure');
    misure.forEach((nome, n) {
      expect(n, inInclusiveRange(158, 218), reason: '$nome: $n');
    });
  });
}
