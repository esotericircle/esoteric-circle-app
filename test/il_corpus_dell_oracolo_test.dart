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
///
/// **L'ORDINE GA, voce GA.06**, 20 ottobre 2026: il file `doni.md` porta il
/// dono e la via di ogni angelo, che `LaRispostaDaiDoni` usa per comporre il
/// responso principale senza modello. I testi passano da 1.440 a 1.584 e le
/// celle da 504 a 648. E due difetti delle carte singole trovati dal lettore
/// cieco (D9) diventano prove: nessun messaggio finge di conoscere la
/// domanda ("Nostalgia è la parola che Iezalel mette sulla tua domanda"), e
/// la formula "dove pesa / dove scalda" non sta in piu' di otto testi per
/// file (era in 41 messaggi del cuore).
void main() {
  const corpus = corpusDellOracolo;
  const file = {
    'custode': [('messaggio', 3), ('consiglio', 3)],
    'cuore': [('messaggio', 3), ('consiglio', 3)],
    'intelletto': [('messaggio', 3), ('consiglio', 3)],
    'rito': [('rito', 2)],
    'doni': [('dono', 1), ('via', 1)],
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

  test('il corpus porta tutti i 1.584 testi, senza celle vuote', () {
    final testi = corpus.values.fold<int>(0, (n, v) => n + v.length);
    cardinaleMinimo(testi, 1584,
        cosa: 'testi del corpus dell\'Oracolo degli Angeli',
        perche: 'il disegno ne dichiara 1.584 (LEGGIMI.md): 648 messaggi e '
            '648 consigli di Medora (ordine GA), 144 riti di Caligo, 72 doni '
            'e 72 vie (ordine GA voce GA.06)');
    expect(testi, 1584);
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
    expect(corpus.length, 72 * 9);
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
    cardinaleMinimo(visti.length + doppi.length, 1584,
        cosa: 'testi confrontati fra loro');
    expect(doppi, isEmpty, reason: 'testi ripetuti: $doppi');
  });

  test('il Dart generato coincide con la fonte', () {
    final f = fonte();
    cardinaleMinimo(f.values.fold<int>(0, (n, v) => n + v.length), 1584,
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
    cardinaleMinimo(guardati, 1584, cosa: 'testi guardati per la politica');
    // ignore: avoid_print
    print('ORDINE FU VOCI FU.05 E FU.07: testi guardati per la politica '
        '$guardati, parole vietate trovate ${trovate.length}');
    expect(trovate, isEmpty,
        reason: 'parole vietate dalla politica di pubblicazione: $trovate');
  });

  /// **LE CARTE NON CONOSCONO LA DOMANDA**, ordine GA voce GA.06 (D9 del
  /// lettore cieco): il messaggio di una carta vale sotto ogni domanda, e uno
  /// che dice "la tua domanda" finge un legame. Lo stesso criterio di
  /// `tool/il_corpus_dell_oracolo.py` (LEGAME_FINTO), su cio' che arriva in
  /// lib. E la formula "dove pesa / dove scalda" al massimo in otto testi per
  /// file (TETTO_FORMULA).
  test(
      'nessuna carta finge di conoscere la domanda, e la formula "dove pesa '
      '/ dove scalda" non si ripete', () {
    final legame = RegExp(
        r'(?<![A-Za-zÀ-ÿ])(nella|sulla|della|alla|dentro la|al centro della) '
        r'tua domanda(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final formula = RegExp(r'(?<![A-Za-zÀ-ÿ])dove (pesa|scalda)(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final finti = <String>[];
    final perFile = <String, int>{};
    var messaggi = 0;
    for (final e in corpus.entries) {
      final nome = e.key.split('|').first;
      for (final t in e.value) {
        if (e.key.endsWith('|messaggio')) {
          messaggi++;
          if (legame.hasMatch(t)) finti.add('${e.key}: $t');
        }
        if (formula.hasMatch(t)) perFile[nome] = (perFile[nome] ?? 0) + 1;
      }
    }
    cardinaleMinimo(messaggi, 648, cosa: 'messaggi delle carte guardati');
    // ignore: avoid_print
    print('ORDINE GA VOCE GA.06: messaggi guardati $messaggi, legami finti '
        '${finti.length}, formula per file $perFile');
    expect(finti, isEmpty, reason: 'la carta non conosce la domanda: $finti');
    final oltre = {
      for (final MapEntry(key: k, value: v) in perFile.entries)
        if (v > 8) k: v
    };
    expect(oltre, isEmpty,
        reason: 'la formula "dove pesa / dove scalda" oltre otto testi: '
            '$oltre');
  });

  /// **IL "TI" OGGETTO COL PARTICIPIO**, ordine GA voci 03, 04, 05 e 08, 20
  /// ottobre 2026. "Chi ti ha cresciuto" si accorda con chi legge ("chi ti ha
  /// cresciuta" a una donna) e la guardia del genere non lo vede, perche' non
  /// c'e' un verbo alla seconda persona: il corpus lo dice al neutro ("chi ti
  /// ha fatto crescere"). Restano i participi dove "ti" vale "a te" e non si
  /// accordano ("ti ha dato", "ti ha insegnato", "ti ha fatto torto"). Lo
  /// stesso criterio di `tool/il_corpus_dell_oracolo.py` (TI_COL_PARTICIPIO),
  /// che ferma il testo prima che entri; qui si guarda cio' che arriva in lib.
  /// Vista rossa: `docs/collaudo/GA/oracolo_regola_a.txt`.
  test('nessun "ti" oggetto col participio che si accorda con chi legge', () {
    final tiCol = RegExp(
        r'(?<![A-Za-zÀ-ÿ])ti (?:ha|hanno|aveva|avevano|abbia|abbiano|avesse|'
        r'avessero|avrà|avranno|avrebbe|avrebbero) (?:(?:solo|soltanto|già|'
        r'davvero|sempre|anche|appena|mai|più|molto|tanto|spesso|forse|ancora|'
        r'poi) )*([a-zàèéìòù]+)',
        caseSensitive: false);
    const aTe = {
      'dato', 'detto', 'chiesto', 'mostrato', 'concesso', 'prestato', //
      'permesso', 'parlato', 'affidato', 'mandato', 'regalato', 'riferito',
      'passato', 'trasmesso', 'imposto', 'assegnato', 'indicato', 'teso',
      'offerto', 'promesso', 'restituito', 'scritto', 'insegnato',
      'confidato', 'raccontato', 'proposto', 'ripetuto', 'fatto', 'lasciato',
      'tolto',
    };
    final trovati = <String>[];
    var guardati = 0;
    var aTeVisti = 0;
    for (final e in corpus.entries) {
      for (final t in e.value) {
        guardati++;
        for (final m in tiCol.allMatches(t)) {
          if (aTe.contains(m.group(1)!.toLowerCase())) {
            aTeVisti++;
          } else {
            trovati.add('${e.key}: "${m.group(0)}"');
          }
        }
      }
    }
    cardinaleMinimo(guardati, 1584, cosa: 'testi guardati per il ti oggetto');
    // La grandezza misurata esiste: il corpus porta forme col "ti" che vale
    // "a te" (ti ha dato, ti ha insegnato), e la prova le vede.
    cardinaleMinimo(aTeVisti, 10,
        cosa: 'forme "ti ha" + participio col ti che vale "a te"');
    // ignore: avoid_print
    print('ORDINE GA: testi guardati per il ti oggetto $guardati, forme '
        'col ti "a te" $aTeVisti, col ti oggetto ${trovati.length}');
    expect(trovati, isEmpty,
        reason: 'si accordano col genere di chi legge, si scrivono al neutro '
            'nella fonte e si rigenera: $trovati');
  });
}
