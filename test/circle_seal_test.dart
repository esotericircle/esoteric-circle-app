import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/circle_seal.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il Sigillo del Cerchio: emblema personale deterministico dai dati di nascita,
/// ora un'esperienza con la frase di Medora e il pannello "Cosa significa".
void main() {
  Widget host({String name = 'Sofia', BirthIdentity? identity}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: CircleSealScreen(name: name, identity: identity),
          ),
        ),
      );

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

  test('Ogni segno ha il suo elemento, con la sua natura', () {
    expect(SealElement.of(Zodiac.aries), SealElement.fuoco);
    expect(SealElement.of(Zodiac.taurus), SealElement.terra);
    expect(SealElement.of(Zodiac.gemini), SealElement.aria);
    expect(SealElement.of(Zodiac.cancer), SealElement.acqua);
    for (final e in SealElement.values) {
      expect(e.meaning, isNotEmpty);
    }
  });

  testWidgets('La schermata compone il sigillo, la frase di Medora e la condivisione',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 1700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(name: 'Sofia'));
    // Lascia comporre il sigillo.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2700));

    expect(find.byKey(const Key('circle_seal')), findsOneWidget);
    expect(find.text('Sofia'), findsOneWidget);
    expect(find.byKey(const Key('seal_share')), findsOneWidget);
    // La frase di Medora, sottotitolo sempre attivo, col nome.
    expect(find.byKey(const Key('seal_greeting')), findsOneWidget);
    expect(
      find.textContaining('Sofia', findRichText: false),
      findsWidgets,
    );
  });

  testWidgets('Il pannello "Cosa significa" spiega ruota, numero ed elemento',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 1700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      name: 'Sofia',
      identity: BirthIdentity(birthMoment: DateTime(1990, 6, 15)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2700));

    // Chiuso di default: chi vuole capire tocca e legge.
    expect(find.byKey(const Key('seal_meaning_panel')), findsNothing);

    await tester.tap(find.byKey(const Key('seal_meaning_toggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('seal_meaning_panel')), findsOneWidget);
    // La riduzione numerologica passo per passo e' a schermo.
    expect(find.text('Giorno 15: 1 + 5 = 6'), findsOneWidget);
    expect(find.text('Somma: 6 + 6 + 1 = 13 → 4'), findsOneWidget);
    // L'elemento con la sua natura.
    expect(find.textContaining('elemento: Aria'), findsOneWidget);
  });
}
