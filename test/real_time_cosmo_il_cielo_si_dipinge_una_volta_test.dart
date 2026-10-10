// GUARDIA 7.1 DELL'ORDINE FG: IL CIELO SI DIPINGE UNA VOLTA.
//
// Il cammino per fotogramma del Real Time Cosmo e' fatto dei metodi elencati
// in [_camminoPerFotogramma]: il pittore, la scena, e i metodi che la
// schermata chiama a ogni battito. Dentro quei corpi non deve nascere un
// MaskFilter, uno shader, un filtro d'immagine, una lista o un insieme: la
// guardia cade nominando file, metodo e riga.
//
// Una guardia cosi' passerebbe anche con un cielo vuoto, se gli strati
// pesanti non esistessero da nessuna parte. Per questo pretende anche che
// esistano, dentro le cotture ([_cotture]): lo sprite col suo gradiente,
// l'alone e la foschia con la loro sfocatura, la Luna di LunaReale, tutti
// fermati in un'immagine con toImageSync. La misura a schermo, che dopo
// quindici fotogrammi la foschia e la Luna non si siano cotte a ogni
// fotogramma, sta in test/real_time_cosmo_si_ferma_fuori_scena_test.dart,
// che monta la schermata vera.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

const _pittore = 'lib/features/real_time_cosmo/pittore_del_cielo.dart';
const _scena = 'lib/features/real_time_cosmo/la_scena_del_cielo.dart';
const _schermata = 'lib/features/real_time_cosmo/cielo_reale_screen.dart';

/// I metodi chiamati a ogni fotogramma, per file. La firma e' l'inizio della
/// riga che apre il metodo.
const Map<String, List<String>> _camminoPerFotogramma = {
  _pittore: ['  void paint(Canvas canvas, Size size) {'],
  _scena: ['  void prepara({'],
  // Ordine FH voce 15.2: anche le linee delle figure.
  'lib/features/real_time_cosmo/le_linee_in_scena.dart': ['  void prepara({'],
  // Ordine FH parte 7: il terreno, proiettato a ogni fotogramma.
  // Ordine FH parte 9: la maglia della Via Lattea.
  'lib/features/real_time_cosmo/la_via_lattea_in_scena.dart': [
    '  void prepara('
  ],
  // Ordine FH parte 12: le stelle cadenti.
  'lib/features/real_time_cosmo/le_meteore_in_scena.dart': ['  void prepara('],
  // Ordine FH parte 10: i cinque oggetti del cielo profondo.
  'lib/features/real_time_cosmo/il_cielo_profondo_in_scena.dart': [
    '  void prepara(',
  ],
  'lib/features/real_time_cosmo/l_orizzonte_in_scena.dart': [
    '  void prepara(',
    '  void _proietta(',
  ],
  _schermata: [
    '  void _fotogrammaNuovo(Duration ora) {',
    '  void _posaICorpi(',
    '  void _posaLaLuna(',
    '  void _posaIVeli(',
    '  void _posaLaFoschia(',
    '  void _posaLeScritte(',
    '  void _posaLaGuida(',
    '  void _posaLAnello(',
    '  void _posaLeMeteore(',
    '  void _aggiornaLInvito(',
    '  void _avanzaIlRitorno(',
  ],
};

/// Cio' che nel fotogramma non deve nascere.
final List<(String, RegExp)> _vietati = [
  ('un MaskFilter', RegExp(r'MaskFilter')),
  ('uno shader', RegExp(r'createShader|\bshader\s*=|Gradient\.')),
  ('un filtro d\'immagine', RegExp(r'ImageFilter')),
  (
    'una lista rigenerata',
    RegExp(
        r'List\.(generate|filled|of|from)|\.toList\(\)|<[\w<>, ?]+>\[|\[\s*for\b|\[\s*\.\.\.')
  ),
  (
    'un insieme o una mappa nuovi',
    RegExp(r'<[\w<>, ?]+>\{|\{\s*\.\.\.|Set\.|Map\.')
  ),
  ('un array tipizzato nuovo', RegExp(r'(Float32|Float64|Int32|Uint8)List\(')),
];

