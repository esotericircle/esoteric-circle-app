import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/settings/riga_di_messa_a_punto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CIELO SI MUOVE DELLA CORSA CHE GLI SPETTA. Ordine AR voce 01.
///
/// **Le due domande, separate.** La prima e' se la FORMULA da' la corsa
/// giusta, e si risponde con l'aritmetica del controller. La seconda, che e'
/// quella che Mauro sente in mano, e' se il cielo a schermo USA quella corsa:
/// e a quella si risponde solo dipingendo la scena vera e guardando i pixel.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// **IL SENSORE IN PROVA NON ESISTE, e va detto invece che subito.** Il
  /// controller apre lo stream dell'accelerometro nel costruttore: in
  /// headless il canale non c'e' e l'eccezione arriva ASINCRONA, cioe' fuori
  /// dal `try` che il controller ha attorno. Qui si mette un canale finto,
  /// cosi' la prova misura il movimento e non il plugin mancante.
  setUp(() {
    final messaggero = binding.defaultBinaryMessenger;
    messaggero.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messaggero.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  });

  /// **LA TABELLA DELLA CORSA ATTESA, fatto F3 dell'ordine.** Nasce dalle
  /// costanti (tiltRange 500, riferimento 0.16, compressione 0.15) e non da
  /// una build: e' il bersaglio, e resta il bersaglio anche quando il codice
  /// attorno cambia.
  const corsaAttesa = <String, (double, double)>{
    'polvere': (ProfonditaDeiPiani.polvere, 30.0),
    'fondo': (ProfonditaDeiPiani.fondo, 80.0),
    'medio': (ProfonditaDeiPiani.medio, 105.5),
    'vicino': (ProfonditaDeiPiani.vicino, 165.5),
  };

  test('la corsa di ogni piano vale quella attesa, entro il cinque per cento',
      () {
    final parallasse = ParallaxController();
    parallasse.inclinaPerLaProva(1, 0);
    final righe = <String>[];
    for (final voce in corsaAttesa.entries) {
      final misurata = parallasse.layerOffset(voce.value.$1).dx;
      final attesa = voce.value.$2;
      righe.add('${voce.key} ${misurata.toStringAsFixed(1)} su $attesa');
      expect((misurata - attesa).abs() / attesa, lessThan(0.05),
          reason: 'il piano ${voce.key} corre ${misurata.toStringAsFixed(1)} '
              'punti invece di $attesa: la formula approvata sulla 2181 e '
              'cambiata');
    }
    // ignore: avoid_print
    print('MISURA AR.01 corsa dei piani a fondo corsa: ${righe.join(', ')}');
    parallasse.dispose();
  });

  test('a trenta gradi la corsa e la meta di quella satura', () {
    // Trenta gradi su novanta di saturazione fanno un tilt normalizzato di
    // 0,5: la tabella dell'ordine dice esattamente la meta'.
    final parallasse = ParallaxController();
    parallasse.inclinaPerLaProva(0.5, 0);
    for (final voce in corsaAttesa.entries) {
      final misurata = parallasse.layerOffset(voce.value.$1).dx;
      expect((misurata - voce.value.$2 / 2).abs() / (voce.value.$2 / 2),
          lessThan(0.05),
          reason: 'a mezza inclinazione il piano ${voce.key} non corre la '
              'meta: ${misurata.toStringAsFixed(1)}');
    }
    parallasse.dispose();
  });

  /// I pixel della scena montata.
  Future<Uint8List> fotografa(WidgetTester tester, GlobalKey chiave) async {
    late Uint8List byte;
    await tester.runAsync(() async {
      final confine =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await confine.toImage();
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      immagine.dispose();
    });
    return byte;
  }

  double perMilleCheCambia(Uint8List a, Uint8List b) {
    if (a.length != b.length) return 1000;
    var diversi = 0;
    for (var i = 0; i < a.length; i += 4) {
      if ((a[i] - b[i]).abs() > 6 ||
          (a[i + 1] - b[i + 1]).abs() > 6 ||
          (a[i + 2] - b[i + 2]).abs() > 6) {
        diversi++;
      }
    }
    return diversi * 4000 / a.length;
  }

  testWidgets('IL CIELO USA IL CONTROLLER CHE IL SENSORE ALIMENTA',
      (tester) async {
    // **LA MISURA CHE DECIDE TUTTO L'ORDINE.** Sul telefono il sensore
    // alimenta il controller che vive nei provider dell'app. Se il cielo ne
    // guarda un altro, la formula puo' essere perfetta e la persona non
    // vedra' muoversi niente: e' la differenza fra un cielo che corre 80
    // punti e uno che ne fa due.
    //
    // Si inclina il controller DEI PROVIDER fino a fondo corsa e si guarda se
    // i pixel della scena cambiano.
    final parallasse = ParallaxController();
    addTearDown(parallasse.dispose);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<ParallaxController>.value(value: parallasse),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: RepaintBoundary(
          key: chiave,
          child: const Scaffold(
            body: CosmosBackground(seed: 13, child: SizedBox.expand()),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final fermo = await fotografa(tester, chiave);

    parallasse.inclinaPerLaProva(1, 1);
    await tester.pump(const Duration(milliseconds: 16));
    final inclinato = await fotografa(tester, chiave);

    final quanto = perMilleCheCambia(fermo, inclinato);
    // ignore: avoid_print
    print('MISURA AR.01 inclinando il controller dei provider cambiano '
        '${quanto.toStringAsFixed(1)} pixel su mille');
    expect(quanto, greaterThan(5),
        reason: 'il cielo NON guarda il controller dei provider: inclinandolo '
            'a fondo corsa la scena resta identica. Sul telefono quel '
            'controller e l unico che il sensore alimenta, quindi la persona '
            'vede solo la deriva di ripiego, che sul piano fondo vale meno di '
            'due punti');
  });

  testWidgets('il cielo si ridipinge a ogni notifica della parallasse',
      (tester) async {
    // Quindici notifiche al secondo (fatto F4) devono diventare quindici
    // ridisegni, non uno ogni due secondi.
    final parallasse = ParallaxController();
    addTearDown(parallasse.dispose);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<ParallaxController>.value(value: parallasse),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: RepaintBoundary(
          key: chiave,
          child: const Scaffold(
            body: CosmosBackground(seed: 13, child: SizedBox.expand()),
          ),
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    // Quindici inclinazioni diverse, come un secondo di sensore vero.
    var cambiati = 0;
    var prima = await fotografa(tester, chiave);
    for (var i = 1; i <= 15; i++) {
      parallasse.inclinaPerLaProva(i / 15, 0);
      await tester.pump(const Duration(milliseconds: 66));
      final dopo = await fotografa(tester, chiave);
      if (perMilleCheCambia(prima, dopo) > 1) cambiati++;
      prima = dopo;
    }
    // ignore: avoid_print
    print('MISURA AR.01 su quindici notifiche il cielo e cambiato '
        '$cambiati volte');
    expect(cambiati, greaterThanOrEqualTo(13),
        reason: 'il cielo si e ridisegnato solo $cambiati volte su quindici '
            'notifiche del sensore: il movimento arriva a scatti o non arriva');
  });

  testWidgets('la riga di messa a punto dice il vero, e cambia col tilt',
      (tester) async {
    // **SERVE A MAURO PER NON DOVER PIU' DESCRIVERE A PAROLE.** Se questa
    // riga mostrasse numeri fermi sarebbe peggio di niente: direbbe la stessa
    // bugia che deve smascherare.
    final parallasse = ParallaxController();
    addTearDown(parallasse.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<ParallaxController>.value(value: parallasse),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Scaffold(body: Center(child: RigaDiMessaAPunto())),
      ),
    ));
    await tester.pump();
    String numeri() => tester
        .widget<Text>(find.byKey(const Key('messa_a_punto_numeri')))
        .data!;
    final fermo = numeri();
    parallasse.inclinaPerLaProva(1, 0);
    await tester.pump();
    final inclinato = numeri();
    // ignore: avoid_print
    print('MISURA AR.01 la riga dice, da fermo: "$fermo"');
    // ignore: avoid_print
    print('MISURA AR.01 la riga dice, inclinato: "$inclinato"');
    expect(inclinato, isNot(fermo),
        reason: 'la riga di messa a punto non cambia mentre il telefono si '
            'inclina: e un numero morto');
    expect(inclinato, contains('80.0'),
        reason: 'a fondo corsa la riga deve dire gli 80 punti del piano di '
            'fondo: "$inclinato"');
    expect(find.byKey(const Key('messa_a_punto_sensore')), findsOneWidget,
        reason: 'la riga non dice se il sensore vive, che e la prima domanda');
  });
}
