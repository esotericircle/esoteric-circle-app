// GUARDIA 7.2 DELL'ORDINE FG: NESSUNA SECONDA PORTA SULL'ASTRONOMIA.
//
// La conversione da coordinate equatoriali a orizzontali vive in un posto
// solo, Celestial.equatorialToHorizontal in lib/core/astro/celestial.dart.
// La prova enumera TUTTO lib/ (dalla porta comune sorgentiDiLib, che non
// gira mai a vuoto) e cade, nominando file e riga, se trova altrove il cuore
// di quella formula: il seno della declinazione per il seno della latitudine
// (o il contrario), che e' il primo termine del seno dell'altezza.
//
// E cade se trova un secondo motore dei pianeti accanto a IlCieloDiMeeus:
// fuori da lib/core/astro/meeus/ nessun codice nomina il VSOP87, gli
// elementi di Keplero o le loro tabelle. I testi a video e i commenti non
// contano (codiceSenzaTesto): il foglio delle fonti puo' citare il VSOP87.

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';
import 'sorgenti_di_lib.dart';

const _portaDellaConversione = 'lib/core/astro/celestial.dart';
const _portaDeiPianeti = 'lib/core/astro/meeus/';

final _conversione = RegExp(
  r'sin\(\s*[\w.]*dec\w*\s*\)\s*\*\s*(math\.)?sin\(\s*[\w.]*lat'
  r'|sin\(\s*[\w.]*lat\w*\s*\)\s*\*\s*(math\.)?sin\(\s*[\w.]*dec',
  caseSensitive: false,
);

final _motoreDeiPianeti = RegExp(
  r'vsop|kepler|SerieVsop|_eliocentrica|elementiOrbitali|semiasse',
  caseSensitive: false,
);

String _percorso(String p) => p.replaceAll('\\', '/');

List<String> difettiDellaPortaSola(Iterable<({String percorso, String testo})> file) {
  final difetti = <String>[];
  for (final f in file) {
    final p = _percorso(f.percorso);
    final righe = codiceSenzaTesto(f.testo).split('\n');
    for (var i = 0; i < righe.length; i++) {
      if (!p.endsWith(_portaDellaConversione) && _conversione.hasMatch(righe[i])) {
        difetti.add('$p riga ${i + 1}: una seconda conversione da '
            'equatoriali a orizzontali');
      }
      if (!p.contains(_portaDeiPianeti) && _motoreDeiPianeti.hasMatch(righe[i])) {
        difetti.add('$p riga ${i + 1}: un secondo motore dei pianeti '
            'accanto a IlCieloDiMeeus');
      }
    }
  }
  return difetti;
}

void main() {
  test('una conversione sola e un motore dei pianeti solo', () {
    final file = [
      for (final f in sorgentiDiLib())
        (percorso: f.path, testo: f.readAsStringSync()),
    ];
    final difetti = difettiDellaPortaSola(file);
    expect(difetti, isEmpty, reason: difetti.join('\n'));
    // La porta c'e' ed e' quella: se la formula sparisse anche da li', la
    // guardia non saprebbe piu' che cosa cerca.
    final porta = file.firstWhere(
        (f) => _percorso(f.percorso).endsWith(_portaDellaConversione));
    expect(_conversione.hasMatch(codiceSenzaTesto(porta.testo)), isTrue,
        reason: 'la formula non e\' piu\' in $_portaDellaConversione: la '
            'guardia va riscritta');
  });
}
