// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
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

/// **IL SEGNO SI RIVELA LA PRIMA VOLTA.** Ordine EU voce 13, 1 ottobre 2026.
///
/// Il fondatore: *"quando l'utente fa click per la prima volta su vedica o
/// cinese o altro, serve un'animazione di rivelazione del segno, non possono
/// comparire di botto."*
///
/// Si apre ognuna delle sei tradizioni (Vedica, Cinese, Maya, Egizia,
/// Celtica, Araba) e si misura l'opacita' della figura in testa: al primo
/// fotogramma della prima apertura e' quasi trasparente, dopo la durata della
/// rivelazione e' piena; alla seconda apertura e' piena subito. Con Riduci
/// Movimento e' piena subito anche la prima volta. Per l'amico, la prima
/// apertura di una sua tradizione si rivela allo stesso modo.
import 'l_oroscopo_di_un_amico_nelle_prove.dart';

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
  const sei = [
    AstroTradition.vedica,
    AstroTradition.cinese,
    AstroTradition.maya,
    AstroTradition.egizia,
    AstroTradition.celtica,
    AstroTradition.araba,
  ];

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

  Future<void> monta(WidgetTester tester, {required bool fermo}) async {
    sensori();
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: fermo),
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
  }

  Future<void> tocca(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.drag(riga, const Offset(2000, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chip);
    await tester.pump();
  }

  double opacita(WidgetTester tester, AstroTradition t) => tester
      .widget<Opacity>(find.descendant(
          of: find.byKey(Key('oroscopo_testa_${t.name}')),
          matching: find.byKey(const Key('oroscopo_rivelazione_figura'))))
      .opacity;

  Future<void> chiudiIlFoglio(WidgetTester tester) async {
    final continua = find.byKey(const Key('rivelazione_continua'));
    if (continua.evaluate().isNotEmpty) {
      await tester.tap(continua);
      await tester.pump(const Duration(milliseconds: 600));
    }
  }

  testWidgets(
      'la prima apertura di ogni tradizione rivela il segno, la '
      'seconda no', (tester) async {
    await monta(tester, fermo: false);
    final senza = <String>[];
    final righe = <String>[];
    var misurate = 0;
    for (final t in sei) {
      await tocca(tester, t);
      final subito = opacita(tester, t);
      await tester.pump(const Duration(milliseconds: 1700));
      final dopo = opacita(tester, t);
      await chiudiIlFoglio(tester);
      misurate++;
      righe.add('${t.name}: prima apertura, figura al primo fotogramma '
          '${subito.toStringAsFixed(2)}, dopo 1,7 s ${dopo.toStringAsFixed(2)}');
      if (subito > 0.3 || dopo < 1) senza.add(t.name);
    }
    // La seconda volta: si passa da un'altra tradizione e si torna.
    final seconde = <String>[];
    for (final t in sei) {
      await tocca(tester, t == sei.first ? sei.last : sei.first);
      await tester.pump(const Duration(milliseconds: 300));
      await chiudiIlFoglio(tester);
      await tocca(tester, t);
      final subito = opacita(tester, t);
      righe.add('${t.name}: seconda apertura, figura al primo fotogramma '
          '${subito.toStringAsFixed(2)}');
      if (subito < 1) seconde.add(t.name);
      await chiudiIlFoglio(tester);
    }
    cardinaleMinimo(misurate, 6, cosa: 'tradizioni aperte');
    print('ORDINE EU VOCE 13: tradizioni la cui prima apertura mostra il segno '
        'senza rivelazione ${senza.length} su $misurate; seconde aperture '
        'che lo rivelano di nuovo ${seconde.length}\n${righe.join('\n')}');
    expect(senza, isEmpty, reason: senza.join(', '));
    expect(seconde, isEmpty, reason: seconde.join(', '));
  });

  testWidgets('con Riduci Movimento il segno e\' subito intero',
      (tester) async {
    await monta(tester, fermo: true);
    for (final t in sei) {
      await tocca(tester, t);
      expect(opacita(tester, t), 1.0, reason: t.name);
      // Il foglio della rivelazione della Cinese e della Vedica (voce
      // ES.35) arriva dopo il disco: si aspetta e si chiude.
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      await chiudiIlFoglio(tester);
    }
  });

  testWidgets('la prima apertura di una tradizione dell\'amico la rivela',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(360, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // LAPIDE, ordine FC voce 02: qui si montava la schermata dell'amico;
    // adesso e' l'Oroscopo col soggetto impostato su Lucia, e la chiave
    // della testa rivelata e' quella di prima (`amico|l|cinese`).
    await tester.pumpWidget(lOroscopoDiUnAmico(
        Amico(
            id: 'l',
            nome: 'Lucia',
            nascita: DateTime(1990, 1, 12),
            ora: '08:10'),
        tier: Tier.tier1,
        riduciMovimento: false,
        adesso: DateTime(2026, 9, 30, 12)));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));
    final righe = <String>[];
    for (final t in [AstroTradition.cinese, AstroTradition.vedica]) {
      final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
      final subito = opacita(tester, t);
      await tester.pump(const Duration(milliseconds: 1700));
      final dopo = opacita(tester, t);
      righe.add('amico, ${t.name}: ${subito.toStringAsFixed(2)} poi '
          '${dopo.toStringAsFixed(2)}');
      expect(subito, lessThan(0.3), reason: t.name);
      expect(dopo, 1.0, reason: t.name);
    }
    final cinese = find.byKey(const Key('oroscopo_tradition_cinese'));
    await tester.ensureVisible(cinese);
    await tester.tap(cinese);
    await tester.pump();
    expect(opacita(tester, AstroTradition.cinese), 1.0,
        reason: 'la seconda apertura dell\'amico rivela di nuovo');
    print('ORDINE EU VOCE 13, amico: ${righe.join('; ')}');
  });
}
