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
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **SCEGLIERE LA GETTATA NON GETTA.** Ordine CQ voce 1.06, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"cliccando sul tipo di gettata parte
/// subito il responso, deve richiedere il pulsante getta ancora."*
///
/// **La provenienza e' l'ordine BF voce 05.a**, che aveva deciso il contrario
/// per una ragione buona: dal responso si cambia stesa senza tornare
/// indietro. Il difetto non era tenere le pillole, era **farle gettare**: chi
/// scorre le tre stese per leggere cosa sono si trova il responso partito, e
/// una gettata consumata, prima di aver scelto niente.
///
/// **Il gesto che costa dev'essere quello che si preme apposta.** E' la stessa
/// legge dell'ordine CQ voce 1.03 sui tarocchi, e nasce dallo stesso giro di
/// prova del fondatore.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<QuestionAllowance> monta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final borsa = QuestionAllowance()..ilServerHaParlato();
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
            create: (_) => EntitlementService(initial: Tier.tier3)),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
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
    return borsa;
  }

  Future<void> premi(WidgetTester tester, Key chiave) async {
    await tester.ensureVisible(find.byKey(chiave));
    await tester.pump();
    await tester.tap(find.byKey(chiave), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// Le pillole a video, una per gettata del corpus, per chiave.
  Finder pillolaDi(GettataRune g) => find.byKey(Key('rune_segment_${g.id}'));

  testWidgets('dal responso, toccare una pillola non consuma e non rigetta',
      (tester) async {
    final borsa = await monta(tester);
    await premi(tester, const Key('rune_cast_button'));
    final dopoLaPrima = borsa.gettateSpese;
    expect(find.byKey(const Key('rune_recast')), findsOneWidget,
        reason: 'il responso non e arrivato: la prova non misura niente');

    // Le altre due gettate del corpus, toccate una per una.
    final altre = gettate.where((g) => g.id != gettate.first.id).toList();
    cardinaleMinimo(altre.length, 2,
        cosa: 'gettate diverse da quella di partenza',
        perche: 'Con una gettata sola non ci sarebbe nessuna pillola da '
            'toccare, e la prova sarebbe verde senza aver toccato niente.');
    final spese = <String, int>{};
    for (final g in altre) {
      final pillola = pillolaDi(g);
      if (pillola.evaluate().isEmpty) continue;
      await tester.ensureVisible(pillola.first);
      await tester.pump();
      await tester.tap(pillola.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));
      spese[g.nome] = borsa.gettateSpese;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.06: gettate spese dopo la prima $dopoLaPrima, e '
        'toccando le pillole $spese');
    cardinaleMinimo(spese.length, 2,
        cosa: 'pillole toccate a video',
        perche: 'Se le pillole non fossero montate, il ciclo non toccherebbe '
            'niente e la prova sarebbe verde.');
    for (final voce in spese.entries) {
      expect(voce.value, dopoLaPrima,
          reason: 'toccare "${voce.key}" ha consumato una gettata: la scelta '
              'getta da sola, ed e il difetto che questa voce chiude');
    }
  });

  testWidgets('e il pulsante, invece, getta', (tester) async {
    final borsa = await monta(tester);
    await premi(tester, const Key('rune_cast_button'));
    final prima = borsa.gettateSpese;
    await premi(tester, const Key('rune_recast'));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.06: gettate spese prima del pulsante $prima, '
        'dopo ${borsa.gettateSpese}');
    expect(borsa.gettateSpese, prima + 1,
        reason: 'il pulsante Getta ancora non getta piu: con la scelta che non '
            'getta e il pulsante che non getta, dal responso non si '
            'rigetterebbe in nessun modo');
  });

  testWidgets('le pillole stanno sopra il pulsante, non sotto',
      (tester) async {
    await monta(tester);
    await premi(tester, const Key('rune_cast_button'));
    final pulsante = tester.getRect(find.byKey(const Key('rune_recast')));
    final pillola = pillolaDi(gettate.first);
    expect(pillola, findsWidgets,
        reason: 'le pillole non sono montate nel responso');
    final riquadro = tester.getRect(pillola.first);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.06: le pillole stanno a ${riquadro.top.round()}, '
        'il pulsante a ${pulsante.top.round()}');
    expect(riquadro.top, lessThan(pulsante.top),
        reason: 'le pillole stanno sotto il pulsante: potevano starci finche '
            'toccarle gettava da sole, cioe finche erano una scorciatoia. '
            'Adesso sono il primo dei due gesti, e un gesto che viene prima '
            'si legge prima');
  });
}
