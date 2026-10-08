// GUARDIA 7.5 DELL'ORDINE FG: NESSUNA LINEA DI ASTERISMO NEL LAVORO NUOVO.
//
// Le linee degli asterismi non si prendono da Stellarium e in questo ordine
// non si disegnano affatto: il velo le sostituisce (voce 1.8). La prova
// enumera i sorgenti della funzione nuova, le due cartelle del Real Time
// Cosmo, e cade nominando file e riga se trova un disegno di segmenti:
// drawLine, drawPath, drawPoints e drawRawPoints in qualunque modo, o un
// Path che si allunga con lineTo. NON guarda il Cielo esistente, che le sue
// linee le ha gia' e non si tocca (voce 9.1).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

const _cartelle = [
  'lib/features/real_time_cosmo',
  'lib/core/astro/real_time_cosmo',
];

final _linee = RegExp(
    r'\.drawLine\(|\.drawPath\(|\.drawPoints\(|\.drawRawPoints\(|\.lineTo\(|PointMode\.');

List<String> difettiDelleLinee(Iterable<({String percorso, String testo})> file) {
  final difetti = <String>[];
  for (final f in file) {
    final righe = codiceSenzaTesto(f.testo).split('\n');
    for (var i = 0; i < righe.length; i++) {
      if (_linee.hasMatch(righe[i])) {
        difetti.add('${f.percorso} riga ${i + 1}: una linea disegnata '
            '(${_linee.firstMatch(righe[i])!.group(0)})');
      }
    }
  }
  return difetti;
}

void main() {
  test('il Real Time Cosmo non disegna linee fra le stelle', () {
    final file = [
      for (final c in _cartelle)
        for (final f in Directory(c).listSync(recursive: true).whereType<File>())
          if (f.path.endsWith('.dart'))
            (percorso: f.path.replaceAll('\\', '/'), testo: f.readAsStringSync()),
    ];
    // Le due cartelle hanno i loro file: una cartella vuota darebbe verde
    // senza aver guardato niente.
    expect(file.length, greaterThanOrEqualTo(12));
    final difetti = difettiDelleLinee(file);
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}
