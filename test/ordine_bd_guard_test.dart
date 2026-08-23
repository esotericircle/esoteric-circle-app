import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BD.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e
/// resta rossa finche' le otto voci non hanno uno stato terminale.
///
/// **Nessun censimento da sorvegliare qui dentro.** Le sette voci di
/// quest'ordine hanno ciascuna la propria prova, che misura la cosa sua: la
/// sovrapposizione delle tre carte, le trentotto cadute bonificate o
/// dichiarate, la mappa del mondo, lo schermo piccolo, i gradini che maturano
/// coi gesti, la data sulla card del traguardo, e le quarantotto ancore col
/// giro di andata e ritorno. Questa guardia sorveglia solo che nessuna resti
/// aperta.
void main() {
  final manifesto = File('docs/ordini/ORDINE_BD_MANIFESTO.md');

  /// Quante voci ha questo ordine. Non si rinumerano, non si accorpano e non
  /// si dichiarano coperte da un'altra.
  const quante = 8;

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
      .where((r) => RegExp(r'^- \*\*BD\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta tutte e otto le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BD_MANIFESTO.md non esiste, e la legge di '
            'consegna dice che nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BD.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato, e almeno uno dei cinque ammessi', () {
    final righe = righeDiVoce(manifesto.readAsStringSync());
    expect(righe, hasLength(quante),
        reason: 'le righe di voce sono ${righe.length} invece di $quante');
    for (final riga in righe) {
      final stati = [
        if (riga.contains('CHIUSA')) 'CHIUSA',
        if (riga.contains('FERMATA SU PREMESSA FALSA'))
          'FERMATA SU PREMESSA FALSA',
        if (riga.contains('FERMATA SU DECISIONE DEL FONDATORE'))
          'FERMATA SU DECISIONE DEL FONDATORE',
        if (riga.contains('FERMATA IN ATTESA DI DECISIONE'))
          'FERMATA IN ATTESA DI DECISIONE',
        if (riga.contains('APERTA')) 'APERTA',
      ];
      expect(stati, isNotEmpty,
          reason: 'questa riga non porta nessuno stato ammesso: $riga');
    }
    // ignore: avoid_print
    print('ORDINE BD: righe di voce osservate ${righe.length}');
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    // Si conta per lo stato PIU' DEBOLE, quello che tiene l'ordine aperto piu'
    // a lungo, come nelle guardie sorelle.
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
    expect(marcatore(testo, 'VOCI_APERTE'), aperte,
        reason: 'il marcatore delle aperte non coincide con le righe');
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'),
        fondatore);
    final contate = aperte + attesa + premessa + chiuse + fondatore;
    expect(contate, quante,
        reason: 'gli stati contati fanno $contate invece di $quante: una voce '
            'e\' sparita dal conto pur restando nel file');
  });

  test('l\'ordine BD non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine BD. Questa riga e\' '
            'rossa apposta e non si tocca: torna verde quando le otto voci '
            'hanno uno stato terminale, e non prima');
  });
}
