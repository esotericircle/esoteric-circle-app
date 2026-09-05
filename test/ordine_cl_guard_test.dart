import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CL.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le otto voci non hanno uno stato terminale.
///
/// **E pretende che le quattro premesse portino il loro esito**, perche' tre su
/// cinque sono cadute e in due casi il difetto vero era diverso e peggiore di
/// quello descritto: un manifesto che non lo scrivesse lascerebbe credere che
/// l'ordine avesse ragione.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CL_MANIFESTO.md');

  const quante = 9;

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

  test('il manifesto esiste e nomina tutte e nove le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CL_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CL.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^- \*\*CL\.\d\d\*\*').hasMatch(r))
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
    print('ORDINE CL: voci $quante, $riassunto');
  });

  test('le quattro premesse portano il loro esito', () {
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 4; i++) {
      if (!testo.contains('| Q$i |')) mancanti.add('Q$i');
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

  test('il referto porta i numeri che l\'ordine chiede', () {
    final testo = manifesto.readAsStringSync();
    for (final pezzo in [
      'QUANTA PARTE DEL VERDE',
      'IL CENSIMENTO, VOCE CL.01',
      'QUANTE SCHERMATE CADONO AL TESTO MASSIMO',
    ]) {
      expect(testo.contains(pezzo), isTrue,
          reason: 'manca la sezione "$pezzo", che l\'ordine chiede per nome');
    }
    // **I NUMERI, e non le parole.** Un referto che dicesse "molte guardie"
    // non servirebbe a decidere niente.
    for (final numero in ['242', '201', '233', '42 su 182', '400']) {
      expect(testo.contains(numero), isTrue,
          reason: 'il referto non porta piu\' il numero $numero: senza '
              'quel numero la riga che lo conteneva diventa un\'impressione');
    }
  });

  test('l\'ordine CL non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE CL: voci ancora aperte $aperte');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e nove non hanno uno stato '
            'terminale');
  });
}
