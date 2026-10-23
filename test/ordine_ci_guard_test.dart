import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CI.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le otto voci non hanno uno stato terminale.
///
/// **E pretende che le cinque premesse portino il loro esito**, perche' tre su
/// cinque sono cadute e in due casi il difetto vero era diverso e peggiore di
/// quello descritto: un manifesto che non lo scrivesse lascerebbe credere che
/// l'ordine avesse ragione.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CI_MANIFESTO.md');

  const quante = 8;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte e otto le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CI_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CI.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^- \*\*CI\.\d\d\*\*').hasMatch(r))
        .toList();
    expect(righe.length, quante,
        reason: 'le righe di voce sono ${righe.length} invece di $quante');

    final conti = <String, int>{for (final v in stati.values) v: 0};
    final senzaStato = <String>[];
    for (final r in righe) {
      final quale = stati.keys.firstWhere(
          (s) => r.contains('**$s.**') || r.contains('**$s**'),
          orElse: () => '');
      if (quale.isEmpty) {
        senzaStato.add(r.substring(0, r.length < 40 ? r.length : 40));
        continue;
      }
      conti[stati[quale]!] = conti[stati[quale]!]! + 1;
    }
    expect(senzaStato, isEmpty,
        reason: 'queste voci non dichiarano nessuno dei cinque stati '
            'ammessi: $senzaStato');

    expect(marcatore(testo, 'VOCI_TOTALI'), quante);
    for (final voce in conti.entries) {
      expect(marcatore(testo, voce.key), voce.value,
          reason: 'il marcatore ${voce.key} dice un numero diverso da quello '
              'che si conta sulle righe, cioe\' ${voce.value}');
    }
    final riassunto =
        conti.entries.map((e) => '${e.key} ${e.value}').join(', ');
    // ignore: avoid_print
    print('ORDINE CI: voci $quante, $riassunto');
  });

  test('le cinque premesse portano il loro esito', () {
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 5; i++) {
      if (!testo.contains('| P$i |')) mancanti.add('P$i');
    }
    expect(mancanti, isEmpty,
        reason: 'queste premesse non hanno una riga nella tavola: $mancanti');
    // **TRE SU CINQUE SONO CADUTE, e il manifesto lo deve dire.** Se un
    // giorno qualcuno riscrivesse questa tavola dichiarandole tutte vere,
    // resterebbe in giro l'idea che l'ordine avesse capito il difetto, e non
    // e' cosi': in due casi il difetto vero era un altro.
    expect('FALSA'.allMatches(testo).length, greaterThanOrEqualTo(3),
        reason: 'il manifesto non dichiara piu\' le premesse cadute');
  });

  test('le tre righe di chiusura ci sono, e portano i numeri', () {
    final testo = manifesto.readAsStringSync();
    for (final pezzo in [
      'Cosa NON e\' verificabile senza il deploy',
      'Quante coppie di colori pieni non passano',
      'Altre voci dichiarate chiuse che chiuse non erano',
    ]) {
      expect(testo.contains(pezzo), isTrue,
          reason: 'manca la riga di chiusura "$pezzo", che l\'ordine chiede '
              'per nome');
    }
    expect(testo.contains('Ventisei su ventotto'), isTrue,
        reason: 'il numero delle coppie di colori pieni che non passano non '
            'e\' piu\' dichiarato: una riga che dice "alcune" non serve a '
            'decidere niente');
    expect(testo.contains('CG.16'), isTrue,
        reason: 'il manifesto non nomina piu\' la voce che era dichiarata '
            'chiusa e non lo era');
  });

  test('l\'ordine CI non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE CI: voci ancora aperte $aperte');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e otto non hanno uno stato '
            'terminale');
  });
}
