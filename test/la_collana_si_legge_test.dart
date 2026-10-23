import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL TESTO DELLA COLLANA SI LEGGE.** Ordine FY voce FY.08, 16 ottobre
/// 2026. Il fondatore: "La collana della luna è tagliata ai lati e il testo è
/// illeggibile" (cattura `docs/collaudo/FY/catture_fondatore/
/// fy_fondatore_07.jpg`).
///
/// Si misura la grandezza VERA a cui ogni testo della Collana arriva sullo
/// schermo, cioe' la misura del carattere per la scala con cui il
/// `FittedBox` lo rimpicciolisce: nel velluto la guida finiva a 6 o 7 punti.
/// Ogni testo deve arrivare almeno a 12 punti (il pavimento della
/// tipografia dell'app) a 320, 360, 390 e 430 punti.
void main() {
  for (final larghezza in const [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('ogni testo della Collana si legge, $larghezza punti',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(larghezza, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
        child: MaterialApp(
          home: MaestroScope(
              child: LaCollanaDelleLuneScreen(now: DateTime(2026, 10, 16, 9))),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final piccoli = <String>[];
      var guardati = 0;
      for (final chiave in const [
        'collana_nome_ciclo',
        'collana_conteggio',
        'collana_perla_di_oggi',
        'collana_obiettivo',
      ]) {
        final testo = find.byKey(Key(chiave));
        expect(testo, findsOneWidget, reason: '$chiave non c\'e\'');
        final p = tester.renderObject<RenderParagraph>(
            find.descendant(of: testo, matching: find.byType(RichText)));
        // La scala vera: la larghezza a schermo divisa per quella del testo.
        final aSchermo = tester.getRect(testo).width;
        final scala = p.size.width == 0 ? 1.0 : aSchermo / p.size.width;
        final misura = (p.text.style?.fontSize ?? 14) * scala;
        guardati++;
        if (misura < 12) {
          piccoli.add('$chiave: ${misura.toStringAsFixed(1)} punti');
        }
      }
      expect(guardati, 4);
      expect(piccoli, isEmpty,
          reason: 'testi della Collana sotto i 12 punti a schermo: $piccoli');
    });
  }
}
