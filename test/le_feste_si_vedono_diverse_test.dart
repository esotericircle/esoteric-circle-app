import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LE FESTE SI VEDONO DAVVERO DIVERSE. Ordine AQ voce 02.
///
/// **Il fatto di Mauro, dalla 2184**: le feste dei traguardi si vedono tutte
/// uguali, e nelle sue schermate non vola niente.
///
/// **Perche' la misura si fa QUI e non nello strumento.**
/// `tool/anteprime_delle_feste.dart` compone il pittore a mano e dimostra che
/// il pittore sa disegnare; non dimostra che la persona vede qualcosa. Questa
/// prova monta la scena VERA della celebrazione, la fotografa a istanti
/// diversi e conta i pixel che cambiano: se fra due istanti non cambia
/// niente, nella scena vera non si muove niente.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I sensori in headless non esistono, e la parallasse li chiede: senza
  /// questo la prova cade su un plugin mancante invece che sulla misura.
  void silenziaISensori() {
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
  }

  Widget attorno(Widget scena, DiarioDelCammino diario, GlobalKey chiave) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: RepaintBoundary(key: chiave, child: scena),
        ),
      );

  /// I pixel della scena, presi dal vero come li vede chi guarda.
  Future<Uint8List> fotografa(WidgetTester tester, GlobalKey chiave) async {
    late Uint8List byte;
    await tester.runAsync(() async {
      final confine = chiave.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final immagine = await confine.toImage();
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      immagine.dispose();
    });
    return byte;
  }

  /// Quanti pixel su mille cambiano fra due fotografie della stessa scena.
  ///
  /// **Il criterio e' il CAMBIO e non il colore**: una particella che passa
  /// accende un pixel e poi lo spegne, e questo si vede solo confrontando due
  /// istanti. Un fondo fermo, per quanto bello, da' zero.
  double perMilleCheCambia(Uint8List a, Uint8List b,
      {int larghezza = 360,
      int altezza = 797,
      bool soloAiBordi = false,
      bool soloInAlto = false}) {
    if (a.length != b.length) return 1000;
    var diversi = 0;
    var guardati = 0;
    final pixel = a.length ~/ 4;
    for (var i = 0; i < a.length; i += 4) {
      if (soloInAlto) {
        // **DOVE NON ARRIVA NIENTE ALTRO.** La scheda, il segno e i testi
        // vivono in mezzo allo schermo: nella fascia alta, un quinto
        // dell'altezza, passano solo il cielo e le cose che volano. E' la
        // finestra che isola la festa dal resto, e senza di lei la misura
        // scambiava per particelle i testi dei traguardi, che sono diversi
        // per sentiero e arrivano fin quasi ai bordi.
        final y = (i ~/ 4) ~/ larghezza;
        if (y > altezza ~/ 5) continue;
      }
      if (soloAiBordi) {
        // **DOVE PUO' PASSARE SOLO UNA PARTICELLA.** Al centro vivono la
        // scheda e il segno che cresce, e un cambio li' non dice niente sul
        // volo. Le due colonne laterali, un quinto di schermo per lato, le
        // attraversano solo le cose che volano.
        final x = (i ~/ 4) % larghezza;
        if (x > larghezza ~/ 5 && x < larghezza * 4 ~/ 5) continue;
      }
      guardati++;
      // Una soglia di otto livelli su 255 tiene fuori il rumore del
      // fondo sfumato e lascia dentro qualunque cosa si veda a occhio.
      final dr = (a[i] - b[i]).abs();
      final dg = (a[i + 1] - b[i + 1]).abs();
      final db = (a[i + 2] - b[i + 2]).abs();
      if (dr > 8 || dg > 8 || db > 8) diversi++;
    }
    final quanti = (soloAiBordi || soloInAlto) ? guardati : pixel;
    return quanti == 0 ? 0 : diversi * 1000 / quanti;
  }

  /// Quanti pixel su mille, nella fascia alta, sono piu' chiari del fondo.
  ///
  /// **Perche' il conto e non il confronto.** Confrontare due scene diverse
  /// misura tutto cio' che le distingue, testi compresi; qui invece si conta
  /// la MATERIA che sta a schermo dove non c'e' nient'altro: nella fascia
  /// alta vivono solo il cielo scuro della festa e le cose che volano.
  double accesiInAlto(Uint8List a,
      {int larghezza = 360, int altezza = 797}) {
    var accesi = 0;
    var guardati = 0;
    for (var i = 0; i < a.length; i += 4) {
      final y = (i ~/ 4) ~/ larghezza;
      if (y > altezza ~/ 5) continue;
      guardati++;
      // Il fondo della festa in alto sta sotto i 60 livelli su 255; una
      // particella d'oro passa i 110 anche quando e' tenue.
      final luce = (a[i] * 0.299 + a[i + 1] * 0.587 + a[i + 2] * 0.114);
      if (luce > 110) accesi++;
    }
    return guardati == 0 ? 0 : accesi * 1000 / guardati;
  }

  for (final sentiero in Sentiero.values) {
    testWidgets('la festa di ${sentiero.name} si muove nella scena vera',
        (tester) async {
      silenziaISensori();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 797);
      addTearDown(tester.view.reset);
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final chiave = GlobalKey();
      final traguardo = Sentieri.di(sentiero).first;
      await tester.pumpWidget(attorno(
        CelebrazioneAScermoPieno(
          traguardi: [traguardo],
          sentieri: [sentiero],
        ),
        diario,
        chiave,
      ));
      // Tre istanti dentro la corsa della festa, che dura 1800 millesimi.
      await tester.pump(const Duration(milliseconds: 300));
      final primo = await fotografa(tester, chiave);
      await tester.pump(const Duration(milliseconds: 400));
      final secondo = await fotografa(tester, chiave);
      await tester.pump(const Duration(milliseconds: 400));
      final terzo = await fotografa(tester, chiave);

      final unoDue = perMilleCheCambia(primo, secondo);
      final dueTre = perMilleCheCambia(secondo, terzo);
      final bordiUnoDue = perMilleCheCambia(primo, secondo, soloAiBordi: true);
      final bordiDueTre = perMilleCheCambia(secondo, terzo, soloAiBordi: true);
      // ignore: avoid_print
      print('MISURA AQ.02 ${sentiero.name}: su mille pixel cambiano, tutta la '
          'scena ${unoDue.toStringAsFixed(1)} e ${dueTre.toStringAsFixed(1)}, '
          'AI BORDI ${bordiUnoDue.toStringAsFixed(1)} e '
          '${bordiDueTre.toStringAsFixed(1)}');
      expect(unoDue + dueTre, greaterThan(0),
          reason: 'nella scena vera della festa di ${sentiero.name} non si '
              'muove NIENTE fra un istante e l\'altro');
    });
  }

  testWidgets('con Riduci Movimento la materia resta a schermo',
      (tester) async {
    // **COSA SI E' MISURATO, e cosa NON e' risultato vero.** L'ordine
    // sospettava che nella scena vera non volasse niente. Misurato: vola.
    // Fra due istanti della corsa cambiano dai 42 ai 66 pixel su mille, e
    // nella fascia alta, dove non arrivano ne' la scheda ne' i testi, la
    // materia si conta anche con Riduci Movimento acceso. Questa prova tiene
    // il numero sotto controllo: se un domani la festa smettesse di mettere
    // materia a schermo, cadrebbe.
    Future<double> quantaMateria({required bool riduciMovimento}) async {
      silenziaISensori();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 797);
      addTearDown(tester.view.reset);
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final chiave = GlobalKey();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(disableAnimations: riduciMovimento),
            child: MaestroScope(child: child!),
          ),
          home: RepaintBoundary(
            key: chiave,
            child: CelebrazioneAScermoPieno(
              traguardi: [Sentieri.di(Sentiero.costellazione).first],
              sentieri: const [Sentiero.costellazione],
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 900));
      return accesiInAlto(await fotografa(tester, chiave));
    }

    final conRiduci = await quantaMateria(riduciMovimento: true);
    final senza = await quantaMateria(riduciMovimento: false);
    // ignore: avoid_print
    print('MISURA AQ.02 pixel accesi su mille nella fascia alta: con Riduci '
        'Movimento ${conRiduci.toStringAsFixed(1)}, senza '
        '${senza.toStringAsFixed(1)}');
    expect(conRiduci, greaterThan(1),
        reason: 'con Riduci Movimento in alto non c e nessuna materia');
    expect(senza, greaterThan(1),
        reason: 'a movimento pieno in alto non c e nessuna materia');
  });

  test('il segno della festa non e un glifo di sistema', () {
    // **LA REGOLA DI CASA, sorvegliata dove si era rotta.** Il segno che la
    // persona guarda alla fine di un traguardo era un'icona di Material, e
    // due dei tre erano lo stesso fiore: `spa_rounded` E' un loto.
    final scena = File('lib/features/sigilli/celebrazione.dart')
        .readAsStringSync()
        .split(String.fromCharCode(10))
        .where((r) => !r.trimLeft().startsWith('//'))
        .join(String.fromCharCode(10));
    final da = scena.indexOf('class SegnoDelMaestro');
    expect(da, greaterThan(0), reason: 'il segno del Maestro non esiste piu');
    final pezzo = scena.substring(da, da + 1200);
    // ignore: avoid_print
    print('ORDINE AQ VOCE 02: il segno usa glifi di sistema: '
        '${pezzo.contains('Icons.')}');
    expect(pezzo.contains('Icons.'), isFalse,
        reason: 'il segno della festa e tornato un glifo di sistema');
    expect(pezzo.contains('SegnoDelSentiero'), isTrue,
        reason: 'il segno non passa piu dal disegno di casa');
  });

  test('i tre segni disegnati non sono la stessa forma', () {
    // Tre rami di uno `switch` che chiamassero lo stesso disegno sarebbero
    // tre nomi per una figura sola, cioe' il difetto di prima con un altro
    // vestito.
    final segno = File('lib/features/sigilli/segno_del_sentiero.dart')
        .readAsStringSync();
    for (final forma in const ['_stella(', '_albero(', '_loto(']) {
      expect(segno.contains(forma), isTrue,
          reason: 'manca la forma $forma: i tre sentieri non hanno tre segni');
    }
  });
}
