import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA LUNA NON HA LA CORNICE NERA.** Ordine FY voce FY.03, 16 ottobre
/// 2026. Il fondatore, sulla build 2312: "La luna presenta una cornice
/// contorno nero" (catture `docs/collaudo/FY/catture_fondatore/
/// fy_fondatore_04.jpg` e `fy_fondatore_05.jpg`).
///
/// Si posa una foto vera del Dial-A-Moon della NASA (il fotogramma 7000,
/// una falce con la parte in ombra nera e il cielo nero, pubblico dominio,
/// in `test/fixtures/fy03_luna_nasa_7000.jpg`) sul blu del cielo dipinto, e
/// si misura la luce in due anelli: subito fuori dal bordo del disco e piu'
/// lontano, nel cielo libero. Se intorno al disco resta un anello scuro, il
/// primo e' piu' buio del secondo.
void main() {
  const cielo = Color(0xFF1B2A55);
  const lato = 300.0;

  testWidgets('intorno al disco della Luna non resta un anello scuro',
      (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final byte = File('test/fixtures/fy03_luna_nasa_7000.jpg').readAsBytesSync();
    final immagine = MemoryImage(byte);
    final radice = GlobalKey();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: radice,
          child: Container(
            color: cielo,
            width: lato,
            height: lato,
            child: LaLunaSenzaFondoNero(immagine: immagine, lato: lato),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      await precacheImage(immagine, tester.element(find.byKey(radice)));
    });
    await tester.pump();

    final pixel = (await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final d = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      return d.buffer.asUint8List();
    }))!;
    double luce(int x, int y) {
      final i = (y * lato.toInt() + x) * 4;
      return 0.2126 * pixel[i] + 0.7152 * pixel[i + 1] + 0.0722 * pixel[i + 2];
    }

    // Il disco della Luna e' il 93 per cento del lato della foto, centrato.
    const raggio = lato * 0.93 / 2;
    double anello(double da, double a) {
      var somma = 0.0;
      var n = 0;
      for (var g = 0; g < 360; g += 2) {
        for (var r = raggio * da; r <= raggio * a; r += 1) {
          final x = (lato / 2 + r * math.cos(g * math.pi / 180)).round();
          final y = (lato / 2 + r * math.sin(g * math.pi / 180)).round();
          if (x < 0 || y < 0 || x >= lato || y >= lato) continue;
          somma += luce(x, y);
          n++;
        }
      }
      return somma / n;
    }

    // L'anello del bordo, dove la cornice nera si vedeva: dal 96 al 101 per
    // cento del raggio, la parte in ombra e il fondo della foto.
    final bordo = anello(0.96, 1.01);
    final fuori = cielo.computeLuminance() >= 0
        ? 0.2126 * cielo.r * 255 + 0.7152 * cielo.g * 255 + 0.0722 * cielo.b * 255
        : 0.0;
    // LA LUNA C'E' DAVVERO: la parte illuminata, dentro il disco, e' ben piu'
    // chiara del cielo. Senza, un'immagine che non si disegna farebbe il
    // bordo uguale al cielo e la prova verde senza aver guardato niente.
    var piuChiara = 0.0;
    for (var y = 0; y < lato.toInt(); y += 2) {
      for (var x = 0; x < lato.toInt(); x += 2) {
        piuChiara = math.max(piuChiara, luce(x, y));
      }
    }
    // ignore: avoid_print
    print('FY.03: luce del bordo $bordo, luce del cielo $fuori, '
        'la piu\' chiara della Luna $piuChiara');
    expect(piuChiara, greaterThan(fuori + 80),
        reason: 'la Luna non si e\' disegnata: la misura del bordo non vale');
    expect(bordo, greaterThan(fuori - 6),
        reason: 'intorno al disco resta un anello piu\' scuro del cielo: '
            'luce del bordo ${bordo.toStringAsFixed(1)}, del cielo '
            '${fuori.toStringAsFixed(1)}');
  });
}
