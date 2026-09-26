import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LO SBARRAMENTO DIVISO SU PIU' MACCHINE.** Ordine ACCELERA, 26 settembre
/// 2026.
///
/// Il fondatore: *"Ma non c'e' modo di accelerare Suite, sbarramenti, ecc?"*
/// e *"Ma se l'accelerazione e' sempre disponibile, usala sempre"*. Lo
/// sbarramento di GitHub adesso gira su piu' macchine: sei pezzi della suite,
/// il corredo a scala 1,3, il server e le chiusure, e un'ultima macchina che
/// riunisce i registri e decide.
///
/// **Una divisione puo' perdere delle prove senza che nessuno se ne accorga**,
/// ed e' il rischio che questa guardia sorveglia: un file che non finisce in
/// nessun pezzo, un pezzo che la matrice non lancia, un registro che non
/// arriva. In tutti e tre i casi il cancello deve dirlo, non tacere.
void main() {
  final sbarramento = File('tool/sbarramento.sh');
  final verde = File('.github/workflows/verde.yml');

  String python() {
    for (final p in const ['python3', 'python']) {
      try {
        final r = Process.runSync(p, const ['--version']);
        if (r.exitCode == 0) return p;
      } catch (_) {
        // Quel nome qui non esiste: si prova il successivo.
      }
    }
    return 'python';
  }

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

  /// Il numero dei pezzi, letto dal flusso di GitHub dove lo sbarramento
  /// finale lo pretende.
  int pezziDelFlusso() {
    final m =
        RegExp(r'SBARRAMENTO_PEZZI=(\d+)').firstMatch(verde.readAsStringSync());
    expect(m, isNotNull, reason: 'verde.yml non dichiara SBARRAMENTO_PEZZI');
    return int.parse(m!.group(1)!);
  }

  test('ogni file di prova sta in un pezzo, e in uno solo', () {
    final quanti = pezziDelFlusso();
    final tutti = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceAll('\\', '/'))
        .where((p) => p.endsWith('_test.dart'))
        .map((p) => p.substring(p.indexOf('test/')))
        .toSet();
    // Oggi i file sono 1.071: margine dichiarato di settanta.
    cardinaleMinimo(tutti.length, 1000,
        cosa: 'file di prova in test/',
        perche: 'la divisione si misura su tutti i file della suite.');
    final visti = <String>[];
    for (var i = 0; i < quanti; i++) {
      final r = Process.runSync(
          python(), ['tool/i_pezzi_della_suite.py', '$quanti', '$i']);
      expect(r.exitCode, 0, reason: 'il pezzo $i non si calcola: ${r.stderr}');
      final file = (r.stdout as String)
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
      expect(file, isNotEmpty, reason: 'il pezzo $i e\' vuoto');
      visti.addAll(file);
    }
    final doppi = visti.length - visti.toSet().length;
    // ignore: avoid_print
    print('ACCELERA: $quanti pezzi, file ${tutti.length}, nei pezzi '
        '${visti.length}, doppi $doppi');
    expect(tutti.difference(visti.toSet()), isEmpty,
        reason: 'questi file non stanno in nessun pezzo, e su GitHub non '
            'girerebbero mai');
    expect(doppi, 0, reason: 'un file sta in due pezzi');
  });

  test('il flusso di GitHub lancia tutti i pezzi e decide alla fine', () {
    final testo = verde.readAsStringSync();
    final quanti = pezziDelFlusso();
    final matrice =
        RegExp(r'pezzo:\s*\[([\d,\s]+)\]').firstMatch(testo)?.group(1);
    expect(matrice, isNotNull, reason: 'la matrice dei pezzi non c\'e\'');
    final indici = matrice!.split(',').map((s) => int.parse(s.trim())).toList();
    expect(indici, List<int>.generate(quanti, (i) => i),
        reason: 'la matrice lancia $indici, e l\'ultima macchina aspetta i '
            'pezzi da 0 a ${quanti - 1}');
    expect(testo, contains('i_pezzi_della_suite.py $quanti '),
        reason: 'i pezzi si calcolano per un numero diverso da $quanti');
    expect(testo, contains('fail-fast: false'),
        reason: 'un pezzo rosso fermerebbe gli altri');
    expect(testo, contains('needs: [analisi, pezzo, scala, server_e_chiusure]'),
        reason: 'l\'ultima macchina non aspetta tutte le altre');
    expect(testo, contains(r'if: ${{ !cancelled() }}'),
        reason: 'l\'ultima macchina non decide quando un\'altra e\' caduta');
    expect(testo, contains('SBARRAMENTO_DA_REGISTRI=registri'));
    expect(testo, contains('SBARRAMENTO_SOLO=scala'));
    expect(testo, contains('SBARRAMENTO_SOLO=server'));
    expect(testo, contains('SBARRAMENTO_SOLO=chiusure'));
  });

  group('lo sbarramento sui registri delle macchine', () {
    late Directory tana;

    setUp(() => tana = Directory.systemTemp.createTempSync('diviso'));
    tearDown(() {
      if (tana.existsSync()) tana.deleteSync(recursive: true);
    });

    /// Monta lo sbarramento VERO, non modificato, in una cartella finta con
    /// il corredo accanto, e lo fa decidere sui [registri]: nome, rapporto,
    /// esito.
    ProcessResult decidi(Map<String, (String, int)> registri,
        {int pezzi = 2, String accettati = ''}) {
      Directory('${tana.path}/tool').createSync(recursive: true);
      Directory('${tana.path}/test').createSync(recursive: true);
      File('${tana.path}/test/screenshot_capture_test.dart')
          .writeAsStringSync('// il corredo finto\n');
      sbarramento.copySync('${tana.path}/tool/sbarramento.sh');
      File('${tana.path}/tool/rossi_accettati.txt')
          .writeAsStringSync(accettati);
      final dir = Directory('${tana.path}/registri')..createSync();
      for (final e in registri.entries) {
        File('${dir.path}/${e.key}.txt').writeAsStringSync(e.value.$1);
        File('${dir.path}/${e.key}.esito').writeAsStringSync('${e.value.$2}\n');
      }
      return Process.runSync(bash(), [
        '${tana.path}/tool/sbarramento.sh'
      ], environment: {
        'SBARRAMENTO_DA_REGISTRI': dir.path,
        'SBARRAMENTO_PEZZI': '$pezzi',
      });
    }

    const verdeCorredo = '00:01 +182: All tests passed!\n';
    Map<String, (String, int)> tuttiVerdi() => {
          'suite_0': ('00:01 +40: All tests passed!\n', 0),
          'suite_1': ('00:01 +35: All tests passed!\n', 0),
          'scala': (verdeCorredo, 0),
          'server': ('ok\n', 0),
        };

    test('tutti i pezzi verdi: suite verde, e il gettone conta la somma', () {
      final r = decidi(tuttiVerdi());
      expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
      expect(r.stdout, contains('SUITE VERDE'));
      final gettone =
          File('${tana.path}/build/sbarramento_passato.txt').readAsStringSync();
      expect(gettone, contains('prove=75'),
          reason: 'il gettone non somma le prove dei pezzi: $gettone');
    });

    test('un pezzo che manca ferma il cancello', () {
      final registri = tuttiVerdi()..remove('suite_1');
      final r = decidi(registri);
      expect(r.exitCode, isNot(0),
          reason: 'con un pezzo mancante il cancello ha detto verde:\n'
              '${r.stdout}');
      expect(r.stdout, contains('MANCA IL REGISTRO suite_1'));
      expect(r.stdout, isNot(contains('SUITE VERDE')));
    });

    test('un rosso accettato in un pezzo passa, uno nuovo no', () {
      final registri = tuttiVerdi()
        ..['suite_1'] = (
          '00:01 +34 -1: la prova antica [E]\n00:02 +34 -1: Some tests failed.\n',
          1
        );
      final accettato = decidi(registri,
          accettati: 'la prova antica | rossa da sempre, con la sua ragione '
              'scritta per esteso\n');
      expect(accettato.exitCode, 0, reason: '${accettato.stdout}');
      expect(accettato.stdout, contains('ROSSI ACCETTATI'));

      tana.deleteSync(recursive: true);
      tana = Directory.systemTemp.createTempSync('diviso');
      final nuovo = decidi(registri);
      expect(nuovo.exitCode, isNot(0), reason: '${nuovo.stdout}');
      expect(nuovo.stdout, contains('ROSSI NUOVI'));
      expect(nuovo.stdout, contains('la prova antica'));
    });

    // **DUE DIFETTI CHE C'ERANO GIA', trovati leggendo lo sbarramento per
    // dividerlo.** Il gettone si cancellava solo in fondo, e non sulle altre
    // uscite rosse: un gettone verde di prima, con lo stesso numero di build,
    // restava valido dopo un corredo che non aveva guardato abbastanza.
    test('ogni uscita rossa cancella il gettone', () {
      final registri = tuttiVerdi()
        ..['scala'] = ('00:01 +12: All tests passed!\n', 0);
      Directory('${tana.path}/build').createSync(recursive: true);
      final gettone = File('${tana.path}/build/sbarramento_passato.txt')
        ..writeAsStringSync('SBARRAMENTO_PASSATO\nnumero=1\n');
      final r = decidi(registri);
      expect(r.exitCode, isNot(0), reason: '${r.stdout}');
      expect(r.stdout, contains('HA GUARDATO 12 SCHERMATE'));
      expect(gettone.existsSync(), isFalse,
          reason: 'il corredo ha guardato 12 schermate e il gettone di prima '
              'e\' rimasto: la consegna lo prenderebbe per buono');
    });

    // E l'elenco dei rossi nuovi si stampava vuoto quando la suite cadeva
    // senza nominare nessuna prova: l'azzeramento stava dopo il nome.
    test('una suite caduta senza nomi lo dice nell\'elenco dei rossi nuovi',
        () {
      final registri = tuttiVerdi()
        ..['suite_1'] = ('00:01 +3: qualcosa si e\' rotto prima dei nomi\n', 1);
      final r = decidi(registri);
      expect(r.exitCode, isNot(0), reason: '${r.stdout}');
      expect(r.stdout, contains('ROSSI NUOVI'));
      expect(r.stdout, contains('(nessun nome letto)'),
          reason: 'l\'elenco dei rossi nuovi e\' vuoto:\n${r.stdout}');
    });

    // **NATA DAL PRIMO GIRO VERO SU GITHUB, 26 settembre 2026.** Le
    // variabili che dicono a una macchina "fai solo il tuo pezzo" arrivavano
    // anche alle prove di quel pezzo: le prove che lanciano una copia dello
    // sbarramento la trovavano in modalita' pezzo, e sei macchine su sei le
    // hanno viste cadere tutte. Sul PC erano verdi, perche' li' quelle
    // variabili non ci sono.
    test('le variabili dello sbarramento non arrivano a cio\' che lancia', () {
      Directory('${tana.path}/tool').createSync(recursive: true);
      var testo = sbarramento.readAsStringSync();
      const riga = r'flutter test -r expanded "$@" 2>&1 | tee "$REGISTRO"';
      expect(testo.contains(riga), isTrue);
      // Al posto della suite, cio' che vede un programma lanciato da qui.
      testo = testo.replaceFirst(
          riga, r'env | grep "^SBARRAMENTO_" | tee "$REGISTRO"; (exit 0)');
      File('${tana.path}/tool/sbarramento.sh').writeAsStringSync(testo);
      final uscita = '${tana.path}/registri';
      final r = Process.runSync(bash(), [
        '${tana.path}/tool/sbarramento.sh'
      ], environment: {
        'SBARRAMENTO_SOLO': 'suite',
        'SBARRAMENTO_USCITA': uscita,
        'SBARRAMENTO_PEZZO': '2',
      });
      expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
      final visto = File('$uscita/suite_2.txt').readAsStringSync().trim();
      expect(visto, isEmpty,
          reason: 'le prove lanciate dal pezzo vedono ancora: $visto');
    });

    test('la macchina di un pezzo conserva registro ed esito, e non decide',
        () {
      Directory('${tana.path}/tool').createSync(recursive: true);
      final finto = File('${tana.path}/rapporto.txt')
        ..writeAsStringSync('00:01 +3 -1: una prova [E]\n');
      var testo = sbarramento.readAsStringSync();
      const riga = r'flutter test -r expanded "$@" 2>&1 | tee "$REGISTRO"';
      expect(testo.contains(riga), isTrue);
      testo = testo.replaceFirst(
          riga, 'cat "${finto.path}" | tee "\$REGISTRO"; (exit 1)');
      File('${tana.path}/tool/sbarramento.sh').writeAsStringSync(testo);
      final uscita = '${tana.path}/registri';
      final r = Process.runSync(bash(), [
        '${tana.path}/tool/sbarramento.sh'
      ], environment: {
        'SBARRAMENTO_SOLO': 'suite',
        'SBARRAMENTO_USCITA': uscita,
        'SBARRAMENTO_PEZZO': '4',
      });
      expect(r.exitCode, 0,
          reason: 'la macchina del pezzo e\' caduta: il verdetto non e\' suo');
      expect(File('$uscita/suite_4.txt').readAsStringSync(),
          contains('una prova [E]'));
      expect(File('$uscita/suite_4.esito').readAsStringSync().trim(), '1');
      expect(r.stdout, isNot(contains('SUITE VERDE')));
      expect(r.stdout, isNot(contains('SUITE ROSSA')));
    });
  });
}
