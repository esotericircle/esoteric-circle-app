import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';

/// IL DOPPIO TOCCO GIRA LA RUNA SULLA PIETRA, NON SOLO SUL RIQUADRO.
///
/// Ordine 2161, voce 8. Parole di Mauro: premere due volte sulla pietra non
/// funzionava, funzionava solo sul riquadro col testo. E' la regola della
/// promessa mantenuta: se un invito nomina un oggetto toccabile, l'area di
/// tocco copre QUELL'oggetto, non il cartello che lo nomina.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final ora = DateTime(2026, 8, 6, 21, 30);

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Widget host() => MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SunsetRuneScreen(now: ora, dataNascita: DateTime(1988, 7, 5)),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void grande(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> allaLettura(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    silenzia();
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await passo(tester);
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('sunset_voce_uno')), findsOneWidget,
        reason: 'La lettura non si e\' aperta: il resto non si puo\' provare.');
  }

  /// IL CENTRO DELLA PIETRA nella lettura: la pietra e' alta 168 e sta sopra
  /// il nome, staccata dal passo medio. Si misura dal nome, che ha la chiave,
  /// cosi' il punto e' quello geometrico vero anche senza chiavi sulla pietra.
  Offset centroPietra(WidgetTester tester) {
    final nome = tester.getRect(find.byKey(const Key('sunset_nome')));
    return Offset(nome.center.dx, nome.top - SpacingTokens.md - 84);
  }

  testWidgets('il doppio tocco AL CENTRO DELLA PIETRA gira la runa',
      (tester) async {
    await allaLettura(tester);
    expect(find.byKey(const Key('sunset_voce_due')), findsNothing);

    final punto = centroPietra(tester);
    await tester.tapAt(punto);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(punto);
    await passo(tester);

    expect(find.byKey(const Key('sunset_voce_due')), findsOneWidget,
        reason: 'Il doppio tocco sulla PIETRA non gira la runa: l\'invito '
            'nomina la pietra e l\'area di tocco sta altrove, che e\' '
            'esattamente cio\' che Mauro ha bocciato.');
  });

  testWidgets('il riquadro resta toccabile, come cortesia', (tester) async {
    await allaLettura(tester);
    final punto = tester.getCenter(find.byKey(const Key('sunset_gira_doppio')));
    await tester.tapAt(punto);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(punto);
    await passo(tester);
    expect(find.byKey(const Key('sunset_voce_due')), findsOneWidget);
  });

  testWidgets(
      'ogni invito del Tramonto che nomina la pietra si compie SULLA pietra',
      (tester) async {
    // L'ENUMERAZIONE DELLE PROMESSE: getto ("tocca la pietra"), incisione
    // ("tieni premuto sulla pietra"), lettura ("gira la pietra"). Ognuna si
    // agisce sul corpo della pietra, mai sul cartello che la nomina.
    SharedPreferences.setMockInitialValues({});
    silenzia();
    grande(tester);
    await tester.pumpWidget(host());
    await passo(tester);

    // 1. Il getto: tocca la pietra.
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await passo(tester);
    expect(find.byKey(const Key('sunset_incisione_gesture')), findsOneWidget,
        reason: 'Il tocco sulla pietra non ha gettato.');

    // 2. L'incisione: tenere premuto sulla pietra (qui col ripiego del
    // movimento ridotto, che e' un tocco: il flusso e' lo stesso gesto).
    await tester.tap(find.byKey(const Key('sunset_incisione_gesture')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('sunset_voce_uno')), findsOneWidget,
        reason: 'Il gesto sulla pietra non ha inciso.');

    // 3. La lettura: doppio tocco sulla pietra.
    final punto = centroPietra(tester);
    await tester.tapAt(punto);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(punto);
    await passo(tester);
    expect(find.byKey(const Key('sunset_voce_due')), findsOneWidget,
        reason: 'Il doppio tocco sulla pietra non l\'ha girata.');
  });
}
