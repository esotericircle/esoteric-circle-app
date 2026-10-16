// LA GUARDIA DELL'ORDINE FL, LO SFONDO DEL TAVOLO E LA STESA SUL PIANO.
// 12 ottobre 2026.
//
// Il manifesto docs/ordini/ORDINE_FL_MANIFESTO.md porta tutte e dieci le voci
// dell'ordine e le cinque richieste del fondatore in chat, FL.11-FL.15
// (quindici in tutto), ognuna con uno stato solo (CHIUSA, APERTA IN ATTESA DI
// VERIFICA o DA FARE), e i marcatori tornano coi conti. Le voci chiuse
// portano DOMANDA, PROVA e MISURA, e le prove nominate esistono.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifesto = File('docs/ordini/ORDINE_FL_MANIFESTO.md');
  final voci = [
    for (var i = 1; i <= 15; i++) 'FL.${i.toString().padLeft(2, '0')}',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte le quindici voci', () {
    expect(manifesto.existsSync(), isTrue);
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final mancanti = [
      for (final v in voci)
        if (!RegExp('^## VOCE ${RegExp.escape(v)}\\s*\$', multiLine: true)
            .hasMatch(testo))
          v,
    ];
    expect(voci, hasLength(15));
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('ogni voce ha uno stato solo, e i conti tornano', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final daFare = marcatore(testo, 'VOCI_DA_FARE');
    final totali = marcatore(testo, 'VOCI_TOTALI');
    var contateChiuse = 0, contateAperte = 0, contateDaFare = 0;
    final storte = <String>[];
    for (final v
        in testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1)) {
      final nome = v.split('\n').first;
      final c = RegExp(r'^\*\*CHIUSA\.\*\*', multiLine: true).hasMatch(v);
      final a =
          RegExp(r'^\*\*APERTA IN ATTESA DI VERIFICA\.\*\*', multiLine: true)
              .hasMatch(v);
      final d = RegExp(r'^\*\*DA FARE\.\*\*', multiLine: true).hasMatch(v);
      if ([c, a, d].where((x) => x).length != 1) {
        storte.add('$nome: stati $c/$a/$d');
      }
      if (c) {
        contateChiuse++;
        for (final campo in ['DOMANDA:', 'PROVA:', 'MISURA:']) {
          if (!v.contains('\n$campo ')) storte.add('$nome: manca $campo');
        }
        final prova =
            RegExp(r'^PROVA:\s*(\S+)', multiLine: true).firstMatch(v)?.group(1);
        if (prova != null && !File(prova).existsSync()) {
          storte.add('$nome: la prova $prova non esiste');
        }
      }
      if (a) contateAperte++;
      if (d) contateDaFare++;
    }
    expect(storte, isEmpty, reason: storte.join('\n'));
    expect([contateChiuse, contateAperte, contateDaFare],
        [chiuse, aperte, daFare]);
    expect(chiuse + aperte + daFare, totali);
    expect(totali, 15);
  });
}
