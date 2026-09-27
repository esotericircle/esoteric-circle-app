// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE ER.** 27 settembre 2026.
///
/// Il manifesto nasce col lavoro e porta tutte e diciannove le voci, ognuna con
/// uno stato solo: CHIUSA, APERTA IN ATTESA DI VERIFICA, oppure DA FARE
/// finche' l'ordine e' in corso. I marcatori a macchina devono dire le stesse
/// cose che dicono le voci.
void main() {
  final manifesto = File('docs/ordini/ORDINE_ER_MANIFESTO.md');
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
      final voce = 'ER.${i.toString().padLeft(2, '0')}';
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
    print('ORDINE ER: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
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
}
