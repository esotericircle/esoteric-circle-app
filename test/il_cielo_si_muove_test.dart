import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'sorgenti_di_lib.dart';

/// IL CIELO SI MUOVE, ordine M voce 1.
///
/// La regressione dell'8 agosto (commit della cache del cielo) aveva spento
/// la deriva quando il sensore contribuisce, cioe' sempre su un telefono
/// vero: col telefono posato il cosmo era immobile. Queste prove misurano il
/// MOTO SUI PIXEL nelle condizioni della release (interruttori ai default:
/// Riduci Movimento spento, qualita' alta) e tengono chiuse le porte da cui
/// il gelo potrebbe rientrare.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('gli interruttori del moto in release valgono spenti', () {
    // IL VALORE CHE GOVERNA, non l'intenzione: i default del controller
    // delle impostazioni sono quelli con cui l'app nasce sul telefono.
    final s = SettingsController();
    expect(s.reduceAnimations, isFalse,
        reason: 'Riduci animazioni nasce acceso: tutta l\'app parte ferma.');
    expect(s.simpleMode, isFalse,
        reason: 'La modalita\' semplice nasce accesa: qualita\' bassa e '
            'cosmo quasi statico per tutti.');
    expect(QualityTierController().tier, QualityTier.high,
        reason: 'Il tier di fabbrica non e\' piu\' alto.');
  });

  test('l\'interruttore delle anteprime non arriva nell\'app', () {
    // La cattura deterministica vive nei test via dart-define STATO: se un
    // file di lib lo leggesse, il gelo delle anteprime potrebbe salire
    // sull'app vera.
    final colpe = <String>[];
    for (final f in sorgentiDiLib()) {
      if (f.readAsStringSync().contains("fromEnvironment('STATO'")) {
        colpe.add(f.path);
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi file di lib leggono l\'interruttore delle anteprime: '
            '\n${colpe.join('\n')}');
  });

  Future<ByteData> scatta(WidgetTester tester, GlobalKey radice) async {
    late ByteData b;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      b = (await (await rb.toImage())
          .toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });
    return b;
  }

  int diversi(ByteData a, ByteData b) {
    var n = 0;
    for (var i = 0; i < a.lengthInBytes; i += 16) {
      if (a.getUint8(i) != b.getUint8(i)) n++;
    }
    return n;
  }

  Widget cosmo(ParallaxController parallax, {bool riduci = false}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(
              create: (_) => QualityTierController(initial: QualityTier.high)),
          ChangeNotifierProvider<ParallaxController>.value(value: parallax),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: riduci),
            child: child!,
          ),
          home: const MaestroScope(
            child: CosmosBackground(
                seed: 5, showZodiac: false, child: SizedBox.expand()),
          ),
        ),
      );

  testWidgets(
      'col sensore attivo, il cielo a riposo respira: e\' la scena '
      'del telefono posato', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    binding.defaultBinaryMessenger.setMockStreamHandler(
        const EventChannel('dev.fluttercommunity.plus/sensors/accelerometer'),
        MockStreamHandler.inline(onListen: (args, events) {
      events.success(Float64List.fromList([5.0, 2.0, 8.0, 0.0]));
    }));
    final radice = GlobalKey();
    final parallax = ParallaxController();
    await tester
        .pumpWidget(RepaintBoundary(key: radice, child: cosmo(parallax)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(parallax.sensorActive, isTrue,
        reason: 'Il sentiero del sensore e\' rotto: l\'evento del canale '
            'non arriva al controller.');

    final fermo = await scatta(tester, radice);
    await tester.pump(const Duration(milliseconds: 1400));
    final poi = await scatta(tester, radice);
    final moto = diversi(fermo, poi);
    // ignore: avoid_print
    print('moto a riposo col sensore attivo: $moto campioni');
    expect(moto, greaterThan(3000),
        reason: 'Col sensore attivo il cielo a riposo e\' fermo: la deriva '
            'si e\' rispenta, ed e\' la regressione dell\'8 agosto tornata.');
  });

  testWidgets('lo scorrimento sposta i piani', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final radice = GlobalKey();
    final parallax = ParallaxController();
    await tester
        .pumpWidget(RepaintBoundary(key: radice, child: cosmo(parallax)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final prima = await scatta(tester, radice);
    parallax.updateScroll(600);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final dopo = await scatta(tester, radice);
    expect(diversi(prima, dopo), greaterThan(10000),
        reason: 'Lo scorrimento non sposta piu\' i piani del cielo.');
  });

  testWidgets('con Riduci Movimento il cosmo resta quieto nel tempo',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final radice = GlobalKey();
    final parallax = ParallaxController();
    await tester.pumpWidget(
        RepaintBoundary(key: radice, child: cosmo(parallax, riduci: true)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final prima = await scatta(tester, radice);
    await tester.pump(const Duration(milliseconds: 1400));
    final dopo = await scatta(tester, radice);
    expect(diversi(prima, dopo), 0,
        reason: 'Con Riduci Movimento il cielo si muove col tempo: chi ha '
            'chiesto quiete riceve moto.');
  });
}
