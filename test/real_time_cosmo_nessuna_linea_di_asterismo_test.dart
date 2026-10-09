// GUARDIA 7.5 DELL'ORDINE FG, RISCRITTA DALL'ORDINE FH (fatto 4): LE LINEE
// DEL LAVORO NUOVO VENGONO SOLO DAL FILE DELLE FIGURE.
//
// La ragione del divieto originale era la licenza, non la geometria: le linee
// di Stellarium non sono nostre, quelle del file dell'Architetto si'. Quindi
// la guardia non vieta piu' ogni linea, ne presidia la provenienza. Nel
// sorgente del Real Time Cosmo:
//
//   - una primitiva che disegna segmenti (drawLine, drawPath, lineTo,
//     drawPoints, drawRawPoints, PointMode, drawVertices) compare SOLO nei
//     metodi ammessi qui sotto, cioe' il pittore, che consegna i buffer delle
//     linee e dell'eclittica;
//   - i buffer delle linee si riempiono SOLO dalle coppie del file: il metodo
//     che li prepara legge i capi da `linee.da[k]` e `linee.a[k]` e da
//     nient'altro.
//
// Il conto a runtime delle linee disegnate contro le 187 del file sta nella
// guardia 15.3, test/real_time_cosmo_nessuna_linea_inventata_test.dart.
// Non guarda il Cielo esistente, che le sue linee le ha gia' e non si tocca.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';
import 'real_time_cosmo_il_cielo_si_dipinge_una_volta_test.dart' show corpoDelMetodo;

const _cartelle = [
  'lib/features/real_time_cosmo',
  'lib/core/astro/real_time_cosmo',
];

final _segmenti = RegExp(
    r'\.drawLine\(|\.drawPath\(|\.drawPoints\(|\.drawRawPoints\(|\.lineTo\(|PointMode\.|\.drawVertices\(');

/// I metodi dove una primitiva di segmenti e' ammessa: (file, firma).
const _ammessi = [
  ('lib/features/real_time_cosmo/pittore_del_cielo.dart',
      '  void paint(Canvas canvas, Size size) {'),
];

/// Il metodo che riempie i buffer delle linee, e da dove deve leggere i capi.
const _riempitore = (
  'lib/features/real_time_cosmo/le_linee_in_scena.dart',
  '  void prepara({',
);

List<String> difettiDellaProvenienza(
    Map<String, String> sorgenti) {
  final difetti = <String>[];
  // 1. Le primitive solo dove ammesse.
  final righeAmmesse = <String, Set<int>>{};
  for (final (file, firma) in _ammessi) {
    final corpo = corpoDelMetodo(sorgenti[file] ?? '', firma);
    if (corpo == null) {
      difetti.add('$file: il metodo ammesso "${firma.trim()}" non c\'e\' piu\'');
      continue;
    }
    righeAmmesse.putIfAbsent(file, () => <int>{}).addAll(
        [for (var k = 0; k < corpo.righe.length; k++) corpo.prima + k]);
  }
  sorgenti.forEach((file, testo) {
    final righe = codiceSenzaTesto(testo).split('\n');
    for (var i = 0; i < righe.length; i++) {
      if (_segmenti.hasMatch(righe[i]) &&
          !(righeAmmesse[file]?.contains(i + 1) ?? false)) {
        difetti.add('$file riga ${i + 1}: un disegno di segmenti fuori dal '
            'pittore (${_segmenti.firstMatch(righe[i])!.group(0)})');
      }
    }
  });
  // 2. I capi delle linee solo dal file.
  final (file, firma) = _riempitore;
  final corpo = corpoDelMetodo(sorgenti[file] ?? '', firma);
  if (corpo == null) {
    difetti.add('$file: il metodo che prepara le linee non c\'e\' piu\'');
  } else {
    final testo = corpo.righe.join('\n');
    if (!testo.contains('linee.da[k]') || !testo.contains('linee.a[k]')) {
      difetti.add('$file: le linee non leggono piu\' i loro capi dalle '
          'coppie del file (linee.da[k], linee.a[k])');
    }
    final altri = RegExp(r'cielo\.[xyz]\[(?!i1\]|i2\])').allMatches(testo);
    for (final m in altri) {
      difetti.add('$file: un capo di linea letto da un indice che non viene '
          'dal file (${m.group(0)})');
    }
  }
  return difetti;
}

void main() {
  test('le linee del Real Time Cosmo vengono solo dal file delle figure', () {
    final sorgenti = {
      for (final c in _cartelle)
        for (final f in Directory(c).listSync(recursive: true).whereType<File>())
          if (f.path.endsWith('.dart'))
            f.path.replaceAll('\\', '/'): f.readAsStringSync(),
    };
    // Le due cartelle hanno i loro file: una cartella vuota darebbe verde
    // senza aver guardato niente.
    expect(sorgenti.length, greaterThanOrEqualTo(14));
    final difetti = difettiDellaProvenienza(sorgenti);
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}
