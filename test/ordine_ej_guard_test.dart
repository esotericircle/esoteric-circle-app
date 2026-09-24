// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EJ, il microfono, le voci e le risposte.
///
/// **Nasce rossa per costruzione**, come la guardia dell'ordine EI: l'ordine
/// apre con dieci voci aperte su dieci, la prova che pretende zero voci
/// aperte cade subito e resta rossa finche' il lavoro non e' fatto e
/// guardato. Le voci chiuse le sorveglia
/// `ogni_voce_chiusa_porta_la_sua_prova_test.dart`, che pretende sotto
/// ciascuna la domanda del fondatore, la prova e la misura.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EJ_MANIFESTO.md');

  const quante = 10;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e dieci le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EJ.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EJ: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test('gli scarti fra l\'ordine e il ramo sono dichiarati col file e la riga',
      () {
    // L'ordine lo pretende: "Dove trovi una smentita applichi il resto e
    // riporti lo scarto col file e la riga".
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'le catture che non sono arrivate': 'Le sedici catture non sono arrivate',
      'la pronuncia che nell\'app non c\'era': 'Non ce n\'e\' nessuno',
      'l\'invito che scrive l\'app': 'righe 178-249',
      'i dati imposti da una regola nostra': 'righe 481-483',
      'la qualita\' mai dichiarata': 'righe 285-313',
      'l\'eccezione alla regola ferrea su Esplora': 'barraNascostaAllApertura',
    };
    final mancanti = [
      for (final p in pretese.entries)
        if (!testo.contains(p.value)) '${p.key} (${p.value})'
    ];
    // Il cardinale, su un elenco scritto a mano.
    expect(pretese.length, 6);
    expect(mancanti, isEmpty, reason: 'il manifesto non dichiara: $mancanti');
  });
}
