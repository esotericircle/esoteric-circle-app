// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_giro_dell_oracolo.dart';

/// **OGNI RESPONSO APRE COL COLPO D'OCCHIO VISIVO.** Ordine GC voci GC.06 e
/// GC.18, 22 ottobre 2026.
///
/// Il fondatore, alle 16:06: *"io noto che c'è troppo testo e infografica zero
/// e ci sono delle regole per le risposte o responsi che indicano di inserire
/// sempre un impatto visivo grafico per non appesantire di testo e annoiare
/// l'utente"*; alle 16:09: *"Approvo"*. Briefing V13, sezione 33; Linee Guida
/// V14, sezione 2, strato 1.
///
/// Per ogni arte toccata dall'ordine si apre il responso e si misura che il
/// colpo d'occhio stia sopra il titolo. La prova cade col nome dell'arte.
/// Le arti: la Stesa di Tarocchi (le piste dei semi, `LeBarreDeiSemi`) e
/// l'Oracolo degli Angeli (la scala di luce, `LaScalaDelResponso`).
class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final viste = <String>[];

  setUp(() {
    LaSuoneria.spentaPerLeProve = true;
    silenziaISensoriDelCosmo();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  void colpoSopraIlTitolo(
      WidgetTester tester, String arte, String colpo, String titolo) {
    final c = find.byKey(Key(colpo));
    expect(c, findsOneWidget,
        reason: '$arte: il responso mostra il testo senza il livello visivo');
    final t = find.byKey(Key(titolo));
    expect(t, findsOneWidget, reason: '$arte: il responso non ha il titolo');
    expect(tester.getRect(c).bottom, lessThanOrEqualTo(tester.getRect(t).top),
        reason: '$arte: il colpo d\'occhio non sta sopra il titolo');
    viste.add(arte);
  }

  for (final tipo in TarotSpreadType.values) {
    testWidgets('Stesa di Tarocchi, ${tipo.name}', (tester) async {
      for (final f in const [
        ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
        ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
      ]) {
        final loader = FontLoader(f[0]);
        loader.addFont(
            Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
        await loader.load();
      }
      tester.view.physicalSize = const Size(360, 15000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: 5,
              revealAll: true,
              skipIntro: true,
              topic: TarotTopic.bivio,
              tipo: tipo,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      colpoSopraIlTitolo(tester, 'Stesa di Tarocchi, ${tipo.name}',
          'stesa_colpo_d_occhio', 'stesa_synthesis');
    });
  }

  testWidgets('Oracolo degli Angeli', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (c, figlio) => MaestroScope(child: figlio!),
        home: OracoloDegliAngeliScreen(
          fabbricaDellaScena: _Ferma.new,
          caso: Random(7),
          adesso: () => DateTime(2026, 10, 15, 10, 5),
          identita: BirthIdentity(
              birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true),
          chiamata: (i, r, c) async => jsonFintoDellOracolo(c),
        ),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await consultaLOracolo(tester, 'Devo cambiare lavoro?');
    colpoSopraIlTitolo(tester, 'Oracolo degli Angeli',
        'oracolo_colpo_d_occhio', 'oracolo_principale_titolo');
  });

  tearDownAll(() {
    print('GC.06 e GC.18: responsi guardati ${viste.length}: $viste');
    cardinaleMinimo(viste.length, TarotSpreadType.values.length + 1,
        cosa: 'responsi col colpo d\'occhio',
        perche: 'le quattro stese e l\'Oracolo');
  });
}
