// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/lang/euphonic.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA LUNGA SI APRE CON GLI EOS.** Ordine EU voce 15, 1 ottobre 2026.
///
/// La tabella della voce ES.06, approvata dal fondatore (*"Approvo
/// tutto."*): *"Occidentale del giorno, Approfondita: 50 Eos, per la
/// giornata e le quattro schede"*; alla domanda *"Chi può scegliere la
/// profondità Lunga?"*, *"Premium più Eos"*. Il rapporto ES (scelta 17)
/// diceva che nel listino quel prezzo non c'era e che al Viandante la Lunga
/// mostrava solo l'invito al piano.
///
/// Si pretende: le voci dell'Oroscopo che la tabella ES.06 prezza in Eos
/// stanno tutte nel listino (la Lunga del giorno 50, l'anno 300, un amico in
/// piu' 100), e nessuna per la Vedica o la Cinese; al Viandante il lucchetto
/// della Lunga nell'Occidentale del giorno apre le due strade, i 50 Eos con
/// la porta della spesa e il piano chiamato col suo nome; con la Lunga di
/// oggi gia' comprata il Viandante la sceglie.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final nascita = BirthDetails(
    date: DateTime(1990, 6, 15),
    time: const TimeOfDay(hour: 8, minute: 10),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );
  final oggi = DateTime(2026, 10, 1, 12, 5);

  test('le voci dell\'Oroscopo prezzate dalla tabella ES.06 stanno nel listino',
      () {
    const prezzate = {
      'oroscopo_lunga_del_giorno': 50,
      'oroscopo_annuale': 300,
      'amico_in_piu': 100,
    };
    final mancanti = <String>[];
    for (final e in prezzate.entries) {
      final voce = ListinoDegliEos.perArte(e.key);
      if (voce == null || voce.costo != e.value) mancanti.add(e.key);
    }
    print('ORDINE EU VOCE 15: voci dell\'Oroscopo con un prezzo nella tabella '
        'ES.06 ma assenti dal listino ${mancanti.length} su ${prezzate.length}');
    expect(mancanti, isEmpty, reason: mancanti.join(', '));
    expect(ListinoDegliEos.oroscopoLungaDelGiorno.nome,
        contains('per la giornata e le quattro schede'));
    // La Vedica e la Cinese non si comprano con gli Eos.
    expect(
        ListinoDegliEos.tutte.where((v) =>
            v.id.contains('vedic') ||
            v.id.contains('cinese') ||
            v.nome.contains('vedic') ||
            v.nome.contains('cinese')),
        isEmpty);
    // La profondita' del piano resta dei piani a pagamento.
    expect(PlanCatalog.haProfondita(Tier.free), isFalse);
    expect(PlanCatalog.haProfondita(Tier.tier1), isTrue);
  });

  Future<void> monta(WidgetTester tester) async {
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
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.free)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(userSign: Zodiac.gemini, now: oggi),
      ),
    ));
    await tester.pump();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 600));
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> scegliLaLunga(WidgetTester tester) async {
    final selettore = find.byKey(const Key('oroscopo_depth_generale'));
    await tester.ensureVisible(selettore);
    await tester.pump();
    await tester.tap(selettore);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(AnswerDepth.profonda.label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('al Viandante la Lunga offre i 50 Eos e il piano col suo nome',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester);
    await scegliLaLunga(tester);
    expect(find.byKey(const Key('oroscopo_lunga_due_strade')), findsOneWidget,
        reason: 'il lucchetto della Lunga non apre le due strade');
    final costo = tester
        .widget<Text>(find.byKey(const Key('porta_della_spesa_costo')))
        .data!;
    expect(costo, contains('50 Eos'));
    final piano = PlanCatalog.forTier(Tier.tier1).name;
    expect(
        find.descendant(
            of: find.byKey(const Key('oroscopo_lunga_col_piano')),
            matching: find.text('La Lunga ogni giorno ${conPiano(piano)}')),
        findsOneWidget);
    print('ORDINE EU VOCE 15: due strade al Viandante: "$costo" e "La Lunga '
        'ogni giorno ${conPiano(piano)}"');
  });

  testWidgets('con la Lunga di oggi gia\' comprata il Viandante la sceglie',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        const {'oroscopo_lunga_comprata_il': '2026-10-01'});
    await monta(tester);
    await scegliLaLunga(tester);
    expect(find.byKey(const Key('oroscopo_lunga_due_strade')), findsNothing);
    expect(
        find.descendant(
            of: find.byKey(const Key('oroscopo_depth_generale')),
            matching: find.text(AnswerDepth.profonda.label)),
        findsOneWidget,
        reason: 'la Lunga comprata oggi non si sceglie');
  });
}
