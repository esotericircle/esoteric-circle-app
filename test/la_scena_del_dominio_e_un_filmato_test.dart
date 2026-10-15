import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/la_scena_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SCENA DEL DOMINIO E' UN FILMATO.** Ordine FW voce FW.03, 15 ottobre
/// 2026: il video del Maestro parte all'apertura del dominio, una volta per
/// apertura, si ferma sull'ultimo fotogramma, un tocco in qualunque punto lo
/// fa sfumare; con Riduci Movimento la scena resta ferma. Il viso del
/// Maestro non si copre: i pilastri restano nella barra, il contenuto del
/// dominio comincia sotto le spalle.
class _Finta implements LettoreDiScena {
  _Finta({this.fallira = false});
  final bool fallira;
  VoidCallback? _ascolta;
  bool _pronto = false, _fallito = false, _cominciato = false;
  bool _finito = false;
  int aperture = 0, avvii = 0, sospensioni = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    aperture++;
    fallira ? _fallito = true : _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async => sospensioni++;
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_dominio'), color: Color(0xFF102030));
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

Future<void> _monta(
  WidgetTester tester, {
  required Maestro maestro,
  required _Finta lettore,
  bool riduci = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1080, 2391);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => EntitlementService()),
      ChangeNotifierProvider(create: (_) => ProfileController()),
      ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(create: (_) => GreetingController()),
      ChangeNotifierProvider(
        create: (ctx) =>
            FeatureFlagService(entitlement: ctx.read<EntitlementService>())
              ..initialize(),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: riduci),
        child: MaestroScope(
          maestro: maestro,
          child: DomainScreen(
              maestro: maestro, fabbricaDellaScena: () => lettore),
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // In headless i sensori non esistono: si silenziano per evitare
  // l'eccezione asincrona della parallasse, che DomainScreen monta.
  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  setUp(silenceSensors);

  for (final m in Maestro.values) {
    testWidgets('FW.03 ${m.id}: il video parte una volta per apertura',
        (tester) async {
      final lettore = _Finta();
      await _monta(tester, maestro: m, lettore: lettore);
      expect(lettore.aperture, 1);
      expect(lettore.avvii, 1);
    });
  }

  testWidgets('FW.03: un tocco in qualunque punto fa sfumare il video',
      (tester) async {
    final lettore = _Finta();
    await _monta(tester, maestro: Maestro.medora, lettore: lettore);
    lettore.comincia();
    await tester.pump();
    expect(find.byKey(const Key('finta_del_filmato_dominio')), findsOneWidget);
    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(lettore.sospensioni, 1,
        reason: 'il tocco non ha fatto sospendere il lettore');
  });

  testWidgets(
      'FW.03: fermo o finito, il dominio mostra l\'ultimo fotogramma della sua scena',
      (tester) async {
    final lettore = _Finta(fallira: true);
    await _monta(tester, maestro: Maestro.caligo, lettore: lettore);
    final scena = LaScenaDelMaestro.delDominio(Maestro.caligo);
    expect(
        tester
            .widget<Image>(find.byKey(const Key('dominio_fotogramma')))
            .image,
        isA<AssetImage>().having(
            (a) => a.assetName, 'assetName', scena.ultimoFotogramma));
  });

  testWidgets('FW.03: con Riduci Movimento la scena resta ferma da subito',
      (tester) async {
    final lettore = _Finta();
    await _monta(tester, maestro: Maestro.aura, lettore: lettore, riduci: true);
    // Riduci Movimento ferma la regia prima ancora di aprire il lettore:
    // nessuna apertura, nessun filmato in scena.
    expect(lettore.aperture, 0);
    expect(find.byKey(const Key('finta_del_filmato_dominio')), findsNothing);
    final scena = LaScenaDelMaestro.delDominio(Maestro.aura);
    expect(
        tester
            .widget<Image>(find.byKey(const Key('dominio_fotogramma')))
            .image,
        isA<AssetImage>().having(
            (a) => a.assetName, 'assetName', scena.ultimoFotogramma));
  });

  testWidgets('FW.03: il tocco che salta non apre per sbaglio un pilastro',
      (tester) async {
    final lettore = _Finta();
    await _monta(tester, maestro: Maestro.medora, lettore: lettore);
    lettore.comincia();
    await tester.pump();
    // Un tocco sulla fascia dove stanno i pilastri, nella barra: il velo
    // del tocco che salta copre tutta la schermata mentre il video gira,
    // ma la barra e' fuori dal `body`, quindi i pilastri restano toccabili.
    // Qui si verifica il caso opposto, piu' comune: un tocco nel corpo
    // della scena non fa navigare da nessuna parte.
    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(DomainScreen), findsOneWidget,
        reason: 'il tocco che salta ha navigato altrove');
  });
}
