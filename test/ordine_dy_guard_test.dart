// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DY, il tutorial che si puo' saltare o disattivare
/// e i tooltip che si leggono per intero.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le tre voci non hanno uno stato terminale. Le guardie
/// del difetto vivono nelle loro prove: `il_primo_approdo_test.dart` per DY.01
/// e DY.02, `il_testo_dei_fogli_non_passa_sotto_le_barre_test.dart` per DY.03
/// e il suo censimento.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DY_MANIFESTO.md');

  const quante = 3;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e tre le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DY.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DY\.\d\d\*\*').hasMatch(r)) {
        if (buffer.isNotEmpty) voci.add(buffer.toString());
        buffer.clear();
        buffer.writeln(r);
      } else if (buffer.isNotEmpty) {
        if (r.startsWith('  ')) {
          buffer.writeln(r);
        } else {
          voci.add(buffer.toString());
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) voci.add(buffer.toString());

    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, chiuse = 0;
    for (final v in voci) {
      if (v.contains('**APERTA**')) {
        aperte++;
      } else if (v.contains('**FERMATA IN ATTESA DI DECISIONE.**')) {
        attesa++;
      } else if (v.contains('**CHIUSA.**')) {
        chiuse++;
      }
    }
    print('ORDINE DY: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, in attesa $attesa');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(aperte + attesa + chiuse, quante,
        reason: 'una voce senza uno stato ammesso non si conta');
  });

  test('l\'ordine DY non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le tre voci hanno uno stato terminale');
  });
}
