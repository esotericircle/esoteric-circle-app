// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I TESTI NUOVI DELL'ARCHITETTO SONO NEL CODICE, CARATTERE PER
/// CARATTERE.** Ordine EV, voci EV.08 ed EV.09.
///
/// Il file dell'Architetto (`docs/corpus/eu/verifica_affermazioni_architetto.md`)
/// porta ogni "NUOVO TESTO" fra virgolette. Qui ognuno si cerca nel file dove
/// vive: le parti fra graffe sono i segnaposti, che il codice riempie a
/// runtime, e i pezzi fra un segnaposto e l'altro devono esserci uguali e in
/// fila. Nei file Dart le stringhe spezzate su piu' righe si riuniscono prima
/// di cercare. Un testo nuovo diverso dalla fonte, o un testo nuovo che non
/// sa dove vive, fa diventare rossa la prova.
void main() {
  const fonte = 'docs/corpus/eu/verifica_affermazioni_architetto.md';
  const dove = {
    'O-M-001': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-002': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-003': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-004': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-005': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-006': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'O-M-007': 'lib/core/horoscope/il_metodo_del_responso.dart',
    'V-M-001': 'lib/core/horoscope/la_lettura_vedica.dart',
    'V-M-004': 'lib/core/horoscope/la_lettura_vedica.dart',
    'V-M-009': 'lib/core/horoscope/l_anno_delle_tradizioni.dart',
    'V-M-011': 'lib/core/horoscope/l_anno_delle_tradizioni.dart',
    'C-M-006': 'lib/core/horoscope/l_anno_delle_tradizioni.dart',
    'C-M-008': 'lib/core/horoscope/l_anno_delle_tradizioni.dart',
    'C-G-068': 'docs/corpus/oroscopo_cinese.md',
    'C-G-069': 'docs/corpus/oroscopo_cinese.md',
    'C-M-002': 'docs/corpus/oroscopo_cinese.md',
    'C-M-004': 'docs/corpus/oroscopo_cinese.md',
    'La variante del Rahu Kalam senza l\'ora': 'docs/corpus/oroscopo_vedico.md',
    'La riga della ruota che ripete il primo passaggio di "Da dove viene"':
        'lib/features/horoscope/la_ruota_del_passaggio.dart',
    'Due giorni migliori di fila con lo stesso "Da dove viene"':
        'lib/features/horoscope/il_periodo_view.dart',
  };

  /// Il testo di un file come lo legge chi guarda le stringhe: in Dart le
  /// stringhe adiacenti si riuniscono e gli apostrofi si tolgono la barra.
  String testoDi(String percorso) {
    final t = File(percorso).readAsStringSync().replaceAll('\r\n', '\n');
    if (!percorso.endsWith('.dart')) return t;
    return t
        .replaceAll(RegExp(r"'\s*\n(\s*//[^\n]*\n)*\s*'"), '')
        .replaceAll(r"\'", "'");
  }

  test('ORDINE EV VOCI 08 E 09: ogni testo nuovo e\' nel codice uguale alla '
      'fonte', () {
    final righe = File(fonte).readAsLinesSync();
    final testi = <(String, String)>[];
    for (final r in righe) {
      final m = RegExp(r'^- (.+?): (?:NUOVO TESTO: |il secondo dice )"([^"]+)"')
          .firstMatch(r);
      if (m == null) continue;
      testi.add((m[1]!, m[2]!));
    }
    cardinaleMinimo(testi.length, 20, cosa: 'testi nuovi dell\'Architetto');
    final diversi = <String>[];
    final senzaCasa = <String>[];
    for (final (sigla, testo) in testi) {
      final percorso = dove[sigla];
      if (percorso == null) {
        senzaCasa.add(sigla);
        continue;
      }
      final codice = testoDi(percorso);
      var da = 0;
      for (final pezzo in testo.split(RegExp(r'\{[^}]*\}'))) {
        if (pezzo.isEmpty) continue;
        final i = codice.indexOf(pezzo, da);
        if (i < 0) {
          diversi.add('$sigla in $percorso: manca «$pezzo»');
          break;
        }
        da = i + pezzo.length;
      }
    }
    print('ORDINE EV VOCI 08 E 09: testi nuovi ${testi.length}, diversi '
        'dalla fonte ${diversi.length}, senza casa ${senzaCasa.length}');
    expect(senzaCasa, isEmpty, reason: senzaCasa.join('\n'));
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });
}
