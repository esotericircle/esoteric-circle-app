import 'dart:io';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// IL CORPUS DELL'ORACOLO DEGLI ANGELI. Ordine FU voci FU.05 e FU.07.
///
/// Il corpus lo scrive Code (il fondatore, 14 ottobre 2026: "Code"), nella
/// voce di Medora per i tre messaggi e in quella di Caligo per il rito, in
/// `docs/corpus/oracolo_angeli/`; `tool/il_corpus_dell_oracolo.py genera` lo
/// porta in `lib` senza modello. Questa prova pretende quattro cose:
///
/// 1. **i 792 testi ci sono tutti** (72 angeli per custode, cuore e
///    intelletto a tre varianti, 648 messaggi; 72 per il rito a due
///    varianti, 144 riti), senza celle vuote;
/// 2. **nessun testo e' uguale a un altro**;
/// 3. **il Dart generato coincide con la fonte**: un testo corretto nella
///    fonte e non rigenerato, o toccato a mano nel .g.dart, la fa cadere;
/// 4. **nessuna parola vietata dalla POLITICA DI PUBBLICAZIONE** di
///    `docs/corpus/angeli.md` (regola R8): salute e corpo, promesse di
///    esito, entita' avverse e goetia, sigilli.
///
/// **Vista rossa**: l'innesto e l'esito stanno in
/// `docs/corpus/oracolo_angeli/LEGGIMI.md`, sezione L'innesto.
///
/// **L'ORDINE GA**, voci GA.03, GA.05 e GA.07, 20 ottobre 2026: ogni carta
/// singola ha il suo riquadro "Cosa fare adesso", e il suo testo e' il campo
/// `consiglio`, tre per cella accanto ai tre messaggi. I testi passano da 792
/// a 1.440 (648 messaggi, 648 consigli, 144 riti) e le celle da 288 a 504.
/// La misura in parole (da 40 a 50) la pretende
/// `test/l_oracolo_ha_la_forma_nuova_test.dart`.
void main() {
  const corpus = corpusDellOracolo;
  const file = {
    'custode': [('messaggio', 3), ('consiglio', 3)],
    'cuore': [('messaggio', 3), ('consiglio', 3)],
    'intelletto': [('messaggio', 3), ('consiglio', 3)],
    'rito': [('rito', 2)],
  };

  /// La fonte riletta come la rilegge lo strumento: "## NN Nome" e le righe
  /// "- <campo> <n>: <testo>".
  Map<String, List<String>> fonte() {
    final fuori = <String, List<String>>{};
    final riga = RegExp(r'^- (\w+) (\d+):(.*)$');
    for (final nome in file.keys) {
      String? nn;
      for (final r
          in File('docs/corpus/oracolo_angeli/$nome.md').readAsLinesSync()) {
        if (r.startsWith('## ')) {
          nn = r.substring(3).trim().split(' ').first;
          continue;
        }
        final m = riga.firstMatch(r);
        if (m == null || nn == null) continue;
        fuori
            .putIfAbsent('$nome|$nn|${m.group(1)}', () => [])
            .add(m.group(3)!.trim().split(RegExp(r'\s+')).join(' '));
      }
    }
    return fuori;
  }

  test('il corpus porta tutti i 1.440 testi, senza celle vuote', () {
    final testi = corpus.values.fold<int>(0, (n, v) => n + v.length);
    cardinaleMinimo(testi, 1440,
        cosa: 'testi del corpus dell\'Oracolo degli Angeli',
        perche: 'il disegno ne dichiara 1.440 (LEGGIMI.md): 648 messaggi e '
            '648 consigli di Medora (ordine GA) e 144 riti di Caligo');
    expect(testi, 1440);
    final mancanti = <String>[];
    final vuote = <String>[];
    for (final MapEntry(key: nome, value: campi) in file.entries) {
      for (final (campo, varianti) in campi) {
        for (final a in AngelCatalog.all) {
          final k = '$nome|${a.number.toString().padLeft(2, '0')}|$campo';
          final v = corpus[k];
          if (v == null || v.length != varianti) {
            mancanti.add(k);
            continue;
          }
          if (v.any((t) => t.trim().isEmpty)) vuote.add(k);
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE FU VOCI FU.05 E FU.07: testi $testi, celle '
        '${corpus.length}, celle mancanti ${mancanti.length}, celle con un '
        'testo vuoto ${vuote.length}');
    expect(mancanti, isEmpty, reason: 'celle mancanti o incomplete: $mancanti');
    expect(vuote, isEmpty, reason: 'celle con un testo vuoto: $vuote');
    expect(corpus.length, 72 * 7);
  });

  test('nessun testo e\' uguale a un altro', () {
    final visti = <String, String>{};
    final doppi = <String>[];
    for (final e in corpus.entries) {
      for (final t in e.value) {
        final prima = visti[t];
        if (prima != null) doppi.add('$prima e ${e.key}: $t');
        visti[t] = e.key;
      }
    }
    cardinaleMinimo(visti.length + doppi.length, 1440,
        cosa: 'testi confrontati fra loro');
    expect(doppi, isEmpty, reason: 'testi ripetuti: $doppi');
  });

  test('il Dart generato coincide con la fonte', () {
    final f = fonte();
    cardinaleMinimo(f.values.fold<int>(0, (n, v) => n + v.length), 1440,
        cosa: 'testi letti nella fonte docs/corpus/oracolo_angeli/');
    final diversi = <String>[];
    for (final k in {...f.keys, ...corpus.keys}) {
      final a = f[k];
      final b = corpus[k];
      if (a == null || b == null || a.length != b.length) {
        diversi.add('$k: cella presente da una parte sola');
        continue;
      }
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) diversi.add('$k variante ${i + 1}');
      }
    }
    expect(diversi, isEmpty,
        reason: 'il .g.dart non e\' la fonte: correggi la fonte e rigenera con '
            'python tool/il_corpus_dell_oracolo.py genera. Diversi: $diversi');
  });

  test('nessuna parola vietata dalla politica di pubblicazione', () {
    // Le radici piu' pericolose della politica (docs/corpus/angeli.md) e
    // della regola R8: lo strumento ne ferma di piu', questa prova guarda
    // cio' che arriva davvero in lib.
    final vietate = RegExp(
        r'(?<![A-Za-zÀ-ÿ])('
        r'salute|malat\w*|guari\w*|terapi\w*|medic\w*|farmac\w*|'
        r'fertil\w*|steril\w*|gravid\w*|incint\w*|longev\w*|corpo|'
        r'vista|udito|olfatt\w*|tatto|morte|'
        r'vittori\w*|vincer\w*|nemic\w*|armi|arma|ricchezz\w*|denar\w*|'
        r'soldi|fortun\w*|tesor\w*|ritrov\w*|prigion\w*|proteg\w*|'
        r'protezion\w*|success\w*|miracol\w*|abbondanz\w*|'
        r'demon\w*|diavol\w*|goet\w*|contrari\w*|malefic\w*|sigill\w*|'
        r'talisman\w*|amulet\w*|evoca\w*'
        r')(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final trovate = <String>[];
    var guardati = 0;
    for (final e in corpus.entries) {
      for (final t in e.value) {
        guardati++;
        final m = vietate.firstMatch(t);
        if (m != null) trovate.add('${e.key}: "${m.group(0)}" in $t');
      }
    }
    cardinaleMinimo(guardati, 1440, cosa: 'testi guardati per la politica');
    // ignore: avoid_print
    print('ORDINE FU VOCI FU.05 E FU.07: testi guardati per la politica '
        '$guardati, parole vietate trovate ${trovate.length}');
    expect(trovate, isEmpty,
        reason: 'parole vietate dalla politica di pubblicazione: $trovate');
  });
}
