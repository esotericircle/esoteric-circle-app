import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LO SBARRAMENTO DISTINGUE UN ROSSO NUOVO DA UNO ACCETTATO.
/// Ordine BZ voce 02.
///
/// **Il fatto.** La build 2167 e' stata prodotta da Codemagic, e' salita su App
/// Store Connect ed e' stata installata dai fondatori via TestFlight l'8 agosto
/// 2026. Il 12 agosto e' entrato lo sbarramento dell'ordine P voce 03, che
/// ferma l'archivio su qualunque rosso. Da quando in suite vive un rosso
/// dichiarato e accettato, nessuna build puo' piu' uscire: non e' una guardia,
/// e' una porta murata.
///
/// **La cura, e cosa questa prova misura.** Lo sbarramento adesso legge
/// `tool/rossi_accettati.txt`. Questa prova non lancia la suite: monta
/// rapporti finti e chiede allo script di giudicarli, che e' l'unico modo di
/// vedere lo sbarramento decidere senza aspettare tremilaottocento prove.
///
/// **Dove bash non c'e' non gira, e lo dice.** Lo sbarramento e' uno script
/// bash e la macchina che costruisce e' un Mac: dove bash manca la prova si
/// dichiara non eseguita invece di restare verde per finta.
void main() {
  final sbarramento = File('tool/sbarramento.sh');
  final registro = File('tool/rossi_accettati.txt');

  test('I due file esistono, e il file di build chiama lo sbarramento', () {
    expect(sbarramento.existsSync(), isTrue,
        reason: 'senza lo sbarramento la build costruisce su qualunque rosso');
    expect(registro.existsSync(), isTrue,
        reason: 'senza il registro un rosso accettato non ha dove essere '
            'scritto col suo nome e la sua ragione');
    final build = File('codemagic.yaml').readAsStringSync();
    expect(build.contains('tool/sbarramento.sh'), isTrue,
        reason: 'il file di build non lancia piu\' lo sbarramento');
    expect(sbarramento.readAsStringSync().contains('rossi_accettati.txt'),
        isTrue,
        reason: 'lo sbarramento non legge il registro dei rossi accettati: '
            'un rosso dichiarato tornerebbe a murare la porta');
  });

  test('Ogni riga del registro porta un nome E una ragione', () {
    final righe = registro
        .readAsLinesSync()
        .where((r) => r.trim().isNotEmpty && !r.trimLeft().startsWith('#'))
        .toList();
    // ignore: avoid_print
    print('ORDINE BZ VOCE 2: rossi accettati in registro ${righe.length}');
    for (final r in righe) {
      expect(r.contains('|'), isTrue,
          reason: 'la riga "$r" non porta la barra: un rosso accettato senza '
              'ragione scritta e\' uno scavalco silenzioso');
      final ragione = r.split('|').sublist(1).join('|').trim();
      expect(ragione.length, greaterThan(20),
          reason: 'la ragione di "$r" e\' troppo corta per dire qualcosa');
    }
  });

  test('Il fuso e\' dichiarato, e non e\' quello che capita alla macchina', () {
    final testo = sbarramento.readAsStringSync();
    expect(testo.contains('export TZ='), isTrue,
        reason: 'lo sbarramento non dichiara il fuso: il Mac che costruisce '
            'gira a UTC e il PC del fondatore a Roma, e le prove del cielo '
            'davano due cieli diversi');
    expect(testo.contains('Europe/Rome'), isTrue,
        reason: 'il fuso dichiarato non e\' quello del fondatore');
  });

  group('Lo sbarramento decide, e lo si guarda decidere', () {
    late Directory tana;
    late String bash;

    setUpAll(() {
      // Il bash di Git per Windows, se c'e': altrimenti quello di sistema.
      final candidati = <String>[
        'C:\\Program Files\\Git\\bin\\bash.exe',
        'C:\\Program Files\\Git\\usr\\bin\\bash.exe',
        '/usr/bin/bash',
        '/bin/bash',
      ];
      bash = candidati.firstWhere((c) => File(c).existsSync(), orElse: () => '');
    });

    setUp(() {
      tana = Directory.systemTemp.createTempSync('sbarramento');
    });

    tearDown(() {
      if (tana.existsSync()) tana.deleteSync(recursive: true);
    });

    /// Monta una copia dello sbarramento che, invece della suite, stampa il
    /// rapporto [rapporto] ed esce con [esito]. **Non si tocca lo script
    /// vero**: si sostituisce la sola riga che lancia `flutter test`, e la
    /// sostituzione si verifica prima di leggere l'esito.
    ProcessResult giudica(String rapporto, int esito, String accettati) {
      final copia = File('${tana.path}/sbarramento.sh');
      final finto = File('${tana.path}/rapporto.txt')
        ..writeAsStringSync(rapporto);
      var testo = sbarramento.readAsStringSync();
      const riga = r'flutter test "$@" 2>&1 | tee "$REGISTRO"';
      expect(testo.contains(riga), isTrue,
          reason: 'la riga che lancia la suite non e\' piu\' quella: questa '
              'prova starebbe misurando uno script che non esiste');
      testo = testo.replaceFirst(riga,
          'cat "${finto.path}" | tee "\$REGISTRO"; (exit $esito)');
      copia.writeAsStringSync(testo);
      File('${tana.path}/rossi_accettati.txt').writeAsStringSync(accettati);
      return Process.runSync(bash, [copia.path],
          workingDirectory: Directory.current.path);
    }

    const unaCaduta = '00:12 +3790 -1: Una prova qualunque che cade [E]\n'
        '  Expected: true\n'
        '  Actual: false\n'
        '\n'
        'Failing tests:\n'
        '  C:/qualcosa/test/una_prova_test.dart: Una prova qualunque che cade\n';

    const ragione = 'Una prova qualunque che cade | ragione scritta per la '
        'prova, con la data del 28 agosto 2026';

    test('Verde: l\'archivio si produce', () {
      if (bash.isEmpty) {
        // ignore: avoid_print
        print('ORDINE BZ VOCE 2: bash non c\'e\' su questa macchina, lo '
            'sbarramento non e\' stato guardato decidere');
        return;
      }
      final r = giudica('00:12 +3794: All tests passed!\n', 0, '');
      expect(r.exitCode, 0);
      expect(r.stdout.toString(), contains('SUITE VERDE'));
    });

    test('Rosso NUOVO: l\'archivio non si produce', () {
      if (bash.isEmpty) return;
      final r = giudica(unaCaduta, 1, '');
      expect(r.exitCode, 1,
          reason: 'un rosso che nessuno ha accettato non ferma la build: e\' '
              'esattamente il permesso di spedire su rosso');
      expect(r.stdout.toString(), contains('ROSSI NUOVI'));
      expect(r.stdout.toString(), contains('Una prova qualunque che cade'));
    });

    test('Rosso ACCETTATO: l\'archivio si produce, e il nome si stampa', () {
      if (bash.isEmpty) return;
      final r = giudica(unaCaduta, 1, ragione);
      expect(r.exitCode, 0,
          reason: 'un rosso gia\' accettato e scritto nel registro continua a '
              'murare la porta: e\' il difetto della voce');
      expect(r.stdout.toString(), contains('ROSSI ACCETTATI'));
      expect(r.stdout.toString(), contains('ragione scritta per la'));
    });

    test('Accettato UNO e caduti DUE: l\'archivio non si produce', () {
      if (bash.isEmpty) return;
      const dueCadute = '00:12 +3790 -1: Una prova qualunque che cade [E]\n'
          '00:12 +3790 -2: Una seconda prova, che nessuno ha mai visto [E]\n';
      final r = giudica(dueCadute, 1, ragione);
      expect(r.exitCode, 1,
          reason: 'con un rosso accettato in registro passa anche quello '
              'nuovo: il registro sarebbe diventato uno scavalco');
      expect(r.stdout.toString(),
          contains('Una seconda prova, che nessuno ha mai visto'));
    });

    test('Un rosso accettato che non cade piu\' viene segnalato', () {
      if (bash.isEmpty) return;
      final r = giudica(
          unaCaduta,
          1,
          '$ragione\nUna prova che non cade piu\' | ragione vecchia di un '
              'rosso che qualcuno ha gia\' curato');
      expect(r.stdout.toString(), contains('AVVISO'));
      expect(r.stdout.toString(), contains('Una prova che non cade piu'));
    });
  });
}
