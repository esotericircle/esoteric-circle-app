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

  testWidgets('L\'interruttore degli effetti sonori c\'e\', si tocca e obbedisce',
      (tester) async {
    // **ORDINE BX VOCE 05.** L\'ordine chiede che nelle impostazioni esista un
    // comando che disattiva gli effetti sonori. Qui si misura a schermo: la
    // riga c\'e\', il tocco cambia la preferenza, e quando l\'interruttore
    // grande e\' spento questa riga non si puo\' piu\' toccare, perche\' sotto un
    // silenzio gia\' deciso non c\'e\' piu\' niente da scegliere.
    silence();
    final settings = SettingsController();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(settings, AppServices.offline()));
    await step(tester);

    final riga = find.byKey(const Key('settings_effetti_sonori'));
    await tester.scrollUntilVisible(riga, 150,
        scrollable: find.byType(Scrollable).first);
    // `scrollUntilVisible` si ferma appena il widget esiste, e puo' esistere
    // ancora sotto il bordo: misurato, il tocco cadeva a 870 su uno schermo
    // alto 844. `ensureVisible` lo porta davvero dentro.
    await tester.ensureVisible(riga);
    await step(tester);
    expect(riga, findsOneWidget,
        reason: 'nelle impostazioni non c\'e\' il comando degli effetti sonori');
    // **SI PARTE DA SPENTO, dalla voce BZ.05**, parole del fondatore: "gli
    // effetti sonori vanno per ora disabilitati per default". Questa prova
    // non misura il valore di partenza, che ha la sua guardia in
    // test/ogni_responso_ha_la_sua_voce_test.dart: misura che la riga
    // OBBEDISCA, e per misurarlo la si tocca due volte.
    expect(settings.effettiSonori, isFalse,
        reason: 'gli effetti sonori non nascono piu\' spenti');
    await tester.tap(riga);
    await step(tester);
    // ignore: avoid_print
    print('ORDINE BX VOCE 5: toccata la riga, gli effetti sonori sono '
        '${settings.effettiSonori ? "accesi" : "spenti"}');
    expect(settings.effettiSonori, isTrue,
        reason: 'la riga degli effetti sonori non accende niente');
    await tester.tap(riga);
    await step(tester);
    expect(settings.effettiSonori, isFalse,
        reason: 'la riga degli effetti sonori non spegne niente');

    // Spento l\'interruttore unico, questa riga non comanda piu\'.
    settings.setEffettiSonori(true);
    settings.setSuonoEVibrazione(false);
    await step(tester);
    await tester.ensureVisible(riga);
    final interruttore = tester.widget<Switch>(riga);
    // ignore: avoid_print
    print('ORDINE BX VOCE 5: col livello sensoriale spento la riga e\' '
        '${interruttore.onChanged == null ? "ferma" : "ancora viva"}');
    expect(interruttore.onChanged, isNull,
        reason: 'col livello sensoriale spento la riga dei soli suoni si '
            'lascia ancora toccare, e non decide niente');
    expect(interruttore.value, isFalse,
        reason: 'la riga dice acceso mentre nessun suono puo\' uscire');
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
    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);

    await tester.tap(find.text('Passport'));
    await step(tester);
    // La rotellina non c'e' piu' (ordine AK voce 03): la via e' porta
    // dell'account, "Il tuo account", voce Impostazioni. **DUE TOCCHI
    // dall'ordine AM voce 04**: il volto vive nella barra sottile in alto,
    // e il primo tocco la APRE invece di portare via da dove si sta.
    // **AL PIU\' DUE TOCCHI, E SI SMETTE QUANDO IL PANNELLO E\' APERTO.** I
    // due tocchi fissi cadevano quando bastava il primo: se al primo avvio
    // c'e\' una festa in scena la barra sottile si ritira, ordine BX voce 07,
    // e il secondo tocco richiude cio\' che il primo aveva aperto.
    for (var t = 0; t < 2; t++) {
      if (find.byKey(const Key('account_impostazioni')).evaluate().isNotEmpty) {
        break;
      }
      final porta = find.byKey(const Key('porta_dell_account'));
      if (porta.evaluate().isEmpty) break;
      await tester.tap(porta.last, warnIfMissed: false);
      for (var g = 0; g < 5; g++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
    // **SI SCORRE PER CERCARE.** La lista dell'account e\' pigra: cio\' che
    // sta sotto il bordo non viene costruito. Con la voce "Chi ti ha
    // invitato" dell'ordine BX voce 02 le voci sono diventate sette, e su
    // una finestra di prova da 800 per 600 punti "Impostazioni" e\' scesa
    // fuori: la guardia diceva "non c'e\'" mentre era al suo posto.
    await tester.scrollUntilVisible(
        find.byKey(const Key('account_impostazioni')), 120,
        scrollable: find.descendant(
            of: find.byKey(const Key('account_list')),
            matching: find.byType(Scrollable)));
    await tester.tap(find.byKey(const Key('account_impostazioni')),
        warnIfMissed: false);
    await step(tester);
    await step(tester);

    expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    expect(find.text('Impostazioni'), findsWidgets);
  });
}
