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

/// **LE TRE OMBRE RIEMPIONO LA SCHERMATA.** Parola del fondatore, 19 ottobre
/// 2026, a video sul Realme: *"Le 3 ombre devi ingrandirle e metterle in
/// verticale, così riempi anche la schermata."* Affiancate in una `Row`,
/// ognuna aveva solo un terzo della larghezza e, essendo le sagome degli
/// animali piu' larghe che alte, restavano piccole con molto vuoto sopra e
/// sotto: impilate in una `Column`, ognuna ha l'intera larghezza e puo'
/// crescere.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'le tre ombre dell incontro stanno una sopra l altra, non una accanto all altra',
      (tester) async {
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
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(1),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));

    final treOmbre = find.byKey(const Key('viaggio_tre_ombre'));
    expect(treOmbre, findsOneWidget);
    expect(tester.widget(treOmbre), isA<Column>(),
        reason: 'le tre ombre stanno ancora fianco a fianco, non una sopra '
            'l\'altra');

    // **OGNUNA LARGA QUANTO LO SCHERMO**, non un terzo: e' la misura che
    // dice se davvero riempiono la schermata.
    final sagome = find.byKey(const Key('viaggio_ombra_vera'));
    expect(sagome, findsNWidgets(3));
    final primaLarghezza = tester.getSize(sagome.at(0)).width;
    expect(primaLarghezza, greaterThan(300),
        reason: 'una sagoma larga $primaLarghezza non riempie i 390 di '
            'larghezza dello schermo di prova');

    // **UNA SOPRA L'ALTRA**: la seconda sta piu' in basso della prima, non
    // alla sua destra.
    final centroUno = tester.getCenter(sagome.at(0));
    final centroDue = tester.getCenter(sagome.at(1));
    expect(centroDue.dy, greaterThan(centroUno.dy),
        reason: 'la seconda ombra non sta sotto la prima');
  });
}
