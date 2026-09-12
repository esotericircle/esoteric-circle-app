import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL SOLCO SI SCAVA SULLA PIETRA VERA, NON SU UN VETTORIALE.
///
/// Ordine 2161, voce 9. Parole di Mauro: la traccia della runa appariva
/// sopra un'immagine vettoriale standard e non sulla Runa Vergine. La pietra
/// vergine sta sotto FIN DAL PRIMO ISTANTE, dalla porta unica RetroDellaRuna,
/// e il solco si scava sopra di lei: al termine non c'e' sostituzione di
/// pietra, cambia solo il solco.
///
/// La prova e' a pixel, a META' incisione: nel riquadro della pietra accanto
/// al solco deve esserci la VENATURA dell'osso vero, che ha grana, non il
/// riempimento liscio del vettoriale. La grana si misura come scarto medio
/// fra pixel vicini. La porta unica e' gia' sorvegliata da
/// il_retro_vergine_ha_una_porta_sola_test.dart, che enumera i file.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final ora = DateTime(2026, 8, 6, 21, 30);

  /// Misurato: il vettoriale liscio sta sotto questa grana, l'osso vero
  /// sopra. Il numero stampato dalla prova documenta la calibrazione.
  const granaMinima = 2.0;

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  testWidgets('a meta\' incisione sotto il solco c\'e\' la venatura vera',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    silenzia();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: RepaintBoundary(
        key: radice,
        child: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // IL PRECACHE PRIMA DI TUTTO: in prova headless nessuno decodifica gli
    // asset da solo. Senza queste righe la pietra non c'e' e la misura
    // accuserebbe la scena di essere vuota mentre e' la misura a non vedere.
    await tester.runAsync(() async {
      final el = tester.element(find.byType(MaterialApp));
      for (final r in kElderFuthark) {
        final vergine = pathVergineDi(r.stem);
        if (vergine != null) {
          await precacheImage(AssetImage(vergine), el);
        }
      }
    });
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    // Col movimento ridotto l'incisione va da se' in 1,2 secondi: tre passi
    // da 200 ms sono circa meta' del segno.
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    final zona =
        tester.getRect(find.byKey(const Key('sunset_incisione_gesture')));
    final img = await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return rb.toImage(pixelRatio: 1.0);
    });
    final dati = await tester
        .runAsync(() => img!.toByteData(format: ui.ImageByteFormat.rawRgba));
    final byte = dati!.buffer.asUint8List();
    final w = img!.width;

    // Il campione: dentro la pietra, accanto al solco, 30 per 30 punti a
    // sinistra sotto il centro. La grana e' lo scarto medio di luminanza fra
    // pixel adiacenti: l'osso vero ha pori e venatura, il vettoriale no.
    final cx = zona.center.dx.round(), cy = zona.center.dy.round();
    double luma(int x, int y) {
      final i = (y * w + x) * 4;
      return 0.299 * byte[i] + 0.587 * byte[i + 1] + 0.114 * byte[i + 2];
    }

    var somma = 0.0;
    var conti = 0;
    for (var y = cy + 40; y < cy + 70; y++) {
      for (var x = cx - 55; x < cx - 25; x++) {
        somma += (luma(x + 1, y) - luma(x, y)).abs() +
            (luma(x, y + 1) - luma(x, y)).abs();
        conti += 2;
      }
    }
    final grana = somma / conti;
    // ignore: avoid_print
    print('SOLCO: grana della pietra accanto al solco = '
        '${grana.toStringAsFixed(2)} (minimo $granaMinima)');
    img.dispose();
    expect(grana, greaterThanOrEqualTo(granaMinima),
        reason: 'A meta\' incisione la superficie accanto al solco e\' '
            'liscia (grana ${grana.toStringAsFixed(2)}): sotto il dito '
            'non c\'e\' la pietra vergine vera ma il vettoriale, che e\' '
            'cio\' che Mauro ha bocciato.');
  });
}
