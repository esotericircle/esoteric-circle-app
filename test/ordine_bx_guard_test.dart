import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BX.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le undici voci non hanno uno stato terminale. Lo stato di una
/// voce vive nella sua riga del manifesto, mai nella prosa di un rapporto: cosi'
/// chi vuole sapere a che punto e' l'ordine legge un file, non una chat.
///
/// **LO STATO STA SULLA RIGA DELLA VOCE**, e non deve esserci nessun'altra
/// parola di stato sulla stessa riga: la guardia legge la riga della voce e ci
/// cerca la prima parola che riconosce.
///
/// **E QUESTA GUARDIA CHIEDE UNA COSA IN PIU' DELLE SORELLE**, perche' la
/// REGOLA ZERO di quest'ordine lo pretende: il manifesto deve portare la
/// sezione delle affermazioni dell'ordine trovate false. Un ordine che dichiara
/// inaffidabile il proprio testo e poi non elenca cosa non reggeva non ha
/// eseguito la sua prima regola.
void main() {
  final manifesto = File('docs/ordini/ORDINE_BX_MANIFESTO.md');

  const quante = 11;

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
      .where((r) => RegExp(r'^- \*\*BX\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e nomina tutte e undici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BX_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BX.${(i + 1).toString().padLeft(2, '0')}';
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
    // ignore: avoid_print
    print('ORDINE BX: voci $quante, chiuse $chiuse, aperte $aperte');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(
        marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'), fondatore);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse + fondatore, quante);
  });

  test('l\'ordine BX non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine BX. Questa riga '
            'e\' rossa apposta e non si tocca');
  });

  test('la REGOLA ZERO ha la sua sezione, e non e\' vuota', () {
    // **La prima regola di quest'ordine e' che il suo testo non e' affidabile
    // e che le affermazioni false vanno elencate.** Una sezione che esiste e
    // non dice niente sarebbe peggio di nessuna sezione: qui si pretende che
    // ci sia e che porti almeno due voci di tabella.
    final testo = manifesto.readAsStringSync();
    expect(testo.contains('LE AFFERMAZIONI DELL\'ORDINE CHE HO TROVATO FALSE'),
        isTrue,
        reason: 'il manifesto non ha la sezione delle affermazioni false, che '
            'la REGOLA ZERO pretende');
    final dopo = testo
        .split('LE AFFERMAZIONI DELL\'ORDINE CHE HO TROVATO FALSE')
        .last
        .split('\n## ')
        .first;
    final righeDiTabella =
        dopo.split('\n').where((r) => r.startsWith('| BX.')).length;
    // ignore: avoid_print
    print('ORDINE BX: affermazioni verificate nella sezione della REGOLA '
        'ZERO: $righeDiTabella');
    expect(righeDiTabella, greaterThanOrEqualTo(2),
        reason: 'la sezione delle affermazioni false porta $righeDiTabella '
            'righe: un ordine che dichiara inaffidabile il proprio testo e '
            'poi non elenca cosa non reggeva non ha eseguito la sua prima '
            'regola');
  });

  test('la quadratura della voce BX.08 porta i tre numeri', () {
    // La voce BX.08 chiede tre cose per nome: quanti Eos sono raggiungibili,
    // quante voci restano dormienti, e l'elenco di chi produce la distanza.
    final testo = manifesto.readAsStringSync();
    for (final atteso in const ['3.735', '6.030', '51']) {
      expect(testo.contains(atteso), isTrue,
          reason: 'la quadratura non porta il numero $atteso');
    }
  });
}
