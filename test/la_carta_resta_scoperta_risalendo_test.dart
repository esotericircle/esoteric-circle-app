import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA CARTA RESTA SCOPERTA RISALENDO LO SCORRIMENTO.** Ordine del 14
/// ottobre 2026, segnalato dal fondatore sul telefono vero, build 2309.
///
/// Scendendo con lo scorrimento tutto e' fluido; risalendo oltre la fila
/// delle carte in piedi, il giro (dorso verso faccia) di ogni carta ripartiva
/// da capo, con uno scatto nello scorrimento. **Causa**: `_FlipCard`
/// animava un giro di 650 ms a ogni montaggio del suo stato, chiamato da
/// `didChangeDependencies` la prima volta; nella lista non pigra della
/// schermata (`ListView(children: ...)`) un elemento lontano dallo schermo
/// viene smontato e rimontato dalla virtualizzazione degli sliver, e
/// `_FlipCard` ripartiva ogni volta, anche se la carta era gia' scoperta da
/// un pezzo. **LAPIDE**: `_FlipCard` e `_FlipCardState`, tolte: la fila in
/// piedi mostra sempre la faccia (`FacciaDellaCarta`), mai piu' il dorso,
/// perche' il giro vero lo fa `_CartaSulTavolo` mentre la carta e' ancora
/// sul tavolo e la fila appare gia' scoperta.
///
/// La finestra e' quella di un telefono vero (390x844, non una finestra
/// alta all'infinito): solo cosi' lo scorrimento vero evita davvero la fila
/// dallo schermo e la virtualizzazione della lista la smonta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  testWidgets(
      'risalendo lo scorrimento oltre la fila in piedi, nessuna carta mostra '
      'piu il dorso', (tester) async {
    silenzia();
    await caricaCaratteri();
    // Un telefono vero: lo scorrimento deve servire davvero.
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
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(
          child: StesaTreCarteScreen(
            seed: 2,
            revealAll: true,
            skipIntro: true,
            topic: TarotTopic.bivio,
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    final lista = find.byKey(const Key('stesa_list'));
    expect(lista, findsOneWidget);
    final fila = find.byKey(const Key('tavolo_fila_alzata'));
    expect(fila, findsOneWidget,
        reason: 'la fila in piedi non e\' montata: la prova non vedrebbe '
            'niente');
    expect(find.descendant(of: fila, matching: find.byType(CardBack)),
        findsNothing,
        reason: 'la fila in piedi mostra gia\' il dorso prima di scorrere');

    // Scende abbastanza da portare la fila ben oltre la cache della lista
    // (250 punti di norma), cosi' la virtualizzazione la smonta davvero.
    await tester.drag(lista, const Offset(0, -3000), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('tavolo_fila_alzata')), findsNothing,
        reason: 'la fila e\' ancora a schermo: la discesa non e\' bastata a '
            'smontarla, la prova non misura lo smontaggio vero');

    // Risale fino in cima: la fila rimonta.
    await tester.drag(lista, const Offset(0, 3000), warnIfMissed: false);
    await tester.pump();

    // Durante il giro che il vecchio _FlipCard avrebbe fatto (650 ms), il
    // dorso non deve mai comparire: si guarda fotogramma per fotogramma.
    final dorsoVisto = <int>[];
    for (var ms = 0; ms <= 700; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      final filaOra = find.byKey(const Key('tavolo_fila_alzata'));
      if (filaOra.evaluate().isEmpty) continue;
      final dorsi = find
          .descendant(of: filaOra, matching: find.byType(CardBack))
          .evaluate()
          .length;
      if (dorsi > 0) dorsoVisto.add(ms);
    }
    expect(dorsoVisto, isEmpty,
        reason: 'risalendo lo scorrimento il dorso delle carte e\' tornato '
            'visibile, ai millisecondi: $dorsoVisto');
  });
}
