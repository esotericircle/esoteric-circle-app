import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "Chiedi ai Maestri": scelta di uno, due o tre Maestri, con sintesi
/// comparativa in testa quando sono piu' di uno. Stati coperti.
void main() {
  Widget host() => ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: const MaterialApp(
          home: MaestroScope(child: AskMaestriScreen()),
        ),
      );

  testWidgets('Parte dallo stato vuoto', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.byKey(const Key('ask_empty')), findsOneWidget);
    expect(find.byKey(const Key('ask_results')), findsNothing);
  });

  testWidgets('Con tre Maestri mostra la sintesi comparativa e tre lenti',
      (tester) async {
    // Superficie alta: cosi' la lista costruisce tutte e tre le lenti insieme.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await tester.pump();

    await tester.enterText(find.byKey(const Key('ask_field')), 'una scelta d\'amore');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pump();

    // La sintesi comparativa in testa e una lente per Maestro.
    expect(find.byKey(const Key('ask_synthesis')), findsOneWidget);
    for (final m in Maestro.values) {
      expect(find.byKey(Key('ask_lens_${m.id}')), findsOneWidget,
          reason: 'manca la lente di ${m.id}');
    }
    expect(find.text('Sintesi comparativa'), findsOneWidget);
  });

  testWidgets('Con un solo Maestro niente sintesi, una sola lente',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    // Deseleziono Aura e Caligo: resta solo Medora.
    await tester.tap(find.byKey(const Key('ask_chip_aura')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_chip_caligo')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('ask_field')), 'il lavoro');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pump();

    expect(find.byKey(const Key('ask_synthesis')), findsNothing);
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
    expect(find.byKey(const Key('ask_lens_aura')), findsNothing);
    expect(find.byKey(const Key('ask_lens_caligo')), findsNothing);
  });

  testWidgets('Non si puo\' restare senza Maestri: l\'ultimo resta scelto',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    // Provo a deselezionarli tutti e tre.
    await tester.tap(find.byKey(const Key('ask_chip_aura')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_chip_caligo')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_chip_medora')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('ask_field')), 'la fortuna');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ask_submit')));
    await tester.pump();

    // Medora, l'ultimo, non si e' potuto togliere: la lettura esce lo stesso.
    expect(find.byKey(const Key('ask_lens_medora')), findsOneWidget);
  });
}
