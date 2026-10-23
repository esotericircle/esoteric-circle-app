// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DZ, la chat di approfondimento e' pulita e le
/// conversazioni hanno un titolo.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le quattro voci non hanno uno stato terminale. Le
/// guardie del difetto vivono nelle loro prove: `chat_initial_message_test`
/// per DZ.01, DZ.03 e DZ.04, `il_journal_vede_i_turni_appena_arrivano_test`
/// per DZ.02, `le_conversazioni_hanno_un_titolo_test` per le regole del
/// titolo e dell'elenco.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DZ_MANIFESTO.md');

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
      final voce = 'DZ.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DZ\.\d\d\*\*').hasMatch(r)) {
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
    print('ORDINE DZ: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, in attesa $attesa');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(aperte + attesa + chiuse, quante,
        reason: 'una voce senza uno stato ammesso non si conta');
  });

  test('l\'ordine DZ non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le quattro voci hanno uno stato terminale');
  });
}
