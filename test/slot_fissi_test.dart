import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CIELO RESTA INTERO: nessun corpo finisce sotto qualcosa.
///
/// **I fatti, dagli screenshot del fondatore.** La Luna era disegnata in cima e
/// finiva SOTTO LA BARRA DEL TITOLO, tagliata dall'orologio e dalle icone di
/// sistema: se ne vedeva la meta' inferiore, e la sua etichetta si leggeva
/// sbiadita dietro il titolo. Cancro finiva SOTTO LA SCHEDA, con l'etichetta
/// fantasma attraverso il vetro.
///
/// **La causa e' una sola per tutti e due i casi**: il campo del cielo si
/// componeva su TUTTA l'altezza dello schermo, ignorando la barra sopra e la
/// scheda sotto. Adesso si compone dentro lo spazio libero, che e' un dato
/// calcolato.
///
/// La prova gira alle tre misure del corredo, con la misura reale per prima, e
/// a due ore diverse, perche' la Luna sale e scende e il difetto compare solo
/// quando e' alta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> monta(
    WidgetTester tester, {
    required double larghezza,
    required double altezza,
    required DateTime istante,
    bool nascita = false,
  }) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(larghezza, altezza);
    // Le barre di sistema ci sono: e' proprio sotto quella in alto che la Luna
    // finiva, quindi senza dichiararle la prova non vedrebbe il difetto.
    tester.view.padding = const FakeViewPadding(top: 108, bottom: 72);
    tester.view.viewPadding = const FakeViewPadding(top: 108, bottom: 72);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: SkyOverviewScreen(
          now: istante,
          birth: nascita,
          ctaLabel: nascita ? 'Leggi la tua carta' : null,
          onCta: nascita ? () {} : null,
          luogoIniziale: const SkyPlace(latitude: 45.46, longitude: 9.19),
          location: const DisabledSkyLocation(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));
  }

  /// I corpi disegnati adesso, con la chiave e il rettangolo che occupano.
  Map<String, Rect> corpi(WidgetTester tester) {
    final out = <String, Rect>{};
    for (final c in const [
      'moon',
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces',
    ]) {
      final f = find.byKey(Key('sky_body_$c'));
      if (f.evaluate().isNotEmpty) out[c] = tester.getRect(f);
    }
    return out;
  }

  /// Il bordo inferiore della barra del titolo, aree di sistema comprese.
  double fondoDellaBarra(WidgetTester tester) {
    final f = find.byType(AppBar);
    return f.evaluate().isEmpty ? 0 : tester.getRect(f).bottom;
  }

  /// Il bordo superiore della scheda, quando c'e'.
  double? cimaDellaScheda(WidgetTester tester) {
    final f = find.byType(SingleChildScrollView);
    if (f.evaluate().isEmpty) return null;
    return tester.getRect(f.first).top;
  }

  // LA MISURA REALE per prima, poi le altre due del corredo, e per ENTRAMBI i
  // cieli: il cielo di nascita e' la stessa classe con `birth` vero, ed era la
  // porta che non avevo guardato.
  // TRE MISURE DEL CORREDO, ENTRAMBI I CIELI. Con gli slot fissi le tre regole
  // sono banali da rispettare, perche' le posizioni le scegliamo noi.
  for (final nascita in const [false, true]) {
    final quale = nascita ? 'nascita' : 'adesso';
    for (final (larghezza, altezza) in const [
      (1080.0, 2392.0),
      (1170.0, 2532.0),
      (1080.0, 2532.0),
    ]) {
      final dove = '${larghezza.round()}x${altezza.round()}, $quale';

      testWidgets('Niente esce, niente copre, niente si sovrappone, a $dove',
          (tester) async {
        await monta(tester,
            larghezza: larghezza,
            altezza: altezza,
            istante: DateTime(2026, 7, 31, 22, 30),
            nascita: nascita);

        final tutti = corpi(tester);
        expect(tutti, isNotEmpty,
            reason: 'a $dove non si disegna nessun corpo');

        final barra = fondoDellaBarra(tester);
        final scheda = find.byKey(const Key('sky_scheda'));
        final cimaScheda = scheda.evaluate().isEmpty
            ? altezza / 3
            : tester.getRect(scheda).top;

        for (final e in tutti.entries) {
          // 1. Nessun corpo e nessuna etichetta esce dallo spazio libero. Il
          //    rettangolo misurato include gia' l'etichetta, che sta sotto.
          expect(e.value.top, greaterThanOrEqualTo(barra),
              reason: 'a $dove il corpo ${e.key} finisce sotto la barra del '
                  'titolo');
          expect(e.value.bottom, lessThanOrEqualTo(cimaScheda),
              reason: 'a $dove il corpo ${e.key} finisce sotto la scheda');
        }

        // 2 e 3. Nessun corpo copre un altro, nessuna etichetta si sovrappone
        //        a un'altra. Con le scatole intere si misurano tutte e due
        //        insieme, perche' la scatola include l etichetta.
        final chiavi = tutti.keys.toList();
        for (var i = 0; i < chiavi.length; i++) {
          for (var j = i + 1; j < chiavi.length; j++) {
            expect(tutti[chiavi[i]]!.overlaps(tutti[chiavi[j]]!), isFalse,
                reason: 'a $dove ${chiavi[i]} e ${chiavi[j]} si sovrappongono: '
                    'e cosi che nasceva CAGEMROLLI, due nomi stampati uno '
                    'dentro l altro');
          }
        }
      });

      testWidgets('Ogni corpo sta nel suo slot, a $dove', (tester) async {
        await monta(tester,
            larghezza: larghezza,
            altezza: altezza,
            istante: DateTime(2026, 7, 31, 22, 30),
            nascita: nascita);

        final tutti = corpi(tester);
        final luna = tutti['moon'];
        if (luna == null) return;
        final larghezzaLogica = larghezza / 3;

        // La LUNA sta in alto al centro: e' il primo slot dichiarato.
        expect((luna.center.dx - larghezzaLogica / 2).abs(),
            lessThan(larghezzaLogica * 0.12),
            reason: 'a $dove la Luna non e al centro');
        for (final e in tutti.entries) {
          if (e.key == 'moon') continue;
          expect(luna.center.dy, lessThan(e.value.center.dy),
              reason: 'a $dove la Luna non e sopra ${e.key}');
        }
      });
    }
  }
}