/// Le cotture: dove gli strati pesanti DEVONO esserci.
const Map<String, List<(String, List<String>)>> _cotture = {
  _pittore: [
    (
      'ui.Image preparaLoSpriteDellaStella()',
      ['ui.Gradient.radial', 'toImageSync']
    ),
  ],
  'lib/features/real_time_cosmo/il_velo_delle_costellazioni.dart': [
    ('  void cuociAlone(double scala) {', ['ImageFilter.blur', 'toImageSync']),
  ],
  _schermata: [
    ('  void _cuociLaLuna(', ['LunaReale.dipingi', 'toImageSync']),
    (
      '  void _cuociLaFoschia(',
      ['ImageFilter.blur', 'BlendMode.dstIn', 'toImageSync']
    ),
  ],
};

/// Il corpo del metodo che comincia alla riga che inizia con [firma]: righe
/// e numero della prima. Le graffe si contano sul codice senza testo, cosi'
/// una graffa dentro una stringa non sposta la fine.
({int prima, List<String> righe})? corpoDelMetodo(
    String sorgente, String firma) {
  final crude = sorgente.split('\n');
  final pulite = codiceSenzaTesto(sorgente).split('\n');
  final inizio = crude.indexWhere((r) => r.startsWith(firma));
  if (inizio < 0) return null;
  var profondita = 0;
  var aperta = false;
  for (var i = inizio; i < pulite.length; i++) {
    for (final c in pulite[i].split('')) {
      if (c == '{') {
        profondita++;
        aperta = true;
      } else if (c == '}') {
        profondita--;
      }
    }
    if (aperta && profondita == 0) {
      return (prima: inizio + 1, righe: pulite.sublist(inizio, i + 1));
    }
  }
  return null;
}

/// I difetti del cammino per fotogramma: "file, metodo, riga: cosa".
List<String> difettiDelFotogramma(Map<String, String> sorgenti) {
  final difetti = <String>[];
  _camminoPerFotogramma.forEach((file, firme) {
    final sorgente = sorgenti[file]!;
    for (final firma in firme) {
      final corpo = corpoDelMetodo(sorgente, firma);
      if (corpo == null) {
        difetti.add('$file: il metodo "${firma.trim()}" non c\'e\' piu\'');
        continue;
      }
      for (var k = 0; k < corpo.righe.length; k++) {
        for (final (cosa, regola) in _vietati) {
          if (regola.hasMatch(corpo.righe[k])) {
            difetti.add('$file, ${firma.trim()} riga ${corpo.prima + k}: '
                '$cosa nel fotogramma');
          }
        }
      }
    }
  });
  return difetti;
}

void main() {
  Map<String, String> leggi() => {
        for (final f in {..._camminoPerFotogramma.keys, ..._cotture.keys})
          f: File(f).readAsStringSync(),
      };

  test('nel cammino per fotogramma non nasce niente di pesante', () {
    final difetti = difettiDelFotogramma(leggi());
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });

  test('gli strati pesanti esistono, dentro le cotture', () {
    final sorgenti = leggi();
    final mancanti = <String>[];
    _cotture.forEach((file, cotture) {
      for (final (firma, pretesi) in cotture) {
        final corpo = corpoDelMetodo(sorgenti[file]!, firma);
        if (corpo == null) {
          mancanti.add('$file: la cottura "${firma.trim()}" non c\'e\'');
          continue;
        }
        // Qui il testo serve: i nomi stanno nel codice, non nelle stringhe.
        final crudo = sorgenti[file]!
            .split('\n')
            .sublist(corpo.prima - 1, corpo.prima - 1 + corpo.righe.length)
            .join('\n');
        for (final p in pretesi) {
          if (!crudo.contains(p)) {
            mancanti.add('$file, ${firma.trim()}: manca $p');
          }
        }
      }
    });
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });
}
