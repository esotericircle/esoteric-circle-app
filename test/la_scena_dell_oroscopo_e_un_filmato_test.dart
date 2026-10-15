import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/la_scena_dell_oroscopo.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA SCENA DELL'OROSCOPO E' UN FILMATO.** Ordine FU voce FU.13, 15
/// ottobre 2026. Il fondatore, 14 ottobre 2026: *"alla fine lei resta con
/// davanti il segno dell'utente, magari facendo vedere anche tutti gli
/// altri"*. Stessa forma delle gemelle della Stesa e della Sinastria
/// evolutiva (`test/la_scena_della_stesa_e_un_filmato_test.dart`,
/// `test/la_scena_della_sinastria_e_un_filmato_test.dart`): il video parte
/// all'apertura, una volta, e resta sull'ultimo fotogramma; da fermo, gli
/// emblemi sulla ruota; con Riduci Movimento, la grafica alleggerita o un
/// video che non si carica la scena e' ferma con gli emblemi; l'audio
/// rispetta le impostazioni e il silenzioso; il tocco salta il video.
class _Finta implements LettoreDiScena {
  _Finta({this.falliraAllApertura = false});

  final bool falliraAllApertura;
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;
  int aperture = 0;
  int avvii = 0;
  int sospensioni = 0;
  bool chiusa = false;
  final volumi = <double>[];

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;

