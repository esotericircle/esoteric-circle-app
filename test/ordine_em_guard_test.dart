// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EM, il LIVE che ascolta giusto, le voci scelte e
/// tre decisioni sull'ordine EK.
///
/// **Nasce rossa per costruzione**, come le guardie degli ordini EI, EJ ed
/// EK: l'ordine apre con dodici voci aperte su dodici, la prova che pretende
/// zero voci aperte cade subito e resta rossa finche' il lavoro non e' fatto
/// e guardato. Le voci chiuse le sorveglia
/// `ogni_voce_chiusa_porta_la_sua_prova_test.dart`, che pretende sotto
/// ciascuna la domanda del fondatore, la prova e la misura.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EM_MANIFESTO.md');

  const quante = 12;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e dodici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EM.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EM: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test('le parole del fondatore sulla televisione stanno nel manifesto', () {
    // Sono la misura della voce EM.04: non basta il respiro, serve la
    // tolleranza di "Ok Google" con la televisione accesa. Senza questa
    // frase chi legge il manifesto misurerebbe la cosa sbagliata.
    final testo = manifesto.readAsStringSync();
    const pretese = <String>[
      'Io uso "Ok Google" giornalmente con TV',
      'Ho bisogno dello stesso',
      'Sintetico, poi il mio',
      'Tutto, una build',
    ];
    final mancanti = [
      for (final p in pretese)
        if (!testo.contains(p)) p
    ];
    expect(pretese.length, 4);
    expect(mancanti, isEmpty, reason: 'il manifesto non porta: $mancanti');
  });
}
