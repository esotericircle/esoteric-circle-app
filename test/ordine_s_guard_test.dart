import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE S.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le ventinove voci non hanno tutte uno stato terminale. Finche'
/// questo test e' rosso la build non si fa e il rapporto non si scrive.
///
/// Si committa comunque a ogni voce chiusa, con la guardia rossa o verde:
/// committare non e' consegnare, ed e' la lezione piu' costosa dell'ordine P, dove
/// il lavoro di tre sessioni e' vissuto per giorni solo su un disco.
///
/// Le voci non si rinumerano e non si accorpano: la guardia conta le righe da S.01
/// a S.29 una per una, quindi un accorpamento la fa cadere invece di passarci in
/// mezzo. I quattro stati ammessi sono quelli dell'ordine P, compreso FERMATA IN
/// ATTESA DI DECISIONE, che serve alle voci dove il lavoro e' finito e resta solo
/// una scelta di Mauro.
void main() {
  final manifesto = File('docs/ordini/ORDINE_S_MANIFESTO.md');

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e ventinove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_S_MANIFESTO.md non esiste: e\' la '
            'primissima azione dell\'ordine, prima di qualunque codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 29; i++) {
      final voce = 'S.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti. Le voci non si '
            'accorpano e non si rinumerano');
  });

  test('ogni voce ha uno stato, e solo uno dei quattro ammessi', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^- \*\*S\.\d\d\*\*').hasMatch(r))
        .toList();
    expect(righe, hasLength(29),
        reason: 'le righe di voce sono ${righe.length} invece di 29');
    for (final riga in righe) {
      final stati = [
        if (riga.contains('— CHIUSA') || riga.contains('- CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
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
    final chiuse = RegExp(r'^- \*\*S\.\d\d\*\*.*(—|-) CHIUSA', multiLine: true)
        .allMatches(testo)
        .length;
    final fermate = RegExp(
            r'^- \*\*S\.\d\d\*\*.*FERMATA SU PREMESSA FALSA',
            multiLine: true)
        .allMatches(testo)
        .length;
    final inAttesa = RegExp(
            r'^- \*\*S\.\d\d\*\*.*FERMATA IN ATTESA DI DECISIONE',
            multiLine: true)
        .allMatches(testo)
        .length;
    expect(marcatore(testo, 'VOCI_TOTALI'), 29);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse,
        reason: 'il marcatore VOCI_CHIUSE non coincide con le righe chiuse '
            'davvero: un marcatore che mente e\' peggio di nessun marcatore');
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), fermate,
        reason: 'il marcatore delle voci fermate non coincide con le righe');
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), inAttesa,
        reason: 'il marcatore delle voci in attesa non coincide con le righe');
  });

  test('l\'ordine S non e\' consegnato finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final totali = marcatore(testo, 'VOCI_TOTALI');
    final terminali = marcatore(testo, 'VOCI_CHIUSE') +
        marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA') +
        marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE');
    expect(terminali, greaterThanOrEqualTo(totali),
        reason: 'restano ${totali - terminali} voci senza uno stato terminale. '
            'Finche\' questa riga e\' rossa la build non si fa e il rapporto non '
            'si scrive: non e\' una promessa, e\' un test che non passa');
  });
}
