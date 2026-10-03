// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/la_risposta_ripetuta.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DOMANDE SIMILI DI FILA, LA SECONDA NON RIDICE LA PRIMA. Ordine ES voce
/// 21, 29 settembre 2026.**
///
/// Il fondatore: *"Ho provato a fare Domande simili consecutive e le
/// risposte, non solo non erano adeguate [...]"*. Le 240 seconde di coppia
/// del banco delle trenta domande, giudicate alla cieca in quattro fasi
/// (`docs/collaudo/ES/coppie_ripetute.json`, scritto da
/// `tool/le_coppie_ripetute.py`), dicono quali ripetono la prima: 26. Qui si
/// pretende che la rete ne prenda almeno la meta' e che sbagli poco sulle
/// altre 214, perche' ogni sbaglio e' un'attesa in piu' per una risposta
/// buona.
void main() {
  test('la rete prende le seconde che ripetono, e lascia le altre', () {
    final coppie = (jsonDecode(File('docs/collaudo/ES/coppie_ripetute.json')
            .readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    cardinaleMinimo(coppie.length, 240, cosa: 'seconde di coppia giudicate');
    var prese = 0;
    var false_ = 0;
    var ripetono = 0;
    final mancate = <String>[];
    for (final c in coppie) {
      final dice = LaRispostaRipetuta.quale(
              c['testo'] as String, [c['primaTesto'] as String],
              domanda: c['domanda'] as String,
              domandaPrima: c['primaDomanda'] as String) !=
          null;
      if (c['ripete'] == true) {
        ripetono++;
        if (dice) {
          prese++;
        } else {
          mancate.add(c['voce'] as String);
        }
      } else if (dice) {
        false_++;
      }
    }
    print('ORDINE ES VOCE 21: seconde che ripetono prese $prese su '
        '$ripetono, seconde buone chiamate ripetute $false_ su '
        '${coppie.length - ripetono}; mancate $mancate');
    expect(ripetono, 26);
    expect(prese, greaterThanOrEqualTo(13),
        reason: 'la rete prende meno della meta\' delle ripetizioni');
    expect(false_, lessThanOrEqualTo(3),
        reason: 'la rete chiama ripetute troppe seconde buone');
  });

  test('una domanda nuova, una risposta diversa: non e\' una ripetizione', () {
    const prima = 'Le carte dicono di sì, se gli scrivi tu per primo. Il '
        'Fante di Coppe parla di un sentimento timido, la Luna in Pesci '
        'chiede pazienza.';
    const seconda = 'Le carte dicono di no, per ora: il colloquio arriva '
        'troppo presto. Il Due di Denari chiede di preparare il portfolio e '
        'di aspettare la settimana prossima.';
    expect(
        LaRispostaRipetuta.quale(seconda, [prima],
            domanda: 'Mi prenderanno al colloquio?',
            domandaPrima: 'Lui mi ama davvero?'),
        isNull);
  });
}
