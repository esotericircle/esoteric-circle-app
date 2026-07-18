import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final manifest = jsonDecode(File('docs/stato_asset.json').readAsStringSync()) as Map<String, dynamic>;
  final bundle = manifest['bundle_versionato'] as Map<String, dynamic>;

  test('pubspec dichiara esattamente gli asset attesi dal manifest', () {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final dichiarati = ((pubspec['flutter'] as YamlMap)['assets'] as YamlList).map((e) => e.toString()).toSet();
    final attesi = (bundle['pubspec_asset_attesi'] as List).map((e) => e.toString()).toSet();
    expect(dichiarati, attesi, reason: 'pubspec.yaml e docs/stato_asset.json non coincidono. Allineali insieme.');
  });

  test('i conteggi file in brand_assets coincidono col manifest', () {
    final conteggi = bundle['brand_assets_conteggi'] as Map<String, dynamic>;
    conteggi.forEach((cartella, atteso) {
      final dir = Directory('brand_assets/$cartella');
      final reale = dir.existsSync() ? dir.listSync().whereType<File>().length : -1;
      expect(reale, atteso as int, reason: 'brand_assets/$cartella ha $reale file, il manifest ne dichiara $atteso. Aggiorna docs/stato_asset.json.');
    });
  });

  test('i conteggi delle sei famiglie coincidono in piena e miniatura', () {
    final famiglie = bundle['famiglie_conteggi'] as Map<String, dynamic>;
    famiglie.forEach((famiglia, atteso) {
      for (final base in const ['assets/img', 'assets/img_thumb']) {
        final dir = Directory('$base/$famiglia');
        final reale = dir.existsSync()
            ? dir.listSync().whereType<File>().where((f) => f.path.endsWith('.webp')).length
            : -1;
        expect(reale, atteso as int, reason: '$base/$famiglia ha $reale file webp, il manifest ne dichiara $atteso. Se hai spostato o tolto un asset, aggiorna docs/stato_asset.json e le cartelle insieme.');
      }
    });
  });
}
