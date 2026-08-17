import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA LINEA AI BORDI SPARISCE. Ordine AJ voce 02.
///
/// **Il difetto, visto da Mauro inclinando il telefono**: la parallasse
/// muove i piani del cosmo, ma i piani in cache erano grandi ESATTAMENTE
/// quanto lo schermo: il loro bordo entrava nell'inquadratura e ai lati si
/// vedeva la LINEA netta dove le stelle finivano. Verificato sulla misura:
/// nessuna scorta, e il piano di fondo corre fino a 80 punti.
///
/// **La cura**: ogni piano in cache si dipinge con la sua SCORTA, l'ampiezza
/// massima della sua parallasse piu' un pixel, riempita dai pittori; il
/// piano vicino esce dalla cache e torna dal vivo (quattordici cerchi).
///
/// **La grandezza**: si rende il cielo a fondo corsa nelle quattro direzioni
/// e si contano le stelle nelle quattro fasce laterali da quaranta punti:
/// una fascia che confina col bordo di un piano resta quasi vuota, una
/// fascia coperta dalla scorta ha una densita' come quella del centro. La
/// soglia viene dal baratro misurato fra le due popolazioni.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a fondo corsa nessuna fascia laterale resta svuotata',
      (tester) async {
    final canali = binding.defaultBinaryMessenger;
    canali.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      canali.setMockStreamHandler(
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RepaintBoundary(
          key: chiave,
          child: const CosmosBackground(seed: 5, child: SizedBox.expand()),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // **LA GRANDEZZA E' IL GRADINO, non la popolazione.** La prima stesura
    // contava i pixel chiari nelle fasce e dava per vuota una fascia coperta
    // da nebulosa fioca sotto soglia: guardata la resa, la fascia era piena.
    // Il bordo di un piano e' un GRADINO netto nella luminanza media lungo
    // la direzione del moto: si misura il salto massimo fra righe (o
    // colonne) a sei punti di distanza dentro la fascia esterna.
    Future<double> gradinoMassimo(String lato) async {
      final scatola = chiave.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final resa = await tester.runAsync(() => scatola.toImage(pixelRatio: 1.0));
      final dati = (await tester.runAsync(
          () => resa!.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      final w = resa!.width, h = resa.height;
      double lumMedia(int a, int b, bool perRiga) {
        var somma = 0.0;
        var quanti = 0;
        if (perRiga) {
          for (var x = 40; x < w - 40; x++) {
            final k = (a * w + x) * 4;
            somma += (dati.getUint8(k) * 299 +
                    dati.getUint8(k + 1) * 587 +
                    dati.getUint8(k + 2) * 114) /
                1000.0;
            quanti++;
          }
        } else {
          for (var y = 40; y < h - 40; y++) {
            final k = (y * w + a) * 4;
            somma += (dati.getUint8(k) * 299 +
                    dati.getUint8(k + 1) * 587 +
                    dati.getUint8(k + 2) * 114) /
                1000.0;
            quanti++;
          }
        }
        return somma / quanti;
      }

      var salto = 0.0;
      switch (lato) {
        case 'cima':
          for (var y = 0; y < 160 - 6; y++) {
            salto = math.max(
                salto, (lumMedia(y, 0, true) - lumMedia(y + 6, 0, true)).abs());
          }
        case 'fondo':
          for (var y = h - 160; y < h - 6; y++) {
            salto = math.max(
                salto, (lumMedia(y, 0, true) - lumMedia(y + 6, 0, true)).abs());
          }
        case 'sinistra':
          for (var x = 0; x < 160 - 6; x++) {
            salto = math.max(salto,
                (lumMedia(x, 0, false) - lumMedia(x + 6, 0, false)).abs());
          }
        default:
          for (var x = w - 160; x < w - 6; x++) {
            salto = math.max(salto,
                (lumMedia(x, 0, false) - lumMedia(x + 6, 0, false)).abs());
          }
      }
      return salto;
    }

    // Le quattro direzioni a fondo corsa: il tilt spinge i piani verso il
    // lato OPPOSTO, quindi il bordo comparirebbe dal lato da cui vengono.
    final casi = {
      'sinistra': const Offset(1, 0),
      'destra': const Offset(-1, 0),
      'cima': const Offset(0, 1),
      'fondo': const Offset(0, -1),
    };
    var osservate = 0;
    final rotture = <String>[];
    final salti = <String, String>{};
    for (final voce in casi.entries) {
      parallasse.inclinaPerLaProva(voce.value.dx, voce.value.dy);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      osservate++;
      final salto = await gradinoMassimo(voce.key);
      salti[voce.key] = salto.toStringAsFixed(1);
      // IL BARATRO, misurato sulle due popolazioni: con la scorta il salto
      // massimo arriva a 6,3 livelli su 255 (i gradienti del cielo e gli
      // aloni delle protagoniste); senza scorta il bordo dei piani taglia
      // nebulose e campo e il salto parte da 9,9 (fino a 12,2). La soglia
      // sette sta nel mezzo del baratro.
      if (salto > 7.0) {
        rotture.add('${voce.key} (gradino ${salto.toStringAsFixed(1)})');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se non sono quattro.**
    // ignore: avoid_print
    print('ORDINE AJ VOCE 02: fasce osservate $osservate, gradini massimi '
        '$salti');
    expect(osservate, 4);
    expect(rotture, isEmpty,
        reason: 'a fondo corsa il bordo di un piano entra in scena come un '
            'gradino di luminanza: ${rotture.join(" | ")}');
  });
}
