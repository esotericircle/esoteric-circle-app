import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il passo dell'ora deve essere usabile appena si arriva.
///
/// I due selettori nascevano spenti: la condizione era `_timeKnown == true`,
/// ma `_timeKnown` parte nullo, perche' ne' "la so" ne' "non la so" sono
/// preselezionate. Risultato: si arrivava su due pillole grigie con dentro 12
/// e 00, che non si potevano toccare e che per giunta dichiaravano un'ora che
/// nessuno aveva scelto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> alPassoOra(WidgetTester tester, {double altezza = 2392}) async {
    silence();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OnboardingScreen(clock: () => DateTime(2026, 7, 15)),
      ),
    ));
    await tester.pumpAndSettle();
    // accoglienza -> data -> ora
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(const Key('onboarding_continue')).last);
      await tester.pumpAndSettle();
    }
  }

  DropdownButton<int> ruota(WidgetTester tester, String key) =>
      tester.widget<DropdownButton<int>>(find.byKey(Key(key)));

  testWidgets('I selettori si possono toccare appena si arriva',
      (tester) async {
    await alPassoOra(tester);

    expect(ruota(tester, 'risveglio_ora').onChanged, isNotNull,
        reason: 'il selettore delle ore nasce spento: non si puo\' scegliere '
            'l\'ora senza prima passare da "Non la so"');
    expect(ruota(tester, 'risveglio_minuto').onChanged, isNotNull,
        reason: 'il selettore dei minuti nasce spento');
  });

  testWidgets('Prima di scegliere si legge Ora e Minuti, non 12 e 00',
      (tester) async {
    await alPassoOra(tester);

    expect(find.text('Ora'), findsOneWidget,
        reason: 'la pillola non invita a scegliere l\'ora');
    expect(find.text('Minuti'), findsOneWidget,
        reason: 'la pillola non invita a scegliere i minuti');
    expect(find.text('12'), findsNothing,
        reason: 'la pillola dichiara mezzogiorno, che nessuno ha scelto');
    expect(find.text('00'), findsNothing,
        reason: 'la pillola dichiara zero minuti, che nessuno ha scelto');
  });

  testWidgets('Scegliendo l\'ora il rito la considera saputa', (tester) async {
    await alPassoOra(tester);

    await tester.tap(find.byKey(const Key('risveglio_ora')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('07').last);
    await tester.pumpAndSettle();

    expect(find.text('07'), findsWidgets,
        reason: 'l\'ora scelta non compare nella pillola');
    // Scegliere l'ora vuol dire saperla: la nota del ripiego sparisce.
    expect(find.textContaining('senza l\'ora'), findsNothing);
  });

  // Le due altezze si provano in due prove separate: rimontare due volte
  // dentro la stessa prova non riparte pulito, e il verde che ne uscirebbe
  // direbbe piu' sul test che sullo schermo.
  for (final h in const [2532.0, 2392.0]) {
    testWidgets('A $h i selettori sono usabili e invitano', (tester) async {
      await alPassoOra(tester, altezza: h);
      expect(ruota(tester, 'risveglio_ora').onChanged, isNotNull,
          reason: 'a $h i selettori nascono spenti');
      expect(find.text('Ora'), findsOneWidget, reason: 'a $h manca l\'invito');
    });
  }
}
