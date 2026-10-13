import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA TASTIERA NON TORNA DOPO LA SCELTA. Ordine FS, 13 ottobre 2026.**
///
/// Il fondatore, sulla build 2308, dopo due correzioni dichiarate (ordine FN
/// con `onTapDown`, ordine FR con `onOpened` e `onSelected`): scritta la
/// domanda e poi scelta una voce in chiave di lettura, mazzo o profondita',
/// "ogni volta che seleziono, la tastiera torna attiva". Le due prove di
/// prima leggevano il sorgente (che la riga ci fosse), mai il focus vero:
/// questa fa il gesto della persona e guarda chi ha il focus dopo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var setup = const TarotSetup();
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: Scaffold(
          body: MaestroScope(
            child: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: TarotSetupPanel(
                  setup: setup,
                  palette: context.palette,
                  aperto: true,
                  onChanged: (s) => setState(() => setup = s),
                  onLocked: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  bool campoAFuoco(WidgetTester tester) => tester
      .widget<EditableText>(find.descendant(
          of: find.byKey(const Key('stesa_domanda_scritta')),
          matching: find.byType(EditableText)))
      .focusNode
      .hasFocus;

  Future<void> scriviLaDomanda(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('stesa_domanda_scritta')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('stesa_domanda_scritta')),
        'Quando diventerò padre?');
    await tester.pump();
    expect(campoAFuoco(tester), isTrue,
        reason: 'il campo della domanda non ha preso il focus: la prova non '
            'parte dalla condizione del fondatore');
  }

  for (final caso in const [
    ('stesa_chiave', 'Riflessione'),
    ('stesa_depth', 'Lunga'),
    ('stesa_tipo', 'Una Carta'),
  ]) {
    testWidgets(
        'scritta la domanda, la scelta in ${caso.$1} non riporta su la '
        'tastiera', (tester) async {
      await monta(tester);
      await scriviLaDomanda(tester);
      await tester.tap(find.byKey(Key(caso.$1)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(caso.$2).last);
      await tester.pumpAndSettle();
      expect(campoAFuoco(tester), isFalse,
          reason: 'scelta "${caso.$2}" in ${caso.$1}, il campo della domanda '
              'ha ripreso il focus: e\' la tastiera che torna su');
      expect(tester.testTextInput.isVisible, isFalse,
          reason: 'la tastiera e\' ancora visibile dopo la scelta');
    });
  }

  testWidgets(
      'aperto e richiuso il menu senza scegliere, la tastiera non torna',
      (tester) async {
    await monta(tester);
    await scriviLaDomanda(tester);
    await tester.tap(find.byKey(const Key('stesa_chiave')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(campoAFuoco(tester), isFalse,
        reason: 'chiuso il menu senza scegliere, il campo della domanda ha '
            'ripreso il focus');
  });
}
