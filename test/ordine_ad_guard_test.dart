import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE AD.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le tre voci non hanno uno stato terminale.
///
/// **Nasce prima del codice, per legge di consegna.** Un manifesto scritto dopo
/// racconta cio' che si e' fatto; scritto prima dice cio' che si e' promesso, e
/// la differenza si vede solo quando una voce non si riesce a chiudere.
void main() {
  final manifesto = File('docs/ordini/ORDINE_AD_MANIFESTO.md');

  /// Quante voci ha questo ordine. Le voci non si rinumerano, non si accorpano
  /// e non si dichiarano coperte da un'altra.
  const quante = 5;

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
      .where((r) => RegExp(r'^- \*\*AD\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_AD_MANIFESTO.md non esiste, e la legge di '
            'consegna dice che nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'AD.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato, e almeno uno dei quattro ammessi', () {
    final righe = righeDiVoce(manifesto.readAsStringSync());
    expect(righe, hasLength(quante),
        reason: 'le righe di voce sono ${righe.length} invece di $quante');
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
    print('ORDINE AD: righe di voce osservate $osservate');
    expect(osservate, quante);
  });

  test('i marcatori dicono il vero, contati sulle righe', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    // Si conta per lo stato PIU' DEBOLE, quello che tiene l'ordine aperto piu'
    // a lungo, come nelle guardie sorelle.
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
    expect(aperte + attesa + premessa + chiuse, quante,
        reason:
            'gli stati contati fanno ${aperte + attesa + premessa + chiuse} '
            'invece di $quante: una voce e\' sparita dal conto pur restando '
            'nel file');
  });

  test('l\'ordine AD non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine AD. Questa riga e\' '
            'rossa apposta e non si tocca: torna verde quando le cinque voci hanno '
            'uno stato terminale, e non prima');
  });
}
