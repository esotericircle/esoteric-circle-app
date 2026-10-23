// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **IL NOME DEL PIANO NON SI SPEZZA IN MEZZO.** Ordine EU voce 07, visto sul
/// Realme il 1 ottobre 2026.
///
/// Col Viandante scelto dal telefono nella demo (*"Per ora è necessario
/// rendere disponibile il cambio di abbonamento in "viandante" per fare le
/// prove."*) la sua scheda porta il badge "Piano Attuale", e accanto al badge
/// il nome andava a capo dentro la parola: "VIANDA / NTE". Prima della voce
/// EU.07 il Viandante non portava mai il badge nella demo.
///
/// Si misura, per ogni piano attivo, a 360 punti e al carattere normale e
/// massimo (1,3, il tetto dell'app): le righe del nome che cominciano dentro
/// una parola (0).
void main() {
  Widget conPiano(Tier tier, double scala) {
    final servizio = EntitlementService()..setTier(tier);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: servizio),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data:
              MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: const PricingScreen(isDemo: true),
      ),
    );
  }

  /// Le posizioni del testo dove comincia una riga dentro una parola.
  List<int> taglliInMezzo(RenderParagraph r, String testo) {
    // La riga di un carattere e' l'altezza del suo riquadro: dove cambia fra
    // due lettere di fila, li' il testo e' andato a capo.
    double alto(int k) => r
        .getBoxesForSelection(TextSelection(baseOffset: k, extentOffset: k + 1))
        .first
        .top;
    final tagli = <int>[];
    for (var k = 1; k < testo.length; k++) {
      if (testo[k - 1] == ' ' || testo[k] == ' ') continue;
      if ((alto(k) - alto(k - 1)).abs() > 1) tagli.add(k);
    }
    return tagli;
  }

  final spezzati = <String>[];
  var guardati = 0;
  for (final scala in const [1.0, 1.3]) {
    for (final tier in Tier.values) {
      testWidgets('il nome del piano ${tier.name} attivo alla scala $scala',
          (t) async {
        t.view.physicalSize = const Size(1080, 7000);
        t.view.devicePixelRatio = 3.0;
        addTearDown(t.view.reset);
        await t.pumpWidget(conPiano(tier, scala));
        await t.pump();
        final carta = find.byKey(Key('plan_${tier.name}'));
        await t.scrollUntilVisible(carta, 400,
            scrollable: find.byType(Scrollable).first, maxScrolls: 30);
        await t.pump();
        final nome = PlanCatalog.forTier(tier).name;
        final testo = find.descendant(of: carta, matching: find.text(nome));
        expect(testo, findsOneWidget, reason: 'il nome $nome non c\'e\'');
        expect(find.descendant(of: carta, matching: find.text('Piano Attuale')),
            findsOneWidget,
            reason: 'il piano attivo $nome non porta il badge');
        final r = t.renderObject<RenderParagraph>(find.descendant(
            of: testo, matching: find.byType(RichText), matchRoot: true));
        guardati++;
        final tagli = taglliInMezzo(r, nome);
        if (tagli.isNotEmpty) {
          spezzati.add('$nome alla scala $scala, a capo dopo '
              '"${nome.substring(0, tagli.first)}"');
        }
      });
    }
  }

  tearDownAll(() => print('ORDINE EU VOCE 07: nomi dei piani attivi spezzati '
      'dentro una parola ${spezzati.length} su $guardati'));

  test('i conti', () {
    cardinaleMinimo(guardati, 8, cosa: 'schede dei piani attivi guardate');
    expect(spezzati, isEmpty, reason: spezzati.join('\n'));
  });
}
