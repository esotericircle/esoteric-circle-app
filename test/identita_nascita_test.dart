import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/numerology.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/risveglio_journey.dart';
import 'package:esoteric_circle/features/onboarding/sigillo_step.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'identita' di nascita deve essere quella della persona, non un esempio.
///
/// Alla prima accensione su dispositivo il Cosmic Passport mostrava sempre il
/// profilo d'esempio, con numero della vita, fase lunare e animale guida di una
/// data che non era quella di nessuno, e la riga "Valore d'esempio" sempre
/// accesa. L'identita' vera era gia' raccolta a onboarding e persistita: solo,
/// nessuno la passava alla schermata.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // L'elenco pieno dei luoghi si legge dal disco una volta sola, in modo
  // sincrono: il seme non contiene Busto Arsizio, e dentro un test di widget
  // l'attesa sull'asset non avanzerebbe mai.
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

  /// Una nascita vera, con luogo noto: il 3 marzo 1985 a Busto Arsizio.
  final nascitaVera = BirthIdentity.fromParts(
    birthDate: DateTime(1985, 3, 3),
    birthHour: 7,
    birthMinute: 20,
  );

  /// Apre l'app come alla vera accensione: le preferenze contengono gia' quel
  /// che l'onboarding ha scritto, e da li' in poi non si inietta piu' nulla a
  /// mano. Passare l'identita' direttamente alla schermata non proverebbe
  /// niente, perche' il difetto sta nel tratto fra il profilo persistito e la
  /// schermata, che nessuno percorreva.
  Future<void> apriIlPassport(WidgetTester tester,
      {BirthIdentity? registrata}) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Il Risveglio e' gia' stato attraversato in un avvio precedente. Scrivere
    // sulle preferenze e' I/O vera, quindi va dentro runAsync: nel tempo finto
    // di un test di widget un'attesa su I/O non avanzerebbe mai.
    await tester.runAsync(() async {
      await OnboardingController().complete();
      if (registrata != null) {
        ProfileController().setIdentity(registrata);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });

    await tester.pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passo(tester);
    await tester.tap(find.text('Passport'));
    await passo(tester);
    await passo(tester);
  }

  group('Il Passport legge l\'identita\' vera', () {
    testWidgets('Con identita\' reale non compare nessun valore d\'esempio',
        (tester) async {
      await apriIlPassport(tester, registrata: nascitaVera);

      expect(find.textContaining('Valore d\'esempio'), findsNothing);
      // Il numero della vita e' quello della data vera, non quello dell'esempio.
      final atteso = LifePath.forDate(DateTime(1985, 3, 3));
      final esempio = LifePath.forDate(BirthIdentity.example.birthMoment);
      expect(atteso.number, isNot(esempio.number));
      expect(find.textContaining('${atteso.number} · '), findsWidgets);
      expect(find.textContaining('${esempio.number} · '), findsNothing);
    });

    testWidgets('Senza identita\' la riga d\'esempio resta', (tester) async {
      await apriIlPassport(tester);

      expect(find.textContaining('Valore d\'esempio'), findsWidgets);
    });
  });

  group('Basta coordinate inventate', () {
    testWidgets('Saltando il luogo non nasce nessun luogo finto',
        (tester) async {
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester
          .pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
      await passo(tester);
      await passo(tester);

      Future<void> avanti() async {
        await tester.tap(find.byKey(const Key('onboarding_continue')));
        await passo(tester);
      }

      // Accoglienza, data, ora, poi il luogo che si salta.
      await avanti();
      await avanti();
      await avanti();
      expect(find.text('Salta per ora'), findsOneWidget,
          reason: 'senza luogo scelto l\'azione dichiara che si salta');
      await avanti();

      await tester.enterText(
          find.byKey(const Key('risveglio_nome_field')), 'Marco');
      await passo(tester);
      await avanti();
      await tester.tap(find.byKey(const Key('vocativo_lui')));
      await passo(tester);
      await avanti();
      // Il Sigillo si tiene premuto per il tempo dichiarato, poi il trionfo
      // scorre prima del passaggio: un long press secco non basta piu', e non
      // deve bastare, perche' il trionfo va visto.
      final dito = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('risveglio_sigillo'))));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(SigilloStep.attesa + const Duration(milliseconds: 60));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 160));
      }
      await dito.up();
      await passo(tester);
      await passo(tester);

      // Il rito e' finito: si guarda cosa e' stato consegnato al motore.
      final journey =
          tester.widget<RisveglioJourney>(find.byType(RisveglioJourney));
      final place = journey.details.place;
      // Il punto zero zero e' in mezzo al Golfo di Guinea. Chiedere la carta
      // per quel punto vuol dire dare alla persona l'Ascendente e le dodici
      // case di un luogo che non e' il suo, mentre la schermata promette il
      // cielo autentico della sua notte.
      if (place != null) {
        expect(place.latitude == 0 && place.longitude == 0, isFalse,
            reason: 'luogo fabbricato: ${place.label} '
                '${place.latitude},${place.longitude} ${place.timezone}');
      }
      expect(place, isNull,
          reason: 'senza luogo scelto non si inventa un luogo');
    });

    testWidgets('Scegliendo un luogo l\'azione diventa Continua',
        (tester) async {
      silence();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester
          .pumpWidget(EsotericCircleApp(conIntro: false, services: AppServices.offline()));
      await passo(tester);
      await passo(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('onboarding_continue')));
        await passo(tester);
      }

      // Senza luogo: si salta, e la schermata dice cosa si perde.
      expect(find.text('Salta per ora'), findsOneWidget);
      expect(find.byKey(const Key('risveglio_luogo_nota')), findsOneWidget);
      expect(find.textContaining('Ascendente'), findsOneWidget);

      // Si cerca e si sceglie: il suggerimento e' un tocco vero.
      //
      // **Si scrive un nome PARZIALE.** Dall'ordine 2169 voce 1, scrivere per
      // intero il nome di una citta' che nel catalogo e' unica la sceglie da
      // sola e l'elenco non compare: qui si vuole misurare l'altra strada,
      // quella del tocco sul suggerimento.
      await tester.enterText(
          find.byKey(const Key('risveglio_luogo_field')), 'busto Arsiz');
      await passo(tester);
      expect(find.byKey(const Key('citta_Busto Arsizio_VA')), findsOneWidget);
      await tester.tap(find.byKey(const Key('citta_Busto Arsizio_VA')));
      await passo(tester);

      // Col luogo scelto l'azione cambia parola e la nota non serve piu'.
      expect(find.text('Continua'), findsOneWidget);
      expect(find.text('Salta per ora'), findsNothing);
      expect(find.byKey(const Key('risveglio_luogo_nota')), findsNothing);
    });

    test('Senza luogo la carta natale non si chiede nemmeno', () async {
      final chiamate = <Map<String, Object?>>[];
      final client = FreeAstroClient(caller: (data) async {
        chiamate.add(data);
        return <String, Object?>{};
      });

      await expectLater(
        client.fetchNatalChart(BirthDetails(date: DateTime(1985, 3, 3))),
        throwsA(isA<AstroApiException>()),
      );
      expect(chiamate, isEmpty,
          reason: 'senza luogo non parte nessuna chiamata');
    });

    test('Col luogo vero il payload porta le sue coordinate', () async {
      final chiamate = <Map<String, Object?>>[];
      final client = FreeAstroClient(caller: (data) async {
        chiamate.add(data);
        throw StateError('basta il payload');
      });

      await expectLater(
        client.fetchNatalChart(BirthDetails(
          date: DateTime(1985, 3, 3),
          time: const TimeOfDay(hour: 7, minute: 20),
          place: const BirthPlace(
            label: 'Busto Arsizio',
            latitude: 45.6122,
            longitude: 8.8427,
            timezone: 'Europe/Rome',
          ),
        )),
        throwsA(isA<AstroApiException>()),
      );
      expect(chiamate, hasLength(1));
      final p = chiamate.single;
      expect(p['lat'], 45.6122);
      expect(p['lng'], 8.8427);
      expect(p['tz_str'], 'Europe/Rome');
      expect(p['lat'] == 0 && p['lng'] == 0, isFalse);
    });
  });

  group('Il cielo di nascita parla al tempo giusto', () {
    testWidgets('Nella schermata di nascita non compare la parola stanotte',
        (tester) async {
      silence();
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(430, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: SkyOverviewScreen(
              now: nascitaVera.birthMoment,
              birth: true,
              location: const DisabledSkyLocation(),
            ),
          ),
        ),
      ));
      await passo(tester);

      // Si guardano tutti i testi montati, non solo quelli in vista: una
      // didascalia sbagliata dietro un tocco resta sbagliata.
      final testi = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((s) => s.isNotEmpty);
      expect(testi, isNotEmpty);
      for (final t in testi) {
        expect(t.toLowerCase().contains('stanotte'), isFalse,
            reason: 'testo preso in prestito dal cielo di stasera: $t');
      }
    });

    test('La didascalia della Luna di nascita non dice stanotte', () {
      // La stessa riga serve due schermate, il cielo di stanotte e quello della
      // notte in cui la persona e' nata: il tempo verbale deve seguire il
      // contesto, altrimenti la nascita viene raccontata al presente.
      for (var g = 0; g < 30; g++) {
        final fase = MoonPhase.forDate(DateTime(1985, 3, 1 + g));
        final nascita = NightSky.describeMoon(fase, birth: true);
        expect(nascita.contains('stanotte'), isFalse,
            reason: 'la riga di nascita non parla di stanotte: $nascita');
        final stasera = NightSky.describeMoon(fase);
        expect(stasera.isNotEmpty, isTrue);
      }
    });
  });
}
