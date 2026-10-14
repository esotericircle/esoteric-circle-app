// L'ANTEPRIMA DELLA STESA IN ALTO, 14 ottobre 2026, dopo la 2310: la barra
// del titolo, la scena e il pannello "Scegli la tua stesa", a 360 per 800
// punti con rapporto di pixel 3 (il Realme del fondatore).
//
// flutter test tool/anteprima_della_stesa_in_alto.dart --dart-define=STATO=dopo
// Il "prima" si fa girando lo stesso file sul codice della 2310.
// Il filmato in prova non si decodifica: si vede la scena ferma, con la
// stessa geometria.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _stato = String.fromEnvironment('STATO', defaultValue: 'prova');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la Stesa in alto, $_stato', (tester) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.padding = const FakeViewPadding(top: 72);
    addTearDown(tester.view.reset);
    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, figlio) =>
            RepaintBoundary(key: radice, child: figlio),
        home: const MaestroScope(
          child: StesaTreCarteScreen(
            seed: 2,
            skipIntro: true,
            topic: TarotTopic.bivio,
          ),
        ),
      ),
    ));
    // Le immagini si decodificano fuori dal tempo finto della prova.
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/stesa_in_alto_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });
}
