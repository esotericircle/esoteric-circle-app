// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/confronto_del_cielo_screen.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DELL'ORDINE FT, prima e dopo.** Voce FT.15: a 360 per 797
/// punti logici col rapporto di pixel 3, in `docs/preview/FT/`. Si generano
/// con `--dart-define=STATO=prima` sul codice di partenza (53dd7be2, la barra
/// dei Tarocchi gia' corretta e niente dell'ordine FT) e con `STATO=dopo` sul
/// codice dell'ordine. Questo file compila su tutti e due: le schermate nuove
/// della Sinastria approfondita, che prima non c'erano, stanno in
/// `le_anteprime_della_sinastria_approfondita_test.dart`.
///
/// Senza STATO la prova non monta niente e non scrive niente.
const _stato = String.fromEnvironment('STATO');

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

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FT');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FT ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, Widget schermata) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)),
          oggi: DateTime(2026, 10, 14));
      await sociale.caricaIlCerchio();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: figlio!),
          ),
          home: schermata,
        ),
      ),
    ));
    await passa(tester);
  }

  testWidgets('FT.14: il confronto del cielo, in fondo', (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(
        tester,
        ConfrontoDelCieloScreen(
            amico: amico, mioSegno: Zodiac.leo, oggi: DateTime(2026, 10, 14)));
    final s = tester.state<ScrollableState>(find.byType(Scrollable).first);
    s.position.jumpTo(s.position.maxScrollExtent);
    await passa(tester, 4);
    await scatta(tester, 'ft14_confronto_in_fondo');
  });

  testWidgets('FT.13: la card del Viandante e la tabella dei piani',
      (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const PricingScreen(isDemo: true));
    final vip = find.text('Sinastria VIP fino a 3 al giorno');
    await tester.scrollUntilVisible(vip, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(vip);
    await passa(tester, 4);
    await scatta(tester, 'ft13_card_del_viandante');

    await tester.scrollUntilVisible(find.byKey(const Key('pricing_table')), 400,
        scrollable: find.byType(Scrollable).first);
    final riga = find.descendant(
        of: find.byKey(const Key('pricing_table')),
        matching: find.text('Sinastria VIP'));
    await tester.ensureVisible(riga);
    await passa(tester, 4);
    await scatta(tester, 'ft13_tabella_dei_piani');
  });
}
