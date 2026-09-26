// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EH, il Soffio del Destino rifatto e guardato.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le cinque voci non hanno uno stato terminale.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EH_MANIFESTO.md');

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
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EH.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EH: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test('ogni voce chiusa porta la domanda del fondatore alla lettera', () {
    // **La regola nuova dell'ordine EH voce 02**, e questo manifesto e' il
    // primo a doverle obbedire: le tre righe le pretende
    // `ogni_voce_chiusa_porta_la_sua_prova`. Qui si guarda la cosa che quella
    // guardia non puo' guardare: che la DOMANDA riporti **parole vere del
    // fondatore**, non una parafrasi comoda scritta dopo.
    final testo = manifesto.readAsStringSync();
    const paroleSue = [
      'mi sembra il testo uguale a ieri',
      'IO VOLGIO LA GARANZIA CHE SIA LA VERITA',
      'Passo meta\' del mio tempo a verificare',
    ];
    final mancanti = [
      for (final p in paroleSue)
        if (!testo.contains(p)) p
    ];
    expect(mancanti, isEmpty,
        reason: 'il manifesto non riporta queste parole del fondatore: '
            '$mancanti');
  });
}
