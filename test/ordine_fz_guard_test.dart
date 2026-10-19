// ignore_for_file: avoid_print
// LA GUARDIA DELL'ORDINE FZ, l'animale di potere che si rivela nel viaggio.
// 17-19 ottobre 2026.
//
// Il manifesto docs/ordini/ORDINE_FZ_MANIFESTO.md porta le quindici voci
// (FZ.01-FZ.15: le voci FZ.10-FZ.14 sono l'aggiunta FZA, eseguita dentro
// l'ordine e consegnata con la sua consegna, FZ.15), ognuna con uno stato
// solo, e i marcatori tornano coi conti. Le voci con la prova portano
// DOMANDA, PROVA e MISURA, e le prove nominate esistono; le voci aperte
// dicono che cosa aspettano. Il
// testo dell'ordine sta accanto, parola per parola, in
// docs/ordini/ORDINE_FZ_TESTO.md.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'le_voci_aperte_dicono_cosa_aspettano.dart';

void main() {
  final manifesto = File('docs/ordini/ORDINE_FZ_MANIFESTO.md');
  final voci = [
    for (var i = 1; i <= 15; i++) 'FZ.${i.toString().padLeft(2, '0')}',
  ];

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto e il testo dell\'ordine esistono, con tutte le voci', () {
    expect(manifesto.existsSync(), isTrue);
    expect(File('docs/ordini/ORDINE_FZ_TESTO.md').existsSync(), isTrue,
        reason: 'il testo dell\'ordine non vive solo nella chat');
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
      if (c || a) {
        for (final campo in ['DOMANDA:', 'PROVA:', 'MISURA:']) {
          if (!v.contains('\n$campo ')) storte.add('$nome: manca $campo');
        }
      }
      if (c) contateChiuse++;
      if (a) contateAperte++;
      if (d) contateDaFare++;
    }
    print('ORDINE FZ: chiuse $contateChiuse, aperte $contateAperte, '
        'da fare $contateDaFare');
    expect(storte, isEmpty, reason: storte.join('\n'));
    expect([contateChiuse, contateAperte, contateDaFare],
        [chiuse, aperte, daFare]);
    expect(chiuse + aperte + daFare, totali);
    expect(totali, voci.length);
  });

  test('le voci aperte dicono che cosa aspettano', () {
    leVociAperteDiconoCosaAspettano('FZ', voci.length);
  });
}
