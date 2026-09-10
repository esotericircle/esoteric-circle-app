import 'dart:io';
import 'dart:ui' as ui;
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_bosco_della_soglia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('anteprima del bosco', () async {
    final dove = Platform.environment['ANTEPRIME'] ?? '.';
    for (final r in [0.0, 0.5]) {
      const m = Size(360, 282);
      final rec = ui.PictureRecorder();
      PittoreDelBosco(quantoRespira: r).paint(Canvas(rec), m);
      final img = rec.endRecording().toImageSync(360, 282);
      final d = await img.toByteData(format: ui.ImageByteFormat.png);
      File('$dove/bosco_${(r * 10).toInt()}.png')
          .writeAsBytesSync(d!.buffer.asUint8List());
    }
  });
}
