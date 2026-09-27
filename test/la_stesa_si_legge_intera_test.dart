import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA STESA SI LEGGE INTERA.** Ordine EQ voci 05, 06, 11 e 12, 27 settembre
/// 2026.
///
/// Le catture del fondatore, da un iPhone 17 Pro (402 per 874 punti): la
/// scritta "PRESENTE" attaccata alla carta chiave, "present" ed "e" su due
/// righe nella card da condividere, il segno del verso in due posti diversi
/// nel riepilogo, "Stesa di Tarocchi" su due righe, "IL CONSIGLIO DI" senza
/// Medora. Si misura a 402 punti con la piattaforma iOS e a 360 con Android,
/// sui rettangoli dipinti, a riposo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  /// La piattaforma della misura, che il banco rimette a posto da solo.
  TargetPlatformVariant laPiattaforma(bool ios) => TargetPlatformVariant.only(
      ios ? TargetPlatform.iOS : TargetPlatform.android);

  /// Le due misure: l'iPhone 17 Pro delle catture e il Realme.
  const misure = [
    (larghezza: 402.0, altezza: 874.0, ios: true),
    (larghezza: 360.0, altezza: 800.0, ios: false),
  ];

  Future<void> monta(WidgetTester tester, double larghezza, bool ios,
      {int seed = 2, double scala = 1.0}) async {
    silenzia();
    await caricaCaratteri();
    // Alta abbastanza da vedere tutto senza scorrere: si misura la forma.
    tester.view.physicalSize = Size(larghezza, 4400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MediaQuery(
        // A riposo: niente galleggiamento, le carte stanno ferme.
        data: MediaQueryData(
            disableAnimations: true, textScaler: TextScaler.linear(scala)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: seed,
              revealAll: true,
              skipIntro: true,
              topic: TarotTopic.momentoCheVivo,
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  for (final m in misure) {
    final nome = '${m.larghezza.toStringAsFixed(0)} punti'
        '${m.ios ? ', iOS' : ''}';

    testWidgets(
        'EQ.05: ogni scritta sta staccata dalla sua carta della stessa '
        'distanza, e le tre sono allineate, a $nome', (tester) async {
      await monta(tester, m.larghezza, m.ios);
      final distanze = <String, double>{};
      final cime = <String, double>{};
      for (final p in SpreadPosition.values) {
        final carta = tester.getRect(find.byKey(Key('stesa_carta_${p.name}')));
        final scritta =
            tester.getRect(find.byKey(Key('stesa_etichetta_${p.name}')));
        distanze[p.name] = scritta.top - carta.bottom;
        cime[p.name] = scritta.top;
      }
      // ignore: avoid_print
      print('EQ.05 MISURA a $nome: distanze fra carta e scritta '
          '${distanze.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}, '
          'cime delle scritte '
          '${cime.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
      for (final d in distanze.values) {
        expect(d, greaterThanOrEqualTo(8),
            reason: 'una scritta tocca la sua carta: $distanze');
      }
      final valori = distanze.values.toList();
      expect(
          valori.reduce((a, b) => a > b ? a : b) -
              valori.reduce((a, b) => a < b ? a : b),
          lessThanOrEqualTo(1),
          reason: 'le tre distanze non sono uguali: $distanze');
      final alte = cime.values.toList();
      expect(
          alte.reduce((a, b) => a > b ? a : b) -
              alte.reduce((a, b) => a < b ? a : b),
          lessThanOrEqualTo(0.5),
          reason: 'le tre scritte non sono allineate: $cime');
    }, variant: laPiattaforma(m.ios));

    testWidgets(
        'EQ.11 ed EQ.12: il titolo della stesa e quello del consiglio '
        'stanno interi su una riga, a $nome', (tester) async {
      // **ANCHE A SCALA 1,3**, quella del corredo di casa: a 1,0 il titolo
      // del consiglio stava gia' su una riga, eppure sull'iPhone del
      // fondatore Medora spariva. La prova nata a 1,0 restava verde sul
      // codice di prima: la grandezza misurata e' cambiata, non la soglia.
      for (final scala in const [1.0, 1.3]) {
        await monta(tester, m.larghezza, m.ios, scala: scala);
        for (final chiave in const ['stesa_titolo', 'stesa_consiglio_titolo']) {
          final p =
              tester.renderObject<RenderParagraph>(find.byKey(Key(chiave)));
          final righe = p.righeNecessarie;
          final testo = p.text.toPlainText();
          // ignore: avoid_print
          print('EQ.11 EQ.12 MISURA a $nome, scala $scala: "$testo" su '
              '$righe righe, tagliato ${p.didExceedMaxLines}');
          // A scala 1,0 una riga, come vuole l'ordine; a 1,3 mai tagliato.
          if (scala == 1.0) {
            expect(righe, 1, reason: '"$testo" sta su $righe righe');
          }
          expect(p.didExceedMaxLines, isFalse,
              reason: '"$testo" perde una parte di se\' a scala $scala');
        }
        final consiglio = tester.renderObject<RenderParagraph>(
            find.byKey(const Key('stesa_consiglio_titolo')));
        expect(consiglio.text.toPlainText(), contains('MEDORA'));
      }
    }, variant: laPiattaforma(m.ios));

    testWidgets(
        'EQ.06: il segno del verso comincia la seconda riga in tutte '
        'le righe del riepilogo, a $nome', (tester) async {
      // Una stesa con almeno due carte capovolte, come nelle catture. Il seme
      // si cerca con la legge con cui la schermata assegna il verso,
      // `versoDi` sul mazzo mescolato: `TarotSpread.draw` ne usa un'altra.
      int? scelto;
      for (var s = 1; s < 400 && scelto == null; s++) {
        final mazzo = TarotSpread.mazzoMescolato(seed: s);
        final capovolte = [
          for (var i = 0; i < 3; i++)
            if (TarotSpread.versoDi(mazzo[i], s)) i
        ];
        if (capovolte.length >= 2 && capovolte.contains(1)) scelto = s;
      }
      expect(scelto, isNotNull,
          reason: 'nessuna stesa con due carte capovolte nei primi 400 semi');
      await monta(tester, m.larghezza, m.ios, seed: scelto!);
      expect(find.byKey(const Key('stesa_reversed_presente')), findsOneWidget,
          reason: 'il seme $scelto non porta il Presente capovolto a video');
      final sinistre = <String, double>{};
      for (final p in SpreadPosition.values) {
        final segno = find.byKey(Key('stesa_reversed_${p.name}'));
        if (segno.evaluate().isEmpty) continue;
        final rSegno = tester.getRect(
            find.ancestor(of: segno, matching: find.byType(Container)).first);
        final rNome = tester.getRect(find.byKey(Key('stesa_name_${p.name}')));
        sinistre[p.name] = rSegno.left;
        expect(rSegno.top, greaterThanOrEqualTo(rNome.bottom - 0.5),
            reason: 'il segno del ${p.name} sta sulla riga del nome');
      }
      // ignore: avoid_print
      print('EQ.06 MISURA a $nome, seme $scelto: bordo sinistro dei segni '
          '${sinistre.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
      final valori = sinistre.values.toList();
      expect(valori.length, greaterThanOrEqualTo(2));
      expect(
          valori.reduce((a, b) => a > b ? a : b) -
              valori.reduce((a, b) => a < b ? a : b),
          lessThanOrEqualTo(0.5),
          reason: 'i segni del verso stanno in posti diversi: $sinistre');
    }, variant: laPiattaforma(m.ios));
  }

  testWidgets('EQ.06: nella card da condividere nessuna posizione va a capo',
      (tester) async {
    await caricaCaratteri();
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StesaShareCard(
            spread: TarotSpread.draw(seed: 7),
            palette: MaestroPalette.medora,
          ),
        ),
      ),
    ));
    await tester.pump();
    for (final p in SpreadPosition.values) {
      final r = tester.renderObject<RenderParagraph>(
          find.byKey(Key('card_posizione_${p.name}')));
      final righe = r.righeNecessarie;
      // La scritta intera sta nella sua colonna.
      final larga = r.getMaxIntrinsicWidth(double.infinity);
      // ignore: avoid_print
      print('EQ.06 MISURA sulla card: "${r.text.toPlainText()}" su $righe '
          'righe, larga ${larga.toStringAsFixed(1)} nella colonna di '
          '${r.size.width.toStringAsFixed(1)}');
      expect(righe, 1, reason: '"${r.text.toPlainText()}" va a capo');
      expect(larga, lessThanOrEqualTo(r.size.width + 0.5),
          reason: '"${r.text.toPlainText()}" non sta nella sua colonna');
    }
  });

  testWidgets(
      'EQ.12: un titolo a una riga che non ci sta va a capo, non perde '
      'parole', (tester) async {
    await caricaCaratteri();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 150,
            child: TitoloCheNonSiRompe(
              chiaveDelTesto: Key('titolo_stretto'),
              testo: 'IL CONSIGLIO DI MEDORA',
              righe: 1,
              stile: TextStyle(fontFamily: 'Cinzel', fontSize: 20),
            ),
          ),
        ),
      ),
    ));
    final p = tester
        .renderObject<RenderParagraph>(find.byKey(const Key('titolo_stretto')));
    // ignore: avoid_print
    print('EQ.12 MISURA in 150 punti: "${p.text.toPlainText()}" su '
        '${p.righeNecessarie} righe, tagliato ${p.didExceedMaxLines}, misura '
        '${TypographyTokens.pavimento} di pavimento');
    expect(p.didExceedMaxLines, isFalse,
        reason: 'il titolo a una riga perde una parte di se\' invece di '
            'andare a capo');
  });
}

/// **QUANTE RIGHE SERVONO AL TESTO DIPINTO**, alla larghezza della sua
/// scatola e senza tetto di righe: se sono due, il titolo va a capo o perde
/// una parte di se'.
extension _Righe on RenderParagraph {
  int get righeNecessarie => (TextPainter(
        text: text,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: size.width))
          .computeLineMetrics()
          .length;
}
