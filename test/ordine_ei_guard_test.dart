// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'le_voci_aperte_dicono_cosa_aspettano.dart';

/// LA GUARDIA DELL'ORDINE EI, le dodici voci che tornano aperte.
///
/// **Questa guardia nasce rossa per costruzione**, ed e' la prima volta che
/// puo' permetterselo onestamente: l'ordine apre con **dieci voci aperte su
/// dieci**, quindi la prova che pretende zero voci aperte cade subito, e resta
/// rossa finche' il lavoro non e' fatto. Non e' un trucco: e' cio' che la
/// Regola A chiede, una guardia vista rossa prima di essere creduta.
///
/// **E c'e' una pretesa che le altre guardie d'ordine non hanno.** L'ordine EI
/// nasce dall'ordine EH, cioe' dalla scoperta che dodici voci erano dichiarate
/// chiuse senza portare una prova. Quindi qui non basta che i conti tornino:
/// **il manifesto deve nominare tutte e dodici le voci riaperte con la loro
/// sigla d'origine**, altrimenti una di quelle dodici puo' sparire dal
/// perimetro senza che nessuno se ne accorga, che e' esattamente il modo in
/// cui erano sparite la prima volta.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EI_MANIFESTO.md');

  const quante = 10;

  /// Le dodici voci riaperte, con la sigla dell'ordine che le aveva chiuse.
  /// **Sono dodici e le voci di quest'ordine sono dieci**, perche' le tre
  /// dell'ordine EC sono un lavoro solo.
  const riaperte = [
    'EB.01',
    'EB.06',
    'EC.01',
    'EC.02',
    'EC.03',
    'ED.02',
    'EE.03',
    'EE.10',
    'EE.12',
    'EF.01',
    'EF.02',
    'EF.04',
  ];

  test('il manifesto esiste e porta tutte e dieci le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EI.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('tutte e dodici le voci riaperte sono nominate col loro nome', () {
    final testo = manifesto.readAsStringSync();
    final mancanti = [
      for (final v in riaperte)
        if (!testo.contains(v)) v
    ];
    print('ORDINE EI: voci riaperte nominate '
        '${riaperte.length - mancanti.length} su ${riaperte.length}');
    // Il cardinale, su un elenco scritto a mano: se qualcuno lo svuotasse,
    // questa prova sarebbe verde senza aver cercato niente.
    expect(riaperte.length, 12);
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci riaperte: $mancanti. '
            'Una voce che sparisce dal perimetro sparisce come la prima '
            'volta, e quella e\' la ragione per cui esiste quest\'ordine');
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
    leVociAperteDiconoCosaAspettano('EI', quante);
  });

  test('gli scarti fra l\'ordine e il ramo sono dichiarati col file e la riga',
      () {
    // **L'ordine stesso lo pretende**: *"Dove trovi una smentita applichi il
    // resto e riporti lo scarto col file e la riga"*. Tre scarti trovati
    // prima di toccare niente, e il piu' pesante e' che una voce dell'ordine
    // chiedeva di disfare una decisione presa dal fondatore.
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'lo scarto sulla cadenza del respiro': 'Lascio come sta, decide il rito',
      'il file e la riga della cadenza': 'rito_alba_corpus.dart',
      'lo scarto sulla sigla del conteggio': 'ordine EA voce 12',
      'lo scarto sul verso della EB.06': 'esito_del_turno.dart:52-56',
    };
    final mancanti = [
      for (final p in pretese.entries)
        if (!testo.contains(p.value)) '${p.key} (${p.value})'
    ];
    expect(mancanti, isEmpty, reason: 'il manifesto non dichiara: $mancanti');
  });
}
