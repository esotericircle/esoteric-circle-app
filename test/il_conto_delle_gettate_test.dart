import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
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

/// IL CONTO DELLE GETTATE SI VEDE E DICE IL VERO, ordine L voce 2.
///
/// "2 di 3", "1 di 3", e a zero il messaggio del domani; chi non ha limite
/// non vede nessun conto. Il numero viene dallo stesso budget dell'ordine I e
/// cala di UNO nell'istante della gettata: se scendesse senza che la gettata
/// avvenga, il conto mentirebbe, ed e' il rosso eseguito di questa prova.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, {required Tier piano}) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: piano)),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: math.Random(3)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
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

  String conto(WidgetTester tester) {
    final t = tester
        .widget<Text>(find.byKey(const Key('rune_conto_gettate')).first);
    return t.data!;
  }

  // I DUE STATI DEL CONTO, e sono due perche' il limite e' UNO dall'ordine O
  // del 12 agosto 2026, per decisione di Mauro: erano tre dall'ordine I.
  // Con una gettata sola il passo intermedio non esiste piu' nel dato, e
  // pretenderlo vorrebbe dire pretendere un numero che nessuno promette.
  testWidgets('i due stati del conto: pieno e finito', (tester) async {
    await monta(tester, piano: Tier.free);
    // Sempre presente per chi ha un limite, gia' prima del primo getto.
    expect(conto(tester), 'Gettate di oggi: 1 di 1',
        reason: 'Prima del primo getto il conto non dice uno di uno.');
    await getta(tester);
    expect(conto(tester),
        'Le gettate di oggi sono finite: si riparte domani.',
        reason: 'Dopo la gettata del giorno il conto non dice che si riparte '
            'domani.');
  });

  testWidgets('chi non ha limite non vede nessun conto', (tester) async {
    await monta(tester, piano: Tier.tier1);
    expect(find.byKey(const Key('rune_conto_gettate')), findsNothing,
        reason: 'Il Tier 1 ha le gettate illimitate: un contatore a '
            'infinito e\' rumore.');
    await getta(tester);
    expect(find.byKey(const Key('rune_conto_gettate')), findsNothing,
        reason: 'Dopo un getto il conto e\' comparso a chi non ha limite.');
  });
}
