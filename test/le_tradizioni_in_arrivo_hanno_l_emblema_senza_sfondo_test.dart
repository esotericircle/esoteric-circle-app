// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/features/horoscope/la_testa_della_tradizione.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE TRADIZIONI IN ARRIVO HANNO L'EMBLEMA SENZA SFONDO.** EU Aggiunta 2,
/// 1 ottobre 2026, il fondatore: *"Diciamo a Code di usare solo gli emblemi
/// Senza sfondo per i segni temporanei delle tipologie di oroscopo non
/// sbloccate"* (voce EU.06).
///
/// Si misura, per ogni tradizione non sbloccata, con e senza un segno: la
/// figura in testa e' l'emblema senza sfondo della tradizione e si disegna
/// come le figure dei segni (non come un emblema quadrato); il file ha i
/// quattro angoli trasparenti, cioe' nessuno sfondo; ed e' uguale byte per
/// byte a quello consegnato (l'impronta SHA-256 dei webp del PC, letta il 1
/// ottobre 2026 in assets/Segni Zodiacali/Tradizioni).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const impronte = {
    AstroTradition.maya:
        '9f571425361c4ca1b2fa15d04503775d165bed90e2e02472895eca0439c07cfa',
    AstroTradition.egizia:
        'a34459d2b91006a75c32898212bf9da6745af2a06cfccbbbce0eacd5f7197733',
    AstroTradition.celtica:
        '2b6c63654368ceaea9c28a7793b3dcdcd3f295af6e603acae2baab7a02ea9319',
    AstroTradition.araba:
        'fe0de4147ca8a37ece92fb0621c102c0789a6fe907c2b11593257567a6633889',
  };

  test('le tradizioni in arrivo mostrano solo l\'emblema senza sfondo',
      () async {
    final inArrivo = [
      for (final t in AstroTradition.values)
        if (!t.unlocked) t,
    ];
    cardinaleMinimo(inArrivo.length, 4, cosa: 'tradizioni in arrivo');
    final colpe = <String>[];
    final righe = <String>[];
    var conSfondo = 0;
    for (final t in inArrivo) {
      final percorso = LaTestaDellaTradizione.figura(t, null)!;
      if (percorso != LaTestaDellaTradizione.emblemaSenzaSfondo(t)) {
        colpe.add('${t.name}: la figura e\' $percorso');
      }
      if (LaTestaDellaTradizione.eUnEmblema(t, null)) {
        colpe.add('${t.name}: si disegna come un emblema quadrato');
      }
      final byte = File(percorso).readAsBytesSync();
      final impronta = sha256.convert(byte).toString();
      if (impronta != impronte[t]) {
        colpe.add('${t.name}: il file non e\' quello consegnato ($impronta)');
      }
      final codec = await ui.instantiateImageCodec(byte);
      final img = (await codec.getNextFrame()).image;
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      int alfa(int x, int y) => dati.getUint8((y * img.width + x) * 4 + 3);
      final angoli = [
        alfa(0, 0),
        alfa(img.width - 1, 0),
        alfa(0, img.height - 1),
        alfa(img.width - 1, img.height - 1),
      ];
      final sfondo = angoli.any((a) => a > 0);
      if (sfondo) conSfondo++;
      righe.add('${t.name}: $percorso, ${img.width}x${img.height}, angoli '
          'alfa $angoli, SHA-256 uguale ${impronta == impronte[t]}');
    }
    print('LE TRADIZIONI IN ARRIVO: con un\'immagine con lo sfondo '
        '$conSfondo su ${inArrivo.length}\n${righe.join('\n')}');
    expect(conSfondo, 0, reason: righe.join('\n'));
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
