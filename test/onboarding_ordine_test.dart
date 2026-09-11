import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/risveglio_journey.dart';
import 'package:esoteric_circle/features/onboarding/trionfi_screen.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ordine del racconto: prima i compagni, poi il ritratto d'insieme.
///
/// Messi dopo la carta natale, i due trionfi rivelavano una cosa gia' vista:
/// la carta contiene la tessera del lupo e quella dei tre angeli, quindi chi
/// arrivava al trionfo li aveva gia' incontrati come voci di un elenco. Un
/// trionfo che svela il noto non e' un trionfo.
///
/// **RISCRITTA DALL'ORDINE DG VOCE 04, e corretta il giorno dopo dal
/// fondatore.** La voce diceva *"dopo gli angeli, per ultima"*, e io avevo
/// scelto la seconda meta' della frase, mettendo l'animale dopo la rivelazione
/// del Maestro. Il fondatore ha rifatto l'onboarding e ha corretto: *"la
/// schermata c'e' con l'animale oscurato, ma andrebbe messa dopo la
/// rivelazione degli angeli. adesso e' dopo la rivelazione del maestro"*.
///
/// **L'ordine e' adesso**: angeli, **animale**, **carta di nascita**, cielo,
/// carta natale, risonanza, Maestro, custodia. Le prime tre sono i doni che ti
/// sono stati dati, e stanno insieme.
///
/// **La legge che questa prova protegge non e' cambiata**: gli Angeli
/// continuano ad arrivare prima della carta natale, perche' e' la carta a
/// contenere le loro tessere e non il contrario. Cio' che e' cambiato e' dove
/// sta l'animale, che non si rivela affatto nel Risveglio: **il suo nome lo
/// dice il Viaggio**, dopo quattro discese.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

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

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('GLI ANGELI ARRIVANO PRIMA DELLA CARTA, e l Animale subito '
      'dopo di loro',
      (tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final c = CityCatalog.search('Roma').first;
    final details = BirthDetails(
      date: DateTime(1985, 3, 3),
      time: const TimeOfDay(hour: 7, minute: 20),
      place: astro.BirthPlace(
        label: c.name,
        latitude: c.latitude,
        longitude: c.longitude,
        timezone: c.timeZoneId,
      ),
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => IdentityController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        home: MaestroScope(child: RisveglioJourney(details: details)),
      ),
    ));
    await passo(tester);

    // **LA CODA APRE CON GLI ANGELI**, ordine DG voce 04.
    expect(find.byType(TrionfoAngeli), findsOneWidget,
        reason: 'la coda non apre col trionfo degli Angeli');
    expect(find.byType(TrionfoAnimale), findsNothing,
        reason: 'l Animale apre ancora il Risveglio: viene DOPO gli Angeli');
    expect(find.byType(NatalChartReveal), findsNothing,
        reason: 'la carta natale arriva prima del trionfo degli Angeli, '
            'quindi il trionfo rivelerebbe una cosa gia\' vista');

    // **POI L'ANIMALE, SUBITO DOPO DI LORO**, ed e' la correzione del
    // fondatore dell'11 settembre 2026.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byKey(const Key('trionfo_angeli_avanti')));
    await passo(tester);
    expect(find.byType(TrionfoAnimale), findsOneWidget,
        reason: 'dopo gli Angeli deve arrivare l Animale: e la correzione del '
            'fondatore, "andrebbe messa dopo la rivelazione degli angeli"');
    expect(find.byType(NatalChartReveal), findsNothing,
        reason: 'la carta arriva prima dell Animale');

    // **POI LA CARTA DI NASCITA**, ordine DC voce 14 agganciata dall ordine
    // DG: la schermata esisteva, provata, e non la apriva nessuno.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byKey(const Key('trionfo_animale_avanti')));
    await passo(tester);
    expect(find.byKey(const Key('rivelazione_carta_di_nascita')),
        findsOneWidget,
        reason: 'dopo l Animale deve arrivare la rivelazione della Carta di '
            'Nascita: il fondatore l ha trovata mancante rifacendo l '
            'onboarding');

    // **IL PULSANTE ARRIVA A RIVELAZIONE FINITA**, non prima: sette secondi
    // in cui non c'e' niente da toccare, perche' un pulsante acceso in mezzo
    // inviterebbe a saltare proprio il pezzo che racconta il calcolo.
    expect(find.byKey(const Key('carta_di_nascita_continua')), findsNothing,
        reason: 'il pulsante della Carta di Nascita e acceso mentre la '
            'rivelazione sta ancora raccontando il calcolo');
    await tester.pump(RivelazioneCartaDiNascita.quantoDura);
    await passo(tester);

    // Poi il cielo di nascita, e SOLO dopo la carta natale, che raccoglie i
    // compagni gia' incontrati uno per uno.
    await tester.tap(find.byKey(const Key('carta_di_nascita_continua')));
    await passo(tester);
    expect(find.byType(NatalChartReveal), findsNothing,
        reason: 'la carta arriva prima del cielo di nascita');

    await tester.tap(find.byKey(const Key('sky_cta')));
    await passo(tester);
    expect(find.byType(NatalChartReveal), findsOneWidget,
        reason: 'dopo gli Angeli e il cielo deve arrivare il ritratto insieme');
  });
}
