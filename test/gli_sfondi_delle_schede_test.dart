import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **GLI SFONDI DELLE SCHEDE SONO NEL REPOSITORY E OGNI ARTE HA I SUOI TRE.**
/// Ordine EO voce 01, 26 settembre 2026. Il fondatore: *"Allora, iniziamo a
/// fare tutte le schede dell'ultimo elenco, 10 per ogni maestro."*
///
/// **Il cardinale e' dichiarato**: 99 file, trenta arti per tre formati piu'
/// i tre sfondi dei Maestri. Una guardia che scorresse la cartella vuota
/// sarebbe verde senza aver guardato niente.
void main() {
  const cardinale = 99;

  test('i 99 WebP stanno in assets/schede/ e il pubspec li registra', () {
    final cartella = Directory(GliSfondiDelleSchede.cartella);
    final webp = cartella
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    cardinaleMinimo(webp.length, cardinale,
        cosa: 'WebP in assets/schede',
        perche: 'la guardia degli sfondi scorre la cartella.');
    expect(webp.length, cardinale,
        reason: 'in assets/schede/ ci sono ${webp.length} WebP');
    final altri = cartella
        .listSync()
        .whereType<File>()
        .where((f) => !f.path.endsWith('.webp'));
    expect(altri, isEmpty,
        reason: 'PNG o JPG di lavorazione sono entrati nel repository');
    final tutti = GliSfondiDelleSchede.tutti();
    expect(tutti.length, cardinale);
    for (final f in tutti) {
      expect(File(f).existsSync(), isTrue, reason: 'manca $f');
    }
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('    - assets/schede/'),
        reason: 'la cartella degli sfondi non e\' registrata');
  });

  test('dieci arti per Maestro, tutte del catalogo e del loro Maestro', () {
    for (final m in Maestro.values) {
      final ids = {
        for (final s in ArtCatalog.forMaestro(m))
          for (final a in s.arts) a.id
      };
      final suoi = GliSfondiDelleSchede.nomi.keys.where(ids.contains).toList();
      expect(suoi, hasLength(10),
          reason: '${m.displayName} ha ${suoi.length} arti con lo sfondo');
    }
    expect(GliSfondiDelleSchede.nomi, hasLength(30));
  });

  test('i formati hanno le misure dell\'ordine', () {
    expect(FormatoDellaScheda.verticale.proporzione, 0.8);
    expect(FormatoDellaScheda.quadrata.proporzione, 1);
    expect(FormatoDellaScheda.orizzontale.proporzione, closeTo(16 / 9, 1e-9));
    expect(
        GliSfondiDelleSchede.perArte('rune_draw', FormatoDellaScheda.verticale),
        'assets/schede/Rune-Vert-1.webp');
    expect(
        GliSfondiDelleSchede.delMaestro(
            Maestro.caligo, FormatoDellaScheda.orizzontale),
        'assets/schede/Sfondo-Caligo-Oriz-1.webp');
  });
}
