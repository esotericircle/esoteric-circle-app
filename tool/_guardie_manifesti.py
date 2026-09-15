# -*- coding: utf-8 -*-
"""CQ4.01: una guardia per ogni manifesto sigillato."""
NL = chr(10)
Q = chr(39)
B = chr(92)

ORDINI = {'CM': 11, 'CN': 16, 'CO': 20, 'CP': 10}

MODELLO = '''import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE @MAIUSC@.
///
/// **Nata con l'ordine CQ voce 4.01, 4 settembre 2026.** Il Collaudatore degli
/// Ordini prende solo manifesti terminali e sigillati coi marcatori a
/// macchina: @MAIUSC@ non li aveva, quindi il Collaudatore lo saltava e andava a
/// ritroso. **Un ordine che nessuno puo' collaudare non e' un ordine finito,
/// e' un ordine di cui nessuno sa niente.**
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le @QUANTE@ voci non hanno tutte uno stato terminale.
void main() {
  final manifesto = File('docs/ordini/ORDINE_@MAIUSC@_MANIFESTO.md');

  const quante = @QUANTE@;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^\$nome:@BS@s*(@BS@d+)@BS@s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore \$nome, e senza marcatori '
            'nessuno puo@Q@ leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  List<String> righeDiVoce(String testo) => testo
      .split('@BS@n')
      .where((r) => RegExp(r'^- @BS@*@BS@*@MAIUSC@@BS@.@BS@d@BS@d@BS@*@BS@*').hasMatch(r))
      .toList();

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_@MAIUSC@_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = '@MAIUSC@.\${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**\$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: \$mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante),
        reason: 'le righe di voce trovate sono \${righe.length} invece di '
            '\$quante: il blocco degli stati non copre tutto l@Q@ordine');
    final conti = <String, int>{for (final m in stati.values) m: 0};
    final senzaStato = <String>[];
    for (final r in righe) {
      final trovato = stati.keys.firstWhere(
          (stato) => r.contains('**\$stato.**') || r.contains('**\$stato**'),
          orElse: () => '');
      if (trovato.isEmpty) {
        senzaStato.add(r.substring(0, r.length < 40 ? r.length : 40));
        continue;
      }
      conti[stati[trovato]!] = conti[stati[trovato]]! + 1;
    }
    expect(senzaStato, isEmpty,
        reason: 'queste righe non portano nessuno dei cinque stati ammessi: '
            '\$senzaStato');
    // ignore: avoid_print
    print('ORDINE @MAIUSC@: voci \$quante, '
        '\${conti.entries.map((e) => "\${e.key} \${e.value}").join(", ")}');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    var somma = 0;
    for (final voce in conti.entries) {
      expect(marcatore(testo, voce.key), voce.value,
          reason: 'il marcatore \${voce.key} non coincide con le righe vere');
      somma += voce.value;
    }
    expect(somma, quante,
        reason: 'i sei marcatori non sommano al totale delle voci');
  });

  test('l@Q@ordine @MAIUSC@ non e@Q@ finito finche@Q@ una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE @MAIUSC@: voci ancora aperte \$aperte');
    expect(aperte, 0,
        reason: 'restano \$aperte voci aperte: questa prova e@Q@ rossa per '
            'legge di consegna finche@Q@ tutte non hanno uno stato terminale');
  });
}
'''

for ordine, quante in ORDINI.items():
    testo = (MODELLO
             .replace('@MAIUSC@', ordine)
             .replace('@QUANTE@', str(quante))
             .replace('@BS@', B)
             .replace('@Q@', Q))
    percorso = 'test/ordine_%s_guard_test.dart' % ordine.lower()
    open(percorso, 'w', encoding='utf-8', newline=NL).write(testo)
    print('SCRITTA', percorso)
