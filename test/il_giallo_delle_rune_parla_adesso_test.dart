import 'dart:math' as math;

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
        home: RuneDrawScreen(random: math.Random(3)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_cast_button')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
  }

  // **L'ORDINE GA, voce GA.03, 20 ottobre 2026: L'ORO E' DEI RIQUADRI.**
  // Il fondatore, 19 ottobre 2026 alle 23:08: *"Per le risposte brevi 2
  // paragrafi di cui il secondo messo in evidenza in un riquadro e questo
  // riquadro deve intitolarsi 'cosa fare adesso'"*, e la forma vive in un
  // punto solo per le quattro arti (`IlResponsoInterpretato`). In quella
  // forma il riquadro "Cosa fare adesso" e' dorato nel bordo e nel titolo,
  // e la prosa dentro e' dello stesso colore di quella fuori.
  //
  // **Cosa pretendeva questa guardia e perche' e' caduta.** Pretendeva UNA
  // prosa dorata, quella dell'azione dentro `rune_presage_azione`. E' caduta
  // prima ancora del codice nuovo, il 20 ottobre 2026: il GESTO riscritto a
  // quaranta-cinquanta parole (ordine GA voce GA.07, commit fae20893) si
  // spezzava in due paragrafi dorati nello stesso riquadro, e la guardia ne
  // contava due. Col codice nuovo ne conterebbe zero.
  //
  // **Cosa resta vero della richiesta dell'ordine DD voce 11**: il giallo e'
  // solo per cio' che parla adesso, e quella frase sta in un riquadro. Le
  // due prove qui sotto lo misurano nella forma nuova: nessuna prosa dorata
  // in tutta la lettura (l'oro non si spalma sulle frasi), e ogni oro di
  // lettura e' il titolo di un riquadro "Cosa fare adesso" che ha dentro la
  // sua prosa.
  testWidgets('LA PROSA DORATA E NESSUNA: l\'oro sta nei riquadri',
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
        perche: 'Con due o tre frasi questa prova direbbe che l oro non c e '
            'per non aver quasi guardato la lettura.');

    final dorate = [
      for (final e in prose.entries)
        if (e.value == palette.goldSoft || e.value == palette.gold)
          e.key.length > 40 ? '${e.key.substring(0, 40)}...' : e.key,
    ];
    // ignore: avoid_print
    print('ORDINE GA VOCE 03: prose nel responso $guardati, dorate '
        '${dorate.length} -> $dorate');
    expect(dorate, isEmpty,
        reason: 'nel responso delle Rune ci sono prose dorate: nella forma '
            'comune l oro e del riquadro "Cosa fare adesso", non delle '
            'frasi. Dorate: ${dorate.join(" | ")}');
  });

  testWidgets(
      'REGOLA H: ogni riquadro "Cosa fare adesso" ha il titolo dorato e la '
      'sua prosa dentro', (tester) async {
    // **La meta opposta.** Togliere l oro da tutto passerebbe la prima prova
    // e lascerebbe la lettura senza nessun richiamo: qui si pretende che il
    // riquadro di cio' che parla adesso ci sia, col suo titolo dorato, e che
    // dentro ci sia la sua prosa.
    await monta(tester);
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final titoli = find.text('Cosa fare adesso');
    var guardati = 0;
    for (final t in tester.widgetList<Text>(titoli)) {
      guardati++;
      expect(
          t.style?.color == palette.gold || t.style?.color == palette.goldSoft,
          isTrue,
          reason: 'il titolo del riquadro "Cosa fare adesso" non e dorato');
    }
    cardinaleMinimo(guardati, 1,
        cosa: 'riquadri "Cosa fare adesso" nel responso delle Rune',
        perche: 'il responso principale ne ha sempre uno');
    final riquadro = find.byKey(const Key('rune_presage_cosa_fare'));
    expect(riquadro, findsOneWidget,
        reason: 'il riquadro attorno alla frase che parla adesso non c e piu');
    final prosa = tester
        .widgetList<Text>(
            find.descendant(of: riquadro, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' ');
    // ignore: avoid_print
    print('ORDINE GA VOCE 03: riquadri "Cosa fare adesso" $guardati, prosa '
        'del riquadro del presagio ${prosa.split(' ').length} parole');
    expect(prosa.trim(), isNotEmpty, reason: 'il riquadro dell azione e vuoto');
  });
}
