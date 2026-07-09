import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La Home Il Santuario si avvia e mostra i Maestri',
      (tester) async {
    await tester.pumpWidget(const EsotericCircleApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Il Santuario'), findsOneWidget);
    // La bottom bar e il selettore contengono i tre Maestri.
    expect(find.text('Medora'), findsWidgets);
    expect(find.text('Aura'), findsWidgets);
    expect(find.text('Caligo'), findsWidgets);
  });

  testWidgets('Il tap su un Maestro naviga alla sua sezione',
      (tester) async {
    await tester.pumpWidget(const EsotericCircleApp());
    await tester.pump(const Duration(seconds: 1));

    // Tocca la voce Caligo nella bottom bar (l'ultima occorrenza).
    await tester.tap(find.text('Caligo').last);
    // Le animazioni di fondo sono in loop: non si usa pumpAndSettle, ma pump
    // con durate fisse per far avanzare la transizione.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // L'intestazione della sezione mostra la tagline univoca del Maestro.
    expect(find.text('Custode delle rune e dei riti antichi'),
        findsOneWidget);
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
