import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_moon.dart';
import 'package:esoteric_circle/core/identity/numerology.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il Cosmic Passport mostra vivi i due fatti deterministici (Numero della vita
/// e Fase lunare di nascita), col valore reale calcolato, e tiene dietro il velo
/// le voci che richiedono servizi esterni.
void main() {
  Widget wrap(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          // La tessera della carta natale legge lo stato del calcolo per
          // dire cio' che la carta E', invece di dichiarare sempre di
          // averla calcolata sulle effemeridi.
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(body: child),
        ),
      );

  testWidgets('Mostra Numero della vita e Fase lunare col valore reale',
      (tester) async {
    await tester.pumpWidget(wrap(const CosmicPassport()));
    await tester.pump();

    // Le due tessere vive sono presenti.
    expect(find.byKey(const Key('passport_life_path')), findsOneWidget);
    expect(find.byKey(const Key('passport_birth_moon')), findsOneWidget);
    // L'Animale guida e' ora un fatto vivo dal segno, non piu' un segnaposto.
    expect(find.byKey(const Key('passport_guide_animal')), findsOneWidget);

    // Mostrano il valore reale calcolato dal dato d'esempio.
    final id = BirthIdentity.example;
    final lp = LifePath.forDate(id.birthMoment);
    final moon = BirthMoon.forDate(id.birthMoment);
    expect(find.text('${lp.number} · ${lp.title}'), findsOneWidget);
    expect(find.text(moon.label), findsOneWidget);

    // Il dato d'esempio e' dichiarato in-world su ogni tessera viva: Numero
    // della vita, Fase lunare, Animale guida e i tre Angeli.
    expect(find.byKey(const Key('passport_angels')), findsOneWidget);
    // La Carta natale e' la quinta tessera viva: prima stava fra le cose "in
    // arrivo" mentre la carta si calcola davvero, quindi chi apriva il proprio
    // passaporto concludeva di non averla.
    expect(find.byKey(const Key('passport_natal_chart')), findsOneWidget);
    expect(
        find.textContaining('Valore d\'esempio'), findsNWidgets(5));

    // Le voci che richiedono servizi esterni restano dietro il velo.
    expect(find.text('Dietro il velo'), findsWidgets);
    // "Carta natale" non e' piu' una voce velata: e' una tessera VIVA, e si
    // chiama "La tua carta natale". Dietro il velo resta il solo Archetipo.
    // L'etichetta di una tessera viva si mostra in maiuscolo.
    expect(find.text('LA TUA CARTA NATALE'), findsOneWidget);
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

  testWidgets('Toccando l\'Animale guida nel Passport si apre la sua lettura',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap(const CosmicPassport()));
    await tester.pump();

    final card = find.byKey(const Key('passport_guide_animal'));
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    // Dal Passport si apre la lettura fissa di identita', chi e' il tuo animale,
    // non il viaggio col tamburo, che resta nel dominio di Caligo.
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    expect(find.byKey(const Key('animal_journey')), findsNothing);
    expect(find.byKey(const Key('animal_natura')), findsOneWidget);
  });

  testWidgets('L\'Archetipo e\' una voce dietro il velo, non una faccia viva',
      (tester) async {
    // L'archetipo cambia rifacendo il test, quindi non e' un fatto fisso di
    // nascita: nel passaporto resta un segnaposto dietro il velo, senza faccia.
    await tester.pumpWidget(wrap(const CosmicPassport()));
    await tester.pump();
    expect(find.text('Archetipo'), findsOneWidget);
    expect(find.byKey(const Key('passport_archetype_face')), findsNothing);
    expect(find.byKey(const Key('passport_archetype_invite')), findsNothing);
  });
}
