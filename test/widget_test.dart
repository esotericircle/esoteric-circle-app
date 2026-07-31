import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('L\'app parte sul Santuario con la bottom bar a cinque voci',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);

    for (final label in const [
      'Il Cerchio',
      'Medora',
      'Caligo',
      'Aura',
      'Passport',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'manca la voce $label');
    }
  });

  testWidgets('La bottom bar apre il dominio del Maestro', (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);

    final ctx = tester.element(find.byType(MaterialApp));
    expect(ctx.read<MaestroController>().activeMaestro, isNull);

    // L'icona Maestro nella barra e' una porta al dominio, non centra soltanto.
    await tester.tap(find.text('Caligo'));
    await step(tester);
    await step(tester);
    expect(find.text('Consulta Caligo'), findsOneWidget);
    expect(ctx.read<MaestroController>().activeMaestro, Maestro.caligo);
  });

  test('La risoluzione dei feature flag rispetta gli stati', () {
    final entitlement = EntitlementService(initial: Tier.free);
    final flags = FeatureFlagService(entitlement: entitlement);

    final active = FeatureCatalog.byId('natal_chart')!;
    // La Costellazione del Viso NON e' piu' in arrivo: lo scaffale e il
    // manifest la dicevano viva da tempo, ed era il catalogo dei flag a
    // essere rimasto indietro. Per provare lo stato "in arrivo" serve una
    // funzione che lo sia davvero.
    final soon = FeatureCatalog.all
        .firstWhere((f) =>
            f.defaultAvailability == RemoteAvailability.comingSoon);
    final premium = FeatureCatalog.byId('masters_memory')!;

    expect(flags.statusOf(active), FeatureStatus.active);
    expect(flags.statusOf(soon), FeatureStatus.comingSoon);
    expect(flags.statusOf(premium), FeatureStatus.premiumLocked);

    // Salendo di tier, la funzione premium si sblocca.
    entitlement.setTier(Tier.tier1);
    expect(flags.statusOf(premium), FeatureStatus.active);
  });

  test('Le dodici costellazioni zodiacali sono definite e coerenti', () {
    // Una per ogni segno, senza duplicati.
    expect(kZodiacConstellations.length, Zodiac.values.length);
    final signs = kZodiacConstellations.map((c) => c.sign).toSet();
    expect(signs.length, Zodiac.values.length);

    // Ogni spigolo referenzia indici di stelle validi.
    for (final c in kZodiacConstellations) {
      expect(c.points.length, greaterThanOrEqualTo(3));
      for (final (a, b) in c.edges) {
        expect(a, inInclusiveRange(0, c.points.length - 1));
        expect(b, inInclusiveRange(0, c.points.length - 1));
      }
    }
  });
}
