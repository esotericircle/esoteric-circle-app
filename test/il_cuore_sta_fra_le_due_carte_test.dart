// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **IL CUORE STA FRA LE DUE CARTE.** Ordine FY voce FY.12, 16 ottobre 2026.
/// Il fondatore, sulla build 2312 (`fy_fondatore_01.jpg`): *"Sinastria VIP
/// devi centrare il cuore tra le due carte"*.
///
/// **IL DIFETTO, MISURATO.** L'ordine FU voce FU.14 posava ogni carta
/// centrata sulla sua cornice di luce dipinta (centro a 984 pixel del video)
/// e il cuore sul cuore dipinto (a 961): il cuore stava 23 pixel del video
/// piu' in alto del centro delle carte, da 9,5 a 11 punti a seconda dello
/// schermo, ed e' cio' che si vede nella cattura del fondatore.
///
/// **COSA MISURA.** A ogni larghezza fra 320 e 430 punti, ogni dieci, e a due
/// proporzioni dello schermo: lo scarto fra il centro del cuore e il punto a
/// meta' fra le due carte, in orizzontale (fra il bordo destro della prima e
/// il bordo sinistro della seconda) e in verticale (fra i centri delle due
/// carte), e lo scarto fra i centri verticali delle due carte. Tutti entro
/// mezzo punto.
const _larghezze = [320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430];
const _proporzioni = [2.0, 2.2];

/// Il cardinale minimo: dodici larghezze per due proporzioni.
/// Il cardinale minimo: dodici larghezze per due proporzioni, sulle due
/// schermate dove il cuore sta fra le due carte (la porta e il responso).
const _casiAttesi = 48;

/// Le due schermate: la chiave della schermata, le chiavi delle due caselle
/// e quella del cuore.
const _schermate = {
  'la porta': (
    'sinastria_carta_tua',
    'sinastria_carta_da_scegliere',
    'sinastria_vip_cuore'
  ),
  'il responso': (
    'sinastria_pole_user',
    'sinastria_pole_vip',
    'sinastria_responso_cuore'
  ),
};

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final righe = <String>[];
  var casi = 0;

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  for (final MapEntry(key: dove, value: (chiaveTua, chiaveVip, chiaveCuore))
      in _schermate.entries) {
    for (final proporzione in _proporzioni) {
      for (final larga in _larghezze) {
        final schermo =
            Size(larga.toDouble(), (larga * proporzione).roundToDouble());
        testWidgets(
            '$dove, a ${schermo.width.toInt()}x${schermo.height.toInt()} il cuore sta '
            'a meta\' fra le due carte, in orizzontale e in verticale',
            (tester) async {
          silenzia();
          tester.view.physicalSize = schermo;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => ZodiacController()),
              ChangeNotifierProvider(create: (_) => ProfileController()),
              ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
              ChangeNotifierProvider(
                  create: (_) => SettingsController(suonoEVibrazione: false)),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // Riduci Movimento: la scena e' ferma e le carte ci sono subito.
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
                child: MaestroScope(child: child!),
              ),
              home: dove == 'la porta'
                  ? PortaDellaSinastria(
                      userSign: Zodiac.cancer,
                      userName: 'Mauro',
                      userBirth: DateTime(1966, 7, 23),
                    )
                  : SinastriaVipScreen(
                      userSign: Zodiac.cancer,
                      userBirth: DateTime(1966, 7, 23),
                      vip: VipCatalog.conNome('Zendaya'),
                      saltaLaChiamata: true,
                    ),
            ),
          ));
          for (var i = 0; i < 4; i++) {
            await tester.pump(const Duration(milliseconds: 200));
          }
          Rect carta(String chiave) => tester.getRect(find.descendant(
              of: find.byKey(Key(chiave)),
              matching: find.byType(VipFramedPortrait)));
          final tua = carta(chiaveTua);
          final vip = carta(chiaveVip);
          final cuore = tester.getRect(find.byKey(Key(chiaveCuore)));
          final metaX = (tua.right + vip.left) / 2;
          final metaY = (tua.center.dy + vip.center.dy) / 2;
          final dx = cuore.center.dx - metaX;
          final dy = cuore.center.dy - metaY;
          final carte = tua.center.dy - vip.center.dy;
          final riga =
              '$dove, ${schermo.width.toInt()}x${schermo.height.toInt()}: '
              'cuore ${cuore.center}, meta\' fra le carte '
              '(${metaX.toStringAsFixed(2)}, ${metaY.toStringAsFixed(2)}), '
              'scarto orizzontale ${dx.toStringAsFixed(2)}, verticale '
              '${dy.toStringAsFixed(2)}, fra i centri delle carte '
              '${carte.toStringAsFixed(2)} punti';
          print('FY.12 $riga');
          righe.add(riga);
          casi++;
          final colpe = <String>[
            if (dx.abs() > 0.5)
              'il cuore e\' a $dx punti dalla meta\' orizzontale',
            if (dy.abs() > 0.5)
              'il cuore e\' a $dy punti dalla meta\' verticale',
            if (carte.abs() > 0.5)
              'le due carte non hanno lo stesso centro verticale ($carte)',
            if (cuore.overlaps(tua) || cuore.overlaps(vip))
              'il cuore tocca una carta',
          ];
          expect(tester.takeException(), isNull);
          expect(colpe, isEmpty, reason: colpe.join('; '));
        });
      }
    }
  }

  tearDownAll(() {
    // **IL CARDINALE MINIMO**: su un insieme vuoto la guardia sarebbe verde
    // senza aver guardato niente.
    expect(casi, greaterThanOrEqualTo(_casiAttesi),
        reason: 'la guardia ha misurato $casi schermi su $_casiAttesi');
    final dir = Directory('docs/collaudo/FY/sinastrie');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/fy12_misure.txt')
        .writeAsStringSync('FY.12, il cuore fra le due carte: scarti in punti\n'
            '${righe.join('\n')}\n');
  });
}
