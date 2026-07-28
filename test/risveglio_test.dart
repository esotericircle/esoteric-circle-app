import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
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

/// Il rituale del Risveglio raccoglie il cielo passo per passo. Qui si verifica
/// la raccolta dei dati fino al sigillo escluso: il segno solare reale, l'ora
/// che si puo' saltare, la ricerca offline del luogo. La coda (ponte verso la
/// carta natale, cielo reale, risonanza, rivelazione) e' coperta dal test di
/// flusso dell'app.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpRisveglio(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileController>(
              create: (_) => ProfileController()),
          ChangeNotifierProvider<OnboardingController>(
              create: (_) => OnboardingController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> continua(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await tester.pumpAndSettle();
  }

  testWidgets('il segno solare compare reale dalla data di default',
      (tester) async {
    await pumpRisveglio(tester);
    await continua(tester); // accoglienza -> data
    // 15 giugno 1990 cade nel Sole in Gemelli, tavola tropicale.
    expect(find.textContaining('Sole in Gemelli'), findsOneWidget);
  });

  testWidgets('senza ora l\'Ascendente si salta con grazia', (tester) async {
    await pumpRisveglio(tester);
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await tester.tap(find.byKey(const Key('risveglio_ora_skip')));
    await tester.pumpAndSettle();
    // La nota provvisoria dichiara che senza l'ora l'Ascendente si salta.
    expect(find.byKey(const Key('risveglio_provvisorio')), findsOneWidget);
  });

  testWidgets('la ricerca del luogo offline sceglie la citta', (tester) async {
    await pumpRisveglio(tester);
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Torino');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citta_Torino_Italia')), findsOneWidget);
    await tester.tap(find.byKey(const Key('citta_Torino_Italia')));
    await tester.pumpAndSettle();
    // Scelta la citta, il campo la riporta con il suo fuso.
    expect(find.textContaining('Torino'), findsWidgets);
  });

  testWidgets('il nome e il vocativo si raccolgono', (tester) async {
    final profile = ProfileController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileController>.value(value: profile),
          ChangeNotifierProvider<OnboardingController>(
              create: (_) => OnboardingController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await continua(tester); // -> nome
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Giulia');
    await tester.pumpAndSettle();
    await continua(tester); // -> vocativo
    await tester.tap(find.byKey(const Key('vocativo_lei')));
    await tester.pumpAndSettle();
    // Il passo del vocativo mostra la scelta; il salvataggio avviene al sigillo,
    // verificato nel flusso dell'app.
    expect(find.byKey(const Key('vocativo_lei')), findsOneWidget);
    expect(find.text('Come vuoi che ti parli'), findsOneWidget);
  });
}
