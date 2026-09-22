// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EF, il Soffio del Destino rifatto e guardato.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le cinque voci non hanno uno stato terminale.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EF_MANIFESTO.md');

  const quante = 5;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EF.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EF: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test('il manifesto porta i numeri misurati, non le promesse', () {
    final testo = manifesto.readAsStringSync();
    // **Ogni pretesa qui e' un numero che il fondatore ha visto a video o che
    // una guardia stampa.** Un manifesto che parla di "migliorato" senza
    // numeri e' la cosa che quest'ordine e' nato per non essere piu'.
    const pretese = <String, String>{
      'il margine fra figura e riquadro, prima e dopo': 'meno 47,0 punti',
      'lo spazio che resta alla bolla': '415',
      'la durata vera del volo dei semi sul telefono': '45 ms',
      'la durata vera del respiro sul telefono': '1,4 s',
    };
    final mancanti = <String>[];
    for (final p in pretese.entries) {
      if (!testo.contains(p.value)) mancanti.add('${p.key} (${p.value})');
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non porta questi numeri misurati: $mancanti');
  });
}
