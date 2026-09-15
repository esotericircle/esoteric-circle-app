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
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL GIALLO DELLE RUNE PARLA ADESSO.** Ordine DD voce 11, 10 settembre
/// 2026.
///
/// **La richiesta del fondatore**: nelle bolle delle Rune il giallo deve
/// restare **solo per cio' che parla all'utente adesso**, e quella frase deve
/// stare **in un riquadro**. Senza aggiungere testo.
///
/// **Cosa c'era.** Tre prose dorate nella stessa lettura: il primo paragrafo
/// del presagio, la riga dell'azione dentro il suo riquadro, e la giuntura
/// delle Norne sopra ogni scheda. **Tre richiami d'oro nella stessa colonna
/// non sono una gerarchia**: sono tre voci che alzano la mano insieme, e chi
/// legge non sa a quale rispondere.
///
/// **QUESTA GUARDIA CONTA LE PROSE DORATE A VIDEO**, non le righe di codice:
/// si guarda ogni testo montato nel ruolo `lettura`, si legge il suo colore, e
/// si pretende che i dorati siano **uno solo**, quello dentro il riquadro
/// dell'azione.
///
/// **I titoli e le etichette non contano, ed e' una scelta dichiarata.** Il
/// nome della runa, il titolo del presagio e quello del sigillo sono
/// *insegne*: dicono dove sei, non cosa fare, e il loro oro e' la livrea di
/// Caligo. La richiesta del fondatore riguarda le frasi che si leggono, ed e'
/// quelle che questa guardia misura.
void main() {
  Future<void> monta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
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
            create: (_) => EntitlementService(initial: Tier.tier2)),
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
    await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_cast_button')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('LA PROSA DORATA E UNA SOLA, ed e quella del riquadro',
      (tester) async {
    await monta(tester);
    expect(find.byKey(const Key('rune_result')), findsOneWidget,
        reason: 'la gettata non ha prodotto nessun responso: questa prova non '
            'ha bolle da guardare');

    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final misuraDiLettura = TypographyTokens.lettura().fontSize;

    // Ogni testo montato NEL RUOLO LETTURA, cioe' la prosa: i titoli e le
    // etichette hanno altre misure e restano fuori per costruzione.
    final prose = <String, Color?>{};
    var guardati = 0;
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final stile = t.style;
      if (stile == null || t.data == null || t.data!.trim().isEmpty) continue;
      if (stile.fontSize != misuraDiLettura) continue;
      guardati++;
      prose[t.data!] = stile.color;
    }
    cardinaleMinimo(guardati, 3,
        cosa: 'prose nel ruolo lettura montate nel responso delle Rune',
        perche: 'Con due o tre frasi questa prova direbbe che l oro e uno '
            'solo per non aver quasi guardato la lettura.');

    final dorate = [
      for (final e in prose.entries)
        if (e.value == palette.goldSoft || e.value == palette.gold)
          e.key.length > 40 ? '${e.key.substring(0, 40)}...' : e.key,
    ];
    // ignore: avoid_print
    print('ORDINE DD VOCE 11: prose nel responso $guardati, dorate '
        '${dorate.length} -> $dorate');
    expect(dorate.length, 1,
        reason: 'le prose dorate nel responso delle Rune sono '
            '${dorate.length} invece di una: piu ori nella stessa colonna non '
            'sono una gerarchia, sono piu voci che alzano la mano insieme. '
            'Dorate: ${dorate.join(" | ")}');
  });

  testWidgets('REGOLA H: e quella prosa sta DENTRO il riquadro',
      (tester) async {
    // **La meta opposta.** Togliere l oro da tutto passerebbe la prima prova
    // e lascerebbe la lettura senza nessun richiamo: qui si pretende che
    // l unica prosa dorata sia proprio quella dell azione, e che il suo
    // riquadro ci sia.
    await monta(tester);
    final riquadro = find.byKey(const Key('rune_presage_azione'));
    expect(riquadro, findsOneWidget,
        reason: 'il riquadro attorno alla frase che parla adesso non c e piu');

    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final misuraDiLettura = TypographyTokens.lettura().fontSize;
    var doratiDentro = 0;
    for (final t in tester.widgetList<Text>(
        find.descendant(of: riquadro, matching: find.byType(Text)))) {
      if (t.style?.fontSize != misuraDiLettura) continue;
      if (t.style?.color == palette.goldSoft ||
          t.style?.color == palette.gold) {
        doratiDentro++;
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 11: prose dorate dentro il riquadro $doratiDentro');
    expect(doratiDentro, greaterThanOrEqualTo(1),
        reason: 'dentro il riquadro dell azione non c e nessuna prosa dorata: '
            'l oro e stato tolto anche a cio che deve parlare adesso');
  });
}
