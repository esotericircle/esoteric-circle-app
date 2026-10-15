// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/la_scena_dell_oroscopo.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ANTEPRIME DELLA SCENA DELL'OROSCOPO**, ordine FU voce FU.13: a 360
/// per 797 punti logici col rapporto di pixel 3, in `docs/preview/FU/`, con
/// `--dart-define=STATO=dopo`. Il "prima" si scatta sul commit a5ebd44d con
/// la stessa apertura (l'Oroscopo come si apriva prima dell'ordine).
///
/// Il filmato vero si guarda sul telefono: qui il lettore finto disegna, al
/// posto del video finito, il suo ultimo fotogramma fermo, che coincide con
/// lui a 10,33 livelli su 255 (`docs/collaudo/FU/fu13_scena_oroscopo.txt`).
const _stato = String.fromEnvironment('STATO');

class _FilmatoFinito implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  bool _finito = false;
  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => Image.asset(LaScenaDellOroscopo.ultimoFotogramma,
      fit: BoxFit.cover, filterQuality: FilterQuality.medium);
  @override
  void chiudi() {}

  void finisci() {
    _cominciato = true;
    _finito = true;
    _ascolta?.call();
  }
}

// Roma, 15 marzo 1990, 8:30: Pesci, il Cavallo.
final _nascita = BirthDetails(
  date: DateTime(1990, 3, 15),
  time: const TimeOfDay(hour: 8, minute: 30),
  place: const BirthPlace(
      label: 'Roma', latitude: 41.9, longitude: 12.5, timezone: 'Europe/Rome'),
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaSuoneria.spentaPerLeProve = false;
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Le immagini si decodificano fuori dal tempo finto: senza, la cattura
  /// le prenderebbe vuote.
  Future<void> decodifica(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        final w = e.widget as Image;
        await precacheImage(w.image, e);
      }
    });
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await decodifica(tester);
    await passa(tester, 2);
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FU');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FU ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<_FilmatoFinito> monta(WidgetTester tester) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(_nascita, null);
    final filmato = _FilmatoFinito();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: OroscopoScreen(
            userSign: Zodiac.pisces,
            now: DateTime(2026, 10, 15),
            fabbricaDellaScena: () => filmato,
          ),
        ),
      ),
    ));
    await passa(tester, 3);
    return filmato;
  }

  /// Il video finito: gli emblemi entrano, la scena resta col segno.
  Future<void> finisceIlVideo(WidgetTester tester, _FilmatoFinito f) async {
    f.finisci();
    await tester.pump();
    await decodifica(tester);
    // La dissolvenza degli emblemi, non la sosta intera.
    await passa(tester, 9);
  }

  Future<void> saleLaLettura(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
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
    await saleLaLettura(tester);
    // La rivelazione del segno della prima volta (ordine ES voce 35) si
    // chiude con "Continua", come fa la persona.
    final continua = find.byKey(const Key('rivelazione_continua'));
    if (continua.evaluate().isNotEmpty) {
      await tester.tap(continua);
      await saleLaLettura(tester);
    }
    // Torna in cima.
    await tester.drag(
        find.byKey(const Key('oroscopo_list')), const Offset(0, 3000));
    await saleLaLettura(tester);
  }

  testWidgets('FU.13: l\'apertura, gli emblemi e la lettura salita',
      (tester) async {
    if (_stato.isEmpty) return;
    final f = await monta(tester);
    await finisceIlVideo(tester, f);
    await scatta(tester, 'fu13_1_apertura_emblemi');
    await saleLaLettura(tester);
    await scatta(tester, 'fu13_2_lettura_salita');
    // Una riga della lettura sopra il globo: si scorre finche' la prima
    // scheda passa sul globo (y del centro 272 punti a 360 per 797).
    await tester.drag(
        find.byKey(const Key('oroscopo_list')), const Offset(0, -330));
    await saleLaLettura(tester);
    await scatta(tester, 'fu13_3_testo_sul_globo');
  });

  testWidgets('FU.13: la Cinese, dodici animali; la Maya, sedi vuote',
      (tester) async {
    if (_stato.isEmpty) return;
    final f = await monta(tester);
    await finisceIlVideo(tester, f);
    await saleLaLettura(tester);
    await toccaLaTradizione(tester, AstroTradition.cinese);
    await scatta(tester, 'fu13_4_cinese');
    await toccaLaTradizione(tester, AstroTradition.maya);
    await scatta(tester, 'fu13_5_maya');
  });
}
