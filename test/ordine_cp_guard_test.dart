import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// LA GUARDIA DELL'ORDINE CP.
///
/// **Nata con l'ordine CQ voce 4.01, 4 settembre 2026.** L'ordine CP non aveva
/// una guardia sua: il Collaudatore degli Ordini prende solo manifesti
/// terminali e sigillati, e senza guardia nessuno teneva ferme le sue
/// affermazioni.
///
/// **Cosa sorveglia questa e cosa sorveglia l'altra.** La forma del sigillo,
/// che e' uguale per tutti gli ordini, la misura
/// `i_manifesti_sono_sigillati_test.dart` una volta sola per tutti. Qui si
/// sorveglia il CONTENUTO di CP, che e' suo e di nessun altro: i numeri che
/// l'ordine dichiara e le decisioni che ha preso.
void main() {
  String testo() =>
      File('docs/ordini/ORDINE_CP_MANIFESTO.md').readAsStringSync();

  test('le sei premesse hanno tutte un esito dichiarato', () {
    final t = testo();
    final esiti = RegExp(r'\*\*(VERA|FALSA|vera|falsa)', multiLine: true)
        .allMatches(t)
        .length;
    // ignore: avoid_print
    print('ORDINE CP: esiti di premessa dichiarati nel manifesto $esiti');
    cardinaleMinimo(esiti, 6,
        cosa: 'esiti di premessa dichiarati nel manifesto di CP',
        perche: 'La REGOLA ZERO chiede di verificare ogni affermazione '
            'dell ordine prima di eseguirla: senza esiti scritti nessuno sa '
            'quali erano vere.');
  });

  test('i numeri che l ordine dichiara stanno scritti', () {
    // **NON SONO DECORAZIONI**: sono le misure con cui CP si e' dichiarato
    // finito, e devono restare leggibili da chi collauda.
    final t = testo();
    const pretesi = <String, String>{
      '165': 'i traguardi del corpus',
      'tredici': 'le feste del giorno peggiore prima della scala',
      'REVISIONE F': 'il nome della revisione del corpus',
    };
    final mancanti = <String>[];
    for (final p in pretesi.entries) {
      if (!t.toUpperCase().contains(p.key.toUpperCase())) {
        mancanti.add('${p.key} (${p.value})');
      }
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto di CP non porta piu questi numeri: $mancanti');
  });

  test('la scala e dichiarata superata, e si dice da chi', () {
    // **CP.01 NON E CHIUSA, ed e la cosa piu utile che questo manifesto
    // dica.** La scala ha murato il Cammino, e l'ordine CQ voce 2.13 l'ha
    // spostata dalla maturazione alla scena. Un manifesto che la dichiarasse
    // chiusa manderebbe il Collaudatore su una menzogna.
    final t = testo();
    final riga = t
        .split(String.fromCharCode(10))
        .firstWhere((r) => r.startsWith('- **CP.01**'), orElse: () => '');
    expect(riga, isNotEmpty,
        reason: 'il manifesto non porta piu la riga di stato di CP.01');
    expect(riga.contains('FERMATA SU DECISIONE DEL FONDATORE'), isTrue,
        reason: 'CP.01 e dichiarata "$riga": la scala ha murato il Cammino e '
            'il fondatore l ha rovesciata con la voce CQ 2.13');
    expect(riga.contains('CQ'), isTrue,
        reason: 'la riga di CP.01 non nomina l ordine che l ha superata: chi '
            'legge non sa dove e andata a finire quella decisione');
  });
}
