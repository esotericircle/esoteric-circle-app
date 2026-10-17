import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LE FONTI DEL VIAGGIO DICONO IL VERO.** Ordine FZ voce FZ.07, 17
/// ottobre 2026.
///
/// *"Il pannello 'Fonti e metodo' del Viaggio dice: la regola del
/// riconoscimento viene da Michael Harner [...] le tre ombre fra cui
/// scegliere sono il modo in cui l'app mette in scena il viaggio, che nella
/// tradizione è una visione libera. Esce ogni riga sul legame fra segno
/// solare e animale. Sullo stile in metallo non si scrive niente."*
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'IL FOGLIO CITA HARNER E LE QUATTRO APPARIZIONI, DICE CHE LE TRE OMBRE '
      'SONO MESSA IN SCENA, E NON NOMINA IL SEGNO SOLARE NE LO STILE IN '
      'METALLO', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.sagittarius,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(0),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final bottone = find.byKey(const Key('viaggio_fonti_bottone'));
    expect(bottone, findsOneWidget,
        reason: 'il bottone delle fonti non si trova nella barra');
    await tester.tap(bottone);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final foglio = find.byKey(const Key('viaggio_fonti'));
    expect(foglio, findsOneWidget);
    final testo = tester
        .widgetList<Text>(find.descendant(of: foglio, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join('\n');
    expect(testo, contains('Michael Harner'));
    expect(testo, contains('quattro volte'));
    expect(testo.toLowerCase(), contains('mette in scena il viaggio'),
        reason: 'il foglio non dice che le tre ombre sono la messa in '
            'scena dell\'app, non la tradizione');
    expect(testo.toLowerCase(), contains('visione libera'));
    for (final parola in ['solare', 'zodiac', 'metall']) {
      expect(testo.toLowerCase(), isNot(contains(parola)),
          reason: '"$parola" non deve comparire: niente legame fra segno '
              'solare e animale, niente dichiarazione sullo stile in metallo');
    }
  });
}
