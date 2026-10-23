import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/miniatura_intera.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA BOLLA DEGLI ANGELI NE MOSTRA TRE.** Ordine EV, il fondatore: *"nel
/// Passport, nella bolla scheda degli angeli, mi fa vedere la Carta solo del
/// primo, ma in verità sono 3"*.
///
/// La tessera "I tuoi Angeli" diceva "i tre che ti accompagnano" e mostrava
/// la carta e il nome del solo Custode. Si contano le carte e i nomi dentro
/// la tessera, contro gli angeli che la tradizione da' alla persona.
void main() {
  testWidgets('la tessera degli Angeli mostra tutte le carte e tutti i nomi',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(const {});
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const Scaffold(body: CosmicPassport()),
      ),
    ));
    await tester.pump();
    final tessera = find.byKey(const Key('passport_angels'));
    await tester.scrollUntilVisible(tessera, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();

    final angeli =
        GuardianAngels.forBirth(BirthIdentity.example.toBirthDetails()).known;
    final carte = find.descendant(
        of: tessera, matching: find.byType(MiniaturaIntera));
    final nomi = [
      for (final a in angeli)
        if (find
            .descendant(of: tessera, matching: find.textContaining(a.name))
            .evaluate()
            .isNotEmpty)
          a.name,
    ];
    // ignore: avoid_print
    print('ORDINE EV, ANGELI NEL PASSAPORTO: angeli della persona '
        '${angeli.length}, carte nella tessera ${carte.evaluate().length}, '
        'nomi nella tessera ${nomi.length}');
    expect(angeli, hasLength(3),
        reason: 'la persona d\'esempio ha l\'ora di nascita: i suoi angeli '
            'sono tre');
    expect(carte.evaluate().length, angeli.length,
        reason: 'la tessera dice "i tre che ti accompagnano" e ne mostra '
            'meno');
    expect(nomi, hasLength(angeli.length));
    expect(tester.takeException(), isNull);
  });
}
