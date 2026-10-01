import 'dart:io';

import 'package:esoteric_circle/core/sensi/lo_schermo_protetto.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LO SCHERMO E LE CATTURE.** Ordine EV, il fondatore il 1 ottobre 2026:
/// prima *"vorrei disattivassi la possibilità di fare screenshot"*, poi lo
/// stesso giorno *"Devi riattivare la possibilità di fare screenshot, così
/// non posso farli nemmeno per te"*. Di base le catture si fanno e l'avvio
/// toglie il segno `FLAG_SECURE`; la protezione resta pronta per la build che
/// dichiara `CATTURE_VIETATE`.
void main() {
  String codice(String percorso) => File(percorso)
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join('\n');

  test('all\'avvio le catture sono permesse', () async {
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
    expect(chieste, [false],
        reason: 'senza CATTURE_VIETATE le catture devono essere permesse: il '
            'fondatore le ha chieste indietro');
    expect(main, contains('LoSchermoProtetto.applica()'),
        reason: 'l\'avvio non chiede piu\' la protezione: le catture tornano');
    expect(attivita, contains('"proteggi"'));
    expect(attivita, contains('window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)'));
    // E l'attivita' ricreata col motore in cache la rimette.
    expect(RegExp(r'onCreate[\s\S]*?applicaLaProtezione\(\)').hasMatch(attivita),
        isTrue);
  });
}
