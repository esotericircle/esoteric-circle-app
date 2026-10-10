import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/debug/app_check_debug_view.dart';
import 'package:esoteric_circle/features/settings/settings_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/firebase/app_check_debug.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il token di debug di App Check a video.
///
/// Mauro installa l'APK sul telefono da casa e da li' non puo' registrare un
/// token in console: il token deve gia' essere valido al primo avvio. Va anche
/// letto senza dover attraversare l'onboarding. Questi test bloccano tre
/// promesse: in debug la striscia c'e' e mostra un UUID di trentasei
/// caratteri, in release non compare mai, il token fissato da
/// `APP_CHECK_DEBUG_TOKEN` vince su qualunque token generato a caso.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Il token registrato in console la sera del 27 luglio 2026.
  const tokenRegistrato = '2f4013f2-e6e7-49b2-a3aa-402f28cd365a';
  final formaUuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  AppServices servizi({String? token, required bool releaseMode}) =>
      AppServices(
        ai: const UnavailableMaestroAiProvider(),
        memory: InMemoryMaestroMemoryRepository(),
        memoryPersistent: false,
        appCheckDebugToken: token,
        showAppCheckDebugToken:
            AppCheckDebugToken.mostraAVideo(releaseMode: releaseMode),
      );

  Widget guscio(AppServices s, Widget child) => Provider<AppServices>.value(
        value: s,
        child: MaterialApp(home: child),
      );

  Widget impostazioni(AppServices s) => MultiProvider(
        providers: [
          Provider<AppServices>.value(value: s),
          ChangeNotifierProvider(create: (_) => SettingsController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: const MaterialApp(home: MaestroScope(child: SettingsScreen())),
      );

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  String testoDelToken(WidgetTester tester) {
    final t = tester.widget<Text>(
      find.byKey(const Key('app_check_debug_token')),
    );
    return t.data ?? '';
  }

  testWidgets(
      'In debug la striscia mostra il token, un UUID di trentasei caratteri',
      (tester) async {
    await tester.pumpWidget(
      guscio(
        servizi(token: tokenRegistrato, releaseMode: false),
        const AppCheckDebugBanner(
          child: Scaffold(body: Center(child: Text('la prima schermata'))),
        ),
      ),
    );
    await passo(tester);

    expect(find.byKey(const Key('app_check_debug_banner')), findsOneWidget);
    final mostrato = testoDelToken(tester);
    expect(mostrato, tokenRegistrato);
    expect(mostrato.length, 36);
    expect(formaUuid.hasMatch(mostrato), isTrue);
    // La striscia sta sopra, non al posto della schermata.
    expect(find.text('la prima schermata'), findsOneWidget);
  });

  testWidgets('In release la striscia non compare mai', (tester) async {
    await tester.pumpWidget(
      guscio(
        servizi(token: tokenRegistrato, releaseMode: true),
        const AppCheckDebugBanner(
          child: Scaffold(body: Center(child: Text('la prima schermata'))),
        ),
      ),
    );
    await passo(tester);

    expect(find.byKey(const Key('app_check_debug_banner')), findsNothing);
    expect(find.byKey(const Key('app_check_debug_token')), findsNothing);
    expect(find.textContaining(tokenRegistrato), findsNothing);
    expect(find.text('la prima schermata'), findsOneWidget);
  });

  test('Il token fissato vince su quello generato a caso', () async {
    // Con la costante valorizzata si usa esattamente quella. Finisce anche
    // nelle preferenze, cosi' il resto dell'app la ritrova.
    SharedPreferences.setMockInitialValues({});
    final fissato =
        await AppCheckDebugToken.getOrCreate(fissato: tokenRegistrato);
    expect(fissato, tokenRegistrato);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_check_debug_token'), tokenRegistrato);

    // Vince anche su un token gia' salvato da un avvio precedente: altrimenti
    // il telefono continuerebbe a presentare un token che in console non c'e'.
    SharedPreferences.setMockInitialValues({
      'app_check_debug_token': '11111111-2222-4333-8444-555555555555',
    });
    expect(
      await AppCheckDebugToken.getOrCreate(fissato: tokenRegistrato),
      tokenRegistrato,
    );

    // Senza costante resta il comportamento di prima: un UUID nuovo, stabile.
    SharedPreferences.setMockInitialValues({});
    final generato = await AppCheckDebugToken.getOrCreate(fissato: '');
    expect(generato, isNot(tokenRegistrato));
    expect(formaUuid.hasMatch(generato), isTrue);
    expect(await AppCheckDebugToken.getOrCreate(fissato: ''), generato);
  });

  test('La regola della visibilita\' guarda solo la release', () {
    expect(AppCheckDebugToken.mostraAVideo(releaseMode: false), isTrue);
    expect(AppCheckDebugToken.mostraAVideo(releaseMode: true), isFalse);
  });

  testWidgets('Il tocco copia il token e la striscia si richiude',
      (tester) async {
    final copiati = <String>[];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiati.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(() => binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(
      guscio(
        servizi(token: tokenRegistrato, releaseMode: false),
        const AppCheckDebugBanner(child: Scaffold(body: SizedBox.shrink())),
      ),
    );
    await passo(tester);

    await tester.tap(find.byKey(const Key('app_check_debug_token')));
    await passo(tester);
    expect(copiati, [tokenRegistrato]);
    expect(find.text('Token copiato'), findsOneWidget);

    // La conferma se ne va da sola e il token torna leggibile.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Token copiato'), findsNothing);
    expect(testoDelToken(tester), tokenRegistrato);

    // Richiudibile: una volta chiusa non torna.
    await tester.tap(find.byKey(const Key('app_check_debug_close')));
    await passo(tester);
    expect(find.byKey(const Key('app_check_debug_banner')), findsNothing);
  });

  testWidgets('Senza token dai servizi la striscia lo legge dalle preferenze',
      (tester) async {
    // App Check puo' non attivarsi: il token resta comunque leggibile, perche'
    // non dipende da Firebase.
    SharedPreferences.setMockInitialValues({
      'app_check_debug_token': tokenRegistrato,
    });
    await tester.pumpWidget(
      guscio(
        servizi(token: null, releaseMode: false),
        const AppCheckDebugBanner(child: Scaffold(body: SizedBox.shrink())),
      ),
    );
    await tester.pumpAndSettle();

    expect(testoDelToken(tester), tokenRegistrato);
  });

  testWidgets('In fondo alle Impostazioni c\'e\' la riga col token',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      impostazioni(servizi(token: tokenRegistrato, releaseMode: false)),
    );
    await passo(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('app_check_debug_row')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await passo(tester);

    expect(find.byKey(const Key('app_check_debug_row')), findsOneWidget);
    expect(testoDelToken(tester), tokenRegistrato);
  });

  testWidgets('In release le Impostazioni non mostrano nessun token',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      impostazioni(servizi(token: tokenRegistrato, releaseMode: true)),
    );
    await passo(tester);

    expect(find.byKey(const Key('app_check_debug_row')), findsNothing);
    expect(find.textContaining(tokenRegistrato), findsNothing);
  });
}
