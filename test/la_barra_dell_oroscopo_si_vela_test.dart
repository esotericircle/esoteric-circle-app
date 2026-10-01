// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA BARRA DELL'OROSCOPO SI VELA QUANDO IL TESTO LE SCORRE SOTTO.** Visto
/// sul Realme il 1 ottobre 2026 (ordine EU): la barra con la freccia, la "i"
/// delle fonti e il cuore era trasparente anche con l'elenco scorso, e i
/// titoli delle schede e il punto interrogativo del segno passavano sotto le
/// icone, mescolati.
///
/// Si misura l'opacita' del fondo della barra: a riposo (sul cielo, come il
/// fondatore l'ha voluta) e dopo aver scorso l'elenco di 600 punti. A riposo
/// trasparente; scorso, almeno il 90 per cento (il velo della barra in alto
/// dell'ordine EU voce 19 e' al 92).
void main() {
  testWidgets('a riposo trasparente, scorsa velata', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.gemini, now: DateTime(2026, 10, 1, 10, 0)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    double opacita() {
      final materiale = tester.widget<Material>(find
          .descendant(
              of: find.byKey(const Key('oroscopo_barra')),
              matching: find.byType(Material))
          .first);
      return materiale.color?.a ?? 0;
    }

    final aRiposo = opacita();
    await tester.drag(
        find.byKey(const Key('oroscopo_list')), const Offset(0, -600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final scorsa = opacita();
    print('LA BARRA DELL\'OROSCOPO: opacita\' del fondo a riposo '
        '${(aRiposo * 100).toStringAsFixed(0)} per cento, scorsa '
        '${(scorsa * 100).toStringAsFixed(0)} per cento');
    expect(aRiposo, lessThan(0.05), reason: 'a riposo la barra copre il cielo');
    expect(scorsa, greaterThanOrEqualTo(0.9),
        reason: 'scorso l\'elenco, la barra lascia vedere il testo che le '
            'passa sotto');
  });
}
