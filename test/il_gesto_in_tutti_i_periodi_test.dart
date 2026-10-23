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
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:esoteric_circle/features/horoscope/la_rivelazione_del_segno.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL GESTO IN TUTTI I PERIODI, E PER L'AMICO.** Ordine EX Aggiunta 5,
/// voce EX.12. Il fondatore: *"Nell'oroscopo il pulsante "interroga il
/// cielo, la luna, l'almanacco" compaiono solo per il giornaliero mentre non
/// c'è per settimanale, mensile e annuale"*. Per ogni tradizione e ogni
/// periodo che ha una lettura: prima del tocco il gesto c'e' e la lettura
/// no; dopo il tocco e la riflessione la lettura c'e'. E l'oroscopo
/// dell'amico, che ha solo il giorno, si apre col gesto anche lui.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // LAPIDE, ordine FC voce 03: qui si riaccendeva l'interruttore del gesto
  // che la suite spegneva; l'interruttore non c'e' piu'.

  Future<void> monta(WidgetTester tester, Widget home) async {
    // La rivelazione del segno gia' vista: e' un'altra scena, e la sua
    // prima volta coprirebbe il gesto.
    SharedPreferences.setMockInitialValues({
      LaRivelazioneDelSegno.chiave: ['cinese', 'vedica'],
      LaRivelazioneDelSegno.chiaveDelleTeste: ['cinese', 'vedica'],
    });
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final piano = EntitlementService()..setTier(Tier.tier3);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider.value(value: piano),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        // Con l'ora e il luogo di nascita: senza, l'anno e le tradizioni
        // mostrano l'invito a completarli, che non e' una lettura.
        ChangeNotifierProvider(
            create: (_) => BirthIdentityController()
              ..setBirth(
                  BirthDetails(
                    date: DateTime(1990, 7, 1),
                    time: const TimeOfDay(hour: 8, minute: 30),
                    place: const BirthPlace(
                        label: 'Roma',
                        latitude: 41.9,
                        longitude: 12.5,
                        timezone: 'Europe/Rome'),
                  ),
                  null)),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: home,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// La lettura a video: la vista del periodo o le schede.
  int letture() =>
      find.byType(IlPeriodoView).evaluate().length +
      find
          .byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_HoroscopeCardView')
          .evaluate()
          .length +
      find
          .byWidgetPredicate((w) => w.runtimeType.toString() == '_Scheda')
          .evaluate()
          .length;

  bool gesto() =>
      find.byKey(const Key('oroscopo_interroga')).evaluate().isNotEmpty;

  Future<void> interroga(WidgetTester tester) async {
    final g = find.byKey(const Key('oroscopo_interroga')).first;
    await tester.ensureVisible(g);
    await tester.pump();
    await tester.tap(g);
    // La riflessione intera, poi la cascata delle schede.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  /// **LO STESSO GIRO PER SE' E PER UN AMICO, ordine FC voce 03**: con la
  /// porta unica dell'ordine FC voce 02 e' lo stesso codice, e la prova lo
  /// pretende su tutti e due i soggetti.
  final amico = Amico(
      id: 'prova',
      nome: 'Lucia',
      nascita: DateTime(1990, 6, 21),
      ora: '10:30',
      luogo: 'Roma',
      lat: 41.9,
      lon: 12.5,
      fuso: 'Europe/Rome');

  for (final (soggetto, schermata) in [
    (
      'io',
      () => OroscopoScreen(userSign: Zodiac.cancer, now: DateTime(2026, 10, 3))
    ),
    (
      'amico',
      () => OroscopoScreen(
          userSign: amico.segno, amico: amico, now: DateTime(2026, 10, 3))
    ),
  ]) {
    testWidgets('ogni periodo con una lettura si apre col gesto ($soggetto)',
        (tester) async {
      final righe = <String>[];
      var conGesto = 0, guardati = 0, senzaTocco = 0;
      final perTradizione = <AstroTradition, int>{};
      for (final t in const [
        AstroTradition.occidentale,
        AstroTradition.vedica,
        AstroTradition.cinese,
      ]) {
        for (final p in HoroscopePeriod.values) {
          await monta(tester, schermata());
          if (t != AstroTradition.occidentale) {
            final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
            await tester.ensureVisible(chip);
            await tester.tap(chip);
            for (var i = 0; i < 8; i++) {
              await tester.pump(const Duration(milliseconds: 250));
            }
          }
          final tab = find.byKey(Key('oroscopo_period_${p.name}'));
          await tester.ensureVisible(tab);
          await tester.tap(tab);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          final primaLetture = letture();
          final primaGesto = gesto();
          if (primaGesto) await interroga(tester);
          final dopoLetture = letture();
          righe.add(
              '${t.name} ${p.name}: prima ${primaGesto ? 'gesto' : 'niente'} '
              '$primaLetture letture, dopo $dopoLetture');
          if (primaLetture > 0) senzaTocco++;
          if (primaGesto && dopoLetture > 0) {
            conGesto++;
            perTradizione[t] = (perTradizione[t] ?? 0) + 1;
          }
          guardati++;
          await tester.pumpWidget(const SizedBox());
        }
      }
      print('ORDINE FC VOCE 03 ($soggetto): ${righe.join('; ')}');
      print('ORDINE FC VOCE 03 ($soggetto): periodi col gesto $conGesto su '
          '$guardati, per tradizione $perTradizione; letture senza il tocco '
          '$senzaTocco');
      cardinaleMinimo(guardati, 12, cosa: 'periodi delle tre tradizioni');
      expect(senzaTocco, 0, reason: righe.join('\n'));
      // Quattro periodi su quattro col gesto, in ognuna delle tre tradizioni.
      for (final t in const [
        AstroTradition.occidentale,
        AstroTradition.vedica,
        AstroTradition.cinese,
      ]) {
        expect(perTradizione[t], 4, reason: '${t.name}\n${righe.join('\n')}');
      }
    });
  }

  // LAPIDE, ordine FC voce 03: qui stava la prova "l'oroscopo dell'amico si
  // apre col gesto", sulla schermata dell'amico (`LOroscopoDellAmicoScreen`),
  // che aveva solo il Giorno. La schermata non c'e' piu' (ordine FC voce 02):
  // l'amico passa dal giro qui sopra, tre tradizioni per quattro periodi.
}
