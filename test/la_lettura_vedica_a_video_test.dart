// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/titolo_della_scheda_del_giorno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'cardinale_minimo.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';

/// **LA VEDICA A VIDEO. Ordine ES voce 09, 29 settembre 2026.** La stessa
/// strada della Cinese: dal primo piano a pagamento il gesto e le quattro
/// schede della lettura, sul gratuito il segno e l'invito, senza la citta'
/// di oggi la riga che la chiede per il Rahu Kalam.
void main() {
  // ---------------------------------------------------------------------------
  // LA SCHERMATA
  // ---------------------------------------------------------------------------

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // Roma, 15 marzo 1990 alle 8:30: la Luna in Tula, Svati.
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );
  final oggi = DateTime(2026, 7, 10);

  Future<void> monta(WidgetTester tester,
      {Tier tier = Tier.tier1, bool conNascita = true}) async {
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
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController();
    if (conNascita) nascite.setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: tier)),
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
        home: OroscopoScreen(userSign: Zodiac.pisces, now: oggi),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
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
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> consulta(WidgetTester tester) async {
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 800));
  }

  String titolo(WidgetTester tester, HoroscopeDomain d) => tester
      .widget<TitoloDellaSchedaDelGiorno>(
          find.byKey(Key('oroscopo_titolo_${d.name}')))
      .testo;

  testWidgets('dal primo piano: Interroga la Luna e le quattro schede vediche',
      (tester) async {
    await monta(tester);
    await toccaLaTradizione(tester, AstroTradition.vedica);
    expect(find.text('Interroga la Luna'), findsOneWidget);
    // Senza la citta' di oggi il Rahu Kalam la chiede, con la riga che porta
    // a sceglierla.
    expect(find.textContaining('Per il Rahu Kalam di oggi dimmi dove'),
        findsOneWidget);
    await consulta(tester);
    final attese = LaLetturaVedica.schede(
        adesso: oggi,
        nascita: NascitaDeiSegni(
            locale: DateTime(1990, 3, 15, 8, 30),
            oraNota: true,
            fuso: 'Europe/Rome'),
        forma: CourtesyForm.unknown)!;
    final diverse = <String>[];
    for (var i = 0; i < 4; i++) {
      final d = HoroscopeDomain.values[i];
      final t = find.byKey(Key('oroscopo_titolo_${d.name}'));
      if (t.evaluate().isEmpty) {
        await tester.dragUntilVisible(
            t, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
      }
      if (titolo(tester, d) != attese[i].title) diverse.add(d.name);
    }
    print('ORDINE ES VOCE 09: schede a video diverse dalla lettura vedica '
        '${diverse.length} su 4');
    expect(diverse, isEmpty);
  });

  testWidgets('il piano gratuito vede il segno vedico e l\'invito',
      (tester) async {
    await monta(tester, tier: Tier.free);
    await toccaLaTradizione(tester, AstroTradition.vedica);
    final invito = find.byKey(const Key('oroscopo_vedica_invito_al_piano'));
    await tester.dragUntilVisible(
        invito, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(invito, findsOneWidget);
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing);
  });
}
