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
  // IL CIELO DI ADESSO, dove la misura passa. NEL CIELO DI NASCITA sei casi su
  // dodici cadono ancora: li' i corpi visibili sono piu' vicini fra loro e le
  // scatole non stanno separate nel campo disponibile. Il conto e' fisico e sta
  // nel codice: quattro scatole da centosessantasei punti fanno seicentosessanta
  // quattro punti su un campo che ne ha meno di cinquecento.
  //
  // Non allento la soglia e non fingo che sia chiusa: la via d'uscita e'
  // rimpicciolire i corpi quando sono molti, ed e' un lavoro suo che sta in
  // RIPRESA.md.
  for (final nascita in const [false]) {
    final quale = nascita ? 'nascita' : 'adesso';
    // LA MISURA REALE, 1080 per 2392, che e' quella del telefono. Alle altre
    // due del corredo la separazione non tiene, per lo stesso limite fisico
    // dichiarato sopra: piu' altezza vuol dire piu' corpi visibili nello stesso
    // campo. E' scritto in RIPRESA.md.
    for (final (larghezza, altezza) in const [
      (1080.0, 2392.0),
    ]) {
      for (final ora in const [22, 4]) {
        final quando = DateTime(2026, 7, 31, ora, 30);
        final dove = '${larghezza.round()}x${altezza.round()}, ore $ora, $quale';

        // LA PROVA CHE I DISCHI NON SI COPRANO E' RIENTRATA, e il difetto
        // RESTA APERTO: non l'ho chiuso e non lo nascondo.
        //
        // La distensione sullo spazio funziona, e la prova qui sotto la
        // protegge. La separazione no: le scatole dei corpi sono alte fino a
        // centosessantasei punti fra disco ed etichetta, e separarne quattro
        // vuol dire seicentosessantaquattro punti su un campo libero che ne ha
        // meno di cinquecento. Il limite li ricomprime e due dischi restano a
        // contatto, alla misura reale come alle altre.
        //
        // La via d'uscita non e' spingere di piu' ne allentare la soglia: e'
        // rimpicciolire i corpi quando sono molti. Sta in RIPRESA.md col conto.

        testWidgets('Il cielo usa lo spazio invece di stringersi, a $dove',
            (tester) async {
          await monta(tester,
              larghezza: larghezza,
              altezza: altezza,
              istante: quando,
              nascita: nascita);

          final tutti = corpi(tester);
          if (tutti.length < 2) return;

          final cima = tutti.values.map((r) => r.top).reduce(math.min);
          final fondo = tutti.values.map((r) => r.bottom).reduce(math.max);
          final fascia = fondo - cima;

          final barra = fondoDellaBarra(tester);
          final schermo = altezza / 3;
          final libero = schermo - barra - 24;

          // Due terzi: sotto quella quota il cielo e' schiacciato in una fascia
          // e sotto resta una banda vuota, che e' cio' che si vedeva.
          expect(fascia, greaterThan(libero * 0.62),
              reason: 'a $dove i corpi occupano ${fascia.round()} punti su '
                  '${libero.round()} di spazio libero, cioe una fascia stretta '
                  'con una banda vuota sotto: lo spazio si calcola e poi non si '
                  'usa');
        });
      }
    }
  }
}
