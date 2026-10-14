import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_approfondita/cielo_approfondito.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/lo_studio_di_medora.dart';
import 'package:esoteric_circle/features/synastry/sinastria_approfondita_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA SCENA DELLA SINASTRIA APPROFONDITA E' UN FILMATO.** Ordine FT voce
/// FT.02, 14 ottobre 2026. Stessa forma della guardia gemella del
/// Tarocchi, `test/la_scena_della_stesa_e_un_filmato_test.dart` (FS voce
/// A2): il video parte all'apertura, nello stesso riquadro dello sfondo, si
/// ferma sull'ultimo fotogramma, una volta per apertura; con Riduci
/// Movimento o un video che non si carica la scena resta ferma; l'audio
/// rispetta le impostazioni dell'app e il silenzioso.
class _Finta implements LettoreDellaScenaSinastria {
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
      key: Key('finta_del_filmato_sinastria'), color: Color(0xFF203040));

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

final _marco = CieloApprofondito.perNascita(
    momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Marco');
final _giulia = CieloApprofondito.perNascita(
    momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Giulia');

Future<void> _monta(
  WidgetTester tester, {
  required List<_Finta> lettori,
  bool riduci = false,
  bool suono = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final finte = List.of(lettori);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: suono)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(390, 844), disableAnimations: riduci),
        child: MaestroScope(
          child: SinastriaApprofonditaScreen(
            nomeTuo: 'Marco',
            cieloTuo: _marco,
            nomeSuo: 'Giulia',
            cieloSuo: _giulia,
            fabbricaDellaScena: () => finte.removeAt(0),
          ),
        ),
      ),
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

String? _posa(WidgetTester tester) {
  final f = find.byKey(const Key('studio_medora'));
  if (f.evaluate().isEmpty) return null;
  final img = tester.widget<Image>(f);
  return (img.image as AssetImage).assetName;
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('il taglio del filmato', () {
    test('il riquadro copre lo sfondo dal pixel 0 al 1223, a tutta larghezza',
        () {
      final larghezze = [360.0, 390.0, 430.0];
      for (final w in larghezze) {
        final r = ScenaDellaSinastriaInVideo.nellaScena(w);
        final s = GeometriaDelloStudio.scala(w);
        expect(r.left, 0);
        expect(r.width, w);
        expect(r.top, closeTo(0, 1e-9));
        expect(r.height, closeTo(1223 * s, 1e-9));
        expect(r.width / r.height, closeTo(720 / 1280, 0.001));
      }
    });

    test('il filmato e le due pose esistono e sono dichiarati', () {
      expect(ScenaDellaSinastriaInVideo.filmato,
          'brand_assets/sinastria/medora_astrolabio_in_polvere_v1.mp4');
      expect(GeometriaDelloStudio.posaDellAstrolabio,
          'assets/img/sinastria/medora_astrolabio_v1.webp');
      expect(GeometriaDelloStudio.posaDelleManiAperte,
          'assets/img/sinastria/medora_mani_aperte_v1.webp');
    });
  });

  testWidgets(
      'aprendo la Sinastria approfondita il filmato parte, prende il posto '
      'di Medora ferma e resta sull\'ultimo fotogramma', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il filmato non parte all\'apertura');
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 1.0);
    expect(_posa(tester), GeometriaDelloStudio.posaDellAstrolabio);
    expect(find.byKey(const Key('finta_del_filmato_sinastria')), findsNothing);

    finta.comincia();
    await tester.pump();
    expect(
        find.byKey(const Key('finta_del_filmato_sinastria')), findsOneWidget);
    expect(_posa(tester), isNull,
        reason: 'col filmato in scena Medora ferma resta sopra');

    finta.finisci();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
        find.byKey(const Key('finta_del_filmato_sinastria')), findsOneWidget,
        reason: 'a filmato finito resta l\'ultimo fotogramma');
    expect(finta.avvii, 1, reason: 'il filmato e\' ripartito');
    expect(finta.chiusa, isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(finta.chiusa, isTrue, reason: 'il lettore non si chiude');
  });

  testWidgets(
      'con Riduci Movimento la scena e\' ferma, con la posa a mani aperte',
      (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta], riduci: true);
    expect(finta.aperture, 0,
        reason: 'con Riduci Movimento il filmato si apre');
    expect(find.byKey(const Key('finta_del_filmato_sinastria')), findsNothing);
    expect(_posa(tester), GeometriaDelloStudio.posaDelleManiAperte);
  });

  testWidgets('se il filmato non si carica la scena e\' ferma, a mani aperte',
      (tester) async {
    final finta = _Finta(falliraAllApertura: true);
    await _monta(tester, lettori: [finta]);
    expect(finta.avvii, 0);
    expect(find.byKey(const Key('finta_del_filmato_sinastria')), findsNothing);
    expect(_posa(tester), GeometriaDelloStudio.posaDelleManiAperte);
  });

  testWidgets('a suoni spenti nell\'app il filmato e\' muto', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta], suono: false);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
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

  testWidgets('gli aspetti veri entrano nella schermata', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(find.byKey(const Key('sinastria_approfondita_nomi')),
        findsOneWidget);
    expect(find.textContaining('Marco'), findsWidgets);
  });
}
