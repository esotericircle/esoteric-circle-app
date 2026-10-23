import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE BZ.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le nove voci non hanno uno stato terminale. Lo stato di una
/// voce vive nella sua riga del manifesto, mai nella prosa di un rapporto: cosi'
/// chi vuole sapere a che punto e' l'ordine legge un file, non una chat.
///
/// **UNO STATO NUOVO, e nasce da un fatto.** Le sorelle conoscono APERTA,
/// CHIUSA e le tre forme del fermarsi. Qui ne serviva una sesta: la voce BZ.02
/// e' finita da parte mia, l'archivio si produce, ma **lanciare la build chiede
/// credenziali che non passano da questa chat**. "CHIUSA" direbbe che i
/// fondatori hanno la build sul telefono, e non ce l'hanno; "APERTA" direbbe
/// che c'e' ancora lavoro da fare qui, e non ce n'e'. FERMATA IN ATTESA DELLE
/// MANI DEL FONDATORE dice cio' che e' vero, e il manifesto porta i passi
/// numerati.
void main() {
  final manifesto = File('docs/ordini/ORDINE_BZ_MANIFESTO.md');

  const quante = 9;

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
      .where((r) => RegExp(r'^- \*\*BZ\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e nomina tutte e nove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_BZ_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'BZ.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante));
    var aperte = 0, attesa = 0, mani = 0, premessa = 0, chiuse = 0;
    var fondatore = 0;
    for (final r in righe) {
      if (r.contains('APERTA')) {
        aperte++;
      } else if (r.contains('FERMATA IN ATTESA DELLE MANI DEL FONDATORE')) {
        mani++;
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
    print('ORDINE BZ: voci $quante, chiuse $chiuse, aperte $aperte, in attesa '
        'delle mani del fondatore $mani');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DELLE_MANI_DEL_FONDATORE'),
        mani);
    expect(marcatore(testo, 'VOCI_FERMATE_SU_PREMESSA_FALSA'), premessa);
    expect(
        marcatore(testo, 'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE'), fondatore);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + mani + premessa + chiuse + fondatore, quante);
  });

  test('la voce della build dichiara cosa e\' cambiato dalla 2167', () {
    // **L'INTEGRAZIONE DELL'ORDINE LO CHIEDE PER NOME**: se lo sbarramento
    // esisteva gia' alla 2167, se il fuso della macchina e' cambiato, e da
    // quale momento un rosso dichiarato ha cominciato a impedire l'archivio.
    // Serve al fondatore per sapere se puo' succedere ancora, quindi non e'
    // prosa: e' un dato che il manifesto deve portare.
    final testo = manifesto.readAsStringSync();
    for (final atteso in const [
      '2167',
      '8 agosto 2026',
      '07e31ab6',
      'ignore_failure',
      '12 agosto',
      '13 agosto',
    ]) {
      expect(testo.contains(atteso), isTrue,
          reason: 'il manifesto non dichiara "$atteso": la voce BZ.02 chiede '
              'il confronto con la build che era gia\' riuscita');
    }
  });

  test('i passi per lanciare la build ci sono, e sono numerati', () {
    // Se per consegnare servono le mani del fondatore, l'ordine chiede i passi
    // pronti da eseguire. Un manifesto che dicesse "va lanciata su Codemagic"
    // lascerebbe il fondatore a indovinare dove si preme.
    final testo = manifesto.readAsStringSync();
    expect(testo.contains('Start new build'), isTrue,
        reason: 'i passi non dicono che bottone si preme');
    expect(testo.contains('claude/esoteric-circle-master-order-e798aj'), isTrue,
        reason: 'i passi non dicono da quale ramo si costruisce');
    for (final numero in const ['1.', '2.', '3.', '4.', '5.']) {
      expect(testo.contains(numero), isTrue,
          reason: 'i passi non sono numerati fino a $numero');
    }
  });

  test('l\'ordine BZ non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine BZ. Questa riga '
            'e\' rossa apposta e non si tocca');
  });
}
