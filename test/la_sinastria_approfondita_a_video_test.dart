import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_approfondita/cielo_approfondito.dart';
import 'package:esoteric_circle/core/synastry_approfondita/la_lettura_approfondita.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/synastry/sinastria_approfondita_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SINASTRIA APPROFONDITA A VIDEO.** Ordine FT voci FT.04, FT.06,
/// FT.07, FT.08, FT.09, FT.10 e FT.13: cio' che si vede e cio' che resta
/// chiuso, piano per piano, e lo sbarramento d'eta' sul legame amore.
final _oggi = DateTime(2026, 10, 14);

CieloApprofondito _cielo(DateTime nascita, String nome) =>
    CieloApprofondito.perNascita(
        momentoUtc: DateTime.utc(nascita.year, nascita.month, nascita.day, 12),
        giornoDiNascita: nascita,
        nome: nome);

Future<void> _monta(WidgetTester tester,
    {required Tier tier, DateTime? nascitaSua}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: false)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(
            size: Size(390, 844), disableAnimations: true),
        child: MaestroScope(
          child: SinastriaApprofonditaScreen(
            nomeTuo: 'Tu',
            cieloTuo: _cielo(DateTime(1990, 5, 12), 'Tu'),
            nomeSuo: 'Giulia',
            cieloSuo: _cielo(nascitaSua ?? DateTime(1992, 9, 3), 'Giulia'),
            oggi: _oggi,
          ),
        ),
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _scorriFino(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 400,
      scrollable: find.byType(Scrollable).first, maxScrolls: 80);
  // Al centro della finestra: in cima starebbe sotto il velo della barra
  // del titolo, che la scena attraversa (extendBodyBehindAppBar).
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pump();
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  testWidgets(
      'il Viandante: Oggi fra voi, due capitoli aperti, tre chiusi col '
      'lucchetto, Keplero e le esclusive chiusi', (tester) async {
    await _monta(tester, tier: Tier.free);
    expect(find.byKey(const Key('sinastria_approfondita_coppia')),
        findsOneWidget);
    await _scorriFino(tester, find.byKey(const Key('sinastria_oggi_fra_voi')));
    for (final c in [Capitolo.attrazione, Capitolo.emozioni]) {
      await _scorriFino(
          tester, find.byKey(Key('sinastria_capitolo_${c.name}')));
    }
    for (final c in [Capitolo.mente, Capitolo.durata, Capitolo.destino]) {
      await _scorriFino(
          tester, find.byKey(Key('sinastria_chiuso_capitolo_${c.name}')));
    }
    await _scorriFino(tester, find.byKey(const Key('sinastria_chiuso_keplero')));
    await _scorriFino(tester, find.byKey(const Key('sinastria_chiuso_adepto')));
    // Mai un vicolo cieco: il lucchetto apre l'invito.
    await tester.tap(find.byKey(const Key('sinastria_chiuso_adepto')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
  });

  testWidgets(
      'l\'Adepto: tutti i capitoli, Keplero, il Composito e il Momento giusto',
      (tester) async {
    await _monta(tester, tier: Tier.tier2);
    for (final c in Capitolo.values) {
      await _scorriFino(
          tester, find.byKey(Key('sinastria_capitolo_${c.name}')));
    }
    await _scorriFino(tester, find.byKey(const Key('sinastria_keplero')));
    // Nessun testo di Keplero si ripete: con questa coppia tre corde su
    // quattro cadono fuori da ogni consonanza (anteprima ft_adepto_1).
    final testiDiKeplero = tester
        .widgetList<ParagrafiDiLettura>(find.descendant(
            of: find.byKey(const Key('sinastria_keplero')),
            matching: find.byType(ParagrafiDiLettura)))
        .map((p) => p.testo)
        .toList();
    expect(testiDiKeplero, isNotEmpty);
    expect(testiDiKeplero.toSet().length, testiDiKeplero.length,
        reason: 'un testo di Keplero esce due volte: $testiDiKeplero');
    await _scorriFino(tester, find.byKey(const Key('sinastria_composito')));
    await _scorriFino(
        tester, find.byKey(const Key('sinastria_momento_giusto')));
    expect(find.byKey(const Key('sinastria_chiuso_adepto')), findsNothing);
  });

  testWidgets(
      'lo sbarramento d\'eta\': con una persona di quindici anni il legame '
      'amore resta chiuso e la lettura parte dall\'amicizia', (tester) async {
    // Quindici anni e trecentosessantaquattro giorni al 14 ottobre 2026.
    await _monta(tester,
        tier: Tier.tier2, nascitaSua: DateTime(2010, 10, 15));
    final prima = tester
        .widget<Text>(find.byKey(const Key('sinastria_titolo_attrazione')))
        .data;
    await _scorriFino(
        tester, find.byKey(const Key('sinastria_legame_amore')));
    await tester.tap(find.byKey(const Key('sinastria_legame_amore')));
    await tester.pump();
    expect(find.byKey(const Key('sinastria_amore_chiuso')), findsOneWidget);
    expect(find.text('Il legame amore si apre dai sedici anni.'),
        findsOneWidget);
    // La lettura non e' cambiata: si legge ancora l'amicizia.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('sinastria_titolo_attrazione')))
            .data,
        prima);
  });

  testWidgets('a sedici anni compiuti l\'amore si apre e cambia la lettura',
      (tester) async {
    await _monta(tester,
        tier: Tier.tier2, nascitaSua: DateTime(2010, 10, 14));
    // Si apre gia' sull'amore: il primo legame, quando e' apribile.
    final amore = tester
        .widget<Text>(find.byKey(const Key('sinastria_titolo_attrazione')))
        .data;
    await _scorriFino(
        tester, find.byKey(const Key('sinastria_legame_lavoro')));
    await tester.tap(find.byKey(const Key('sinastria_legame_lavoro')));
    await tester.pump();
    final lavoro = tester
        .widget<Text>(find.byKey(const Key('sinastria_titolo_attrazione')))
        .data;
    expect(lavoro, isNot(amore),
        reason: 'il legame cambia la lettura (FT.06)');
  });
}
