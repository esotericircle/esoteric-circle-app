// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EG, il LIVE dei Maestri.
///
/// **L'ordine e' interrotto, non chiuso.** L'ordine EH, urgente e
/// straordinario, lo ha fermato il 24 settembre 2026 e riprende solo quando
/// quello e' finito e verificato. Quindi questa guardia **non pretende che le
/// voci siano chiuse**: pretende che il manifesto esista, che nomini tutte e
/// nove le voci e che i conti tornino, cosi' il giorno che l'ordine riparte
/// nessuno trova un manifesto mezzo scritto.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EG_MANIFESTO.md');

  const quante = 9;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e nove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EG.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i conti tornano, anche a ordine interrotto', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EG: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante);
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
  });

  test('il manifesto porta i fatti verificati prima del codice', () {
    // **Le chiavi e gli identificativi non sono una promessa**: sono stati
    // ricavati dal server prima di scrivere una riga, e il manifesto li porta.
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'l identificativo di Medora': 'av_01M0N4GC9M1791PVH6NDD4FMMG',
      'lo scarto sulla stanza LiveKit': 'we never touch',
      'la premessa verificata sulla documentazione': 'driven by',
    };
    final mancanti = <String>[];
    for (final p in pretese.entries) {
      if (!testo.contains(p.value)) mancanti.add('${p.key} (${p.value})');
    }
    expect(mancanti, isEmpty, reason: 'il manifesto non porta: $mancanti');
  });
}
