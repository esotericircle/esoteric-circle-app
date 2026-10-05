// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CANCELLO ESEGUE TUTTE LE PROVE DEL RAMO. Ordine FC voce 11.2, 5
/// ottobre 2026.**
///
/// Il fondatore: *"Il cancello su GitHub deve eseguire tutte le prove del
/// ramo, non una parte [...] un cancello che esegue una parte delle prove
/// dichiara un verde che non esiste."*
///
/// Misurato sul giro 37215562849 (commit `bcf8eaff`): il cancello eseguiva
/// tutti i 1248 file, ma 11 casi si saltavano a ogni giro (6 anteprime senza
/// la loro variabile, 5 banchi col modello vero senza token), e il suo
/// numero contava solo le passate (6685 su 6703). Adesso le anteprime girano
/// sempre e scrivono solo a richiesta, i banchi col modello stanno fra gli
/// strumenti (`tool/banchi_col_modello/`), e lo sbarramento conta passate,
/// rosse e saltate di ogni pezzo e **cade se un solo caso e' saltato**.
/// Questa guardia lo prova sullo sbarramento vero, coi registri finti.
void main() {
  String bash() {
    const candidati = <String>[
      'C:\\Program Files\\Git\\bin\\bash.exe',
      'C:\\Program Files\\Git\\usr\\bin\\bash.exe',
      '/usr/bin/bash',
      '/bin/bash',
    ];
    return candidati.firstWhere((c) => File(c).existsSync(),
        orElse: () => 'bash');
  }

  late Directory tana;
  setUp(() => tana = Directory.systemTemp.createTempSync('cancello'));
  tearDown(() {
    if (tana.existsSync()) tana.deleteSync(recursive: true);
  });

  ProcessResult decidi(Map<String, (String, int)> registri) {
    Directory('${tana.path}/tool').createSync(recursive: true);
    Directory('${tana.path}/test').createSync(recursive: true);
    File('${tana.path}/test/screenshot_capture_test.dart')
        .writeAsStringSync('// il corredo finto\n');
    File('tool/sbarramento.sh').copySync('${tana.path}/tool/sbarramento.sh');
    File('${tana.path}/tool/rossi_accettati.txt').writeAsStringSync('');
    final dir = Directory('${tana.path}/registri')..createSync();
    for (final e in registri.entries) {
      File('${dir.path}/${e.key}.txt').writeAsStringSync(e.value.$1);
      File('${dir.path}/${e.key}.esito').writeAsStringSync('${e.value.$2}\n');
    }
    return Process.runSync(bash(), [
      '${tana.path}/tool/sbarramento.sh'
    ], environment: {
      'SBARRAMENTO_DA_REGISTRI': dir.path,
      'SBARRAMENTO_PEZZI': '2',
    });
  }

  Map<String, (String, int)> verdi() => {
        'suite_0': ('00:01 +40: All tests passed!\n', 0),
        'suite_1': ('00:01 +35: All tests passed!\n', 0),
        'scala': ('00:01 +182: All tests passed!\n', 0),
        'server': ('✔ una prova (1.2ms)\nℹ tests 185\n', 0),
      };

  test('il cancello dice quanti casi ha eseguito, e quanti del server', () {
    final r = decidi(verdi());
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect(
        r.stdout,
        contains(
            'IL CANCELLO HA ESEGUITO 75 CASI: 75 passati, 0 rossi, 0 saltati'));
    expect(r.stdout, contains('IL SERVER HA ESEGUITO 185 CASI'));
    final gettone =
        File('${tana.path}/build/sbarramento_passato.txt').readAsStringSync();
    expect(gettone, contains('eseguite=75'));
    expect(gettone, contains('saltate=0'));
    print(
        'FC.11.2: tutti verdi, "${RegExp(r'IL CANCELLO HA ESEGUITO[^=]*').firstMatch('${r.stdout}')!.group(0)!.trim()}"');
  });

  test('un caso saltato ferma il cancello, anche con tutto il resto verde', () {
    final registri = verdi()
      ..['suite_1'] = ('00:01 +34 ~1: All tests passed!\n', 0);
    final r = decidi(registri);
    expect(r.exitCode, isNot(0),
        reason: 'un caso saltato e il cancello ha detto verde:\n${r.stdout}');
    expect(r.stdout, contains('CASI SALTATI: 1'));
    expect(r.stdout, contains('CASI SALTATI NEL CANCELLO'));
    expect(r.stdout, isNot(contains('SUITE VERDE')));
    print('FC.11.2: un caso saltato, uscita ${r.exitCode}');
  });

  test('un rosso del server col nome nel formato spec ferma il cancello', () {
    final registri = verdi()
      ..['server'] = ('✖ la prova del server (2.1ms)\nℹ tests 185\n', 1);
    final r = decidi(registri);
    expect(r.exitCode, isNot(0), reason: '${r.stdout}');
    expect(r.stdout, contains('la prova del server'));
  });

  test('lo script del server chiede il rapporto spec', () {
    final pacchetto = File('functions/package.json').readAsStringSync();
    expect(pacchetto, contains('node --test --test-reporter=spec'),
        reason: 'senza, su GitHub il server scrive TAP e lo sbarramento non '
            'legge il nome di una prova caduta');
  });

  test('nessuna prova del ramo si salta da sola', () {
    // Le forme del salto: un `skip:` vero, o markTestSkipped.
    final file = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .toList();
    cardinaleMinimo(file.length, 1200, cosa: 'file di prova del ramo');
    final salti = <String>[];
    // "skip: false" non salta niente: il guardare avanti sta subito dopo i
    // due punti, cosi' gli spazi non lo possono scavalcare.
    final skip = RegExp(r'^\s*skip:(?!\s*false\b)', multiLine: true);
    for (final f in file) {
      if (f.path
          .replaceAll('\\', '/')
          .endsWith('il_cancello_esegue_tutte_le_prove_test.dart')) {
        continue;
      }
      final t = f.readAsStringSync();
      if (skip.hasMatch(t) || t.contains('markTestSkipped(')) {
        salti.add(f.path);
      }
    }
    print('FC.11.2: file di prova ${file.length}, che si saltano '
        '${salti.length} $salti');
    expect(salti, isEmpty,
        reason: 'queste prove si saltano: il cancello non le esegue');
  });
}