  @override
  Future<void> apri() async {
    aperture++;
    if (falliraAllApertura) {
      _fallito = true;
    } else {
      _pronto = true;
    }
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async => volumi.add(quanto);

  @override
  Future<void> avvia() async {
    if (_finito) return;
    avvii++;
  }

  @override
  Future<void> sospendi() async => sospensioni++;

  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_oroscopo'), color: Color(0xFF203040));

  @override
  void chiudi() => chiusa = true;

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

// Roma, 15 marzo 1990, 8:30: Pesci, il Cavallo, Tula (Bilancia), 7 Akʼbʼal.
final _nascita = BirthDetails(
  date: DateTime(1990, 3, 15),
  time: const TimeOfDay(hour: 8, minute: 30),
  place: const BirthPlace(
      label: 'Roma', latitude: 41.9, longitude: 12.5, timezone: 'Europe/Rome'),
);

Future<void> _monta(
  WidgetTester tester, {
  required List<_Finta> lettori,
  bool riduci = false,
  bool suono = true,
  bool grafica = true,
}) async {
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null);
  for (final name in const [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
  ]) {
    messenger.setMockStreamHandler(EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}));
  }
  tester.view.physicalSize = const Size(360, 797);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final nascite = BirthIdentityController()..setBirth(_nascita, null);
  final finte = List.of(lettori);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => EntitlementService()),
      ChangeNotifierProvider(create: (_) {
        final q = QualityTierController();
        if (!grafica) q.setTier(QualityTier.low);
        return q;
      }),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(create: (_) => ProfileController()),
      ChangeNotifierProvider.value(value: nascite),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: suono)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: riduci),
        child: MaestroScope(child: child!),
      ),
      home: OroscopoScreen(
        userSign: Zodiac.pisces,
        now: DateTime(2026, 7, 10),
        fabbricaDellaScena: () => finte.removeAt(0),
      ),
    ),
  ));
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _scorri(WidgetTester tester, Duration quanto) async {
  final passi = quanto.inMilliseconds ~/ 100;
  for (var i = 0; i < passi; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

final _filmato = find.byKey(const Key('finta_del_filmato_oroscopo'));
final _ferma = find.byKey(const Key('oroscopo_scena_ferma'));
final _centro = find.byKey(const Key('oroscopo_emblema_al_centro'));
final _lettura = find.byKey(const Key('oroscopo_lettura'));
final _velo = find.byKey(const Key('il_tocco_che_salta'));

String _asset(WidgetTester tester, Finder f) =>
    (tester.widget<Image>(f).image as AssetImage).assetName;

/// Gli emblemi delle dodici sedi a video, nell'ordine delle sedi.
List<String> _sedi(WidgetTester tester) => [
      for (var k = 0; k < 12; k++)
        if (find.byKey(Key('oroscopo_sede_$k')).evaluate().isNotEmpty)
          _asset(tester, find.byKey(Key('oroscopo_sede_$k'))),
    ];

/// Tocca il chip della tradizione [t], come in
/// `test/la_tradizione_scelta_sta_in_cima_test.dart`.
Future<void> _toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
  final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
  await tester.ensureVisible(riga);
  await tester.pump();
  await tester.drag(riga, const Offset(2000, 0));
  await tester.pump(const Duration(milliseconds: 300));
  final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
  await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
  await tester.pump(const Duration(milliseconds: 300));
  final r = tester.getRect(chip);
  if (r.right > 360) {
    await tester.drag(riga, Offset(360 - r.right - 8, 0));
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.tap(chip);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('la geometria misurata', () {
    test('il globo e le dodici sedi stanno sulla ruota, a trenta gradi', () {
      const c = LaScenaDellOroscopo.centroDelGlobo;
      expect(LaScenaDellOroscopo.sedi, hasLength(12));
      // Il centro del globo e quello della ruota coincidono entro un pixel e
      // mezzo: la ruota e il globo sono concentrici nel fotogramma.
      for (var k = 0; k < 12; k++) {
        final d = LaScenaDellOroscopo.sedi[k] - c;
        expect(d.distance, closeTo(403, 7),
            reason: 'sede $k fuori dalla ruota');
        // L'angolo dall'alto, in senso orario: 30 gradi per sede.
        final angolo = (d.direction * 180 / 3.141592653589793 + 90 + 360) % 360;
        final atteso = (30.0 * k) % 360;
        final scarto = ((angolo - atteso + 540) % 360) - 180;
        expect(scarto.abs(), lessThan(1.5), reason: 'sede $k a $angolo gradi');
      }
      expect(LaScenaDellOroscopo.raggioDelGlobo, closeTo(171, 2));
      expect(LaScenaDellOroscopo.fotogramma, const Size(1080, 1920));
    });

    test(
        'l\'Occidentale gira in senso antiorario dal segno della persona, la '
        'Cinese in senso orario, e senza dodici segni le sedi sono vuote', () {
      final pesci = LaScenaDellOroscopo.emblemiDelleSedi(
          AstroTradition.occidentale, null, Zodiac.pisces)!;
      expect(pesci.first, 'assets/img/zodiac/zod_pesci.webp');
      expect(pesci[11], 'assets/img/zodiac/zod_ariete.webp',
          reason: 'il segno che segue i Pesci sta alla loro sinistra');
      expect(pesci[1], 'assets/img/zodiac/zod_acquario.webp');
      expect(pesci.toSet(), hasLength(12));
      final nascita = NascitaDeiSegni.daiDettagli(_nascita);
      final cavallo = LaScenaDellOroscopo.emblemiDelleSedi(
          AstroTradition.cinese,
          ISegniDelleTradizioni.per(AstroTradition.cinese, nascita),
          Zodiac.pisces)!;
      expect(cavallo.first, 'assets/img/zodiac/zod_cinese_cavallo.webp');
      expect(cavallo[1], 'assets/img/zodiac/zod_cinese_capra.webp');
      expect(cavallo.toSet(), hasLength(12));
      final tula = LaScenaDellOroscopo.emblemiDelleSedi(
          AstroTradition.vedica,
          ISegniDelleTradizioni.per(AstroTradition.vedica, nascita),
          Zodiac.pisces)!;
      expect(tula.first, 'assets/img/zodiac/zod_bilancia.webp');
      expect(tula, contains('assets/img/zodiac/zod_vedica_mithuna.webp'));
      expect(tula, contains('assets/img/zodiac/zod_vedica_makara.webp'));
      expect(tula.toSet(), hasLength(12));
      for (final t in [
        AstroTradition.maya,
        AstroTradition.celtica,
        AstroTradition.egizia,
        AstroTradition.araba,
      ]) {
        expect(
            LaScenaDellOroscopo.emblemiDelleSedi(
                t, ISegniDelleTradizioni.per(t, nascita), Zodiac.pisces),
            isNull,
            reason: '${t.name} non ha dodici segni: le sedi restano vuote');
      }
    });
  });

  testWidgets(
      'aprendo l\'Oroscopo il filmato parte, resta sull\'ultimo fotogramma, '
      'poi gli emblemi si accendono e la lettura sale', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il filmato non parte all\'apertura');
    expect(finta.volumi.last, 1.0);
    expect(_lettura, findsNothing,
        reason: 'mentre il video gira la lettura non e\' ancora salita');
    expect(_centro, findsNothing);

    finta.comincia();
    await tester.pump();
    expect(_filmato, findsOneWidget);
    expect(_velo, findsOneWidget, reason: 'col video in corso il tocco salta');

    finta.finisci();
    await tester.pump();
    expect(_filmato, findsOneWidget,
        reason: 'a filmato finito resta l\'ultimo fotogramma');
    expect(_centro, findsOneWidget,
        reason: 'a filmato finito l\'emblema non compare nel globo');
    expect(_asset(tester, _centro), 'assets/img/zodiac/zod_pesci.webp');
    expect(_sedi(tester), hasLength(12));
    expect(_sedi(tester).first, 'assets/img/zodiac/zod_pesci.webp',
        reason: 'nella sede del Sole va il segno della persona');
    expect(_lettura, findsNothing,
        reason: 'la lettura sale dopo la sosta sugli emblemi, non subito');

    await _scorri(
        tester,
        LaScenaDellOroscopo.dissolvenzaDegliEmblemi +
            LaScenaDellOroscopo.sostaSugliEmblemi +
            LaScenaDellOroscopo.salitaDellaLettura +
            const Duration(milliseconds: 1600));
    expect(_lettura, findsOneWidget, reason: 'la lettura non e\' salita');
    expect(find.byKey(const Key('oroscopo_sign_name')), findsOneWidget);
    expect(finta.avvii, 1, reason: 'il filmato e\' ripartito');
    final velo = tester
        .widget<AnimatedOpacity>(find.byKey(const Key('oroscopo_scena_velo')));
    expect(velo.opacity, LaScenaDellOroscopo.veloDietroLaLettura,
        reason: 'dietro la lettura la scena resta scura');
    expect(finta.chiusa, isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(finta.chiusa, isTrue, reason: 'il lettore non si chiude');
  });

  testWidgets('un tocco sulla scena ferma fa salire la lettura prima',
      (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta
      ..comincia()
      ..finisci();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_lettura, findsNothing);
    await tester.tapAt(const Offset(180, 600));
    await tester.pump();
    expect(_lettura, findsOneWidget);
    await _scorri(tester, const Duration(seconds: 3));
  });

  testWidgets(
      'FU.15: un tocco mentre il video gira lo fa sfumare, gli emblemi e la '
      'lettura compaiono subito, e il tocco non arriva alla scena sotto',
      (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump();
    expect(tester.getRect(_velo).size, const Size(360, 797),
        reason: 'il tocco che salta non copre tutto lo schermo');
    await tester.tapAt(const Offset(180, 400));
    await tester.pump();
    expect(finta.sospensioni, 1, reason: 'il tocco non ha fermato il video');
    expect(_velo, findsNothing);
    expect(_centro, findsOneWidget,
        reason: 'saltato il video, gli emblemi compaiono subito');
    expect(_lettura, findsOneWidget,
        reason: 'saltato il video, la lettura compare subito');
    final sfuma = tester.widget<IlFilmatoCheSfuma>(
        find.byKey(const Key('oroscopo_scena_filmato')));
    expect(sfuma.saltato, isTrue, reason: 'il video non sfuma');
    expect(_ferma, findsOneWidget,
        reason: 'sotto il video c\'e\' la scena ferma');
    await _scorri(tester, const Duration(seconds: 3));
    expect(finta.avvii, 1, reason: 'il video saltato e\' ripartito');
  });

  for (final (nome, riduci, grafica, fallira) in [
    ('con Riduci Movimento', true, true, false),
    ('con la grafica alleggerita', false, false, false),
    ('se il video non si carica', false, true, true),
  ]) {
    testWidgets('$nome la scena e\' ferma, con gli emblemi e la lettura',
        (tester) async {
      final finta = _Finta(falliraAllApertura: fallira);
      await _monta(tester, lettori: [finta], riduci: riduci, grafica: grafica);
      expect(finta.avvii, 0, reason: '$nome il filmato parte');
      if (!fallira) expect(finta.aperture, 0, reason: '$nome si apre');
      expect(_filmato, findsNothing);
      expect(_ferma, findsOneWidget, reason: 'manca la scena ferma');
      expect(_asset(tester, _ferma), LaScenaDellOroscopo.ultimoFotogramma);
      expect(_centro, findsOneWidget, reason: 'manca l\'emblema al centro');
      expect(_sedi(tester), hasLength(12));
      expect(_lettura, findsOneWidget,
          reason: 'a scena ferma la lettura e\' al suo posto');
      await _scorri(tester, const Duration(seconds: 2));
    });
  }

  testWidgets('a suoni spenti nell\'app il filmato e\' muto', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta], suono: false);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
    expect(finta.avvii, 1);
  });

  testWidgets('col telefono in silenzioso il filmato e\' muto', (tester) async {
    LaSuoneria.spentaPerLeProve = true;
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
    expect(finta.avvii, 1, reason: 'muto, ma il filmato parte lo stesso');
  });

  testWidgets(
      'uscendo dall\'app il filmato si ferma, e al ritorno riprende se non '
      'e\' finito', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(finta.sospensioni, greaterThanOrEqualTo(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 200));
    expect(finta.avvii, 2);
  });

  testWidgets(
      'una volta per apertura: cambiare tradizione non fa ripartire il '
      'video, e le sedi seguono la tradizione aperta', (tester) async {
    final finta = _Finta(falliraAllApertura: true);
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(_sedi(tester).first, 'assets/img/zodiac/zod_pesci.webp');

    await _toccaLaTradizione(tester, AstroTradition.cinese);
    expect(finta.aperture, 1, reason: 'cambiando tradizione il video riparte');
    expect(
        _asset(tester, _centro), 'assets/img/zodiac/zod_cinese_cavallo.webp');
    expect(_sedi(tester), hasLength(12),
        reason: 'la Cinese ha dodici segni: le sedi portano i suoi emblemi');
    expect(_sedi(tester).first, 'assets/img/zodiac/zod_cinese_cavallo.webp');

    await _toccaLaTradizione(tester, AstroTradition.maya);
    expect(_asset(tester, _centro),
        'assets/img/zodiac/emblema_tradizione_maya.webp');
    expect(_sedi(tester), isEmpty,
        reason: 'la Maya non ha dodici segni: le sedi restano vuote');
    expect(find.byKey(const Key('oroscopo_sede_accesa_0')), findsOneWidget,
        reason: 'le sedi vuote restano accese');
    expect(finta.aperture, 1);
    await _scorri(tester, const Duration(seconds: 2));
  });
}
