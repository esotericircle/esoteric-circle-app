// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'il_gesto_nelle_prove.dart';

/// **LA SETTIMANA E IL MESE SI APRONO COL PIANO.** Ordine ES voci 02, 03 e
/// 06, 29 settembre 2026.
///
/// Il fatto dell'Architetto: Settimana e Mese erano bloccati per tutti, e al
/// tocco l'invito ad abbonarsi arrivava anche a chi era abbonato. Adesso la
/// Settimana si apre dall'Iniziato e il Mese dall'Adepto; a chi non ha il
/// piano l'invito lo chiama col suo nome.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, Tier tier) async {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final piano = EntitlementService()..setTier(tier);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider.value(value: piano),
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
        home: OroscopoScreen(userSign: Zodiac.leo, now: DateTime(2026, 10, 5)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> tocca(WidgetTester tester, HoroscopePeriod p) async {
    final tab = find.byKey(Key('oroscopo_period_${p.name}'));
    await tester.ensureVisible(tab);
    await tester.pump();
    await tester.tap(tab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets(
      'ES.06: chi ha il piano apre il suo periodo, gli altri '
      'trovano il piano per nome', (tester) async {
    final righe = <String>[];
    var inviteAgliAbbonati = 0;
    for (final (tier, settimana, mese) in [
      (Tier.free, false, false),
      (Tier.tier1, true, false),
      (Tier.tier2, true, true),
      (Tier.tier3, true, true),
    ]) {
      for (final (p, atteso, chiave, piano) in [
        (
          HoroscopePeriod.settimana,
          settimana,
          'oroscopo_la_settimana',
          'Iniziato'
        ),
        (HoroscopePeriod.mese, mese, 'oroscopo_il_mese', 'Adepto'),
      ]) {
        await monta(tester, tier);
        await tocca(tester, p);
        // Ordine FC voce 03: il periodo aperto si legge col gesto, sempre;
        // a chi non ha il piano resta l'invito, e il gesto del Giorno sotto
        // l'invito non si tocca.
        if (atteso) await interrogaSeCe(tester);
        final aperto = find.byKey(Key(chiave)).evaluate().isNotEmpty;
        final invito = find.textContaining(piano).evaluate().isNotEmpty;
        righe.add('${tier.name} ${p.name}: '
            '${aperto ? 'aperto' : (invito ? 'invito a $piano' : 'niente')}');
        expect(aperto, atteso, reason: '${tier.name} ${p.name}');
        if (!atteso) {
          expect(invito, isTrue,
              reason: '${tier.name} ${p.name}: l\'invito non nomina $piano');
        }
        if (atteso && invito && !aperto) inviteAgliAbbonati++;
        await tester.pumpWidget(const SizedBox());
      }
    }
    print('ORDINE ES VOCE 06: ${righe.join('; ')}; inviti a chi ha gia\' il '
        'piano $inviteAgliAbbonati');
    expect(inviteAgliAbbonati, 0);
  });

  testWidgets('l\'avviso dei dati mancanti segue il livello della porta',
      (tester) async {
    final periodo = LaSettimanaDelCielo.per(
        segno: Zodiac.leo, carta: null, oggi: DateTime(2026, 10, 5));
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final righe = <String>[];
    for (final livello in LivelloPersonalizzazione.values) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IlPeriodoView(
                periodo: periodo,
                mese: false,
                palette: palette,
                livello: livello,
                profondita: const {},
                premiumUnlocked: true,
                onDepthSelected: (_, __) {},
                onDepthLocked: (_, __) {}),
          ),
        ),
      ));
      final avviso = find.byKey(const Key('oroscopo_periodo_sul_segno'));
      final presente = avviso.evaluate().isNotEmpty;
      righe.add('${livello.name}: ${presente ? 'avviso' : 'niente'}');
      expect(presente, livello != LivelloPersonalizzazione.cartaCompleta,
          reason: livello.name);
    }
    print('ORDINE ES VOCE 02: ${righe.join('; ')}');
  });
}
