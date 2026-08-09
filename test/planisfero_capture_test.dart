import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/planisfero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CATTURA DEL PLANISFERO, per l'anteprima prima e dopo.
///
/// Ordine 2169, voce 9. Il nome del file arriva dall'ambiente (`FASE`), cosi'
/// la stessa cattura si esegue due volte sullo stesso albero: una col disegno
/// vecchio rimesso al suo posto con una modifica mirata, una con quello nuovo.
/// **Il "prima" non e' una simulazione**: e' il codice vecchio che dipinge
/// davvero, com'e' scritto nelle regole della casa.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scatta il planisfero col luogo scelto', (tester) async {
    final fase = Platform.environment['FASE'] ?? 'dopo';

    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }

    tester.view.physicalSize = const Size(720, 380);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF05040A),
          body: Center(
            child: RepaintBoundary(
              key: Key('scatto'),
              child: SizedBox(
                width: 720,
                height: 380,
                // Torino, come nel Risveglio di chi sceglie la sua citta'.
                child: Planisfero(
                  palette: MaestroPalette.neutral,
                  luogo: (lat: 45.07, lon: 7.69),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('scatto'))) ;
      final img = await boundary.toImage(pixelRatio: 2.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('docs/preview/prima_dopo/planisfero_luogo_$fase.png');
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(dati!.buffer.asUint8List());
      // ignore: avoid_print
      print('SCATTO: ${f.path}, ${f.lengthSync()} byte');
    });
  });
}
