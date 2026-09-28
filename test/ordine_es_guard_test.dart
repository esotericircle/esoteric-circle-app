// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE ES.** 28 settembre 2026.
///
/// Il manifesto nasce col lavoro e porta tutte e trentasette le voci dei
/// quattro pezzi dell'ordine, ognuna con uno stato solo: CHIUSA, APERTA IN
/// ATTESA DI VERIFICA, oppure DA FARE finche' l'ordine e' in corso. I
/// marcatori a macchina devono dire le stesse cose che dicono le voci, e le
/// nove voci aperte dell'ordine ET hanno nel loro manifesto la riga che le
/// porta qui.
void main() {
  final manifesto = File('docs/ordini/ORDINE_ES_MANIFESTO.md');
  const quante = 37;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e trentasette le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce col lavoro');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'ES.${i.toString().padLeft(2, '0')}';
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
    print('ORDINE ES: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
        'fare $daFare');
    final voci = testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1);
    var contateChiuse = 0, contateAperte = 0, contateDaFare = 0;
    final senzaStato = <String>[];
    final conPiuStati = <String>[];
    for (final v in voci) {
      final nome = v.split('\n').first;
      final stati = [
        RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v),
        v.contains('**APERTA IN ATTESA DI VERIFICA**'),
        v.contains('**DA FARE.**'),
      ].where((x) => x).length;
      if (stati == 0) senzaStato.add(nome);
      if (stati > 1) conPiuStati.add(nome);
      if (RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v)) {
        contateChiuse++;
      } else if (v.contains('**APERTA IN ATTESA DI VERIFICA**')) {
        contateAperte++;
      } else if (v.contains('**DA FARE.**')) {
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

  test('le nove voci aperte dell\'ordine ET dicono dove proseguono', () {
    final et = File('docs/ordini/ORDINE_ET_MANIFESTO.md').readAsStringSync();
    const dove = {
      'ET.01': 'ES.19',
      'ET.02': 'ES.20',
      'ET.03': 'ES.21',
      'ET.04': 'ES.22',
      'ET.06': 'ES.23',
      'ET.07': 'ES.24',
      'ET.08': 'ES.25',
      'ET.09': 'ES.26',
      'ET.10': 'ES.27',
    };
    final mancanti = <String>[];
    for (final e in dove.entries) {
      final inizio = et.indexOf('## VOCE ${e.key},');
      expect(inizio, greaterThan(-1), reason: '${e.key} non c\'e\'');
      final fine = et.indexOf('\n## ', inizio + 1);
      final voce = et.substring(inizio, fine < 0 ? et.length : fine);
      if (!voce.contains('prosegue nell\'ordine ES, voce ${e.value}')) {
        mancanti.add('${e.key} -> ${e.value}');
      }
    }
    expect(mancanti, isEmpty,
        reason: 'voci ET senza la riga che le porta nell\'ordine ES: '
            '$mancanti');
  });
}
