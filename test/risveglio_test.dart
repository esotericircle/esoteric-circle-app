import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il rituale del Risveglio raccoglie il cielo passo per passo e a fine rito
/// salva il profilo: nome, vocativo, e la nascita con luogo e ora (che puo'
/// mancare). Il segno solare e' reale, ricavato dalla data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProfileController> pumpRisveglio(WidgetTester tester) async {
    final profile = ProfileController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileController>.value(value: profile),
          ChangeNotifierProvider<OnboardingController>(
              create: (_) => OnboardingController()),
        ],
        // Riduci Movimento attivo su tutte le route (anche la rivelazione
        // spinta dopo il sigillo): ferma le accensioni e la rotazione
        // d'ambiente della ruota, cosi' il test non dipende dalle animazioni.
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return profile;
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

  testWidgets('senza ora l\'Ascendente si salta e non finisce nei dati',
      (tester) async {
    final profile = await pumpRisveglio(tester);
    await continua(tester); // -> data
    await continua(tester); // -> ora
    // Dichiaro di non sapere l'ora.
    await tester.tap(find.byKey(const Key('risveglio_ora_skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('risveglio_provvisorio')), findsOneWidget);
    await continua(tester); // -> luogo
    await continua(tester); // luogo saltato -> nome
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Sole');
    await tester.pumpAndSettle();
    await continua(tester); // -> vocativo
    await tester.tap(find.byKey(const Key('vocativo_neutro')));
    await tester.pumpAndSettle();
    await continua(tester); // -> sigillo
    await tester.longPress(find.byKey(const Key('risveglio_sigillo')));
    await tester.pumpAndSettle();

    expect(profile.identity.hasBirthTime, isFalse);
    expect(profile.courtesy, CourtesyForm.neutral);
  });

  testWidgets('la ricerca del luogo offline ancora il cielo alla citta scelta',
      (tester) async {
    final profile = await pumpRisveglio(tester);
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Torino');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('citta_Torino')));
    await tester.pumpAndSettle();
    await continua(tester); // -> nome
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Marco');
    await tester.pumpAndSettle();
    await continua(tester); // -> vocativo
    await tester.tap(find.byKey(const Key('vocativo_lui')));
    await tester.pumpAndSettle();
    await continua(tester); // -> sigillo
    await tester.longPress(find.byKey(const Key('risveglio_sigillo')));
    await tester.pumpAndSettle();

    expect(profile.vocative, 'Marco');
    expect(profile.courtesy, CourtesyForm.masculine);
    expect(profile.identity.birthPlace, isNotNull);
    expect(profile.identity.birthPlace!.city, 'Torino');
    expect(profile.identity.birthPlace!.timeZoneId, 'Europe/Rome');
  });
}
