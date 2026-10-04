// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
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
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE TRADIZIONI DELL'AMICO NELL'ORDINE DELLA PERSONA.** Visto sul Realme
/// il 1 ottobre 2026 (ordine EU): nell'oroscopo della persona i chip sono
/// Occidentale, Vedica, Cinese; in quello dell'amico erano Occidentale,
/// Cinese, Vedica. Chi passa dall'uno all'altro trova le stesse tradizioni
/// in un altro posto.
///
/// Si legge l'ordine da sinistra a destra delle tre tradizioni nei due
/// oroscopi montati, e si pretende che sia lo stesso.
import 'l_oroscopo_di_un_amico_nelle_prove.dart';

void main() {
  const tre = [
    AstroTradition.occidentale,
    AstroTradition.vedica,
    AstroTradition.cinese,
  ];

  List<AstroTradition> inFila(WidgetTester tester, String prefisso) {
    final x = {
      for (final t in tre)
        t: tester.getRect(find.byKey(Key('$prefisso${t.name}'))).left,
    };
    return [...tre]..sort((a, b) => x[a]!.compareTo(x[b]!));
  }

  testWidgets('lo stesso ordine nei due oroscopi', (tester) async {
    // I sensori dell'Oroscopo (il cielo che si inclina) non esistono nella
    // prova: le loro porte rispondono a vuoto.
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(name),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 2400);
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
    final dellaPersona = inFila(tester, 'oroscopo_tradition_');

    // LAPIDE, ordine FC voce 02: qui si montava la schermata dell'amico,
    // che aveva la sua riga delle tradizioni (`amico_tradizione_`) scritta a
    // parte, e l'ordine era diverso da quello della persona (visto sul Realme
    // il 1 ottobre 2026). Adesso l'oroscopo di un amico e' l'Oroscopo: la
    // riga e' la stessa, e la prova resta a sorvegliare che lo resti.
    await tester.pumpWidget(lOroscopoDiUnAmico(
        Amico(
            id: 'l',
            nome: 'Lucia',
            nascita: DateTime(1990, 1, 12),
            ora: '08:10'),
        tier: Tier.tier1,
        adesso: DateTime(2026, 10, 1, 12)));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));
    final dellAmico = inFila(tester, 'oroscopo_tradition_');
    print('LE TRADIZIONI DELL\'AMICO: della persona '
        '${dellaPersona.map((t) => t.label).join(', ')}; dell\'amico '
        '${dellAmico.map((t) => t.label).join(', ')}');
    expect(dellAmico, dellaPersona);
  });
}
