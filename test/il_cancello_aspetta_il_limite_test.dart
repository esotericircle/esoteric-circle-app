// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL CANCELLO ASPETTA IL LIMITE DI GITHUB. Ordine EA voce 15.
///
/// **Il fatto**: una build di Codemagic si e' fermata perche' GitHub ha
/// risposto *"API rate limit exceeded"*: senza credenziali risponde a sessanta
/// domande all'ora per indirizzo, e i Mac di Codemagic escono da indirizzi
/// condivisi. Il cancello contava quel rifiuto come una risposta illeggibile,
/// ci provava tre volte a venti secondi e si fermava, senza che il commit
/// fosse rosso.
///
/// **Cosa si pretende**: sul limite il cancello aspetta la riapertura letta
/// dalle intestazioni, dice che sta aspettando, quanto e fino a che ora, e
/// riprova; se la riapertura cade oltre il tetto lo dice subito; ogni altra
/// fermata resta com'era; e nessun token nuovo entra nel cancello.
///
/// Lo script vero, su risposte finte. Dove bash non c'e' non gira, e lo dice.
void main() {
  final controllo = File('tool/il_cancello_ha_detto_verde.sh');
  const ramo = 'claude/esoteric-circle-master-order-e798aj';
  const commit = 'abc1230000000000000000000000000000000000';
  final bash = [
    r'C:\Program Files\Git\bin\bash.exe',
    r'C:\Program Files\Git\usr\bin\bash.exe',
    '/usr/bin/bash',
    '/bin/bash',
  ].firstWhere((p) => File(p).existsSync(), orElse: () => '');
  late Directory tana;

  setUpAll(() => tana = Directory.systemTemp.createTempSync('limite_'));
  tearDownAll(() => tana.deleteSync(recursive: true));

  const verde = '{"workflow_runs": [{"id": 1, "event": "push", '
      '"head_sha": "$commit", "status": "completed", '
      '"conclusion": "success"}]}';
  const limite = '{"message": "API rate limit exceeded for 1.2.3.4. '
      '(But here\'s the good news: Authenticated requests get a higher rate '
      'limit.)"}';

  int ora() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// Le risposte, una per domanda: l'ultima vale per tutte quelle dopo.
  ProcessResult prova(String nome, List<(String, String?)> risposte,
      {String? segno}) {
    final base = '${tana.path}/$nome';
    for (final (i, (corpo, intestazioni)) in risposte.indexed) {
      final f = i == risposte.length - 1 ? base : '$base.${i + 1}';
      File(f).writeAsStringSync(corpo);
      if (intestazioni != null) {
        File('$f.intestazioni').writeAsStringSync(intestazioni);
      }
    }
    return Process.runSync(bash, [
      controllo.path
    ], environment: {
      'CM_COMMIT': commit,
      'CM_BRANCH': ramo,
      'RISPOSTA_FINTA_DEL_CANCELLO': base.replaceAll(r'\', '/'),
      'ATTESA_FRA_I_TENTATIVI': '0',
      'ATTESA_DEL_LIMITE_FORZATA': '0',
      if (segno != null) 'SEGNO_FINTO_DEL_CANCELLO': segno,
    });
  }

  bool senzaBash() {
    if (bash.isNotEmpty) return false;
    print('ORDINE EA: bash non c\'e\' su questa macchina, il cancello non e\' '
        'stato eseguito');
    return true;
  }

  test('sul limite aspetta, dice quanto e fino a che ora, e poi passa', () {
    if (senzaBash()) return;
    final reset = ora() + 90;
    final esito = prova('poi_verde', [
      (limite, 'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: $reset\r\n'),
      (verde, null),
    ]);
    final uscita = '${esito.stdout}';
    print('ORDINE EA.15: limite poi verde, uscita ${esito.exitCode}');
    expect(esito.exitCode, 0,
        reason: 'dopo il limite GitHub risponde verde, e il cancello non '
            'lascia passare:\n$uscita\n${esito.stderr}');
    expect(uscita, contains('LIMITE DELLE DOMANDE'),
        reason: 'aspetta senza dire che sta aspettando il limite');
    // **SI MISURA L'ORA DI RIPRESA, NON I SECONDI DI ATTESA**, ordine ES, 29
    // settembre 2026. La prova pretendeva "Aspetto 90-92 secondi", e i
    // secondi dipendono da quanto ci mette bash a partire dopo che la prova
    // ha scritto l'intestazione: con la macchina carica (una build, una suite
    // accanto) ne passavano piu' di uno e usciva 89, rosso quattro volte in
    // un giorno senza nessun difetto. L'ora a cui il cancello riprova e'
    // `reset + 2` qualunque sia il ritardo: e' quella che dice se il cancello
    // legge le intestazioni. Stessa precisione di prima, un secondo, sul
    // confine fra le due letture dell'orologio.
    expect(RegExp(r'Aspetto \d+ secondi').hasMatch(uscita), isTrue,
        reason: 'non dice quanto aspetta:\n$uscita');
    String hms(int s) {
      final t = DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true);
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}:'
          '${t.second.toString().padLeft(2, '0')}';
    }

    final attese = {
      for (final d in [1, 2, 3]) 'riprovo alle ${hms(reset + d)} UTC'
    };
    expect(attese.any(uscita.contains), isTrue,
        reason: 'non riprova all\'ora delle intestazioni (${hms(reset + 2)}), '
            'cioe\' non le legge:\n$uscita');
    expect(uscita, isNot(contains('Tentativo 1')),
        reason: 'il limite ha consumato un tentativo dei tre');
  });

  test('il limite si riconosce anche dalle sole intestazioni', () {
    if (senzaBash()) return;
    final esito = prova('intestazioni', [
      (
        '{"message": "Forbidden"}',
        'X-RateLimit-Remaining: 0\r\nRetry-After: 30\r\n'
      ),
      (verde, null),
    ]);
    expect(esito.exitCode, 0, reason: '${esito.stdout}');
    expect('${esito.stdout}', contains('Aspetto 32 secondi'),
        reason: 'retry-after vale prima del reset, piu\' due di margine');
  });

  test('se la riapertura cade oltre il tetto, si ferma subito e dice quando',
      () {
    if (senzaBash()) return;
    final esito = prova('oltre', [
      (
        limite,
        'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: ${ora() + 3000}\r\n'
      ),
    ]);
    final uscita = '${esito.stdout}';
    expect(esito.exitCode, 1, reason: uscita);
    expect(uscita, contains('NON SI RIAPRE IN TEMPO'), reason: uscita);
    expect(uscita, contains("L'ARCHIVIO NON SI PRODUCE"));
    expect(uscita, isNot(contains('Aspetto')),
        reason: 'aspetta una riapertura che sa gia\' fuori tempo');
  });

  test('un rifiuto che non e\' il limite resta come prima: tre tentativi', () {
    if (senzaBash()) return;
    final esito = prova('altro', [('{"message": "Not Found"}', null)]);
    final uscita = '${esito.stdout}';
    expect(esito.exitCode, 1);
    expect('Tentativo '.allMatches(uscita).length, 3, reason: uscita);
    expect(uscita, contains('GITHUB NON HA RISPOSTO, TRE VOLTE'));
    expect(uscita, isNot(contains('Aspetto')));
  });

  /// **IL SEGNO DEL VERDE, LETTO CON GIT. Ordine ET, 28 settembre 2026.**
  /// La build iOS su 82230fe9 si e' fermata al cancello col commit verde:
  /// l'API senza credenziali era al limite, e si riapriva oltre il tetto. Il
  /// fondatore: "Possibile che codemagic non funziona mai alla prima volta?".
  /// Col segno refs/verde/<commit>, scritto da GitHub a sbarramento passato,
  /// il cancello passa senza chiedere all'API; senza il segno chiede
  /// all'API come prima.
  test('col segno del verde passa anche col limite di GitHub chiuso', () {
    if (senzaBash()) return;
    final esito = prova(
        'segno_presente',
        [
          (
            limite,
            'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: ${ora() + 3000}\r\n'
          ),
        ],
        segno: 'presente');
    final uscita = '${esito.stdout}';
    print(
        'ORDINE ET: segno presente e limite chiuso, uscita ${esito.exitCode}');
    expect(esito.exitCode, 0,
        reason: 'il segno del verde c\'e\', e il cancello si ferma lo stesso '
            'sul limite di GitHub:\n$uscita');
    expect(uscita, contains('lo dice il segno refs/verde/$commit'));
    expect(uscita, isNot(contains('LIMITE')),
        reason: 'col segno ha chiesto lo stesso all\'API');
  });

  test('senza il segno chiede all\'API, e l\'API decide come prima', () {
    if (senzaBash()) return;
    final passa =
        prova('segno_assente_verde', [(verde, null)], segno: 'assente');
    expect(passa.exitCode, 0, reason: '${passa.stdout}');
    expect('${passa.stdout}', contains('chiedo all\'API di GitHub'));
    final ferma = prova(
        'segno_assente_limite',
        [
          (
            limite,
            'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: ${ora() + 3000}\r\n'
          ),
        ],
        segno: 'assente');
    expect(ferma.exitCode, 1, reason: '${ferma.stdout}');
    expect('${ferma.stdout}', contains('NON SI RIAPRE IN TEMPO'));
  });

  test('il cancello di GitHub scrive il segno, e solo a sbarramento passato',
      () {
    final flusso = File('.github/workflows/verde.yml')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    final passo =
        flusso.indexOf('Il segno del verde, per chi lo legge con git');
    final sbarramento =
        flusso.indexOf('Lo sbarramento, sui registri delle macchine');
    expect(sbarramento, greaterThan(0));
    expect(passo, greaterThan(sbarramento),
        reason: 'il segno si scrive prima dello sbarramento, o non si scrive');
    final blocco = flusso.substring(passo, flusso.indexOf('\n\n', passo));
    expect(blocco, contains("if: success() && github.event_name == 'push'"));
    expect(blocco, contains(r'refs/verde/${GITHUB_SHA}'));
    expect(flusso, contains('contents: write'));
  });

  test('nessun token nuovo nel cancello', () {
    final s = controllo.readAsStringSync();
    for (final vietato in const [
      'Authorization',
      'GITHUB_TOKEN',
      'CODEMAGIC3',
    ]) {
      expect(s.contains(vietato), isFalse,
          reason: 'il cancello nomina $vietato: l\'ordine EA voce 15 lo vuole '
              'senza credenziali');
    }
  });
}
