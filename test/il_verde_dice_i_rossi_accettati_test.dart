// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **IL VERDE DICE IL VERO. Ordine FC voce 08, 4 ottobre 2026.**
///
/// La premessa dell'ordine, "il cancello non esegue la suite intera", non
/// regge: dall'ordine ACCELERA `verde.yml` la esegue in sei pezzi paralleli e
/// cade per ogni rosso che nessuno ha accettato. Il difetto vero era un
/// altro, della stessa famiglia dello strumento di misura che mente: un verde
/// con dei rossi accettati e un verde pieno si leggevano uguali. L'elenco
/// stava nel registro del giro, che senza credenziali non si legge, e per
/// settimane nessun rapporto ha detto che dentro il verde c'erano diciassette
/// prove rosse (sette della suite e dieci del corredo a scala 1,3).
///
/// Adesso la macchina finale, a verde, pubblica un'annotazione con quanti e
/// quali rossi ha accettato. Questa prova pretende il passo nel flusso, e fa
/// girare lo script su un registro scritto come lo scrive lo sbarramento.
void main() {
  test('FC.08: il flusso pubblica il verde coi rossi accettati', () {
    final flusso = File('.github/workflows/verde.yml').readAsStringSync();
    final passo = RegExp(
            r'if: success\(\)\s*\n\s*run: bash tool/il_verdetto_del_cancello\.sh /tmp/sbarramento\.txt verde')
        .hasMatch(flusso);
    final suite = RegExp(r'pezzo: \[0, 1, 2, 3, 4, 5\]').hasMatch(flusso);
    print('ORDINE FC VOCE 08: la suite intera nel cancello in sei pezzi '
        '$suite; il passo del verde coi rossi accettati $passo');
    expect(suite, isTrue, reason: 'il cancello non esegue piu\' la suite');
    expect(passo, isTrue,
        reason: 'a verde il cancello non dice piu\' i rossi accettati');
  });

  test('FC.08: lo script dice quanti e quali rossi sono accettati', () {
    final bash = Process.runSync('bash', ['--version']);
    // **NON SI SALTA, ordine FC voce 11.2**: bash c'e' su ogni macchina del
    // progetto (Git Bash sul PC, Linux su GitHub). Se manca, la prova lo
    // dice cadendo invece di saltarsi.
    expect(bash.exitCode, 0, reason: 'bash non c\'e\' su questa macchina');
    final cartella = Directory.systemTemp.createTempSync('verdetto');
    final conRossi = File('${cartella.path}/con_rossi.txt')
      ..writeAsStringSync('''
riga qualunque
----------------------------------------------------------------------
  ROSSI ACCETTATI, E SOLO QUELLI. L'ARCHIVIO SI PRODUCE.
----------------------------------------------------------------------
  prima prova rossa | la sua ragione
  seconda prova rossa | la sua ragione
----------------------------------------------------------------------
''');
    final pieno = File('${cartella.path}/pieno.txt')
      ..writeAsStringSync('tutto verde\n');
    String esegui(File f) => (Process.runSync(
            'bash', ['tool/il_verdetto_del_cancello.sh', f.path, 'verde'])
        .stdout as String);
    final uno = esegui(conRossi);
    final due = esegui(pieno);
    cartella.deleteSync(recursive: true);
    print('ORDINE FC VOCE 08: verde con rossi: ${uno.trim()}; verde pieno: '
        '${due.trim()}');
    expect(uno, contains('::warning'));
    expect(uno, contains('VERDE CON 2 ROSSI ACCETTATI'));
    expect(uno, contains('prima prova rossa'));
    expect(uno, contains('seconda prova rossa'));
    expect(due, contains('::notice'));
    expect(due, isNot(contains('::warning')));
  });
}
