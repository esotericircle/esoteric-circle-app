import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "Il cielo sopra di te": mostra la Luna e le costellazioni alte stanotte,
/// toccabili, con la loro riga. Freccia Indietro, mai un vicolo cieco.
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

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Widget host(DateTime now) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(child: SkyOverviewScreen(now: now)),
        ),
      );

  testWidgets('Mostra la Luna e le costellazioni alte stanotte, toccabili',
      (tester) async {
    silence();
    final now = DateTime.utc(2026, 7, 13, 22);
    await tester.pumpWidget(host(now));
    await step(tester);

    // La Luna e le tre costellazioni alte hanno il loro corpo toccabile.
    expect(find.byKey(const Key('sky_body_moon')), findsOneWidget);
    final high = NightSky.constellationsHighTonight(now);
    expect(high.length, 3);
    for (final sign in high) {
      expect(find.byKey(Key('sky_body_${sign.id}')), findsOneWidget,
          reason: 'manca il corpo ${sign.id}');
      expect(find.text(sign.italianName), findsWidgets);
    }

    // Toccando la Luna, la scheda mostra la sua riga.
    await tester.tap(find.byKey(const Key('sky_body_moon')));
    await step(tester);
    expect(find.text('Luna'), findsWidgets);

    // Toccando una costellazione, la scheda ne mostra la descrizione.
    final sign = high.first;
    await tester.tap(find.byKey(Key('sky_body_${sign.id}')));
    await step(tester);
    expect(find.text(NightSky.describe(sign)), findsOneWidget);
  });

  testWidgets('Ha la freccia Indietro e il bottone Condividi', (tester) async {
    silence();
    await tester.pumpWidget(host(DateTime.utc(2026, 7, 13, 22)));
    await step(tester);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Il bottone della cartolina condivisibile.
    expect(find.byKey(const Key('sky_share')), findsOneWidget);
  });
}
