import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LE ETICHETTE DELLA CROCE CELTICA NON SPEZZANO LE PAROLE.** Ordine FS,
/// 13 ottobre 2026.
///
/// Visto sul Realme con dieci carte in piedi: "IL FONDA / MENTO", "CIÒ CHE
/// ATTRAVE / RSA", "SPERANZ / E O / TIMORI". Il testo era chiuso nella
/// larghezza della carta, piu' stretta delle parole lunghe, e Flutter le
/// spezzava a meta'. Qui ogni parola di ogni etichetta deve stare su una
/// riga sola.
void main() {
  testWidgets('ogni parola delle dieci etichette sta su una riga',
      (tester) async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(
          child: StesaTreCarteScreen(
            seed: 2,
            revealAll: true,
            skipIntro: true,
            topic: TarotTopic.momentoCheVivo,
            tipo: TarotSpreadType.dieciCarte,
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    final spezzate = <String>[];
    var parole = 0;
    for (final pos in TarotSpreadType.dieciCarte.posizioni.toSet()) {
      final trovata = find.byKey(Key('stesa_etichetta_${pos.name}'));
      if (trovata.evaluate().isEmpty) continue;
      final paragrafo = tester.renderObject<RenderParagraph>(find.descendant(
          of: trovata.first, matching: find.byType(RichText)).first);
      final testo = paragrafo.text.toPlainText();
      var inizio = 0;
      for (final parola in testo.split(' ')) {
        final fine = inizio + parola.length;
        if (parola.isNotEmpty) {
          parole++;
          final righe = paragrafo
              .getBoxesForSelection(
                  TextSelection(baseOffset: inizio, extentOffset: fine))
              .map((b) => b.top.round())
              .toSet();
          if (righe.length > 1) spezzate.add('$parola in "$testo"');
        }
        inizio = fine + 1;
      }
    }
    cardinaleMinimo(parole, 20,
        cosa: 'parole delle etichette guardate',
        perche: 'Senza etichette a video la prova non guarderebbe niente e '
            'sarebbe verde.');
    expect(spezzate, isEmpty,
        reason: 'PAROLE SPEZZATE A META\' nelle etichette: $spezzate');
  });
}
