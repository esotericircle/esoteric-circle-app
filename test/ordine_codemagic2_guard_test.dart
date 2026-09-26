// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CODEMAGIC2, la build iOS che andava in timeout.
///
/// **Il fatto.** La build iOS del 17 settembre 2026 e' morta al tetto dei
/// sessanta minuti durante l'archivio: prima dell'archivio il Mac aveva girato
/// `bash tool/sbarramento.sh` per 46 minuti e 23 secondi, lo stesso cancello
/// che `.github/workflows/verde.yml` fa gratis a ogni spinta. L'ordine
/// CODEMAGIC1 li aveva resi uguali e li aveva tenuti tutti e due.
///
/// **Cosa sorveglia.** Che la build iOS non rifaccia lo sbarramento, che non
/// costruisca senza aver letto il verdetto del cancello su quel commit, che
/// il cancello gratuito continui a farlo per intero, e che il controllo si
/// fermi su **ogni** esito che non e' verde. L'ultima cosa si misura facendo
/// girare lo script vero su risposte finte, non leggendone la forma.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CODEMAGIC2_MANIFESTO.md');
  final codemagic = File('codemagic.yaml');
  final verde = File('.github/workflows/verde.yml');
  final controllo = File('tool/il_cancello_ha_detto_verde.sh');

  const quante = 8;
  const ramo = 'claude/esoteric-circle-master-order-e798aj';

  /// Le righe che non sono commenti: i commenti raccontano la storia del
  /// passo tolto, e bocciarli guarderebbe la cosa sbagliata.
  List<String> codiceDi(String testo) => [
        for (final r in testo.split('\n'))
          if (!r.trimLeft().startsWith('#')) r,
      ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste, porta le sue voci e i marcatori dicono il vero',
      () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync();
    final voci = RegExp(r'^- \*\*CODEMAGIC2\.(\d\d)\*\*', multiLine: true)
        .allMatches(testo)
        .toList();
    expect(voci, hasLength(quante));
    var chiuse = 0, aperte = 0, attesa = 0;
    final blocchi =
        testo.split(RegExp(r'^- \*\*CODEMAGIC2\.', multiLine: true));
    for (final b in blocchi.skip(1)) {
      final voce = b.split('\n\n').first;
      if (voce.contains('APERTA')) {
        aperte++;
      } else if (voce.contains('FERMATA IN ATTESA DI DECISIONE')) {
        attesa++;
      } else if (voce.contains('CHIUSA')) {
        chiuse++;
      }
    }
    print('ORDINE CODEMAGIC2: voci $quante, chiuse $chiuse, aperte $aperte, '
        'in attesa $attesa');
    expect(marcatore(testo, 'VOCI_TOTALI'), quante);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(chiuse + aperte + attesa, quante);
  });

  test(
      'LA BUILD IOS NON RIFA LO SBARRAMENTO, E NON COSTRUISCE SENZA IL '
      'VERDETTO', () {
    final c = codiceDi(codemagic.readAsStringSync());
    final sbarramenti = [
      for (final r in c)
        if (r.contains('sbarramento.sh')) r,
    ];
    expect(sbarramenti, isEmpty,
        reason: 'codemagic.yaml esegue di nuovo lo sbarramento: sono 46 '
            'minuti di Mac per rifare cio\' che GitHub ha gia\' fatto, e la '
            'build del 17 settembre e\' morta al tetto per questo: '
            '$sbarramenti');
    // Il verdetto e' il PRIMO script, e sta prima dell'archivio.
    final script = [
      for (final r in c)
        if (RegExp(r'^\s+script:').hasMatch(r)) r.trim(),
    ];
    expect(script, isNotEmpty);
    expect(script.first, 'script: bash tool/il_cancello_ha_detto_verde.sh',
        reason: 'il controllo del cancello non e\' il primo passo: una build '
            'che deve fermarsi spende minuti prima di farlo');
    final testo = c.join('\n');
    expect(testo.indexOf('il_cancello_ha_detto_verde.sh'),
        lessThan(testo.indexOf('flutter build ipa')));
    // Il tetto: dentro il massimo documentato di Codemagic.
    final tetto = RegExp(r'^\s+max_build_duration:\s*(\d+)', multiLine: true)
        .firstMatch(testo);
    expect(tetto, isNotNull);
    final minuti = int.parse(tetto!.group(1)!);
    expect(minuti, inInclusiveRange(1, 120),
        reason: 'Codemagic ammette da 1 a 120 minuti: un valore fuori non '
            'allunga la build, la fa fallire in un altro modo');
    expect(testo.contains('RISPOSTA_FINTA_DEL_CANCELLO'), isFalse,
        reason: 'la risposta finta e\' delle prove, e nella build salterebbe '
            'il cancello');
  });

  test('IL CANCELLO GRATUITO CONTINUA A FARE TUTTO LO SBARRAMENTO', () {
    // Togliere lo sbarramento da Codemagic ha senso solo se GitHub lo fa:
    // sullo stesso ramo, a ogni spinta, per intero e con le prove del server.
    final g = codiceDi(verde.readAsStringSync()).join('\n');
    expect(g.contains('bash tool/sbarramento.sh'), isTrue);
    expect(g.contains('npm ci'), isTrue);
    expect(
        RegExp(r'push:\s*\n\s*branches:\s*\n\s*-\s*' + RegExp.escape(ramo))
            .hasMatch(g),
        isTrue,
        reason: 'verde.yml non gira piu\' a ogni spinta sul ramo canonico: il '
            'controllo di Codemagic troverebbe sempre "mai partito"');
    // La stessa versione di Flutter sulle due macchine.
    final versione = RegExp(r'flutter-version:\s*([\d.]+)').firstMatch(g);
    final suMac = RegExp(r'^\s+flutter:\s*([\d.]+)', multiLine: true)
        .firstMatch(codemagic.readAsStringSync());
    expect(versione?.group(1), isNotNull);
    expect(versione?.group(1), suMac?.group(1),
        reason: 'le due macchine usano Flutter diversi: il verde di GitHub '
            'non direbbe piu\' niente sulla build');
    // Il controllo chiede proprio QUEL cancello, su QUEL ramo.
    final s = controllo.readAsStringSync();
    expect(s.contains('CANCELLO="verde.yml"'), isTrue);
    expect(s.contains('RAMO_CANONICO="$ramo"'), isTrue);
    expect(s.contains(r'head_sha=$COMMIT'), isTrue);
  });

  group('IL CONTROLLO SI FERMA SU TUTTO CIO\' CHE NON E\' VERDE', () {
    // Lo script vero, su risposte finte. Dove bash non c'e' non gira, e lo
    // dice, come la prova dello sbarramento.
    final bash = [
      r'C:\Program Files\Git\bin\bash.exe',
      r'C:\Program Files\Git\usr\bin\bash.exe',
      '/usr/bin/bash',
      '/bin/bash',
    ].firstWhere((p) => File(p).existsSync(), orElse: () => '');
    const commit = 'abc1230000000000000000000000000000000000';
    late Directory tana;

    setUpAll(() => tana = Directory.systemTemp.createTempSync('cancello_'));
    tearDownAll(() => tana.deleteSync(recursive: true));

    String giro(String status, String? conclusione, {String sha = commit}) =>
        '{"id": 1, "event": "push", "head_sha": "$sha", "status": "$status", '
        '"conclusion": ${conclusione == null ? 'null' : '"$conclusione"'}}';

    ProcessResult prova(String risposta, {String ramoDellaBuild = ramo}) {
      final f = File('${tana.path}/risposta_${risposta.hashCode}.json')
        ..writeAsStringSync(risposta);
      return Process.runSync(bash, [
        controllo.path
      ], environment: {
        'CM_COMMIT': commit,
        'CM_BRANCH': ramoDellaBuild,
        'RISPOSTA_FINTA_DEL_CANCELLO': f.path.replaceAll(r'\', '/'),
        'ATTESA_FRA_I_TENTATIVI': '0',
        // **Ordine EA voce 15**: il limite di GitHub adesso si aspetta. Nelle
        // prove l'attesa e' zero, e il conto verso il tetto resta quello vero.
        'ATTESA_DEL_LIMITE_FORZATA': '0',
      });
    }

    final casi = <String, (String, int, {String ramo})>{
      'verde': (
        '{"workflow_runs": [${giro('completed', 'success')}]}',
        0,
        ramo: ramo
      ),
      'rosso': (
        '{"workflow_runs": [${giro('completed', 'failure')}]}',
        1,
        ramo: ramo
      ),
      'annullato': (
        '{"workflow_runs": [${giro('completed', 'cancelled')}]}',
        1,
        ramo: ramo
      ),
      'in corso': (
        '{"workflow_runs": [${giro('in_progress', null)}]}',
        1,
        ramo: ramo
      ),
      'mai partito': ('{"workflow_runs": []}', 1, ramo: ramo),
      'verde su un altro commit': (
        '{"workflow_runs": [${giro('completed', 'success', sha: 'ffff')}]}',
        1,
        ramo: ramo
      ),
      'GitHub rifiuta': (
        '{"message": "API rate limit exceeded"}',
        1,
        ramo: ramo
      ),
      'risposta illeggibile': ('<html>errore</html>', 1, ramo: ramo),
      'verde ma da main': (
        '{"workflow_runs": [${giro('completed', 'success')}]}',
        1,
        ramo: 'main'
      ),
    };

    for (final caso in casi.entries) {
      test(caso.key, () {
        if (bash.isEmpty) {
          print('ORDINE CODEMAGIC2: bash non c\'e\' su questa macchina, il '
              'caso "${caso.key}" non e\' stato eseguito');
          return;
        }
        final (risposta, uscita, :ramo) = caso.value;
        final esito = prova(risposta, ramoDellaBuild: ramo);
        print('ORDINE CODEMAGIC2: ${caso.key}, uscita ${esito.exitCode}');
        expect(esito.exitCode, uscita,
            reason: '${caso.key}: il controllo esce ${esito.exitCode} invece '
                'di $uscita\n${esito.stdout}\n${esito.stderr}');
        if (uscita != 0) {
          expect('${esito.stdout}', contains("L'ARCHIVIO NON SI PRODUCE"),
              reason: 'si ferma senza dire perche\'');
        }
      });
    }
  });
}
