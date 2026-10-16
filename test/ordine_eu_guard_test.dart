// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE EU.** 1 ottobre 2026.
///
/// Il manifesto porta le diciannove voci dell'ordine, ognuna con uno stato
/// solo: CHIUSA con domanda, prova e misura, APERTA IN ATTESA DI VERIFICA,
/// oppure DA FARE finche' l'ordine e' in corso. I marcatori a macchina devono
/// dire le stesse cose che dicono le voci, e le voci aperte dell'ordine ES
/// che l'ordine EU tocca hanno nel loro manifesto la riga che le porta qui.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EU_MANIFESTO.md');
  const quante = 19;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e diciannove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce col lavoro');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EU.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EU: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
        'fare $daFare');
    final voci = testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1);
    var contateChiuse = 0, contateAperte = 0, contateDaFare = 0;
    final senzaStato = <String>[];
    final conPiuStati = <String>[];
    for (final v in voci) {
      final nome = v.split('\n').first;
      final chiusa = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final aperta = v.contains('**APERTA IN ATTESA DI VERIFICA**');
      final daFareQui = v.contains('**DA FARE.**');
      final stati = [chiusa, aperta, daFareQui].where((x) => x).length;
      if (stati == 0) senzaStato.add(nome);
      if (stati > 1) conPiuStati.add(nome);
      if (chiusa) {
        contateChiuse++;
      } else if (aperta) {
        contateAperte++;
      } else if (daFareQui) {
        contateDaFare++;
      }
    }
    expect(senzaStato, isEmpty, reason: 'voci senza stato: $senzaStato');
    expect(conPiuStati, isEmpty, reason: 'voci con piu\' stati: $conPiuStati');
    expect(dichiarate, quante);
    expect(contateChiuse, chiuse);
    expect(contateAperte, aperte);
    expect(contateDaFare, daFare);
    expect(chiuse + aperte + daFare, quante,
        reason: 'un conto che non torna nasconde una voce senza stato');
  });

  test('le voci aperte dell\'ordine ES toccate dicono dove proseguono', () {
    final es = File('docs/ordini/ORDINE_ES_MANIFESTO.md').readAsStringSync();
    const dove = {
      'ES.04': 'EU.12',
      'ES.06': 'EU.07',
      'ES.08': 'EU.02',
      'ES.09': 'EU.02',
      'ES.11': 'EU.06',
      'ES.12': 'EU.05',
      'ES.14': 'EU.10',
      'ES.35': 'EU.13',
    };
    final mancanti = <String>[];
    for (final e in dove.entries) {
      final inizio = es.indexOf('## VOCE ${e.key},');
      expect(inizio, greaterThan(-1), reason: '${e.key} non c\'e\'');
      final fine = es.indexOf('\n## ', inizio + 1);
      final voce = es.substring(inizio, fine < 0 ? es.length : fine);
      if (!voce.contains('prosegue nell\'ordine EU, voce ${e.value}')) {
        mancanti.add('${e.key} -> ${e.value}');
      }
    }
    expect(mancanti, isEmpty,
        reason: 'voci ES senza la riga che le porta nell\'ordine EU: '
            '$mancanti');
  });
}
