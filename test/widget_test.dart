import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('L\'app parte dall\'intro e apre Il Risveglio', (tester) async {
    await tester.pumpWidget(const EsotericCircleApp());
    await tester.pump();

    // Intro: il tasto Salta e' sempre disponibile.
    expect(find.text('Salta'), findsOneWidget);

    // Saltando l'intro si entra nell'onboarding, dal passo del nome.
    await tester.tap(find.text('Salta'));
    await tester.pump(); // avvia la transizione
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Come vuoi che ti chiami il cerchio?'), findsOneWidget);
  });

  test('La risoluzione dei feature flag rispetta gli stati', () {
    final entitlement = EntitlementService(initial: Tier.free);
    final flags = FeatureFlagService(entitlement: entitlement);

    final active = FeatureCatalog.byId('natal_chart')!;
    final soon = FeatureCatalog.byId('face_constellation')!;
    final premium = FeatureCatalog.byId('masters_memory')!;

    expect(flags.statusOf(active), FeatureStatus.active);
    expect(flags.statusOf(soon), FeatureStatus.comingSoon);
    expect(flags.statusOf(premium), FeatureStatus.premiumLocked);

    entitlement.setTier(Tier.tier1);
    expect(flags.statusOf(premium), FeatureStatus.active);
  });

  test('Le dodici costellazioni zodiacali sono definite e coerenti', () {
    expect(kZodiacConstellations.length, Zodiac.values.length);
    final signs = kZodiacConstellations.map((c) => c.sign).toSet();
    expect(signs.length, Zodiac.values.length);

    for (final c in kZodiacConstellations) {
      expect(c.points.length, greaterThanOrEqualTo(3));
      for (final (a, b) in c.edges) {
        expect(a, inInclusiveRange(0, c.points.length - 1));
        expect(b, inInclusiveRange(0, c.points.length - 1));
      }
    }
  });
}
