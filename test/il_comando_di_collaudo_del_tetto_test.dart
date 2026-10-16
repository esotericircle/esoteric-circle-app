import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/il_tetto_delle_chiamate.dart';
import 'package:esoteric_circle/design_system/components/interruttore_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL COMANDO DI COLLAUDO CHE ALZA IL TETTO.** Ordine DL voce 14, 14
/// settembre 2026.
///
/// *"Un comando nella zona Demo che alza il tetto: solo nelle build di
/// collaudo, mai attivo da solo; mentre e' attivo ogni responso scrive nel
/// Diario la sua fonte; spento, il tetto torna quello di sempre senza
/// riavviare. Prova: fuori dalla Demo non si raggiunge."*
///
/// Il tetto che torna subito, e il comando che fuori dalla Demo non vale
/// anche acceso, li prova `i_limiti_del_viaggio_stanno_nella_matrice_test`;
/// qui la schermata.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => IlTettoDelleChiamate.alzatoPerIlCollaudo = false);

  Future<DiarioDelloSciamanoDiProva> apri(WidgetTester tester,
      {required bool demo}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelloSciamanoDiProva(1);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 14, 12),
            diario: diario,
            demo: demo,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return diario;
  }

  Future<void> scendiERisali(WidgetTester tester) async {
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
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_risali')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget);
  }

  testWidgets('FUORI DALLA DEMO IL COMANDO NON C E, e la riga delle fonti '
      'nemmeno, anche col comando acceso da un altro posto', (tester) async {
    final diario = await apri(tester, demo: false);
    expect(find.byKey(const Key('viaggio_tetto_del_collaudo')), findsNothing,
        reason: 'il comando di collaudo si raggiunge fuori dalla Demo');
    IlTettoDelleChiamate.alzatoPerIlCollaudo = true;
    await scendiERisali(tester);
    expect(find.byKey(const Key('viaggio_fonti_del_collaudo')), findsNothing);
    // **IL DIARIO SCRIVE LA FONTE SEMPRE**, in Demo e fuori: costa niente, e
    // chi riapre una discesa sa da dove veniva.
    expect(diario.viaggi.single.fonti, isNotEmpty);
  });

  testWidgets('IN DEMO IL COMANDO C E, PARTE SPENTO, e acceso fa leggere la '
      'fonte di ogni pezzo', (tester) async {
    final diario = await apri(tester, demo: true);
    final comando = find.byKey(const Key('viaggio_tetto_del_collaudo'));
    await tester.ensureVisible(comando);
    expect(comando, findsOneWidget);
    expect(tester.widget<InterruttoreDelCerchio>(comando).acceso, isFalse,
        reason: 'il comando parte acceso');
    expect(IlTettoDelleChiamate.alzatoPerIlCollaudo, isFalse);
    await tester.tap(comando);
    await tester.pump();
    expect(IlTettoDelleChiamate.alzatoPerIlCollaudo, isTrue);
    await tester.scrollUntilVisible(
        find.text('Una scelta da fare'), -200,
        scrollable: find.byType(Scrollable).first);
    await scendiERisali(tester);
    final fonti = find.byKey(const Key('viaggio_fonti_del_collaudo'));
    await tester.ensureVisible(fonti);
    final riga = tester.widget<Text>(fonti).data!;
    // ignore: avoid_print
    print('ORDINE DL VOCE 14: la riga delle fonti dice "$riga"');
    // Nelle prove il modello non c'e': tutto viene dalla riserva.
    expect(riga, contains('scena: riserva'));
    expect(riga, contains('titolo: riserva'));
    expect(riga, contains('gesto: riserva'));
    expect(diario.viaggi.single.fonti['scena'], 'riserva');
  });
}
