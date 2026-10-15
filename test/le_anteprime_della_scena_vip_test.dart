// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ANTEPRIME DELLA SCENA VIP**, ordine FU voce FU.14: la porta della
/// Sinastria VIP a 360 per 797 punti logici col rapporto di pixel 3, in
/// `docs/preview/FU/`, con `--dart-define=STATO=prima` o `STATO=dopo`.
///
/// La scena e' quella ferma (Riduci Movimento): l'ultimo fotogramma del
/// Sipario con l'interfaccia sopra, cioe' cio' che resta a video finito. Il
/// video vero si guarda sul telefono. **La prova non nomina niente di cio'
/// che l'ordine FU aggiunge**, cosi' la stessa cattura gira anche sul commit
/// di prima (a5ebd44d) e da' il "prima" con la stessa misura: la grandezza
/// delle due carte in punti logici, scritta nella riga ANTEPRIMA.
const _stato = String.fromEnvironment('STATO');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FU');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FU ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  testWidgets('FU.14: la porta della Sinastria VIP', (tester) async {
    if (_stato.isEmpty) return;
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(child: figlio!),
          ),
          home: PortaDellaSinastria(
            userSign: Zodiac.leo,
            userName: 'Mauro',
            userBirth: DateTime(1972, 8, 10),
          ),
        ),
      ),
    ));
    await passa(tester);
    // Le immagini si decodificano fuori dal tempo finto: senza, la cattura
    // le prenderebbe vuote.
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await passa(tester, 4);
    final carte = [
      for (final chiave in const [
        'sinastria_carta_tua',
        'sinastria_carta_da_scegliere'
      ])
        tester.getRect(find.descendant(
            of: find.byKey(Key(chiave)),
            matching: find.byType(VipFramedPortrait))),
    ];
    print(
        'FU ANTEPRIMA $_stato: carte ${carte.map((r) => '${r.width.toStringAsFixed(1)}x'
            '${r.height.toStringAsFixed(1)} a (${r.left.toStringAsFixed(1)}, '
            '${r.top.toStringAsFixed(1)})').join(' e ')}');
    await scatta(tester, 'fu14_porta_vip');

    // Le tre scelte, scorrendo fino all'ultima.
    final ultima = find.byKey(Key(ModoDellaSinastria.gemelloAstrale.chiave));
    await tester.ensureVisible(ultima);
    await passa(tester, 3);
    await scatta(tester, 'fu14_porta_vip_scelte');
  });
}
