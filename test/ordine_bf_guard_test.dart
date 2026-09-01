import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BF.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e
/// resta rossa finche' le sette voci e i tredici lavori di BF.05 non hanno
/// uno stato terminale. E' l'ultimo ordine di bonifica prima della revisione
/// delle funzionalita', e porta il mandato esteso: le decisioni del
/// fondatore le prende Code e le dichiara nel manifesto.
void main() {
  final manifesto = File('docs/ordini/ORDINE_BF_MANIFESTO.md');

  /// Quante voci ha questo ordine, e quanti lavori porta la voce BF.05.
  /// Non si rinumerano, non si accorpano e non si dichiarano coperte da
  /// un'altra.
  const quante = 7;
  const quantiLavori = 13;

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
      .where((r) => RegExp(r'^- \*\*BF\.\d\d\*\*').hasMatch(r))
      .toList();

  List<String> righeDiLavoro(String testo) => testo
      .split('\n')
      .where((r) => RegExp(r'^- \*\*BF\.05\.[a-z]\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta le sette voci e i tredici lavori', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BF_MANIFESTO.md non esiste, e la legge di '
            'consegna dice che nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BF.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    for (var i = 0; i < quantiLavori; i++) {
      final lavoro = 'BF.05.${String.fromCharCode(97 + i)}';
      if (!testo.contains('**$lavoro**')) mancanti.add(lavoro);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce e ogni lavoro hanno uno stato ammesso', () {
    final testo = manifesto.readAsStringSync();
    final righe = [...righeDiVoce(testo), ...righeDiLavoro(testo)];
    expect(righe, hasLength(quante + quantiLavori),
        reason: 'le righe di voce sono ${righe.length} invece di '
            '${quante + quantiLavori}');
    for (final riga in righe) {
      final stati = [
        if (riga.contains('CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
        if (riga.contains('FERMATA SU DECISIONE DEL FONDATORE'))
          'FERMATA SU DECISIONE DEL FONDATORE',
        if (riga.contains('FERMATA IN ATTESA DI DECISIONE'))
          'FERMATA IN ATTESA DI DECISIONE',
        // RIMANDATA ALLA REVISIONE e' ammessa SOLO per i lavori di BF.05:
        // l'ordine la nomina per loro ("eseguilo, oppure dichiaralo
        // rimandato alla revisione delle funzionalita'").
        if (riga.contains('RIMANDATA ALLA REVISIONE') &&
            RegExp(r'^- \*\*BF\.05\.[a-z]\*\*').hasMatch(riga))
          'RIMANDATA ALLA REVISIONE',
        if (riga.contains('APERTA')) 'APERTA',
      ];
      expect(stati, isNotEmpty,
          reason: 'questa riga non porta nessuno stato ammesso: $riga');
    }
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final voci = righeDiVoce(testo);
    final lavori = righeDiLavoro(testo);
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'LAVORI_BF05_TOTALI'), lavori.length);
    // Si conta per lo stato PIU' DEBOLE, quello che tiene l'ordine aperto
    // piu' a lungo, come nelle guardie sorelle.
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0, fondatore = 0;
    for (final r in voci) {
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
    expect(marcatore(testo, 'VOCI_APERTE'), aperte,
        reason: 'il marcatore delle aperte non coincide con le righe');
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(
        marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'), fondatore);
    expect(aperte + attesa + premessa + chiuse + fondatore, quante,
        reason: 'gli stati contati non coprono le sette voci: una voce e\' '
            'sparita dal conto pur restando nel file');
    final lavoriAperti = lavori.where((r) => r.contains('APERTA')).length;
    expect(marcatore(testo, 'LAVORI_BF05_APERTI'), lavoriAperti,
        reason: 'il marcatore dei lavori aperti non coincide con le righe');
  });

  test('l\'ordine BF non e\' finito finche\' qualcosa resta aperto', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final lavoriAperti = marcatore(testo, 'LAVORI_BF05_APERTI');
    expect(aperte + lavoriAperti, 0,
        reason: 'restano $aperte voci e $lavoriAperti lavori APERTI '
            'nell\'ordine BF. Questa riga e\' rossa apposta e non si tocca: '
            'torna verde quando tutto ha uno stato terminale, e non prima');
  });
}
