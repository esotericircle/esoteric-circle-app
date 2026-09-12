import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/components/icona_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il prima e il dopo dell'icona del Cerchio, ingranditi per essere guardabili:
/// a 21 punti reali la differenza fra una falce sola e una falce dentro un
/// anello non si giudica su uno schermo, si giudica ingrandendola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> scatta(WidgetTester tester, Widget figlio, String nome) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: chiave,
        child: Container(
          color: const Color(0xFF0B0A14),
          padding: const EdgeInsets.all(24),
          child: Center(child: figlio),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // runAsync: fuori da qui la codifica in PNG non completa mai, perche' il
    // tempo della prova e' finto e la codifica e' vera.
    await tester.runAsync(() async {
      final b =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 6);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('docs/preview/prima_dopo/$nome.png');
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(dati!.buffer.asUint8List());
    });
  }

  testWidgets('Prima: la mezzaluna sola', (tester) async {
    await scatta(
      tester,
      const Icon(Icons.brightness_3, color: Color(0xFFD9B65C), size: 84),
      'icona_cerchio_prima',
    );
  });

  testWidgets('Dopo: la mezzaluna dentro il cerchio', (tester) async {
    await scatta(
      tester,
      const IconaDelCerchio(colore: Color(0xFFD9B65C), dimensione: 84),
      'icona_cerchio_dopo',
    );
  });

  testWidgets('Dopo, accanto alle altre e alla misura vera', (tester) async {
    await scatta(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconaDelCerchio(colore: Color(0xFFD9B65C), dimensione: 21),
          SizedBox(width: 14),
          Icon(Icons.auto_awesome, color: Color(0xFF8C8AA6), size: 21),
          SizedBox(width: 14),
          Icon(Icons.badge_outlined, color: Color(0xFF8C8AA6), size: 21),
        ],
      ),
      'icona_cerchio_accanto',
    );
  });
}
