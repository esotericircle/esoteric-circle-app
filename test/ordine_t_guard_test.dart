import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE T.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le due voci non hanno tutte e due uno stato terminale.
///
/// Si committa comunque a ogni voce chiusa, con la guardia rossa o verde:
/// committare non e' consegnare. **Questo ordine pero' non consegna**, e la
/// deroga e' scritta in testa al manifesto: la build si fa alla fine della serie
/// di quattro ordini, perche' un ordine che consegna ogni volta produce quattro
/// archivi da installare per vedere un lavoro solo.
void main() {
  final manifesto = File('docs/ordini/ORDINE_T_MANIFESTO.md');

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
      .where((r) => RegExp(r'^- \*\*T\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta tutte e due le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_T_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 2; i++) {
      final voce = 'T.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato, e almeno uno dei quattro ammessi', () {
    final righe = righeDiVoce(manifesto.readAsStringSync());
    expect(righe, hasLength(2),
        reason: 'le righe di voce sono ${righe.length} invece di 2');
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    var osservate = 0;
    for (final riga in righe) {
      osservate++;
      final stati = [
        if (riga.contains('CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
        if (riga.contains('FERMATA IN ATTESA DI DECISIONE'))
          'FERMATA IN ATTESA DI DECISIONE',
        if (riga.contains('APERTA')) 'APERTA',
      ];
      expect(stati, isNotEmpty,
          reason: 'questa riga non porta nessuno stato ammesso: $riga');
    }
    // ignore: avoid_print
    print('ORDINE T: righe di voce osservate $osservate');
    expect(osservate, greaterThan(0),
        reason: 'la prova non ha guardato nessuna riga');
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    // Una riga puo' portare due stati quando una voce si chiude per una parte e
    // resta in attesa per un'altra: si conta per lo stato PIU' DEBOLE, cioe'
    // quello che tiene l'ordine aperto piu' a lungo.
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0;
    for (final r in righe) {
      if (r.contains('APERTA')) {
        aperte++;
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
  });

  test('l\'ordine T non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine T. Questa riga e\' '
            'rossa apposta e non si tocca: torna verde quando ogni voce ha uno '
            'stato terminale, e non prima');
  });
}
