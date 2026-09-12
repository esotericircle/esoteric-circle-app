import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CC.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le nove voci non hanno uno stato terminale.
///
/// **E chiede tre sezioni**, perche' quest'ordine le pretende per nome: le
/// affermazioni trovate false, le scelte prese da me, e le decisioni che NON
/// sono mie, cioe' quelle che toccano il listino, cambiano una frase che la
/// persona legge, o decidono se un dato resta o sparisce.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CC_MANIFESTO.md');

  const quante = 9;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  List<String> righeDiVoce(String testo) => testo
      .split('\n')
      .where((r) => RegExp(r'^- \*\*CC\.\d\d\*\*').hasMatch(r))
      .toList();

  /// I cinque stati ammessi, dal piu' lungo al piu' corto: si cerca lo stato
  /// dentro le stelline, non nel testo libero della riga.
  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte e nove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CC_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CC.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante));
    final conti = <String, int>{for (final m in stati.values) m: 0};
    final senzaStato = <String>[];
    for (final r in righe) {
      final trovato = stati.keys.firstWhere(
          (stato) => r.contains('**$stato.**') || r.contains('**$stato**'),
          orElse: () => '');
      if (trovato.isEmpty) {
        senzaStato.add(r.substring(0, r.length < 40 ? r.length : 40));
        continue;
      }
      conti[stati[trovato]!] = conti[stati[trovato]]! + 1;
    }
    expect(senzaStato, isEmpty,
        reason: 'queste righe non portano nessuno dei cinque stati ammessi: '
            '$senzaStato');
    // ignore: avoid_print
    print('ORDINE CC: voci $quante, '
        '${conti.entries.map((e) => "${e.key} ${e.value}").join(", ")}');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    var somma = 0;
    for (final voce in conti.entries) {
      expect(marcatore(testo, voce.key), voce.value,
          reason: 'il marcatore ${voce.key} non coincide con le righe vere');
      somma += voce.value;
    }
    expect(somma, quante,
        reason: 'i sei marcatori non sommano al totale delle voci');
  });

  test('le tre sezioni obbligatorie ci sono, e non sono vuote', () {
    final testo = manifesto.readAsStringSync();
    const sezioni = <String, String>{
      'LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE':
          'la REGOLA ZERO chiede di verificare ogni affermazione',
      'LE SCELTE CHE HO PRESO IO E PERCHE\'':
          'la REGOLA UNO chiede di motivare ogni scelta',
      'LE DECISIONI CHE NON SONO MIE':
          'servono al fondatore per vedere in un colpo d\'occhio cosa e\' '
              'stato deciso senza di lui',
    };
    final mancanti = <String>[];
    for (final s in sezioni.entries) {
      if (!testo.contains(s.key)) mancanti.add('${s.key} (${s.value})');
    }
    expect(mancanti, isEmpty, reason: 'mancano queste sezioni: $mancanti');

    // Una sezione che esiste e non dice niente vale come una che non c'e'.
    for (final s in sezioni.keys) {
      final dopo = testo.substring(testo.indexOf(s));
      final righe = dopo
          .split('\n')
          .skip(1)
          .takeWhile((r) => !r.startsWith('## '))
          .where((r) => r.trim().startsWith('-') || r.trim().startsWith('|'))
          .length;
      expect(righe, greaterThan(0), reason: 'la sezione "$s" e\' vuota');
    }
  });

  test('le affermazioni false sono elencate col fatto vero accanto', () {
    final testo = manifesto.readAsStringSync();
    final false_ = RegExp(r'\*\*(VERA A META\x27|SUPERATA|FALSA)')
        .allMatches(testo)
        .length;
    // ignore: avoid_print
    print('ORDINE CC: affermazioni dell\'ordine non vere e dichiarate '
        '$false_');
    expect(false_, greaterThanOrEqualTo(2),
        reason: 'la verifica della REGOLA ZERO non ha dichiarato nessuna '
            'affermazione non vera: o l\'ordine era perfetto, o non e\' stata '
            'fatta');
  });

  test('l\'ordine CC non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine CC. Questa riga '
            'e\' rossa apposta e non si tocca');
  });
}
