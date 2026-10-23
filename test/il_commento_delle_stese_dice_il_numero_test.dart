import 'dart:io';

import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL COMMENTO DELLE STESE DICE IL NUMERO VERO. Ordine FK, aggiunta 2 voce
/// A14, 12 ottobre 2026.
///
/// Il commento in testa a `TarotSpreadType` dichiarava "CINQUE STESE" e
/// aspettava "quelle da sette e dieci carte", mentre l'enum ne porta quattro:
/// il ferro di cavallo e' una lapide dall'ordine FJ e la Croce Celtica c'e'
/// gia'. Chi legge il commento per sapere quante stese ci sono deve trovare
/// il numero dell'enum. Vista rossa sul commento vecchio prima di correggerlo
/// (docs/collaudo/FK/fk_aggiunta_regola_a.txt).
void main() {
  test('A14: il numero di stese scritto nel commento e\' quello dell\'enum', () {
    const parole = {
      'UNA': 1,
      'DUE': 2,
      'TRE': 3,
      'QUATTRO': 4,
      'CINQUE': 5,
      'SEI': 6,
      'SETTE': 7,
      'OTTO': 8,
    };
    final testo =
        File('lib/core/tarot/tarot_spread_type.dart').readAsStringSync();
    final dichiarato =
        RegExp(r'\*\*([A-Z]+) STESE\*\*').firstMatch(testo)?.group(1);
    expect(dichiarato, isNotNull,
        reason: 'il commento non dichiara piu\' quante sono le stese');
    expect(parole[dichiarato], TarotSpreadType.values.length,
        reason: 'il commento dice $dichiarato stese, l\'enum ne porta '
            '${TarotSpreadType.values.length}');
    expect(testo, contains('LAPIDE: la Stesa del Ferro di Cavallo'),
        reason: 'la lapide del ferro di cavallo e\' la memoria della '
            'decisione e non si cancella');
  });
}
