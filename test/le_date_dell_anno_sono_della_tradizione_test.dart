// ignore_for_file: avoid_print
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
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LE DATE DELL'ANNO IN TESTATA SONO QUELLE DELLA TRADIZIONE.** Ordine EU
/// voci 02 e 04, vista sul Realme il 1 ottobre 2026.
///
/// Il fondatore, sulla testata: *"è sufficiente "Oroscopo del giorno o
/// settimana o mese o anno" e sotto la data o date corrispondenti"*. Sul
/// Realme l'Anno della Cinese diceva in testata "dal 15 giugno 2026 al 15
/// giugno 2027", l'anno del ritorno del Sole, e subito sotto "Il tuo anno
/// cinese va dal 17 febbraio 2026 al 6 febbraio 2027": la testata leggeva
/// l'anno dell'Occidentale per ogni tradizione.
///
/// Si misura, nelle tre tradizioni: le date della testata dell'Anno uguali a
/// quelle della riga dell'anno della stessa tradizione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );

  void sensori() {
    final messenger = binding.defaultBinaryMessenger;
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
  }

  Future<void> chiudiIlFoglio(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      final continua = find.byKey(const Key('rivelazione_continua'));
      if (continua.evaluate().isNotEmpty) {
        await tester.tap(continua);
        await tester.pump(const Duration(milliseconds: 600));
      }
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets('la testata dell\'Anno dice le date della tradizione scelta',
      (tester) async {
    sensori();
    SharedPreferences.setMockInitialValues(const {});
    // La lista e' pigra: la finestra e' alta quanto la testata, i periodi,
    // le tradizioni e la riga dell'anno, cosi' sono costruite tutte insieme.
    tester.view.physicalSize = const Size(390, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.pisces, now: DateTime(2026, 10, 1, 12)),
      ),
    ));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 600));

    final anno = find.byKey(const Key('oroscopo_period_anno'));
    await tester.ensureVisible(anno);
    await tester.tap(anno);
    await tester.pump(const Duration(milliseconds: 600));

    final diverse = <String>[];
    final righe = <String>[];
    var guardate = 0;
    for (final t in const [
      AstroTradition.occidentale,
      AstroTradition.vedica,
      AstroTradition.cinese,
    ]) {
      // Il foglio della rivelazione del segno (ordine ES voce 35) puo' salire
      // in ritardo sulla tradizione di prima: si chiude prima di toccare.
      await chiudiIlFoglio(tester);
      final tabs = find.byKey(const Key('oroscopo_tradition_tabs'));
      await tester.ensureVisible(tabs);
      await tester.pump();
      await tester.drag(tabs, const Offset(2000, 0));
      await tester.pump(const Duration(milliseconds: 300));
      final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
      await tester.dragUntilVisible(chip, tabs, const Offset(-80, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 600));
      await chiudiIlFoglio(tester);
      final testata =
          tester.widget<Text>(find.byKey(const Key('oroscopo_date'))).data!;
      final rigaChiave = t == AstroTradition.occidentale
          ? const Key('oroscopo_anno_riga')
          : Key('oroscopo_${t.name}_anno_riga');
      final riga = tester.widget<Text>(find.byKey(rigaChiave)).data!;
      guardate++;
      righe.add('${t.name}: testata "$testata", riga "$riga"');
      if (!riga.contains(testata)) diverse.add('${t.name}: "$testata"');
    }
    cardinaleMinimo(guardate, 3, cosa: 'tradizioni con l\'Anno');
    print('ORDINE EU, LE DATE DELL\'ANNO: testate con date diverse dalla '
        'riga della tradizione ${diverse.length} su $guardate\n'
        '${righe.join('\n')}');
    expect(diverse, isEmpty, reason: diverse.join('\n'));
  });
}
