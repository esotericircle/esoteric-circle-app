import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LO SPAZIO FRA LA DOMANDA E IL PULSANTE. Ordine S voce 22.
///
/// **Il difetto.** Fra i pulsanti del tipo di gettata e il getto stavano 140 punti
/// di pozzo in attesa. L'ordine L voce 2a li aveva scelti di proposito, portandoli
/// da 300 a 140 e chiamandoli "un accenno, non una scena vuota". **Misurato sulla
/// resa, quell'accenno non veniva dipinto:** nella banda di 140 punti l'inchiostro
/// stava su 8 righe su 140, con al massimo 4 pixel chiari per riga, cioe' le stelle
/// del fondale che passano dietro.
///
/// **PERCHE' SI MISURA SULLA RESA e non sul sorgente.** Il censimento degli spazi
/// conta i `SizedBox` senza figlio, cioe' i vuoti SCRITTI: un vuoto che nasce da un
/// widget che occupa spazio e non dipinge niente non lo vede nessuno. E' la stessa
/// ragione della voce S.10.
///
/// **QUESTA PROVA NON VIETA UN ACCENNO, vieta un vuoto.** Se un giorno si vuole
/// qualcosa fra la domanda e il pulsante, basta che sia DIPINTO: una banda con
/// inchiostro passa, una banda di niente no.
void main() {
  void silenceSensors(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
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

  /// **LA SOGLIA, DICHIARATA: quaranta punti.**
  ///
  /// Non e' il vuoto che c'era (140) ne' quello che resta: e' la misura sotto la
  /// quale una banda senza inchiostro e' respiro e non buco. I distacchi di sezione
  /// dell'app arrivano a 32 punti (`SpacingTokens.xl`), quindi quaranta lascia
  /// passare un distacco pieno con un margine e non lascia passare due distacchi
  /// messi in fila per sbaglio.
  const double vuotoMassimo = 40;

  /// Quanti pixel chiari fanno "questa riga porta qualcosa". Tre, perche' una o
  /// due sono le stelle del fondale, che passano dietro qualunque cosa.
  const int inchiostroDiUnaRiga = 3;

  testWidgets('fra la domanda e il pulsante non c\'e\' una banda vuota',
      (tester) async {
    silenceSensors(tester);
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) =>
            RepaintBoundary(key: chiave, child: MaestroScope(child: child!)),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
      ),
    ));
    // Frami dichiarati: la comparsa degli elementi ha un ritardo per strato, e
    // misurare prima che finisca vorrebbe dire misurare l'inchiostro a metа.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    final riga = tester.getRect(find.byKey(const Key('rune_senza_domanda')));
    final bottone = tester.getRect(find.byKey(const Key('rune_cast_button')));
    expect(bottone.top, greaterThan(riga.bottom),
        reason: 'il pulsante del getto non sta sotto la riga della domanda: '
            'questa prova sta misurando la banda sbagliata');

    late final int righeVuoteDiFila;
    late final double bandaVuota;
    await tester.runAsync(() async {
      final boundary =
          chiave.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final w = image.width;
      var correnteMax = 0;
      var corrente = 0;
      for (var y = riga.bottom.round(); y < bottone.top.round(); y++) {
        var chiari = 0;
        for (var x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          final l = 0.2126 * px[i] + 0.7152 * px[i + 1] + 0.0722 * px[i + 2];
          if (l >= 130) chiari++;
        }
        if (chiari < inchiostroDiUnaRiga) {
          corrente++;
          correnteMax = max(correnteMax, corrente);
        } else {
          corrente = 0;
        }
      }
      righeVuoteDiFila = correnteMax;
      bandaVuota = bottone.top - riga.bottom;
    });

    // ignore: avoid_print
    print('ORDINE S VOCE 22: fra la riga della domanda e il pulsante ci sono '
        '${bandaVuota.toStringAsFixed(1)} punti, di cui $righeVuoteDiFila '
        'senza inchiostro di fila (soglia $vuotoMassimo)');
    expect(righeVuoteDiFila, lessThanOrEqualTo(vuotoMassimo.round()),
        reason: 'fra la domanda e il pulsante del getto ci sono '
            '$righeVuoteDiFila punti di fila in cui non si dipinge niente. Se '
            'quello spazio deve ospitare un accenno, va DIPINTO: una banda con '
            'inchiostro passa questa prova, una banda di niente no');
  });

  testWidgets('il pozzo compare col getto, non prima', (tester) async {
    silenceSensors(tester);
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    // **PRIMA DEL GETTO IL POZZO NON C'E'**, ed e' la differenza fra questa voce e
    // una riduzione: 140 punti che non dipingono niente non si accorciano, si
    // togliono. Il pozzo appare col getto, dove ha le pietre da mostrare.
    expect(find.byKey(const Key('rune_well')), findsNothing,
        reason: 'il pozzo in attesa e\' tornato fra la domanda e il pulsante');

    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const Key('rune_well')), findsOneWidget,
        reason: 'col getto il pozzo deve esserci: e\' la scena delle pietre');
  });
}
