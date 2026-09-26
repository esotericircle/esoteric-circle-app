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
  ProcessResult prova(String nome, List<(String, String?)> risposte) {
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
    final esito = prova('poi_verde', [
      (
        limite,
        'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: ${ora() + 90}\r\n'
      ),
      (verde, null),
    ]);
    final uscita = '${esito.stdout}';
    print('ORDINE EA.15: limite poi verde, uscita ${esito.exitCode}');
    expect(esito.exitCode, 0,
        reason: 'dopo il limite GitHub risponde verde, e il cancello non '
            'lascia passare:\n$uscita\n${esito.stderr}');
    expect(uscita, contains('LIMITE DELLE DOMANDE'),
        reason: 'aspetta senza dire che sta aspettando il limite');
    expect(RegExp(r'Aspetto (9[0-2]) secondi').hasMatch(uscita), isTrue,
        reason: 'non dice quanto aspetta, o non lo legge dalle intestazioni:\n'
            '$uscita');
    expect(RegExp(r'riprovo alle \d\d:\d\d:\d\d UTC').hasMatch(uscita), isTrue,
        reason: 'non dice a che ora riprova');
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
