import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE ARTI DEL MAESTRO SALTANO ALL'OCCHIO. Ordine AS voce 11.
///
/// **La critica dei fondatori**: chi arriva non conosce i Maestri e cerca
/// un'arte. Cercava "tarocchi" e trovava "Entra nel Dominio di Medora", che e'
/// un nome proprio; le tre arti stavano sotto il pulsante, nel ruolo
/// tipografico piu' piccolo dell'app e in oro tenue.
///
/// **Cosa si misura, e sono due cose che si vedono davvero a schermo**: che le
/// arti stiano SOPRA il pulsante, cioe' che l'occhio le prenda prima, e che
/// siano scritte piu' grandi del pulsante stesso.
void main() {
  testWidgets('le arti stanno sopra il pulsante del dominio, e sono piu grandi',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
    });
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
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
        home: SantuarioScreen(clock: () => DateTime(2026, 7, 30, 21)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final arti = find.byKey(const Key('santuario_domain_arts'));
    final pulsante = find.byKey(const Key('santuario_enter_domain'));
    expect(arti, findsOneWidget,
        reason: 'la riga delle arti non c e piu nella home');
    expect(pulsante, findsOneWidget);

    final rArti = tester.getRect(arti);
    final rPulsante = tester.getRect(pulsante);
    // ignore: avoid_print
    print('ORDINE AS VOCE 11: arti a ${rArti.top.toStringAsFixed(1)}, '
        'pulsante a ${rPulsante.top.toStringAsFixed(1)}');
    expect(rArti.bottom, lessThanOrEqualTo(rPulsante.top + 1),
        reason: 'le arti stanno sotto il pulsante: chi cerca un arte legge '
            'prima un nome proprio che non conosce');

    final testoArti = tester.widget<Text>(arti);
    final corpoArti = testoArti.style!.fontSize!;
    // ignore: avoid_print
    print('ORDINE AS VOCE 11: corpo delle arti $corpoArti, pavimento '
        '${TypographyTokens.pavimento}');
    expect(corpoArti, greaterThan(TypographyTokens.pavimento),
        reason: 'le arti sono ancora al ruolo piu piccolo dell app: erano '
            'l ultima cosa che l occhio prende, e devono essere la prima');
  });

  test('ogni Maestro dichiara le sue tre arti, e sono diverse', () {
    final tutte = <String>{};
    for (final maestro in Maestro.values) {
      final arti = maestro.domainArts.split(',').map((s) => s.trim()).toList();
      expect(arti, hasLength(3),
          reason: '${maestro.id} dichiara ${arti.length} arti invece di tre');
      tutte.addAll(arti);
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 11: arti distinte fra i tre Maestri ${tutte.length}');
    expect(tutte, hasLength(9),
        reason: 'due Maestri condividono un arte: chi la cerca non sa dove '
            'andare');
  });
}
