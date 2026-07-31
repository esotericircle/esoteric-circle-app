import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE IMMAGINI PRIMA E DOPO, che l'Architetto apre dal remoto prima che il
/// fondatore installi.
///
/// Si generano con `--dart-define=STATO=prima` oppure `dopo`, e finiscono in
/// `docs/preview/prima_dopo/`. La "prima" si ottiene riportando il codice allo
/// stato di partenza e rieseguendo: NON si recupera da un file vecchio, che
/// potrebbe essere di un'altra misura e mostrerebbe una differenza che non e'
/// quella corretta.
const _stato = String.fromEnvironment('STATO');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
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
  }

  for (final nascita in const [false, true]) {
  testWidgets('Cielo ${nascita ? "nascita" : "adesso"}', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    // La misura reale del telefono del fondatore: 360 punti logici.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: SkyOverviewScreen(
            birth: nascita,
            now: nascita ? DateTime(1975, 7, 6, 9, 30) : null,
            ctaLabel: nascita ? 'Leggi la tua carta' : null,
            onCta: nascita ? () {} : null,
            luogoIniziale:
                const SkyPlace(latitude: 45.46, longitude: 9.19),
            location: const DisabledSkyLocation(),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));

    // Si tocca Ariete, che e' la costellazione della segnalazione.
    // Si tocca la LUNA, che e' il corpo che finiva sotto la barra del titolo.
    final corpo = find.byKey(const Key('sky_body_moon'));
    if (corpo.evaluate().isNotEmpty) {
      await tester.tap(corpo, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final quale = nascita ? 'nascita' : 'adesso';
      File('${dir.path}/cielo_${quale}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });
  }

  testWidgets('Dati di nascita', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: const DatiDiNascitaScreen(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/dati_nascita_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });

  testWidgets('Miniature del Passport', (tester) async {
    if (_stato.isEmpty) return;
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: const Scaffold(
            backgroundColor: Color(0xFF0B1020),
            body: CosmicPassport(),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Si scorre fino alle tessere dell'Animale e degli Angeli, che sono quelle
    // con le miniature segnalate.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/miniature_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  });
}
