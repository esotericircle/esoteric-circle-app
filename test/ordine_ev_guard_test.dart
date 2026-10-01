// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE EV.** 1 ottobre 2026.
///
/// Il manifesto `ORDINE_EV_MANIFESTO.md` porta le sei voci del pezzo 1
/// (EV.01-EV.06), le quattro dell'Architetto del pezzo 2 (EV.07-EV.10) e le
/// dieci segnalazioni del fondatore arrivate durante il lavoro
/// (EV.51-EV.60), ognuna con uno stato solo; i marcatori dicono le
/// stesse cose delle voci; e la voce EU.14 ha nel manifesto EU la riga che
/// l'ordine le chiede, "prosegue nell'ordine EV, voce EV.08".
void main() {
  final manifesto = File('docs/ordini/ORDINE_EV_MANIFESTO.md');
  const voci = [
    'EV.01', 'EV.02', 'EV.03', 'EV.04', 'EV.05', 'EV.06', //
    'EV.07', 'EV.08', 'EV.09', 'EV.10', //
    'EV.51', 'EV.52', 'EV.53', 'EV.54', 'EV.55', 'EV.56', 'EV.57', //
    'EV.58', 'EV.59', 'EV.60',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte le venti voci', () {
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
    print('ORDINE EV: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
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

  test('EU.14 dice che prosegue nella voce EV.08', () {
    final eu = File('docs/ordini/ORDINE_EU_MANIFESTO.md').readAsStringSync();
    final inizio = eu.indexOf('## VOCE EU.14,');
    expect(inizio, greaterThan(-1));
    final fine = eu.indexOf('\n## ', inizio + 1);
    final voce = eu.substring(inizio, fine < 0 ? eu.length : fine);
    expect(voce, contains("prosegue nell'ordine EV, voce EV.08"),
        reason: 'la riga che l\'ordine EV chiede alla voce EU.14 manca');
  });
}
