import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA DOMANDA VIENE PRIMA. Ordine BV voce 05.
///
/// **Parole del fondatore sulla build 2209**: "Scegli la tua domanda deve
/// essere la prima e deve avere un colore diverso, perche' e' li' che si
/// sceglie cosa chiedere".
///
/// Cinque tendine identiche allineate nella stessa griglia: il tipo di stesa,
/// la domanda, la chiave di lettura, il mazzo, il tono. **La domanda era la
/// seconda e vestita come le altre**, cioe' la scelta che cambia il responso
/// stava in mezzo al contorno. Qui si misura che venga per prima e che si
/// veda: il posto e il colore, col contrasto contato sui pixel dipinti.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I sensori non esistono in prova, e con `runAsync` le chiamate al canale
  /// partono davvero: senza questo la prova cade su un difetto che non c'e'.
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

  Future<GlobalKey> monta(WidgetTester tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(
              child: RepaintBoundary(key: radice, child: child!)),
        ),
        home: const StesaTreCarteScreen(seed: 2, skipIntro: true),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const Key('stesa_setup_riga')));
    await tester.pump();
    return radice;
  }

  /// Il contrasto secondo WCAG fra due colori gia' opachi.
  double contrasto(Color a, Color b) {
    double canale(double v) {
      final c = v;
      return c <= 0.03928
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    double luminanza(Color c) =>
        0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
    final la = luminanza(a);
    final lb = luminanza(b);
    final alto = la > lb ? la : lb;
    final basso = la > lb ? lb : la;
    return (alto + 0.05) / (basso + 0.05);
  }

  testWidgets('BV.05: la domanda e\' la prima tendina della griglia',
      (tester) async {
    await monta(tester);
    const tendine = {
      'stesa_topic': 'la domanda',
      'stesa_tipo': 'il tipo di stesa',
      'stesa_chiave': 'la chiave di lettura',
      'stesa_mazzo': 'il mazzo',
    };
    final posti = <String, Rect>{};
    tendine.forEach((chiave, _) {
      final f = find.byKey(Key(chiave));
      if (f.evaluate().isNotEmpty) posti[chiave] = tester.getRect(f);
    });
    expect(posti.containsKey('stesa_topic'), isTrue,
        reason: 'la tendina della domanda non e\' in scena');
    // L'ordine di lettura: prima chi sta piu' in alto, poi chi sta piu' a
    // sinistra sulla stessa riga.
    final ordinate = posti.keys.toList()
      ..sort((x, y) {
        final a = posti[x]!;
        final b = posti[y]!;
        if ((a.top - b.top).abs() > 4) return a.top.compareTo(b.top);
        return a.left.compareTo(b.left);
      });
    // ignore: avoid_print
    print('ORDINE BV VOCE 5: le tendine si leggono in quest\'ordine '
        '${ordinate.map((k) => tendine[k]).join(", ")}');
    expect(ordinate.first, 'stesa_topic',
        reason: 'la prima tendina della griglia e\' '
            '${tendine[ordinate.first]}, non la domanda');
  });

  testWidgets('BV.05: la domanda porta un colore che le altre non hanno',
      (tester) async {
    final radice = await monta(tester);
    // La palette la si prende DALLA TENDINA STESSA: cosi' la prova dice che
    // il colore viene dal Maestro e non da una costante scritta a mano.
    final tendina = tester.widget<TendinaSelettore<TarotTopic>>(find.ancestor(
        of: find.byKey(const Key('stesa_topic')),
        matching: find.byType(TendinaSelettore<TarotTopic>)));
    final palette = tendina.palette;

    Color titoloDi(String chiave, String etichetta) {
      final t = tester.widget<Text>(find.descendant(
          of: find.byKey(Key(chiave)), matching: find.text(etichetta)));
      return t.style!.color!;
    }

    final domanda = titoloDi('stesa_topic', 'SCEGLI LA TUA DOMANDA');
    final altre = {
      'il tipo di stesa': titoloDi('stesa_tipo', 'TIPO DI STESA'),
      'il mazzo': titoloDi('stesa_mazzo', 'MAZZO'),
    };
    // ignore: avoid_print
    print('ORDINE BV VOCE 5: il titolo della domanda e\' $domanda, quello '
        'delle altre ${altre.values.toSet()}');
    expect(domanda, palette.glow,
        reason: 'il colore della domanda non e\' il bagliore del Maestro: '
            'sarebbe un colore nuovo, e il colore lo porta la palette');
    for (final voce in altre.entries) {
      expect(domanda == voce.value, isFalse,
          reason: 'la domanda ha lo stesso colore di ${voce.key}: e\' cio\' '
              'che il fondatore ha visto, cinque tendine tutte uguali');
    }

    // **IL CONTRASTO SI CONTA SUL FONDO DIPINTO**, non su quello dichiarato:
    // il riquadro e' semitrasparente e sotto ci passa il cosmo.
    final r = tester.getRect(find.byKey(const Key('stesa_topic')));
    late Color fondo;
    await tester.runAsync(() async {
      final b =
          radice.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final origine = tester.getRect(find.byKey(radice)).topLeft;
      // Il colore piu' frequente dentro il riquadro: il testo occupa poco, il
      // fondo occupa tutto il resto.
      final conta = <int, int>{};
      for (var y = r.top.round() + 2; y < r.bottom.round() - 2; y++) {
        for (var x = r.left.round() + 2; x < r.right.round() - 2; x++) {
          final px0 = (x - origine.dx).round();
          final py0 = (y - origine.dy).round();
          if (px0 < 0 || py0 < 0 || px0 >= img.width || py0 >= img.height) {
            continue;
          }
          final i = (py0 * img.width + px0) * 4;
          if (i + 2 >= px.length) continue;
          final v = (px[i] << 16) | (px[i + 1] << 8) | px[i + 2];
          conta[v] = (conta[v] ?? 0) + 1;
        }
      }
      final vincitore =
          conta.entries.reduce((a, b) => a.value >= b.value ? a : b);
      fondo = Color(0xFF000000 | vincitore.key);
    });
    final rapporto = contrasto(domanda, fondo);
    // ignore: avoid_print
    print('ORDINE BV VOCE 5: il titolo della domanda sta su un fondo $fondo, '
        'contrasto ${rapporto.toStringAsFixed(2)} a 1');
    expect(rapporto, greaterThanOrEqualTo(4.5),
        reason: 'il contrasto e\' ${rapporto.toStringAsFixed(2)} a 1: sotto il '
            'quattro e mezzo il colore che mette in rilievo la domanda la '
            'rende meno leggibile delle altre');
  });

  testWidgets('BV.05: il colore in rilievo regge su tutti e tre i Maestri',
      (tester) async {
    // La stesa e' di Medora, ma la tendina e' un pezzo del design system e
    // domani puo' comparire altrove. Il conto e' lo stesso su ogni palette,
    // fatto sul fondo dichiarato del riquadro sopra il piu' scuro dello
    // sfondo, che e' il caso peggiore.
    final magri = <String>[];
    for (final p in const [
      MaestroPalette.medora,
      MaestroPalette.aura,
      MaestroPalette.caligo,
    ]) {
      final fondo = Color.alphaBlend(
          p.deepest.withValues(alpha: 0.65), p.backgroundGradient.last);
      final rapporto = contrasto(p.glow, fondo);
      // ignore: avoid_print
      print('ORDINE BV VOCE 5: sul Maestro ${p.label} il bagliore contro il '
          'riquadro fa ${rapporto.toStringAsFixed(2)} a 1');
      if (rapporto < 4.5) {
        magri.add('${p.label} a ${rapporto.toStringAsFixed(2)}');
      }
    }
    expect(magri, isEmpty,
        reason: 'su questi Maestri il colore in rilievo non arriva al quattro '
            'e mezzo: $magri');
  });
}
