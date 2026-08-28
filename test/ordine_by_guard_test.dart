import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BY.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le cinque voci non hanno uno stato terminale. Lo stato di una
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
  final manifesto = File('docs/ordini/ORDINE_BY_MANIFESTO.md');

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
      .where((r) => RegExp(r'^- \*\*BY\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e nomina tutte e cinque le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BY_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BY.${(i + 1).toString().padLeft(2, '0')}';
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
    print('ORDINE BY: voci $quante, chiuse $chiuse, aperte $aperte');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'),
        fondatore);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse + fondatore, quante);
  });

  test('l\'ordine BY non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine BY. Questa riga '
            'e\' rossa apposta e non si tocca');
  });

  test('la consegna porta i numeri letti dal server, non a memoria', () {
    // **BY.02 chiede tre cose per nome**: il numero di build,
    // l'identificativo della consegna e l'ora, letti dalla consegna vera. Un
    // manifesto che li dichiarasse a memoria sarebbe la cosa che questo
    // progetto ha gia' pagato due volte, con la 2206 rimasta fuori dal
    // registro e con la 2161 consegnata senza accendersi.
    final testo = manifesto.readAsStringSync();
    final registro = File('docs/versione_distribuita.json').readAsStringSync();
    final numero =
        RegExp(r'"ultimo_distribuito":\s*(\d+)').firstMatch(registro)!.group(1)!;
    final release =
        RegExp(r'"release":\s*"([^"]+)"').firstMatch(registro)!.group(1)!;
    // ignore: avoid_print
    print('ORDINE BY: il registro dice build $numero, consegna $release');
    expect(testo.contains(numero), isTrue,
        reason: 'il manifesto non porta il numero di build $numero che il '
            'registro della consegna dichiara');
    expect(testo.contains(release), isTrue,
        reason: 'il manifesto non porta l\'identificativo $release della '
            'consegna vera');
    expect(RegExp(r'\d\d:\d\d:\d\d').hasMatch(testo), isTrue,
        reason: 'il manifesto non porta nessuna ora della consegna');
  });

  test('cio\' che resta dichiarato non e\' una sezione vuota', () {
    // **BY.05 chiede tre cose insieme**: le funzioni Coming soon, gli Eos
    // raggiungibili contro i 6.030, e la voce med_43. Una sezione che ne
    // dimentica una lascia il fondatore a decidere senza guardare.
    final testo = manifesto.readAsStringSync();
    for (final atteso in const ['Coming soon', '3.735', '6.030', 'med_43']) {
      expect(testo.contains(atteso), isTrue,
          reason: 'la sezione di cio\' che resta dichiarato non nomina '
              '"$atteso"');
    }
  });
}
