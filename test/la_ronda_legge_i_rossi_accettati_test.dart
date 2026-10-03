// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA RONDA LEGGE I ROSSI ACCETTATI. Ordine EA voce 03.
///
/// **Il fatto, dal fondatore**: la Ronda dei motori deve essere verde.
///
/// **Perche' non lo era.** Il passo che gira la suite era `flutter test`
/// nudo, e `flutter test` non conosce `tool/rossi_accettati.txt`: i rossi
/// dichiarati e voluti la facevano rossa ogni notte. Sullo stesso commit
/// `007b360f` il cancello `verde.yml`, che passa dallo sbarramento, era
/// **verde**, e la Ronda rossa con quattro prove cadute: le quattro erano
/// tutte nel registro dei rossi accettati.
///
/// **Una Ronda rossa per motivi noti non dice piu' niente** il giorno in cui
/// si rompe qualcosa davvero, ed e' il difetto che questa guardia presidia.
void main() {
  final ronda = File('.github/workflows/ronda.yml');
  final verde = File('.github/workflows/verde.yml');

  test('la Ronda gira la suite dallo sbarramento, non da flutter test nudo',
      () {
    expect(ronda.existsSync(), isTrue,
        reason: 'il workflow della Ronda non c\'e\' piu\'');
    final righe = ronda
        .readAsLinesSync()
        .map((r) => r.trim())
        .where((r) =>
            r.startsWith('run:') ||
            r.startsWith('bash ') ||
            r.startsWith('flutter '))
        .toList();
    print('ORDINE EA VOCE 03: comandi della Ronda ${righe.length}');
    expect(righe.length, greaterThanOrEqualTo(4),
        reason: 'la Ronda ha ${righe.length} comandi: se il workflow si '
            'svuota, questa guardia non guarda piu\' niente');
    expect(righe.any((r) => r.contains('tool/sbarramento.sh')), isTrue,
        reason: 'la Ronda non passa dallo sbarramento, quindi non legge i '
            'rossi accettati e resta rossa per i due rossi voluti');
    // La suite NON si lancia piu' nuda: la Ronda dei motori, che e' un file
    // solo, continua a girare per conto suo, ed e' giusto.
    final nude = righe
        .where((r) => r.contains('flutter test') && !r.contains('_test.dart'))
        .toList();
    expect(nude, isEmpty,
        reason: 'la Ronda lancia ancora la suite intera senza sbarramento: '
            '$nude');
  });

  test('la Ronda pubblica il verdetto come il cancello', () {
    final testo = ronda.readAsStringSync();
    expect(testo.contains('tool/il_verdetto_del_cancello.sh'), isTrue,
        reason: 'la Ronda cade e non dice dove: i registri delle azioni '
            'vogliono un accesso, le annotazioni no');
    expect(testo.contains('if: failure()'), isTrue,
        reason: 'il verdetto della Ronda non e\' legato alla caduta');
  });

  test('e lo sbarramento che la Ronda chiama e\' quello del cancello', () {
    final sbarramento = File('tool/sbarramento.sh');
    expect(sbarramento.existsSync(), isTrue);
    expect(
        sbarramento.readAsStringSync().contains('rossi_accettati.txt'), isTrue,
        reason: 'lo sbarramento non legge piu\' il registro dei rossi '
            'accettati: la Ronda passerebbe da un comando che non fa cio\' '
            'per cui e\' stato scelto');
    expect(verde.readAsStringSync().contains('tool/sbarramento.sh'), isTrue,
        reason: 'il cancello non passa piu\' dallo sbarramento: i due '
            'cammini sono tornati a divergere');
  });
}
