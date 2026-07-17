import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/features/onboarding/reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La rivelazione chiama per nome col vocativo giusto e mostra il cielo coi tre
/// pilastri: Sole reale, Luna e Ascendente marcati provvisori, senza invenzioni.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpReveal(
    WidgetTester tester, {
    required String name,
    required CourtesyForm courtesy,
    bool hasBirthTime = true,
  }) async {
    final profile = ProfileController(
      profile: UserProfile(displayName: name, courtesyForm: courtesy),
      identity: BirthIdentity.fromParts(
        birthDate: DateTime(1990, 6, 15),
        birthHour: hasBirthTime ? 2 : null,
      ),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileController>.value(value: profile),
          ChangeNotifierProvider<OnboardingController>(
              create: (_) => OnboardingController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const RevealScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('il Sole e\' reale e i pilastri provvisori sono marcati',
      (tester) async {
    await pumpReveal(tester, name: 'Marco', courtesy: CourtesyForm.masculine);
    // 15 giugno 1990: Sole in Gemelli, reale dalla tavola.
    expect(find.text('Sole in Gemelli'), findsOneWidget);
    // Luna e Ascendente entrambi provvisori.
    expect(find.byKey(const Key('reveal_provvisorio')), findsNWidgets(2));
    expect(find.text('Questo cielo è solo tuo.'), findsOneWidget);
    expect(find.byKey(const Key('reveal_birth_sky')), findsOneWidget);
    expect(find.byKey(const Key('onboarding_enter')), findsOneWidget);
  });

  testWidgets('concorda la frase al vocativo maschile', (tester) async {
    await pumpReveal(tester, name: 'Marco', courtesy: CourtesyForm.masculine);
    expect(find.textContaining('ti ha visto nascere'), findsOneWidget);
  });

  testWidgets('concorda la frase al vocativo femminile', (tester) async {
    await pumpReveal(tester, name: 'Giulia', courtesy: CourtesyForm.feminine);
    expect(find.textContaining('ti ha vista nascere'), findsOneWidget);
  });

  testWidgets('il neutro evita la desinenza di genere', (tester) async {
    await pumpReveal(tester, name: 'Ale', courtesy: CourtesyForm.neutral);
    expect(find.textContaining('ha vegliato sulla tua nascita'), findsOneWidget);
    // Nessuna forma marcata al genere nella frase della Guida.
    expect(find.textContaining('nascere'), findsNothing);
  });

  testWidgets('senza ora l\'Ascendente resta in ombra', (tester) async {
    await pumpReveal(tester,
        name: 'Ale', courtesy: CourtesyForm.neutral, hasBirthTime: false);
    expect(find.textContaining('Serve l\'ora di nascita'), findsOneWidget);
  });
}
