import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/feature_tile.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I DUE GRIGI SI DISTINGUONO, A SCHERMO E NON PER FIDUCIA.
/// Ordine BF voce 05.l, che chiude la verifica promessa da AN.06.
///
/// Il velo di fondo e' lo stesso per costruzione (deepest al 45 per cento),
/// e VA BENE cosi': cio' che distingue le due strade e' cio' che ci sta
/// sopra. Il Coming soon porta il badge "Dietro il velo" e nessun lucchetto;
/// il Premium porta il lucchetto dorato al centro e il badge "Premium" col
/// suo lucchetto piccolo. Qui si rende la coppia e si misura sui pixel che
/// la differenza ESISTE davvero, non solo nel sorgente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dietroIlVelo = FeatureDefinition(
    id: 'prova_velo',
    title: 'Arte velata',
    teaser: 'Si sta preparando.',
    icon: Icons.auto_awesome,
    defaultAvailability: RemoteAvailability.comingSoon,
  );
  const premium = FeatureDefinition(
    id: 'prova_premium',
    title: 'Arte premium',
    teaser: 'Oltre la soglia.',
    icon: Icons.auto_awesome,
    requiredTier: Tier.tier1,
  );

  Future<GlobalKey> monta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final radice = GlobalKey();
    final entitlement = EntitlementService();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: entitlement),
        ChangeNotifierProvider(
            create: (_) => FeatureFlagService(entitlement: entitlement)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          child: RepaintBoundary(
            key: radice,
            child: const Scaffold(
              body: Row(children: [
                Expanded(
                    child: FeatureTile(
                        key: Key('tessera_velo'), feature: dietroIlVelo)),
                Expanded(
                    child: FeatureTile(
                        key: Key('tessera_premium'), feature: premium)),
              ]),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return radice;
  }

  testWidgets('le due strade portano segni diversi, e si vedono',
      (tester) async {
    final radice = await monta(tester);

    // 1. I SEGNI DICHIARATI: il premium ha i lucchetti, il velo no.
    final velo = find.byKey(const Key('tessera_velo'));
    final prem = find.byKey(const Key('tessera_premium'));
    expect(
        find.descendant(
            of: prem, matching: find.byIcon(Icons.lock_rounded)),
        findsNWidgets(2),
        reason: 'il premium deve portare il lucchetto al centro e quello '
            'piccolo nel badge');
    expect(
        find.descendant(of: velo, matching: find.byIcon(Icons.lock_rounded)),
        findsNothing,
        reason: 'il Coming soon non e\' bloccato: un lucchetto direbbe una '
            'cosa falsa');
    expect(find.descendant(of: velo, matching: find.text('Dietro il velo')),
        findsOneWidget);
    expect(find.descendant(of: prem, matching: find.text('Premium')),
        findsOneWidget);

    // 2. SUI PIXEL: al centro delle due tessere la differenza deve esistere
    //    davvero (il lucchetto dorato), non solo nell'albero dei widget.
    await tester.runAsync(() async {
      final rb = radice.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati =
          (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final px = dati.buffer.asUint8List();
      final larghezza = img.width;

      final rVelo = tester.getRect(velo);
      final rPrem = tester.getRect(prem);
      var diversi = 0;
      // Si confronta il quadrato centrale delle due tessere, punto a punto.
      const lato = 40;
      for (var dy = -lato ~/ 2; dy < lato ~/ 2; dy++) {
        for (var dx = -lato ~/ 2; dx < lato ~/ 2; dx++) {
          final xa = (rVelo.center.dx + dx).round(),
              ya = (rVelo.center.dy + dy).round();
          final xb = (rPrem.center.dx + dx).round(),
              yb = (rPrem.center.dy + dy).round();
          final a = (ya * larghezza + xa) * 4, b = (yb * larghezza + xb) * 4;
          final d = (px[a] - px[b]).abs() +
              (px[a + 1] - px[b + 1]).abs() +
              (px[a + 2] - px[b + 2]).abs();
          if (d > 30) diversi++;
        }
      }
      // ignore: avoid_print
      print('ORDINE BF VOCE 05.l: pixel diversi al centro $diversi su '
          '${lato * lato}');
      expect(diversi, greaterThan(150),
          reason: 'al centro le due tessere sono uguali sui pixel: il '
              'lucchetto del premium non si vede, e i due grigi tornano '
              'indistinguibili (ordine AN voce 06)');
      img.dispose();
    });
  });
}
