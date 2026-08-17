import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart' as z;
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CIELO DI NASCITA SI MUOVE. Ordine AL voce 02.
///
/// **La misura ha trovato la causa dove la P2 la sospettava**: la fisica dei
/// due cieli e' identica e in banco la nascita correva 143 punti a tilt
/// saturo; era la guardia di Riduci Movimento MESSA MALE ad azzerare il
/// tilt, e disableAnimations sul telefono si accende anche da solo
/// (risparmio batteria, scala animazioni). Il cosmo della home non azzera i
/// suoi offset, ed ecco il "stanotte va bene, nascita ferma" di Mauro.
///
/// La grandezza: ANCHE con Riduci Movimento acceso, inclinare sposta la
/// volta (l'inclinazione e' un gesto deliberato come il dito); la deriva e
/// le animazioni restano tolte, e il cielo di stanotte non e' stato toccato.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('con Riduci Movimento acceso, inclinare muove la volta di '
      'nascita', (tester) async {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final parallasse = ParallaxController();
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<ParallaxController>.value(value: parallasse),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => z.ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          // RIDUCI MOVIMENTO ACCESO: e' il caso del telefono di Mauro.
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RepaintBoundary(
            key: chiave,
            child:
                SkyOverviewScreen(now: DateTime(1990, 6, 15, 14, 30), birth: true)),
      ),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    Future<List<int>> riga() async {
      final scatola =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await tester.runAsync(() => scatola.toImage(pixelRatio: 1.0));
      final dati = (await tester
          .runAsync(() => img!.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      final w = img!.width;
      final y = (img.height * 0.4).toInt();
      return [
        for (var x = 0; x < w; x++)
          (dati.getUint8((y * w + x) * 4) * 299 +
                  dati.getUint8((y * w + x) * 4 + 1) * 587 +
                  dati.getUint8((y * w + x) * 4 + 2) * 114) ~/
              1000
      ];
    }

    // **LA GRANDEZZA E' LA CAMERA DELLA VOLTA, letta dal suo painter.**
    // Tre misure bugiarde sono cadute prima di questa, e si dichiarano:
    // contare i pixel diversi non distingue (il brulichio da solo ne cambia
    // 215 su 360, volta ferma o no); la correlazione a finestra variabile
    // premia gli spostamenti grandi, dove il confronto si accorcia e il
    // bordo scuro combacia col bordo scuro (194 "misurati" su una volta
    // ghiacciata); la correlazione a finestra fissa misura il COSMO dietro
    // la volta, i cui piani rispondono sempre all'inclinazione per disegno
    // di AJ.01 (54 pixel di corsa con la volta di ghiaccio). L'unica cosa
    // che l'azzeramento congela e' la camera del campo stellare, ed e' lei
    // che si legge, prima e dopo l'inclinazione. La striscia di pixel resta
    // nella prova come sentinella che la camera finisce davvero sulla tela.
    double cameraDellaVolta() {
      for (final w in tester.widgetList<CustomPaint>(find.byType(CustomPaint))) {
        final p = w.painter;
        if (p != null && p.runtimeType.toString().contains('SkyFieldPainter')) {
          return ((p as dynamic).cam as Offset).dx;
        }
      }
      fail('il painter della volta non sta nell\'albero');
    }

    parallasse.inclinaPerLaProva(0, 0);
    await tester.pump(const Duration(milliseconds: 200));
    final prima = await riga();
    final camPrima = cameraDellaVolta();
    parallasse.inclinaPerLaProva(0.4, 0);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final dopo = await riga();
    final camDopo = cameraDellaVolta();
    final corsa = (camDopo - camPrima).abs();
    var cambiati = 0;
    for (var x = 0; x < prima.length; x++) {
      if ((prima[x] - dopo[x]).abs() > 6) cambiati++;
    }
    // ignore: avoid_print
    print('ORDINE AL VOCE 02: la camera della volta corre di '
        '${corsa.toStringAsFixed(1)} pixel inclinando, con Riduci Movimento '
        'acceso; sulla tela cambiano $cambiati pixel su ${prima.length}');
    expect(corsa, greaterThan(25),
        reason: 'con Riduci Movimento acceso il Cielo di nascita non risponde '
            'all\'inclinazione: e\' il ghiaccio visto da Mauro sulla 2179');
    expect(cambiati, greaterThan(0),
        reason: 'la camera corre ma la tela non cambia di un pixel: il '
            'painter non ridisegna');
  });
}
