// IL CATALOGO DELLE STELLE DEL REAL TIME COSMO SI LEGGE COM'E' SCRITTO.
// Ordine FG parte 1.
//
// Le misure le ha prese il generatore sul CSV HYG v4.1 scaricato l'8 ottobre
// 2026 (impronta in tool/il_catalogo_delle_stelle_hyg.py): 5.071 righe al
// taglio 6,0, cioe' 5.070 stelle piu' il Sole che non entra; 347 nomi propri
// dopo il taglio sui 465 del catalogo intero; 23 stelle senza indice di
// colore; 88 costellazioni. Qui si prova che il lettore le ritrova tutte dai
// file del pacchetto, e che un file diverso lo fa sollevare invece di
// indovinare.

import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogoDelleStelle _leggi([Uint8List? binario]) {
  final b = binario ?? File(kCatalogoBinario).readAsBytesSync();
  return CatalogoDelleStelle.daiByte(ByteData.sublistView(b),
      nomiJson: File(kCatalogoNomi).readAsStringSync(),
      costellazioniJson: File(kCatalogoCostellazioni).readAsStringSync());
}

void main() {
  test('il catalogo ha le misure della cottura', () {
    final c = _leggi();
    expect(c.numeroDiStelle, 5070);
    expect(File(kCatalogoBinario).lengthSync(), 24 + 5070 * 12);
    expect(c.taglioDiMagnitudine, 6.0);
    expect(c.epocaJd, 2451545.0);
    expect(c.nomi.length, 347);
    expect(c.costellazioni.length, 88);
    // Ordine FH, fatto 1: la mappa da HIP a indice, 5.041 stelle su 5.070.
    expect(c.perHip.length, 5041);
    expect(c.nomi[c.perHip[32349]!], 'Sirius');
    expect(c.indiceDiColore.where((x) => x.isNaN).length, 23);
    expect(c.magnitudine.every((m) => m <= 6.0), isTrue);
    // In ordine di magnitudine crescente, Sirio in testa.
    for (var i = 1; i < c.numeroDiStelle; i++) {
      expect(c.magnitudine[i] >= c.magnitudine[i - 1], isTrue,
          reason: 'stella $i fuori ordine');
    }
    expect(c.nomi[0], 'Sirius');
    expect(c.sigle[0], 'α CMa');
    expect(c.costellazioneDi(0), 'CMa');
    // Il Sole non c'e'.
    expect(c.nomi.values, isNot(contains('Sol')));
    // Ogni stella sta in una costellazione e in una sola.
    final tutte = [for (final l in c.costellazioni.values) ...l];
    expect(tutte.length, c.numeroDiStelle);
    expect(tutte.toSet().length, c.numeroDiStelle);
  });

  test('ogni costellazione elenca le sue stelle dalla piu\' luminosa', () {
    final c = _leggi();
    for (final e in c.costellazioni.entries) {
      for (var k = 1; k < e.value.length; k++) {
        expect(c.magnitudine[e.value[k]] >= c.magnitudine[e.value[k - 1]],
            isTrue,
            reason: '${e.key}: ${e.value[k]} fuori ordine');
      }
    }
    expect(c.nomi[c.costellazioni['Leo']!.first], 'Regulus');
  });

  test('una firma diversa solleva', () {
    final b = Uint8List.fromList(File(kCatalogoBinario).readAsBytesSync());
    b[0] = 0x58; // 'X'
    expect(() => _leggi(b), throwsA(isA<FormatException>()));
  });

  test('una versione diversa solleva', () {
    final b = Uint8List.fromList(File(kCatalogoBinario).readAsBytesSync());
    b[4] = 2;
    expect(() => _leggi(b), throwsA(isA<FormatException>()));
  });

  test('un binario troncato solleva', () {
    final b = File(kCatalogoBinario).readAsBytesSync();
    expect(() => _leggi(Uint8List.sublistView(b, 0, b.length - 12)),
        throwsA(isA<FormatException>()));
  });
}
