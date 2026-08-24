import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA VERSIONE DI FLUTTER E' UNA SOLA. Ordine AH voce 01.
///
/// **Il difetto**: GitHub Actions e Codemagic dichiaravano il solo canale
/// stable senza numero, quindi due build a settimane di distanza potevano
/// usare due Flutter diversi, e un archivio che nessuno sa rifare identico
/// non e' verificabile.
///
/// **Il numero sovrano vive in UN posto**, `docs/versione_flutter.json`, con
/// la data della misura sul PC di Mauro. Questa prova legge il sovrano e i
/// due file della CI e pretende che i tre numeri coincidano: chi rialza
/// domani rialza tutto insieme, o la suite lo ferma nominando il file
/// disallineato.
void main() {
  const sovrano = 'docs/versione_flutter.json';
  const actions = '.github/workflows/android-build.yml';
  const codemagic = 'codemagic.yaml';

  // **ANCHE RONDA E VERDE, ordine BF voce 05.i.** Dichiaravano "channel:
  // stable" senza numero, cioe' la stable del giorno: un rialzo a monte
  // avrebbe cambiato la CI sotto i piedi senza nessun commit.
  const altre = ['.github/workflows/ronda.yml', '.github/workflows/verde.yml'];

  test('il sovrano e i due file della CI portano lo stesso numero', () {
    final dichiarata = (jsonDecode(File(sovrano).readAsStringSync())
        as Map<String, dynamic>)['flutter'] as String;
    expect(RegExp(r'^\d+\.\d+\.\d+$').hasMatch(dichiarata), isTrue,
        reason: 'il sovrano porta "$dichiarata", che non e\' un numero di '
            'versione: senza numero non c\'e\' niente da fissare');

    // La riga di Actions: flutter-version dentro l'azione di setup.
    final testoActions = File(actions).readAsStringSync();
    final versioneActions = RegExp(r'flutter-version:\s*([\d.]+)')
        .firstMatch(testoActions)
        ?.group(1);

    // La riga di Codemagic: il campo flutter del workflow.
    final testoCodemagic = File(codemagic).readAsStringSync();
    final versioneCodemagic =
        RegExp(r'^\s+flutter:\s*([\d.]+)\s*$', multiLine: true)
            .firstMatch(testoCodemagic)
            ?.group(1);

    // **QUANTE OSSERVAZIONI, e cade se una manca.**
    // ignore: avoid_print
    print('ORDINE AH VOCE 01: sovrano $dichiarata, Actions '
        '${versioneActions ?? "ASSENTE"}, Codemagic '
        '${versioneCodemagic ?? "ASSENTE"}');
    expect(versioneActions, isNotNull,
        reason: '$actions non porta nessun flutter-version col numero: la '
            'versione non e\' fissata li\'');
    expect(versioneCodemagic, isNotNull,
        reason: '$codemagic non porta nessun campo flutter col numero: la '
            'versione non e\' fissata li\'');
    final disallineati = <String>[
      if (versioneActions != dichiarata)
        '$actions dice $versioneActions contro $dichiarata',
      if (versioneCodemagic != dichiarata)
        '$codemagic dice $versioneCodemagic contro $dichiarata',
    ];
    expect(disallineati, isEmpty,
        reason: 'la versione di Flutter non e\' piu\' una sola: '
            '${disallineati.join(" | ")}. Chi rialza, rialza il sovrano '
            '$sovrano e i due file della CI insieme');
  });
}
