import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **I PREZZI DEI PIANI STANNO INTERI.** Ordine EV voce 01, visto sul Realme
/// coi prezzi a 99: la casella della settimana diceva "SETTIM..." coi puntini
/// e quella dell'anno "189,99" con l'euro sulla riga sotto. Si misura, a 360
/// punti al carattere normale e al massimo, che ogni nome di periodo e ogni
/// prezzo stia su una riga e senza puntini.
void main() {
  for (final scala in [1.0, 1.3]) {
    testWidgets('a 360 punti, carattere $scala', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 6000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          builder: (c, w) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: TextScaler.linear(scala)),
              child: w!),
          home: const MaestroScope(child: PricingScreen(isDemo: true)),
        ),
      ));
      await tester.pump();
      final testi = find.byWidgetPredicate((w) =>
          w is Text &&
          w.key is ValueKey<String> &&
          ((w.key! as ValueKey<String>).value.startsWith('ciclo_')));
      final rotti = <String>[];
      for (final e in testi.evaluate()) {
        final p = e.renderObject! as RenderParagraph;
        final pittore = TextPainter(
          text: p.text,
          textDirection: TextDirection.ltr,
          textScaler: p.textScaler,
        )..layout(maxWidth: p.constraints.maxWidth);
        final righe = pittore.computeLineMetrics().length;
        pittore.dispose();
        final testo = (e.widget as Text).data!;
        if (p.didExceedMaxLines || righe > 1) rotti.add('$testo ($righe righe)');
      }
      // ignore: avoid_print
      print('ORDINE EV VOCE 01: a 360 punti, carattere $scala, nomi e prezzi '
          'dei periodi ${testi.evaluate().length}, tagliati o a capo '
          '${rotti.length} ${rotti.join(', ')}');
      expect(testi.evaluate().length, greaterThanOrEqualTo(18),
          reason: 'tre piani a pagamento, tre periodi, nome e prezzo');
      expect(rotti, isEmpty);
    });
  }
}
