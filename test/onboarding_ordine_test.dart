import 'dart:convert';
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
    // **SENZA UN LUOGO SALVATO, IL CIELO DI NASCITA RESTA APPESO.** Ordine
    // FN/FO, 13 ottobre 2026: da quando "Leggi la tua carta" aspetta la
    // corsa, questa prova deve davvero arrivare in fondo al caricamento del
    // cielo, e quel caricamento chiede la posizione attuale
    // (`DoveSonoAdesso.letto()`, poi `GeolocatorSkyLocation` se non trova
    // niente) prima di preparare il modo. Nessun canale del geolocalizzatore
    // e' finto in questa prova (solo i sensori lo sono, in `silence()`), e
    // l'attesa di quella chiamata non finiva mai. Un luogo gia' salvato
    // evita del tutto la domanda al dispositivo, come la trova chi ha gia'
    // concesso la posizione una volta.
    SharedPreferences.setMockInitialValues({
      'luogo.attuale': jsonEncode({
        'lat': 41.9028,
        'lon': 12.4964,
        'nome': 'Roma',
        'origine': 'dispositivo',
      }),
    });
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
    // Dall'ordine DP il pulsante sta nella colonna fin dall'inizio, per non
    // far saltare la schermata quando arriva: **spento e trasparente**.
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('carta_di_nascita_continua')))
            .onPressed,
        isNull,
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

    // **"LEGGI LA TUA CARTA" ASPETTA LA CORSA, ordine FN, 13 ottobre 2026.**
    // Prima il pulsante del seguito (`sky_cta`) stava li' fin da subito; il
    // fondatore ha chiesto un solo pulsante alla volta, "viaggia nel tempo"
    // prima e "leggi la tua carta" solo a corsa finita. Qui si avvia la
    // corsa come farebbe la persona, e si aspetta l'arrivo.
    // **L'ATTESA VUOLE `runAsync`, NON SOLO `pump`.** La schermata carica
    // asset veri (catalogo delle stelle, Luna, orizzonte, Via Lattea, cinque
    // corpi del cielo profondo) con `rootBundle.load` e la decodifica delle
    // immagini: lavoro asincrono vero, che il solo `tester.pump()` non fa
    // avanzare, perche' resta dentro la zona finta del test. Lo stesso
    // schema di `test/le_anteprime_dell_ordine_fg_test.dart` (`carica`):
    // un `runAsync` con un ritardo vero, alternato a un `pump`, cede
    // davvero il controllo all'event loop finche' il caricamento finisce.
    // **IL BUDGET E' IN TEMPO REALE, e le macchine di GitHub sono piu'
    // lente della mia.** Centoventi giri da 250 millisecondi sono fino a
    // trenta secondi veri di attesa: generoso per un caricamento che in
    // locale finisce in pochi secondi, necessario su un runner condiviso.
    var compare = find.byKey(const Key('macchina_viaggia_dal_cielo'))
        .evaluate()
        .isNotEmpty;
    for (var i = 0; i < 120 && !compare; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 250)));
      await tester.pump(const Duration(milliseconds: 50));
      compare = find.byKey(const Key('macchina_viaggia_dal_cielo'))
          .evaluate()
          .isNotEmpty;
    }
    expect(compare, isTrue,
        reason: 'il cielo di nascita non offre piu\' "Viaggia nel tempo"');
    // **RIDUCI MOVIMENTO, invece di inseguire la durata vera della corsa.**
    // La corsa verso la nascita dura da sola una ventina di secondi
    // (misurato in `test/le_anteprime_della_macchina_del_tempo_test.dart`,
    // I6/I11: 17,2 secondi dal tocco all'arrivo), un tempo simulato che tre
    // giri del cancello di GitHub non sono bastati a coprire con margine
    // anche raddoppiato: il runner e' piu' lento del previsto e inseguire
    // la sua velocita' a tentativi non e' la cura giusta. Il codice stesso
    // (`_avviaLaCorsa`, `if (_riduciMovimento) _vaiAllaNascita(...)`) sa
    // saltare l'animazione intera quando l'accessibilita' lo chiede: e'
    // la stessa via che userebbe una persona con quell'opzione attiva, e
    // qui rende la prova veloce e indipendente da quanto e' lenta la
    // macchina. Resta da aspettare solo l'arrivo vero e proprio (3,2
    // secondi di tempo simulato, `_durataDellArrivo`), che non dipende da
    // nessun caricamento reale.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();
    await tester.tap(find.byKey(const Key('macchina_viaggia_dal_cielo')));
    await tester.pump();
    var trovato = false;
    for (var i = 0; i < 20 && !trovato; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      trovato = find.byKey(const Key('sky_cta')).evaluate().isNotEmpty;
    }
    expect(trovato, isTrue,
        reason: 'la corsa non porta mai a "Leggi la tua carta"');
    await tester.tap(find.byKey(const Key('sky_cta')));
    await passo(tester);
    expect(find.byType(NatalChartReveal), findsOneWidget,
        reason: 'dopo gli Angeli e il cielo deve arrivare il ritratto insieme');
  });
}
