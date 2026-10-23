// GUARDIA 7.6 DELL'ORDINE FG: I DUE CATALOGHI RESTANO SEPARATI.
//
// Finche' il fondatore non decide sulla sostituzione convivono due cataloghi
// per le stesse stelle: HYG (assets/astro/, CatalogoDelleStelle) per il Real
// Time Cosmo e Hipparcos (assets/data/bright_stars.json, SkyCatalog) per il
// Cielo esistente. E' un debito dichiarato, con la sua data di chiusura; se
// le due strade si incrociano diventa un difetto vero, perche' due cataloghi
// che descrivono le stesse stelle divergono sempre.
//
// La prova cade, nominando file e riga, se il codice del Real Time Cosmo
// legge bright_stars.json o SkyCatalog, oppure se il Cielo esistente (la
// schermata, sky.dart, la cartolina) legge il catalogo nuovo. I commenti non
// contano (senzaCommenti), le stringhe si': il percorso di un asset e' una
// stringa.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

const _nuovo = ['lib/features/real_time_cosmo', 'lib/core/astro/real_time_cosmo'];
const _esistente = [
  'lib/features/santuario/sky_overview_screen.dart',
  'lib/core/astro/sky.dart',
  'lib/features/santuario/sky_postcard.dart',
];

final _vecchioCatalogo = RegExp(r'bright_stars|SkyCatalog');
final _nuovoCatalogo =
    RegExp(r'stelle_hyg|assets/astro/|CatalogoDelleStelle|real_time_cosmo/');

List<String> difettiDegliIncroci({
  required Iterable<({String percorso, String testo})> nuovo,
  required Iterable<({String percorso, String testo})> esistente,
}) {
  final difetti = <String>[];
  void guarda(Iterable<({String percorso, String testo})> file, RegExp vietato,
      String cosa) {
    for (final f in file) {
      final righe = senzaCommenti(f.testo).split('\n');
      for (var i = 0; i < righe.length; i++) {
        if (vietato.hasMatch(righe[i])) {
          difetti.add('${f.percorso} riga ${i + 1}: $cosa');
        }
      }
    }
  }

  guarda(nuovo, _vecchioCatalogo,
      'il Real Time Cosmo legge il catalogo del Cielo esistente');
  guarda(esistente, _nuovoCatalogo,
      'il Cielo esistente legge il catalogo del Real Time Cosmo');
  return difetti;
}

void main() {
  test('HYG e Hipparcos non si incrociano', () {
    final nuovo = [
      for (final c in _nuovo)
        for (final f in Directory(c).listSync(recursive: true).whereType<File>())
          if (f.path.endsWith('.dart'))
            (percorso: f.path.replaceAll('\\', '/'), testo: f.readAsStringSync()),
    ];
    final esistente = [
      for (final p in _esistente) (percorso: p, testo: File(p).readAsStringSync()),
    ];
    expect(nuovo.length, greaterThanOrEqualTo(12));
    // Il Cielo esistente legge davvero il suo catalogo: se smettesse, la
    // guardia guarderebbe i file sbagliati.
    expect(esistente.any((f) => senzaCommenti(f.testo).contains('bright_stars')),
        isTrue);
    final difetti = difettiDegliIncroci(nuovo: nuovo, esistente: esistente);
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}
