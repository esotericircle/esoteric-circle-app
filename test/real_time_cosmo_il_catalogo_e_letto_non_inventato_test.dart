// GUARDIA 7.3 DELL'ORDINE FG: IL CATALOGO E' LETTO, NON INVENTATO.
//
// Tre stelle note, la posizione che l'app ne ricava e tre valori di una fonte
// terza scritti qui. La fonte e' SIMBAD del CDS di Strasburgo, interrogato
// l'8 ottobre 2026 alle 21:02 (ora di Parigi) con la query
// SELECT main_id, ra, dec FROM basic, coordinate ICRS all'epoca J2000:
//
//   * alf CMa (Sirio)      101,28715533  -16,71611586
//   * alf Lyr (Vega)       279,23473479  +38,78368896
//   * alf Ori (Betelgeuse)  88,79293899   +7,40706400
//
// Scarto massimo dichiarato: 0,003 gradi, cioe' il millesimo di grado a cui
// il binario arrotonda piu' lo scarto fra HYG e SIMBAD (misurato: sotto i
// due millesimi). Poi la posizione calcolata dall'app sull'orizzonte: la
// Stella Polare, che SIMBAD da' a +89,26410897 di declinazione, da Roma sta
// sempre fra 41,9 - 0,736 e 41,9 + 0,736 gradi d'altezza, a qualunque ora;
// la prova la guarda in ventiquattro ore di fila.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:flutter_test/flutter_test.dart';

const _simbad = <String, (double, double)>{
  'Sirius': (101.28715533, -16.71611586),
  'Vega': (279.23473479, 38.78368896),
  'Betelgeuse': (88.79293899, 7.40706400),
};
const _declinazioneDellaPolare = 89.26410897;
const _scartoMassimo = 0.003;

CatalogoDelleStelle _catalogo() => CatalogoDelleStelle.daiByte(
    ByteData.sublistView(File(kCatalogoBinario).readAsBytesSync()),
    nomiJson: File(kCatalogoNomi).readAsStringSync(),
    costellazioniJson: File(kCatalogoCostellazioni).readAsStringSync());

int _indice(CatalogoDelleStelle c, String nome) =>
    c.nomi.entries.firstWhere((e) => e.value == nome).key;

void main() {
  test('tre stelle note stanno dove le mette SIMBAD', () {
    final c = _catalogo();
    _simbad.forEach((nome, rif) {
      final i = _indice(c, nome);
      final dRa = (c.raGradi[i] - rif.$1).abs() * math.cos(rif.$2 * math.pi / 180);
      final dDec = (c.decGradi[i] - rif.$2).abs();
      expect(dRa, lessThanOrEqualTo(_scartoMassimo),
          reason: '$nome: ascensione retta ${c.raGradi[i]} contro ${rif.$1}');
      expect(dDec, lessThanOrEqualTo(_scartoMassimo),
          reason: '$nome: declinazione ${c.decGradi[i]} contro ${rif.$2}');
    });
  });

  test('la Stella Polare da Roma sta all\'altezza della latitudine', () {
    final c = _catalogo();
    final polare = _indice(c, 'Polaris');
    const lat = 41.9;
    const raggio = 90 - _declinazioneDellaPolare;
    final inizio = Celestial.julianDay(DateTime.utc(2026, 10, 8));
    for (var ora = 0; ora < 24; ora++) {
      final cielo = CieloInUnIstante.calcola(c,
          jd: inizio + ora / 24, latitudine: lat, longitudine: 12.5);
      final alt =
          math.asin(cielo.z[polare].clamp(-1.0, 1.0)) * 180 / math.pi;
      expect(alt, inInclusiveRange(lat - raggio - 0.01, lat + raggio + 0.01),
          reason: 'alle $ora UTC la Polare e\' a $alt gradi');
    }
  });
}
