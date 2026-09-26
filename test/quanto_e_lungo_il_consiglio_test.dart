// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

/// **QUANTO E' LUNGO IL CONSIGLIO DOPO L'ORDINE DF.**
///
/// **Perche' questa prova esiste.** Il fondatore, nell'ordine DF: *"la
/// lunghezza dei testi e la divisione dei paragrafi va bene attualmente"*. Un
/// compositore nuovo che scrive piu' varieta' scrive anche piu' caratteri, e
/// oltre il tetto la bolla **viene troncata**: la varieta' si pagherebbe con
/// una frase mozza, che e' il peggiore dei due mali.
///
/// **Il numero si misura e non si stima**, su tutti e sedici gli argomenti per
/// molte estrazioni, e si confronta col tetto: se il caso peggiore arriva al
/// tetto, il tetto e' gia' stato superato in qualche lettura che nessuno ha
/// visto.
void main() {
  test('IL CASO PEGGIORE DEL CONSIGLIO STA DENTRO IL TETTO, con margine', () {
    final caso = Random(7);
    var peggiore = 0;
    var doveIlPeggiore = '';
    var quante = 0;
    final lunghezze = <int>[];
    for (final t in TarotTopic.values) {
      for (var i = 0; i < 200; i++) {
        final stesa = TarotSpread.draw(seed: caso.nextInt(1 << 31));
        for (final conDomanda in [true, false]) {
          final lettura = TarotReading.of(stesa, t,
              domandaScritta: conDomanda
                  ? 'come posso migliorare il mio rapporto con il denaro'
                  : null);
          quante++;
          final quanto = lettura.consiglio.length;
          lunghezze.add(quanto);
          if (quanto > peggiore) {
            peggiore = quanto;
            doveIlPeggiore = '${t.name}, '
                '${stesa.cards.map((c) => c.displayName).join(" + ")}, '
                'domanda ${conDomanda ? "scritta" : "dal corpus"}';
          }
        }
      }
    }
    lunghezze.sort();
    final mediana = lunghezze[lunghezze.length ~/ 2];
    print('ORDINE DF: misurate $quante composizioni del Consiglio. '
        'Mediana $mediana caratteri, caso peggiore $peggiore '
        '($doveIlPeggiore). Il tetto e ${TettiDellaStesa.consiglio}.');
    expect(peggiore, lessThan(TettiDellaStesa.consiglio),
        reason: 'il Consiglio arriva a $peggiore caratteri contro un tetto di '
            '${TettiDellaStesa.consiglio}: in quelle letture la bolla viene '
            'troncata e la persona legge una frase mozza');
    // **E il margine si dichiara**, cosi la prossima frase del corpus non fa
    // troncare la bolla il giorno che nasce.
    final margine =
        (TettiDellaStesa.consiglio - peggiore) / TettiDellaStesa.consiglio;
    print('ORDINE DF: il margine sul tetto e il '
        '${(margine * 100).toStringAsFixed(1)} per cento');
    expect(margine, greaterThan(0.05),
        reason: 'il margine sul tetto e solo il '
            '${(margine * 100).toStringAsFixed(1)} per cento: sta al filo');
  });
}
