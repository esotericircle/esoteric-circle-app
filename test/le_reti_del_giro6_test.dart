// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/la_posizione_della_lettura.dart';
import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE RETI CONTRO I GIUDIZI DATI A MANO. Ordine ES voce 19, 29 settembre
/// 2026.**
///
/// La voce: *"Ritocchi alle reti che scartano le risposte dirette (il sì
/// detto senza "sì", il no detto con "non", il "sì, se" sulla coppia):
/// entrano, perché senza non si arriva a 30 su 30"*, risposta del fondatore
/// *"Confermo tutto"*.
///
/// Al giro 6 del banco delle trenta domande le due reti hanno scartato 101
/// risposte, e ognuna e' stata giudicata a mano
/// (`docs/collaudo/ET/trenta_domande/giro6_scartate.txt`): 55 scarti inutili,
/// 43 giusti, 3 risposte dirette fermate. Qui si pretende che ogni rete
/// scarti cio' che il giudizio chiama un difetto vero, e lasci passare cio'
/// che chiama diretto o certo solo in apparenza. I casi stanno in
/// `docs/collaudo/ES/giro6_reti.json`, scritto da `tool/le_reti_del_giro6.py`.
void main() {
  final casi =
      (jsonDecode(File('docs/collaudo/ES/giro6_reti.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();
  Maestro maestro(String n) => Maestro.values.firstWhere((m) => m.name == n);
  String domanda(Map<String, dynamic> c) =>
      (c['domanda'] as String).replaceFirst(RegExp(r'^\d+\.\s*'), '');

  test('la rete della prima frase: scarta le vaghe, lascia le dirette', () {
    final pf = casi
        .where((c) => (c['reti'] as String).contains('prima frase senza'))
        .toList();
    cardinaleMinimo(pf.length, 40, cosa: 'casi della rete della prima frase');
    final dirette = pf.where((c) => c['bozzaDiretta'] == true).toList();
    final vaghe = pf.where((c) => c['bozzaDiretta'] != true).toList();
    final scartateDirette = <int>[];
    final passateVaghe = <int>[];
    for (final c in pf) {
      final m = maestro(c['maestro'] as String);
      // Nel LIVE la domanda arriva detta, e il controller le rimette il
      // punto interrogativo: la rete la legge cosi'.
      final d = c['canale'] == 'live'
          ? LaPosizioneDellaLettura.comeDomandaDetta(domanda(c))
          : domanda(c);
      final passa =
          LaPosizioneDellaLettura.rispetta(m, d, c['scartata'] as String);
      if (c['bozzaDiretta'] == true && !passa) scartateDirette.add(c['n']);
      if (c['bozzaDiretta'] != true && passa) passateVaghe.add(c['n']);
    }
    print('ORDINE ES VOCE 19: rete della prima frase su ${pf.length} casi del '
        'giro 6: dirette ancora scartate ${scartateDirette.length} su '
        '${dirette.length} $scartateDirette; vaghe lasciate passare '
        '${passateVaghe.length} su ${vaghe.length} $passateVaghe');
    // Al giro 6 le dirette scartate erano tutte (la rete le aveva scartate
    // davvero), e le vaghe tutte fermate.
    expect(scartateDirette.length, lessThanOrEqualTo(dirette.length ~/ 5),
        reason: 'la rete scarta ancora le risposte dirette: $scartateDirette');
    expect(passateVaghe.length, lessThanOrEqualTo(vaghe.length ~/ 5),
        reason: 'la rete lascia passare le prime frasi vaghe: $passateVaghe');
  });

  test('la rete delle certezze: prende le vere, lascia le apparenti', () {
    final ce = casi
        .where((c) =>
            (c['reti'] as String).contains('certezza') &&
            c['certezzaVera'] != null)
        .toList();
    cardinaleMinimo(ce.length, 30, cosa: 'casi della rete delle certezze');
    final vere = ce.where((c) => c['certezzaVera'] == true).toList();
    final apparenti = ce.where((c) => c['certezzaVera'] == false).toList();
    final vereMancate = <int>[];
    final apparentiPrese = <int>[];
    for (final c in ce) {
      final prese = LeCertezzeDelMaestro.inQuesteFrasi(c['scartata'] as String);
      if (c['certezzaVera'] == true && prese.isEmpty) vereMancate.add(c['n']);
      if (c['certezzaVera'] == false && prese.isNotEmpty) {
        apparentiPrese.add(c['n']);
      }
    }
    // Le certezze vere che al giro 6 nessuna rete aveva tolto: la forma
    // "La sua X e' Y" al presente, sul suo stato interiore.
    final sfuggite = <String>[];
    for (final frase in const [
      'La sua riserva è una forma di rispetto, non di disinteresse.',
      'La sua esitazione non è disinteresse.',
      'La sua mente è chiara, ma la sua lingua no.',
    ]) {
      if (LeCertezzeDelMaestro.inQuesteFrasi(frase).isEmpty) {
        sfuggite.add(frase);
      }
    }
    print('ORDINE ES VOCE 19: rete delle certezze su ${ce.length} casi del '
        'giro 6: vere mancate ${vereMancate.length} su ${vere.length} '
        '$vereMancate; apparenti prese ${apparentiPrese.length} su '
        '${apparenti.length} $apparentiPrese; certezze sfuggite al giro 6 '
        'ancora sfuggite ${sfuggite.length} su 3');
    expect(vereMancate.length, lessThanOrEqualTo(vere.length ~/ 5),
        reason: 'la rete non prende piu\' le certezze vere: $vereMancate');
    expect(apparentiPrese.length, lessThanOrEqualTo(apparenti.length ~/ 3),
        reason: 'la rete scarta ancora le certezze apparenti: '
            '$apparentiPrese');
    expect(sfuggite, isEmpty);
  });
}
