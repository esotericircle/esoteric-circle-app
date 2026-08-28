import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CA.
///
/// **Non e' una promessa, e' un test che non passa.** Legge il manifesto e resta
/// rossa finche' le sette voci non hanno uno stato terminale.
///
/// **E chiede due cose in piu' delle sorelle**, perche' quest'ordine le
/// pretende per nome: la forma delle tre scelte va DICHIARATA (l'ordine la
/// lascia a me e chiede di scriverla), e la fonte dell'attualita' dei
/// personaggi con la sua cadenza va dichiarata anche lei.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CA_MANIFESTO.md');

  const quante = 7;

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
      .where((r) => RegExp(r'^- \*\*CA\.\d\d\*\*').hasMatch(r))
      .toList();

  test('il manifesto esiste e nomina tutte e sette le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CA_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CA.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = righeDiVoce(testo);
    expect(righe, hasLength(quante));
    var aperte = 0, chiuse = 0;
    for (final r in righe) {
      if (r.contains('APERTA')) {
        aperte++;
      } else if (r.contains('CHIUSA')) {
        chiuse++;
      }
    }
    // ignore: avoid_print
    print('ORDINE CA: voci $quante, chiuse $chiuse, aperte $aperte');
    expect(marcatore(testo, 'VOCI_TOTALI'), righe.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + chiuse, quante);
  });

  test('la forma delle tre scelte e\' dichiarata, e si rovescia con una riga',
      () {
    final testo = manifesto.readAsStringSync();
    expect(testo.contains('TRE PORTE IN'), isTrue,
        reason: 'il manifesto non dichiara quale forma ho scelto per le tre '
            'scelte, e l\'ordine lo chiede per nome');
    expect(testo.contains('leTreScelteInFila'), isTrue,
        reason: 'il manifesto non dice quale riga rovescia la scelta');
    final porta =
        File('lib/features/synastry/porta_della_sinastria.dart').readAsStringSync();
    expect(porta.contains('static const bool leTreScelteInFila'), isTrue,
        reason: 'la riga che rovescia la forma non esiste nel codice');
  });

  test('la fonte dell\'attualita\' e la sua cadenza sono dichiarate', () {
    final testo = manifesto.readAsStringSync();
    for (final atteso in const [
      'LA FONTE SCELTA E OGNI QUANTO SI AGGIORNA',
      'trimestrale',
      'anagrafica',
      'catalogo/vip',
    ]) {
      expect(testo.contains(atteso), isTrue,
          reason: 'il manifesto non dichiara "$atteso": la voce CA.05 chiede '
              'la fonte scelta e ogni quanto si aggiorna');
    }
  });

  test('l\'ordine CA non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE nell\'ordine CA. Questa riga '
            'e\' rossa apposta e non si tocca');
  });
}
