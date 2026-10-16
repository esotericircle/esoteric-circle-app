import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA PORTA PICCOLA PER CHI TORNA. Ordine AP voce 04.
///
/// **La decisione di Mauro del 18 agosto**: nessun muro di accesso alla prima
/// apertura. La prima schermata resta il risveglio, e la via per chi torna e'
/// una porta piccola, non un modulo. La riga e' "Faccio gia' parte del
/// Cerchio", con sotto la riga di servizio smorzata "Accedi e ritrova il tuo
/// cammino".
///
/// **Cosa misura questa guardia, e perche' guarda anche l'ORDINE.** Che la
/// porta ci sia e' facile; che resti PICCOLA lo e' meno, ed e' la parte che
/// si rompe per prima. Qui si pretende che il richiamo principale resti
/// "Inizia il rito" e che la porta stia sotto: se un giorno qualcuno le
/// invertisse, chi arriva per la prima volta si troverebbe davanti un
/// accesso, cioe' il muro che la decisione ha escluso.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OnboardingScreen(clock: () => DateTime(2026, 8, 19)),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('sulla prima schermata la porta c\'e\', con le due righe',
      (tester) async {
    await apri(tester);
    final porta = find.byKey(const Key('onboarding_porta_per_chi_torna'));
    expect(porta, findsOneWidget,
        reason: 'chi torna non ha nessuna via sulla prima schermata, e per '
            'ritrovare il suo cammino dovrebbe rifare tutto il rito');
    final righe = tester
        .widgetList<Text>(
            find.descendant(of: porta, matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    // ignore: avoid_print
    print('ORDINE AP VOCE 04: la porta dice $righe');
    expect(
        righe,
        [
          'Faccio già parte del Cerchio',
          'Accedi e ritrova il tuo cammino',
        ],
        reason: 'i testi non sono quelli decisi da Mauro: $righe');
  });

  testWidgets('NON e\' un muro: il richiamo principale resta il rito',
      (tester) async {
    await apri(tester);
    final rito = find.text('Inizia il rito');
    final porta = find.byKey(const Key('onboarding_porta_per_chi_torna'));
    expect(rito, findsOneWidget,
        reason: 'il richiamo principale non c\'e\' piu\': chi arriva per la '
            'prima volta non sa piu\' da dove si comincia');

    // **L'ORDINE VISIVO, misurato e non presunto**: il rito sta SOPRA, la
    // porta sotto. Invertirli farebbe della porta il richiamo principale, e
    // la prima apertura diventerebbe un accesso.
    final quotaRito = tester.getCenter(rito).dy;
    final quotaPorta = tester.getCenter(porta).dy;
    // ignore: avoid_print
    print('ORDINE AP VOCE 04: rito a ${quotaRito.toStringAsFixed(0)}, porta '
        'a ${quotaPorta.toStringAsFixed(0)}');
    expect(quotaRito, lessThan(quotaPorta),
        reason: 'la porta per chi torna sta sopra il richiamo principale: e\' '
            'diventata lei il richiamo, cioe\' il muro che la decisione di '
            'Mauro ha escluso');

    // E resta piu' smorzata: la riga di servizio non grida quanto il rito.
    final testoRito = tester.widget<Text>(find.text('Inizia il rito'));
    final servizio =
        tester.widget<Text>(find.text('Accedi e ritrova il tuo cammino'));
    expect(servizio.style?.fontSize ?? 99,
        lessThanOrEqualTo(testoRito.style?.fontSize ?? 0),
        reason: 'la riga di servizio della porta e\' grande quanto il '
            'richiamo principale');
  });

  testWidgets('chi arriva per la prima volta prosegue senza notarla',
      (tester) async {
    // Il rito comincia toccando il richiamo principale, e la porta non
    // intercetta niente: se lo facesse, la prima apertura porterebbe a un
    // accesso invece che al Risveglio.
    await apri(tester);
    await tester.tap(find.text('Inizia il rito'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(
        find.byKey(const Key('onboarding_porta_per_chi_torna')), findsNothing,
        reason: 'la porta segue chi ha gia'
            'cominciato il rito: e\' una '
            'via per chi torna, non un ripensamento a ogni passo');
  });
}
