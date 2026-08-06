// IL TARGET IOS E' IL MASSIMO SUI PODSPEC DI TUTTI I PLUGIN, NON DI ALCUNI.
//
// La terza build su Codemagic e' caduta in pod install: google_mlkit_commons
// pretendeva iOS 15.5 e il progetto dichiarava 15.0. Il 15.0 era una misura
// fatta sui soli podspec di Firebase, cioe' su un sottoinsieme, e il resto dei
// plugin non era mai stato enumerato. Questa prova chiude quel buco nel solo
// modo che non invecchia: NON fissa un numero, rifa' la misura. Legge
// l'elenco dei plugin iOS da .flutter-plugins-dependencies, apre i podspec e i
// Package.swift di ciascuno nella cache di pub, ne ricava il massimo dei
// minimi richiesti, e pretende che il progetto Xcode e il Podfile dichiarino
// almeno quel massimo. Quando un plugin nuovo alzera' l'asticella, cade lei
// sul PC, non il pod install su un Mac a pagamento.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Una versione iOS confrontabile, perche' "15.5" > "15.0" non e' un
/// confronto fra stringhe.
class _Versione implements Comparable<_Versione> {
  _Versione(this.testo)
      : maggiore = int.parse(testo.split('.').first),
        minore = testo.split('.').length > 1
            ? int.parse(testo.split('.')[1])
            : 0;

  final String testo;
  final int maggiore;
  final int minore;

  @override
  int compareTo(_Versione altra) => maggiore != altra.maggiore
      ? maggiore.compareTo(altra.maggiore)
      : minore.compareTo(altra.minore);

  @override
  String toString() => testo;
}

