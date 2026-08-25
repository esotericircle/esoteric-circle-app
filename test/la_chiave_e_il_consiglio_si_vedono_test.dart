import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CHIAVE SI VEDE, E IL CONSIGLIO SI LEGGE. Ordine BN voci 05 e 06.
///
/// - **BN.05**: la carta che regge la lettura si distingue dalle altre due
///   ANCHE nella stesa, e non solo nella sua bolla. La distinzione si misura
///   sui PIXEL e mai sui rettangoli di layout, col metodo di AX.02: le carte
///   escono dal proprio riquadro, quindi un confronto di geometrie direbbe il
///   falso.
/// - **BN.06**: il titolo del consiglio sale di una misura piena della scala e
///   resta su una riga sola; il testo si presenta in due o tre paragrafi, e
///   nessun paragrafo comincia a meta' di una frase.
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

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<GlobalKey> monta(WidgetTester tester, {int seed = 2}) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = const Size(360, 4400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final radice = GlobalKey();
    await tester.pumpWidget(attorno(RepaintBoundary(
      key: radice,
      child: StesaTreCarteScreen(
        seed: seed,
        revealAll: true,
        skipIntro: true,
        topic: TarotTopic.bivio,
      ),
    )));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return radice;
  }

  /// Quanto oro c'e' attorno alla carta [posizione], misurato SUI PIXEL.
  ///
  /// Si guarda una cornice larga sei punti attorno al riquadro della carta,
  /// perche' e' li' che il segno vive: dentro c'e' la figura, che e' uguale
  /// per tutte e non direbbe niente.
  Future<double> oroAttorno(
      WidgetTester tester, GlobalKey radice, SpreadPosition posizione) async {
    final carta = find.byKey(Key('stesa_carta_${posizione.name}'));
    final r = tester.getRect(carta);
    var quanti = 0;
    await tester.runAsync(() async {
      final b =
          radice.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final origine = tester.getRect(find.byKey(radice)).topLeft;
      const bordo = 6.0;
      for (var y = (r.top - bordo).round(); y < (r.bottom + bordo).round(); y++) {
        for (var x = (r.left - bordo).round();
            x < (r.right + bordo).round();
            x++) {
          // Solo la cornice: dentro il riquadro non si guarda.
          final dentro = x > r.left + bordo &&
              x < r.right - bordo &&
              y > r.top + bordo &&
              y < r.bottom - bordo;
          if (dentro) continue;
          final px0 = (x - origine.dx).round();
          final py0 = (y - origine.dy).round();
          if (px0 < 0 || py0 < 0 || px0 >= img.width || py0 >= img.height) {
            continue;
          }
          final i = (py0 * img.width + px0) * 4;
          if (i + 2 >= px.length) continue;
          // Oro: il rosso domina sul blu.
          if (px[i] - px[i + 2] > 25) quanti++;
        }
      }
    });
    return quanti.toDouble();
  }

  testWidgets('la carta chiave si distingue dalle altre due, sui pixel',
      (tester) async {
    // Tre semi diversi, cosi' la chiave cade su posizioni diverse e la prova
    // non misura una sola configurazione fortunata.
    for (final seed in const [2, 5, 9]) {
      final radice = await monta(tester, seed: seed);
      final lettura = TarotReading.of(
        TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed)),
        TarotTopic.bivio,
      );
      final chiave = lettura.chiave.drawn.position;

      final misure = <SpreadPosition, double>{};
      for (final p in SpreadPosition.values) {
        misure[p] = await oroAttorno(tester, radice, p);
      }
      final altre = [
        for (final p in SpreadPosition.values)
          if (p != chiave) misure[p]!,
      ];
      // ignore: avoid_print
      print('BN.05 MISURA seme $seed, chiave ${chiave.name}: '
          'oro attorno alla chiave ${misure[chiave]!.toStringAsFixed(0)}, '
          'alle altre ${altre.map((v) => v.toStringAsFixed(0)).join(" e ")}');
      for (final v in altre) {
        expect(misure[chiave]!, greaterThan(v * 1.5),
            reason: 'seme $seed: la carta chiave (${chiave.name}) non si '
                'distingue dalle altre due nella stesa: chi guarda le tre '
                'carte non sa quale regge la lettura');
      }
    }
  });

  testWidgets('il titolo del consiglio e\' cresciuto e sta su una riga',
      (tester) async {
    await monta(tester);
    final titolo = find.byKey(const Key('stesa_consiglio_titolo'));
    expect(titolo, findsOneWidget);
    final w = tester.widget<Text>(titolo);
    // La misura non e' battuta qui: viene dalla scala del design system.
    expect(w.style!.fontSize, TypographyTokens.titoloScheda().fontSize,
        reason: 'il titolo non e\' salito al gradino pieno della scala');
    expect(w.style!.fontSize, greaterThan(TypographyTokens.pavimento),
        reason: 'il titolo e\' ancora al pavimento della scala');
    final tp = TextPainter(
      text: TextSpan(text: w.data, style: w.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 360 - 32);
    expect(tp.didExceedMaxLines, isFalse,
        reason: 'il titolo cresciuto non sta piu\' su una riga a 360 punti');
  });

  test('il consiglio ha due o tre paragrafi, e nessuno comincia a meta\'', () {
    for (final seed in const [2, 5, 9, 13, 21]) {
      for (final topic in TarotTopic.values) {
        final lettura = TarotReading.of(
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed)),
          topic,
        );
        // La domanda finale sta gia' staccata da sempre: si guarda il corpo.
        final corpo = lettura.consiglio.split('\n\n');
        expect(corpo.length, greaterThanOrEqualTo(3),
            reason: 'seme $seed, ${topic.name}: il consiglio non e\' diviso '
                'in paragrafi');
        // L'ultimo pezzo e' la domanda: i paragrafi del consiglio sono gli
        // altri, e devono essere due o tre.
        final paragrafi = corpo.sublist(0, corpo.length - 1);
        expect(paragrafi.length, inInclusiveRange(2, 3),
            reason: 'seme $seed, ${topic.name}: i paragrafi sono '
                '${paragrafi.length}, e l\'ordine ne chiede due o tre');
        for (final p in paragrafi) {
          final primo = p.trimLeft();
          expect(primo.isNotEmpty, isTrue);
          // NESSUN PARAGRAFO COMINCIA A META' DI UNA FRASE: la prima lettera
          // e' maiuscola, o e' un nome proprio, e mai una minuscola figlia di
          // un taglio.
          expect(primo[0], primo[0].toUpperCase(),
              reason: 'seme $seed, ${topic.name}: un paragrafo comincia con '
                  '"${primo.substring(0, primo.length.clamp(0, 40))}", cioe\' '
                  'a meta\' di una frase');
        }
      }
    }
  });
}
