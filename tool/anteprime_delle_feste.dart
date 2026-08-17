import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/pittore_della_festa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE NOVE ANTEPRIME DELLE TRE FESTE. Ordine U voce 02, sbloccate dall'ordine V.
///
/// **Tre fotogrammi per Maestro, all'inizio, a meta' e alla fine.** Alla
/// larghezza vera del telefono di Mauro, 360 per 797. Sono le immagini su cui
/// dira' se e' una festa o no.
///
/// **UN TEST PER IMMAGINE, e non un ciclo dentro una prova sola.** La prima
/// stesura faceva le nove catture dentro un `testWidgets` solo e non arrivava
/// mai in fondo: `TimeoutException after 0:10:00.000000: Test timed out after
/// 10 minutes`, dopo aver prodotto la prima immagine. **Il tetto e' del singolo
/// test**, quindi nove catture in una prova lo incontrano e nove prove da una
/// cattura no. E' la forma che `test/screenshot_capture_test.dart` usa da
/// settimane, con centotredici prove da una cattura ciascuna: non era un harness
/// rotto, era una forma che in questo repo non ha mai funzionato.
///
/// **Allungare il tetto non sarebbe stata una correzione**: avrebbe spostato il
/// muro invece di togliere la ragione per cui ci si sbatte contro.
///
/// Si lancia a mano:
///
///     flutter test tool/anteprime_delle_feste.dart
void main() {
  const larghezza = 360.0;
  const altezza = 797.0;

  /// I TRE MOMENTI. Non a caso: l'inizio e' quando il fronte e' appena partito,
  /// la meta' e' quando riempie la scena, la fine e' quando ha scoperto cio' che
  /// c'era sotto.
  const momenti = {'inizio': 0.18, 'meta': 0.5, 'fine': 0.92};

  setUpAll(() async {
    // **IL FONT SI CARICA QUI perche' `test/flutter_test_config.dart` vale per
    // l'albero `test/` e non per `tool/`.** Non e' una seconda porta: e' una
    // conseguenza di dove vive questo file.
    final font = FontLoader('Cinzel')
      ..addFont(File('assets/fonts/Cinzel-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await font.load();
    // La festa unita monta la SCENA VERA, che porta il corpo in EBGaramond e
    // le icone Material: senza, la frase e i segni escono a scatole bianche,
    // guardato sulla prima cattura. Le icone stanno nella cache dell'SDK,
    // stessa risalita di test/flutter_test_config.dart.
    final corpo = FontLoader('EBGaramond')
      ..addFont(File('assets/fonts/EBGaramond-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await corpo.load();
    const relIcone = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
    final candidati = <String>[
      if (Platform.environment['FLUTTER_ROOT'] != null)
        '${Platform.environment['FLUTTER_ROOT']}/bin/cache/$relIcone',
    ];
    var cartella = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      candidati.add('${cartella.path}/$relIcone');
      candidati.add('${cartella.path}/bin/cache/$relIcone');
      cartella = cartella.parent;
    }
    for (final c in candidati) {
      if (File(c).existsSync()) {
        final icone = FontLoader('MaterialIcons')
          ..addFont(
              File(c).readAsBytes().then((b) => ByteData.view(b.buffer)));
        await icone.load();
        break;
      }
    }
  });

  Future<void> scatta(
      WidgetTester tester, Maestro maestro, String quando, double avanzamento) async {
    tester.view.physicalSize = const Size(larghezza * 3, altezza * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final palette = switch (maestro) {
      Maestro.medora => MaestroPalette.medora,
      Maestro.caligo => MaestroPalette.caligo,
      Maestro.aura => MaestroPalette.aura,
    };
    final chiave = GlobalKey();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: chiave,
        child: Container(
          width: larghezza,
          height: altezza,
          color: const Color(0xFF0B0D1A),
          child: Stack(
            children: [
              // Cio' che la festa scopre: il nome e il premio, come nella scena
              // vera. Senza, non si vedrebbe se la festa copre o apre.
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hai gettato le prime rune',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 26,
                            color: palette.gold)),
                    const SizedBox(height: 12),
                    Text('+20 Eos',
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 18,
                            color: palette.goldSoft)),
                  ],
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: PittoreDellaFesta(
                    maestro: maestro,
                    avanzamento: avanzamento,
                    oro: palette.gold,
                    oroTenue: palette.goldSoft,
                    eGrande: false,
                    effettiPieni: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    // **LA CATTURA STA DENTRO runAsync, ed e' la riga che toglieva il blocco.**
    // `toImage` e `toByteData` li completa il MOTORE sul tempo vero, mentre
    // dentro `testWidgets` il tempo e' finto: fuori da `runAsync` quella
    // promessa non viene mai osservata e la prova resta appesa fino al tetto dei
    // dieci minuti, **dopo che il file e' gia' stato scritto**. E' per questo
    // che le immagini uscivano lo stesso e il generatore falliva comunque.
    //
    // Il conteggio dice il resto: i due generatori che si fermavano erano gli
    // unici due con zero `runAsync`, e `test/screenshot_capture_test.dart` ne
    // ha quarantadue. Non si scrive niente di nuovo: si adotta la forma che nel
    // repo funziona gia'.
    await tester.runAsync(() async {
      final scatola =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await scatola.toImage(pixelRatio: 3.0);
      final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
      final dove = File('docs/preview/festa_${maestro.id}_$quando.png');
      dove.parent.createSync(recursive: true);
      dove.writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('anteprima: ${dove.path}');
    });
  }

  for (final maestro in Maestro.values) {
    for (final momento in momenti.entries) {
      testWidgets('festa ${maestro.id} ${momento.key}', (tester) async {
        await scatta(tester, maestro, momento.key, momento.value);
      });
    }
  }

  /// LA DECIMA: LA FESTA UNITA CON TRE TRAGUARDI. Ordine AC voce 04.
  ///
  /// Non e' un fotogramma del pittore: e' la SCENA VERA della celebrazione,
  /// coi tre nomi, la somma degli Eos e la frase del piu' importante. E'
  /// l'immagine su cui Mauro dira' se la festa unita e' una festa.
  testWidgets('festa unita tre', (tester) async {
    tester.view.physicalSize = const Size(larghezza * 3, altezza * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Il fondo cosmico ascolta i sensori, che in prova non esistono: si
    // silenziano, come fanno le prove che montano l'app intera.
    final messaggero =
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;
    messaggero.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (chiamata) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messaggero.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino();
    await diario.carica();
    final tre = [
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_1'),
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_6'),
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_8'),
    ];
    for (final t in tre) {
      await diario.accendi(t.id);
    }
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: chiave,
          child: MaestroScope(
            maestro: Maestro.caligo,
            child: CelebrazioneAScermoPieno(
              traguardi: tre,
              sentieri: const [
                Sentiero.albero,
                Sentiero.albero,
                Sentiero.albero,
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    // A fine corsa del segno: e' il fotogramma in cui tutto si legge.
    await tester.pump(const Duration(seconds: 8));
    await tester.runAsync(() async {
      final scatola =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await scatola.toImage(pixelRatio: 3.0);
      final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
      final dove = File('docs/preview/festa_unita_tre.png');
      dove.writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('anteprima: ${dove.path}');
    });
  });
}
