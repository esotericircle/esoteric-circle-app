import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL LIMITE DELLE GETTATE DI RUNE, ordine I voce 3.
///
/// Tre gettate al giorno per il Viandante, illimitate dal Tier 1 in su. Il
/// numero vive nella MATRICE dei piani, il conteggio in `QuestionAllowance`
/// col reset giornaliero gia' in uso per le altre arti, e a quota esaurita il
/// pulsante e' grigio col tocco che apre l'invito: mai un blocco muto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il numero tre vive nel dato, con gli altri limiti giornalieri', () {
    expect(PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, Tier.free),
        3,
        reason: 'La matrice non promette piu\' tre gettate al Viandante.');
    for (final t in [Tier.tier1, Tier.tier2, Tier.tier3]) {
      expect(PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, t), isNull,
          reason: 'Dal Tier 1 in su le gettate sono illimitate, e per '
              '$t la matrice dice altro.');
    }
  });

  Future<QuestionAllowance> monta(WidgetTester tester,
      {required Tier piano}) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final borsa = QuestionAllowance();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => EntitlementService(initial: piano)),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: math.Random(9)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    return borsa;
  }

  Future<void> getta(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_cast_button')));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> ancora(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('rune_recast')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_recast')));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('al terzo getto il gratuito e\' fermo: pulsante grigio e '
      'invito, mai muto', (tester) async {
    final borsa = await monta(tester, piano: Tier.free);
    await getta(tester);
    await ancora(tester);
    await ancora(tester);
    // Tre gettate fatte: la quota del giorno e' spesa.
    expect(borsa.gettateRimaste(Tier.free), 0,
        reason: 'Dopo tre getti al Viandante deve restare zero.');
    // Il pulsante lo dice col colore e col lucchetto, prima di ogni tocco.
    expect(
        find.descendant(
            of: find.byKey(const Key('rune_recast')),
            matching: find.byIcon(Icons.lock_outline_rounded)),
        findsOneWidget,
        reason: 'A quota esaurita Getta ancora non si spegne: sembra vivo e '
            'poi non fa niente.');
    // Il quarto tocco non getta e non tace: apre l\'invito del gating.
    await ancora(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'Il quarto getto del Viandante e\' un blocco muto: nessun '
            'invito comparso.');
    expect(borsa.gettateRimaste(Tier.free), 0,
        reason: 'Il quarto getto ha intaccato un contatore gia\' a zero.');
  });

  testWidgets('al quarto getto il Tier 1 non e\' fermo', (tester) async {
    final borsa = await monta(tester, piano: Tier.tier1);
    await getta(tester);
    await ancora(tester);
    await ancora(tester);
    await ancora(tester);
    // Quattro getti, nessun invito e nessun lucchetto: la strada e' aperta.
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'Il Tier 1 ha le gettate illimitate, e al quarto getto gli '
            'e\' comparso il gating.');
    expect(
        find.descendant(
            of: find.byKey(const Key('rune_recast')),
            matching: find.byIcon(Icons.lock_outline_rounded)),
        findsNothing,
        reason: 'Il pulsante del Tier 1 si e\' spento: il limite sta '
            'mordendo il piano sbagliato.');
    expect(borsa.gettateRimaste(Tier.tier1), isNull,
        reason: 'Per il Tier 1 non c\'e\' un residuo da contare.');
  });
}
