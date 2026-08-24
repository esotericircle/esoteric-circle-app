import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/face/face_corpus.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La schermata della Costellazione del Viso.
///
/// La fotocamera dal vivo non si prova in headless: qui si prova il percorso
/// deterministico, la soglia e il ripiego tattile che alimenta lo stesso motore
/// e porta al responso, cosi' l'esperienza e' verificata senza plugin.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: const MaterialApp(
          home: MaestroScope(child: FaceConstellationScreen()),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('La soglia mostra privacy, cielo e ingresso al ripiego',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('face_privacy')), findsOneWidget);
    expect(find.byKey(const Key('face_sky_setting')), findsOneWidget);
    expect(find.byKey(const Key('face_start')), findsOneWidget);
    expect(find.byKey(const Key('face_fallback_entry')), findsOneWidget);
  });

  testWidgets('Il ripiego alimenta il motore e porta al responso',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('face_fallback_entry')));
    await passo(tester);

    // Sceglie una variante per ognuna delle cinque categorie del ripiego.
    for (final t in const [
      FaceTrait.voltoTondo,
      FaceTrait.occhiGrandi,
      FaceTrait.sopraccigliaDritte,
      FaceTrait.labbraPiene,
      FaceTrait.mentoAmpio,
    ]) {
      final f = find.byKey(Key('face_pick_${t.name}'));
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await tester.pump();
    }

    final done = find.byKey(const Key('face_fallback_done'));
    await tester.ensureVisible(done);
    await tester.pump();
    await tester.tap(done);
    await passo(tester);

    // Il responso c'e', col titolo evocativo del dominante e la sintesi.
    expect(find.byKey(const Key('face_result')), findsOneWidget);
    // Fra le scelte, occhi grandi ha la salienza piu' alta: e' il dominante.
    expect(find.text(FaceTrait.occhiGrandi.titoloEvocativo), findsOneWidget);
    expect(find.byKey(const Key('face_synthesis')), findsOneWidget);
    expect(find.byKey(const Key('face_trait_occhiGrandi')), findsWidgets);
    expect(find.byKey(const Key('face_share')), findsOneWidget);
    expect(find.byKey(const Key('face_consulta')), findsOneWidget);
  });

  testWidgets('Il sottotitolo segue l\'interruttore dei transiti',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('face_fallback_entry')));
    await passo(tester);
    for (final t in const [
      FaceTrait.voltoQuadrato,
      FaceTrait.occhiRaccolti,
      FaceTrait.sopraccigliaAngolo,
      FaceTrait.labbraSottili,
      FaceTrait.mentoAPunta,
    ]) {
      final f = find.byKey(Key('face_pick_${t.name}'));
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await tester.pump();
    }
    final done = find.byKey(const Key('face_fallback_done'));
    await tester.ensureVisible(done);
    await tester.pump();
    await tester.tap(done);
    await passo(tester);

    expect(tester.widget<Text>(find.byKey(const Key('face_mode_subtitle'))).data,
        'non legato ai transiti astrologici');
    final sw = find.byKey(const Key('face_transits_switch'));
    await tester.ensureVisible(sw);
    await tester.pump();
    await tester.tap(sw);
    await passo(tester);
    expect(tester.widget<Text>(find.byKey(const Key('face_mode_subtitle'))).data,
        'legato ai transiti astrologici di oggi');
  });

  testWidgets('Il pulsante Parlane con Aura e\' nel verde di Aura',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);
    await tester.tap(find.byKey(const Key('face_fallback_entry')));
    await passo(tester);
    for (final t in const [
      FaceTrait.voltoTondo,
      FaceTrait.occhiGrandi,
      FaceTrait.sopraccigliaCurve,
      FaceTrait.labbraPiene,
      FaceTrait.mentoAmpio,
    ]) {
      final f = find.byKey(Key('face_pick_${t.name}'));
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await tester.pump();
    }
    final done = find.byKey(const Key('face_fallback_done'));
    await tester.ensureVisible(done);
    await tester.pump();
    await tester.tap(done);
    await passo(tester);

    final verde = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final btn =
        tester.widget<FilledButton>(find.byKey(const Key('face_consulta')));
    expect(btn.style!.backgroundColor!.resolve({}), verde.primary);
  });

  test('La rotta del viso porta alla schermata vera, non alla soglia', () {
    final r = artRouteFor('face_constellation');
    expect(r, isNotNull);
    expect(artiSullaSoglia.containsKey('face_constellation'), isFalse);
  });

  test('Ogni tratto ha titolo evocativo e frase', () {
    for (final t in FaceTrait.values) {
      expect(t.titoloEvocativo.trim(), isNotEmpty, reason: t.name);
      expect(FaceCorpus.frase(t).trim(), isNotEmpty, reason: t.name);
    }
  });
}
