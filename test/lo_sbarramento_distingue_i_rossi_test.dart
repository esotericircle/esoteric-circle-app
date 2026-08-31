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

  test('IL SECONDO CANCELLO: lo sbarramento guarda anche la suite del '
      'server', () {
    // **Ordine CF voce 18, e il fatto che lo motiva.** L'ordine CE e'
    // stato consegnato dichiarando "4.032 prove, un solo rosso", ed era
    // vero solo per le prove Flutter: le prove del server erano DUE
    // ROSSE, e nessuno le guardava perche' quella suite non era toccata
    // ne' da `flutter test` ne' da questo file. **Una suite che nessun
    // cancello guarda non e' una rete di sicurezza.**
    final testo = sbarramento.readAsStringSync();
    expect(testo.contains('npm test'), isTrue,
        reason: 'lo sbarramento non esegue piu\' la suite del server: torna '
            'a esistere una seconda suite che nessuno guarda');
    expect(testo.contains('functions'), isTrue,
        reason: 'lo sbarramento non sa dove vive la suite del server');
    // **E i suoi rossi finiscono nello STESSO registro**, quindi passano
    // solo se dichiarati, come ogni altro.
    expect(testo.contains('REGISTRO_SERVER'), isTrue,
        reason: 'lo sbarramento non legge i nomi delle prove cadute del '
            'server: un rosso del server fermerebbe la build senza dire '
            'quale prova, e non potrebbe mai essere accettato per nome');
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

    // **I RAPPORTI FINTI PORTANO IL PERCORSO, ordine BZ voce 02,
    // integrazione del 28 agosto.** Quando `flutter test` gira su PIU' file
    // il rapporto mette davanti al nome della prova il PERCORSO ASSOLUTO
    // del file; su un file solo non lo mette. Questi rapporti erano scritti
    // nella forma del file singolo, quindi la guardia era CIECA sul caso
    // vero, che e' la suite intera: la stessa prova risultava insieme
    // guarita e nuova, e la build dei fondatori non usciva.
    //
    // Adesso ce ne sono TRE forme: senza percorso, col percorso del PC, e
    // col percorso della macchina che costruisce, /Users/builder/clone.
    // Quest'ultima e' l'unica che risponde alla domanda dell'ordine, cioe'
    // se il riconoscimento regge su una macchina che qui non c'e'.
    const nome = 'Una prova qualunque che cade';
    const cadutaNuda = '00:12 +3790 -1: $nome [E]\n';
    const cadutaDalPc = '00:12 +3790 -1: '
        'C:/Users/user/Desktop/esoteric-circle-app/test/una_prova_test.dart: '
        '$nome [E]\n';
    const cadutaDalMac = '00:12 +3790 -1: '
        '/Users/builder/clone/test/una_prova_test.dart: $nome [E]\n';
    const unaCaduta = cadutaNuda;

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

    test('Un rosso accettato si riconosce ANCHE col percorso del PC', () {
      if (bash.isEmpty) return;
      final r = giudica(cadutaDalPc, 1, ragione);
      expect(r.exitCode, 0,
          reason: 'col percorso davanti al nome il registro non riconosce '
              'piu\' la propria riga: e\' il difetto che ha tenuto fermo '
              'l\'archivio');
      expect(r.stdout.toString(), contains('ROSSI ACCETTATI'));
      expect(r.stdout.toString(), isNot(contains('AVVISO')),
          reason: 'la stessa prova risulta insieme accettata e guarita');
    });

    test('E ANCHE col percorso della macchina che costruisce', () {
      if (bash.isEmpty) return;
      // **QUESTA E' LA DOMANDA DELL'ORDINE**: una prova gia' accettata viene
      // riconosciuta su QUALUNQUE macchina? Il percorso del Mac di Codemagic
      // qui non esiste, ma nel confronto non entra piu': si verifica dando
      // allo sbarramento una riga scritta come la scrive quella macchina.
      final r = giudica(cadutaDalMac, 1, ragione);
      expect(r.exitCode, 0,
          reason: 'sulla macchina che costruisce il registro non riconosce '
              'la propria riga, e l\'archivio non si produce');
      expect(r.stdout.toString(), contains('ROSSI ACCETTATI'));
      expect(r.stdout.toString(), isNot(contains('ROSSI NUOVI')));
    });

    test('E un rosso NUOVO sbarra anche col percorso del Mac', () {
      if (bash.isEmpty) return;
      final r = giudica(cadutaDalMac, 1, '');
      expect(r.exitCode, 1,
          reason: 'togliendo il percorso dal confronto e\' passato anche un '
              'rosso che nessuno ha accettato');
      expect(r.stdout.toString(), contains('ROSSI NUOVI'));
    });
    // **UNA RIGA CHE SOPRAVVIVE ALLA SUA RAGIONE FA CADERE. Ordine CH voce
    // 04.** Fino al 31 agosto 2026 questo caso stampava "AVVISO" e la build
    // usciva lo stesso, e per giunta il confronto viveva SOLO nel ramo rosso:
    // con la suite verde non veniva eseguito affatto, cioe' proprio nel caso
    // in cui una riga vecchia si riconosce meglio.
    //
    // Quel registro e' l'unico posto in cui un difetto puo' essere messo a
    // tacere legalmente: se una riga ci resta dopo che la sua ragione e'
    // finita, la rete di sicurezza si spegne un pezzo alla volta.
    test('Un rosso accettato che non cade piu\' FERMA la build', () {
      if (bash.isEmpty) return;
      final r = giudica(
          unaCaduta,
          1,
          '$ragione\nUna prova che non cade piu\' | ragione vecchia di un '
              'rosso che qualcuno ha gia\' curato');
      expect(r.exitCode, 1,
          reason: 'una riga del registro che mette a tacere una prova oggi '
              'verde non ferma la build: il registro e\' diventato un elenco '
              'di permessi che nessuno rilegge');
      expect(r.stdout.toString(), contains('RIGHE DI TROPPO'));
      expect(r.stdout.toString(), contains('Una prova che non cade piu'),
          reason: 'lo sbarramento non dice QUALE riga e\' di troppo, quindi '
              'chi legge non sa cosa togliere');
    });

    // **E il controllo gira anche a SUITE VERDE**, che e' il buco vero: prima
    // il ramo verde usciva con exit 0 senza guardare il registro nemmeno una
    // volta.
    test('Verde con una riga di troppo: l\'archivio NON si produce', () {
      if (bash.isEmpty) return;
      final r = giudica('00:12 +3794: All tests passed!\n', 0,
          'Una prova che passa da mesi | ragione di un rosso gia\' curato');
      expect(r.exitCode, 1,
          reason: 'con la suite tutta verde e una riga vecchia nel registro '
              'la build esce lo stesso: il controllo non gira in questo ramo');
      expect(r.stdout.toString(), contains('RIGHE DI TROPPO'));
      expect(r.stdout.toString(), contains('Una prova che passa da mesi'));
      expect(r.stdout.toString(), isNot(contains('SUITE VERDE')),
          reason: 'dice verde e poi si ferma: chi legge non sa a cosa '
              'credere');
    });

    test('Verde col registro VUOTO: l\'archivio si produce', () {
      if (bash.isEmpty) return;
      // Senza questa riga la prova qui sopra passerebbe anche se lo
      // sbarramento fermasse SEMPRE la build a suite verde.
      final r = giudica('00:12 +3794: All tests passed!\n', 0, '');
      expect(r.exitCode, 0);
      expect(r.stdout.toString(), contains('SUITE VERDE'));
    });
  });
}
