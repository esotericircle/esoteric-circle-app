import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/identity/numerology.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il Cosmic Passport mostra vivi i due fatti deterministici (Numero della vita
/// e Fase lunare di nascita), col valore reale calcolato, e tiene dietro il velo
/// le voci che richiedono servizi esterni.
void main() {
  Widget wrap(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(home: MaestroScope(child: Scaffold(body: child))),
      );

  testWidgets('Mostra Numero della vita e Fase lunare col valore reale',
      (tester) async {
    await tester.pumpWidget(wrap(const CosmicPassport()));
    await tester.pump();

    // Le due tessere vive sono presenti.
    expect(find.byKey(const Key('passport_life_path')), findsOneWidget);
    expect(find.byKey(const Key('passport_birth_moon')), findsOneWidget);

    // Mostrano il valore reale calcolato dal dato d'esempio.
    final id = BirthIdentity.example;
    final lp = LifePath.forDate(id.birthMoment);
    final moon = BirthMoon.forDate(id.birthMoment);
    expect(find.text('${lp.number} · ${lp.title}'), findsOneWidget);
    expect(find.text(moon.label), findsOneWidget);

    // Il dato d'esempio e' dichiarato in-world (due tessere).
    expect(
        find.textContaining('Valore d\'esempio'), findsNWidgets(2));

    // Le voci che richiedono servizi esterni restano dietro il velo.
    expect(find.text('Dietro il velo'), findsWidgets);
    expect(find.text('Carta natale'), findsOneWidget);
  });

  testWidgets('Con un\'identita\' reale sparisce la nota d\'esempio',
      (tester) async {
    final real = BirthIdentity(birthMoment: DateTime(1988, 3, 21, 8), isExample: false);
    await tester.pumpWidget(wrap(CosmicPassport(identity: real)));
    await tester.pump();

    expect(find.byKey(const Key('passport_life_path')), findsOneWidget);
    // Nessuna nota d'esempio: il dato e' reale.
    expect(find.textContaining('Valore d\'esempio'), findsNothing);
    final lp = LifePath.forDate(real.birthMoment);
    expect(find.text('${lp.number} · ${lp.title}'), findsOneWidget);
  });
}
