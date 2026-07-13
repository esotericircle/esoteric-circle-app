import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:esoteric_circle/features/pricing/upgrade_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata dei piani: quattro livelli canonici, la card Demo dietro il
/// flag, la tabella comparativa e l'invito all'upgrade, mai un vicolo cieco.
void main() {
  Widget wrap(EntitlementService ent, Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ent),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(home: MaestroScope(child: child)),
      );

  void tallView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 3200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('In Demo mostra la card Demo col Piano Attuale e i quattro livelli',
      (tester) async {
    tallView(tester);
    final ent = EntitlementService();
    await tester.pumpWidget(wrap(ent, const PricingScreen(isDemo: true)));
    await tester.pump();

    expect(find.byKey(const Key('plan_demo')), findsOneWidget);
    for (final t in [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3]) {
      expect(find.byKey(Key('plan_${t.name}')), findsOneWidget);
    }
    // Il badge Piano Attuale sta sulla Demo, non sul Viandante.
    expect(find.text('Piano Attuale'), findsOneWidget);
    expect(find.text('Consigliato'), findsOneWidget);
    // Testo persistente in basso.
    expect(
        find.textContaining('il pagamento non è integrato'), findsOneWidget);
    // La tabella comparativa e' presente.
    expect(find.byKey(const Key('pricing_table')), findsOneWidget);
    // Compare sia come vantaggio dell'Iniziato sia come riga della tabella.
    expect(find.text('Memoria AI dei Maestri'), findsWidgets);
  });

  testWidgets('Fuori Demo il Piano Attuale sta sul tier corrente', (tester) async {
    tallView(tester);
    final ent = EntitlementService(); // Viandante
    await tester.pumpWidget(wrap(ent, const PricingScreen(isDemo: false)));
    await tester.pump();
    expect(find.byKey(const Key('plan_demo')), findsNothing);
    expect(find.text('Piano Attuale'), findsOneWidget); // sul Viandante
  });

  testWidgets('Scegliere un livello lo attiva in Demo', (tester) async {
    tallView(tester);
    final ent = EntitlementService();
    await tester.pumpWidget(wrap(ent, const PricingScreen(isDemo: true)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('choose_tier1')));
    await tester.pumpAndSettle();
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
                  message: 'Con l\'Iniziato le domande crescono.'),
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
