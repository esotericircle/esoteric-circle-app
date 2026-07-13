import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/circle_seal.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il Sigillo del Cerchio: emblema personale deterministico dai dati di nascita.
void main() {
  test('Il sigillo nasce deterministico da segno, numero ed elemento', () {
    final seal = CircleSeal.from(
      name: 'Sofia',
      identity: BirthIdentity(birthMoment: DateTime(1990, 6, 15), isExample: false),
    );
    expect(seal.name, 'Sofia');
    expect(seal.sign, Zodiac.gemini);
    expect(seal.element, SealElement.aria);
    expect(seal.lifePath, 4);

    // Stesso dato, stesso sigillo.
    final again = CircleSeal.from(
      name: 'Sofia',
      identity: BirthIdentity(birthMoment: DateTime(1990, 6, 15), isExample: false),
    );
    expect(again.sign, seal.sign);
    expect(again.lifePath, seal.lifePath);
  });

  test('Ogni segno ha il suo elemento', () {
    expect(SealElement.of(Zodiac.aries), SealElement.fuoco);
    expect(SealElement.of(Zodiac.taurus), SealElement.terra);
    expect(SealElement.of(Zodiac.gemini), SealElement.aria);
    expect(SealElement.of(Zodiac.cancer), SealElement.acqua);
  });

  testWidgets('La schermata compone il sigillo col nome e la condivisione',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: const MaterialApp(
          home: MaestroScope(child: CircleSealScreen(name: 'Sofia')),
        ),
      ),
    );
    // Lascia comporre il sigillo.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));

    expect(find.byKey(const Key('circle_seal')), findsOneWidget);
    expect(find.text('Sofia'), findsOneWidget);
    expect(find.byKey(const Key('seal_share')), findsOneWidget);
  });
}
