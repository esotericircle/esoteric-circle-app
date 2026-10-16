// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE EW.** 2 ottobre 2026.
///
/// Il manifesto `ORDINE_EW_MANIFESTO.md` porta le sette voci dell'ordine
/// (EW.01-EW.07), ognuna con uno stato solo, e i marcatori dicono le stesse
/// cose delle voci. I sette documenti che l'ordine chiede esistono, e il
/// conto del costo per utente e' quello che lo script dei conti scrive
/// dalle chiamate misurate: il numero dell'Iniziato nel documento e' lo
/// stesso dell'uscita di `tool/i_conti_del_costo_ew.py`.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EW_MANIFESTO.md');
  const voci = [
    'EW.01', 'EW.02', 'EW.03', 'EW.04', 'EW.05', 'EW.06', 'EW.07', //
  ];
  const documenti = [
    'docs/costi/le_chiamate_al_modello.md',
    'docs/costi/il_viaggio_e_il_modello.md',
    'docs/collaudo/EW/etichette.txt',
    'docs/costi/costo_per_funzione.md',
    'docs/costi/costo_per_utente.md',
    'docs/costi/le_leve_del_costo.md',
    'docs/costi/il_minuto_del_live.md',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte le sette voci', () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync();
    final mancanti = [
      for (final v in voci)
        if (!testo.contains('## VOCE $v,')) v,
    ];
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EW: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
        'fare $daFare');
    var contateChiuse = 0, contateAperte = 0, contateDaFare = 0;
    final senzaStato = <String>[];
    final conPiuStati = <String>[];
    for (final v
        in testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1)) {
      final nome = v.split('\n').first;
      final chiusa = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final aperta = v.contains('**APERTA IN ATTESA DI VERIFICA**');
      final daFareQui = v.contains('**DA FARE.**');
      final stati = [chiusa, aperta, daFareQui].where((x) => x).length;
      if (stati == 0) senzaStato.add(nome);
      if (stati > 1) conPiuStati.add(nome);
      if (chiusa) contateChiuse++;
      if (aperta && !chiusa) contateAperte++;
      if (daFareQui && !chiusa && !aperta) contateDaFare++;
    }
    expect(senzaStato, isEmpty, reason: 'voci senza stato: $senzaStato');
    expect(conPiuStati, isEmpty, reason: 'voci con piu\' stati: $conPiuStati');
    expect(dichiarate, voci.length);
    expect(contateChiuse, chiuse);
    expect(contateAperte, aperte);
    expect(contateDaFare, daFare);
  });

  test('i sette documenti dell\'ordine esistono e non sono vuoti', () {
    final mancanti = [
      for (final d in documenti)
        if (!File(d).existsSync() || File(d).lengthSync() == 0) d,
    ];
    print('ORDINE EW: documenti ${documenti.length - mancanti.length} su '
        '${documenti.length}');
    expect(mancanti, isEmpty, reason: 'documenti mancanti: $mancanti');
  });

  test(
      'il costo dell\'Iniziato nel documento e\' quello dei conti sulle '
      'chiamate misurate', () {
    final conti = File('docs/costi/i_conti_del_costo.txt').readAsStringSync();
    final riga = RegExp(r'^Iniziato: modello al massimo 30 giorni (\d+)\.(\d+)',
            multiLine: true)
        .firstMatch(conti);
    expect(riga, isNotNull,
        reason: 'i conti non portano la riga dell\'Iniziato');
    final numero = '${riga!.group(1)},${riga.group(2)}';
    // La riga dell'Iniziato nella tabella "In breve", e non il numero
    // ovunque nel documento: alla prova del rosso lo stesso numero stava
    // anche nella riga dei trenta giorni, e la guardia restava verde.
    final righe = File('docs/costi/costo_per_utente.md')
        .readAsLinesSync()
        .where((r) => r.startsWith('| Iniziato |'))
        .toList();
    print('ORDINE EW: Iniziato al massimo nei conti $numero dollari');
    expect(righe, hasLength(1),
        reason:
            'la tabella "In breve" deve avere una riga sola dell\'Iniziato');
    expect(righe.single, contains('| **$numero \$** '),
        reason: 'il documento del costo per utente non dice il numero dei '
            'conti ($numero): i conti sono stati rifatti e il documento no, '
            'o il contrario');
  });
}
