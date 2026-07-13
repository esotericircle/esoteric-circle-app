import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "Chiedi ai Maestri" ridisegnato: parte da un Maestro, poi invita a portare la
/// stessa domanda a un altro con la sintesi a confronto. Accesso per tier.
void main() {
  Widget host({
    Tier tier = Tier.free,
    Maestro starter = Maestro.medora,
    Size? surface,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          home: MaestroScope(child: AskMaestriScreen(starter: starter)),
        ),
      );

  Future<void> ask(WidgetTester tester, String theme) async {
    await tester.enterText(find.byKey(const Key('ask_field')), theme);
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('Parte dal Maestro del dominio, una risposta e l\'invito',
      (tester) async {
    await tester.pumpWidget(host(starter: Maestro.medora));
    await tester.pump();
    expect(find.byKey(const Key('ask_empty')), findsOneWidget);

    await ask(tester, 'il lavoro');

    // Solo la risposta di Medora, nessuna sintesi, piu' l'invito.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_synthesis')), findsNothing);
    expect(find.byKey(const Key('ask_another_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_add_aura')), findsOneWidget);
    expect(find.byKey(const Key('ask_add_caligo')), findsOneWidget);
  });

  testWidgets('Free: il confronto a un altro Maestro invita all\'upgrade',
      (tester) async {
    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'una scelta');
    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // Appare l'invito gentile, e Aura non e' stata aggiunta.
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsNothing);
  });

  testWidgets('Free: la seconda domanda invita all\'upgrade', (tester) async {
    await tester.pumpWidget(host(tier: Tier.free));
    await ask(tester, 'prima domanda');
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);

    // La seconda domanda del giorno e' oltre il limite del Free.
    await ask(tester, 'seconda domanda');
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
  });

  testWidgets('Tier a pagamento: il confronto aggiunge lo sguardo e la sintesi',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(tier: Tier.tier1, starter: Maestro.medora));
    await ask(tester, 'una scelta d\'amore');

    await tester.tap(find.byKey(const Key('ask_add_aura')));
    await tester.pumpAndSettle();

    // Ora due sguardi e la sintesi comparativa in cima.
    expect(find.byKey(const Key('ask_synthesis')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsOneWidget);
  });
}
