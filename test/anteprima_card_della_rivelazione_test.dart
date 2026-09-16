// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/card_della_rivelazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ANTEPRIMA DELLA CARD DELLA RIVELAZIONE.** Ordine DQ voce 14.
///
/// La card si vede una volta sola nella vita, nell'istante in cui il nome si
/// sa: sul telefono di chi ha gia' riconosciuto il suo animale non si puo'
/// piu' guardare. Qui si dipinge dal componente vero, per chi la deve
/// approvare. Si scrive solo con `ANTEPRIMA_CARD=1`, perche' la suite non
/// deve toccare i file del repository.
void main() {
  testWidgets('la card della rivelazione, per la Volpe e per l\'Orso',
      (tester) async {
    if (Platform.environment['ANTEPRIMA_CARD'] != '1') {
      markTestSkipped('senza ANTEPRIMA_CARD non si scrive niente');
      return;
    }
    tester.view.physicalSize = const Size(760, 1200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    for (final nome in ['Volpe', 'Orso']) {
      final a = AnimalCatalog.animals.firstWhere((x) => x.name == nome);
      await tester.pumpWidget(MaterialApp(
        // **DENTRO UNO SCAFFOLD**, come nella schermata vera: senza un
        // Material sopra, Flutter segna il testo con le righe gialle del
        // debug, e l'anteprima direbbe una cosa che l'app non fa.
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0812),
          body: Center(
            child: RepaintBoundary(
              key: ValueKey(nome),
              child: CardDellaRivelazione(
                animale: a,
                quando: DateTime(2026, 9, 16),
              ),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 400));
      final png = await (await tester
              .renderObject<RenderRepaintBoundary>(find.byKey(ValueKey(nome)))
              .toImage(pixelRatio: 2))
          .toByteData(format: ui.ImageByteFormat.png);
      final dove = 'docs/collaudo/DQ/15_la_card_${nome.toLowerCase()}.png';
      File(dove).writeAsBytesSync(png!.buffer.asUint8List());
      print('ANTEPRIMA: $dove');
    }
  });
}