void main() {
  final manifesto = File('.flutter-plugins-dependencies');
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj');
  final podfile = File('ios/Podfile');

  // La misura si fa una volta e le prove la interrogano: plugin -> minimo.
  late Map<String, _Versione> minimi;
  late List<String> senzaNativo;

  setUpAll(() {
    expect(manifesto.existsSync(), isTrue,
        reason: 'Manca .flutter-plugins-dependencies: serve `flutter pub get` '
            'prima di questa prova.');
    final dati = jsonDecode(manifesto.readAsStringSync())
        as Map<String, dynamic>;
    final plugins = ((dati['plugins'] as Map<String, dynamic>)['ios'] as List)
        .cast<Map<String, dynamic>>();
    expect(plugins, isNotEmpty,
        reason: 'Flutter non dichiara nessun plugin iOS: o il progetto e\' '
            'cambiato radicalmente o il manifesto e\' rotto.');

    minimi = {};
    senzaNativo = [];
    final estrattori = [
      // s.ios.deployment_target = '15.5' nei podspec.
      RegExp("deployment_target\\s*=\\s*['\"](\\d+\\.\\d+)['\"]"),
      // s.platform = :ios, '15.5' nei podspec.
      RegExp("platform\\s*=?\\s*:ios\\s*,\\s*['\"](\\d+\\.\\d+)['\"]"),
      // .iOS("15.5") nei Package.swift.
      RegExp('\\.iOS\\(\\s*"(\\d+(?:\\.\\d+)?)"\\s*\\)'),
    ];
    // .iOS(.v15_5) oppure .iOS(.v15) nei Package.swift.
    final conVu = RegExp(r'\.iOS\(\.v(\d+)(?:_(\d+))?\)');

    for (final plugin in plugins) {
      final nome = plugin['name'] as String;
      final radice = plugin['path'] as String;
      final trovate = <_Versione>[];
      var haFileNativi = false;

      for (final sotto in ['ios', 'darwin']) {
        final cartella = Directory('$radice$sotto');
        if (!cartella.existsSync()) continue;
        for (final voce in cartella.listSync(recursive: true)) {
          if (voce is! File) continue;
          final base = voce.uri.pathSegments.last;
          if (!base.endsWith('.podspec') && base != 'Package.swift') continue;
          haFileNativi = true;
          final testo = voce.readAsStringSync();
          for (final estrattore in estrattori) {
            for (final m in estrattore.allMatches(testo)) {
              trovate.add(_Versione(m.group(1)!.contains('.')
                  ? m.group(1)!
                  : '${m.group(1)!}.0'));
            }
          }
          for (final m in conVu.allMatches(testo)) {
            trovate.add(_Versione('${m.group(1)}.${m.group(2) ?? '0'}'));
          }
        }
      }

      if (trovate.isEmpty) {
        // Nessun numero trovato. E' lecito in un caso solo: il plugin non ha
        // proprio codice nativo iOS, cioe' e' un plugin solo Dart
        // (dartPluginClass, come path_provider_foundation 2.6.0). Un plugin
        // CON podspec da cui non esce nessun numero e' invece un buco nella
        // misura, e la misura bucata e' esattamente l'errore che ha ucciso la
        // terza build.
        expect(haFileNativi, isFalse,
            reason: '$nome ha podspec o Package.swift ma non se ne ricava '
                'nessun minimo iOS: la misura e\' bucata, sistemare '
                'l\'estrazione prima di fidarsi del massimo.');
        senzaNativo.add(nome);
      } else {
        trovate.sort();
        minimi[nome] = trovate.last;
      }
    }
  });

  test('l\'enumerazione copre tutti i plugin, nessuno escluso', () {
    // Enumerare invece di campionare: ogni plugin iOS o ha un minimo misurato
    // o e' dichiarato solo Dart. Non esiste una terza categoria silenziosa.
    final dati = jsonDecode(manifesto.readAsStringSync())
        as Map<String, dynamic>;
    final quanti =
        ((dati['plugins'] as Map<String, dynamic>)['ios'] as List).length;
    expect(minimi.length + senzaNativo.length, quanti,
        reason: 'Su $quanti plugin iOS, ${minimi.length} hanno un minimo '
            'misurato e ${senzaNativo.length} sono solo Dart: la somma non '
            'torna, qualcuno e\' sfuggito alla misura.');
  });

  test('il progetto Xcode dichiara almeno il massimo dei plugin', () {
    final massimo = minimi.values.reduce(
        (a, b) => a.compareTo(b) >= 0 ? a : b);
    final colpevoli = minimi.entries
        .where((e) => e.value.compareTo(massimo) == 0)
        .map((e) => e.key)
        .join(', ');

    final testo = pbx.readAsStringSync();
    final dichiarati = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = (\d+\.\d+);')
        .allMatches(testo)
        .map((m) => _Versione(m.group(1)!))
        .toList();
    expect(dichiarati.length, 3,
        reason: 'Il target iOS e\' dichiarato in ${dichiarati.length} punti '
            'del pbxproj invece di tre: Debug, Release e Profile devono '
            'dirlo tutti.');
    for (final v in dichiarati) {
      expect(v.compareTo(massimo) >= 0, isTrue,
          reason: 'Il pbxproj dichiara iOS $v ma i plugin pretendono '
              '$massimo, imposto da: $colpevoli. E\' l\'errore della terza '
              'build, misurato su un sottoinsieme invece che su tutti.');
    }
    expect(dichiarati.map((v) => v.testo).toSet().length, 1,
        reason: 'Le tre configurazioni del pbxproj dichiarano numeri diversi '
            'fra loro: devono dire tutte lo stesso.');
  });

  test('il Podfile dichiara la piattaforma, e lo stesso numero del progetto',
      () {
    // CocoaPods avvisava: "Automatically assigning platform iOS ... because
    // no platform was specified". Il numero deve vivere nel Podfile,
    // esplicito, e coincidere con quello del progetto Xcode: due numeri
    // diversi nei due file sono una divergenza che si scopre solo in build.
    expect(podfile.existsSync(), isTrue,
        reason: 'Manca ios/Podfile: senza, CocoaPods assegna la piattaforma '
            'da solo copiandola dal progetto, e la scelta non vive in nessun '
            'posto leggibile.');
    final m = RegExp("^platform :ios, '(\\d+\\.\\d+)'", multiLine: true)
        .firstMatch(podfile.readAsStringSync());
    expect(m, isNotNull,
        reason: 'Il Podfile non dichiara `platform :ios`: CocoaPods torna a '
            'decidere da solo.');
    final delPodfile = _Versione(m!.group(1)!);

    final massimo = minimi.values.reduce(
        (a, b) => a.compareTo(b) >= 0 ? a : b);
    expect(delPodfile.compareTo(massimo) >= 0, isTrue,
        reason: 'Il Podfile dichiara iOS $delPodfile ma i plugin pretendono '
            '$massimo.');

    final delProgetto = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = (\d+\.\d+);')
        .firstMatch(pbx.readAsStringSync())!
        .group(1)!;
    expect(delPodfile.testo, delProgetto,
        reason: 'Podfile ($delPodfile) e pbxproj ($delProgetto) dichiarano '
            'due numeri diversi: devono coincidere.');
  });

  test('la misura vede davvero chi ha imposto il numero di oggi', () {
    // Il controllo della bilancia: se l'estrazione smettesse di leggere i
    // podspec di ML Kit, il massimo scenderebbe in silenzio e la prova
    // sarebbe verde per cecita'. I due plugin che oggi impongono il 15.5
    // devono risultare misurati, col valore che il pod install ha gridato
    // nella terza build.
    expect(minimi['google_mlkit_commons']?.testo, '15.5',
        reason: 'google_mlkit_commons non risulta piu' ' misurato a 15.5: o '
            'e\' stato tolto dal progetto, e allora questa riga si aggiorna, '
            'o l\'estrazione e\' diventata cieca.');
    expect(minimi['google_mlkit_face_detection']?.testo, '15.5',
        reason: 'google_mlkit_face_detection non risulta piu' ' misurato a '
            '15.5: o e\' stato tolto dal progetto o l\'estrazione e\' '
            'diventata cieca.');
  });
}
