// GUARDIA 15.5 DELL'ORDINE FH: OGNI ASSET DEL COSMO HA IL SUO FILE.
//
// La prova enumera i dieci asset che il Real Time Cosmo carica
// (AssetDelCosmo.values, la stessa strada del codice) e cade se per uno manca
// il file in assets/img/cosmo/ oppure se la cartella non e' dichiarata nel
// pubspec: in Flutter le cartelle degli asset non sono ricorsive, e senza la
// riga il file non entrerebbe nel pacchetto. Pretende anche il file delle
// linee delle figure, che il cielo legge in assets/astro/.

import 'dart:io';

import 'package:esoteric_circle/features/real_time_cosmo/gli_asset_del_cosmo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

List<String> difettiDegliAsset({
  required Iterable<String> percorsi,
  required bool Function(String) esiste,
  required Set<String> dichiarati,
}) {
  final difetti = <String>[];
  for (final p in percorsi) {
    if (!esiste(p)) difetti.add('manca $p');
    final cartella = p.substring(0, p.lastIndexOf('/') + 1);
    if (!dichiarati.contains(cartella)) {
      difetti.add('il pubspec non dichiara $cartella (per $p)');
    }
  }
  return difetti;
}

void main() {
  test('dieci asset del cosmo e le linee delle figure, coi loro file', () {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final dichiarati = ((pubspec['flutter'] as YamlMap)['assets'] as YamlList)
        .map((e) => e.toString())
        .toSet();
    final percorsi = [
      for (final a in AssetDelCosmo.values) a.percorso,
      kLineeDelleFigure,
    ];
    expect(AssetDelCosmo.values.length, 10);
    final difetti = difettiDegliAsset(
      percorsi: percorsi,
      esiste: (p) => File(p).existsSync(),
      dichiarati: dichiarati,
    );
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}
