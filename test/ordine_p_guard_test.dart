import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE P.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e
/// resta rossa finche' le quaranta voci non hanno tutte uno stato terminale.
/// Finche' questo test e' rosso l'ordine non e' consegnato, la build non si fa
/// e il rapporto non si scrive.
///
/// Le voci non si rinumerano e non si accorpano: la guardia conta le righe da
/// P.01 a P.40 una per una, quindi un accorpamento la fa cadere invece di
/// passarci in mezzo. La Sezione Zero ha portato il totale da 32 a 40.
void main() {
  final manifesto = File('docs/ordini/ORDINE_P_MANIFESTO.md');

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e quaranta le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_P_MANIFESTO.md non esiste: e\' la '
            'primissima azione dell\'ordine, prima di qualunque codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 40; i++) {
      final voce = 'P.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti. Le voci non '
            'si accorpano e non si rinumerano');
  });

  test('ogni voce ha uno stato, e solo uno dei quattro ammessi', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^- \*\*P\.\d\d\*\*').hasMatch(r))
        .toList();
    expect(righe, hasLength(40),
        reason: 'le righe di voce sono ${righe.length} invece di 40');
    for (final riga in righe) {
      final stati = [
        if (riga.contains('— CHIUSA') || riga.contains('- CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
        // IL QUARTO STATO, dalla quarta sessione. Non e' un modo elegante di
        // dire aperta: il lavoro e' finito e cio' che resta e' una scelta di
        // Mauro, quindi non c'e' niente da fare e dire "aperta" sarebbe falso.
        if (riga.contains('FERMATA IN ATTESA DI DECISIONE'))
          'FERMATA IN ATTESA DI DECISIONE',
        if (riga.trimRight().endsWith('APERTA')) 'APERTA',
      ];
      expect(stati, hasLength(1),
          reason: 'questa riga non ha esattamente uno stato: $riga');
    }
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = RegExp(r'^- \*\*P\.\d\d\*\*.*(—|-) CHIUSA', multiLine: true)
        .allMatches(testo)
        .length;
    final fermate = RegExp(r'^- \*\*P\.\d\d\*\*.*FERMATA SU PREMESSA FALSA',
            multiLine: true)
        .allMatches(testo)
        .length;
    final inAttesa = RegExp(
            r'^- \*\*P\.\d\d\*\*.*FERMATA IN ATTESA DI DECISIONE',
            multiLine: true)
        .allMatches(testo)
        .length;
    expect(marcatore(testo, 'VOCI_TOTALI'), 40);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse,
        reason: 'il marcatore VOCI_CHIUSE non coincide con le righe chiuse '
            'davvero: un marcatore che mente e\' peggio di nessun marcatore');
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), fermate,
        reason: 'il marcatore delle voci fermate non coincide con le righe');
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), inAttesa,
        reason: 'il marcatore delle voci in attesa di decisione non coincide '
            'con le righe');
  });

  test('l\'ordine P non e\' consegnato finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final totali = marcatore(testo, 'VOCI_TOTALI');
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final fermate = marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA') +
        marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE');
    expect(chiuse + fermate, greaterThanOrEqualTo(totali),
        reason: 'restano ${totali - chiuse - fermate} voci senza uno stato '
            'terminale. Finche\' questa riga e\' rossa la build non si fa e il '
            'rapporto non si scrive: non e\' una promessa, e\' un test che non '
            'passa');
  });
}
