// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/brand/brand.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/soffio_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE CARD DA MANDARE.** Ordine DW voci 03 e 06, 18 settembre 2026.
///
/// Il Soffio del Destino mandava un testo solo; due card stampavano un
/// dominio scritto a mano, *esotericircle.com*, diverso da quello del
/// marchio. Qui si pretende la card del Soffio e un dominio solo.
void main() {
  testWidgets(
      'DW.03: LA CARD DEL SOFFIO porta l\'orientamento del giorno e il '
      'dominio del marchio', (tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    const orientamento =
        'Oggi la Luna ti chiede di rallentare: scegli una cosa sola.';
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SoffioShareCard(
              orientamento: orientamento, palette: MaestroPalette.aura),
        ),
      ),
    ));
    await tester.pump();
    String testo(String chiave) =>
        tester.widget<Text>(find.byKey(Key(chiave))).data!;
    expect(testo('soffio_card_orientamento'), orientamento);
    expect(testo('soffio_card_dominio'), Brand.domain);
    expect(find.byType(Image), findsWidgets,
        reason: 'la card del Soffio non ha la sua immagine');
    final accompagna = testoDelSoffioCondiviso(orientamento);
    expect(accompagna, contains(Brand.url),
        reason: 'il testo che parte con la card non dice dove trovare l\'app');
    print('ORDINE DW voce 03: il testo che accompagna la card: $accompagna');
  });

  test('DW.06: NESSUNA CARD SCRIVE A MANO UN DOMINIO, lo legge dal marchio',
      () {
    // **Il fatto**: le card dell'Oroscopo e della Stesa stampavano
    // *esotericircle.com/...* e il testo dell'Archetipo un percorso
    // *esotericircle.app/aura/archetype_test* che nessuno gestisce, mentre il
    // marchio dice `Brand.domain`. Due domini sulle immagini che escono dal
    // telefono sono due indirizzi per la stessa app.
    //
    // **Resta fuori l'indirizzo di posta** della privacy, che e' un recapito
    // e non un link.
    final aMano = RegExp(r'''['"](https?://)?(www\.)?esotericircle\.(com|app)''');
    final fuori = <String>[];
    var guardati = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('core/brand/brand.dart')) continue;
      guardati++;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        if (aMano.hasMatch(r)) fuori.add('$percorso:${i + 1}');
      }
    }
    cardinaleMinimo(guardati, 500,
        cosa: 'file di lib',
        perche: 'Su una cartella vuota nessuna card scriverebbe un dominio.');
    print('ORDINE DW voce 06: file guardati $guardati, domini a mano '
        '${fuori.length} $fuori');
    expect(fuori, isEmpty,
        reason: 'questi punti scrivono un dominio a mano invece di leggerlo '
            'da Brand: $fuori');
  });
}
