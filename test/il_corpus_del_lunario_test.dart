import 'dart:io';

import 'package:esoteric_circle/core/lunario/il_corpus_del_lunario.g.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CORPUS DEL CALENDARIO LUNARE.** Ordine FV voci FV.06 e FV.07, 15
/// ottobre 2026.
///
/// Il corpus lo scrive Code (regola R2: nessun modello), nei tre file di
/// `docs/corpus/lunario/` (`fonti.md`, `regole.md`, `testi.md`);
/// `tool/il_corpus_del_lunario.py genera` lo porta in
/// `lib/core/lunario/il_corpus_del_lunario.g.dart` senza toccarlo a mano.
/// Questa prova rilegge la fonte con un parser suo (piu' semplice di quello
/// dello strumento, ma sulla stessa grammatica) e pretende:
///
/// 1. le cardinalita' minime dichiarate (nessuna cella scomparsa in
///    silenzio);
/// 2. ogni regola ha fonti che esistono davvero;
/// 3. ogni [AttivitaDelLunario] del contratto ha almeno una regola con una
///    fonte vera (diversa da `chiave_di_medora`);
/// 4. il Dart generato coincide con la fonte rigenerata a mano qui;
/// 5. nessuna parola vietata da R7 o R8 nei testi che arrivano in `lib`.
///
/// **Vista rossa**: l'innesto e l'esito stanno nel rapporto dell'ordine FV.
void main() {
  const cartella = 'docs/corpus/lunario';

  Map<String, Map<String, String>> celle(String file) {
    final fuori = <String, Map<String, String>>{};
    String? id;
    for (final riga in File('$cartella/$file').readAsLinesSync()) {
      if (riga.startsWith('### ')) {
        id = riga.substring(4).trim();
        fuori[id] = {};
        continue;
      }
      final m = RegExp(r'^- (\w+):\s*(.*)$').firstMatch(riga);
      if (m != null && id != null) fuori[id]![m.group(1)!] = m.group(2)!.trim();
    }
    return fuori;
  }

  final fontiFonte = celle('fonti.md');
  final regoleFonte = celle('regole.md');

  Map<String, String> testiFonte() {
    final fuori = <String, String>{};
    String? sezione;
    for (final riga in File('$cartella/testi.md').readAsLinesSync()) {
      final s = RegExp(r'^## (\w+)\s*$').firstMatch(riga);
      if (s != null) {
        sezione = s.group(1);
        continue;
      }
      final m = RegExp(r'^- ([\w.]+):\s*(.*)$').firstMatch(riga);
      if (m != null && sezione != null) {
        fuori['$sezione.${m.group(1)}'] = m.group(2)!.trim();
      }
    }
    return fuori;
  }

  test('le cardinalita\' minime dichiarate', () {
    cardinaleMinimo(fontiFonte.length, 10,
        cosa: 'fonti in docs/corpus/lunario/fonti.md');
    cardinaleMinimo(regoleFonte.length, 27,
        cosa: 'regole in docs/corpus/lunario/regole.md',
        perche: 'ogni attivita\' del contratto (27) ha bisogno di almeno '
            'una regola con fonte vera');
    cardinaleMinimo(testiFonte().length, 4,
        cosa: 'testi in docs/corpus/lunario/testi.md',
        perche: 'i quattro giorni tuoi di FV.07');
    cardinaleMinimo(fontiDelLunario.length, 10,
        cosa: 'fonti nel Dart generato');
    cardinaleMinimo(regoleDelLunario.length, 27,
        cosa: 'regole nel Dart generato');
    cardinaleMinimo(testiDelLunario.length, 4, cosa: 'testi nel Dart generato');
  });

  test('ogni regola ha fonti che esistono davvero', () {
    final mancanti = <String>[];
    for (final MapEntry(key: id, value: campi) in regoleFonte.entries) {
      final fonti = (campi['fonti'] ?? '').split(',').map((f) => f.trim());
      for (final f in fonti) {
        if (f.isNotEmpty && !fontiFonte.containsKey(f)) {
          mancanti.add('$id -> $f');
        }
      }
    }
    expect(mancanti, isEmpty,
        reason: 'regole con una fonte inesistente: $mancanti');
  });

  test('ogni attivita\' del contratto ha almeno una regola con fonte vera', () {
    final conFonteVera = <String>{};
    for (final regola in regoleDelLunario) {
      if (regola.fonti.any((f) => f != 'chiave_di_medora')) {
        for (final a in regola.attivita) {
          conFonteVera.add(a.name);
        }
      }
    }
    final senza = [
      for (final a in AttivitaDelLunario.values)
        if (!conFonteVera.contains(a.name)) a.name,
    ];
    expect(senza, isEmpty,
        reason:
            'attivita\' senza una regola con una fonte documentata: $senza');
  });

  test('il Dart generato coincide con la fonte riletta qui', () {
    final idGenerati = regoleDelLunario.map((r) => r.id).toSet();
    final idFonte = regoleFonte.keys.toSet();
    expect(idGenerati, idFonte,
        reason: 'gli id delle regole nel .g.dart non coincidono con '
            'regole.md: rigenera con python tool/il_corpus_del_lunario.py '
            'genera');
    for (final regola in regoleDelLunario) {
      final campi = regoleFonte[regola.id]!;
      expect(regola.detto, campi['detto'],
          reason:
              '${regola.id}: il "detto" generato non coincide con la fonte');
      final fontiAttese = (campi['fonti'] ?? '')
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();
      expect(regola.fonti, fontiAttese,
          reason:
              '${regola.id}: le fonti generate non coincidono con la fonte');
    }
    final idFontiGenerati = fontiDelLunario.keys.toSet();
    expect(idFontiGenerati, fontiFonte.keys.toSet(),
        reason: 'le fonti del .g.dart non coincidono con fonti.md');
    expect(testiDelLunario, testiFonte(),
        reason: 'i testi del .g.dart non coincidono con testi.md');
  });

  test('nessuna regola di salute o soldi nel corpus generato', () {
    // Le radici di R8 dell'ordine FV: niente salute, niente soldi, nessuna
    // promessa di esito, niente fertilita'/fecondita', mai la NASA.
    final vietate = RegExp(
        r'(?<![A-Za-zÀ-ÿ])('
        r'salute|sanità|malat\w*|guari\w*|curativ\w*|terapi\w*|rimedi\w*|'
        r'farmac\w*|medic\w*|dentist\w*|diet\w*|digiun\w*|'
        r'soldi|denar\w*|guadagn\w*|investiment\w*|invest\w*|ricchezz\w*|'
        r'garantit\w*|'
        r'fertil\w*|steril\w*|fecond\w*|gravid\w*|incint\w*|concepi\w*|'
        r'nasa'
        r')(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final trovate = <String>[];
    var guardati = 0;
    for (final r in regoleDelLunario) {
      guardati++;
      final m = vietate.firstMatch(r.detto);
      if (m != null) trovate.add('${r.id}: "${m.group(0)}"');
    }
    for (final f in fontiDelLunario.values) {
      for (final t in [f.citazione, f.indirizzo, f.dice]) {
        guardati++;
        final m = vietate.firstMatch(t);
        if (m != null) trovate.add('${f.id}: "${m.group(0)}"');
      }
    }
    for (final MapEntry(key: chiave, value: testo) in testiDelLunario.entries) {
      guardati++;
      final m = vietate.firstMatch(testo);
      if (m != null) trovate.add('$chiave: "${m.group(0)}"');
    }
    cardinaleMinimo(guardati, 36 + 10,
        cosa: 'testi guardati per la politica R8');
    expect(trovate, isEmpty, reason: 'parole vietate da R8: $trovate');
  });
}
