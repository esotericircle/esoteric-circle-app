// GUARDIA 7.4 DELL'ORDINE FG: IL VELO NON SI DISEGNA SENZA IL SUO ASSET.
//
// La prova enumera i dodici segni (Zodiac.values, non un elenco scritto qui)
// e per ciascuno pretende il file che la schermata carichera'
// (assetDelVelo, la stessa strada del codice) e la cartella dichiarata nel
// pubspec: in Flutter le cartelle degli asset non sono ricorsive, e senza la
// riga il file non entrerebbe nel pacchetto.

import 'dart:io';

import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _cartella = 'assets/img/zodiac_velo/';

List<String> difettiDeiVeli({
  required Iterable<Zodiac> segni,
  required bool Function(String) esiste,
  required Set<String> dichiarati,
}) {
  final difetti = <String>[];
  for (final s in segni) {
    if (!s.assetDelVelo.startsWith(_cartella)) {
      difetti.add('${s.italianName}: il velo ${s.assetDelVelo} sta fuori da $_cartella');
    }
    if (!esiste(s.assetDelVelo)) {
      difetti.add('${s.italianName}: manca ${s.assetDelVelo}');
    }
  }
  if (!dichiarati.contains(_cartella)) {
    difetti.add('il pubspec non dichiara $_cartella');
  }
  return difetti;
}

void main() {
  test('dodici segni, dodici veli, la cartella nel pubspec', () {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final dichiarati = ((pubspec['flutter'] as YamlMap)['assets'] as YamlList)
        .map((e) => e.toString())
        .toSet();
    expect(Zodiac.values.length, 12);
    final difetti = difettiDeiVeli(
      segni: Zodiac.values,
      esiste: (p) => File(p).existsSync(),
      dichiarati: dichiarati,
    );
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}
