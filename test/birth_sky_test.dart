import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "Il tuo cielo di nascita": lo stesso motore immersivo del cielo di adesso,
/// ma ancorato alla notte di nascita e fisso. Vive nel portale del Cosmic
/// Passport, nella voce di Medora. Non chiede mai la posizione.
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

  Widget wrap(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          // La tessera della carta natale legge lo stato del calcolo per
          // dire cio' che la carta E', invece di dichiarare sempre di
          // averla calcolata sulle effemeridi.
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(home: MaestroScope(child: child)),
      );

  testWidgets('Il cielo di nascita e\' fisso, parla di identita\' e non chiede '
      'il luogo', (tester) async {
    silence();
    final birth = DateTime.utc(1990, 6, 15, 2, 30);
    await tester.pumpWidget(wrap(SkyOverviewScreen(now: birth, birth: true)));
    await step(tester);

    // Titolo del cielo di nascita, mai il pre-avviso della posizione: il luogo
    // e' quello della nascita, non l'adesso.
    expect(find.text('Il tuo cielo di nascita'), findsOneWidget);
    expect(find.byKey(const Key('sky_location_prompt')), findsNothing);

    // La Luna e le costellazioni sono quelle della notte di nascita.
    expect(find.byKey(const Key('sky_body_moon')), findsOneWidget);
    final high = NightSky.constellationsHighTonight(birth);
    for (final sign in high) {
      expect(find.byKey(Key('sky_body_${sign.id}')), findsOneWidget,
          reason: 'manca il corpo di nascita ${sign.id}');
    }

    // La voce di Medora sull'identita', con la dichiarazione in-world.
    // LA SCHEDA SI E' RIDOTTA a due sole cose, per decisione del fondatore
    // del 31 luglio: una riga che dice cos'e' il cielo, e le coordinate del
    // corpo toccato. La nota sull'assaggio e quella sul dato registrato sono
    // uscite, e con loro lo spazio che mangiavano al cielo.
    // expect(find.textContaining('prima notte'), findsOneWidget);
    // Senza nascita registrata la veduta dichiara di essere un assaggio. La
    // parola "esempio" e' sparita di proposito: diceva "veduta d'esempio
    // finche' non registri", e restava identica anche a chi aveva appena
    // registrato tutto, quindi mentiva proprio a chi aveva fatto le cose per
    // bene. Il caso opposto e' provato in cielo_nascita_vero_test.dart.
    // LA SCHEDA SI E' RIDOTTA a due sole cose, per decisione del fondatore
    // del 31 luglio: una riga che dice cos'e' il cielo, e le coordinate del
    // corpo toccato. La nota sull'assaggio e quella sul dato registrato sono
    // uscite, e con loro lo spazio che mangiavano al cielo.
    // expect(find.textContaining('assaggio'), findsOneWidget);
  });

  testWidgets('Il Cosmic Passport ha il portale attivo verso il cielo di nascita',
      (tester) async {
    silence();
    await tester.pumpWidget(wrap(const Scaffold(body: CosmicPassport())));
    await step(tester);

    // Il portale e' presente e attivo (non "Dietro il velo").
    expect(find.byKey(const Key('passport_birth_sky')), findsOneWidget);
    expect(find.text('Il tuo cielo di nascita'), findsOneWidget);

    // Toccandolo si apre la volta immersiva di nascita. La bolla dei
    // traguardi (ordine AK voce 04) sta sopra e il portale puo' essere
    // sceso sotto il bordo: prima lo si porta in vista.
    await tester.ensureVisible(find.byKey(const Key('passport_birth_sky')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('passport_birth_sky')));
    await step(tester);
    await step(tester);
    expect(find.byType(SkyOverviewScreen), findsOneWidget);
    expect(find.byKey(const Key('sky_location_prompt')), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });
}
