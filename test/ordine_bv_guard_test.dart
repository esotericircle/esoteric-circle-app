import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BV.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le sei voci non hanno uno stato terminale. Lo stato di una voce
/// vive nella sua riga del manifesto, mai nella prosa di un rapporto: cosi' chi
/// vuole sapere a che punto e' l'ordine legge un file, non una chat.
///
/// **LO STATO STA SULLA RIGA DELLA VOCE, non due righe piu' sotto**, e non deve
/// esserci nessun'altra parola di stato sulla stessa riga: la guardia legge la
/// riga della voce e ci cerca la prima parola che riconosce. Una voce chiusa
/// che raccontasse sulla stessa riga di essersi fermata verrebbe contata fra le
/// fermate, ed e' successo davvero mentre si chiudeva l'ordine BQ: la storia si
/// conserva in un capitolo a parte, citata, non sulla riga della voce.
void main() {
  final manifesto = File('docs/ordini/ORDINE_BV_MANIFESTO.md');

  const quante = 6;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  List<String> righeDiVoce(String testo) => testo
      .split('\n')
      .where((r) => RegExp(r'^- \*\*BV\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BV_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BV.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante));
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0, fondatore = 0;
    for (final r in righe) {
      if (r.contains('APERTA')) {
        aperte++;
      } else if (r.contains('FERMATA SU DECISIONE DEL FONDATORE')) {
        fondatore++;
      } else if (r.contains('FERMATA IN ATTESA DI DECISIONE')) {
        attesa++;
      } else if (r.contains('FERMATA SU PREMESSA FALSA')) {
        premessa++;
      } else if (r.contains('CHIUSA')) {
        chiuse++;
      }
    }
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'),
        fondatore);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse + fondatore, quante);
  });

  test('l\'ordine BV non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine BV. Questa riga '
            'e\' rossa apposta e non si tocca');
  });
}
