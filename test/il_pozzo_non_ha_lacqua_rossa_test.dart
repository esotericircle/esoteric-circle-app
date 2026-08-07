import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL POZZO NON HA PIU' L'ACQUA ROSSA, E IL TELO NON E' UN RETTANGOLO.
///
/// Ordine 2161, voce 6. Parole di Mauro: la gettata mostrava uno sfondo
/// quadrato rosso sotto le rune. Era `_acqua` in `_PozzoPainter`, un
/// `drawRect` col rosso di Caligo: un fondale bespoke squadrato, contro la
/// regola del cosmo condiviso. Le pietre adesso cadono sul cosmo.
///
/// Il panno di Tacito invece RESTA, perche' e' la fonte (Germania, capitolo
/// dieci) e non decorazione: ma smette di essere un rettangolo. Bordi
/// morbidi e irregolari, nessun angolo retto.
///
/// La terza guardia della voce, pietre nel campo e mai sovrapposte, vive in
/// `fisica_della_gettata_test.dart` (righe 91 e 127) e resta al suo posto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// L'ACQUA SI RICONOSCE DALLA SUA TINTA, palette.surfaceElevated: e' il
  /// rosso elevato di Caligo che il drawRect stendeva al novanta per cento
  /// sopra il cosmo. Il cosmo condiviso NON usa quel tono (usa deepest e i
  /// blu delle stelle), quindi nel pozzo quel colore puo' venire solo
  /// dall'acqua. Misurato prima della correzione: col drawRect acceso i
  /// pixel di quella tinta nel pozzo sono decine di migliaia; senza, quasi
  /// zero. La soglia sta larga sopra lo zero per il rumore di sfumatura.
  const sogliaPixelAcqua = 800;

  /// Un bordo del panno e' RETTILINEO se la sua quota non cambia per piu' di
  /// questa corsa, in pixel fisici a rapporto 3 (60 pixel = 20 punti). Il
  /// rettangolo di prima aveva il bordo dritto per l'intera larghezza del
  /// campo, oltre mille pixel.
  const corsaRettaMassima = 60;

  Future<ui.Image> cattura(WidgetTester tester, GlobalKey radice) async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return rb.toImage(pixelRatio: 3.0);
  }

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

  Future<void> monta(WidgetTester tester, GlobalKey radice) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: RepaintBoundary(
          key: radice,
          child: RuneDrawScreen(userSign: Zodiac.aries, random: math.Random(7)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> getta(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    // La caduta si esaurisce: la scena ferma e' quella che Mauro guarda.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.ensureVisible(find.byKey(const Key('rune_well')));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// I byte RGBA del pozzo, ritagliati dall'immagine dell'intera schermata.
  Future<(Uint8List, int, int, int)> pozzo(
      WidgetTester tester, GlobalKey radice) async {
    final rect = tester.getRect(find.byKey(const Key('rune_well')));
    final img = await cattura(tester, radice);
    final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final byte = dati.buffer.asUint8List();
    final imgW = img.width;
    final x0 = (rect.left * 3).round().clamp(0, imgW - 1);
    final y0 = (rect.top * 3).round().clamp(0, img.height - 1);
    final w = (rect.width * 3).round().clamp(1, imgW - x0);
    final h = (rect.height * 3).round().clamp(1, img.height - y0);
    final fuori = Uint8List(w * h * 4);
    for (var y = 0; y < h; y++) {
      final da = ((y0 + y) * imgW + x0) * 4;
      fuori.setRange(y * w * 4, (y * w + w) * 4, byte, da);
    }
    img.dispose();
    return (fuori, w, h, imgW);
  }

  testWidgets('nella stesa fissa non esiste piu\' il rosso dell\'acqua',
      (tester) async {
    final radice = GlobalKey();
    await monta(tester, radice);
    await getta(tester);

    final (byte, w, h, _) = await tester.runAsync(() => pozzo(tester, radice))
        as (Uint8List, int, int, int);
    final tinta = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo))
        .surfaceElevated;
    final tr = (tinta.r * 255).round();
    final tg = (tinta.g * 255).round();
    final tb = (tinta.b * 255).round();
    var acqua = 0;
    for (var i = 0; i < w * h; i++) {
      final r = byte[i * 4], g = byte[i * 4 + 1], b = byte[i * 4 + 2];
      final d = (r - tr).abs() + (g - tg).abs() + (b - tb).abs();
      if (d < 36) acqua++;
    }
    // IL CONTO SI STAMPA SEMPRE: quando la prova cade, il rosso si legge.
    // ignore: avoid_print
    print('POZZO: pixel del rosso dell\'acqua = $acqua su ${w * h}');
    expect(acqua, lessThan(sogliaPixelAcqua),
        reason: 'Nel pozzo della stesa fissa ci sono $acqua pixel del rosso '
            'dell\'acqua (soglia $sogliaPixelAcqua): il drawRect del fondale '
            'squadrato e\' tornato, ed e\' cio\' che Mauro ha bocciato.');
  });

  testWidgets('il panno di Tacito non ha bordi rettilinei', (tester) async {
    final radice = GlobalKey();
    await monta(tester, radice);
    // Si sceglie il getto sul telo, che e' l'unico che stende il panno.
    await tester.ensureVisible(find.text('Il getto sul telo'));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.text('Il getto sul telo'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    await getta(tester);

    final (byte, w, h, _) = await tester.runAsync(() => pozzo(tester, radice))
        as (Uint8List, int, int, int);
    // Il panno si riconosce dal suo chiaro caldo: piu' luminoso del cosmo,
    // col rosso sopra il blu. Le pietre d'osso sono anch'esse chiare, ma
    // stanno DENTRO il panno: il bordo esterno del chiaro e' il bordo del
    // panno.
    bool panno(int i) {
      final r = byte[i * 4], g = byte[i * 4 + 1], b = byte[i * 4 + 2];
      return r > 150 && g > 130 && b > 100 && r >= g && g >= b;
    }

    // La quota del primo pixel di panno dall'alto, colonna per colonna, e
    // dal basso: un bordo rettilineo tiene la stessa quota per una corsa
    // lunga, il bordo morbido la cambia di continuo.
    int corsaPiuLunga(List<int> quote) {
      var corsa = 1, massima = 0;
      for (var x = 1; x < quote.length; x++) {
        if (quote[x] >= 0 && quote[x] == quote[x - 1]) {
          corsa++;
        } else {
          corsa = 1;
        }
        if (quote[x] >= 0 && corsa > massima) massima = corsa;
      }
      return massima;
    }

    final dallAlto = List<int>.filled(w, -1);
    final dalBasso = List<int>.filled(w, -1);
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        if (panno(y * w + x)) {
          dallAlto[x] = y;
          break;
        }
      }
      for (var y = h - 1; y >= 0; y--) {
        if (panno(y * w + x)) {
          dalBasso[x] = y;
          break;
        }
      }
    }
    final sinistra = List<int>.filled(h, -1);
    final destra = List<int>.filled(h, -1);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (panno(y * w + x)) {
          sinistra[y] = x;
          break;
        }
      }
      for (var x = w - 1; x >= 0; x--) {
        if (panno(y * w + x)) {
          destra[y] = x;
          break;
        }
      }
    }
    final corse = {
      'alto': corsaPiuLunga(dallAlto),
      'basso': corsaPiuLunga(dalBasso),
      'sinistra': corsaPiuLunga(sinistra),
      'destra': corsaPiuLunga(destra),
    };
    // ignore: avoid_print
    print('PANNO: corse rettilinee per bordo = $corse');
    corse.forEach((bordo, corsa) {
      expect(corsa, lessThanOrEqualTo(corsaRettaMassima),
          reason: 'Il bordo $bordo del panno tiene la stessa quota per '
              '$corsa pixel di fila (massimo $corsaRettaMassima): e\' un '
              'bordo rettilineo, cioe\' il rettangolo che Mauro ha bocciato.');
    });
  });
}
