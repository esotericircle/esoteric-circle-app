import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/settings/settings_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La schermata Impostazioni: gli interruttori funzionano, la cancellazione
/// GDPR chiede conferma con custodia e azzera davvero i dati, ed e'
/// raggiungibile dal Cosmic Passport.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Widget host(SettingsController settings, AppServices services) =>
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: const MaterialApp(home: MaestroScope(child: SettingsScreen())),
      );

  test('Riduci animazioni e Modalita semplice partono spenti', () {
    final s = SettingsController();
    expect(s.reduceAnimations, isFalse);
    expect(s.simpleMode, isFalse);
    // I sottotitoli, invece, sono attivi di default.
    expect(s.subtitles, isTrue);
  });

  testWidgets('Gli interruttori aggiornano le preferenze', (tester) async {
    silence();
    final settings = SettingsController();
    await tester.pumpWidget(host(settings, AppServices.offline()));
    await step(tester);

    expect(settings.reduceAnimations, isFalse);
    await tester.tap(find.byKey(const Key('settings_reduce')));
    await step(tester);
    expect(settings.reduceAnimations, isTrue);

    expect(settings.simpleMode, isFalse);
    await tester.tap(find.byKey(const Key('settings_simple')));
    await step(tester);
    expect(settings.simpleMode, isTrue);
  });

  testWidgets('La cancellazione GDPR chiede conferma e azzera i dati',
      (tester) async {
    silence();
    final repo = InMemoryMaestroMemoryRepository();
    await repo.saveProfile(UserProfile(displayName: 'Sofia'));
    await repo.appendMessage(
        Maestro.medora, const ChatMessage(role: ChatRole.user, text: 'ciao'));
    final services = AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: repo,
      memoryPersistent: false,
      diagnostics: 'test',
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(SettingsController(), services));
    await step(tester);

    // Tocca la riga: appare la conferma di custodia.
    await tester.tap(find.byKey(const Key('settings_delete')));
    await step(tester);
    expect(find.text('Cancellare i tuoi dati?'), findsOneWidget);

    // Conferma: i dati si azzerano davvero.
    await tester.tap(find.byKey(const Key('settings_delete_confirm')));
    await step(tester);
    expect((await repo.loadProfile()).displayName, isNull);
    expect(await repo.recentMessages(Maestro.medora), isEmpty);
  });

  testWidgets('E raggiungibile dal Cosmic Passport', (tester) async {
    silence();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    await tester.tap(find.text('Passport'));
    await step(tester);
    await tester.tap(find.byKey(const Key('passport_settings')));
    await step(tester);
    await step(tester);

    expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    expect(find.text('Impostazioni'), findsWidgets);
  });
}
