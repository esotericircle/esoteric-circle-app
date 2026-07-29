import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Genera l'anteprima ingrandita della mano, per guardarla davvero.
void main() {
  testWidgets('anteprima mano', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(700, 400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final k = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: k,
        child: Container(
          width: 700,
          height: 400,
          color: const Color(0xFF0B0714),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final f in [-1.0, 0.35, 0.7])
                SizedBox(
                  width: 180,
                  height: 360,
                  child: CustomPaint(
                    painter: TapHandPainter(phase: f, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(() async {
      final b = k.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 2.0);
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      File('docs/preview/mano-terza-stesura.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
