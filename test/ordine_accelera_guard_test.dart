// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE ACCELERA.** 26 settembre 2026.
///
/// Il manifesto porta le quattro voci, ognuna con uno stato, e le parole del
/// fondatore. La prova degli stati resta rossa finche' l'ordine ha voci
/// aperte, come quelle degli ordini prima di lui: sta fra i rossi accettati.
void main() {
  final manifesto = File('docs/ordini/ORDINE_ACCELERA_MANIFESTO.md');
  const quante = 4;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e quattro le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce col lavoro');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'ACCELERA.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE ACCELERA: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    final voci = testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1);
    var contateChiuse = 0, contateAperte = 0;
    for (final v in voci) {
      if (RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v)) {
        contateChiuse++;
      } else if (v.contains('**APERTA IN ATTESA DI VERIFICA**')) {
        contateAperte++;
      }
    }
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(contateChiuse, chiuse,
        reason: 'le voci scritte CHIUSA sono $contateChiuse, il marcatore '
            'dice $chiuse');
    expect(contateAperte, aperte,
        reason:
            'le voci aperte sono $contateAperte, il marcatore dice $aperte');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test('le parole del fondatore stanno nel manifesto', () {
    final testo = manifesto.readAsStringSync();
    const pretese = <String>[
      'Ma non c\'è modo di accelerare Suite, sbarramenti',
      'usala sempre',
      'Ma ancora sbarramentii da 40 Min?',
      'Subito dopo questa build',
    ];
    final mancanti = [
      for (final p in pretese)
        if (!testo.contains(p)) p
    ];
    expect(pretese.length, 4);
    expect(mancanti, isEmpty, reason: 'il manifesto non porta: $mancanti');
  });
}
