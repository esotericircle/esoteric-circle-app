// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELL'ORDINE FE, IL CRASH DEL REDMI, LE VOCI DEL LIVE, IL FILO
/// DEL CONSULTO E IL DIARIO COSMICO.** 6 ottobre 2026.
///
/// Il manifesto `ORDINE_FE_MANIFESTO.md` porta le quarantaquattro voci
/// dell'ordine (FE.01-FE.20, le cinque della FE.21 sul Test Lab, le diciotto
/// della FE.22 sul Diario Cosmico e la FE.23 del filo in cima), ognuna con uno
/// stato solo fra quelli canonici (CHIUSA, APERTA, oppure APERTA IN ATTESA DI
/// VERIFICA), e i marcatori dicono le stesse cose delle voci. Ogni voce porta la DOMANDA, la PROVA, la MISURA e
/// la frase di ACCETTAZIONE, e le prove che nomina esistono.
void main() {
  final manifesto = File('docs/ordini/ORDINE_FE_MANIFESTO.md');
  final voci = [
    for (var i = 1; i <= 20; i++) 'FE.${i.toString().padLeft(2, '0')}',
    for (var i = 1; i <= 5; i++) 'FE.21.$i',
    for (var i = 1; i <= 18; i++) 'FE.22.$i',
    'FE.23',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte le quarantaquattro voci', () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync();
    final mancanti = [
      for (final v in voci)
        if (!testo.contains('## VOCE $v,')) v,
    ];
    expect(voci, hasLength(44));
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    var contateChiuse = 0, contateAperte = 0;
    final storte = <String>[];
    for (final v
        in testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1)) {
      final nome = v.split('\n').first;
      final chiusa = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final aperta =
          RegExp(r'^\*\*APERTA( IN ATTESA DI VERIFICA)?\.\*\*', multiLine: true)
              .hasMatch(v);
      if (chiusa == aperta) storte.add('$nome: stati $chiusa/$aperta');
      if (chiusa) contateChiuse++;
      if (aperta) contateAperte++;
      for (final campo in ['DOMANDA:', 'PROVA:', 'MISURA:', 'ACCETTAZIONE:']) {
        if (!v.contains('\n$campo ')) storte.add('$nome: manca $campo');
      }
      final prova = RegExp(r'^PROVA: (.*)$', multiLine: true).firstMatch(v);
      for (final f in RegExp(r'((?:test|functions/src)/[\w/]+\.(?:dart|ts))')
          .allMatches(prova?.group(1) ?? '')) {
        if (!File(f.group(1)!).existsSync()) {
          storte.add('$nome: la prova ${f.group(1)} non esiste');
        }
      }
    }
    print('ORDINE FE: voci $dichiarate, chiuse $chiuse, aperte $aperte, da '
        'fare $daFare');
    expect(storte, isEmpty);
    expect(dichiarate, 44);
    expect(contateChiuse, chiuse);
    expect(contateAperte, aperte);
    expect(daFare, 0);
    expect(chiuse + aperte + daFare, dichiarate);
  });

  test('il rapporto dell\'ordine esiste e dice in testa le tre cose', () {
    final rapporto = File('docs/ordini/RAPPORTO_ORDINE_FE.md');
    expect(rapporto.existsSync(), isTrue);
    final t = rapporto.readAsStringSync();
    for (final parte in [
      'LE PREMESSE ABBATTUTE',
      'FIN DOVE SONO ARRIVATO',
      'LE DECISIONI CHE RESTANO AL FONDATORE',
    ]) {
      expect(t, contains(parte), reason: 'il rapporto non dice $parte');
    }
  });
}
