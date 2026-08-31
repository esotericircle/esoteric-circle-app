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
import 'package:esoteric_circle/design_system/components/riga_del_residuo.dart';
import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';

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
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance()..ilServerHaParlato()),
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

  /// **IL CONTO ADESSO E' LA RIGA COMUNE, ordine CF voce 11.** Le rune
  /// avevano un contatore scritto per loro sole, `_ContoDelleGettate`, con
  /// parole sue e senza la legge del silenzio. Adesso montano
  /// `RigaDelResiduo`, come gli altri cinque budget, e le parole sono quelle
  /// comuni: **"Ti resta 1 gettata di rune su 1, oggi"** invece di "Gettate di
  /// oggi: 1 di 1". Il cambio di parole e' la conseguenza voluta di avere una
  /// porta sola, e va dichiarato al fondatore.
  String conto(WidgetTester tester) {
    final riga = find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.gettate));
    if (riga.evaluate().isEmpty) return '';
    final testi = find
        .descendant(of: riga.first, matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty);
    return testi.isEmpty ? '' : testi.first;
  }

  // I DUE STATI DEL CONTO, e sono due perche' il limite e' UNO dall'ordine O
  // del 12 agosto 2026, per decisione di Mauro: erano tre dall'ordine I.
  // Con una gettata sola il passo intermedio non esiste piu' nel dato, e
  // pretenderlo vorrebbe dire pretendere un numero che nessuno promette.
  testWidgets('i due stati del conto: pieno e finito', (tester) async {
    await monta(tester, piano: Tier.free);
    // Sempre presente per chi ha un limite, gia' prima del primo getto.
    expect(conto(tester), 'Ti resta 1 gettata di rune su 1, oggi',
        reason: 'Prima del primo getto il conto non dice uno su uno.');
    await getta(tester);
    expect(conto(tester), 'Non ti resta nessuna gettata di rune, oggi',
        reason: 'Dopo la gettata del giorno il conto non dice che non ne '
            'resta nessuna.');
  });

  testWidgets('adesso anche il Tier 1 vede il suo conto', (tester) async {
    // **NON C\'E\' PIU\' NESSUNO SENZA LIMITE, ordine CE voce 08.** Questa
    // prova difendeva il silenzio per chi aveva le gettate illimitate: da
    // quando l\'illimitato non esiste, quel silenzio sarebbe un conto
    // nascosto. Il Tier 1 ha venti gettate al giorno e le vede.
    await monta(tester, piano: Tier.tier1);
    expect(find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.gettate)),
        findsWidgets,
        reason: 'il Tier 1 ha un tetto e non lo vede');
  });
}
