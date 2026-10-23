// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'le_voci_aperte_dicono_cosa_aspettano.dart';

/// LA GUARDIA DELL'ORDINE EK, la build, le risposte dirette, i nomi e i volti.
///
/// **Nasce rossa per costruzione**, come le guardie degli ordini EI ed EJ:
/// l'ordine apre con cinque voci aperte su cinque, la prova che pretende zero
/// voci aperte cade subito e resta rossa finche' il lavoro non e' fatto e
/// guardato. Le voci chiuse le sorveglia
/// `ogni_voce_chiusa_porta_la_sua_prova_test.dart`, che pretende sotto
/// ciascuna la domanda del fondatore, la prova e la misura.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EK_MANIFESTO.md');

  const quante = 5;

  test('il manifesto esiste e porta tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EK.${i.toString().padLeft(2, '0')}';
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
    leVociAperteDiconoCosaAspettano('EK', quante);
  });

  test('gli scarti fra l\'ordine e il ramo sono dichiarati col file e la riga',
      () {
    // L'ordine lo pretende: "Dove trovi una smentita applichi il resto e
    // riporti lo scarto col file e la riga".
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'la premessa su Medora, misurata e non confermata':
          'Medora non e\' la meno diretta',
      'la regola comune che metteva il simbolo in seconda frase':
          'maestro_persona.dart` riga 232',
      'la regola di Medora che metteva il cielo in seconda frase':
          'voce_del_maestro.dart` righe 307-311',
      'la parola da portare presa alla lettera':
          'maestro_persona.dart` riga 214',
      'il diario dell\'Alba che Firestore rifiutava':
          'diario_dell_alba.dart` riga 350',
      'la sessione di Protoface che non si chiudeva': 'POST /v1/sessions',
      'lo schermo che si spegneva nel LIVE': 'FLAG_KEEP_SCREEN_ON',
    };
    final mancanti = [
      for (final p in pretese.entries)
        if (!testo.contains(p.value)) '${p.key} (${p.value})'
    ];
    // Il cardinale, su un elenco scritto a mano.
    expect(pretese.length, 7);
    expect(mancanti, isEmpty, reason: 'il manifesto non dichiara: $mancanti');
  });
}
