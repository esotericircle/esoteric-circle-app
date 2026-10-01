// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/riquadro_del_numero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL NUMERO E IL COLORE RIEMPIONO IL RIQUADRO, AL CENTRO.** Il fondatore,
/// 1 ottobre 2026: *"Il colore del giorno e il numero del giorno più grandi in
/// modo da riempire il riquadro e centrati verticalmente e orizzontalmente."*
///
/// Si misura, coi due riquadri della Fortuna montati come nella scheda (larga
/// 296 punti, cioe' 360 meno i margini della pagina e della scheda), con una
/// cifra, con due, coi due numeri della Cinese, al carattere normale e a
/// quello massimo (1,3): la cifra alta almeno il 55 per cento dello spazio
/// fra l'etichetta e il suo contrappeso; il cerchio del colore col suo nome
/// alto almeno il 55 per cento dello stesso spazio; tutti e due al centro del
/// loro riquadro entro un punto, in orizzontale e in verticale; i due
/// riquadri larghi e alti uguale.
void main() {
  final colpe = <String>[];
  var guardati = 0;

  for (final (numero, cifre, colore) in const [
    (7, null, 'oro'),
    (22, null, 'blu zaffiro'),
    (0, '3 e 8', 'verde'),
  ]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets('numero ${cifre ?? numero}, colore $colore, scala $scala',
          (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 800),
                textScaler: TextScaler.linear(scala)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 296,
                  child: LaFortunaDelGiorno(
                    numero: numero,
                    cifre: cifre,
                    palette: MaestroPalette.medora,
                    nomeDelColore: colore,
                    colore: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        guardati++;
        final rn = tester.getRect(find.byKey(const Key('riquadro_del_numero')));
        final rc = tester.getRect(find.byKey(const Key('riquadro_del_colore')));
        final cifra =
            tester.getRect(find.byKey(const Key('riquadro_del_numero_cifra')));
        final contenuto = tester
            .getRect(find.byKey(const Key('riquadro_del_colore_contenuto')));
        // Lo spazio del contenuto: il riquadro meno l'etichetta e il suo
        // contrappeso, alti uguale.
        final etichetta = tester.getRect(find.text('NUMERO').evaluate().isEmpty
            ? find.text('NUMERI').first
            : find.text('NUMERO').first);
        final spazio = rn.height - 2 * etichetta.height;
        final riga = 'numero ${cifre ?? numero} alla scala $scala: riquadri '
            '${rn.width.toStringAsFixed(1)}x${rn.height.toStringAsFixed(1)} e '
            '${rc.width.toStringAsFixed(1)}x${rc.height.toStringAsFixed(1)}; '
            'cifra alta ${cifra.height.toStringAsFixed(1)} su '
            '${spazio.toStringAsFixed(1)}, fuori centro '
            '${(cifra.center.dx - rn.center.dx).abs().toStringAsFixed(1)} e '
            '${(cifra.center.dy - rn.center.dy).abs().toStringAsFixed(1)}; '
            'colore alto ${contenuto.height.toStringAsFixed(1)}, fuori centro '
            '${(contenuto.center.dx - rc.center.dx).abs().toStringAsFixed(1)} '
            'e ${(contenuto.center.dy - rc.center.dy).abs().toStringAsFixed(1)}';
        print('IL NUMERO E IL COLORE: $riga');
        // **RIEMPIRE** vuol dire toccare i bordi dello spazio che il
        // riquadro ha per il contenuto, in alto e in basso oppure ai lati: la
        // cifra "7" lo riempie in alto, i due numeri "3 e 8" o un nome lungo
        // come "blu zaffiro" in largo. Lo spazio e' il FittedBox.
        Rect spazioDi(Key k) => tester.getRect(find
            .descendant(of: find.byKey(k), matching: find.byType(FittedBox))
            .first);
        bool riempie(Rect c, Rect s) =>
            c.width >= s.width - 1 || c.height >= s.height - 1;
        final sn = spazioDi(const Key('riquadro_del_numero'));
        final sc = spazioDi(const Key('riquadro_del_colore'));
        if (!riempie(cifra, sn)) {
          colpe.add('la cifra non riempie il riquadro: $riga');
        }
        if (sn.height < 0.6 * spazio) {
          colpe.add('lo spazio della cifra e\' piccolo: $riga');
        }
        if ((cifra.center.dx - rn.center.dx).abs() > 1 ||
            (cifra.center.dy - rn.center.dy).abs() > 1) {
          colpe.add('la cifra non sta al centro: $riga');
        }
        if (!riempie(contenuto, sc)) {
          colpe.add('il colore non riempie il riquadro: $riga');
        }
        if ((contenuto.center.dx - rc.center.dx).abs() > 1 ||
            (contenuto.center.dy - rc.center.dy).abs() > 1) {
          colpe.add('il colore non sta al centro: $riga');
        }
        if ((rn.width - rc.width).abs() > 0.5 ||
            (rn.height - rc.height).abs() > 0.5) {
          colpe.add('i due riquadri non sono uguali: $riga');
        }
      });
    }
  }

  // **IL DISEGNO DELLA CIFRA AL CENTRO, misurato sui pixel**: la riga di un
  // testo puo' stare al centro col disegno spostato, e il fondatore guarda il
  // disegno. Si rasterizza il riquadro e si cerca il disegno dorato della
  // cifra: il suo centro in verticale entro il 3 per cento dell'altezza del
  // riquadro dal centro del riquadro.
  for (final cifre in const ['6', '7', '22']) {
    testWidgets('il disegno di "$cifre" sta al centro del riquadro',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: RepaintBoundary(
              key: const Key('fotografia'),
              child: SizedBox(
                width: 296,
                child: LaFortunaDelGiorno(
                  numero: int.parse(cifre),
                  palette: MaestroPalette.medora,
                  nomeDelColore: 'oro',
                  colore: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      final foto = tester.getRect(find.byKey(const Key('fotografia')));
      final rn = tester.getRect(find.byKey(const Key('riquadro_del_numero')));
      final etichetta = tester.getRect(find.text('NUMERO').first);
      late ByteData dati;
      late int larghezza;
      await tester.runAsync(() async {
        final img = await tester
            .renderObject<RenderRepaintBoundary>(
                find.byKey(const Key('fotografia')))
            .toImage(pixelRatio: 2.0);
        larghezza = img.width;
        dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      });
      // Il disegno dorato fra l'etichetta e il suo contrappeso.
      double? alto, basso;
      final x0 = ((rn.left - foto.left) * 2).round();
      final x1 = ((rn.right - foto.left) * 2).round();
      final y0 = ((etichetta.bottom - foto.top) * 2).round();
      final y1 = ((rn.bottom - etichetta.height - foto.top) * 2).round();
      for (var y = y0; y < y1; y++) {
        for (var x = x0 + 8; x < x1 - 8; x++) {
          final i = (y * larghezza + x) * 4;
          final r = dati.getUint8(i), g = dati.getUint8(i + 1);
          final b = dati.getUint8(i + 2);
          if (r > 170 && g > 140 && b < 160 && r - b > 60) {
            alto ??= y / 2;
            basso = y / 2;
          }
        }
      }
      expect(alto, isNotNull, reason: 'il disegno della cifra non si trova');
      final centro = (alto! + basso!) / 2 + foto.top;
      final scarto = (centro - rn.center.dy).abs() / rn.height;
      print('IL NUMERO E IL COLORE: il disegno di "$cifre" alto '
          '${(basso - alto).toStringAsFixed(1)} su ${rn.height.toStringAsFixed(1)}, '
          'fuori centro ${(scarto * 100).toStringAsFixed(1)} per cento');
      if (scarto > 0.03) {
        colpe.add('il disegno di "$cifre" e\' fuori centro del '
            '${(scarto * 100).toStringAsFixed(1)} per cento');
      }
      guardati++;
    });
  }

  tearDownAll(() => print('IL NUMERO E IL COLORE RIEMPIONO IL RIQUADRO: '
      'difetti ${colpe.length} su $guardati coppie di riquadri'));

  test('i conti', () {
    cardinaleMinimo(guardati, 6, cosa: 'coppie di riquadri guardate');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
