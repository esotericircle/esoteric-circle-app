// GUARDIA 15.3 DELL'ORDINE FH: NESSUNA LINEA INVENTATA.
//
// Le linee che il cielo disegna sono quelle del file dell'Architetto, tutte e
// sole. La prova legge il file da se' (non dal codice che lo legge), ricava le
// 187 coppie di stelle per numero HIP, poi fa girare la scena delle linee su
// tutta la sfera: 72 direzioni di vista a cento gradi di campo, che insieme
// coprono il cielo intero. Cade se una linea disegnata non e' una coppia del
// file (il codice ne aggiunge), o se una coppia del file non e' mai stata
// disegnata (il codice ne toglie).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/le_linee_delle_figure.dart';
import 'package:esoteric_circle/features/real_time_cosmo/gli_asset_del_cosmo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/le_linee_in_scena.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogoDelleStelle catalogo() => CatalogoDelleStelle.daiByte(
    ByteData.sublistView(File(kCatalogoBinario).readAsBytesSync()),
    nomiJson: File(kCatalogoNomi).readAsStringSync(),
    costellazioniJson: File(kCatalogoCostellazioni).readAsStringSync());

/// Le coppie del file come le scrive il file: (HIP, HIP), senza verso.
Set<String> coppieDelFile() {
  final dati = json.decode(File(kLineeDelleFigure).readAsStringSync())
      as Map<String, dynamic>;
  final coppie = <String>{};
  for (final f in (dati['figure'] as Map<String, dynamic>).values) {
    for (final c in (f as Map<String, dynamic>)['linee'] as List) {
      final a = (c as List)[0] as int, b = c[1] as int;
      coppie.add(a < b ? '$a-$b' : '$b-$a');
    }
  }
  return coppie;
}

/// Le linee disegnate su tutta la sfera, come coppie di HIP.
Set<String> coppieDisegnate(LineeInScena scena, CatalogoDelleStelle c,
    CieloInUnIstante cielo) {
  final hipDi = {for (final e in c.perHip.entries) e.value: e.key};
  final viste = <String>{};
  final proiezione =
      ProiezioneDelCielo(larghezza: 360, altezza: 797, campoGradi: kCampoMassimo);
  for (var alt = -75.0; alt <= 75; alt += 30) {
    for (var az = 0.0; az < 360; az += 30) {
      scena.prepara(
        cielo: cielo,
        orientamento:
            OrientamentoDellaCamera.daAngoli(azimutGradi: az, altezzaGradi: alt),
        proiezione: proiezione,
      );
      for (var n = 0; n < scena.quante; n++) {
        final k = scena.disegnate[n];
        final a = hipDi[scena.linee.da[k]]!, b = hipDi[scena.linee.a[k]]!;
        viste.add(a < b ? '$a-$b' : '$b-$a');
      }
    }
  }
  return viste;
}

void main() {
  test('le linee disegnate sono le 187 coppie del file, tutte e sole', () {
    final c = catalogo();
    final linee = LeLineeDelleFigure.daJson(
        File(kLineeDelleFigure).readAsStringSync(), c);
    final file = coppieDelFile();
    expect(file.length, 187);
    expect(linee.numeroDiLinee, 187);
    final cielo = CieloInUnIstante.calcola(c,
        jd: Celestial.julianDay(DateTime.utc(2026, 10, 8, 20)),
        latitudine: 41.9,
        longitudine: 12.5);
    final viste = coppieDisegnate(LineeInScena(linee), c, cielo);
    final aggiunte = viste.difference(file);
    final tolte = file.difference(viste);
    expect(aggiunte, isEmpty, reason: 'linee disegnate che il file non ha: $aggiunte');
    expect(tolte, isEmpty, reason: 'coppie del file mai disegnate: $tolte');
  });
}
