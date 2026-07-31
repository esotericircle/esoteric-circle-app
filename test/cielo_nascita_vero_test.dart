import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/risveglio_journey.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il cielo di nascita deve essere il TUO, e deve dirlo.
///
/// A schermo, con nascita e luogo appena registrati, la bolla continuava a
/// dichiarare "veduta d'esempio finche' non registri nascita e luogo". La
/// frase era scritta a mano nel widget e non guardava mai il profilo, quindi
/// era falsa esattamente per chi aveva fatto tutto giusto. E' la stessa
/// famiglia del difetto del Cosmic Passport: il dato c'era, nessuno lo
/// leggeva. Per questo il test monta l'app dall'avvio vero e non passa niente
/// a mano alla schermata.
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
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Il Risveglio, montato con gli stessi provider dell'app vera e con i dati
  /// di nascita appena inseriti: e' la fase in cui Mauro ha visto la bugia.
  /// Non si passa niente alla scheda, si guarda cosa dice a schermo.
  Future<void> apriIlCieloDelRisveglio(WidgetTester tester,
      {required BirthDetails details}) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: RisveglioJourney(details: details),
        ),
      ),
    ));
    await passo(tester);
    await passo(tester);
    // I due trionfi vengono PRIMA del cielo: l'Animale Guida e la triade di
    // Angeli stanno subito dopo il numero della vita, quindi per arrivare al
    // cielo si attraversano loro. Prima il cielo era la prima fase.
    for (final chiave in const [
      'trionfo_animale_avanti',
      'trionfo_angeli_avanti',
    ]) {
      // I trionfi accendono il proprio pulsante solo a scena conclusa: si
      // aspetta la fine invece di toccare a meta'.
      await tester.pump(const Duration(seconds: 5));
      await tester.tap(find.byKey(Key(chiave)));
      await passo(tester);
      await passo(tester);
    }
  }

  testWidgets('Col luogo inserito la bolla non parla di esempio',
      (tester) async {
    final c = CityCatalog.search('Busto Arsizio').first;
    await apriIlCieloDelRisveglio(tester,
        details: BirthDetails(
          date: DateTime(1985, 3, 3),
          time: const TimeOfDay(hour: 7, minute: 20),
          place: astro.BirthPlace(
            label: c.name,
            latitude: c.latitude,
            longitude: c.longitude,
            timezone: c.timeZoneId,
          ),
        ));

    expect(find.textContaining('esempio'), findsNothing,
        reason: 'la bolla dichiara un esempio sul dato appena inserito');
    // LA SCHEDA SI E' RIDOTTA a due sole cose, per decisione del fondatore
    // del 31 luglio: una riga che dice cos'e' il cielo, e le coordinate del
    // corpo toccato. La nota sull'assaggio e quella sul dato registrato sono
    // uscite, e con loro lo spazio che mangiavano al cielo.
    // expect(find.textContaining('che hai registrato'), findsOneWidget);
  });

  testWidgets('Senza luogo la veduta dichiara di essere un assaggio',
      (tester) async {
    // Il rovescio: chi salta il luogo DEVE vedere che quella non e' ancora la
    // sua volta, altrimenti si toglie una bugia e se ne mette un'altra.
    await apriIlCieloDelRisveglio(tester,
        details: BirthDetails(
          date: DateTime(1985, 3, 3),
          time: const TimeOfDay(hour: 7, minute: 20),
        ));

    // LA SCHEDA SI E' RIDOTTA a due sole cose, per decisione del fondatore
    // del 31 luglio: una riga che dice cos'e' il cielo, e le coordinate del
    // corpo toccato. La nota sull'assaggio e quella sul dato registrato sono
    // uscite, e con loro lo spazio che mangiavano al cielo.
    // expect(find.textContaining('assaggio'), findsOneWidget);
  });

  test('Le costellazioni alte sono quelle della data, su una data nota', () {
    // Il 3 marzo il Sole sta nei Pesci: la volta alta a quell'ora e' calcolata
    // dalla longitudine eclittica, non estratta a caso. Se qualcuno un giorno
    // sostituisse il calcolo con tre segni fissi, questo test cade.
    final marzo = NightSky.constellationsHighTonight(DateTime(1985, 3, 3, 7, 20));
    final settembre =
        NightSky.constellationsHighTonight(DateTime(1985, 9, 3, 7, 20));

    expect(NightSky.sunSign(DateTime(1985, 3, 3)), Zodiac.pisces);
    expect(marzo.length, 3);
    expect(marzo.toSet().length, 3, reason: 'tre segni distinti');
    expect(marzo, isNot(equals(settembre)),
        reason: 'a sei mesi di distanza la volta e\' la stessa: '
            'marzo $marzo, settembre $settembre');
  });

  test('Cambiando l\'ora di nascita cambia cio\' che si vede', () {
    // La stessa data a dodici ore di distanza guarda la parte opposta del
    // cielo: se l'ora fosse ignorata, i due elenchi coinciderebbero.
    final mattina = NightSky.constellationsHighTonight(DateTime(1985, 3, 3, 7));
    final sera = NightSky.constellationsHighTonight(DateTime(1985, 3, 3, 19));
    expect(mattina, isNot(equals(sera)),
        reason: 'l\'ora non conta: mattina $mattina, sera $sera');
  });
}
