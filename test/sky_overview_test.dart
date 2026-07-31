import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Il cielo sopra di te": mostra la Luna e le costellazioni alte stanotte,
/// toccabili, con la loro riga. Freccia Indietro, mai un vicolo cieco.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // La schermata ricorda se la posizione e' gia' stata concessa: senza le
  // preferenze la lettura fallirebbe, e il ripiego chiederebbe comunque il
  // permesso. Dichiararle qui rende la prova esplicita invece di appoggiarsi a
  // un ripiego.
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  Widget hostFull({
    DateTime? now,
    SkyLocation location = const DisabledSkyLocation(),
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
              child: SkyOverviewScreen(now: now, location: location)),
        ),
      );

  Widget host(DateTime now) => hostFull(now: now);

  testWidgets('Mostra la Luna e le costellazioni alte stanotte, toccabili',
      (tester) async {
    silence();
    final now = DateTime.utc(2026, 7, 13, 22);
    await tester.pumpWidget(host(now));
    await step(tester);

    // La Luna e le tre costellazioni alte hanno il loro corpo toccabile.
    expect(find.byKey(const Key('sky_body_moon')), findsOneWidget);
    final high = NightSky.constellationsHighTonight(now);
    expect(high.length, 3);
    for (final sign in high) {
      expect(find.byKey(Key('sky_body_${sign.id}')), findsOneWidget,
          reason: 'manca il corpo ${sign.id}');
      expect(find.text(sign.italianName), findsWidgets);
    }

    // Toccando la Luna, la scheda mostra la sua riga.
    await tester.tap(find.byKey(const Key('sky_body_moon')));
    await step(tester);
    expect(find.text('Luna'), findsWidgets);

    // Toccando una costellazione, la scheda ne mostra la descrizione.
    final sign = high.first;
    await tester.tap(find.byKey(Key('sky_body_${sign.id}')));
    await step(tester);
    expect(find.text(NightSky.describe(sign)), findsOneWidget);
  });

  testWidgets('Ha la freccia Indietro e il bottone Condividi', (tester) async {
    silence();
    await tester.pumpWidget(host(DateTime.utc(2026, 7, 13, 22)));
    await step(tester);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Il bottone della cartolina condivisibile.
    expect(find.byKey(const Key('sky_share')), findsOneWidget);
  });

  testWidgets('Condividi offre i due formati, Storia e Feed', (tester) async {
    silence();
    await tester.pumpWidget(host(DateTime.utc(2026, 7, 13, 22)));
    await step(tester);
    await tester.tap(find.byKey(const Key('sky_share')));
    await step(tester);
    // Appare la scelta del formato; non procediamo oltre (i canali di
    // piattaforma di condivisione non esistono in headless).
    expect(find.byKey(const Key('share_story')), findsOneWidget);
    expect(find.byKey(const Key('share_feed')), findsOneWidget);
  });

  testWidgets('Col luogo disponibile chiede il permesso con un pre-avviso gentile',
      (tester) async {
    silence();
    await tester.pumpWidget(hostFull(
        location: const _FakeLocation(
            place: SkyPlace(latitude: 41.9, longitude: 12.5))));
    await step(tester);
    // Appare il pre-avviso, non la richiesta secca del sistema.
    expect(find.byKey(const Key('sky_location_prompt')), findsOneWidget);
    expect(find.text('Oriento il cielo sul tuo luogo?'), findsOneWidget);

    // Accettando, il cielo si orienta e lo dichiara in-world.
    await tester.tap(find.byKey(const Key('sky_location_accept')));
    await step(tester);
    expect(find.byKey(const Key('sky_location_prompt')), findsNothing);
    // La dichiarazione in-world, in italiano semplice, senza gergo.
    // La nota diceva "Orientato sul tuo luogo. La posizione esatta di ogni
    // astro arriva col motore a effemeridi", ed era meta' falsa: negava in
    // blocco un calcolo che l'app fa davvero. Adesso dice cosa e' calcolato e
    // cosa non c'e'.
    expect(find.textContaining('altezza vera sul tuo orizzonte'),
        findsOneWidget);
    // E dichiara anche cosa NON c'e', invece di negare tutto in blocco: gli
    // altri pianeti non si disegnano su questa schermata.
    expect(find.textContaining('Gli altri pianeti non si disegnano'),
        findsOneWidget);
  });

  testWidgets('Se il permesso manca, ripiega con eleganza sulla veduta attuale',
      (tester) async {
    silence();
    await tester.pumpWidget(hostFull(location: const _FakeLocation()));
    await step(tester);
    await tester.tap(find.byKey(const Key('sky_location_accept')));
    await step(tester);
    // Il messaggio ora dice COSA si sta mostrando al posto del luogo vero, e
    // offre la via d'uscita: prima era un'unica frase per permesso negato,
    // GPS spento e sensore assente, sbagliata per almeno uno dei tre.
    expect(find.byKey(const Key('sky_location_negata')), findsOneWidget);
    expect(find.textContaining('cielo della tua nascita'), findsOneWidget);
  });

  testWidgets('Col momento fissato non chiede mai il luogo', (tester) async {
    silence();
    // Anche con una sorgente disponibile, un momento fisso (cielo di nascita,
    // test, anteprime) non fa comparire il pre-avviso.
    await tester.pumpWidget(hostFull(
        now: DateTime.utc(2026, 7, 13, 22),
        location: const _FakeLocation(
            place: SkyPlace(latitude: 41.9, longitude: 12.5))));
    await step(tester);
    expect(find.byKey(const Key('sky_location_prompt')), findsNothing);
  });
}

/// Sorgente di posizione finta per i test: disponibile, restituisce il luogo
/// dato (o null per simulare permesso negato o sensore assente).
class _FakeLocation extends SkyLocation {
  const _FakeLocation({this.place});

  final SkyPlace? place;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => place;

  @override
  Future<SkyPlace?> resolveSeConcesso() async => place;
}
