// ignore_for_file: avoid_print
// LA GUARDIA DELL'ORDINE GB, l'Oroscopo si apre senza congelarsi, tutti i
// filmati si saltano, le stese ricalcolate e le cure del rapporto GA. 22
// ottobre 2026.
//
// Il manifesto docs/ordini/ORDINE_GB_MANIFESTO.md porta le tredici voci
// (GB.01-GB.13), ognuna con uno stato solo, e i marcatori tornano coi
// conti. A differenza dell'ordine GA questo manifesto conosce anche due
// stati che GA non aveva: PREMESSA CADUTA (GB.01, il fondatore ha detto
// che il difetto non c'e' piu') e DIVIETO (GB.10, "non si tocca",
// nessun lavoro per decisione del fondatore). Le voci CHIUSA e APERTA
// portano DOMANDA, PROVA e MISURA; le voci PREMESSA CADUTA e DIVIETO no,
// perche' non hanno misurato ne' costruito niente.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifesto = File('docs/ordini/ORDINE_GB_MANIFESTO.md');
  final voci = [
    for (var i = 1; i <= 13; i++) 'GB.${i.toString().padLeft(2, '0')}',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste, con tutte le voci', () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final mancanti = [
      for (final v in voci)
        if (!RegExp('^## VOCE ${RegExp.escape(v)}\\s*\$', multiLine: true)
            .hasMatch(testo))
          v,
    ];
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final premessaCaduta = marcatore(testo, 'VOCI_PREMESSA_CADUTA');
    final divieto = marcatore(testo, 'VOCI_DIVIETO');
    final totali = marcatore(testo, 'VOCI_TOTALI');
    var contateChiuse = 0,
        contateAperte = 0,
        contateDaFare = 0,
        contatePremessaCaduta = 0,
        contateDivieto = 0;
    final storte = <String>[];
    for (final v
        in testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1)) {
      final nome = v.split('\n').first;
      final c = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final a =
          RegExp(r'^\*\*APERTA IN ATTESA DI VERIFICA\.\*\*', multiLine: true)
              .hasMatch(v);
      final d = RegExp(r'^\*\*DA FARE\.\*\*', multiLine: true).hasMatch(v);
      final p = RegExp(r'^\*\*PREMESSA CADUTA\.\*\*', multiLine: true)
          .hasMatch(v);
      final i = RegExp(
              r'^\*\*DIVIETO DICHIARATO, NESSUN LAVORO SVOLTO\.\*\*',
              multiLine: true)
          .hasMatch(v);
      if ([c, a, d, p, i].where((x) => x).length != 1) {
        storte.add('$nome: stati $c/$a/$d/$p/$i');
      }
      if (c || a) {
        for (final campo in ['DOMANDA:', 'PROVA:', 'MISURA:']) {
          if (!v.contains('\n$campo ')) storte.add('$nome: manca $campo');
        }
      }
      if (c) contateChiuse++;
      if (a) contateAperte++;
      if (d) contateDaFare++;
      if (p) contatePremessaCaduta++;
      if (i) contateDivieto++;
    }
    print('ORDINE GB: chiuse $contateChiuse, aperte $contateAperte, '
        'da fare $contateDaFare, premessa caduta $contatePremessaCaduta, '
        'divieto $contateDivieto');
    expect(storte, isEmpty, reason: storte.join('\n'));
    expect(
        [contateChiuse, contateAperte, contateDaFare, contatePremessaCaduta,
          contateDivieto],
        [chiuse, aperte, daFare, premessaCaduta, divieto]);
    expect(chiuse + aperte + daFare + premessaCaduta + divieto, totali);
    expect(totali, voci.length);
  });
}
