import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
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

/// La posizione concessa cambia il cielo per davvero.
///
/// Erano tre difetti dentro uno, con una causa radice sola: **il motore del
/// cielo non era collegato alla schermata**. `buildSkySnapshot` esisteva, sapeva
/// calcolare alt-azimut da latitudine, longitudine e ora, e nessuno lo
/// chiamava: verificato, zero chiamanti in tutto il progetto. La schermata
/// disegnava una volta procedurale e, quando arrivava la posizione, spostava il
/// disegno di un offset grafico.
///
/// Da qui i tre sintomi: la posizione non arrivava a nessun calcolo, il banner
/// dichiarava un orientamento che non era avvenuto, e l'invito si riproponeva a
/// ogni ingresso perche' il consenso viveva in un campo di stato che nasce falso
/// a ogni montaggio.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Il luogo di nascita, lontano da quello finto del dispositivo.
  const nascita = BirthPlace(
    city: 'Busto Arsizio',
    latitude: 45.61,
    longitude: 8.85,
    timeZoneId: 'Europe/Rome',
    utcOffsetMinutes: 120,
  );

  /// La posizione del dispositivo: un'altra latitudine, per poterle distinguere.
  const dispositivo = SkyPlace(latitude: -33.87, longitude: 151.21);

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

  Future<void> apri(
    WidgetTester tester, {
    required SkyLocation posizione,
    double altezza = 2532,
  }) async {
    silence();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezza);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profilo = ProfileController();
    profilo.setIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1990, 5, 12),
      birthHour: 7,
      birthMinute: 20,
      birthPlace: nascita,
    ));
    addTearDown(profilo.dispose);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileController>.value(value: profilo),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SkyOverviewScreen(location: posizione),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// Il valore mostrato nel riquadro dei metodi, per nome della riga.
  String valore(WidgetTester tester, String nome) =>
      tester.widget<Text>(find.byKey(Key('sky_valore_$nome'))).data!;

  Future<void> apriFonti(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('sky_fonti_apri')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Senza posizione il cielo usa il luogo di nascita, e lo dice',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const DisabledSkyLocation());
    await apriFonti(tester);

    expect(find.byKey(const Key('sky_fonti_valori')), findsOneWidget,
        reason: 'il cielo non e\' stato calcolato affatto');
    expect(valore(tester, 'Coordinate da'), 'luogo di nascita');
    expect(double.parse(valore(tester, 'Latitudine')),
        closeTo(nascita.latitude, 0.01));
  });

  testWidgets(
      'Concessa la posizione, il calcolo usa le coordinate del '
      'dispositivo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const _PosizioneFinta(dispositivo));

    // Il pre-avviso, poi la concessione.
    expect(find.byKey(const Key('sky_location_prompt')), findsOneWidget,
        reason: 'al primo ingresso l\'invito non compare');
    await tester.tap(find.byKey(const Key('sky_location_accept')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await apriFonti(tester);
    expect(valore(tester, 'Coordinate da'), 'posizione del dispositivo',
        reason: 'il calcolo usa ancora il luogo di nascita');
    final lat = double.parse(valore(tester, 'Latitudine'));
    expect(lat, closeTo(dispositivo.latitude, 0.01),
        reason: 'la latitudine del calcolo non e\' quella del dispositivo');
    expect((lat - nascita.latitude).abs(), greaterThan(10),
        reason: 'le due latitudini non differiscono, quindi la prova non '
            'distingue nulla');
  });

  testWidgets('Il banner parla di cielo ricalcolato, non di semplice permesso',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const _PosizioneFinta(dispositivo));
    await tester.tap(find.byKey(const Key('sky_location_accept')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('sky_location_concessa')), findsOneWidget,
        reason:
            'concessa la posizione e ricalcolato il cielo, nessuno lo dice');
  });

  testWidgets('Rientrando, l\'invito non ricompare', (tester) async {
    // Il consenso e' gia' stato dato in una visita precedente.
    SharedPreferences.setMockInitialValues(
        {'cielo_posizione_concessa_v1': true});
    await apri(tester, posizione: const _PosizioneFinta(dispositivo));

    expect(find.byKey(const Key('sky_location_prompt')), findsNothing,
        reason: 'l\'invito si ripropone a chi ha gia\' concesso la posizione');

    // E il cielo e' comunque quello del dispositivo, senza dover riaccettare.
    await tester.pump(const Duration(milliseconds: 600));
    await apriFonti(tester);
    expect(valore(tester, 'Coordinate da'), 'posizione del dispositivo',
        reason: 'saltato l\'invito, il cielo non viene orientato');
  });

  testWidgets('Negata la posizione, non si dichiara nessun orientamento',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const _PosizioneNegata());
    await tester.tap(find.byKey(const Key('sky_location_accept')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('sky_location_concessa')), findsNothing,
        reason: 'la posizione e\' stata negata e l\'app dichiara il cielo '
            'orientato');
    await apriFonti(tester);
    expect(valore(tester, 'Coordinate da'), 'luogo di nascita');
  });

  testWidgets('Il riquadro del metodo porta i valori verificabili',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const DisabledSkyLocation());
    await apriFonti(tester);

    // Ognuno di questi si confronta con un'effemeride in trenta secondi.
    for (final riga in const [
      'Latitudine',
      'Longitudine',
      'Coordinate da',
      'Istante locale',
      'Istante in UT',
      'Luna illuminata',
      'Fase',
      'Luna nel segno',
    ]) {
      expect(find.byKey(Key('sky_valore_$riga')), findsOneWidget,
          reason: 'manca la riga "$riga" fra i valori del calcolo');
    }
    expect(find.byKey(const Key('sky_fonti_costellazioni')), findsOneWidget,
        reason: 'non si dichiara quali costellazioni il motore considera '
            'visibili adesso');
    expect(valore(tester, 'Luna illuminata'), contains('per cento'));
  });

  testWidgets('Toccando la Luna si legge un dato calcolato di adesso',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, posizione: const DisabledSkyLocation());

    await tester.tap(find.byKey(const Key('sky_body_moon')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // La scheda si e' ridotta a due sole cose, e il dato calcolato vive adesso
    // nella riga delle COORDINATE: nome, gradi sopra il suolo e direzione, piu'
    // la fase per la Luna. Con gli slot fissi quella riga e' l'unica cosa
    // esatta rimasta a schermo, quindi e' li' che va guardata.
    final dato = find.byKey(const Key('sky_coordinate'));
    expect(dato, findsOneWidget,
        reason: 'la scheda della Luna non porta nessun dato calcolato: due '
            'righe generiche su un cielo che si dichiara adesso');
    final testo = tester.widget<Text>(dato).data!;
    expect(testo, contains('per cento'),
        reason: 'manca la percentuale di illuminazione: $testo');
    expect(RegExp(r'[0-9]').hasMatch(testo), isTrue,
        reason: 'il dato non contiene nessun numero, quindi non e un dato');
  });
}

/// Una posizione che concede sempre, con coordinate fissate.
class _PosizioneFinta extends SkyLocation {
  const _PosizioneFinta(this._luogo);

  final SkyPlace _luogo;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => _luogo;

  @override
  Future<SkyPlace?> resolveSeConcesso() async => _luogo;
}

/// Una posizione che nega sempre.
class _PosizioneNegata extends SkyLocation {
  const _PosizioneNegata();

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => null;

  @override
  Future<SkyPlace?> resolveSeConcesso() async => null;
}
