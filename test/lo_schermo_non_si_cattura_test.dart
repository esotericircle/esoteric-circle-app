import 'dart:io';

import 'package:esoteric_circle/core/sensi/lo_schermo_protetto.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LO SCHERMO NON SI CATTURA.** Ordine EV, il fondatore il 1 ottobre 2026:
/// *"vorrei disattivassi la possibilità di fare screenshot"*. Su Android il
/// segno `FLAG_SECURE`, chiesto all'avvio; su iOS il sistema non lo permette.
void main() {
  String codice(String percorso) => File(percorso)
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join('\n');

  test('all\'avvio lo schermo si protegge', () async {
    final chieste = <bool>[];
    LoSchermoProtetto.chiedi = (p) async => chieste.add(p);
    await LoSchermoProtetto.applica();
    final main = codice('lib/main.dart');
    final attivita = codice('android/app/src/main/kotlin/com/esotericircle/'
        'esoteric_circle/MainActivity.kt');
    // ignore: avoid_print
    print('ORDINE EV, CATTURE: protetto ${chieste.join(',')}; main chiede '
        '${main.contains('LoSchermoProtetto.applica()')}; FLAG_SECURE '
        '${attivita.contains('FLAG_SECURE')}');
    expect(chieste, [true],
        reason: 'senza CATTURE_PERMESSE lo schermo deve essere protetto');
    expect(main, contains('LoSchermoProtetto.applica()'),
        reason: 'l\'avvio non chiede piu\' la protezione: le catture tornano');
    expect(attivita, contains('"proteggi"'));
    expect(attivita, contains('window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)'));
    // E l'attivita' ricreata col motore in cache la rimette.
    expect(RegExp(r'onCreate[\s\S]*?applicaLaProtezione\(\)').hasMatch(attivita),
        isTrue);
  });
}
