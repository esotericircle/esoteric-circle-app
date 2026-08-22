import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE AZ.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e
/// resta rossa finche' le sedici voci non hanno uno stato terminale.
///
/// **Sorveglia anche il censimento**, che in questo ordine non e' un contorno:
/// il fondatore ha chiesto di prevedere OGNI mossa, volontaria o involontaria,
/// e il numero delle situazioni censite e' la misura di quella promessa. Una
/// situazione tolta dalla tabella per far tornare i conti fa cadere la guardia.
void main() {
  final manifesto = File('docs/ordini/ORDINE_AZ_MANIFESTO.md');

  /// Quante voci ha questo ordine. Le voci non si rinumerano, non si accorpano
  /// e non si dichiarano coperte da un'altra.
  ///
  /// **Sono diventate SEDICI, e il numero e' cresciuto per un motivo che va
  /// detto**: il collaudo del fondatore sulla 2194 ha trovato due cose che il
  /// censimento delle prime quindici non copriva, cioe' la custodia proposta
  /// a chi e' gia' custodito e il bentornato che non puo' comparire dopo una
  /// reinstallazione. **Non sono state infilate dentro una voce esistente**:
  /// hanno la loro, la AZ.15, perche' un ordine che si allarga in silenzio
  /// non si puo' piu' leggere a distanza di un mese.
  const quante = 16;

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
      .where((r) => RegExp(r'^- \*\*AZ\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e porta tutte e sedici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_AZ_MANIFESTO.md non esiste, e la legge di '
            'consegna dice che nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'AZ.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato, e almeno uno dei cinque ammessi', () {
    final righe = righeDiVoce(manifesto.readAsStringSync());
    expect(righe, hasLength(quante),
        reason: 'le righe di voce sono ${righe.length} invece di $quante');
    var osservate = 0;
    for (final riga in righe) {
      osservate++;
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
    print('ORDINE AZ: righe di voce osservate $osservate');
    expect(osservate, quante);
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

  test('il censimento e\' intero, e il numero e\' contato sulle righe', () {
    // **IL CENSIMENTO E' LA PROMESSA DI QUESTO ORDINE.** "Prevedendo ogni
    // mossa volontaria o involontaria": il numero delle situazioni e' la
    // misura di quella frase, e non deve poter calare in silenzio.
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^\| S\d\d \|').hasMatch(r))
        .toList();
    // ignore: avoid_print
    print('ORDINE AZ: situazioni censite nelle tabelle ${righe.length}');
    expect(marcatore(testo, 'SITUAZIONI_CENSITE'), righe.length,
        reason: 'il marcatore del censimento dice '
            '${marcatore(testo, 'SITUAZIONI_CENSITE')} ma nelle tabelle le '
            'righe sono ${righe.length}');

    // **E NESSUN NUMERO SALTATO**: un buco fra S12 e S14 vorrebbe dire una
    // situazione tolta senza dirlo.
    final numeri = righe
        .map((r) => int.parse(RegExp(r'^\| S(\d\d) \|').firstMatch(r)!.group(1)!))
        .toList();
    for (var i = 0; i < numeri.length; i++) {
      final prima = i == 0 ? 'l\'inizio' : 'S${numeri[i - 1]}';
      expect(numeri[i], i + 1,
          reason: 'il censimento salta un numero: dopo $prima arriva '
              'S${numeri[i]}, e ne mancherebbe uno in mezzo');
    }
  });

  test('ogni situazione censita dice cosa fa l\'app oggi', () {
    // Una riga di censimento con la colonna di mezzo vuota sarebbe un
    // censimento che elenca senza guardare.
    final righe = manifesto
        .readAsStringSync()
        .split('\n')
        .where((r) => RegExp(r'^\| S\d\d \|').hasMatch(r));
    final mute = <String>[];
    for (final r in righe) {
      final colonne = r.split('|').map((c) => c.trim()).toList();
      // | S01 | situazione | cosa fa oggi | voce |
      if (colonne.length < 5 || colonne[3].isEmpty) mute.add(colonne[1]);
    }
    expect(mute, isEmpty,
        reason: 'queste situazioni sono censite ma non dicono cosa fa l\'app '
            'oggi: $mute');
  });

  test('l\'ordine AZ non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine AZ. Questa riga e\' '
            'rossa apposta e non si tocca: torna verde quando le sedici voci '
            'hanno uno stato terminale, e non prima');
  });
}
