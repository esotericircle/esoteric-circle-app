import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA HOME NON VA IN NEGATIVO.** Ordine GA voce 11, 20 ottobre 2026,
/// difetto 5 della ricognizione.
///
/// Il fatto: aprendo l'app senza rete la home mostrava l'errore rosso di
/// Flutter `'_elements.contains(element)'` (STATO_VIVO, PROVENIENZA IGNOTA);
/// in Crashlytics 238 eventi dal 19 ottobre. Letta la traccia intera, quello
/// e' il secondo errore: il primo, un istante prima e sullo stesso
/// `RawGestureDetector` dello scorrimento della home, e' "BoxConstraints has
/// a negative minimum height, h=-112.0". **-112 e' esattamente meno
/// l'altezza della barra** (`SantuarioBottomBar.altezzaResa`): l'eroe della
/// home e' alto `outer.maxHeight - SpazioDellaBarraNelloScroll.quanto`, e
/// quando lo spazio sotto la striscia del giorno vale zero (la finestra che
/// non ha ancora la sua altezza, o una striscia che la prende tutta) il
/// `SizedBox` dell'eroe nasce con un'altezza negativa. In debug e' l'errore
/// rosso e poi l'albero rotto (`_elements.contains`); in release un riquadro
/// grigio al posto della home.
///
/// Padre (Regola C): il commit `bc162adf` del 7 agosto 2026 ("Lo spazio
/// della barra vive dentro cio' che scorre"), che ha scritto la sottrazione
/// senza un pavimento.
void main() {
  Future<List<String>> monta(WidgetTester tester, Size logica) async {
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
    });
    tester.view.physicalSize = logica * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final errori = <String>[];
    final diPrima = FlutterError.onError;
    FlutterError.onError = (dettagli) => errori.add(dettagli.toString());
    try {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => GreetingController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: SantuarioScreen(clock: () => DateTime(2026, 10, 19, 21)),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // La finestra prende la sua altezza vera: l'albero si ricostruisce.
      tester.view.physicalSize = const Size(390, 844) * 3;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    } finally {
      FlutterError.onError = diPrima;
    }
    return errori;
  }

  for (final altezza in [0.0, 60.0, 120.0]) {
    testWidgets(
        'con ${altezza.toStringAsFixed(0)} punti di finestra la home non '
        'costruisce altezze negative ne\' rompe l\'albero', (tester) async {
      final errori = await monta(tester, Size(390, altezza));
      final gravi = errori
          .where((e) =>
              e.contains('negative') ||
              e.contains('NOT NORMALIZED') ||
              e.contains('_elements.contains'))
          .toList();
      expect(gravi, isEmpty,
          reason: 'la home ha costruito un\'altezza negativa: '
              '${gravi.map((e) => e.split('\n').take(4).join(' ')).join(' | ')}');
    });
  }
}
