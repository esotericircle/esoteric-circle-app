// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'le_voci_aperte_dicono_cosa_aspettano.dart';

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

  // **LAPIDE, ordine FC voce 11.** Qui c'era "ogni voce dichiara uno stato
  // terminale, e i conti tornano", che pretendeva zero voci aperte ed era
  // rossa per costruzione: le voci aperte aspettano gesti del fondatore che
  // sul ramo non esistono. Il fondatore, il 5 ottobre 2026, ha scelto la
  // cura (3) della FC.11: la prova gira sul ramo e pretende che ogni voce
  // aperta dica quale gesto aspetta. Il perche' per esteso sta in
  // `le_voci_aperte_dicono_cosa_aspettano.dart`.
  test(
      'ogni voce ha uno stato, i conti tornano, e ogni voce aperta dice '
      'quale gesto aspetta', () {
    leVociAperteDiconoCosaAspettano('EJ', quante);
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
