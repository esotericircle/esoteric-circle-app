import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Il numero di versione deve crescere sempre.
///
/// Android rifiuta di installare un versionCode piu' basso sopra uno piu' alto.
/// La release del 28 luglio notte portava il numero 1 contro il 2001 di quella
/// del giorno prima, quindi sul telefono non si sovrapponeva: il 2001 veniva da
/// `--split-per-abi`, che somma duemila per l'ABI arm64, e togliendo lo split il
/// numero e' tornato a uno senza che nessuno se ne accorgesse.
///
/// Qui il numero si legge dal pubspec, cioe' dall'unica sorgente che vale per
/// ogni modo di costruire, e si confronta con l'ultimo davvero consegnato.
void main() {
  int numeroDiBuild() {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final versione = pubspec['version'] as String;
    final piu = versione.indexOf('+');
    expect(piu, greaterThan(0),
        reason: 'la versione del pubspec deve portare il numero di build '
            'dopo il segno piu\', per esempio 0.1.0+2100');
    return int.parse(versione.substring(piu + 1));
  }

  int ultimoDistribuito() {
    final j =
        jsonDecode(File('docs/versione_distribuita.json').readAsStringSync())
            as Map<String, dynamic>;
    return j['ultimo_distribuito'] as int;
  }

  test('Il numero di build non scende sotto l\'ultimo distribuito', () {
    final ora = numeroDiBuild();
    final prima = ultimoDistribuito();
    // Android rifiuta un versionCode piu' BASSO di quello gia' installato,
    // mentre lo stesso numero si sovrascrive senza storie: la regola da tenere
    // e' che non si scenda. Salire resta buona pratica quando cambia il
    // contenuto della release, ma non e' il telefono a imporlo.
    expect(ora, greaterThanOrEqualTo(prima),
        reason: 'una build con numero $ora non si installa sopra la $prima '
            'gia\' sul telefono: alza il numero nel pubspec');
  });

  test('Il numero di build e\' un intero positivo e non torna indietro', () {
    final ora = numeroDiBuild();
    expect(ora, greaterThan(0));
    // Il vecchio schema sommava duemila per l'ABI: qualunque numero nuovo deve
    // stare sopra quella soglia, altrimenti chi ha installato una release
    // costruita col vecchio comando resta bloccato.
    expect(ora, greaterThan(2001),
        reason: 'le release costruite con lo split arrivavano a 2001');
  });
}
