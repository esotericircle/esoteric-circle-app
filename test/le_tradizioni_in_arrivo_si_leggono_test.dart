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
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/la_testa_della_tradizione.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LE TRADIZIONI IN ARRIVO SI LEGGONO.** Il fondatore, 1 ottobre 2026:
/// *"Per le altre tipologie di oroscopo non sbloccati, ad esempio maya,
/// egizio, ecc, scrivi solo "in arrivo" Senza indicare la fase"*; e sulla
/// testa dell'Araba, cerchiando "AL-FARGH AL-MU'AKHKHAR, IL SECONDO
/// BECCUCCIO" rimpicciolito su una riga: *"La scritta che ho cerchiato in
/// alto è illeggibile"*.
///
/// Si misura, sulle quattro tradizioni in arrivo, con una nascita che da'
/// loro un segno: la scritta del chip ("In arrivo", nient'altro, anche nella
/// Demo); il nome in testa senza la spiegazione dopo la virgola, che sta gia'
/// nella frase sotto la figura; e la sua scala a video, cioe' quanto il nome
/// e' rimpicciolito rispetto al suo carattere (almeno 0,7).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const quattro = [
    AstroTradition.maya,
    AstroTradition.egizia,
    AstroTradition.celtica,
    AstroTradition.araba,
  ];

  testWidgets('i chip dicono "In arrivo" e i nomi si leggono', (tester) async {
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
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // La nascita del fondatore della cattura: Cancro, con la dimora lunare
    // dal nome lungo.
    final nascite = BirthIdentityController()
      ..setBirth(
          BirthDetails(
            date: DateTime(1975, 7, 4),
            time: const TimeOfDay(hour: 10, minute: 30),
            place: const BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          null);
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
            userSign: Zodiac.cancer, now: DateTime(2026, 10, 1, 12)),
      ),
    ));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 600));

    final colpe = <String>[];
    final righe = <String>[];
    var guardate = 0;
    for (final t in quattro) {
      final chip = find.byKey(Key('oroscopo_tradition_soon_${t.name}'));
      final scritta = tester.widget<Text>(chip).data;
      if (scritta != 'In arrivo') {
        colpe.add('${t.name}: il chip dice "$scritta"');
      }
      final tabs = find.byKey(const Key('oroscopo_tradition_tabs'));
      await tester.ensureVisible(tabs);
      await tester.pump();
      final tocco = find.byKey(Key('oroscopo_tradition_${t.name}'));
      await tester.dragUntilVisible(tocco, tabs, const Offset(-80, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(tocco);
      await tester.pump(const Duration(milliseconds: 600));
      final nome = find.byKey(const Key('oroscopo_sign_name'));
      await tester.ensureVisible(nome);
      await tester.pump();
      final testo = tester.widget<Text>(nome).data!;
      final paragrafo = tester.renderObject<RenderParagraph>(
          find.descendant(of: nome, matching: find.byType(RichText)).first);
      final aVideo = tester.getRect(nome).height;
      final scala = aVideo / paragrafo.size.height;
      guardate++;
      righe.add('${t.name}: chip "$scritta", nome "$testo", scala '
          '${scala.toStringAsFixed(2)}');
      if (testo.contains(',')) {
        colpe.add('${t.name}: il nome porta la spiegazione: "$testo"');
      }
      if (scala < 0.7) {
        colpe.add('${t.name}: il nome e\' rimpicciolito a '
            '${scala.toStringAsFixed(2)}: "$testo"');
      }
    }
    cardinaleMinimo(guardate, 4, cosa: 'tradizioni in arrivo');
    print('LE TRADIZIONI IN ARRIVO: difetti ${colpe.length} su $guardate\n'
        '${righe.join('\n')}');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  // Il nome della cattura del fondatore, intero e senza la spiegazione, nel
  // posto della testa (360 punti): la parola piu' lunga non entra nel
  // carattere cerimoniale, e il nome deve rimpicciolirsi quanto basta
  // andando a capo, non tutto su una riga.
  for (final nome in const [
    'al-Fargh al-Mu\'akhkhar, il secondo beccuccio',
    'al-Fargh al-Mu\'akhkhar',
  ]) {
    testWidgets('il nome "$nome" si legge', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: NomeConLaNota(
                nome: nome,
                tradizione: AstroTradition.araba,
                palette: MaestroPalette.medora,
                chiave: const Key('nome')),
          ),
        ),
      ));
      await tester.pump();
      final paragrafo = tester.renderObject<RenderParagraph>(find
          .descendant(
              of: find.byKey(const Key('nome')),
              matching: find.byType(RichText))
          .first);
      final scala = tester.getRect(find.byKey(const Key('nome'))).height /
          paragrafo.size.height;
      print('LE TRADIZIONI IN ARRIVO: "$nome" a video alla scala '
          '${scala.toStringAsFixed(2)}, alto '
          '${paragrafo.size.height.toStringAsFixed(0)} punti prima della '
          'scala');
      expect(scala, greaterThanOrEqualTo(0.7),
          reason: 'il nome e\' rimpicciolito a ${scala.toStringAsFixed(2)}');
    });
  }
}
