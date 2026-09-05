import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA LARGHEZZA REALE: 360 punti logici.
///
/// **La causa di nove segnalazioni.** Il telefono su cui l'app viene guardata
/// riporta 1080 per 2392 pixel fisici, che con un rapporto di pixel di 3 fanno
/// **360 per 797 punti logici**. Le anteprime pero' venivano generate a 390 di
/// larghezza, cioe' trenta punti logici in piu', novanta pixel fisici. La
/// costante che diceva di essere "quella di Mauro" aveva l'altezza giusta e la
/// larghezza sbagliata: il commento dichiarava una cosa e il codice ne faceva
/// un'altra.
///
/// Su trenta punti in meno il testo va a capo prima, i titoli si spezzano, le
/// etichette si troncano e le bolle crescono in altezza perche' occupano due
/// righe invece di una. Era l'elenco esatto dei difetti segnalati, e nelle
/// anteprime non si vedevano perche' le anteprime erano piu' larghe.
///
/// **Cosa misura questo test.** Monta le schermate principali alla larghezza
/// reale e raccoglie gli errori di layout che Flutter emette: un riquadro che
/// sborda dal proprio spazio produce un errore, e quell'errore e' il difetto.
/// Non serve guardare le immagini una per una.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// La misura reale, in punti logici.
  const larghezzaReale = 360.0;
  const altezzaReale = 797.0;

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

  Widget conProvider(Widget schermata) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => GreetingController()),
          ChangeNotifierProvider(create: (_) => SettingsController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ArtiPreferiteController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: schermata,
        ),
      );

  /// Monta una schermata alla larghezza reale e raccoglie gli errori di layout.
  Future<List<String>> erroriDiLayout(
      WidgetTester tester, Widget schermata) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(larghezzaReale, altezzaReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final errori = <String>[];
    final precedente = FlutterError.onError;
    FlutterError.onError = (dettaglio) {
      final testo = dettaglio.exceptionAsString();
      // Sono questi gli errori che raccontano un testo che non ci sta.
      if (testo.contains('overflowed') || testo.contains('RenderFlex')) {
        errori.add(testo.split('\n').first);
      }
    };
    addTearDown(() => FlutterError.onError = precedente);

    await tester.pumpWidget(conProvider(schermata));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return errori;
  }

  testWidgets('Il Cerchio regge la larghezza reale', (tester) async {
    final errori = await erroriDiLayout(
        tester, SantuarioScreen(clock: () => DateTime(2026, 7, 30, 21)));
    expect(errori, isEmpty,
        reason: 'a $larghezzaReale punti di larghezza il Cerchio ha errori di '
            'layout: ${errori.join(" | ")}');
  });

  for (final m in Maestro.values) {
    testWidgets('Il dominio di ${m.displayName} regge la larghezza reale',
        (tester) async {
      final errori = await erroriDiLayout(tester, DomainScreen(maestro: m));
      expect(errori, isEmpty,
          reason: 'a $larghezzaReale punti il dominio di ${m.displayName} ha '
              'errori di layout: ${errori.join(" | ")}');
    });
  }

  test('La misura reale e\' dichiarata nel corredo delle anteprime', () {
    // Se qualcuno riportasse le catture a 390, i difetti tornerebbero a essere
    // invisibili nelle anteprime pur restando sul telefono.
    final codice = File('test/screenshot_capture_test.dart').readAsStringSync();
    expect(codice.contains('schermoReale = Size(360, 797)'), isTrue,
        reason: 'il corredo non dichiara piu\' la misura reale del telefono su '
            'cui l\'app viene guardata');
  });
}
