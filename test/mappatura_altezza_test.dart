import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
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

/// IL DISEGNO NON CONTRADDICE IL PROPRIO NUMERO.
///
/// **La contraddizione vista dall'Architetto**: la scheda diceva "Adesso sta a
/// 4 gradi sopra il suolo" e la Luna era disegnata in cima, poco sotto il
/// titolo. Quattro gradi sono appena sopra l'orizzonte: quella Luna doveva
/// stare in fondo.
///
/// **L'ipotesi era l'asse rovesciato, ed era SBAGLIATA.** La mappatura e'
/// giusta: a zero gradi la posizione vale 0,86 dell'altezza, cioe' in fondo, e
/// allo zenit 0,12, cioe' in cima. L'ho verificato prima di toccare.
///
/// **La causa vera era il RIPIEGO.** Quando l'azimut cadeva fuori dal campo
/// orizzontale, il calcolo restituiva nulla e il corpo ripiegava sullo slot
/// grafico fisso, che per la Luna sta in cima. Il numero veniva dal dato, il
/// disegno da una costante, e i due si contraddicevano.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> monta(WidgetTester tester,
      {required DateTime istante, required bool nascita}) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    tester.view.padding = const FakeViewPadding(top: 108, bottom: 72);
    tester.view.viewPadding = const FakeViewPadding(top: 108, bottom: 72);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: SkyOverviewScreen(
          now: istante,
          birth: nascita,
          luogoIniziale: const SkyPlace(latitude: 45.46, longitude: 9.19),
          location: const DisabledSkyLocation(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));
  }

  /// I gradi che la scheda dichiara per il corpo selezionato.
  double? gradiDichiarati(WidgetTester tester) {
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final d = t.data;
      if (d == null) continue;
      final m = RegExp(r'a (\d+) gradi sopra il suolo').firstMatch(d);
      if (m != null) return double.parse(m.group(1)!);
    }
    return null;
  }

  for (final nascita in const [false, true]) {
    final quale = nascita ? 'di nascita' : 'di adesso';
    testWidgets('Nel cielo $quale il disegno concorda col numero',
        (tester) async {
      await monta(tester,
          istante: DateTime(2026, 7, 31, 22, 30), nascita: nascita);

      final luna = find.byKey(const Key('sky_body_moon'));
      if (luna.evaluate().isEmpty) return;
      await tester.tap(luna, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final gradi = gradiDichiarati(tester);
      if (gradi == null) return;

      final schermo = tester.view.physicalSize.height / 3;
      final dove = tester.getRect(find.byKey(const Key('sky_body_moon'))).center;
      final quota = dove.dy / schermo;

      // Sotto i quindici gradi un corpo e' basso: non puo' stare nella meta'
      // alta dello schermo, dove sta cio' che e' vicino allo zenit.
      if (gradi < 15) {
        expect(quota, greaterThan(0.5),
            reason: 'la scheda dichiara ${gradi.round()} gradi sopra il suolo, '
                'cioe un corpo basso, e il disegno lo mette a '
                '${(quota * 100).round()} per cento dell altezza, in alto: il '
                'disegno contraddice il proprio numero');
      }
      // Sopra i sessanta un corpo e' vicino allo zenit e sta in alto.
      if (gradi > 60) {
        expect(quota, lessThan(0.5),
            reason: 'la scheda dichiara ${gradi.round()} gradi, quasi allo '
                'zenit, e il disegno lo mette in basso');
      }
    });
  }
}
