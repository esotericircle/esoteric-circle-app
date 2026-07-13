import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:esoteric_circle/features/pricing/upgrade_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata dei piani e l'invito all'upgrade, mai un vicolo cieco.
void main() {
  Widget wrap(EntitlementService ent, Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ent),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(home: MaestroScope(child: child)),
      );

  testWidgets('Mostra i quattro piani e segna quello attuale', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ent = EntitlementService(); // Free di default
    await tester.pumpWidget(wrap(ent, const PricingScreen()));
    await tester.pump();

    for (final plan in PlanCatalog.plans) {
      expect(find.byKey(Key('plan_${plan.tier.name}')), findsOneWidget,
          reason: 'manca il piano ${plan.tier.name}');
    }
    expect(find.text('Piano attuale'), findsOneWidget);
    expect(find.text('Consigliato'), findsOneWidget);
  });

  testWidgets('Scegliere un piano lo attiva in Demo', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ent = EntitlementService();
    await tester.pumpWidget(wrap(ent, const PricingScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('choose_tier1')));
    await tester.pumpAndSettle();
    // Il foglio spiega il pagamento non attivo, con la prova in Demo.
    await tester.tap(find.byKey(const Key('activate_demo')));
    await tester.pump();
    await tester.pump();
    expect(ent.tier, Tier.tier1);
  });

  testWidgets('L\'invito all\'upgrade porta ai piani, mai un vicolo cieco',
      (tester) async {
    final ent = EntitlementService();
    await tester.pumpWidget(wrap(
      ent,
      Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showUpgradeInvite(ctx,
                  title: 'Hai posto la domanda di oggi',
                  message: 'Col Cerchio le domande sono senza limiti.'),
              child: const Text('vai'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('vai'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);

    await tester.tap(find.byKey(const Key('upgrade_see_plans')));
    await tester.pumpAndSettle();
    expect(find.byType(PricingScreen), findsOneWidget);
  });
}
